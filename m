From: Daniel Lezcano <daniel.lezcano@free.fr>
Subject: Re: Kernel panic in inet_twdr_do_twkill_work
Date: Thu, 14 May 2009 11:42:02 +0200
Message-ID: <4A0BE76A.8070408@free.fr>
References: <m17i0ktr4p.fsf@fess.ebiederm.org> <4A0BCE0E.3000206@free.fr>	<m1y6t0nlle.fsf@fess.ebiederm.org> <4A0BD750.4030605@free.fr> <m18wl0nj2b.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040504080804070008070202"
Cc: netdev@vger.kernel.org, "Denis V. Lunev" <den@openvz.org>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mtagate2.de.ibm.com ([195.212.17.162]:52552 "EHLO
	mtagate2.de.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752809AbZENJmF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 May 2009 05:42:05 -0400
Received: from d12nrmr1607.megacenter.de.ibm.com (d12nrmr1607.megacenter.de.ibm.com [9.149.167.49])
	by mtagate2.de.ibm.com (8.13.1/8.13.1) with ESMTP id n4E9g55P009472
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 09:42:05 GMT
Received: from d12av01.megacenter.de.ibm.com (d12av01.megacenter.de.ibm.com [9.149.165.212])
	by d12nrmr1607.megacenter.de.ibm.com (8.13.8/8.13.8/NCO v9.2) with ESMTP id n4E9g5x03662018
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 11:42:05 +0200
Received: from d12av01.megacenter.de.ibm.com (loopback [127.0.0.1])
	by d12av01.megacenter.de.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id n4E9g4Pb015827
	for <netdev@vger.kernel.org>; Thu, 14 May 2009 11:42:04 +0200
In-Reply-To: <m18wl0nj2b.fsf@fess.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------040504080804070008070202
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Eric W. Biederman wrote:
> Daniel Lezcano <daniel.lezcano@free.fr> writes:
>
>   
>> May be you can activate the NETNS_REFCNT_DEBUG in order to check if the timewait
>> socket
>> were destroyed at the namespace destruction ? Unfortunately it looks like the
>> option is not in the Kconfig :(
>>     
>
> Looks like a good starting place.
>
> I will enable that when I respin my internal kernel.
>
> I don't have a good reproducer at the moment....  So I was hoping we could
> figure this out with code inspection.
>   
I found this one which makes a lot of timewait sockets. I tried on a 
2.6.29 kernel and I was not able to reproduce it. Can you check if this 
program reproduce the bug ?

--------------040504080804070008070202
Content-Type: text/x-csrc;
 name="timewait.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="timewait.c"

#include <stdio.h>
#include <string.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/poll.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include <unistd.h>

#define MAXCONN 10000

int client(int *fds)
{
	int i, len;
	struct sockaddr_in6 addr;

	close(fds[1]);

	memset(&addr, 0, sizeof(addr));

        addr.sin6_family = AF_INET6;
        addr.sin6_port = htons(10000);
        addr.sin6_addr = in6addr_loopback;

	if (read(fds[0], &i, sizeof(i)) == -1) {
		perror("read");
		return 1;
	}

	for (i = 0; i < MAXCONN; i++) {
		int fd = socket(PF_INET6, SOCK_STREAM, 0);
		if (fd == -1) {
			perror("socket");
			return 1;
		}

		if (connect(fd, (const struct sockaddr *)&addr, sizeof(addr))) {
			perror("connect");
			return 1;
		}
		
		len = write(fd, &fd, sizeof(fd));
		if (!len) {
			fprintf(stderr, "write wrote 0 bytes\n");
			return 1;
		}
		if (len == -1) {
			perror("write");
			return 1;
		}
	}

	return 0;
}

int server(int *fds)
{
	int i, fd, fdpoll[MAXCONN];
	struct sockaddr_in6 addr;
	socklen_t socklen = sizeof(addr);

	close(fds[0]);

	fd = socket(PF_INET6, SOCK_STREAM, 0);
	if (fd == -1) {
		perror("socket");
		return 1;
	}

	memset(&addr, 0, sizeof(addr));

        addr.sin6_family = AF_INET6;
        addr.sin6_port = htons(10000);
        addr.sin6_addr = in6addr_loopback;
	
	if (setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &fd, sizeof(fd))) {
		perror("setsockopt");
		return 1;
	}

	if (bind(fd, (const struct sockaddr *)&addr, sizeof(addr))) {
		perror("bind");
		return 1;
	}

	if (listen(fd, MAXCONN)) {
		perror("listen");
		return 1;
	}
	
	if (write(fds[1], &i, sizeof(i)) == -1) {
		perror("write");
		return 1;
	}

	for (i = 0; i < MAXCONN; i++) {
		int len, f = accept(fd, (struct sockaddr *)&addr, &socklen);
		if (f == -1) {
			perror("accept");
			return 1;
		}
		fdpoll[i] = f;

		len = read(f, &f, sizeof(f)); 
		if (!len) {
			fprintf(stderr, "read readen 0 bytes\n");
			return 1;
		}
		if (len == -1) {
			perror("read");
			return 1;
		}
	}

	return 0;
}

int main(int argc, char *argv[])
{
	int fds[2];
	int pid;

	if (pipe(fds)) {
		perror("pipe");
		return 1;
	}

	pid = fork();
	if (pid == -1) {
		perror("fork");
		return 1;
	}

	if (!pid) 
		return client(fds);
	else 
		return server(fds);
}

--------------040504080804070008070202--
