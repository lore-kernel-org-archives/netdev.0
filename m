From: Stefan Richter <stefanr@s5r6.in-berlin.de>
Subject: Re: [RFC PATCH 5/6] firewire net: IPv6 support (RFC3146).
Date: Sat, 12 Jan 2013 16:22:24 +0100
Message-ID: <20130112162224.10e2aa44@stein>
References: <50F17171.3050105@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Stephan Gatzka <stephan.gatzka@gmail.com>, netdev@vger.kernel.org,
	linux1394-devel@lists.sourceforge.net
To: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from einhorn.in-berlin.de ([192.109.42.8]:60164 "EHLO
	einhorn.in-berlin.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752009Ab3ALPWn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 12 Jan 2013 10:22:43 -0500
In-Reply-To: <50F17171.3050105@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Jan 12 YOSHIFUJI Hideaki wrote:
> Send packets for IPv6 multicast via GASP.
> 
> CC: Stephan Gatzka <stephan.gatzka@gmail.com>
> CC: Stefan Richter <stefanr@s5r6.in-berlin.de>
> Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
> ---
>  drivers/firewire/Kconfig |    8 ++++++++
>  drivers/firewire/net.c   |   13 ++++++++++---
>  2 files changed, 18 insertions(+), 3 deletions(-)
> 
> diff --git a/drivers/firewire/Kconfig b/drivers/firewire/Kconfig
> index 7224533..2e3018b 100644
> --- a/drivers/firewire/Kconfig
> +++ b/drivers/firewire/Kconfig
> @@ -51,9 +51,17 @@ config FIREWIRE_NET
>  	  other implementations of RFC 2734 as found on several operating
>  	  systems.  Multicast support is currently limited.
>  
> +	  Optional IPv6 support is available if you say Y here.
> +

This is a bit premature.  At least one thing which is still missing (also
missing in Stephan's patch from previous week) is the RFC 3146 clause 5
Configuration ROM entry.

>  	  To compile this driver as a module, say M here:  The module will be
>  	  called firewire-net.
>  
> +config FIREWIRE_NET_IPV6
> +	bool "IPv6 networking over 1394"
> +	depends on FIREWIRE_NET=y
> +	help
> +	  This enabless IPv6 over IEEE 1394, based on RFC 3146.
> +

I would rather like this to be like an invisible option which is
automatically on if IPV6=y || (IPV6=m && FIREWIRE_NET=m), and off
otherwise.

Or, as alluded to in my other post, it is going to be written such that

  - if IPV6=n, FIREWIRE_NET can be n, y, or m.  RFC 3146 support won't be
    built in in any case.

  - If IPV6=y, FIREWIRE_NET can be n, y, or m.  RFC 3146 support will be
    built in.

  - If IPV6=m, FIREWIRE_NET can be only n or m.  RFC 3146 support will be
    built in in the latter case.


>  config FIREWIRE_NOSY
>  	tristate "Nosy - a FireWire traffic sniffer for PCILynx cards"
>  	depends on PCI
> diff --git a/drivers/firewire/net.c b/drivers/firewire/net.c
> index 66c4f1c..a21d2f9 100644
> --- a/drivers/firewire/net.c
> +++ b/drivers/firewire/net.c
> @@ -27,6 +27,8 @@
>  #include <linux/spinlock.h>
>  
>  #include <asm/unaligned.h>
> +#include <linux/ipv6.h>
> +#include <net/addrconf.h>
>  #include <net/arp.h>
>  #include <net/firewire.h>
>  
> @@ -1329,13 +1331,18 @@ static netdev_tx_t fwnet_tx(struct sk_buff *skb, struct net_device *net)
>  	dg_size = skb->len;
>  
>  	/*
> -	 * Set the transmission type for the packet.  ARP packets and IP
> -	 * broadcast packets are sent via GASP.
> +	 * Set the transmission type for the packet.  ARP packets, IPv4
> +	 * broadcast packets, IPv6 multicast packets are sent via GASP.
>  	 */
>  	if (memcmp(hdr_buf.h_dest, net->broadcast, FWNET_ALEN) == 0
>  	    || proto == htons(ETH_P_ARP)
>  	    || (proto == htons(ETH_P_IP)
> -		&& IN_MULTICAST(ntohl(ip_hdr(skb)->daddr)))) {
> +		&& IN_MULTICAST(ntohl(ip_hdr(skb)->daddr)))
> +#if defined(CONFIG_FIREWIRE_NET_IPV6)
> +	    || (proto == htons(ETH_P_IPV6)
> +		&& ipv6_addr_is_multicast(&ipv6_hdr(skb)->daddr))
> +#endif
> +	   ) {
>  		max_payload        = dev->broadcast_xmt_max_payload;
>  		datagram_label_ptr = &dev->broadcast_xmt_datagramlabel;
>  

This hunk is fine with me.
-- 
Stefan Richter
-=====-===-= ---= -==--
http://arcgraph.de/sr/
