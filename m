From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to physical device (v3)
Date: Fri, 03 Jun 2011 11:06:27 -0700
Message-ID: <15345.1307124387@death>
References: <1307112216.2789.16.camel@bwh-desktop> <1307122353-3414-1-git-send-email-nhorman@tuxdriver.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e2.ny.us.ibm.com ([32.97.182.142]:41640 "EHLO e2.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751229Ab1FCSGe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 3 Jun 2011 14:06:34 -0400
Received: from d01relay05.pok.ibm.com (d01relay05.pok.ibm.com [9.56.227.237])
	by e2.ny.us.ibm.com (8.14.4/8.13.1) with ESMTP id p53HkLbn008885
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 13:46:21 -0400
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d01relay05.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id p53I6XUQ092740
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 14:06:33 -0400
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p53C6T3J020076
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 06:06:29 -0600
In-reply-to: <1307122353-3414-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Neil Horman <nhorman@tuxdriver.com> wrote:

>The bonding driver is multiqueue enabled, in which each queue represents a slave
>to enable optional steering of output frames to given slaves against the default
>output policy.  However, it needs to reset the skb->queue_mapping prior to
>queuing to the physical device or the physical slave (if it is multiqueue) could
>wind up transmitting on an unintended tx queue
>
>Change Notes:
>v2) Based on first pass review, updated the patch to restore the origional queue
>mapping that was found in bond_select_queue, rather than simply resetting to
>zero.  This preserves the value of queue_mapping when it was set on receive in
>the forwarding case which is desireable.
>
>v3) Fixed spelling an casting error in skb->cb
>
>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: "David S. Miller" <davem@davemloft.net>
>---
> drivers/net/bonding/bond_main.c |   10 ++++++++++
> 1 files changed, 10 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 17b4dd9..dbb1048 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -400,6 +400,11 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
> {
> 	skb->dev = slave_dev;
> 	skb->priority = 1;
>+	/*
>+	 *restore the origional mapping
>+	 */

	I don't think this comment (or the one below) really adds much.
If you think they're necessary, then (a) it's "original," and (b)
they'll probably fit on one line.

	Or, alternately, make one of them (probably the one below) big
enough to actually explain what's going on, especially if (as Ben says)
you need to stash queue_mapping directly.

	-J

>+	skb_set_queue_mapping(skb, ((u16 *)skb->cb)[0]);
>+
> 	if (unlikely(netpoll_tx_running(slave_dev)))
> 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
> 	else
>@@ -4216,6 +4221,11 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
> 	 */
> 	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
>
>+	/*
>+ 	 * Save the original txq to restore before passing to the driver
>+ 	 */
>+	((u16 *)skb->cb)[0] = txq;
>+
> 	if (unlikely(txq >= dev->real_num_tx_queues)) {
> 		do {
> 			txq -= dev->real_num_tx_queues;
>-- 
>1.7.3.4

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
