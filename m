From: Cyril =?iso-8859-1?q?Bont=E9?= <cyril.bonte@free.fr>
Subject: tcp: disallow bind() to reuse addr/port regression in 2.6.38
Date: Sat, 2 Apr 2011 20:01:47 +0200
Message-ID: <201104022001.48144.cyril.bonte@free.fr>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Daniel Baluta <daniel.baluta@gmail.com>,
	Gaspar Chilingarov <gasparch@gmail.com>,
	Charles Duffy <charles@dyfis.net>, Willy Tarreau <w@1wt.eu>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp5-g21.free.fr ([212.27.42.5]:41888 "EHLO smtp5-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756135Ab1DBSB4 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Apr 2011 14:01:56 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi All,

(2nd try to fix the mailing list address)

It has been reported that kernel 2.6.38 prevented the load balancer hap=
roxy to=20
reload. After reading the kernel Changelog, it looks like the following=
 commit=20
has a negative side effect on the the way haproxy "pauses" its listenin=
g=20
sockets to start a new process :

http://git.kernel.org/?p=3Dlinux/kernel/git/torvalds/linux-2.6.git;a=3D=
commit;h=3Dc191a836a908d1dd6b40c503741f91b914de3348

Disabling the TCPF_CLOSE flag condition reallows to work as before. I g=
uess=20
this was done for good reasons (Sorry, I haven't found the thread about=
 that=20
commit in the archives yet) but other applications may also be impacted=
 by=20
this change.

I add Willy Tarreau to the CC to open the discussion.

Here is a simple test case to reproduce the issue (with kernel 2.6.38, =
it will=20
fail on the second loop whereas it works with previous kernel versions)=
 :
#include <sys/socket.h>
#include <netinet/in.h>
#include <stdlib.h>
#include <stdio.h>
#include <strings.h>

int main(int argc, char**argv)
{
	int listenfd;
	struct sockaddr_in servaddr;
	int i;
	int one =3D 1;
=09
	for (i =3D 0; i < 2; i++)
	{
		printf("LOOP %d...\n", i + 1);
		listenfd=3Dsocket(AF_INET,SOCK_STREAM,0);

		setsockopt(listenfd,SOL_SOCKET,SO_REUSEADDR,(char *)&one,sizeof(one))=
;

		bzero(&servaddr,sizeof(servaddr));
		servaddr.sin_family =3D AF_INET;
		servaddr.sin_addr.s_addr=3Dhtonl(INADDR_ANY);
		servaddr.sin_port=3Dhtons(32000);

		if (bind(listenfd,(struct sockaddr *)&servaddr,sizeof(servaddr)) !=3D=
 0)
		{
			perror("bind");
			exit(1);
		}

		if (listen(listenfd,1024) !=3D 0)
		{
			perror("listen");
			exit(1);
		}

		if (shutdown(listenfd, SHUT_WR) =3D=3D 0 &&
		    listen(listenfd, 1024) =3D=3D 0 &&
		    shutdown(listenfd, SHUT_RD) =3D=3D 0) {
			printf("shutdown OK\n");
		}
	}
	exit(0);
}

--=20
Cyril Bont=E9
