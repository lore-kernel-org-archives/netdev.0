From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: bond_select_queue off by one
Date: Thu, 17 Feb 2011 20:41:48 -0800
Message-ID: <22094.1298004108@death>
References: <20110218020713.GA9696@linuxace.com>
Cc: netdev@vger.kernel.org
To: Andy Gospodarek <andy@greyhouse.net>,
	Phil Oester <kernel@linuxace.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e37.co.us.ibm.com ([32.97.110.158]:47123 "EHLO
	e37.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751888Ab1BREmA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Feb 2011 23:42:00 -0500
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by e37.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p1I4dOYn007213
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 21:39:24 -0700
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p1I4fvrq119136
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 21:41:57 -0700
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p1I4kYgg014155
	for <netdev@vger.kernel.org>; Thu, 17 Feb 2011 21:46:34 -0700
In-reply-to: <20110218020713.GA9696@linuxace.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Phil Oester <kernel@linuxace.com> wrote:

>The bonding driver's bond_select_queue function simply returns
>skb->queue_mapping.  However queue_mapping could be == 16
>for queue #16.  This causes the following message to be flooded
>to syslog:
>
>kernel: bondx selects TX queue 16, but real number of TX queues is 16
>
>ndo_select_queue wants a zero-based number, so bonding driver needs
>to subtract one to return the proper queue number.  Also fix grammar in
>a comment while in the vicinity.

	Andy, can you comment on this?

	If memory serves, the omission of queue ID zero was on purpose;
is this patch going to break any of the functionality added by:

commit bb1d912323d5dd50e1079e389f4e964be14f0ae3
Author: Andy Gospodarek <andy@greyhouse.net>
Date:   Wed Jun 2 08:40:18 2010 +0000

    bonding: allow user-controlled output slave selection


Ben Hutchings <bhutchings@solarflare.com> wrote:

>This looks basically correct, but it should use the proper functions:
>
>	skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;

	As Ben points out, skb_rx_queue_recorded, skb_record_rx_queue,
et al, do the offset by one internally, but the bond_slave_override
function is comparing the slave's queue_id to the skb->queue_mapping.

	That makes me wonder if this patch is going to mess things up,
and if bond_slave_override should also use the skb_rx_queue_recorded, et
al, functions.

	-J

>Phil Oester
>
>Signed-off-by: Phil Oester <kernel@linuxace.com>
>
>
>--- linux-2.6/drivers/net/bonding/bond_main.c.orig	2011-01-30 09:15:09.813843817 -0800
>+++ linux-2.6/drivers/net/bonding/bond_main.c	2011-02-17 18:02:46.919050909 -0800
>@@ -4537,11 +4537,11 @@
> {
> 	/*
> 	 * This helper function exists to help dev_pick_tx get the correct
>-	 * destination queue.  Using a helper function skips the a call to
>+	 * destination queue.  Using a helper function skips a call to
> 	 * skb_tx_hash and will put the skbs in the queue we expect on their
> 	 * way down to the bonding driver.
> 	 */
>-	return skb->queue_mapping;
>+	return skb->queue_mapping ? skb->queue_mapping - 1 : 0;
> }
>
> static netdev_tx_t bond_start_xmit(struct sk_buff *skb, struct net_device *dev)

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
