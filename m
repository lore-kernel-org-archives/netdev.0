From: Alexei Starovoitov <alexei.starovoitov@gmail.com>
Subject: Re: [PATCH net-next v2] route: allow to route in a peer netns via
 lwt framework
Date: Fri, 24 Jul 2015 09:27:25 -0700
Message-ID: <20150724162723.GA32909@Alexeis-MBP.westell.com>
References: <55B1077F.1090501@6wind.com>
 <1437747419-8442-1-git-send-email-nicolas.dichtel@6wind.com>
 <1437752397.20182.8.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Nicolas Dichtel <nicolas.dichtel@6wind.com>, davem@davemloft.net,
	netdev@vger.kernel.org, roopa@cumulusnetworks.com, tgraf@suug.ch
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f43.google.com ([209.85.220.43]:33323 "EHLO
	mail-pa0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752057AbbGXQ11 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 24 Jul 2015 12:27:27 -0400
Received: by padck2 with SMTP id ck2so16779364pad.0
        for <netdev@vger.kernel.org>; Fri, 24 Jul 2015 09:27:26 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <1437752397.20182.8.camel@edumazet-glaptop2.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jul 24, 2015 at 05:39:57PM +0200, Eric Dumazet wrote:
> 
> On Fri, 2015-07-24 at 16:16 +0200, Nicolas Dichtel wrote:
> > This patch takes advantage of the newly added lwtunnel framework to
> > allow the user to set routes that point to a peer netns.
> > 
> > Packets are injected to the peer netns via the loopback device. It works
> > only when the output device is 'lo'.
> > 
> > Example:
> > ip route add 40.1.1.1/32 encap netns nsid 5 via dev lo
> > 
> 
> Is this feature so badly wanted to add complexity on lo device ?
...
> >  static netdev_tx_t loopback_xmit(struct sk_buff *skb,
> >  				 struct net_device *dev)
...
> > +	if (nsid != NETNSA_NSID_NOT_ASSIGNED) {
> > +		peernet = get_net_ns_by_id(dev_net(dev), nsid);
> > +		if (!peernet) {
> > +			kfree_skb(skb);
> > +			goto end;
> > +		}
> > +
> > +		/* it's OK to use per_cpu_ptr() because BHs are off */
> > +		lb_stats = this_cpu_ptr(peernet->loopback_dev->lstats);
> > +		ret = dev_forward_skb(peernet->loopback_dev, skb);

have the same concern as Eric.
Using loopback for this looks wrong.
netns suppose to look like host, but I cannot imagine a host
without NICs seeing packets on loopback from another world.
Then how the opposite direction suppose to work?
netns will setup a route to send packets to loopback of the host?!
The idea of using routing to forward packets to namespaces is great,
but I think we need something else instead of loopback.
