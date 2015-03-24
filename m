From: Guenter Roeck <linux@roeck-us.net>
Subject: Re: [PATCH net-next RFC v2] switchdev: bridge: drop hardware
 forwarded packets
Date: Tue, 24 Mar 2015 10:58:25 -0700
Message-ID: <20150324175825.GA1465@roeck-us.net>
References: <20150323002215.GA6074@roeck-us.net>
 <550F6D7D.7030403@gmail.com>
 <550F8102.7040701@roeck-us.net>
 <550F8600.2020300@gmail.com>
 <550F8987.5070600@roeck-us.net>
 <5510498D.5010001@cumulusnetworks.com>
 <CAE4R7bCcMtrKmiGaLqVMfERQxYZW3WD1vF2rts9+CE7ZZ0_BVQ@mail.gmail.com>
 <20150324142921.GA2026@nanopsycho.orion>
 <20150324160126.GA17104@roeck-us.net>
 <5511A29F.5010006@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jiri@resnulli.us>, Scott Feldman <sfeldma@gmail.com>,
	John Fastabend <john.fastabend@gmail.com>,
	Andrew Lunn <andrew@lunn.ch>,
	David Miller <davem@davemloft.net>,
	"Arad, Ronen" <ronen.arad@intel.com>,
	Netdev <netdev@vger.kernel.org>
To: roopa <roopa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from bh-25.webhostbox.net ([208.91.199.152]:43286 "EHLO
	bh-25.webhostbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753410AbbCXR6o (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Mar 2015 13:58:44 -0400
Received: from mailnull by bh-25.webhostbox.net with sa-checked (Exim 4.82)
	(envelope-from <linux@roeck-us.net>)
	id 1YaT6B-0015Q2-6K
	for netdev@vger.kernel.org; Tue, 24 Mar 2015 17:58:43 +0000
Content-Disposition: inline
In-Reply-To: <5511A29F.5010006@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Mar 24, 2015 at 10:45:03AM -0700, roopa wrote:
> On 3/24/15, 9:01 AM, Guenter Roeck wrote:
> >On Tue, Mar 24, 2015 at 03:29:21PM +0100, Jiri Pirko wrote:
> >>>diff --git a/drivers/net/ethernet/rocker/rocker.c
> >>>b/drivers/net/ethernet/rocker/rocker.c
> >>>index aab962c..0f7217f7 100644
> >>>--- a/drivers/net/ethernet/rocker/rocker.c
> >>>+++ b/drivers/net/ethernet/rocker/rocker.c
> >>>@@ -3931,15 +3931,28 @@ unmap_frag:
> >>>        return -EMSGSIZE;
> >>>}
> >>>
> >>>+static bool rocker_port_dev_check(struct net_device *dev);
> >>>+
> >>>static netdev_tx_t rocker_port_xmit(struct sk_buff *skb, struct
> >>>net_device *dev)
> >>>{
> >>>        struct rocker_port *rocker_port = netdev_priv(dev);
> >>>        struct rocker *rocker = rocker_port->rocker;
> >>>        struct rocker_desc_info *desc_info;
> >>>        struct rocker_tlv *frags;
> >>>+       struct net_device *in_dev;
> >>>        int i;
> >>>        int err;
> >>>
> >>>+       if (rocker_port_is_bridged(rocker_port)) {
> >>>+               rcu_read_lock();
> >>>+               in_dev = dev_get_by_index_rcu(dev_net(dev), skb->skb_iif);
> >>Hmm, you iterate over all ports for every xmit call :/
> >>Would be nicer if skb_iif would be netdev poiter. Not sure it is doable.
> >>
> >It may be easier (and faster) to loop through all rocker ports and try to find
> >one with the same ifindex. Then the dev_check call would not be necessary.
> >
> This is still overhead for every packet on the switches we support. The
> number of ports can go close to 128
> (40G ports can be broken into 4x10G ports).
> 
Agreed. Given that, and since dev_get_by_index_rcu uses a hash to find the
device pointer, it may actually be (much) faster (and the above "iterate
over all ports" is a bit misleading).

I tested the above approach with DSA and a Marvell switch chip. It works,
but I am a bit concerned about the per-packet overhead, especially
in larger networks. I would prefer if there would be a means to 'catch'
duplicate packets earlier - before they are even created, if that is
possible.

Guenter
