From: Francois Romieu <romieu@fr.zoreil.com>
Subject: Re: r8169: IO_PAGE_FAULT & netdev watchdog
Date: Fri, 1 Jun 2012 14:59:49 +0200
Message-ID: <20120601125949.GA11973@electric-eye.fr.zoreil.com>
References: <201205312331.06623.plr.vincent@gmail.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="T4sUOijqQbZv57TR"
Cc: netdev@vger.kernel.org
To: Vincent Pelletier <plr.vincent@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from violet.fr.zoreil.com ([92.243.8.30]:58234 "EHLO
	violet.fr.zoreil.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757909Ab2FANIW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 1 Jun 2012 09:08:22 -0400
Content-Disposition: inline
In-Reply-To: <201205312331.06623.plr.vincent@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline

Vincent Pelletier <plr.vincent@gmail.com> :
[...]
> I'm getting consistently errors when using btlaunchmanycurses (multi-torrent
> downloader) after a few minutes. I usually first notice the network being down
> (no trafic) then find this in syslog (see at bottom).
> 
> Then, I "ifdown eth0;rmmod r8169;modprobe r8169" (which implicitely ifup's),
> but network never comes back - at least no trafic can go through - until
> reboot.

Same thing if you reset and remove the pci device through sysfs then ask
the PCI bridge to scan it again ?

> www.kerneloops.org being down (aparently for quite some time...) I though I
> should report here.
> 
> I'm quite sure this problem also occured on 3.2, but I don't know the exact
> version I was using at that time. I only have this motherboard since a few
> months, and previous one didn't have an IOMMU - which in my understanding is
> what causes (well, detects actually) this error.

https://bugzilla.kernel.org/show_bug.cgi?id=42899 contains similar if not
identical IOMMU messages (this #bz is messy but it may be of intereset to
add yourself to the Cc: list btw).
AFAIUI the IOMMU complains because the r8169 tried to perform a read access.
The target address matches the start of a descriptor ring one. However it
happens long after the r8169 initialized the chipset and the driver would
work rather poorly if it could not access its descriptor rings. The r8169
bug is real but the IOMMU message seems rather useless if not bogus.

> May 31 22:54:55 x2 kernel: [78579.111904] AMD-Vi: Event logged [IO_PAGE_FAULT device=05:00.0 domain=0x0019 address=0x0000000000003000 flags=0x0050]
> May 31 22:55:07 x2 kernel: [78590.832047] ------------[ cut here ]------------
> May 31 22:55:07 x2 kernel: [78590.832067] WARNING: at /build/buildd-linux-2.6_3.3.4-1~experimental.1-amd64-_y3OdD/linux-2.6-3.3.4/debian/build/source_amd64_none/net/sched/sch_generic.c:256 dev_watchdog+0xf2/0x151()
> May 31 22:55:07 x2 kernel: [78590.832080] Hardware name: GA-990FXA-UD3
> May 31 22:55:07 x2 kernel: [78590.832087] NETDEV WATCHDOG: eth0 (r8169): transmit queue 0 timed out

You can apply the attached patch but it may not do much for your problem.

The patch below could make a difference though. Does it ?

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index bbacb37..da46588 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -3766,6 +3766,7 @@ static void rtl_init_rxcfg(struct rtl8169_private *tp)
 	case RTL_GIGA_MAC_VER_22:
 	case RTL_GIGA_MAC_VER_23:
 	case RTL_GIGA_MAC_VER_24:
+	case RTL_GIGA_MAC_VER_34:
 		RTL_W32(RxConfig, RX128_INT_EN | RX_MULTI_EN | RX_DMA_BURST);
 		break;
 	default:


-- 
Ueimor

--T4sUOijqQbZv57TR
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="0001-PATCH-r8169-fix-unsigned-int-wraparound-with-TSO.patch"

>From 3068d55417db4c8e3414ce840afb932fdf1f0f76 Mon Sep 17 00:00:00 2001
Message-Id: <3068d55417db4c8e3414ce840afb932fdf1f0f76.1338553193.git.romieu@fr.zoreil.com>
From: Julien Ducourthial <jducourt@free.fr>
Date: Fri, 1 Jun 2012 14:17:43 +0200
Subject: [PATCH] [PATCH] r8169: fix unsigned int wraparound with TSO
X-Organisation: Land of Sunshine Inc.

[ Upstream commit 477206a018f902895bfcd069dd820bfe94c187b1 ]

The r8169 may get stuck or show bad behaviour after activating TSO :
the net_device is not stopped when it has no more TX descriptors.
This problem comes from TX_BUFS_AVAIL which may reach -1 when all
transmit descriptors are in use. The patch simply tries to keep positive
values.

Tested with 8111d(onboard) on a D510MO, and with 8111e(onboard) on a
Zotac 890GXITX.

Signed-off-by: Julien Ducourthial <jducourt@free.fr>
Acked-by: Francois Romieu <romieu@fr.zoreil.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
---
 drivers/net/ethernet/realtek/r8169.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index f545093..ce6b44d 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -61,8 +61,12 @@
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
@@ -5115,7 +5119,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts[2];
 	int frags;

-	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
+	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop_0;
 	}
@@ -5169,7 +5173,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,

 	mmiowb();

-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 		/* Avoid wrongly optimistic queue wake-up: rtl_tx thread must
 		 * not miss a ring update when it notices a stopped queue.
 		 */
@@ -5183,7 +5187,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 		 * can't.
 		 */
 		smp_mb();
-		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+		if (TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS))
 			netif_wake_queue(dev);
 	}

@@ -5306,7 +5310,7 @@ static void rtl_tx(struct net_device *dev, struct rtl8169_private *tp)
 		 */
 		smp_mb();
 		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
+		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
 		/*
--
1.7.10.2
---
 drivers/net/ethernet/realtek/r8169.c |   16 ++++++++++------
 1 file changed, 10 insertions(+), 6 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/ethernet/realtek/r8169.c
index da46588..59dd29e 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
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
@@ -5513,7 +5517,7 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 	u32 opts[2];
 	int frags;
 
-	if (unlikely(TX_BUFFS_AVAIL(tp) < skb_shinfo(skb)->nr_frags)) {
+	if (unlikely(!TX_FRAGS_READY_FOR(tp, skb_shinfo(skb)->nr_frags))) {
 		netif_err(tp, drv, dev, "BUG! Tx Ring full when queue awake!\n");
 		goto err_stop_0;
 	}
@@ -5561,10 +5565,10 @@ static netdev_tx_t rtl8169_start_xmit(struct sk_buff *skb,
 
 	RTL_W8(TxPoll, NPQ);
 
-	if (TX_BUFFS_AVAIL(tp) < MAX_SKB_FRAGS) {
+	if (!TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 		netif_stop_queue(dev);
 		smp_rmb();
-		if (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)
+		if (TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS))
 			netif_wake_queue(dev);
 	}
 
@@ -5666,7 +5670,7 @@ static void rtl8169_tx_interrupt(struct net_device *dev,
 		tp->dirty_tx = dirty_tx;
 		smp_wmb();
 		if (netif_queue_stopped(dev) &&
-		    (TX_BUFFS_AVAIL(tp) >= MAX_SKB_FRAGS)) {
+		    TX_FRAGS_READY_FOR(tp, MAX_SKB_FRAGS)) {
 			netif_wake_queue(dev);
 		}
 		/*
-- 
1.7.10.2


--T4sUOijqQbZv57TR--
