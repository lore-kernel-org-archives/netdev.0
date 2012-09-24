From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [PATCHv3 net-next 3/3] vxlan: virtual extensible lan
Date: Mon, 24 Sep 2012 13:27:53 -0700
Message-ID: <20120924132753.04c20647@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<1348515547.26828.1538.camel@edumazet-glaptop>
	<20120924124657.4541c186@nehalam.linuxnetplumber.net>
	<1348516500.26828.1570.camel@edumazet-glaptop>
	<20120924130239.18767146@nehalam.linuxnetplumber.net>
	<5060C189.8090803@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	David Miller <davem@davemloft.net>,
	Chris Wright <chrisw@redhat.com>, netdev@vger.kernel.org
To: John Fastabend <john.r.fastabend@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59262 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932133Ab2IXU2Y (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 24 Sep 2012 16:28:24 -0400
In-Reply-To: <5060C189.8090803@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 24 Sep 2012 13:24:41 -0700
John Fastabend <john.r.fastabend@intel.com> wrote:

> [...]
> 
> On 9/24/2012 1:02 PM, Stephen Hemminger wrote:
> > +
> > +/* Transmit local packets over Vxlan
> > + *
> > + * Outer IP header inherits ECN and DF from inner header.
> > + * Outer UDP destination is the VXLAN assigned port.
> > + *           source port is based on hash of flow if available
> > + *                       otherwise use a random value
> > + */
> > +static netdev_tx_t vxlan_xmit(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	struct vxlan_dev *vxlan = netdev_priv(dev);
> > +	struct rtable *rt;
> > +	const struct ethhdr *eth;
> > +	const struct iphdr *old_iph;
> > +	struct iphdr *iph;
> > +	struct vxlanhdr *vxh;
> > +	struct udphdr *uh;
> > +	struct flowi4 fl4;
> > +	struct vxlan_fdb *f;
> > +	unsigned int pkt_len = skb->len;
> > +	unsigned int mtu;
> > +	u32 hash;
> > +	__be32 dst;
> > +	__be16 df = 0;
> > +	__u8 tos, ttl;
> > +	int err;
> > +
> 
> [...]
> 
> > +	err = ip_local_out(skb);
> > +	if (likely(net_xmit_eval(err) == 0)) {
> > +		struct vxlan_stats *stats = this_cpu_ptr(vxlan->stats);
> > +
> > +		u64_stats_update_begin(&stats->syncp);
> > +		stats->tx_packets++;
> > +		stats->tx_bytes += pkt_len;
> 
> Should pkt_len include the outer headers?

It doesn't for GRE and related tunnels.
