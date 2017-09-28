From: Florian Fainelli <f.fainelli@gmail.com>
Subject: Re: [patch net-next 3/7] ipv4: ipmr: Don't forward packets already
 forwarded by hardware
Date: Thu, 28 Sep 2017 10:56:38 -0700
Message-ID: <bb37f353-8f15-f570-a35e-ed76c56f1180@gmail.com>
References: <20170928173415.15551-1-jiri@resnulli.us>
 <20170928173415.15551-4-jiri@resnulli.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, yotamg@mellanox.com, idosch@mellanox.com,
        mlxsw@mellanox.com, nikolay@cumulusnetworks.com, andrew@lunn.ch,
        dsa@cumulusnetworks.com, edumazet@google.com, willemb@google.com,
        johannes.berg@intel.com, dcaratti@redhat.com, pabeni@redhat.com,
        daniel@iogearbox.net, fw@strlen.de, gfree.wind@vip.163.com
To: Jiri Pirko <jiri@resnulli.us>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f193.google.com ([209.85.220.193]:35359 "EHLO
        mail-qk0-f193.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752042AbdI1R4r (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 28 Sep 2017 13:56:47 -0400
Received: by mail-qk0-f193.google.com with SMTP id o77so1507122qke.2
        for <netdev@vger.kernel.org>; Thu, 28 Sep 2017 10:56:46 -0700 (PDT)
In-Reply-To: <20170928173415.15551-4-jiri@resnulli.us>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 09/28/2017 10:34 AM, Jiri Pirko wrote:
> From: Yotam Gigi <yotamg@mellanox.com>
> 
> Change the ipmr module to not forward packets if:
>  - The packet is marked with the offload_mr_fwd_mark, and
>  - Both input interface and output interface share the same parent ID.
> 
> This way, a packet can go through partial multicast forwarding in the
> hardware, where it will be forwarded only to the devices that share the
> same parent ID (AKA, reside inside the same hardware). The kernel will
> forward the packet to all other interfaces.
> 
> To do this, add the ipmr_offload_forward helper, which per skb, ingress VIF
> and egress VIF, returns whether the forwarding was offloaded to hardware.
> The ipmr_queue_xmit frees the skb and does not forward it if the result is
> a true value.
> 
> All the forwarding path code compiles out when the CONFIG_NET_SWITCHDEV is
> not set.
> 
> Signed-off-by: Yotam Gigi <yotamg@mellanox.com>
> Reviewed-by: Ido Schimmel <idosch@mellanox.com>
> Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> ---
>  net/ipv4/ipmr.c | 37 ++++++++++++++++++++++++++++++++-----
>  1 file changed, 32 insertions(+), 5 deletions(-)
> 
> diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
> index 4566c54..deba569 100644
> --- a/net/ipv4/ipmr.c
> +++ b/net/ipv4/ipmr.c
> @@ -1857,10 +1857,33 @@ static inline int ipmr_forward_finish(struct net *net, struct sock *sk,
>  	return dst_output(net, sk, skb);
>  }
>  
> +#ifdef CONFIG_NET_SWITCHDEV
> +static bool ipmr_forward_offloaded(struct sk_buff *skb, struct mr_table *mrt,
> +				   int in_vifi, int out_vifi)
> +{
> +	struct vif_device *out_vif = &mrt->vif_table[out_vifi];
> +	struct vif_device *in_vif = &mrt->vif_table[in_vifi];

Nit: in_vifi and out_vifi may be better named as in_vif_idx and
out_vif_idx, oh well you are just replicating the existing naming
conventions used down below, never mind then.
-- 
Florian
