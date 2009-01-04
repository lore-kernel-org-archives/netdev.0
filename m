From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: splice from half-closed socket returning -EAGAIN
Date: Sun, 4 Jan 2009 14:30:54 +0100
Message-ID: <20090104133054.GB16185@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ben Mansell <ben@zeus.com>, netdev@vger.kernel.org
To: Jens Axboe <jens.axboe@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([80.101.37.227]:55296 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751531AbZADNy3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 4 Jan 2009 08:54:29 -0500
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When doing a nonblocking splice() from a half-closed TCP socket
(POLLRDHUP, FIN sent by the other side), I get -EAGAIN, while I was
expecting that to return zero.  Non-blocking read/readv/recv/recvfrom/
recvmsg on a half-closed socket also returns zero AFAIK, and in
general, a zero return on a read operation meaning "EOF" seems to be
well-established.

Is there any reason why splice() doesn't do this?  -EAGAIN hints that
the operation might succeed in the future, but since the socket is
half-closed, this won't ever happen.  Also, it's kind of annoying to
have to poll for POLLRDHUP separately, as this isn't needed when using
"copyful" socket I/O -- and there doesn't seem to be any other way of
telling that a half-close has occured on the source socket.

(Test app attached, tested on 2.6.27.5 and 2.6.28.)


thanks,
Lennert




#define _GNU_SOURCE

#include <stdio.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <netinet/in.h>
#include <string.h>
#include <unistd.h>

int listening_fd;
int connecting_fd;
int accepted_fd;


int main()
{
	struct sockaddr_in addr;
	socklen_t addrlen;
	int pfd[2];
	int ret;

	/*
	 * Step 1: set up listening socket.
	 */
	listening_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (listening_fd < 0) {
		perror("socket");
		abort();
	}

	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(INADDR_ANY);
	addr.sin_port = htons(6667);
	if (bind(listening_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("bind");
		abort();
	}

	listen(listening_fd, 1);


	/*
	 * Step 2: set up socket to connect to listening socket
	 * created in step 1.
 	 */
	connecting_fd = socket(AF_INET, SOCK_STREAM, 0);
	if (connecting_fd < 0) {
		perror("socket");
		exit(-1);
	}

	addr.sin_family = AF_INET;
	addr.sin_addr.s_addr = htonl(0x7f000001);
	addr.sin_port = htons(6667);
	if (connect(connecting_fd, (struct sockaddr *)&addr, sizeof(addr)) < 0) {
		perror("connect");
		exit(-1);
	}


	/*
	 * Step 3: accept the connection created in step 2.
	 */
	addrlen = sizeof(addr);
	accepted_fd = accept(listening_fd, (struct sockaddr *)&addr, &addrlen);
	if (accepted_fd < 0) {
		perror("accept");
		exit(-1);
	}


	/*
	 * Step 4: close the other half of the connection, and try
	 * to splice into a pipe.
	 */
	close(connecting_fd);

	if (pipe(pfd) < 0) {
		perror("pipe");
		exit(-1);
	}

	ret = splice(accepted_fd, NULL, pfd[1], NULL, 4096, SPLICE_F_NONBLOCK);
	printf("splice returned %d\n", ret);
	if (ret < 0)
		perror("splice");

	return 0;
}
