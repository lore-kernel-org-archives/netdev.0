From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Fri, 5 Dec 2014 11:53:31 +0100
Message-ID: <20141205105331.GI6390@secunet.com>
References: <547F2462.6040405@smart-weblications.de>
 <20141204075627.GE6390@secunet.com>
 <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>, <netdev@vger.kernel.org>,
	LKML <linux-kernel@vger.kernel.org>, <stable@vger.kernel.org>
To: Julian Anastasov <ja@ssi.bg>
Return-path: <stable-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg>
Sender: stable-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, Dec 05, 2014 at 01:15:51AM +0200, Julian Anastasov wrote:
> 
> 	Hello,
> 
> On Thu, 4 Dec 2014, Steffen Klassert wrote:
> 
> > > [16623.096721] Call Trace:
> > > [16623.096744]  <IRQ>
> > > [16623.096749]  [<ffffffff81547a7c>] ? xfrm_sk_policy_lookup+0x44/0x9b
> > > [16623.096802]  [<ffffffff81547ef7>] ? xfrm_lookup+0x91/0x446
> > > [16623.096832]  [<ffffffff81541316>] ? ip_route_me_harder+0x150/0x1b0
> > > [16623.096865]  [<ffffffffa01b6457>] ? ip_vs_route_me_harder+0x86/0x91 [ip_vs]
> > > [16623.096899]  [<ffffffffa01b797a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs]
> > > [16623.096930]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
> > 
> > I really wonder why the xfrm_sk_policy_lookup codepath is taken here.
> > It looks like this is the processing of an inbound ipv4 packet that
> > is going to be rerouted to the output path by ipvs, so this packet
> > should not have socket context at all.
> 
> 	In above trace looks like IPVS-NAT is used between
> local client and some real server. IPVS handles this skb
> at LOCAL_IN and calls ip_vs_route_me_harder(). If we have
> skb->sk at LOCAL_IN, my first thought is about early demux.

Yes, that's possible. Can be checked by disabling early demux.
echo 0 > /proc/sys/net/ipv4/ip_early_demux

If I look what it tries to dereference when the crash happens,
this does not look like a pointer. But sk->sk_policy[dir]
should be either a pointer to kernel memory or NULL. So I
think that the skb->sk pointer is already bogus.
