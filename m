From: Andy Gospodarek <andy@greyhouse.net>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 18:12:03 -0500
Message-ID: <20110223231203.GG11864@gospo.rdu.redhat.com>
References: <1298490169-5224-1-git-send-email-andy@greyhouse.net> <720.1298499545@death>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org,
	Phil Oester <kernel@linuxace.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:30144 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754544Ab1BWXMa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Feb 2011 18:12:30 -0500
Content-Disposition: inline
In-Reply-To: <720.1298499545@death>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Feb 23, 2011 at 02:19:05PM -0800, Jay Vosburgh wrote:
> Andy Gospodarek <andy@greyhouse.net> wrote:
> 
> >Users noticed the following messages:
> >
> >kernel: bond0 selects TX queue 16, but real number of TX queues is 16
> >
> >were filling their logs when frames received from a device that
> >contained 16 input queues were being forwarded out of a bonded device.
> >Ben pointed out that the contents of skb->queue_mapping cannot be
> >directly mapped to a transmit queue, so I went with his suggestion for a
> >solution to the offset problem.
> >
> >The function now also warns the user to increase the default value for
> >tx_queues if needed and returns a valid tx queue to dev_pick_tx.
> >
> >Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
> >Reported-by: Phil Oester <kernel@linuxace.com>
> >CC: Ben Hutchings <bhutchings@solarflare.com>
> >---
> > drivers/net/bonding/bond_main.c |   24 +++++++++++++++++-------
> > 1 files changed, 17 insertions(+), 7 deletions(-)
> >
> >diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
> >index 77e3c6a..1512c83 100644
> >--- a/drivers/net/bonding/bond_main.c
> >+++ b/drivers/net/bonding/bond_main.c
> >@@ -4533,15 +4533,25 @@ out:
> > 	return res;
> > }
> >
> >+/*
> >+ * This helper function exists to help dev_pick_tx get the correct
> >+ * destination queue.  Using a helper function skips the a call to
> >+ * skb_tx_hash and will put the skbs in the queue we expect on their
> >+ * way down to the bonding driver.
> >+ */
> > static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
> > {
> >-	/*
> >-	 * This helper function exists to help dev_pick_tx get the correct
> >-	 * destination queue.  Using a helper function skips the a call to
> >-	 * skb_tx_hash and will put the skbs in the queue we expect on their
> >-	 * way down to the bonding driver.
> >-	 */
> >-	return skb->queue_mapping;
> >+	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
> >+
> >+	while (txq >= dev->real_num_tx_queues) {
> >+		/* let the user know if we do not have enough tx queues */
> >+		if (net_ratelimit())
> >+			pr_warning("%s selects invalid tx queue %d.  Consider"
> >+				   " setting module option tx_queues > %d.",
> >+				   dev->name, txq, dev->real_num_tx_queues);
> >+		txq -= dev->real_num_tx_queues;
> 
> 	Would this be better as:
> 
> 	if (txq >= dev->real_num_tx_queues) {
> 		/* let the user know if we do not have enough tx queues */
> 		if (net_ratelimit())
> 			pr_warning("%s selects invalid tx queue %d.  Consider"
> 				   " setting module option tx_queues > %d.",
> 				   dev->name, txq, dev->real_num_tx_queues);
> 		txq %= dev->real_num_tx_queues;
> 	}
> 
> 	I.e., use one modulus instead of a looping subtraction?  If the
> queue id in the packet is substantially out of range, the loop may
> interate multiple times.  Presumably you want to distribute the out of
> range queue mappings (not just assign them all to the same queue id).
> 

I hesitated to put the printk inside the while, but decided to do it as
it looked cleaner than a bunch of if/while statements and this loop was
likely to get run only once based on current settings and hardware out
there.

I'm not a big fan of modulo as it is generally pretty expensive when
most cases will be covered with a single subtraction.  I could be
over-stating the expense, though.

While it would be nice to distribute things more evenly, this code
essentially does what the __skb_tx_hash does right now, so it seemed
logical to do the same.

If you would rather not see the pr_warning in the loop, this could work
as well and doesn't look too nasty.

diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
index 77e3c6a..2d3ae54 100644
--- a/drivers/net/bonding/bond_main.c
+++ b/drivers/net/bonding/bond_main.c
@@ -4533,15 +4533,27 @@ out:
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
