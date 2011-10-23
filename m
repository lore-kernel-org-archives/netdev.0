From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Kernel Panic every 2 weeks on ISP server (NULL pointer
 dereference)
Date: Sun, 23 Oct 2011 07:16:29 +0200
Message-ID: <1319346989.6180.71.camel@edumazet-laptop>
References: <201110222218.12524.lruete@sequre.com.ar>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: Luciano Ruete <lruete@sequre.com.ar>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:52278 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752521Ab1JWFmI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 23 Oct 2011 01:42:08 -0400
Received: by wyg36 with SMTP id 36so5185468wyg.19
        for <netdev@vger.kernel.org>; Sat, 22 Oct 2011 22:42:06 -0700 (PDT)
In-Reply-To: <201110222218.12524.lruete@sequre.com.ar>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le samedi 22 octobre 2011 =C3=A0 22:18 -0300, Luciano Ruete a =C3=A9cri=
t :
> Hi,
>=20
> I'm the sysadmin at a 3500 customers ISP, wich runs an iptables+tc so=
lution=20
> for load balancing and QoS.
>=20
> Every 2 or 3 weeks the server panics with a "NULL pointer dereference=
" and=20
> with IP at "dev_queue_xmit"
>=20
> It is curious that if i disable MSI on the network card driver this p=
anics=20
> seems to disapear, does this ring a bell?
>=20
> The server is an IBM, previously with Broadcom NetXtreme II BCM5709 n=
ics and=20
> now with Intel 82576. I change the nics thinking that maybe the bug w=
as in=20
> Broadcom Driver but it seems to affect MSI in general.
>=20
> The tc+iptables rules are auto-generated with sequreisp[1] an ISP sol=
ution=20
> that i wrote and is open sourced under AGPLv3.
>=20
> Tell me if you need any further information, and plz CC because I'm n=
ot=20
> suscribed.=20
>=20
>=20
> root@server:~# uname -a
> Linux server 2.6.35-30-server #60~lucid1-Ubuntu SMP Tue Sep 20 22:28:=
40 UTC=20
> 2011 x86_64 GNU/Linux
>=20
>=20
> [1]https://github.com/sequre/sequreisp
>=20

Hi Luciano

[694250.472081] Code: f6=20
49 c1 e6 07          shl    $0x7,%r14
66 89 93 ac 00 00 00 mov    %dx,0xac(%rbx)

4d 03 b5 40 03 00 00 add    0x340(%r13),%r14  =20
 txq =3D dev_pick_tx(dev, skb);

0f b7 83 a6 00 00 00 movzwl 0xa6(%rbx),%eax
4d 8b 66 08          mov    0x8(%r14),%r12   =20
	   q =3D rcu_dereference_bh(txq->qdisc);
80 e4 cf             and    $0xcf,%ah
80 cc 20             or     $0x20,%ah

66 89 83 a6 00 00 00 mov    %ax,0xa6(%rbx)  =20
   skb->tc_verd =3D SET_TC_AT(skb->tc_verd, AT_EGRESS);

<49> 83 3c 24 00     cmpq   $0x0,(%r12)      =20
  if (q->enqueue)   CRASH because q is NULL.

0f 84 3b 02 00 00 je      ...	=09
				rc =3D __dev_xmit_skb(skb, q, dev, txq); =20
49 8d 84 24 9c 00 00 00   lea    0x9c(%r12),%rax
48 89=20


This looks like a dev_pick_tx() bug, using an out of bound=20
queue_index number and returning a txq pointing after
the device allocated array.



With recent kernels, this cannot happen anymore because
we added fixes in this area.

You could try Ubuntu 11.10 (based on linux 3.0) kernel
on your server, or apply following patch :

commit df32cc193ad88f7b1326b90af799c927b27f7654
Author: Tom Herbert <therbert@google.com>
Date:   Mon Nov 1 12:55:52 2010 -0700

    net: check queue_index from sock is valid for device
   =20
    In dev_pick_tx recompute the queue index if the value stored in the
    socket is greater than or equal to the number of real queues for th=
e
    device.  The saved index in the sock structure is not guaranteed to
    be appropriate for the egress device (this could happen on a route
    change or in presence of tunnelling).  The result of the queue inde=
x
    being bad would be to return a bogus queue (crash could prersumably
    follow).
   =20
    Signed-off-by: Tom Herbert <therbert@google.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

diff --git a/net/core/dev.c b/net/core/dev.c
index 35dfb83..0dd54a6 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -2131,7 +2131,7 @@ static struct netdev_queue *dev_pick_tx(struct ne=
t_device *dev,
 	} else {
 		struct sock *sk =3D skb->sk;
 		queue_index =3D sk_tx_queue_get(sk);
-		if (queue_index < 0) {
+		if (queue_index < 0 || queue_index >=3D dev->real_num_tx_queues) {
=20
 			queue_index =3D 0;
 			if (dev->real_num_tx_queues > 1)
