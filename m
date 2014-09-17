From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCHv5 net-next 3/3] sunvnet: generate ICMP PTMUD messages
 for smaller port MTUs
Date: Thu, 18 Sep 2014 00:13:32 +0300
Message-ID: <5419F97C.1080105@cogentembedded.com>
References: <5419F3E5.4050708@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: David L Stevens <david.stevens@oracle.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f181.google.com ([209.85.212.181]:48402 "EHLO
	mail-wi0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756625AbaIQVOT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Sep 2014 17:14:19 -0400
Received: by mail-wi0-f181.google.com with SMTP id bs8so107799wib.2
        for <netdev@vger.kernel.org>; Wed, 17 Sep 2014 14:14:18 -0700 (PDT)
In-Reply-To: <5419F3E5.4050708@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello.

On 9/17/2014 11:49 PM, David L Stevens wrote:

> This patch sends ICMP and ICMPv6 messages for Path MTU Discovery when a remote
> port MTU is smaller than the device MTU. This allows mixing newer VIO protocol
> devices that support MTU negotiation with older devices that do not on the
> same vswitch. It also allows Linux-Linux LDOMs to use 64K-1 data packets even
> though Solaris vswitch is limited to <16K MTU.

> Signed-off-by: David L Stevens <david.stevens@oracle.com>
> ---
>   drivers/net/ethernet/sun/sunvnet.c |   37 +++++++++++++++++++++++++++++++++++-
>   1 files changed, 36 insertions(+), 1 deletions(-)

> diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
> index 5e64e60..3c4ee18 100644
> --- a/drivers/net/ethernet/sun/sunvnet.c
> +++ b/drivers/net/ethernet/sun/sunvnet.c
[...]
> @@ -791,8 +798,36 @@ static int vnet_start_xmit(struct sk_buff *skb, struct net_device *dev)
>   	if (unlikely(!port))
>   		goto out_dropped;
>
> -	if (skb->len > port->rmtu)
> +	if (skb->len > port->rmtu) {
> +		unsigned long localmtu = port->rmtu - ETH_HLEN;
> +
> +		if (vio_version_after_eq(&port->vio, 1, 3))
> +			localmtu -= VLAN_HLEN;
> +
> +		if (skb->protocol == htons(ETH_P_IP)) {
> +			struct flowi4 fl4;
> +			struct rtable *rt = NULL;
> +
> +			memset(&fl4, 0, sizeof(fl4));
> +			fl4.flowi4_oif = dev->ifindex;
> +			fl4.flowi4_tos = RT_TOS(ip_hdr(skb)->tos);
> +			fl4.daddr = ip_hdr(skb)->daddr;
> +			fl4.saddr = ip_hdr(skb)->saddr;
> +
> +			rt = ip_route_output_key(dev_net(dev), &fl4);
> +			if (!IS_ERR(rt)) {
> +				skb_dst_set(skb, &rt->dst);
> +				icmp_send(skb, ICMP_DEST_UNREACH,
> +					  ICMP_FRAG_NEEDED,
> +					  htonl(localmtu));
> +			}
> +		}
> +#if IS_ENABLED(CONFIG_IPV6)

    This #if could be avoided by extending the *if* statement below, no?

> +		else if (skb->protocol == htons(ETH_P_IPV6))
> +			icmpv6_send(skb, ICMPV6_PKT_TOOBIG, 0, localmtu);
> +#endif
>   		goto out_dropped;
> +	}

WBR, Sergei
