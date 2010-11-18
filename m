From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Loopback performance from kernel 2.6.12 to 2.6.37
Date: Thu, 18 Nov 2010 14:52:33 +0100
Message-ID: <1290088353.2781.137.camel@edumazet-laptop>
References: <1288954189.28003.178.camel@firesoul.comx.local>
	 <1288988955.2665.297.camel@edumazet-laptop>
	 <1289213926.15004.19.camel@firesoul.comx.local>
	 <1289214289.2820.188.camel@edumazet-laptop>
	 <1289228785.2820.203.camel@edumazet-laptop>
	 <1289311159.17448.9.camel@traveldev.cxnet.dk>
	 <1289312178.17448.20.camel@traveldev.cxnet.dk>
	 <1289312742.18992.21.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, David Miller <davem@davemloft.net>
To: Jesper Dangaard Brouer <jdb@comx.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:33439 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757692Ab0KRNwr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Nov 2010 08:52:47 -0500
Received: by wyb28 with SMTP id 28so3256210wyb.19
        for <netdev@vger.kernel.org>; Thu, 18 Nov 2010 05:52:46 -0800 (PST)
In-Reply-To: <1289312742.18992.21.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 09 novembre 2010 =C3=A0 15:25 +0100, Eric Dumazet a =C3=A9crit=
 :

> So far, so good. These are the expected numbers. Now we have to
> understand why corei7 gets 38 seconds instead of 8 :)
>=20
>=20

My tests show a problem with backlog processing, and too big TCP
windows. (at least on loopback and wild senders)

Basically, with huge tcp windows we have now (default 4 Mbytes),
the reader process can have to process up to 4Mbytes of backlogged data
in __release_sock() before returning from its 'small' read(fd, buffer,
1024) done by netcat.

While it processes this backlog, it sends tcp ACKS, allowing sender to
send new frames that might be dropped because of sk_rcvqueues_full(), o=
r
continue to fill receive queue up to the receiver window, feeding the
task in __release_sock() [loop]


This blows cpu caches completely [data is queued, and the dequeue is
done long after], and latency of a single read() can be very high. This
blocks the pipeline of user processing eventually.


<disgress>
I also understand why UDP latencies are so impacted. If we receive a
burst of frames on same socket, the user process reading first frame
might be forced to process the backlog before returning to userland.

Really we must zap lock_sock() from UDP input path.

commit 95766fff6b9a78d1 ([UDP]: Add memory accounting) was a big error.
</disgress>



On my server machine with 6Mbytes of L2 cache, you dont see the problem=
,
while on my laptop with 3Mbytes of L2 cache, you can see the problem.

I caught this because of new SNMP counter added in 2.6.34
(TCPBacklogDrop), that could easily take 1000 increments during the
test.


I built a test program, maybe easier to use than various netcat flavors
It also use two tasks only, thats better if you have a core 2 Duo like
me on my laptop ;)

To reproduce the problem, run it with option -l 4M

$ netstat -s|grep TCPBacklogDrop
    TCPBacklogDrop: 788
$ time ./loopback_transfert -l 1k;netstat -s|grep TCPBacklogDrop

real	0m14.013s
user	0m0.630s
sys	0m13.250s
    TCPBacklogDrop: 788
$ time ./loopback_transfert -l 128k;netstat -s|grep TCPBacklogDrop

real	0m7.447s
user	0m0.030s
sys	0m5.490s
    TCPBacklogDrop: 789
$ time ./loopback_transfert -l 1M;netstat -s|grep TCPBacklogDrop

real	0m11.206s
user	0m0.020s
sys	0m7.150s
    TCPBacklogDrop: 793
$ time ./loopback_transfert -l 4M;netstat -s|grep TCPBacklogDrop

real	0m10.347s
user	0m0.000s
sys	0m6.120s
    TCPBacklogDrop: 1510
$ time ./loopback_transfert -l 16k;netstat -s|grep TCPBacklogDrop

real	0m6.810s
user	0m0.040s
sys	0m6.670s
    TCPBacklogDrop: 1511


