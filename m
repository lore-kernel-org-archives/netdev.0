From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: Data corruption issue with splice() on 2.6.27.10
Date: Mon, 19 Jan 2009 09:39:21 +0100
Message-ID: <20090119083921.GA17124@xi.wantstofly.org>
References: <20081224152841.GB13113@1wt.eu> <20090106183223.GA11964@ioremap.net> <20090106185012.GA30322@1wt.eu>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Evgeniy Polyakov <zbr@ioremap.net>,
	Jens Axboe <jens.axboe@oracle.com>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Willy Tarreau <w@1wt.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:46657 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752897AbZASIjX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Jan 2009 03:39:23 -0500
Content-Disposition: inline
In-Reply-To: <20090106185012.GA30322@1wt.eu>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 06, 2009 at 07:50:12PM +0100, Willy Tarreau wrote:

> > Thanks a lot for the test application, it will greatly help to resolve
> > this issue.
> 
> I figured it was an absolute necessity. The original code in my proxy is in
> an experimental state and far too hard to debug for these purposes. It was
> enough to detect the problem, but I could run a lot more tests with this
> small test app ! An who know, maybe it will serve as an example for
> non-blocking splice ;-)

:-)

Just to throw some more (hacky) example code into the pool, below is
an echo server that I hacked up to test nonblocking splice().  (You'll
need sf.net/projects/libivykis to use it.)  I also have a splice()
discard server and a patch to my intercept-connection-via-iptables-and-
forward-it-to-a-remote-SOCKS5-server-to-deal-with-crappy-VPNs app to
use splice() somewhere.

My main annoyances with splice(2) are/were:

1. -EAGAIN return on splice from socket/pipe to socket/pipe doesn't
   directly tell you whether the source ran out of data or the
   destination can't accept more data, which means you can't e.g. use
   epoll in edge triggered mode without jumping through some minor
   number of extra hoops.  (For a pipe you can keep track of how many
   bytes are in it by hand, but for a socket->pipe splice -EAGAIN return
   you'll have to assume that the pipe is full if there are >0 bytes in
   it.)

2. Because of (1), and because when splicing from a socket to a pipe
   it returns after the first bit of data (you mentioned this as well),
   you don't know at that point whether your pipe is full or not.

3. Always returns -EAGAIN even if there was a FIN or error on the
   source socket.  (Now fixed.)



#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <iv.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <signal.h>
#include <sys/ioctl.h>
#include <sys/socket.h>
#include <sys/types.h>
#include <time.h>
#include <unistd.h>

struct connection {
	struct iv_fd sock;
	int pfd[2];
	int pipe_bytes;
	int saw_fin;
};


static void conn_kill(struct connection *conn)
{
	iv_unregister_fd(&conn->sock);
	close(conn->sock.fd);
	close(conn->pfd[0]);
	close(conn->pfd[1]);
	free(conn);
}

static void conn_pollin(void *_conn);
static void conn_pollout(void *_conn);
static void conn_pollerr(void *_conn);

static void conn_pollin(void *_conn)
{
	struct connection *conn = (struct connection *)_conn;
	int ret;

	while (1) {
		ret = splice(conn->sock.fd, NULL, conn->pfd[1], NULL,
			     1048576, SPLICE_F_NONBLOCK);
		if (ret <= 0)
			break;

		if (conn->pipe_bytes == 0)
			iv_fd_set_handler_out(&conn->sock, conn_pollout);
		conn->pipe_bytes += ret;
	}

	if (ret == 0) {
		conn->saw_fin = 1;
		iv_fd_set_handler_in(&conn->sock, NULL);
		if (conn->pipe_bytes == 0) {
			shutdown(conn->sock.fd, SHUT_WR);
			conn_kill(conn);
		}
		return;
	}

	if (errno == EAGAIN && conn->pipe_bytes > 0) {
		int bytes_sock = 1;

		ioctl(conn->sock.fd, FIONREAD, &bytes_sock);
		if (bytes_sock > 0)
			iv_fd_set_handler_in(&conn->sock, NULL);
	} else if (errno != EAGAIN) {
		conn_kill(conn);
	}
}

static void conn_pollout(void *_conn)
{
	struct connection *conn = (struct connection *)_conn;
	int ret;

	if (!conn->pipe_bytes) {
		fprintf(stderr, "conn_pollout: no pipe bytes!\n");
		abort();
	}

	do {
		ret = splice(conn->pfd[0], NULL, conn->sock.fd, NULL,
			     conn->pipe_bytes, 0);
		if (ret <= 0)
			break;

		conn->pipe_bytes -= ret;
		if (!conn->saw_fin)
			iv_fd_set_handler_in(&conn->sock, conn_pollin);
	} while (conn->pipe_bytes);

	if (ret == 0) {
		fprintf(stderr, "pollout: splice returned zero!\n");
		abort();
	}

	if (errno == EAGAIN && conn->pipe_bytes == 0) {
		iv_fd_set_handler_out(&conn->sock, NULL);
		if (conn->saw_fin) {
			shutdown(conn->sock.fd, SHUT_WR);
			conn_kill(conn);
		}
	} else if (errno != EAGAIN) {
		conn_kill(conn);
	}
}

static void conn_pollerr(void *_conn)
{
	struct connection *conn = (struct connection *)_conn;
	socklen_t len;
	int ret;

	len = sizeof(ret);
	if (getsockopt(conn->sock.fd, SOL_SOCKET, SO_ERROR, &ret, &len) < 0) {
		fprintf(stderr, "pollerr: error %d while "
				"getsockopt(SO_ERROR)\n", errno);
		abort();
	}

	if (ret == 0) {
		fprintf(stderr, "pollerr: no error?!\n");
		abort();
	}

	conn_kill(conn);
}


static struct iv_fd listening_socket;

static void got_connection(void *_dummy)
{
	struct sockaddr_in addr;
	struct connection *conn;
	socklen_t addrlen;
	int ret;

	addrlen = sizeof(addr);
	ret = accept(listening_socket.fd, (struct sockaddr *)&addr, &addrlen);
	if (ret < 0)
		return;

	conn = malloc(sizeof(*conn));
	if (conn == NULL) {
		fprintf(stderr, "memory squeeze\n");
		abort();
	}

	if (pipe(conn->pfd) < 0) {
		fprintf(stderr, "pipe squeeze\n");
		abort();
	}

	INIT_IV_FD(&conn->sock);
	conn->sock.fd = ret;
	conn->sock.cookie = (void *)conn;
	conn->sock.handler_in = conn_pollin;
	conn->sock.handler_err = conn_pollerr;
	iv_register_fd(&conn->sock);

	conn->pipe_bytes = 0;
	conn->saw_fin = 0;
}

static int open_listening_socket(void)
{
	struct sockaddr_in addr;
	int sock;

	sock = socket(AF_INET, SOCK_STREAM, 0);
	if (sock < 0) {
		perror("socket");
		return 1;
	}

	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(6969);
	if (bind(sock, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("bind");
		return 1;
	}

	listen(sock, 5);

	INIT_IV_FD(&listening_socket);
	listening_socket.fd = sock;
	listening_socket.cookie = NULL;
	listening_socket.handler_in = got_connection;
	iv_register_fd(&listening_socket);

	return 0;
}

int main()
{
	iv_init();
	open_listening_socket();
	iv_main();

	return 0;
}
