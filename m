From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] net: Fix tentative IPv6 address due to DAD looping back
Date: Thu, 11 Apr 2013 13:55:44 +0200
Message-ID: <20130411115544.GA19782@order.stressinduktion.org>
References: <027526AF93736D4380632CD4F3B42B8002FE9D@MX101CL02.corp.emc.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: "davem@davemloft.net" <davem@davemloft.net>,
	"kuznet@ms2.inr.ac.ru" <kuznet@ms2.inr.ac.ru>,
	"jmorris@namei.org" <jmorris@namei.org>,
	"yoshfuji@linux-ipv6.org" <yoshfuji@linux-ipv6.org>,
	"kaber@trash.net" <kaber@trash.net>,
	"Sun, Yinglin" <yinglin.sun@emc.com>,
	"Prithviraj, Lakshmanan" <lakshmanan.prithviraj@emc.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: "Meng, Jilin" <Jilin.Meng@emc.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:37669 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752087Ab3DKLzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 07:55:46 -0400
Content-Disposition: inline
In-Reply-To: <027526AF93736D4380632CD4F3B42B8002FE9D@MX101CL02.corp.emc.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 03:06:23AM +0000, Meng, Jilin wrote:
> we should ignore the looped-back IPv6 DAD packet to avoid configuration failure.
> This occurs when a bonding interface with roundrobin mode is being configured an IPv6 address while the switch side isn't configured bonding/channel yet.

I am very uncomfortable with this change in ndisc layer. I would
prefer DAD kicking in and disabling ipv6 on that interface in such a
situation. The likelihood that an interface with the same mac address
has the same ll ipv6 address is very high and DAD must guard that.

> Signed-off-by: Jilin Meng <jilin.meng@emc.com>
> Signed-off-by: Yinglin Sun <yinglin.sun@emc.com>
> Signed-off-by: Lakshmanan Prithviraj <lakshmanan.prithviraj@emc.com>
> ---
> --- linux/net/ipv6/ndisc.c.orig	2013-03-12 17:16:18.000000000 +0800
> +++ linux/net/ipv6/ndisc.c	2013-04-11 09:00:45.000000000 +0800
> @@ -71,6 +71,7 @@
>  
>  #include <linux/netfilter.h>
>  #include <linux/netfilter_ipv6.h>
> +#include <linux/etherdevice.h>
>  
>  /* Set to 3 to get tracing... */
>  #define ND_DEBUG 1
> @@ -757,6 +758,19 @@ static void ndisc_recv_ns(struct sk_buff
>  
>  		if (ifp->flags & (IFA_F_TENTATIVE|IFA_F_OPTIMISTIC)) {
>  			if (dad) {
> +				if (dev->type == ARPHRD_ETHER) {
> +					const unsigned char *sadr;
> +					sadr = skb_mac_header(skb);
> +					if (ether_addr_equal_64bits(sadr + 6, dev->dev_addr))

Minor improvment:

struct ethhdr *eth = eth_hdr(skb);
if (ether_addr_equal_64bits(eth->h_source, dev->dev_addr))
