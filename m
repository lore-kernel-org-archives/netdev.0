From: Jens Stroebel <drifter@bcsoft.de>
Subject: 2.6.21.5+1small patch: not blocking [was: Re: r8169: 2.6.22rc6+patches
 works, but 2.6.21.5 and 2.6.22rc6 without patches->network transfer blocking]
Date: Fri, 29 Jun 2007 14:18:32 +0200
Message-ID: <4684F898.80204@bcsoft.de>
References: <4683F923.80508@bcsoft.de> <20070628213050.GB4233@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------000801040403090809080406"
Cc: netdev list <netdev@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from moutng.kundenserver.de ([212.227.126.171]:53100 "EHLO
	moutng.kundenserver.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758332AbXF2MSf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 29 Jun 2007 08:18:35 -0400
In-Reply-To: <20070628213050.GB4233@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------000801040403090809080406
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit

Francois Romieu wrote:
> Jens Stroebel <drifter@bcsoft.de> :
> [...]
>> Would it
>> be possible to apply the single patch to 2.6.21.5 and get a working
>> driver?

> Mantra: mainline first, stable later.

hm .. OK.

> In the next future, most of this patchset will hopefully go into
> 2.6.23-rc1. Some people will then complain that 2.6.23-rc1 breaks
> their 816x. After that the patchkit will be amended and the r8169
> regressions in 2.6.23-rcX fixed.
> 
> Then it will be time to feed some r8169 bits in 2.6.2x.y

By this time, probably the hosts which should run w. the driver will be
standing all around the world, which makes applying a patch slightly
more interesting... ;-)

But see below:

> It may help and/or accelerate things if you can narrow the fix(es) in
> the current r8169 serie.

As I mentioned in the initial message, I had experimented with
2.6.22rc6; unfortunately

 a) we have some stuff depending on the kernel where
    2.6.21.5<->2.6.22rc6 makes a difference (does not work)
 b) I experienced a hard lockup w. kernel 2.6.22rc6 this morning while
    not really doing something special (file IO, extracting a tar. As
    this was reproducably happening, we retreated from experimenting
    with it now.

Instead, I built 2.6.21.5+[a patch I snatched from a mail communication
you had on 2007-06-20
(Msg-ID: <20070620211530.GA10042@electric-eye.fr.zoreil.com> )].
I will attach it with this mail, as it is really small and you don't
have to dig around to know what I'm talking about.

As I am no kernel-developer, I am not sure there are no undesired side
effects by applying this patch to this kernel; if you think there are
(could/should be), it would be nice if you could state that, so I'd
refrain from testing with this combination.

		greets,
		   jens
-- 
drifter@bcsoft.de
			23.....56.......drifting
By caffeine alone I set my mind in motion, By the beans of Java
do thoughts acquire speed,  hands acquire shaking,  the shaking
becomes a warning, By caffeine alone do I set my mind in motion

--------------000801040403090809080406
Content-Type: text/plain;
 name="8169_stop_blocking.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="8169_stop_blocking.patch"

diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
--- a/drivers/net/r8169.c
+++ b/drivers/net/r8169.c
@@ -2514,7 +2514,7 @@ static inline u32 rtl8169_tso_csum(struct sk_buff *skb, struct net_device *dev)
 static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	struct rtl8169_private *tp = netdev_priv(dev);
-	unsigned int frags, entry = tp->cur_tx % NUM_TX_DESC;
+	unsigned int frags, cur_tx, entry = tp->cur_tx % NUM_TX_DESC;
 	struct TxDesc *txd = tp->TxDescArray + entry;
 	void __iomem *ioaddr = tp->mmio_addr;
 	dma_addr_t mapping;
@@ -2567,13 +2567,17 @@ static int rtl8169_start_xmit(struct sk_buff *skb, struct net_device *dev)
 
 	dev->trans_start = jiffies;
 
+	cur_tx = tp->cur_tx;
+
 	tp->cur_tx += frags + 1;
 
-	smp_wmb();
+	mmiowb();
 
-	RTL_W8(TxPoll, NPQ);	/* set polling bit */
+	smp_mb();
 
-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (cur_tx == tp->dirty_tx)
+		RTL_W8(TxPoll, NPQ);
+	else if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
 		netif_stop_queue(dev);
 		smp_rmb();
 		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
@@ -2677,10 +2681,18 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 
 	if (tp->dirty_tx != dirty_tx) {
 		tp->dirty_tx = dirty_tx;
-		smp_wmb();
-		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
-			netif_wake_queue(dev);
+		smp_mb();
+		if (unlikely(netif_queue_stopped(dev))) {
+			netif_tx_lock(dev);
+		    	if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+				netif_wake_queue(dev);
+			if (dirty_tx != tp->cur_tx)
+				RTL_W8(TxPoll, NPQ);
+			netif_tx_unlock(dev);
+		} else if (dirty_tx != tp->cur_tx) {
+			netif_tx_lock(dev);
+			RTL_W8(TxPoll, NPQ);
+			netif_tx_unlock(dev);
 		}
 	}
 }


--------------000801040403090809080406--
