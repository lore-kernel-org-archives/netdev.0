From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Gianfar ethernet drop package
Date: Mon, 27 Aug 2012 06:32:39 -0700
Message-ID: <1346074359.26634.4.camel@edumazet-glaptop>
References: <5037A86E.2000004@efacec.com>
	 <1345832223.19483.75.camel@edumazet-glaptop> <503B4CBB.1020405@efacec.com>
	 <1346065738.2420.135.camel@edumazet-glaptop> <503B6FA7.8070807@efacec.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: =?ISO-8859-1?Q?An=EDbal?= Almeida Pinto <anibal.pinto@efacec.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:38028 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751634Ab2H0Nco (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 27 Aug 2012 09:32:44 -0400
Received: by pbbrr13 with SMTP id rr13so7435831pbb.19
        for <netdev@vger.kernel.org>; Mon, 27 Aug 2012 06:32:43 -0700 (PDT)
In-Reply-To: <503B6FA7.8070807@efacec.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-08-27 at 14:01 +0100, An=C3=ADbal Almeida Pinto wrote:

> Is there any way of put tcpdump or other tool to only log the package=
s=20
> dropped ?

To log such packets with tcpdump, I am afraid you'll need to patch your
kernel.

We dont have a way to tell tcpdump "sniff dropped packets"

Something like this one

(alternatively you can use dropwatch (based on drop_monitor)) and tweak
it...


diff --git a/net/core/dev.c b/net/core/dev.c
index 3401e2d..1336570 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3263,14 +3263,6 @@ another_round:
 	if (sk_memalloc_socks() && skb_pfmemalloc(skb))
 		goto skip_taps;
=20
-	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-		if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
-			if (pt_prev)
-				ret =3D deliver_skb(skb, pt_prev, orig_dev);
-			pt_prev =3D ptype;
-		}
-	}
-
 skip_taps:
 #ifdef CONFIG_NET_CLS_ACT
 	skb =3D handle_ing(skb, &pt_prev, &ret, orig_dev);
@@ -3337,6 +3329,11 @@ ncls:
 	} else {
 drop:
 		atomic_long_inc(&skb->dev->rx_dropped);
+		list_for_each_entry_rcu(ptype, &ptype_all, list) {
+			if (!ptype->dev || ptype->dev =3D=3D skb->dev) {
+				ret =3D deliver_skb(skb, ptype, orig_dev);
+			}
+		}
 		kfree_skb(skb);
 		/* Jamal, now you will not able to escape explaining
 		 * me how you were going to use this. :-)
