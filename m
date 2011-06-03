From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] bonding: reset queue mapping prior to transmission to physical device (v5)
Date: Fri, 03 Jun 2011 16:31:06 -0700
Message-ID: <26637.1307143866@death>
References: <1307129073-3769-1-git-send-email-nhorman@tuxdriver.com> <1307133352-4111-1-git-send-email-nhorman@tuxdriver.com>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	"David S. Miller" <davem@davemloft.net>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e39.co.us.ibm.com ([32.97.110.160]:34945 "EHLO
	e39.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753601Ab1FCXbP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 3 Jun 2011 19:31:15 -0400
Received: from d03relay02.boulder.ibm.com (d03relay02.boulder.ibm.com [9.17.195.227])
	by e39.co.us.ibm.com (8.14.4/8.13.1) with ESMTP id p53NH5Ea023046
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 17:17:05 -0600
Received: from d03av06.boulder.ibm.com (d03av06.boulder.ibm.com [9.17.195.245])
	by d03relay02.boulder.ibm.com (8.13.8/8.13.8/NCO v9.1) with ESMTP id p53NVA7g153838
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 17:31:10 -0600
Received: from d03av06.boulder.ibm.com (loopback [127.0.0.1])
	by d03av06.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id p53NaNtR022087
	for <netdev@vger.kernel.org>; Fri, 3 Jun 2011 17:36:23 -0600
In-reply-to: <1307133352-4111-1-git-send-email-nhorman@tuxdriver.com>
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
>v4) fixed to store raw queue_mapping to avoid double decrement
>
>v5) Eric D requested that ->cb access be wrapped in a macro.

	Shouldn't the change log go below the "---" so it doesn't end up
in the git commit log?

	In any event, I looked for ways into bond_dev_queue_xmit without
first passing through bond_select_queue (lest stale cb[] data intrude),
and I don't see any, so I think this is ok.

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>

	-J

>Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
>CC: Jay Vosburgh <fubar@us.ibm.com>
>CC: Andy Gospodarek <andy@greyhouse.net>
>CC: "David S. Miller" <davem@davemloft.net>
>---
> drivers/net/bonding/bond_main.c |   11 +++++++++++
> 1 files changed, 11 insertions(+), 0 deletions(-)
>
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 17b4dd9..abf6e19 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -388,6 +388,8 @@ struct vlan_entry *bond_next_vlan(struct bonding *bond, struct vlan_entry *curr)
> 	return next;
> }
>
>+#define bond_queue_mapping(skb) (*(u16 *)((skb)->cb))
>+
> /**
>  * bond_dev_queue_xmit - Prepare skb for xmit.
>  *
>@@ -400,6 +402,9 @@ int bond_dev_queue_xmit(struct bonding *bond, struct sk_buff *skb,
> {
> 	skb->dev = slave_dev;
> 	skb->priority = 1;
>+
>+	skb->queue_mapping = bond_queue_mapping(skb); 
>+
> 	if (unlikely(netpoll_tx_running(slave_dev)))
> 		bond_netpoll_send_skb(bond_get_slave_by_dev(bond, slave_dev), skb);
> 	else
>@@ -4206,6 +4211,7 @@ static inline int bond_slave_override(struct bonding *bond,
> 	return res;
> }
>
>+
> static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
> {
> 	/*
>@@ -4216,6 +4222,11 @@ static u16 bond_select_queue(struct net_device *dev, struct sk_buff *skb)
> 	 */
> 	u16 txq = skb_rx_queue_recorded(skb) ? skb_get_rx_queue(skb) : 0;
>
>+	/*
>+ 	 * Save the original txq to restore before passing to the driver
>+ 	 */
>+	bond_queue_mapping(skb) = skb->queue_mapping;
>+
> 	if (unlikely(txq >= dev->real_num_tx_queues)) {
> 		do {
> 			txq -= dev->real_num_tx_queues;
>-- 
>1.7.3.4
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com

