From: Leonardo Chiquitto <leonardo.lists@gmail.com>
Subject: POLLPRI/poll() behavior change since 2.6.31
Date: Thu, 6 Jan 2011 13:50:41 -0200
Message-ID: <20110106155040.GA27769@libre.l.ngdn.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eric Dumazet <dada1@cosmosbay.com>,
	"David S. Miller" <davem@davemloft.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-gy0-f174.google.com ([209.85.160.174]:47614 "EHLO
	mail-gy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753109Ab1AFPuu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Jan 2011 10:50:50 -0500
Received: by gyb11 with SMTP id 11so6180101gyb.19
        for <netdev@vger.kernel.org>; Thu, 06 Jan 2011 07:50:49 -0800 (PST)
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

Since 2.6.31, poll() no longer returns when waiting exclusively for a
POLLPRI event. If we wait for POLLPRI | POLLIN, though, it will
correctly return POLLPRI as a received event.

The reproducer (code below) will print the following when running on
2.6.30:

$ ./pollpri-oob 
main: starting
main: setup_pipe ok (sfd[0] = 5, sfd[1] = 4)
parent: child <pid 3790> started
child: polling...
parent: sending the message
parent: waiting for child to exit
child: poll(): some data <1,2> has arrived!
child: done
parent: done

... and will block when running on 2.6.37-rc7:

$ ./pollpri-oob 
main: starting
main: setup_pipe ok (sfd[0] = 5, sfd[1] = 4)
parent: child <pid 14148> started
child: polling...
parent: sending the message
parent: waiting for child to exit
[hangs here]

I've bisected this behavior change to the following commit:

commit 4938d7e0233a455f04507bac81d0886c71529537
Author: Eric Dumazet <dada1@cosmosbay.com>
Date:   Tue Jun 16 15:33:36 2009 -0700

  poll: avoid extra wakeups in select/poll

  After introduction of keyed wakeups Davide Libenzi did on epoll, we are
  able to avoid spurious wakeups in poll()/select() code too.

  For example, typical use of poll()/select() is to wait for incoming
  network frames on many sockets.  But TX completion for UDP/TCP frames call
  sock_wfree() which in turn schedules thread.

  When scheduled, thread does a full scan of all polled fds and can sleep
  again, because nothing is really available.  If number of fds is large,
  this cause significant load.

  This patch makes select()/poll() aware of keyed wakeups and useless
  wakeups are avoided.  This reduces number of context switches by about 50%
  on some setups, and work performed by sofirq handlers.


I don't know if the new behavior is correct, but we've got one report of
an application that broke due to the change.

Thanks,
Leonardo

#define _BSD_SOURCE
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/ioctl.h>
#include <sys/wait.h>
#include <sys/stat.h>
#include <sys/un.h>
#include <netinet/in.h>
#include <arpa/inet.h>
#include <stdio.h>
#include <unistd.h>
#include <stdlib.h>
#include <errno.h>
#include <fcntl.h>
#include <poll.h>

int setup_pipe(int f[2])
{
	int ret, server, client, client_ofl;
	struct sockaddr_in own_sa;
	struct sockaddr a_sa;
	socklen_t a_len;

	/* server side */
	if ((server = socket(PF_INET, SOCK_STREAM, 0)) < 0)
		return -1;
	own_sa.sin_family = AF_INET;
	own_sa.sin_addr.s_addr = htonl(INADDR_LOOPBACK);
	own_sa.sin_port = htons(10789);
	if (bind(server, (struct sockaddr *)&own_sa, sizeof(own_sa)) != 0)
		return -1;
	if (listen(server, 1) < 0)
		return -1;

	/* client side */
	if ((client = socket(PF_INET, SOCK_STREAM, 0)) < 0)
		return -1;
	if ((client_ofl = fcntl(client, F_GETFL)) < 0)
		return -1;
	if (fcntl(client, F_SETFL, client_ofl | O_NONBLOCK) < 0)
		return -1;
	ret = connect (client, (struct sockaddr *) &own_sa, sizeof(own_sa));
	if (ret != 0 && errno != EINPROGRESS)
		return -1;

	if ((f[0] = accept(server, &a_sa, &a_len)) < 0)
		return -1;
	f[1] = client;

	return 0;
}

int child_proc(int fd)
{
	struct pollfd fds;
	int ret;

	fds.fd = fd;
	fds.events = POLLPRI;

	printf("child: polling...\n");
	ret = poll(&fds, 1, -1);
	if (ret > 0)
		printf("child: poll(): some data <%d,%d> has arrived!\n",
				ret, fds.revents);
	printf("child: done\n");

	return 0;
}

int main(int argc, char *argv[])
{
	int sfd[2] = { -1, -1 };
	pid_t child_pid;

	printf("main: starting\n");

	if (setup_pipe(sfd) == -1) {
		fprintf(stderr, "main: error in setup_pipe()\n");
		return -1;
	}
	printf("main: setup_pipe ok (sfd[0] = %d, sfd[1] = %d)\n",
			sfd[0], sfd[1]);

	switch (child_pid = fork()) {
	case -1:
		fprintf(stderr, "main: fork() error\n");
		exit(1);
	case 0:
		return child_proc(sfd[0]);
	default:
		printf("parent: child <pid %d> started\n", child_pid);
		sleep(1);
		printf("parent: sending the message\n");
		send(sfd[1], "a", 1, MSG_OOB);
		printf("parent: waiting for child to exit\n");
		waitpid(child_pid, NULL, 0);
		printf("parent: done\n");
	}
	return 0;
}
