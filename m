From: Rick Jones <rick.jones2@hp.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Wed, 13 Jul 2011 11:05:22 -0700
Message-ID: <4E1DDE62.3080503@hp.com>
References: <4E1DC83C.3020506@genband.com> <1310579520.2509.17.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Chris Friesen <chris.friesen@genband.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from g1t0027.austin.hp.com ([15.216.28.34]:7201 "EHLO
	g1t0027.austin.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757035Ab1GMSFX (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 14:05:23 -0400
In-Reply-To: <1310579520.2509.17.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2011 10:52 AM, Eric Dumazet wrote:
> Le mercredi 13 juillet 2011 =C3=A0 10:30 -0600, Chris Friesen a =C3=A9=
crit :
>> I've been asked an interesting question about TCP.  We have some peo=
ple
>> that want to set up a TCP socket that can listen for connections on =
a
>> given IP/port, but also initiate connections from that same IP/port.
>> (Only one at a time, of course.)
>>
>> The TCP state machine seems to allow this (moving from LISTEN to
>> SYN_SENT) but it's not a normal transition.
>>
>> Is there any way to do this using the socket API?
>>
>> I thought up a hack whereby we could use NFQUEUE to detect an incomi=
ng
>> SYN and delay it while we call listen() on the socket.  Is there any
>> better way to do this?
>
> Could you try SO_REUSEADDR, on both listener and connect attempt ?

I was thinking the same thing, but it appears to not work under:

raj@tardy:~$ uname -a
Linux tardy 2.6.35-30-generic #54-Ubuntu SMP Tue Jun 7 18:41:54 UTC 201=
1=20
x86_64 GNU/Linux

raj@tardy:~$ ./both
bind active: Address already in use

(nor HP-UX 11.31)

unless I botched the test code somehow:

raj@tardy:~$ cat both.c
#include <stdio.h>
#include <sys/types.h>
#include <sys/socket.h>
#include <string.h>
#include <arpa/inet.h>
#include <stdlib.h>

int
main(int argc, char *argv[]) {

   struct sockaddr_in me,him;
   int on =3D 1;
   socklen_t  len;
   int  listener, active, client;


   if ((listener =3D socket(AF_INET,SOCK_STREAM,0)) < 0) {
     perror("socket listener");
     exit(-1);
   }

   if ((active =3D socket(AF_INET,SOCK_STREAM,0)) < 0) {
     perror("socket active");
     exit(-1);
   }

   if ((client =3D socket(AF_INET,SOCK_STREAM,0)) < 0) {
     perror("socket client");
     exit(-1);
   }

   /* setup the listen endpoint */
   memset(&me,0,sizeof(me));

   if (!inet_pton(AF_INET,"127.0.0.1",&(me.sin_addr.s_addr))) {
     perror("inet_pton me");
     exit(-1);
   }
   me.sin_port =3D htons(23456);
   me.sin_family =3D AF_INET;

   if (setsockopt(listener,
		 SOL_SOCKET,
		 SO_REUSEADDR,
		 (char *)&on ,
		 sizeof(on)) < 0) {
     perror("setsockopt SO_REUSEADDR listener");
     exit(-1);
   }

   if (bind(listener,
	   (struct sockaddr *)&me,
	   sizeof(me)) < 0) {
     perror("bind listener");
     exit(-1);
   }

   if (listen(listener,128) < 0) {
     perror("listen listener");
     exit(-1);
   }

   /* connect something to it */
   if (connect(client,(struct sockaddr *)&me,sizeof(me)) < 0) {
     perror("connect client");
     exit(-1);
   }

   /* now try to make an active connection from "me" */
   memset(&him,0,sizeof(him));

   if (!inet_pton(AF_INET,"127.0.0.1",&(him.sin_addr.s_addr))) {
     perror("inet_pton him");
     exit(-1);
   }

   him.sin_port =3D htons(9);  /* assume someone is listening on
					"discard"*/
   him.sin_family =3D AF_INET;

   if (setsockopt(active,
		 SOL_SOCKET,
		 SO_REUSEADDR,
		 (char *)&on ,
		 sizeof(on)) < 0) {
     perror("setsockopt SO_REUSEADDR active");
     exit(-1);
   }

   if (bind(active,
	   (struct sockaddr *)&me,
	   sizeof(me)) < 0) {
     perror("bind active");
     exit(-1);
   }

   if (connect(active,(struct sockaddr *)&him,sizeof(him)) < 0) {
     perror("connect active");
     exit(-1);
   }

   printf("Successfully created a listen endpoint and an active=20
connection from the same IP/port pair\n");

}


rick jones
