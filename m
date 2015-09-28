From: "John W. Linville" <linville@tuxdriver.com>
Subject: Re: [RFT] geneve: implement support for IPv6-based tunnels
Date: Mon, 28 Sep 2015 15:20:33 -0400
Message-ID: <20150928192033.GC19079@tuxdriver.com>
References: <1443119682-14236-1-git-send-email-linville@tuxdriver.com>
 <20150925140844.3e8faae2@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	Pravin B Shelar <pshelar@nicira.com>,
	Jesse Gross <jesse@nicira.com>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:33524 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751701AbbI1TaU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Sep 2015 15:30:20 -0400
Content-Disposition: inline
In-Reply-To: <20150925140844.3e8faae2@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 25, 2015 at 02:08:44PM +0200, Jiri Benc wrote:
> On Thu, 24 Sep 2015 14:34:42 -0400, John W. Linville wrote:
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +static netdev_tx_t geneve6_xmit_skb(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +	struct geneve_dev *geneve = netdev_priv(dev);
> > +	struct geneve_sock *gs = geneve->sock;
> > +	struct ip_tunnel_info *info = NULL;
> > +	struct dst_entry *dst = NULL;
> > +	struct flowi6 fl6;
> > +	__u8 ttl;
> > +	__be16 sport;
> > +	bool udp_csum;
> > +	int err;
> > +	bool xnet = !net_eq(geneve->net, dev_net(geneve->dev));
> > +
> > +	if (geneve->collect_md) {
> > +		info = skb_tunnel_info(skb);
> > +		if (unlikely(info && info->mode != IP_TUNNEL_INFO_TX)) {
> > +			netdev_dbg(dev, "no tunnel metadata\n");
> > +			goto tx_error;
> > +		}
> > +	}
> 
> You may get IPv4 tunnel info here. Either a check whether it's really
> IPv6 is needed or, better, decide whether to use IPv4 or IPv6 for xmit
> based on the tunnel info. See below.
> 
> > +static netdev_tx_t geneve_xmit(struct sk_buff *skb, struct net_device *dev)
> > +{
> > +#if IS_ENABLED(CONFIG_IPV6)
> > +	struct geneve_dev *geneve = netdev_priv(dev);
> > +
> > +	if (geneve->remote.sa.sa_family == AF_INET6)
> > +		return geneve6_xmit_skb(skb, dev);
> > +#endif
> > +	return geneve_xmit_skb(skb, dev);
> > +}
> 
> For metadata based tunnels, there should be no requirement for the
> remote to be specified. As the consequence, you cannot decide based on
> the remote type.

Sure, that makes sense.  I'm testing something now...

> To be really useful, geneve should open both IPv4 and IPv6 socket when
> it's metadata based. Take a look at my recent patchset that does this
> for vxlan: http://thread.gmane.org/gmane.linux.network/379282

OK, that seems simple enough.  So we should just assume that a metadata
tunnel could do either protocol at any time?  Or are there more rules
than that?

John
-- 
John W. Linville		Someday the world will need a hero, and you
linville@tuxdriver.com			might be all we have.  Be ready.
