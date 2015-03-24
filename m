From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Tue, 24 Mar 2015 09:01:26 -0700
Message-ID: <20150324160126.GA17104@roeck-us.net>
References: <550C92F3.50302@cumulusnetworks.com>
 <20150320220946.GB31769@lunn.ch>
 <20150323002215.GA6074@roeck-us.net>
 <550F6D7D.7030403@gmail.com>
 <550F8102.7040701@roeck-us.net>
 <550F8600.2020300@gmail.com>
 <550F8987.5070600@roeck-us.net>
 <5510498D.5010001@cumulusnetworks.com>
 <CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
 <20150324142921.GA2026@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Scott Feldman <sfeldma@gmail.com>,
	roopa <roopa@cumulusnetworks.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:56945 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753706AbbCXQBu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 12:01:50 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YaRGy-004KmA-HR
	for netdev@vger.kernel.org; Tue, 24 Mar 2015 16:01:44 +0000
Content-Disposition: inline
In-Reply-To: <20150324142921.GA2026@nanopsycho.orion>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 03:29:21PM +0100, Jiri Pirko wrote:
> >
> >diff --git a/drivers/net/ethernet/rocker/rocker.c
> >b/drivers/net/ethernet/rocker/rocker.c
> >index aab962c..0f7217f7 100644
> >--- a/drivers/net/ethernet/rocker/rocker.c
> >+++ b/drivers/net/ethernet/rocker/rocker.c
> >@@ -3931,15 +3931,28 @@ unmap_frag:
> >        return -EMSGSIZE;
> > }
> >
> >+static bool rocker_port_dev_check(struct net_device *dev);
> >+
> > static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct
> >net_device *dev)
> > {
> >        struct rocker_port *rocker_port = netdev_priv(dev);
> >        struct rocker *rocker = rocker_port->rocker;
> >        struct rocker_desc_info *desc_info;
> >        struct rocker_tlv *frags;
> >+       struct net_device *in_dev;
> >        int i;
> >        int err;
> >
> >+       if (rocker_port_is_bridged(rocker_port)) {
> >+               rcu_read_lock();
> >+               in_dev = dev_get_by_index_rcu(dev_net(dev), skb->skb_iif);
> 
> Hmm, you iterate over all ports for every xmit call :/
> Would be nicer if skb_iif would be netdev poiter. Not sure it is doable.
> 
It may be easier (and faster) to loop through all rocker ports and try to find
one with the same ifindex. Then the dev_check call would not be necessary.

If the rocker switch can be attached to multiple bridges, it may also be
necessary to check if the bridge group is the same for both ports.

Guenter

> 
> >+               if (in_dev && rocker_port_dev_check(in_dev)) {
> >+                       rcu_read_unlock();
> >+                       goto skip;
> >+               }
> >+               rcu_read_unlock();
> >+       }
> >+
> >        desc_info = rocker_desc_head_get(&rocker_port->tx_ring);
> >        if (unlikely(!desc_info)) {
> >                if (net_ratelimit())
> >@@ -3951,7 +3964,7 @@ static netdev_tx_t rocker_port_xmit(struct
> >sk_buff *skb, struct net_device *dev)
> >
> >        frags = rocker_tlv_nest_start(desc_info, ROCKER_TLV_TX_FRAGS);
> >        if (!frags)
> >-               goto out;
> >+               goto drop;
> >        err = rocker_tx_desc_frag_map_put(rocker_port, desc_info,
> >                                          skb->data, skb_headlen(skb));
> >        if (err)
> >@@ -3983,9 +3996,10 @@ unmap_frags:
> >        rocker_tx_desc_frags_unmap(rocker_port, desc_info);
> > nest_cancel:
> >        rocker_tlv_nest_cancel(desc_info, frags);
> >-out:
> >-       dev_kfree_skb(skb);
> >+drop:
> >        dev->stats.tx_dropped++;
> >+skip:
> >+       dev_kfree_skb(skb);
