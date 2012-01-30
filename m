From: Or Gerlitz <ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>
Subject: Re: [PATCH 2/2] IB/ipoib: fix GRO merge failure for IPoIB originated
 TCP streams
Date: Mon, 30 Jan 2012 09:44:44 +0200
Message-ID: <4F264A6C.3070706@mellanox.com>
References: <alpine.LRH.2.00.1201261624540.30384@ogerlitz.voltaire.com> <alpine.LRH.2.00.1201261642340.31408@ogerlitz.voltaire.com> <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-rdma <linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Shlomo Pongratz <shlomop-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>,
	<netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Roland Dreier <roland-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Herbert Xu <herbert-lOAM2aK0SrRLBo1qDEOMRrpzq4S04n8Q@public.gmane.org>, <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CAL1RGDUm8ROxFFMa+D1ZD5jF+cK+kV8aEVzspgnZFNXeuai+fA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 1/30/2012 6:36 AM, Roland Dreier wrote:
> On Thu, Jan 26, 2012 at 6:43 AM, Or Gerlitz<ogerlitz-VPRAkNaXOzVWk0Htik3J/w@public.gmane.org>  wrote:
>> The GRO flow makes a check in every layer to ensure the packets
>> are actually merged only if they match at all layers.
>>
>> The first GRO check, at L2 always fails for IPoIB, since it assumes
>> that all packets have 14 bytes of Ethernet link layer header. Using the
>> IPoIB header will not help here either, since its only four bytes. To
>> overcome this, the skb mac header pointer is set to an area within the
>> packet IB GRH headroom, such that later, the L2 check done by GRO
>> succeeds and it can move to checks at the network and transport layers.
>
>> --- a/drivers/infiniband/ulp/ipoib/ipoib_ib.c
>> +++ b/drivers/infiniband/ulp/ipoib/ipoib_ib.c
>> @@ -286,10 +287,20 @@ static void ipoib_ib_handle_rx_wc(struct net_device *dev, struct ib_wc *wc)
>>         else
>>                 skb->pkt_type = PACKET_MULTICAST;
>>
>> -       skb_pull(skb, IB_GRH_BYTES);
>> +       /*
>> +        * GRO first does L2 compares (14 bytes). We must not let it start from
>> +        * the IPoIB header as ten octets of the IP header, containing fields
>> +        * which vary from packet to packet will cause non-merging of packets.
>> +        * from the same TCP stream.
>> +        */
>> +       psgid = skb_pull(skb, offsetof(struct ib_grh, sgid));
>> +       /* if there's no GRH, that area could contain random data */
>> +       if (!(wc->wc_flags&  IB_WC_GRH))
>> +               memset(psgid, 0, 16);
>> +       skb_reset_mac_header(skb);
>> +       skb_pull(skb, IB_GRH_BYTES - offsetof(struct ib_grh, sgid));
>>
>>         skb->protocol = ((struct ipoib_header *) skb->data)->proto;
>> -       skb_reset_mac_header(skb);
>
> This seems like a really weird place to fix this.  Wouldn't it
> make more sense to fix the GRO check to handle non-ethernet L2 headers?

Yes, we can do that as well. Herbert, Dave, would it be enough here, to 
skip the Ethernet header and vlan comparison for skbs whose associated 
netdevice type isn't ARPHRD_ETHER? e.g something along the lines of:

> diff --git a/net/core/dev.c b/net/core/dev.c
> index 115dee1..c529f5a 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -3505,9 +3505,11 @@ __napi_gro_receive(struct napi_struct *napi, 
> struct sk_buff *skb)
>                 unsigned long diffs;
>
>                 diffs = (unsigned long)p->dev ^ (unsigned long)skb->dev;
> -               diffs |= p->vlan_tci ^ skb->vlan_tci;
> -               diffs |= compare_ether_header(skb_mac_header(p),
> -                                             skb_gro_mac_header(skb));
> +               if (!diffs && p->dev->type == ARPHRD_ETHER) {
> +                       diffs |= p->vlan_tci ^ skb->vlan_tci;
> +                       diffs |= compare_ether_header(skb_mac_header(p),
> +                                                     
> skb_gro_mac_header(skb));
> +               }
>                 NAPI_GRO_CB(p)->same_flow = !diffs;
>                 NAPI_GRO_CB(p)->flush = 0;
>         }

--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
