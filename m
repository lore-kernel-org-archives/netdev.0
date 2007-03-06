From: Eric Dumazet <dada1@cosmosbay.com>
Subject: Re: TCP 2MSL on loopback
Date: Tue, 6 Mar 2007 11:42:00 +0100
Message-ID: <200703061142.00261.dada1@cosmosbay.com>
References: <45EBFD13.1060106@symas.com> <200703051528.02564.dada1@cosmosbay.com> <45ED32CA.5080709@symas.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_4VU7Fm540kNnvPf"
Cc: netdev@vger.kernel.org
To: Howard Chu <hyc@symas.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:36717 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752945AbXCFKmG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 6 Mar 2007 05:42:06 -0500
In-Reply-To: <45ED32CA.5080709@symas.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--Boundary-00=_4VU7Fm540kNnvPf
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

On Tuesday 06 March 2007 10:22, Howard Chu wrote:

>
> It's a combination of 2MSL and /proc/sys/net/ipv4/ip_local_port_range -
> on my system the default port range is 32768-61000. That means if I use
> up 28232 ports in less than 2MSL then everything stops. netstat will
> show that all the available port numbers are in TIME_WAIT state. And
> this is particularly bad because while waiting for the timeout, I can't
> initiate any new outbound connections of any kind at all - telnet, ssh,
> whatever, you have to wait for at least one port to free up.
> (Interesting denial of service there....)
>
> Granted, I was running my test on 2.6.18, perhaps 2.6.21 behaves
> differently.

Could you try this attached program and tell me whats happen ?

$ gcc -O2 -o socktest socktest.c -lpthread
$ time ./socktest -n 100000
nb_conn=99999 nb_accp=99999

real    0m5.058s
user    0m0.212s
sys     0m4.844s

(on my small machine, dell d610 :) )


--Boundary-00=_4VU7Fm540kNnvPf
Content-Type: text/plain;
  charset="iso-8859-1";
  name="socktest.c"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
	filename="socktest.c"

/*
  Copyright (C) 2007  Eric Dumazet

    This program is free software; you can redistribute it and/or modify
    it under the terms of the GNU General Public License as published by
    the Free Software Foundation; either version 2 of the License, or
    (at your option) any later version.

    This program is distributed in the hope that it will be useful,
    but WITHOUT ANY WARRANTY; without even the implied warranty of
    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
    GNU General Public License for more details.

    You should have received a copy of the GNU General Public License along
    with this program; if not, write to the Free Software Foundation, Inc.,
    51 Franklin Street, Fifth Floor, Boston, MA 02110-1301 USA.
 */
#include <pthread.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <sys/resource.h>
#include <sys/wait.h>
#include <sys/ioctl.h>
#include <sys/stat.h>
#include <sys/time.h>
#include <sys/poll.h>
#include <sys/sendfile.h>
#include <sys/epoll.h>

#include <netinet/in.h>
#include <netinet/tcp.h>
#include <arpa/inet.h>

#include <stdio.h>
#include <stdlib.h>
#include <unistd.h>
#include <errno.h>
#include <string.h>
#include <fcntl.h>
#include <time.h>
#include <ctype.h>
#include <netdb.h>

int fd __attribute__((aligned(64)));
int port = 9999;
unsigned long nb_acc __attribute__((aligned(64)));
unsigned long nb_conn1 __attribute__((aligned(64)));
unsigned long nb_conn2 __attribute__((aligned(64)));
unsigned long nb_conn3 __attribute__((aligned(64)));
int limit = 10000/3;

void *do_accept(void *arg)
{
int s;
struct sockaddr_in sa;
socklen_t addrlen ;
int flags;
char buffer[1024];

while (1) {
	addrlen = sizeof(sa);
	s = accept(fd, (struct sockaddr *)&sa, &addrlen);
	if (s == -1) continue;
	flags = 0;
	recv(s, buffer, 1024, 0);
	send(s, "Answer\r\n", 8, 0);
	close(s);
	nb_acc++;
	}
}

void *do_conn(void *arg)
{
int i;
int on = 1;
struct sockaddr_in sa;
unsigned long *cpt = (unsigned long *)arg;
for (i = 0 ; i < limit ; i++) {
	int s = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
	int res;
	setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, 4);
	memset(&sa, 0, sizeof(sa));
	sa.sin_addr.s_addr = htonl(0x7f000001);
	sa.sin_port = htons(port);
	sa.sin_family = AF_INET;
	res = connect(s, (struct sockaddr *)&sa, sizeof(sa));
	if (res == 0) {
		char buffer[1024];
		send(s, "question\r\n", 10, 0);
		recv(s, buffer, sizeof(buffer), 0);
		(*cpt)++;
		}
	else {
		static int errcnt = 0;
		if (errcnt++ < 10) printf("connect error %d\n", errno);
		}
	close(s);
	}
}

int main(int argc, char *argv[])
{
int on = 1;
struct sockaddr_in sa;
pthread_t tid, tid1, tid2, tid3;
int i;
void *res;

while ((i = getopt(argc, argv, "Vn:")) != EOF) {
	if (i == 'n')
		limit = atoi(optarg) / 3;
	}
fd = socket(AF_INET, SOCK_STREAM, IPPROTO_TCP);
setsockopt(fd, SOL_SOCKET, SO_REUSEADDR, &on, 4);
memset(&sa, 0, sizeof(sa));
sa.sin_port = htons(port);
sa.sin_family = AF_INET;
if (bind(fd, (struct sockaddr *)&sa, sizeof(sa)) == -1) {
	perror("bind");
	return 1;
	}
listen(fd, 30000);
pthread_create(&tid, NULL, do_accept, NULL);
pthread_create(&tid1, NULL, do_conn, &nb_conn1);
pthread_create(&tid2, NULL, do_conn, &nb_conn2);
pthread_create(&tid3, NULL, do_conn, &nb_conn3);
pthread_join(tid1, &res);
pthread_join(tid2, &res);
pthread_join(tid3, &res);
printf("nb_conn=%lu nb_accp=%lu\n", nb_conn1 + nb_conn2 + nb_conn3, nb_acc);
return 0;
}

--Boundary-00=_4VU7Fm540kNnvPf--
