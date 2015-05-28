From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Drops in qdisc on ifb interface
Date: Thu, 28 May 2015 08:14:45 -0700
Message-ID: <1432826085.7456.6.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1432584300.32671.103.camel@jasiiieee.pacifera.com>
	 <1432593064.4060.190.camel@edumazet-glaptop2.roam.corp.google.com>
	 <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: "jsullivan@opensourcedevel.com" <jsullivan@opensourcedevel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f173.google.com ([209.85.213.173]:35547 "EHLO
	mail-ig0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753304AbbE1POs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 May 2015 11:14:48 -0400
Received: by igbyr2 with SMTP id yr2so114910837igb.0
        for <netdev@vger.kernel.org>; Thu, 28 May 2015 08:14:47 -0700 (PDT)
In-Reply-To: <1767970154.119773.1432823923389.JavaMail.open-xchange@oxuslxltgw11.lxa.perfora.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2015-05-28 at 10:38 -0400, jsullivan@opensourcedevel.com wrote:

> This has been an interesting exercise - thank you for your help along the way,
> Eric.  IFB did not seem to bottleneck in our initial testing but there was
> really only one flow of traffic during the test at around 1 Gbps.  However, on a
> non-test system with many different flows, IFB does seem to be a serious
> bottleneck - I assume this is the consequence of being single-threaded.
> 
> Single queue did not seem to help.
> 
> Am I correct to assume that IFB would be as much as a bottleneck on the ingress
> side as it would be on the egress side? If so, is there any way to do high
> performance ingress traffic shaping on Linux - a multi-threaded version of IFB
> or a different approach? Thanks - John

IFB has still a long way before being efficient.

In the mean time, you could play with following patch, and
setup /sys/class/net/eth0/gro_timeout to 20000

This way, the GRO aggregation will work even at 1Gbps, and your IFB will
get big GRO packets instead of single MSS segments.

Both IFB but also IP/TCP stack will have less work to do,
and receiver will send fewer ACK packets as well.

diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
index f287186192bb655ba2dc1a205fb251351d593e98..c37f6657c047d3eb9bd72b647572edd53b1881ac 100644
--- a/drivers/net/ethernet/intel/igb/igb_main.c
+++ b/drivers/net/ethernet/intel/igb/igb_main.c
@@ -151,7 +151,7 @@ static void igb_setup_dca(struct igb_adapter *);
 #endif /* CONFIG_IGB_DCA */
 static int igb_poll(struct napi_struct *, int);
 static bool igb_clean_tx_irq(struct igb_q_vector *);
-static bool igb_clean_rx_irq(struct igb_q_vector *, int);
+static unsigned int igb_clean_rx_irq(struct igb_q_vector *, int);
 static int igb_ioctl(struct net_device *, struct ifreq *, int cmd);
 static void igb_tx_timeout(struct net_device *);
 static void igb_reset_task(struct work_struct *);
@@ -6342,6 +6342,7 @@ static int igb_poll(struct napi_struct *napi, int budget)
 						     struct igb_q_vector,
 						     napi);
 	bool clean_complete = true;
+	unsigned int packets = 0;
 
 #ifdef CONFIG_IGB_DCA
 	if (q_vector->adapter->flags & IGB_FLAG_DCA_ENABLED)
@@ -6350,15 +6351,17 @@ static int igb_poll(struct napi_struct *napi, int budget)
 	if (q_vector->tx.ring)
 		clean_complete = igb_clean_tx_irq(q_vector);
 
-	if (q_vector->rx.ring)
-		clean_complete &= igb_clean_rx_irq(q_vector, budget);
+	if (q_vector->rx.ring) {
+		packets = igb_clean_rx_irq(q_vector, budget);
+		clean_complete &= packets < budget;
+	}
 
 	/* If all work not completed, return budget and keep polling */
 	if (!clean_complete)
 		return budget;
 
 	/* If not enough Rx work done, exit the polling mode */
-	napi_complete(napi);
+	napi_complete_done(napi, packets);
 	igb_ring_irq_enable(q_vector);
 
 	return 0;
@@ -6926,7 +6929,7 @@ static void igb_process_skb_fields(struct igb_ring *rx_ring,
 	skb->protocol = eth_type_trans(skb, rx_ring->netdev);
 }
 
-static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
+static unsigned int igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 {
 	struct igb_ring *rx_ring = q_vector->rx.ring;
 	struct sk_buff *skb = rx_ring->skb;
@@ -7000,7 +7003,7 @@ static bool igb_clean_rx_irq(struct igb_q_vector *q_vector, const int budget)
 	if (cleaned_count)
 		igb_alloc_rx_buffers(rx_ring, cleaned_count);
 
-	return total_packets < budget;
+	return total_packets;
 }
 
 static bool igb_alloc_mapped_page(struct igb_ring *rx_ring,
