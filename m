From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2] net: Require exact match for TCP socket lookups if
 dif is l3mdev
Date: Fri, 14 Oct 2016 08:33:09 +0200
Message-ID: <1476426789.5650.34.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1476420459-20966-1-git-send-email-dsa@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David Ahern <dsa@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:35936 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1756864AbcJNGeR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 14 Oct 2016 02:34:17 -0400
Received: by mail-pf0-f195.google.com with SMTP id r16so6580237pfg.3
        for <netdev@vger.kernel.org>; Thu, 13 Oct 2016 23:33:14 -0700 (PDT)
In-Reply-To: <1476420459-20966-1-git-send-email-dsa@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2016-10-13 at 21:47 -0700, David Ahern wrote:
> Currently, socket lookups for l3mdev (vrf) use cases can match a socket
> that is bound to a port but not a device (ie., a global socket). If the
> sysctl tcp_l3mdev_accept is not set this leads to ack packets going out
> based on the main table even though the packet came in from an L3 domain.
> The end result is that the connection does not establish creating
> confusion for users since the service is running and a socket shows in
> ss output. Fix by requiring an exact dif to sk_bound_dev_if match if the
> skb came through an interface enslaved to an l3mdev device and the
> tcp_l3mdev_accept is not set.
> 
> skb's through an l3mdev interface are marked by setting a flag in the
> inet{6}_skb_parm. The IPv6 variant is already set. This patch adds the
> flag for IPv4. Marking the skb avoids a device lookup on the dif.
> 
> The inet_skb_parm struct currently has a 1-byte hold following the
> flags, so the flags is expanded to u16 without increasing the size of
> the struct. This is needed to add another flag.
> 
> Fixes: 193125dbd8eb ("net: Introduce VRF device driver")
> Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
> ---
> v2
> - reordered the checks in inet_exact_dif_match per Eric's comment
> - changed the l3mdev determination from looking up the dif to using
>   a flag set on the skb which is much faster
> 
>  drivers/net/vrf.c           |  2 ++
>  include/linux/ipv6.h        | 10 ++++++++++
>  include/net/ip.h            | 13 ++++++++++++-
>  net/ipv4/inet_hashtables.c  |  7 ++++---
>  net/ipv6/inet6_hashtables.c |  7 ++++---
>  5 files changed, 32 insertions(+), 7 deletions(-)
> 
> diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
> index 85c271c70d42..820de6a9ddde 100644
> --- a/drivers/net/vrf.c
> +++ b/drivers/net/vrf.c
> @@ -956,6 +956,7 @@ static struct sk_buff *vrf_ip6_rcv(struct net_device *vrf_dev,
>  	if (skb->pkt_type == PACKET_LOOPBACK) {
>  		skb->dev = vrf_dev;
>  		skb->skb_iif = vrf_dev->ifindex;
> +		IP6CB(skb)->flags |= IP6SKB_L3SLAVE;
>  		skb->pkt_type = PACKET_HOST;
>  		goto out;
>  	}
> @@ -996,6 +997,7 @@ static struct sk_buff *vrf_ip_rcv(struct net_device *vrf_dev,
>  {
>  	skb->dev = vrf_dev;
>  	skb->skb_iif = vrf_dev->ifindex;
> +	IPCB(skb)->flags |= IPSKB_L3SLAVE;
>  
>  	/* loopback traffic; do not push through packet taps again.
>  	 * Reset pkt_type for upper layers to process skb
> diff --git a/include/linux/ipv6.h b/include/linux/ipv6.h
> index 7e9a789be5e0..dd3bb34aac8b 100644
> --- a/include/linux/ipv6.h
> +++ b/include/linux/ipv6.h
> @@ -144,6 +144,16 @@ static inline int inet6_iif(const struct sk_buff *skb)
>  	return l3_slave ? skb->skb_iif : IP6CB(skb)->iif;
>  }
>  
> +static inline bool inet6_exact_dif_match(struct net *net, struct sk_buff *skb)
> +{
> +#ifdef CONFIG_NET_L3_MASTER_DEV
> +	if (!net->ipv4.sysctl_tcp_l3mdev_accept &&
> +	    IP6CB(skb)->flags & IP6SKB_L3SLAVE)

There is a catch here.
TCP moves IP6CB() in a different location.

Reference :

971f10eca186 ("tcp: better TCP_SKB_CB layout to reduce cache line misses")


Problem is that the lookup can happen from IP early demux, before TCP
moved IP{6}CB around.

So you might need to let the caller pass IP6CB(skb)->flags (or
TCP_SKB_CB(skb)->header.h6.flags ) instead of skb since
inet6_exact_dif_match() does not know where to fetch the flags.

Same issue for IPv4.
