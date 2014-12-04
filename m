From: Julian Anastasov <ja@ssi.bg>
Subject: Re: 3.12.33 - BUG xfrm_selector_match+0x25/0x2f6
Date: Fri, 5 Dec 2014 01:15:51 +0200 (EET)
Message-ID: <alpine.LFD.2.11.1412042338370.4841@ja.home.ssi.bg>
References: <547F2462.6040405@smart-weblications.de> <20141204075627.GE6390@secunet.com>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: Smart Weblications GmbH - Florian Wiessner
	<f.wiessner@smart-weblications.de>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>, stable@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20141204075627.GE6390@secunet.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 4 Dec 2014, Steffen Klassert wrote:

> > [16623.096721] Call Trace:
> > [16623.096744]  <IRQ>
> > [16623.096749]  [<ffffffff81547a7c>] ? xfrm_sk_policy_lookup+0x44/0x9b
> > [16623.096802]  [<ffffffff81547ef7>] ? xfrm_lookup+0x91/0x446
> > [16623.096832]  [<ffffffff81541316>] ? ip_route_me_harder+0x150/0x1b0
> > [16623.096865]  [<ffffffffa01b6457>] ? ip_vs_route_me_harder+0x86/0x91 [ip_vs]
> > [16623.096899]  [<ffffffffa01b797a>] ? ip_vs_out+0x2d3/0x5bc [ip_vs]
> > [16623.096930]  [<ffffffff81501420>] ? ip_rcv_finish+0x2b8/0x2b8
> 
> I really wonder why the xfrm_sk_policy_lookup codepath is taken here.
> It looks like this is the processing of an inbound ipv4 packet that
> is going to be rerouted to the output path by ipvs, so this packet
> should not have socket context at all.

	In above trace looks like IPVS-NAT is used between
local client and some real server. IPVS handles this skb
at LOCAL_IN and calls ip_vs_route_me_harder(). If we have
skb->sk at LOCAL_IN, my first thought is about early demux.

	If I remember correctly, looking at commit f5a41847acc535e2
("ipvs: move ip_route_me_harder for ICMP") that introduced
this rerouting (2.6.37), it was needed because at that time TCP
used rt_src from received skb to select daddr in ip_send_reply().
As packets to server are DNAT-ed and packets to client are
SNAT-ed we used rerouting to fill rt_src with correct IP
after SNAT.

	Now when routing cache is removed in 3.6 and
tcp_v4_send_reset() is changed to provide ip_hdr(skb)->saddr
instead of rt_src it should be safe to remove this rerouting,
it is enough that ip_hdr(skb)->saddr was updated on IPVS-SNAT at
LOCAL_IN. In fact, rt_src was removed early in 3.0 with
commit 0a5ebb8000c5362 ("ipv4: Pass explicit daddr arg to 
ip_send_reply().").

	This is only to explain above stack. Not sure
if problem is related somehow to early demux but such
commits look interesting:

- commit 6b8dbcf2c44fd7a ("bridge: netfilter: orphan skb before invoking 
ip netfilter hooks")

	Also, it would be good to know which 3.x kernel between
3.13 and 3.17 fixes the problem, it will narrow the search.

Regards

--
Julian Anastasov <ja@ssi.bg>
