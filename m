From: Robert Olsson <robert@robur.slu.se>
Subject: Re: [PATCH] pktgen: fix multiple queue warning
Date: Mon, 17 Nov 2008 09:59:03 +0100
Message-ID: <18721.12887.390889.914789@robur.slu.se>
References: <20081028193042.22781.15774.stgit@gitlost.lost>
	<18709.30748.784246.990265@robur.slu.se>
	<20081116.233006.128063706.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert.Olsson@data.slu.se, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org, jeff@garzik.org,
	jesse.brandeburg@intel.com, robert.olsson@its.uu.se
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:36480 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752290AbYKQI7G (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 17 Nov 2008 03:59:06 -0500
In-Reply-To: <20081116.233006.128063706.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


David Miller writes:

 > >  This triggers with the niu driver which has 12 TX queues on our 8 CPU-core 

> Can someone cook up a patch to fix this?

Here is one suggestion...

As number of TX queues in unrelated to number of CPU's we remove this test
and just make sure nxtq never gets exceeded.

Cheers.
					--ro


Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>


diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index a47f5ba..8997e91 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -1973,13 +1973,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 
 	/* make sure that we don't pick a non-existing transmit queue */
 	ntxq = pkt_dev->odev->real_num_tx_queues;
-	if (ntxq > num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
-		printk(KERN_WARNING "pktgen: WARNING: QUEUE_MAP_CPU "
-		       "disabled because CPU count (%d) exceeds number "
-		       "of tx queues (%d) on %s\n", num_online_cpus(), ntxq,
-		       pkt_dev->odev->name);
-		pkt_dev->flags &= ~F_QUEUE_MAP_CPU;
-	}
+
 	if (ntxq <= pkt_dev->queue_map_min) {
 		printk(KERN_WARNING "pktgen: WARNING: Requested "
 		       "queue_map_min (zero-based) (%d) exceeds valid range "
@@ -2202,6 +2196,7 @@ static void set_cur_queue_map(struct pktgen_dev *pkt_dev)
 		}
 		pkt_dev->cur_queue_map = t;
 	}
+	pkt_dev->cur_queue_map  = pkt_dev->cur_queue_map % pkt_dev->odev->real_num_tx_queues;
 }
 
 /* Increment/randomize headers according to flags and current values

