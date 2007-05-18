From: Julian Anastasov <ja@ssi.bg>
Subject: Re: oops in net/ipv4/icmp.c:icmp_send() with icmp_errors_use_inbound_ifaddr
 (fwd)
Date: Fri, 18 May 2007 03:57:53 +0300 (EEST)
Message-ID: <Pine.LNX.4.58.0705180244420.3137@u.domain.uli>
References: <Line.LNX.4.64.0705141430120.8521@d.namei> <4648AE85.6020608@trash.net>
 <4648B656.6030800@trash.net> <464C884D.4010100@trash.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: "David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	James Morris <jmorris@namei.org>,
	Curtis Doty <Curtis@GreenKey.net>
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([217.79.71.194]:3826 "EHLO u.domain.uli"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755470AbXERA6F (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 17 May 2007 20:58:05 -0400
In-Reply-To: <464C884D.4010100@trash.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


	Hello,

On Thu, 17 May 2007, Patrick McHardy wrote:

> > saddr = iph->daddr;
> > if (!(rt->rt_flags & RTCF_LOCAL)) {
> >         if (sysctl_icmp_errors_use_inbound_ifaddr)
> > 
> > 
> >                 saddr = inet_select_addr(skb_in->dev, 0, RT_SCOPE_LINK);
> >         else
> >                 saddr = 0;
> > }

	While we are fixing this problem, is adding more logic
for the sysctl_icmp_errors_use_inbound_ifaddr case still working for its
users (untested code follows) ?:

	if (!(rt->rt_flags & RTCF_LOCAL)) {
		if (sysctl_icmp_errors_use_inbound_ifaddr && rt->fl.iif)
			saddr = inet_select_addr(skb_in->dev, iph->saddr,
				(rt->rt_flags & RTCF_DIRECTSRC) ?
				RT_SCOPE_LINK : RT_SCOPE_UNIVERSE);
		else
			saddr = 0;
	}

	Because this inet_select_addr call is too risky, it uses blindly
the first address (usually scope link). So,

- assume sysctl_icmp_errors_use_inbound_ifaddr is for packets from network,
work for input routes only (replaces check for skb_in->dev)

- prefer local address from the same subnet as sender (iph->saddr) or
it should be the target: icmp_param.replyopts.srr ? 
icmp_param.replyopts.faddr : iph->saddr as used below? Useful when input 
interface has many subnets.

- don't expose link addresses to sender if they are not known to it, sender
should be onlink to see them. If sender is not onlink and all our addresses
on input interface are scope link then we can not expose such addresses,
we risk to send from private address, for example, when our uplink
interface has only private addresses to talk with gateway and our
public IP is on internal interface where we are router for public subnet.
If we can not select address the routing still has chance to do it 
(from prefsrc or another interface).

	Also, any problems if icmp_send happens after SNAT changes
source? Or that is not possible? Because we think iph->saddr is
sender (target for our ICMP).

Regards

--
Julian Anastasov <ja@ssi.bg>
