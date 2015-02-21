From: Sabrina Dubroca <sd@queasysnail.net>
Subject: Re: [PATCH] ipv6: address issue in __ip6_append_data
Date: Sat, 21 Feb 2015 19:33:59 +0100
Message-ID: <20150221183359.GB16874@kria>
References: <1423841459-21880-1-git-send-email-madalin.bucur@freescale.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: netdev@vger.kernel.org, vyasevich@gmail.com, davem@davemloft.net
To: Madalin Bucur <madalin.bucur@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp3-g21.free.fr ([212.27.42.3]:51801 "EHLO smtp3-g21.free.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751671AbbBUSeF (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 21 Feb 2015 13:34:05 -0500
Content-Disposition: inline
In-Reply-To: <1423841459-21880-1-git-send-email-madalin.bucur@freescale.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2015-02-13, 17:30:59 +0200, Madalin Bucur wrote:
> Hello,
> 
> I think I've found a problem that allows generic IPv6 traffic to be
> sent by the stack with CHECKSUM_PARTIAL to a netdevice that declares
> NETIF_F_IPV6_CSUM. The NETIF_F_IPV6_CSUM flag is based on the
> NETIF_F_IPV6_CSUM_BIT that is described as referring only to TCP and
> UDP but in my test ICMPv6 frames with CHECKSUM_PARTIAL are seen:

This should be fixed by:

    bf250a1fa769 ("ipv6: Partial checksum only UDP packets")

Have you tested it?


> NETIF_F_IPV6_CSUM_BIT,          /* Can checksum TCP/UDP over IPV6 */
> 
> I've traced the issue to a recent commit that includes this check:
> 
> 	rt->dst.dev->features & NETIF_F_V6_CSUM
> 
> The problem with this is that NETIF_F_V6_CSUM is more than one bit:
> 
> #define NETIF_F_V6_CSUM         (NETIF_F_GEN_CSUM | NETIF_F_IPV6_CSUM)
> 
> Thus the above check should be either:
> 
> 	(rt->dst.dev->features & NETIF_F_V6_CSUM) == NETIF_F_V6_CSUM

I think this disables HW checksumming that Vlad's patch enabled.  As
Vlad pointed out in another similar thread [1], the two bits are
mutually exclusive, so you can't have

    (dev->features & NETIF_F_V6_CSUM) == NETIF_F_V6_CSUM

[1] http://www.spinics.net/lists/netdev/msg316341.html


> or probably should use NETIF_F_HW_CSUM only:
> 
> 	rt->dst.dev->features & NETIF_F_HW_CSUM

Maybe.  But I just tried this, and it doesn't work with qemu's e1000
emulation (could be a driver/qemu problem, I can't check with other
devices).


Thanks,
-- 
Sabrina
