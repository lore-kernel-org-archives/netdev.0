From: =?ISO-8859-1?Q?Mart=EDn_Ferrari?= <martin.ferrari@gmail.com>
Subject: Performance problem in network namespaces
Date: Mon, 3 May 2010 11:25:20 +0200
Message-ID: <q2tb9800b71005030225q21365e3ch8dd5b35383a32e8a@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Mathieu Lacage <mathieu.lacage@sophia.inria.fr>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vw0-f46.google.com ([209.85.212.46]:58512 "EHLO
	mail-vw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752479Ab0ECJZV convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 May 2010 05:25:21 -0400
Received: by vws19 with SMTP id 19so1532318vws.19
        for <netdev@vger.kernel.org>; Mon, 03 May 2010 02:25:20 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

When running some benchmarks to test the feasibility of using
namespaces for emulating networks, I have found a big drop in
performance when one of the namespaces is performing routing of
packets.

After some search, we found that  in ip_forward() the skb is being
copied. It seems that (ICMP and UDP, does not happen with TCP) packets
start with a small headroom (16 bytes in our observation) but skb_cow
always allocates at least NET_SKB_PAD (32 in x86) bytes of headroom,
thus triggering this unnecessary memcpy.

We made two crude attempts at fixing this, which are surely incorrect,
but hopefully somebody here could come up with a correct solution.

Our attempts are: 1. remove the lower bound in headroom size at
skb_cow, and 2. set needed_headroom in veth.c to NET_SKB_PAD; patches
included below.

Thanks.


diff -Naurp linux-2.6.34-rc5/include/linux/skbuff.h
=2E./linux-2.6.34-rc5/include/linux/skbuff.h
--- linux-2.6.34-rc5/include/linux/skbuff.h	2010-04-20 01:29:56.0000000=
00 +0200
+++ ../linux-2.6.34-rc5/include/linux/skbuff.h	2010-05-03
11:17:13.000000000 +0200
@@ -1526,8 +1526,6 @@ static inline int __skb_cow(struct sk_bu
 {
 	int delta =3D 0;

-	if (headroom < NET_SKB_PAD)
-		headroom =3D NET_SKB_PAD;
 	if (headroom > skb_headroom(skb))
 		delta =3D headroom - skb_headroom(skb);


diff -Naurp linux-2.6.34-rc5/drivers/net/veth.c
=2E./linux-2.6.34-rc5/drivers/net/veth.c
--- linux-2.6.34-rc5/drivers/net/veth.c	2010-04-20 01:29:56.000000000 +=
0200
+++ ../linux-2.6.34-rc5/drivers/net/veth.c	2010-04-30 11:29:39.00000000=
0 +0200
@@ -303,6 +303,8 @@ static void veth_setup(struct net_device
 	dev->ethtool_ops =3D &veth_ethtool_ops;
 	dev->features |=3D NETIF_F_LLTX;
 	dev->destructor =3D veth_dev_free;
+	/* Try to avoid skb copies when passing packets around */
+	dev->needed_headroom =3D NET_SKB_PAD;
 }

 /*


--=20
Mart=EDn Ferrari
