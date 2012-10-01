From: Stephen Hemminger <shemminger@vyatta.com>
Subject: Re: [RFC] gre: conform to RFC6040 ECN progogation
Date: Mon, 1 Oct 2012 08:56:06 -0700
Message-ID: <20121001085606.6f828f7d@nehalam.linuxnetplumber.net>
References: <20120924184304.727711327@vyatta.com>
	<20120924185050.162920909@vyatta.com>
	<20120924205822.GI26494@x200.localdomain>
	<20120924141133.3c97e9de@nehalam.linuxnetplumber.net>
	<20120924212226.GJ26494@x200.localdomain>
	<20120924144457.0c76bce2@nehalam.linuxnetplumber.net>
	<1349106919.2577.9.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Chris Wright <chrisw@redhat.com>,
	David Miller <davem@davemloft.net>, <netdev@vger.kernel.org>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:59893 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752228Ab2JAP4m (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 1 Oct 2012 11:56:42 -0400
In-Reply-To: <1349106919.2577.9.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 1 Oct 2012 16:55:19 +0100
Ben Hutchings <bhutchings@solarflare.com> wrote:

> On Mon, 2012-09-24 at 14:44 -0700, Stephen Hemminger wrote:
> [...]
> > --- a/net/ipv4/ip_gre.c	2012-09-21 08:45:55.948772761 -0700
> > +++ b/net/ipv4/ip_gre.c	2012-09-24 14:35:54.666185603 -0700
> [...]
> > @@ -703,17 +704,18 @@ static int ipgre_rcv(struct sk_buff *skb
> >  			skb_postpull_rcsum(skb, eth_hdr(skb), ETH_HLEN);
> >  		}
> >  
> > +		__skb_tunnel_rx(skb, tunnel->dev);
> > +
> > +		skb_reset_network_header(skb);
> > +		if (!ipgre_ecn_decapsulate(iph, skb))
> > +			goto drop;
> > +
> >  		tstats = this_cpu_ptr(tunnel->dev->tstats);
> >  		u64_stats_update_begin(&tstats->syncp);
> >  		tstats->rx_packets++;
> >  		tstats->rx_bytes += skb->len;
> >  		u64_stats_update_end(&tstats->syncp);
> 
> I don't know why you're moving this code above the stats update;
> rx_packets/rx_bytes should include dropped packets.
> 
> Ben.
> 
> > -		__skb_tunnel_rx(skb, tunnel->dev);
> > -
> > -		skb_reset_network_header(skb);
> > -		ipgre_ecn_decapsulate(iph, skb);
> > -
> >  		netif_rx(skb);
> >  
> >  		rcu_read_unlock();
> 

Is that true? I thought they were accounted for by rx_dropped.
