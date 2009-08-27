From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 02/14] pktgen: change inlining
Date: Thu, 27 Aug 2009 16:55:08 -0700
Message-ID: <20090827235705.258246781@vyatta.com>
References: <20090827235506.624381734@vyatta.com>
Cc: netdev@vger.kernel.org, Thomas Gleixner <tglx@linutronix.de>
To: David Miller <davem@davemloft.net>,
	Robert Olsson <robert.olsson@its.uu.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:58752 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752825AbZH0X7T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 27 Aug 2009 19:59:19 -0400
Content-Disposition: inline; filename=pktgen-deinline.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Don't force inlining where not needed. Gcc does better job
of deciding to inline local functions.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/core/pktgen.c |   15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

--- a/net/core/pktgen.c	2009-08-27 11:30:10.108520235 -0700
+++ b/net/core/pktgen.c	2009-08-27 11:57:13.510686707 -0700
@@ -2438,7 +2438,7 @@ error:
 	return err;
 }
 
-static inline void free_SAs(struct pktgen_dev *pkt_dev)
+static void free_SAs(struct pktgen_dev *pkt_dev)
 {
 	if (pkt_dev->cflows) {
 		/* let go of the SAs if we have them */
@@ -2453,7 +2453,7 @@ static inline void free_SAs(struct pktge
 	}
 }
 
-static inline int process_ipsec(struct pktgen_dev *pkt_dev,
+static int process_ipsec(struct pktgen_dev *pkt_dev,
 			      struct sk_buff *skb, __be16 protocol)
 {
 	if (pkt_dev->flags & F_IPSEC_ON) {
@@ -3029,8 +3029,8 @@ static struct sk_buff *fill_packet_ipv6(
 	return skb;
 }
 
-static inline struct sk_buff *fill_packet(struct net_device *odev,
-					  struct pktgen_dev *pkt_dev)
+static struct sk_buff *fill_packet(struct net_device *odev,
+				   struct pktgen_dev *pkt_dev)
 {
 	if (pkt_dev->flags & F_IPV6)
 		return fill_packet_ipv6(odev, pkt_dev);
@@ -3341,13 +3341,12 @@ static void pktgen_rem_thread(struct pkt
 	mutex_unlock(&pktgen_thread_lock);
 }
 
-static __inline__ void pktgen_xmit(struct pktgen_dev *pkt_dev)
+static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 {
 	struct net_device *odev = pkt_dev->odev;
 	int (*xmit)(struct sk_buff *, struct net_device *)
 		= odev->netdev_ops->ndo_start_xmit;
 	struct netdev_queue *txq;
-	__u64 idle_start = 0;
 	u16 queue_map;
 	int ret;
 
@@ -3379,7 +3378,7 @@ static __inline__ void pktgen_xmit(struc
 	if (netif_tx_queue_stopped(txq) ||
 	    netif_tx_queue_frozen(txq) ||
 	    need_resched()) {
-		idle_start = getCurUs();
+		u64 idle_start = getCurUs();
 
 		if (!netif_running(odev)) {
 			pktgen_stop_device(pkt_dev);
@@ -3475,7 +3474,7 @@ static __inline__ void pktgen_xmit(struc
 	/* If pkt_dev->count is zero, then run forever */
 	if ((pkt_dev->count != 0) && (pkt_dev->sofar >= pkt_dev->count)) {
 		if (atomic_read(&(pkt_dev->skb->users)) != 1) {
-			idle_start = getCurUs();
+			u64 idle_start = getCurUs();
 			while (atomic_read(&(pkt_dev->skb->users)) != 1) {
 				if (signal_pending(current)) {
 					break;

-- 

