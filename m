From: robert@herjulf.net
Subject: [PATCH] pktgen: Fix device name compares
Date: Mon, 23 Nov 2009 15:44:47 +0100
Message-ID: <19210.40927.13011.176740@gargle.gargle.HOWL>
References: <4B0A75A5.8000106@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Robert Olsson <robert.olsson@its.uu.se>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from klais.its.uu.se ([130.238.7.59]:40918 "EHLO klais.its.uu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756924AbZKWMlB (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 23 Nov 2009 07:41:01 -0500
In-Reply-To: <4B0A75A5.8000106@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Eric Dumazet writes:
 > Commit e6fce5b916cd7f7f7 (pktgen: multiqueue etc.) tried to relax
 > the pktgen restriction of one device per kernel thread, adding a '@'
 > tag to device names.
 > 
 > Problem is we dont perform check on full pktgen device name.
 > This allows adding many time same 'device' to pktgen thread
 > 
 >  pgset "add_device eth0@0"
 > 
 > one session later :
 > 
 >  pgset "add_device eth0@0"
 > 
 > (This doesnt find previous device)

 

 > Solution to this problem is to use a odevname field (includes @ tag and suffix),
 > instead of using netdevice name.


 Ok. So the duplicate test got wrong when the multiqueue stuff was 
 added. 

 Signed-off-by: Robert Olsson <robert.olsson@its.uu.se>

 Cheers
					--ro



 > Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
 > ---
 >  net/core/pktgen.c |   18 ++++++++++--------
 >  1 file changed, 10 insertions(+), 8 deletions(-)
 > 
 > diff --git a/net/core/pktgen.c b/net/core/pktgen.c
 > index d38470a..1813f08 100644
 > --- a/net/core/pktgen.c
 > +++ b/net/core/pktgen.c
 > @@ -364,6 +364,7 @@ struct pktgen_dev {
 >  				  * device name (not when the inject is
 >  				  * started as it used to do.)
 >  				  */
 > +	char odevname[32];
 >  	struct flow_state *flows;
 >  	unsigned cflows;	/* Concurrent flows (config) */
 >  	unsigned lflow;		/* Flow length  (config) */
 > @@ -529,7 +530,7 @@ static int pktgen_if_show(struct seq_file *seq, void *v)
 >  	seq_printf(seq,
 >  		   "     frags: %d  delay: %llu  clone_skb: %d  ifname: %s\n",
 >  		   pkt_dev->nfrags, (unsigned long long) pkt_dev->delay,
 > -		   pkt_dev->clone_skb, pkt_dev->odev->name);
 > +		   pkt_dev->clone_skb, pkt_dev->odevname);
 >  
 >  	seq_printf(seq, "     flows: %u flowlen: %u\n", pkt_dev->cflows,
 >  		   pkt_dev->lflow);
 > @@ -1689,13 +1690,13 @@ static int pktgen_thread_show(struct seq_file *seq, void *v)
 >  	if_lock(t);
 >  	list_for_each_entry(pkt_dev, &t->if_list, list)
 >  		if (pkt_dev->running)
 > -			seq_printf(seq, "%s ", pkt_dev->odev->name);
 > +			seq_printf(seq, "%s ", pkt_dev->odevname);
 >  
 >  	seq_printf(seq, "\nStopped: ");
 >  
 >  	list_for_each_entry(pkt_dev, &t->if_list, list)
 >  		if (!pkt_dev->running)
 > -			seq_printf(seq, "%s ", pkt_dev->odev->name);
 > +			seq_printf(seq, "%s ", pkt_dev->odevname);
 >  
 >  	if (t->result[0])
 >  		seq_printf(seq, "\nResult: %s\n", t->result);
 > @@ -1995,7 +1996,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 >  		       "queue_map_min (zero-based) (%d) exceeds valid range "
 >  		       "[0 - %d] for (%d) queues on %s, resetting\n",
 >  		       pkt_dev->queue_map_min, (ntxq ?: 1) - 1, ntxq,
 > -		       pkt_dev->odev->name);
 > +		       pkt_dev->odevname);
 >  		pkt_dev->queue_map_min = ntxq - 1;
 >  	}
 >  	if (pkt_dev->queue_map_max >= ntxq) {
 > @@ -2003,7 +2004,7 @@ static void pktgen_setup_inject(struct pktgen_dev *pkt_dev)
 >  		       "queue_map_max (zero-based) (%d) exceeds valid range "
 >  		       "[0 - %d] for (%d) queues on %s, resetting\n",
 >  		       pkt_dev->queue_map_max, (ntxq ?: 1) - 1, ntxq,
 > -		       pkt_dev->odev->name);
 > +		       pkt_dev->odevname);
 >  		pkt_dev->queue_map_max = ntxq - 1;
 >  	}
 >  
 > @@ -3263,7 +3264,7 @@ static int pktgen_stop_device(struct pktgen_dev *pkt_dev)
 >  
 >  	if (!pkt_dev->running) {
 >  		printk(KERN_WARNING "pktgen: interface: %s is already "
 > -		       "stopped\n", pkt_dev->odev->name);
 > +		       "stopped\n", pkt_dev->odevname);
 >  		return -EINVAL;
 >  	}
 >  
 > @@ -3467,7 +3468,7 @@ static void pktgen_xmit(struct pktgen_dev *pkt_dev)
 >  	default: /* Drivers are not supposed to return other values! */
 >  		if (net_ratelimit())
 >  			pr_info("pktgen: %s xmit error: %d\n",
 > -				odev->name, ret);
 > +				pkt_dev->odevname, ret);
 >  		pkt_dev->errors++;
 >  		/* fallthru */
 >  	case NETDEV_TX_LOCKED:
 > @@ -3576,7 +3577,7 @@ static struct pktgen_dev *pktgen_find_dev(struct pktgen_thread *t,
 >  	if_lock(t);
 >  
 >  	list_for_each_entry(p, &t->if_list, list)
 > -		if (strncmp(p->odev->name, ifname, IFNAMSIZ) == 0) {
 > +		if (strncmp(p->odevname, ifname, IFNAMSIZ) == 0) {
 >  			pkt_dev = p;
 >  			break;
 >  		}
 > @@ -3632,6 +3633,7 @@ static int pktgen_add_device(struct pktgen_thread *t, const char *ifname)
 >  	if (!pkt_dev)
 >  		return -ENOMEM;
 >  
 > +	strcpy(pkt_dev->odevname, ifname);
 >  	pkt_dev->flows = vmalloc(MAX_CFLOWS * sizeof(struct flow_state));
 >  	if (pkt_dev->flows == NULL) {
 >  		kfree(pkt_dev);
