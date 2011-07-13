From: Chris Friesen <chris.friesen@genband.com>
Subject: Re: any way to let host act as TCP server OR client on same IP/port?
Date: Wed, 13 Jul 2011 13:16:09 -0600
Message-ID: <4E1DEEF9.7040901@genband.com>
References: <4E1DC83C.3020506@genband.com> <1310579520.2509.17.camel@edumazet-laptop> <4E1DDE62.3080503@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org
To: Rick Jones <rick.jones2@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from exprod7og110.obsmtp.com ([64.18.2.173]:52059 "EHLO
	exprod7og110.obsmtp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750722Ab1GMTQR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Jul 2011 15:16:17 -0400
In-Reply-To: <4E1DDE62.3080503@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 07/13/2011 12:05 PM, Rick Jones wrote:
> On 07/13/2011 10:52 AM, Eric Dumazet wrote:
>> Le mercredi 13 juillet 2011 =E0 10:30 -0600, Chris Friesen a =E9crit=
 :
>>> I've been asked an interesting question about TCP. We have some peo=
ple
>>> that want to set up a TCP socket that can listen for connections on=
 a
>>> given IP/port, but also initiate connections from that same IP/port=
=2E
>>> (Only one at a time, of course.)
>>>
>>> The TCP state machine seems to allow this (moving from LISTEN to
>>> SYN_SENT) but it's not a normal transition.
>>>
>>> Is there any way to do this using the socket API?
>>>
>>> I thought up a hack whereby we could use NFQUEUE to detect an incom=
ing
>>> SYN and delay it while we call listen() on the socket. Is there any
>>> better way to do this?
>>
>> Could you try SO_REUSEADDR, on both listener and connect attempt ?
>=20
> I was thinking the same thing, but it appears to not work under:

<snip>

> if (bind(listener,
> (struct sockaddr *)&me,
> sizeof(me)) < 0) {
> perror("bind listener");
> exit(-1);
> }
>=20
> if (listen(listener,128) < 0) {
> perror("listen listener");
> exit(-1);
> }
>=20
> /* connect something to it */
> if (connect(client,(struct sockaddr *)&me,sizeof(me)) < 0) {
> perror("connect client");
> exit(-1);

In our case we don't need to actually be connected, just be listening
and ready to either accept() a connection or connect() to someone else.

However, even after removing the connect() call I get:
"bind active: Address already in use"


The TCP state machine shows a single connection going from LISTEN to
SYN_SENT via a "send" operation in the application.  Presumably this
would logically map to a sendto/sendmsg but according to the man page
those don't support specifying addresses for connection-oriented
sockets.  I tried it anyways and got no errors but the following trace
shows that it's dying with SIGPIPE:

bind(3, {sa_family=3DAF_INET, sin_port=3Dhtons(23456), sin_addr=3Dinet_=
addr("127.0.0.1")}, 16) =3D 0
listen(3, 128)                          =3D 0
sendto(3, "\1", 1, 0, {sa_family=3DAF_INET, sin_port=3Dhtons(9), sin_ad=
dr=3Dinet_addr("127.0.0.1")}, 16) =3D -1 EPIPE (Broken pipe)
--- {si_signo=3DSIGPIPE, si_code=3DSI_USER, si_pid=3D20609, si_uid=3D83=
82, si_value=3D{int=3D2722689790, ptr=3D0x3ca248f2fe}} (Broken pipe) --=
-
+++ killed by SIGPIPE +++


Chris



--=20
Chris Friesen
Software Developer
GENBAND
chris.friesen@genband.com
www.genband.com
