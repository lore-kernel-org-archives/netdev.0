From: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Subject: Re: [PATCH net-next-2.6] ip_gre: lockless xmit
Date: Wed, 29 Sep 2010 10:10:19 +0200
Message-ID: <4CA2F46B.1070607@6wind.com>
References: <1285664747.2607.48.camel@edumazet-laptop>
Reply-To: nicolas.dichtel@6wind.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:47774 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751756Ab0I2IK2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 29 Sep 2010 04:10:28 -0400
Received: by wwd20 with SMTP id 20so520913wwd.1
        for <netdev@vger.kernel.org>; Wed, 29 Sep 2010 01:10:26 -0700 (PDT)
In-Reply-To: <1285664747.2607.48.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

NETIF_F_LLTX is marked as deprecated:

include/linux/netdevice.h:
#define NETIF_F_LLTX            4096    /* LockLess TX - deprecated. 
Please */
                                         /* do not use LLTX in new 
drivers */

Is it right to use it?

Regards,
Nicolas

Eric Dumazet wrote:
> GRE tunnels can benefit from lockless xmits, using NETIF_F_LLTX
> 
> Note: If tunnels are created with the "oseq" option, LLTX is not
> enabled :
> 
> Even using an atomic_t o_seq, we would increase chance for packets being
> out of order at receiver.
> 
> Bench on a 16 cpus machine (dual E5540 cpus), 16 threads sending
> 10000000 UDP frames via one gre tunnel (size:200 bytes per frame)
> 
> Before patch : 
> real	3m0.094s
> user	0m9.365s
> sys	47m50.103s
> 
> After patch:
> real	0m29.756s
> user	0m11.097s
> sys	7m33.012s
> 
> Last problem to solve is the contention on dst :
> 
> 
> 38660.00 21.4% __ip_route_output_key          vmlinux             
> 20786.00 11.5% dst_release                    vmlinux             
> 14191.00  7.8% __xfrm_lookup                  vmlinux             
> 12410.00  6.9% ip_finish_output               vmlinux             
>  4540.00  2.5% ip_push_pending_frames         vmlinux             
>  4427.00  2.4% ip_append_data                 vmlinux             
>  4265.00  2.4% __alloc_skb                    vmlinux             
>  4140.00  2.3% __ip_local_out                 vmlinux             
>  3991.00  2.2% dev_queue_xmit                 vmlinux     
> 
> Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
> ---
>  net/ipv4/ip_gre.c |    4 ++++
>  1 files changed, 4 insertions(+)
> 
> diff --git a/net/ipv4/ip_gre.c b/net/ipv4/ip_gre.c
> index a1b5d5e..035db63 100644
> --- a/net/ipv4/ip_gre.c
> +++ b/net/ipv4/ip_gre.c
> @@ -1557,6 +1557,10 @@ static int ipgre_newlink(struct net *src_net, struct net_device *dev, struct nla
>  	if (!tb[IFLA_MTU])
>  		dev->mtu = mtu;
>  
> +	/* Can use a lockless transmit, unless we generate output sequences */
> +	if (!(nt->parms.o_flags & GRE_SEQ))
> +		dev->features |= NETIF_F_LLTX;
> +
>  	err = register_netdevice(dev);
>  	if (err)
>  		goto out;
> 
> 
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
