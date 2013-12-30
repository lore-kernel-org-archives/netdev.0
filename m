From: Florian Westphal <fw@strlen.de>
Subject: Re: [PATCH] macvlan: fix oops with vlan-on-top and HW_VLAN_CTAG_TX
 lowerdev
Date: Mon, 30 Dec 2013 11:27:12 +0100
Message-ID: <20131230102712.GO29632@breakpoint.cc>
References: <1388237920-5140-1-git-send-email-fw@strlen.de>
 <20131229.170121.154913581019152817.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fw@strlen.de, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([80.244.247.6]:33497 "EHLO
	Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754490Ab3L3K1O (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Dec 2013 05:27:14 -0500
Content-Disposition: inline
In-Reply-To: <20131229.170121.154913581019152817.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Miller <davem@davemloft.net> wrote:
> From: Florian Westphal <fw@strlen.de>
> Date: Sat, 28 Dec 2013 14:38:40 +0100
> 
> >  Or is the real bug the use of netdev_priv in macvlan_hard_header()?
> 
> That's a really good question.
[..]
> So the more I think about this, the more I think that the operations
> assignment VLAN is doing is illegal.  If it wants to "pass through"
> it must do so with explicit handlers, ones that pass the expected
> device to the hard header ops.

Both bonding and team seem to do the same.  Guess it was never
a problem since most create hooks don't use netdev_priv.

> So vlan_dev.c would have things like:
> 
> static int vlan_passthru_hard_header(struct sk_buff *skb, struct net_device *dev,
> 				     unsigned short type,
> 				     const void *daddr, const void *saddr,
> 				     unsigned int len)
> {
> 	struct vlan_dev_priv *vlan = vlan_dev_priv(dev);
> 	struct net_device *real_dev = vlan->real_dev;
> 
> 	return real_dev->header_ops->create(skb, real_dev, type, daddr, saddr, len);
> }

I wonder if this needs to use dev_hard_header() to protect against
NULL header_ops/create hook. macvlan does this.

> static int vlan_passthru_rebuild_header(struct sk_buff *skb)
> {
> 	struct net_device *dev = skb->dev;
> 	struct net_device *real_dev;
> 	struct vlan_dev_priv *vlan;
> 
> 	vlan = vlan_dev_priv(dev);
> 	real_dev = vlan->real_dev;
> 
> 	return real_dev->header_ops->rebuild(skb);
> }

similar, e.g. drivers/net/plip/plip.c defines 'create' and 'cache' but
no 'rebuild'.

> Can someone test this?

Here is what i did in qemu guest running net-tree+your patch below:

ip link add link eth0 name wan0 type macvlan
ip link add link wan0 name wan1 type vlan id 2
ip link set wan0 up

[ without your patch it would oops real soon now ]

ip addr add 10.0.0.2/8 dev wan1
ip link set wan1 up

- host/guest can xmit data using vlan interface (tested with netcat)
- tcpdump -ne on host shows:
[ .. ] 9:fc:b7, ethertype 802.1Q (0x8100), length 1518: vlan 2, p 0, ethertype IPv4, 10.0.0.1.12345 > 10.0.0.2.50369 [..]
ethtool -k wan0 on guest shows:
rx-vlan-offload: on [fixed]
tx-vlan-offload: on [fixed]

So, this looks good to me.

Many thanks for investigating this issue!
