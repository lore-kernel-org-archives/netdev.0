From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH 0/1] Bridge mirroring function
Date: Thu, 21 Nov 2013 15:28:09 -0800
Message-ID: <20131121152809.4fb38536@nehalam.linuxnetplumber.net>
References: <322017e8-c793-4729-8937-7edc3328f14b@zmail220>
	<166a058a-ed18-4a95-9b5a-64a2641bf2c1@zmail220>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Glenn FEUNTEUN <glenn.feunteun@telecom-bretagne.eu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:56978 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751508Ab3KUX2M (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Nov 2013 18:28:12 -0500
Received: by mail-pa0-f54.google.com with SMTP id rd3so463256pab.27
        for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 15:28:12 -0800 (PST)
In-Reply-To: <166a058a-ed18-4a95-9b5a-64a2641bf2c1@zmail220>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 21 Nov 2013 23:33:11 +0100 (CET)
Glenn FEUNTEUN <glenn.feunteun@telecom-bretagne.eu> wrote:

> Hello
> 
> I am working on a school project whose goal is to implement a traffic mirroring function inside bridge kernel module.
> 
> I implemented the function that lets :
> - select the mirrored interface(s)
> - select ingress, egress or both traffic to be mirrored
> - select the output interface(s)
> 
> Examples :
> 
> a)
> 
> brctl mirror br0 eth0 ingress
> brclt mirror br0 eth1 destination
> 
> All incoming traffic on eth0 will be mirrored on eth1.
> 
> b)
> 
> brctl mirror br0 eth0 egress
> brclt mirror br0 eth1 destination
> 
> All outgoing traffic from eth0 will be mirrored on eth1.
> 
> c)
> 
> brctl mirror br0 eth0 both
> brclt mirror br0 eth1 destination
> 
> All incoming and outgoing traffic coming on or from eth0 will be mirrored on eth1.
> 
> Following is the patch against kernel v3.12.
> 
> I also implemented the userspace counterpart, I'll send the patch in another mail.
> 
> Thank you for giving some feedback on the code and about its possible commit into kernel main tree.
> 
> 
> diff -urBb old/br_forward.c new/br_forward.c
> --- old/br_forward.c	2013-11-12 14:55:59.054134721 +0100
> +++ new/br_forward.c	2013-11-12 14:35:28.262134745 +0100
> @@ -62,6 +62,30 @@
>  
>  }
>  
> +void br_mirror_xmit(const struct net_bridge_port *p, struct sk_buff *skb, u8 mask)
> +{ 
> +    struct net_bridge_port *pos;
> +    struct sk_buff *clone;
> +    /* See if port has mirroring activated on incoming packet
> +       ,outgoing packet or both depending on mask */
> +	if(p->mirror_state & mask)
> +	{
> +		/* Look at each bridge port if one is a mirroring destination */
> +
> +		list_for_each_entry(pos,&p->br->port_list,list)
> +		{
> +			if(pos->mirror_state & BR_MIRROR_DST)
> +			{
> +			    /* Set clone device so it is sent on destination port */
> +			        clone = skb_copy(skb, GFP_ATOMIC);
> +				clone->dev = pos->dev;
> +				skb_push(clone, ETH_HLEN);
> +				dev_queue_xmit(clone);
> +			}
> +		}
> +	}
> +}
> +
>  static void __br_deliver(const struct net_bridge_port *to, struct sk_buff *skb)
>  {
>  	skb = br_handle_vlan(to->br, nbp_get_vlan_info(to), skb);
> @@ -70,6 +94,8 @@
>  
>  	skb->dev = to->dev;
>  
> +	br_mirror_xmit(to,skb,BR_MIRROR_TX);
> +
>  	if (unlikely(netpoll_tx_running(to->br->dev))) {
>  		if (packet_length(skb) > skb->dev->mtu && !skb_is_gso(skb))
>  			kfree_skb(skb);
> diff -urBb old/br_input.c new/br_input.c
> --- old/br_input.c	2013-11-12 14:55:59.054134721 +0100
> +++ new/br_input.c	2013-11-12 14:35:28.262134745 +0100
> @@ -216,6 +216,8 @@
>  		}
>  	}
>  
> +	br_mirror_xmit(p,skb,BR_MIRROR_RX);
> +
>  forward:
>  	switch (p->state) {
>  	case BR_STATE_FORWARDING:
> diff -urBb old/br_private.h new/br_private.h
> --- old/br_private.h	2013-11-12 14:55:59.054134721 +0100
> +++ new/br_private.h	2013-11-13 15:57:33.668402893 +0100
> @@ -159,6 +159,12 @@
>  	u32				designated_cost;
>  	unsigned long			designated_age;
>  
> +	/* Mirroring */
> +#define BR_MIRROR_RX 0x01
> +#define BR_MIRROR_TX 0x02
> +#define BR_MIRROR_DST 0x04
> +	u8				mirror_state;
> +
>  	struct timer_list		forward_delay_timer;
>  	struct timer_list		hold_timer;
>  	struct timer_list		message_age_timer;
> @@ -424,6 +430,7 @@
>  			     bool unicast);
>  extern void br_flood_forward(struct net_bridge *br, struct sk_buff *skb,
>  			     struct sk_buff *skb2, bool unicast);
> +extern void br_mirror_xmit(const struct net_bridge_port *p, struct sk_buff *skb, u8 mask);
>  
>  /* br_if.c */
>  extern void br_port_carrier_check(struct net_bridge_port *p);
> diff -urBb old/br_sysfs_if.c new/br_sysfs_if.c
> --- old/br_sysfs_if.c	2013-11-12 14:55:59.054134721 +0100
> +++ new/br_sysfs_if.c	2013-11-12 14:35:28.262134745 +0100
> @@ -161,6 +161,18 @@
>  BRPORT_ATTR_FLAG(learning, BR_LEARNING);
>  BRPORT_ATTR_FLAG(unicast_flood, BR_FLOOD);
>  
> +static ssize_t show_mirror_state(struct net_bridge_port *p, char *buf)
> +{
> +	return sprintf(buf, "%d\n", p->mirror_state);
> +}
> +static int store_mirror_state(struct net_bridge_port *p, unsigned long v)
> +{
> +	p->mirror_state = v;
> +	return 0;
> +}
> +static BRPORT_ATTR(mirror_state, S_IRUGO | S_IWUSR,
> +		   show_mirror_state, store_mirror_state);
> +
>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>  static ssize_t show_multicast_router(struct net_bridge_port *p, char *buf)
>  {
> @@ -199,6 +211,7 @@
>  	&brport_attr_root_block,
>  	&brport_attr_learning,
>  	&brport_attr_unicast_flood,
> +	&brport_attr_mirror_state,
>  #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
>  	&brport_attr_multicast_router,
>  	&brport_attr_multicast_fast_leave,
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html

This already possible with 'tc mirred action'.
