From: Robert Olsson <robert@robur.slu.se>
Subject: [PATCH] pktgen: fix multiple queue warning
Date: Tue, 28 Oct 2008 21:10:21 +0100
Message-ID: <18695.29101.262935.694007@robur.slu.se>
References: <20081028193042.22781.15774.stgit@gitlost.lost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, netdev@vger.kernel.org, jeff@garzik.org,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Robert Olsson <robert.olsson@its.uu.se>
To: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from robur.slu.se ([130.238.98.12]:45969 "EHLO robur.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751543AbYJ1UKX (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 28 Oct 2008 16:10:23 -0400
In-Reply-To: <20081028193042.22781.15774.stgit@gitlost.lost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



Hi, 

Looks correct to me. Can test to test tomorrow.

Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

Cheers.
				--ro


Jeff Kirsher writes:
 > From: Jesse Brandeburg <jesse.brandeburg@intel.com>
 > 
 > when testing the new pktgen module with multiple queues and ixgbe with:
 > 	pgset "flag QUEUE_MAP_CPU"
 > 
 > I found that I was getting errors in dmesg like:
 > pktgen: WARNING: QUEUE_MAP_CPU disabled because CPU count (8) exceeds number
 > <4>pktgen: WARNING: of tx queues (8) on eth15
 > 
 > you'll note, 8 really doesn't exceed 8.
 > 
 > This patch seemed to fix the logic errors and also the attempts at
 > limiting line length in printk (which didn't work anyway)
 > 
 > Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
 > Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
 > CC: Robert Olsson <robert.olsson@its.uu.se>
 > --
 > ---
 > 
 >  net/core/pktgen.c |   27 +++++++++++++--------------
 >  1 files changed, 13 insertions(+), 14 deletions(-)
 > 
 > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
 > index 99f656d..a47f5ba 100644
 > --- a/net/core/pktgen.c
 > +++ b/net/core/pktgen.c
 > @@ -1973,28 +1973,27 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 >  
 >  	/* make sure that we don't pick a non-existing transmit queue */
 >  	ntxq = pkt_dev->odev->real_num_tx_queues;
 > -	if (ntxq <= num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
 > +	if (ntxq > num_online_cpus() && (pkt_dev->flags & F_QUEUE_MAP_CPU)) {
 >  		printk(KERN_WARNING "pktgen: WARNING: QUEUE_MAP_CPU "
 > -		       "disabled because CPU count (%d) exceeds number ",
 > -		       num_online_cpus());
 > -		printk(KERN_WARNING "pktgen: WARNING: of tx queues "
 > -		       "(%d) on %s \n", ntxq, pkt_dev->odev->name);
 > +		       "disabled because CPU count (%d) exceeds number "
 > +		       "of tx queues (%d) on %s\n", num_online_cpus(), ntxq,
 > +		       pkt_dev->odev->name);
 >  		pkt_dev->flags &= ~F_QUEUE_MAP_CPU;
 >  	}
 >  	if (ntxq <= pkt_dev->queue_map_min) {
 >  		printk(KERN_WARNING "pktgen: WARNING: Requested "
 > -		       "queue_map_min (%d) exceeds number of tx\n",
 > -		       pkt_dev->queue_map_min);
 > -		printk(KERN_WARNING "pktgen: WARNING: queues (%d) on "
 > -		       "%s, resetting\n", ntxq, pkt_dev->odev->name);
 > +		       "queue_map_min (zero-based) (%d) exceeds valid range "
 > +		       "[0 - %d] for (%d) queues on %s, resetting\n",
 > +		       pkt_dev->queue_map_min, (ntxq ?: 1)- 1, ntxq,
 > +		       pkt_dev->odev->name);
 >  		pkt_dev->queue_map_min = ntxq - 1;
 >  	}
 > -	if (ntxq <= pkt_dev->queue_map_max) {
 > +	if (pkt_dev->queue_map_max >= ntxq) {
 >  		printk(KERN_WARNING "pktgen: WARNING: Requested "
 > -		       "queue_map_max (%d) exceeds number of tx\n",
 > -		       pkt_dev->queue_map_max);
 > -		printk(KERN_WARNING "pktgen: WARNING: queues (%d) on "
 > -		       "%s, resetting\n", ntxq, pkt_dev->odev->name);
 > +		       "queue_map_max (zero-based) (%d) exceeds valid range "
 > +		       "[0 - %d] for (%d) queues on %s, resetting\n",
 > +		       pkt_dev->queue_map_max, (ntxq ?: 1)- 1, ntxq,
 > +		       pkt_dev->odev->name);
 >  		pkt_dev->queue_map_max = ntxq - 1;
 >  	}
 >  
 > 
 > --
 > To unsubscribe from this list: send the line "unsubscribe netdev" in
 > the body of a message to majordomo@vger.kernel.org
 > More majordomo info at  http://vger.kernel.org/majordomo-info.html
