From: YOSHIFUJI Hideaki / =?iso-2022-jp?B?GyRCNUhGIzFRTEAbKEI=?= <yoshfuji@linux-ipv6.org>
Subject: Re: Source Specific Query of MLDv2 [PATCH]
Date: Tue, 10 Feb 2004 12:51:24 +0900 (JST)
Sender: netdev-bounce@oss.sgi.com
Message-ID: <20040210.125124.97248371.yoshfuji@linux-ipv6.org>
References: <20040207.154603.51160771.yoshfuji@linux-ipv6.org>
	<OF40DCBAE1.2110C762-ON88256E35.007F7C77-88256E35.0080020D@us.ibm.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: davem@redhat.com, hibi665@oki.com, netdev@oss.sgi.com,
        yoshfuji@linux-ipv6.org
Return-path: <netdev-bounce@oss.sgi.com>
To: dlstevens@us.ibm.com
In-Reply-To: <OF40DCBAE1.2110C762-ON88256E35.007F7C77-88256E35.0080020D@us.ibm.com>
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

In article <OF40DCBAE1.2110C762-ON88256E35.007F7C77-88256E35.0080020D@us.ibm.com> (at Mon, 9 Feb 2004 16:20:52 -0700), David Stevens <dlstevens@us.ibm.com> says:

> Here's a revised version with all the comments incorporated.

> @@ -211,50 +219,21 @@
> 
>  int ip6_mc_input(struct sk_buff *skb)
>  {
> -     struct ipv6hdr *hdr;
> -     int deliver = 0;
> -     int discard = 1;
> +     struct ipv6hdr *hdr;
> +     int deliver;
> 
>       IP6_INC_STATS_BH(Ip6InMcastPkts);
> 
>       hdr = skb->nh.ipv6h;
> -     if (ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, &hdr->saddr))
> -           deliver = 1;
> -
> -     /*
> -      *    IPv6 multicast router mode isnt currently supported.
> -      */
> -#if 0
> -     if (ipv6_config.multicast_route) {
> -           int addr_type;
> -
> -           addr_type = ipv6_addr_type(&hdr->daddr);
> -
> -           if (!(addr_type & (IPV6_ADDR_LOOPBACK | IPV6_ADDR_LINKLOCAL))) {
> -                 struct sk_buff *skb2;
> -                 struct dst_entry *dst;
> -
> -                 dst = skb->dst;
> -
> -                 if (deliver) {
> -                       skb2 = skb_clone(skb, GFP_ATOMIC);
> -                 } else {
> -                       discard = 0;
> -                       skb2 = skb;
> -                 }
> -
> -                 dst_output(skb2);
> -           }
> -     }
> -#endif
> +     deliver = !(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)) ||
> +         ipv6_chk_mcast_addr(skb->dev, &hdr->daddr, NULL);
> 
> -     if (deliver) {
> -           discard = 0;
> +     if (likely(deliver)) {
>             ip6_input(skb);
> +           return 0;
>       }
> -
> -     if (discard)
> -           kfree_skb(skb);
> +     /* discard */
> +     kfree_skb(skb);
> 
>       return 0;

likely(!(skb->dev->flags & (IFF_PROMISC|IFF_ALLMULTI)))?

Where is pskb_pull()?
I'd suggest to check the protocol number != icmp there.
After doing pskb_pull() in icmpv6_rcv(), we see type field.

BTW, I want to keep #if 0 ... #endif portion.
We're working on this... :-)

-- 
Hideaki YOSHIFUJI @ USAGI Project <yoshfuji@linux-ipv6.org>
GPG FP: 9022 65EB 1ECF 3AD1 0BDF  80D8 4807 F894 E062 0EEA
