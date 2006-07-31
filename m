From: Stephen Hemminger <shemminger@osdl.org>
Subject: Re: [RFC] gre: transparent ethernet bridging
Date: Mon, 31 Jul 2006 09:14:23 -0700
Message-ID: <20060731091423.3327f85e@dxpl.pdx.osdl.net>
References: <44CDD631.5030008@snapgear.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.4]:35209 "EHLO smtp.osdl.org")
	by vger.kernel.org with ESMTP id S1030211AbWGaQOi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 31 Jul 2006 12:14:38 -0400
To: Philip Craig <philipc@snapgear.com>
In-Reply-To: <44CDD631.5030008@snapgear.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, 31 Jul 2006 20:06:41 +1000
Philip Craig <philipc@snapgear.com> wrote:

> This patch implements transparent ethernet bridging for gre tunnels.
> There are a few outstanding issues.

Why not use existing bridge code?

> There is no way for userspace to select the type of gre tunnel. The
> #if 0 near the top of the patch forces all gre tunnels to be bridges.
> The problem is that userspace uses an IPPROTO_ to select the type of
> tunnel, but both types of gre tunnel are IPPROTO_GRE. I can't see
> anything else in struct ip_tunnel_parm that could be used to select
> this. One approach that I've seen mentioned in the archives is to add
> a netlink interface to replace the tunnel ioctls.
> 
> Network loops are bad. See the comments at the top of ip_gre.c for
> a description of how gre tunnels handle this normally. But for gre
> bridges, we don't want to copy the ttl (it breaks routing protocols),
> and we don't want to force DF (we want to bridge 1500 byte packets).
> I couldn't think of any solution for this.
> 
> Some routers set LLC_SAP_BSPAN in the gre protocol field, and then
> give the bpdu packet without any other ethernet/llc header. This patch
> currently tries to fake the ethernet/llc header before passing the
> packet up, but it is buggy (mac addresses are wrong at least). Maybe a
> better approach is to call directly into the bridging code. I didn't try
> that at first because it isn't modular, and may break other things that
> want to see the packet.

Existing bridge code already has spanning tree.

> --- linux-2.6.x/net/ipv4/ip_gre.c	18 Jun 2006 23:30:56 -0000	1.1.1.33
> +++ linux-2.6.x/net/ipv4/ip_gre.c	31 Jul 2006 09:57:41 -0000
> @@ -30,6 +30,8 @@
>  #include <linux/igmp.h>
>  #include <linux/netfilter_ipv4.h>
>  #include <linux/if_ether.h>
> +#include <linux/etherdevice.h>
> +#include <linux/llc.h>
> 
>  #include <net/sock.h>
>  #include <net/ip.h>
> @@ -41,6 +43,8 @@
>  #include <net/dsfield.h>
>  #include <net/inet_ecn.h>
>  #include <net/xfrm.h>
> +#include <net/llc.h>
> +#include <net/llc_pdu.h>
> 
>  #ifdef CONFIG_IPV6
>  #include <net/ipv6.h>
> @@ -119,6 +123,7 @@
> 
>  static int ipgre_tunnel_init(struct net_device *dev);
>  static void ipgre_tunnel_setup(struct net_device *dev);
> +static void ipgre_ether_tunnel_setup(struct net_device *dev);
> 
>  /* Fallback tunnel: no source, no destination, no key, no options */
> 
> @@ -274,7 +279,11 @@ static struct ip_tunnel * ipgre_tunnel_l
>  			goto failed;
>  	}
> 
> +#if 0
>  	dev = alloc_netdev(sizeof(*t), name, ipgre_tunnel_setup);
> +#else
> +	dev = alloc_netdev(sizeof(*t), name, ipgre_ether_tunnel_setup);
> +#endif

"Do, or do not there is no try"


> +__be16 ipgre_type_trans(struct sk_buff *skb, int offset)
> +{
> +	u8     *h = skb->data;
> +	__be16 flags = *(__be16*)h;
> +	__be16 proto = *(__be16*)(h + 2);
> +
> +	/* WCCP version 1 and 2 protocol decoding.
> +	 * - Change protocol to IP
> +	 * - When dealing with WCCPv2, Skip extra 4 bytes in GRE header
> +	 */
> +	if (flags == 0 &&
> +	    proto == __constant_htons(ETH_P_WCCP)) {
> +		proto = __constant_htons(ETH_P_IP);
> +		if ((*(h + offset) & 0xF0) != 0x40)
> +			offset += 4;
> +	}

Don't use __constant_htons() except in initializers and switch cases
(where gcc is too stupid to optimize the macro).

-- 
Stephen Hemminger <shemminger@osdl.org>
"And in the Packet there writ down that doome"
