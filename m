From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bonding: don't increase rx_dropped after processing LACPDUs
Date: Wed, 02 May 2012 16:10:39 -0700
Message-ID: <1765.1336000239@death.nxdomain>
References: <20120502202309.GA25355@midget.suse.cz> <1335991009.22133.639.camel@edumazet-glaptop> <20120502205118.GB25355@midget.suse.cz>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Andy Gospodarek <andy@greyhouse.net>, netdev@vger.kernel.org
To: Jiri Bohac <jbohac@suse.cz>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:54441 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753477Ab2EBXKr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 May 2012 19:10:47 -0400
Received: from /spool/local
	by e32.co.us.ibm.com with IBM ESMTP SMTP Gateway: Authorized Use Only! Violators will be prosecuted
	for <netdev@vger.kernel.org> from <fubar@us.ibm.com>;
	Wed, 2 May 2012 17:10:47 -0600
Received: from d03relay03.boulder.ibm.com (d03relay03.boulder.ibm.com [9.17.195.228])
	by d03dlp01.boulder.ibm.com (Postfix) with ESMTP id 6B0DD1FF004C
	for <netdev@vger.kernel.org>; Wed,  2 May 2012 17:10:42 -0600 (MDT)
Received: from d03av04.boulder.ibm.com (d03av04.boulder.ibm.com [9.17.195.170])
	by d03relay03.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id q42NAhq1169110
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 17:10:43 -0600
Received: from d03av04.boulder.ibm.com (loopback [127.0.0.1])
	by d03av04.boulder.ibm.com (8.14.4/8.13.1/NCO v10.0 AVout) with ESMTP id q42NAgHu006656
	for <netdev@vger.kernel.org>; Wed, 2 May 2012 17:10:42 -0600
In-reply-to: <20120502205118.GB25355@midget.suse.cz>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Bohac <jbohac@suse.cz> wrote:

>On Wed, May 02, 2012 at 10:36:49PM +0200, Eric Dumazet wrote:
>> > +			if (ret == RX_HANDLER_CONSUMED)
>> > +				kfree_skb(skb);
>> 
>> After this point, you have use after free :
>> 
>> if (bond_should_deliver_exact_match(skb, slave, bond)) { 
>> 	...
>> }
>> skb->dev = bond->dev;
>
>Thanks for spotting this! Let's just return immediately at that
>point. Fixed version below:

	Won't this make it impossible to bind a PF_PACKET socket to
sll_protocol == ETH_P_SLOW and see the LACPDUs, but only when bonding is
running 802.3ad?  This because the ptype_all check in
__netif_receive_skb happens before the rx_handler, but the ptype_base
check (bound packet socket, for example) happens after.  Currently,
libpcap looks to bind to ETH_P_ALL, so it won't be affected.

	If so, is that something we care about?

	-J


