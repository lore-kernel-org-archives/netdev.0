From: Andy Gospodarek <andy@greyhouse.net>
Subject: [PATCH 1/2 net-next][v2] bonding: fix incorrect transmit queue
	offset
Date: Tue, 1 Mar 2011 10:31:36 -0500
Message-ID: <20110301153135.GL11864@gospo.rdu.redhat.com>
References: <20110223230844.GA16476@linuxace.com> <20110223.151357.245408084.davem@davemloft.net> <1298504269.2211.503.camel@localhost> <20110223.155451.70202591.davem@davemloft.net> <20110225225636.GA18792@linuxace.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, bhutchings@solarflare.com,
	andy@greyhouse.net, netdev@vger.kernel.org, fubar@us.ibm.com
To: Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:53090 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752346Ab1CAPb7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Mar 2011 10:31:59 -0500
Content-Disposition: inline
In-Reply-To: <20110225225636.GA18792@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Feb 25, 2011 at 02:56:36PM -0800, Phil Oester wrote:
> On Wed, Feb 23, 2011 at 03:54:51PM -0800, David Miller wrote:
> > From: Ben Hutchings <bhutchings@solarflare.com>
> > Date: Wed, 23 Feb 2011 23:37:49 +0000
> > 
> > > On Wed, 2011-02-23 at 15:13 -0800, David Miller wrote:
> > >> From: Phil Oester <kernel@linuxace.com>
> > >> Date: Wed, 23 Feb 2011 15:08:44 -0800
> > >> 
> > >> > On Wed, Feb 23, 2011 at 02:42:49PM -0500, Andy Gospodarek wrote:
> > >> >> +     while (txq >= dev->real_num_tx_queues) {
> > >> >> +             /* let the user know if we do not have enough tx queues */
> > >> >> +             if (net_ratelimit())
> > >> >> +                     pr_warning("%s selects invalid tx queue %d.  Consider"
> > >> >> +                                " setting module option tx_queues > %d.",
> > >> >> +                                dev->name, txq, dev->real_num_tx_queues);
> > >> >> +             txq -= dev->real_num_tx_queues;
> > >> >> +     }
> > >> > 
> > >> > Think this would be better as a WARN_ONCE, as otherwise syslog will still
> > >> > get flooded with this - even when ratelimited.  See get_rps_cpu in 
> > >> > net/core/dev.c as an example.o
> > >> 
> > >> Agreed.
> > > 
> > > This shouldn't WARN at all.  It is perfectly valid (though non-optimal)
> > > to have different numbers of queues on two different multiqueue devices.
> > 
> > That's also a good point.
> 
> The patch works as expected.  Do we have any agreement on a final version?
> 

Thanks for the testing, Phil.

I'm in favor of this patch as it does alert the admin that bonding may
not have enough default queues, but it is not as verbose (backtrace et
al) and likely to create bug reports as a message from WARN_ON.

Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

---
 drivers/net/bonding/bond_main.c |   26 +++++++++++++++++++-------
 1 files changed, 19 insertions(+), 7 deletions(-)

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 584f97b..acc05d6 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4643,15 +4643,27 @@ out:
 	return res;
 }
 
+/*
+ * This helper function exists to help dev_pick_tx get the correct
+ * destination queue.  Using a helper function skips the a call to
+ * skb_tx_hash and will put the skbs in the queue we expect on their
+ * way down to the bonding driver.
+ */
 static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
 {
-	/*
-	 * This helper function exists to help dev_pick_tx get the correct
-	 * destination queue.  Using a helper function skips the a call to
-	 * skb_tx_hash and will put the skbs in the queue we expect on their
-	 * way down to the bonding driver.
-	 */
-	return skb->queue_mapping;
+	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
+
+	if (txq >= dev->real_num_tx_queues) {
+		/* let the user know if we do not have enough tx queues */
+		if (net_ratelimit())
+			pr_warning("%s selects invalid tx queue %d.  Consider"
+				   " setting module option tx_queues > %d.",
+				   dev->name, txq, dev->real_num_tx_queues);
+		do
+			txq -= dev->real_num_tx_queues;
+		while (txq >= dev->real_num_tx_queues);
+	}
+	return txq;
 }
 
 static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
