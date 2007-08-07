From: Johannes Berg <johannes@sipsolutions.net>
Subject: [RFC] allow device to stop packet mirror behaviour
Date: Tue, 07 Aug 2007 10:25:55 +0200
Message-ID: <1186475155.4067.17.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Andy Green <andy@warmcat.com>, David Miller <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>
To: netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:59028 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758270AbXHGJq6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 7 Aug 2007 05:46:58 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the wireless code, we have special 802.11+radiotap framed virtual
interfaces, mostly used to monitor traffic on the air. They also show
outgoing packets from other virtual interfaces associated with the same
PHY because you can't receive packets while sending. Due to the design
of the virtual interfaces, the packets don't pass through those
802.11+radiotap framed interfaces.

This whole setup has the additional advantage that we are able to
indicate the transmission status parameters via radiotap as well,
meaning that we can tell (in userspace) by looking at the radiotap
header whether a packet was acknowledged by the receiver, whether
RTS/CTS was used etc. This is required for implementing more things in
userspace which we plan to do in order to not have the high-complexity
MLME in the kernel.

Now, however, we run into the situation that somebody is actually
sending frames down the 802.11+radiotap framed interface. This could be
the userspace MLME implementation, for example, sending association
requests or whatever. These will now show up twice on the monitoring
interface that the userspace MLME is using, once via
dev_queue_xmit_nit() because they were sent on that interface and once
via our own mirror mechanism that also shows the transmission status
indication.

Andy has written a patch that suppresses our own mirror mechanism from
becoming effective for packets that were already mirrored out by
dev_queue_xmit_nit(), however this is not very desirable because it
makes such packets special, their transmission status information will
not be available; however, in some circumstances this information is
required (for example when implementing an MLME using 802.11+radiotap
framed interfaces.) [Also, the current implementation means that on yet
another monitor interface you don't see those frames at all.]

The only way to solve this problem therefore seems to be to suppress the
mirroring out of the packet by dev_queue_xmit_nit(). The patch below
does that by way of adding a new netdev flag.

Comments welcome.

johannes

---
Tested with three monitor interfaces and a trivial injection program on
bcm43xx-mac80211. I'll send the mac80211 patch I used as a follow-up.

 include/linux/if.h |    2 ++
 net/core/dev.c     |    4 ++--
 2 files changed, 4 insertions(+), 2 deletions(-)

--- wireless-dev.orig/include/linux/if.h	2007-08-06 21:02:55.868164177 +0200
+++ wireless-dev/include/linux/if.h	2007-08-06 21:03:05.458164177 +0200
@@ -50,6 +50,8 @@
 #define IFF_LOWER_UP	0x10000		/* driver signals L1 up		*/
 #define IFF_DORMANT	0x20000		/* driver signals dormant	*/
 
+#define IFF_NO_MIRROR	0x40000		/* driver will mirror packets	*/
+
 #define IFF_VOLATILE	(IFF_LOOPBACK|IFF_POINTOPOINT|IFF_BROADCAST|\
 		IFF_MASTER|IFF_SLAVE|IFF_RUNNING|IFF_LOWER_UP|IFF_DORMANT)
 
--- wireless-dev.orig/net/core/dev.c	2007-08-06 21:02:55.898164177 +0200
+++ wireless-dev/net/core/dev.c	2007-08-06 21:04:58.218164177 +0200
@@ -1417,7 +1417,7 @@ static int dev_gso_segment(struct sk_buf
 int dev_hard_start_xmit(struct sk_buff *skb, struct net_device *dev)
 {
 	if (likely(!skb->next)) {
-		if (!list_empty(&ptype_all))
+		if (!list_empty(&ptype_all) && !(dev->flags & IFF_NO_MIRROR))
 			dev_queue_xmit_nit(skb, dev);
 
 		if (netif_needs_gso(dev, skb)) {
@@ -2829,7 +2829,7 @@ int dev_change_flags(struct net_device *
 			       IFF_DYNAMIC | IFF_MULTICAST | IFF_PORTSEL |
 			       IFF_AUTOMEDIA)) |
 		     (dev->flags & (IFF_UP | IFF_VOLATILE | IFF_PROMISC |
-				    IFF_ALLMULTI));
+				    IFF_ALLMULTI | IFF_NO_MIRROR));
 
 	/*
 	 *	Load in the correct multicast list now the flags have changed.