>Signed-off-by: Jiri Bohac <jbohac@suse.cz>
>
>diff --git a/drivers/net/bonding/bond_3ad.c b/drivers/net/bonding/bond_3ad.c
>--- a/drivers/net/bonding/bond_3ad.c
>+++ b/drivers/net/bonding/bond_3ad.c
>@@ -2173,9 +2173,10 @@ re_arm:
>  * received frames (loopback). Since only the payload is given to this
>  * function, it check for loopback.
>  */
>-static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u16 length)
>+static int bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u16 length)
> {
> 	struct port *port;
>+	int ret = RX_HANDLER_ANOTHER;
>
> 	if (length >= sizeof(struct lacpdu)) {
>
>@@ -2184,11 +2185,12 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
> 		if (!port->slave) {
> 			pr_warning("%s: Warning: port of slave %s is uninitialized\n",
> 				   slave->dev->name, slave->dev->master->name);
>-			return;
>+			return ret;
> 		}
>
> 		switch (lacpdu->subtype) {
> 		case AD_TYPE_LACPDU:
>+			ret = RX_HANDLER_CONSUMED;
> 			pr_debug("Received LACPDU on port %d\n",
> 				 port->actor_port_number);
> 			/* Protect against concurrent state machines */
>@@ -2198,6 +2200,7 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
> 			break;
>
> 		case AD_TYPE_MARKER:
>+			ret = RX_HANDLER_CONSUMED;
> 			// No need to convert fields to Little Endian since we don't use the marker's fields.
>
> 			switch (((struct bond_marker *)lacpdu)->tlv_type) {
>@@ -2219,6 +2222,7 @@ static void bond_3ad_rx_indication(struct lacpdu *lacpdu, struct slave *slave, u
> 			}
> 		}
> 	}
>+	return ret;
> }
>
> /**
>@@ -2456,18 +2460,20 @@ out:
> 	return NETDEV_TX_OK;
> }
>
>-void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
>+int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
> 			  struct slave *slave)
> {
>+	int ret = RX_HANDLER_ANOTHER;
> 	if (skb->protocol != PKT_TYPE_LACPDU)
>-		return;
>+		return ret;
>
> 	if (!pskb_may_pull(skb, sizeof(struct lacpdu)))
>-		return;
>+		return ret;
>
> 	read_lock(&bond->lock);
>-	bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, skb->len);
>+	ret = bond_3ad_rx_indication((struct lacpdu *) skb->data, slave, skb->len);
> 	read_unlock(&bond->lock);
>+	return ret;
> }
>
> /*
>diff --git a/drivers/net/bonding/bond_3ad.h b/drivers/net/bonding/bond_3ad.h
>index 235b2cc..5ee7e3c 100644
>--- a/drivers/net/bonding/bond_3ad.h
>+++ b/drivers/net/bonding/bond_3ad.h
>@@ -274,7 +274,7 @@ void bond_3ad_adapter_duplex_changed(struct slave *slave);
> void bond_3ad_handle_link_change(struct slave *slave, char link);
> int  bond_3ad_get_active_agg_info(struct bonding *bond, struct ad_info *ad_info);
> int bond_3ad_xmit_xor(struct sk_buff *skb, struct net_device *dev);
>-void bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
>+int bond_3ad_lacpdu_recv(struct sk_buff *skb, struct bonding *bond,
> 			  struct slave *slave);
> int bond_3ad_set_carrier(struct bonding *bond);
> void bond_3ad_update_lacp_rate(struct bonding *bond);
>diff --git a/drivers/net/bonding/bond_main.c b/drivers/net/bonding/bond_main.c
>index 62d2409..0a0f4a6 100644
>--- a/drivers/net/bonding/bond_main.c
>+++ b/drivers/net/bonding/bond_main.c
>@@ -1444,8 +1444,9 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> 	struct sk_buff *skb = *pskb;
> 	struct slave *slave;
> 	struct bonding *bond;
>-	void (*recv_probe)(struct sk_buff *, struct bonding *,
>+	int (*recv_probe)(struct sk_buff *, struct bonding *,
> 				struct slave *);
>+	int ret = RX_HANDLER_ANOTHER;
>
> 	skb = skb_share_check(skb, GFP_ATOMIC);
> 	if (unlikely(!skb))
>@@ -1464,8 +1465,12 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> 		struct sk_buff *nskb = skb_clone(skb, GFP_ATOMIC);
>
> 		if (likely(nskb)) {
>-			recv_probe(nskb, bond, slave);
>+			ret = recv_probe(nskb, bond, slave);
> 			dev_kfree_skb(nskb);
>+			if (ret == RX_HANDLER_CONSUMED) {
>+				kfree_skb(skb);
>+				return ret;
>+			}
> 		}
> 	}
>
>@@ -1487,7 +1492,7 @@ static rx_handler_result_t bond_handle_frame(struct sk_buff **pskb)
> 		memcpy(eth_hdr(skb)->h_dest, bond->dev->dev_addr, ETH_ALEN);
> 	}
>
>-	return RX_HANDLER_ANOTHER;
>+	return ret;
> }
>
> /* enslave device <slave> to bond device <master> */
>@@ -2723,7 +2728,7 @@ static void bond_validate_arp(struct bonding *bond, struct slave *slave, __be32
> 	}
> }
>
>-static void bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
>+static int bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
> 			 struct slave *slave)
> {
> 	struct arphdr *arp;
>@@ -2731,7 +2736,7 @@ static void bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
> 	__be32 sip, tip;
>
> 	if (skb->protocol != __cpu_to_be16(ETH_P_ARP))
>-		return;
>+		return RX_HANDLER_ANOTHER;
>
> 	read_lock(&bond->lock);
>
>@@ -2776,6 +2781,7 @@ static void bond_arp_rcv(struct sk_buff *skb, struct bonding *bond,
>
> out_unlock:
> 	read_unlock(&bond->lock);
>+	return RX_HANDLER_ANOTHER;
> }
>
> /*
>
>
>-- 
>Jiri Bohac <jbohac@suse.cz>
>SUSE Labs, SUSE CZ

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
