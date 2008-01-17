From: Neil Turton <nturton@solarflare.com>
Subject: [PATCH net-2.6.25] net: Improve cache line coherency of ingress qdisc
Date: Thu, 17 Jan 2008 11:04:44 +0000
Message-ID: <478F364C.1000301@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-net-drivers <linux-net-drivers@solarflare.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 216-237-3-220.orange.nextweb.net ([216.237.3.220]:15509 "EHLO
	OCEX01.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1751071AbYAQLVV (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2008 06:21:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the ingress qdisc members of struct net_device from the transmit
cache line to the receive cache line to avoid cache line ping-pong.
These members are only used on the receive path.

Signed-off-by: Neil Turton <nturton@solarflare.com>
---

--- net-2.6.25.git-orig/include/linux/netdevice.h	2008-01-15 17:43:08.000000000 +0000
+++ net-2.6.25.git-ndt1/include/linux/netdevice.h	2008-01-16 09:46:19.000000000 +0000
@@ -597,37 +597,37 @@ struct net_device
 /*
  * Cache line mostly used on receive path (including eth_type_trans())
  */
 	unsigned long		last_rx;	/* Time of last Rx	*/
 	/* Interface address info used in eth_type_trans() */
 	unsigned char		dev_addr[MAX_ADDR_LEN];	/* hw address, (before bcast 
 							because most packets are unicast) */
 
 	unsigned char		broadcast[MAX_ADDR_LEN];	/* hw bcast add	*/
 
+	/* ingress path synchronizer */
+	spinlock_t		ingress_lock;
+	struct Qdisc		*qdisc_ingress;
+
 /*
  * Cache line mostly used on queue transmit path (qdisc)
  */
 	/* device queue lock */
 	spinlock_t		queue_lock ____cacheline_aligned_in_smp;
 	struct Qdisc		*qdisc;
 	struct Qdisc		*qdisc_sleeping;
 	struct list_head	qdisc_list;
 	unsigned long		tx_queue_len;	/* Max frames per queue allowed */
 
 	/* Partially transmitted GSO packet. */
 	struct sk_buff		*gso_skb;
 
-	/* ingress path synchronizer */
-	spinlock_t		ingress_lock;
-	struct Qdisc		*qdisc_ingress;
-
 /*
  * One part is mostly used on xmit path (device)
  */
 	/* hard_start_xmit synchronizer */
 	spinlock_t		_xmit_lock ____cacheline_aligned_in_smp;
 	/* cpu id of processor entered to hard_start_xmit or -1,
 	   if nobody entered there.
 	 */
 	int			xmit_lock_owner;
 	void			*priv;	/* pointer to private data	*/