/*
 * Very simple program to test TCP loopback speed
 * This came from the phoronix benchmark using following :
 *
 * netcat -d -l 9999 >/dev/null &
 * time dd if=3D/dev/zero bs=3D1M count=3D10000 | netcat 127.0.0.1 9999
 *
 * Problem is the benchmark also use pipe subsystem, and three tasks,
 * while the following program uses only TCP subsystem and two tasks.
 * I still use small blocksize (netcat apparently use 1Kbyte blocks)
 *
 * Options :
 *            -l  blocksize   (in bytes, default : 1024)
 *            -s  socket SNDBUF/RCVBUF (default : system defaults (too =
big))
 */

#include <sys/types.h>
#include <sys/socket.h>
#include <netinet/in.h>
#include <netinet/tcp.h>
#include <string.h>
#include <unistd.h>
#include <stdio.h>
#include <stdlib.h>

long long amount_to_transfert =3D 10*1024*1024*1024LL; /* 10 Go */
unsigned int blocksize =3D 1024; /* to mimic netcat very pessimistic be=
havior */
unsigned int socket_bufsize =3D 0;

static void Server(int fdlisten)
{
	int newfd;
	struct sockaddr_in sockaddr;
	socklen_t len =3D sizeof(sockaddr);
	char *buffer;
	long total =3D 0;
	int ret;

	buffer =3D malloc(blocksize);
	newfd =3D accept(fdlisten, (struct sockaddr *)&sockaddr, &len);

	if (newfd =3D=3D -1) {
		perror("accept");
		exit(1);
	}
	close(fdlisten);
	if (socket_bufsize)
		setsockopt(newfd, SOL_SOCKET, SO_RCVBUF, &socket_bufsize, 4);
	while (1) {
		ret =3D read(newfd, buffer, blocksize);
		if (ret <=3D 0) break;
		total +=3D ret;
		}
	close(newfd);
	_exit(0);
}

static void usage(int code)
{
	exit(code);
}

static long scansize(char *str)
{
	char *end;
	long res =3D strtol(str, &end, 0);
	if (end) {
		if (*end =3D=3D 'k') res <<=3D 10;
		if (*end =3D=3D 'M') res <<=3D 20;
	}
	return res;
}

int main(int argc, char *argv[])
{
	int i;
	struct sockaddr_in sockaddr;
	socklen_t slen =3D sizeof(sockaddr);
	int fdlisten, fd;
	int port;
	char *buffer;
	long long total =3D 0;
	int ret =3D 0;

	while ((i =3D getopt(argc, argv, "l:s:")) !=3D EOF) {
		if (i =3D=3D 'l')
			blocksize =3D scansize(optarg);
		else if (i =3D=3D 's')
			socket_bufsize =3D scansize(optarg);
		else usage(1);
	}
	buffer =3D calloc(blocksize, 1);
	fdlisten =3D socket(AF_INET, SOCK_STREAM, 0);
	if (fdlisten =3D=3D -1) {
		perror("socket");
		return 1;
	}
	memset(&sockaddr, 0, sizeof(sockaddr));
	sockaddr.sin_family =3D AF_INET;
	sockaddr.sin_port =3D 0;
	sockaddr.sin_addr.s_addr =3D htonl(0x7f000001);
	if (bind(fdlisten, (struct sockaddr *)&sockaddr, sizeof(sockaddr))=3D=3D=
 -1) {
		perror("bind()");
		return 1;
	}
	if (listen(fdlisten, 10)=3D=3D -1) {
		perror("listen");
		return 1;
	}
	getsockname(fdlisten, (struct sockaddr *)&sockaddr, &slen);
	port =3D ntohs(sockaddr.sin_port);

	if (fork() =3D=3D 0)
		Server(fdlisten);

	close(fdlisten);
	fd =3D socket(AF_INET, SOCK_STREAM, 0);
	if (fd =3D=3D -1) {
		perror("socket");
		return -1;
	}
	memset(&sockaddr, 0, sizeof(sockaddr));
	sockaddr.sin_family =3D AF_INET;
	sockaddr.sin_port =3D htons(port);
	sockaddr.sin_addr.s_addr =3D htonl(0x7f000001);
	if (socket_bufsize)
		setsockopt(fd, SOL_SOCKET, SO_SNDBUF, &socket_bufsize, 4);
	connect(fd, (struct sockaddr *)&sockaddr, sizeof(sockaddr));
	while (total < amount_to_transfert) {
		ret =3D write(fd, buffer, blocksize);
		if (ret <=3D 0) break;
		total +=3D ret;
	}
	close(fd);
	return 0;
}


