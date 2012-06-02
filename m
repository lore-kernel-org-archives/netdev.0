From: Vincent Pelletier <plr.vincent@gmail.com>
Subject: Re: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Sat, 2 Jun 2012 11:08:52 +0200
Message-ID: <201206021108.53551.plr.vincent@gmail.com>
References: <201205312331.06623.plr.vincent@gmail.com> <20120601125949.GA11973@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_lgdyPvlpXJC+hDC"
Cc: netdev@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f178.google.com ([209.85.212.178]:63493 "EHLO
	mail-wi0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759011Ab2FBJI5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jun 2012 05:08:57 -0400
Received: by wibhn6 with SMTP id hn6so1356334wib.1
        for <netdev@vger.kernel.org>; Sat, 02 Jun 2012 02:08:56 -0700 (PDT)
In-Reply-To: <20120601125949.GA11973@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_lgdyPvlpXJC+hDC
Content-Type: Text/Plain;
  charset="iso-8859-15"
Content-Transfer-Encoding: quoted-printable

Le vendredi 01 juin 2012 14:59:49, Francois Romieu a =E9crit :
> You can apply the attached patch but it may not do much for your problem.

After failing to build the module alone in a way that it would accept loadi=
ng=20
in debian-provided kernel, I fall back to building vanilla kernel + propose=
d=20
patches.

I first went for 3.4, but realised the patch you attached was already appli=
ed=20
there.

So I went with 3.3.7, and patch failed to apply, at least partly because 3.=
3.7=20
lacks "r8169: fix early queue wake-up."[1] . I solved the conflicts manuall=
y,=20
but I'm not sure of the result. Could you confirm attached patch might give=
=20
expected result ? Or should I stick to 3.4 and only test inlined patch ?

[1] ae1f23fb433ac0aaff8aeaa5a7b14348e9aa8277

Regards,
=2D-=20
Vincent Pelletier

--Boundary-00=_lgdyPvlpXJC+hDC
Content-Type: text/x-patch;
  charset="UTF-8";
  name="for_3.3.7.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: attachment;
	filename="for_3.3.7.patch"

--- drivers/net/ethernet/realtek/r8169.c.orig	2012-06-02 10:26:45.000000000 +0200
+++ drivers/net/ethernet/realtek/r8169.c	2012-06-02 10:58:37.000000000 +0200
@@ -62,8 +62,12 @@
 #define R8169_MSG_DEFAULT \
 	(NETIF_MSG_DRV | NETIF_MSG_PROBE | NETIF_MSG_IFUP | NETIF_MSG_IFDOWN)
 
-#define TX_BUFFS_AVAIL(tp) \
-	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx - 1)
+#define TX_SLOTS_AVAIL(tp) \
+	(tp->dirty_tx + NUM_TX_DESC - tp->cur_tx)
+
+/* A skbuff with nr_frags needs nr_frags+1 entries in the tx queue */
+#define TX_FRAGS_READY_FOR(tp,nr_frags) \
+	(TX_SLOTS_AVAIL(tp) >= (nr_frags + 1))
 
 /* Maximum number of multicast addresses to filter (vs. Rx-all-multicast).
    The RTL chips use a 64 element hash table based on the Ethernet CRC. */
@@ -5513,7 +5517,7 @@
 	u32 opts[2];
 	int frags;
 
-	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
+	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop_0;
 	}
@@ -5561,10 +5565,10 @@
 
 	RTL_W8(TxPoll, NPQ);
 
-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 		netif_stop_queue(dev);
 		smp_rmb();
-		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+		if (TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS))
 			netif_wake_queue(dev);
 	}
 
@@ -5666,7 +5670,7 @@
 		tp->dirty_tx = dirty_tx;
 		smp_wmb();
 		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
+		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
 		/*

--Boundary-00=_lgdyPvlpXJC+hDC--
