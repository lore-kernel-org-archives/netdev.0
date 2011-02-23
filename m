From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH 1/2] bonding: fix incorrect transmit queue offset
Date: Wed, 23 Feb 2011 14:19:05 -0800
Message-ID: <720.1298499545@death>
References: <1298490169-5224-1-git-send-email-andy@greyhouse.net>
Cc: netdev@vger.kernel.org, Phil Oester <kernel@linuxace.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e33.co.us.ibm.com ([32.97.110.151]:45929 "EHLO
	e33.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753865Ab1BWWTI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Feb 2011 17:19:08 -0500
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e33.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1NMCjGc025456
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 15:12:45 -0700
Received: from d03av02.boulder.ibm.com (d03av02.boulder.ibm.com [9.17.195.168])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p1NMJ8KF069986
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 15:19:08 -0700
Received: from d03av02.boulder.ibm.com (loopback [127.0.0.1])
	by d03av02.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1NMJ7fd026135
	for <netdev@vger.kernel.org>; Wed, 23 Feb 2011 15:19:08 -0700
In-reply-to: <1298490169-5224-1-git-send-email-andy@greyhouse.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>Users noticed the following messages:
>
>kernel: bond0 selects TX queue 16, but real number of TX queues is 16
>
>were filling their logs when frames received from a device that
>contained 16 input queues were being forwarded out of a bonded device.
>Ben pointed out that the contents of skb->queue_mapping cannot be
>directly mapped to a transmit queue, so I went with his suggestion for a
>solution to the offset problem.
>
>The function now also warns the user to increase the default value for
>tx_queues if needed and returns a valid tx queue to dev_pick_tx.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>
>Reported-by: Phil Oester <kernel@linuxace.com>
>CC: Ben Hutchings <bhutchings@solarflare.com>
>---
> drivers/net/bonding/bond_main.c |   24 +++++++++++++++++-------
> 1 files changed, 17 insertions(+), 7 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 77e3c6a..1512c83 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -4533,15 +4533,25 @@ out:
> 	return res;
> }
>
>+/*
>+ * This helper function exists to help dev_pick_tx get the correct
>+ * destination queue.  Using a helper function skips the a call to
>+ * skb_tx_hash and will put the skbs in the queue we expect on their
>+ * way down to the bonding driver.
>+ */
> static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
> {
>-	/*
>-	 * This helper function exists to help dev_pick_tx get the correct
>-	 * destination queue.  Using a helper function skips the a call to
>-	 * skb_tx_hash and will put the skbs in the queue we expect on their
>-	 * way down to the bonding driver.
>-	 */
>-	return skb->queue_mapping;
>+	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
>+
>+	while (txq >= dev->real_num_tx_queues) {
>+		/* let the user know if we do not have enough tx queues */
>+		if (net_ratelimit())
>+			pr_warning("%s selects invalid tx queue %d.  Consider"
>+				   " setting module option tx_queues > %d.",
>+				   dev->name, txq, dev->real_num_tx_queues);
>+		txq -= dev->real_num_tx_queues;

	Would this be better as:

	if (txq >= dev->real_num_tx_queues) {
		/* let the user know if we do not have enough tx queues */
		if (net_ratelimit())
			pr_warning("%s selects invalid tx queue %d.  Consider"
				   " setting module option tx_queues > %d.",
				   dev->name, txq, dev->real_num_tx_queues);
		txq %= dev->real_num_tx_queues;
	}

	I.e., use one modulus instead of a looping subtraction?  If the
queue id in the packet is substantially out of range, the loop may
interate multiple times.  Presumably you want to distribute the out of
range queue mappings (not just assign them all to the same queue id).

	-J


>+	}
>+	return txq;
> }
>
> static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)
>-- 
>1.7.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
