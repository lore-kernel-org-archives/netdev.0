From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: ip_forward_use_pmtu and forwarding to xfrm'ed gre
Date: Wed, 08 Jul 2015 17:52:32 +0200
Message-ID: <1436370752.3846.36.camel@stressinduktion.org>
References: <20150708163032.5b5df2ec@vostro>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
To: Timo Teras <timo.teras@iki.fi>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out5-smtp.messagingengine.com ([66.111.4.29]:38251 "EHLO
	out5-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S932855AbbGHPwj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2015 11:52:39 -0400
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 9669520DC2
	for <netdev@vger.kernel.org>; Wed,  8 Jul 2015 11:52:37 -0400 (EDT)
In-Reply-To: <20150708163032.5b5df2ec@vostro>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

On Wed, 2015-07-08 at 16:30 +0300, Timo Teras wrote:
> Hi,
> 
> It seems ip_forward_use_pmtu commit log says:
>     Tunnel and ipsec output paths clear IPCB again, thus 
> IPSKB_FORWARDED
>     won't be set and further fragmentation logic will use the path mtu
>     to determine the fragmentation size. They also recheck packet size
>     with help of path mtu discovery and report appropriate errors.
> 
> But this does not seem to be true in all paths. For example, I'm
> forwarding from ethX -> greX (with gre having ttl 64; and thus
> setting DF on tunnel always) and then gre output is finally IPsec
> encrypted. But fragmentation does not work. Setting 
> ip_forward_use_pmtu
> makes it work again. tcpdump says the packet is fragmented based on 
> the
> greX device mtu, not the path mtu in this case.
> 
> This probably is due to the way how the xfrm+gre work together. On
> first packet, the gre tunnel driver updates pmtu for the inner flow,
> which is expected to be honored always. And if the 'ttl' value is set
> for gre tunnel, no re-fragmentation is allowed as the inner flow
> should know better. This does how the side effect that if the very
> first packet is large, it'll be dropped to 'learn' the pmtu. 
> 
> It's probably not possible to detect this kind of target easily, as 
> the
> xfrm can be applied or not even on per inner target IP basis (as then
> tunnel destination IP can be dynamic for nbma tunnels).

I am currently not sure if we actually have resolved the xfrm path at
the time we enter ip_forward, I actually thought we do. In this case we
should be able to use skb_dst->dst->path->header_len and substract it
before using it to fragment the packets. I hope it is so easy... :)

I would actually avoid telling anyone to enable using the path mtu
information in forwarding ever again.


> So I wonder if ip_gre driver can workaround this somehow, by e.g.
> refragmenting if necessary. Or if we just should update the sysctl's
> help text to say that this another scenario where it needs to be
> turned on.

If above idea does not work, we could simply add an option to gre driver
to set skb->ignore_df, but I don't like that much.

Bye,
Hannes
