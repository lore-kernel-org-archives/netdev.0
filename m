From: Jason Wang <jasowang@redhat.com>
Subject: Re: [PATCH net] gso: do GSO for local skb with size bigger than MTU
Date: Fri, 28 Nov 2014 07:10:08 +0008
Message-ID: <1417158128.3268.2@smtp.corp.redhat.com>
References: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Cc: netdev@vger.kernel.org, davem@davemloft.net, fw@strlen.de,
	Fan Du <fan.du@intel.com>
To: Fan Du <fan.du@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35990 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750870AbaK1HCZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 28 Nov 2014 02:02:25 -0500
In-Reply-To: <1417156385-18276-1-git-send-email-fan.du@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



On Fri, Nov 28, 2014 at 2:33 PM, Fan Du <fan.du@intel.com> wrote:
> Test scenario: two KVM guests sitting in different
> hosts communicate to each other with a vxlan tunnel.
> 
> All interface MTU is default 1500 Bytes, from guest point
> of view, its skb gso_size could be as bigger as 1448Bytes,
> however after guest skb goes through vxlan encapuslation,
> individual segments length of a gso packet could exceed
> physical NIC MTU 1500, which will be lost at recevier side.
> 
> So it's possible in virtualized environment, locally created
> skb len after encapslation could be bigger than underlayer
> MTU. In such case, it's reasonable to do GSO first,
> then fragment any packet bigger than MTU as possible.
> 
> +---------------+ TX     RX +---------------+
> |   KVM Guest   | -> ... -> |   KVM Guest   |
> +-+-----------+-+           +-+-----------+-+
>   |Qemu/VirtIO|               |Qemu/VirtIO|
>   +-----------+               +-----------+
>        |                            |
>        v tap0                  tap0 v
>   +-----------+               +-----------+
>   | ovs bridge|               | ovs bridge|
>   +-----------+               +-----------+
>        | vxlan                vxlan |
>        v                            v
>   +-----------+               +-----------+
>   |    NIC    |    <------>   |    NIC    |
>   +-----------+               +-----------+
> 
> Steps to reproduce:
>  1. Using kernel builtin openvswitch module to setup ovs bridge.
>  2. Runing iperf without -M, communication will stuck.

Is this issue specific to ovs or ipv4? Path MTU discovery should
help in this case I believe.
> 
> 
> Signed-off-by: Fan Du <fan.du@intel.com>
> ---
>  net/ipv4/ip_output.c |    7 ++++---
>  1 files changed, 4 insertions(+), 3 deletions(-)
> 
> diff --git a/net/ipv4/ip_output.c b/net/ipv4/ip_output.c
> index bc6471d..558b5f8 100644
> --- a/net/ipv4/ip_output.c
> +++ b/net/ipv4/ip_output.c
> @@ -217,9 +217,10 @@ static int ip_finish_output_gso(struct sk_buff 
> *skb)
>  	struct sk_buff *segs;
>  	int ret = 0;
>  
> -	/* common case: locally created skb or seglen is <= mtu */
> -	if (((IPCB(skb)->flags & IPSKB_FORWARDED) == 0) ||
> -	      skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
> +	/* Both locally created skb and forwarded skb could exceed
> +	 * MTU size, so make a unified rule for them all.
> +	 */
> +	if (skb_gso_network_seglen(skb) <= ip_skb_dst_mtu(skb))
>  		return ip_finish_output2(skb);
>  
>  	/* Slowpath -  GSO segment length is exceeding the dst MTU.
> -- 
> 1.7.1
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
