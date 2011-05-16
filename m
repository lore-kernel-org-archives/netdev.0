From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Null pointer dereference in icmp_send
Date: Mon, 16 May 2011 23:38:54 +0200
Message-ID: <1305581934.9466.11.camel@edumazet-laptop>
References: <BANLkTi=uBDOQOJJMGn6V0Ne7OjQ7kGc-2w@mail.gmail.com>
	 <1305581236.9466.4.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, roberto.paleari@emaze.net
To: Aristide Fattori <joystick@security.dico.unimi.it>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:55546 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756414Ab1EPVi7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2011 17:38:59 -0400
Received: by wya21 with SMTP id 21so3775605wya.19
        for <netdev@vger.kernel.org>; Mon, 16 May 2011 14:38:58 -0700 (PDT)
In-Reply-To: <1305581236.9466.4.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 16 mai 2011 =C3=A0 23:27 +0200, Eric Dumazet a =C3=A9crit :
> Le lundi 16 mai 2011 =C3=A0 23:06 +0200, Aristide Fattori a =C3=A9cri=
t :
> > Hi everybody,
> >=20
> > in function icmp_send() (net/ipv4/icmp.c), the parameter passed to
> > dev_net() function is not properly validated. This can lead to a NU=
LL
> > pointer dereference that crashes the kernel. The bug can be trigger=
ed
> > remotely, by flooding the target with fragmented IPv4 packets.
> > Important fields in the IP packet are:
> >  * Flags: the MF flag must be set.
> >  * Fragment ID: using pseudo-random values for this field quickly
> > fills fragmented queues in the victim's kernel, as it is unable to
> > easily reassemble received packets.
> >  * TOS: using pseudo-random values for this field triggers the
> > creation of more than one route cache entry for the same destinatio=
n
> > address, increasing the chances of incurring in the error condition
> > described before.
> > Other fields of the packet do not really matter, and they can be se=
t
> > to arbitrary values.
> >=20
> > If you are interested, we can provide a small and very dirty python
> > script that easily triggers the error condition.
> >=20
>=20
> Hi
>=20
> You forgot to tell us which linux version you used ?
>=20
> We had some fixes lately in this area.
>=20

Since its late here I should give more information :)

We fixed a problem 12 days ago, please check following patch

http://git.kernel.org/?p=3Dlinux/kernel/git/davem/net-next-2.6.git;a=3D=
commit;h=3D64f3b9e203bd06855072e295557dca1485a2ecba

It is scheduled for linux-2.6.38 stable tree as well


net: ip_expire() must revalidate route

Commit 4a94445c9a5c (net: Use ip_route_input_noref() in input path)
added a bug in IP defragmentation handling, in case timeout is fired.

When a frame is defragmented, we use last skb dst field when building
final skb. Its dst is valid, since we are in rcu read section.

But if a timeout occurs, we take first queued fragment to build one ICM=
P
TIME EXCEEDED message. Problem is all queued skb have weak dst pointers=
,
since we escaped RCU critical section after their queueing. icmp_send()
might dereference a now freed (and possibly reused) part of memory.

Calling skb_dst_drop() and ip_route_input_noref() to revalidate route i=
s
the only possible choice.


