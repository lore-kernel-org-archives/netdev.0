From: Macnish <macnish@gmail.com>
Subject: Re: cc: skb configured but can't get data allocated
Date: Wed, 12 Sep 2007 15:21:17 -0300
Message-ID: <46E82E1D.6080002@gmail.com>
References: <200709121731456120c5e4ad@mail.smumn.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kernelnewbies@nl.linux.org
To: DHAJOGLO <DHAJOGLO@smumn.edu>
Return-path: <netdev-owner@vger.kernel.org>
Received: from an-out-0708.google.com ([209.85.132.248]:53300 "EHLO
	an-out-0708.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1764471AbXILSVY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 12 Sep 2007 14:21:24 -0400
Received: by an-out-0708.google.com with SMTP id d31so39104and
        for <netdev@vger.kernel.org>; Wed, 12 Sep 2007 11:21:24 -0700 (PDT)
In-Reply-To: <200709121731456120c5e4ad@mail.smumn.edu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

DHAJOGLO escreveu:
> Right,
>     I managed to figure out through looking at the code how to configure and send my skb properly.  For those who say the code is well documented.. you're right.. however I fell like a blind man in an "adult book store" and just don't see what I'm missing.  Below is my code. The packets are making it back and forth but the data is absent on the return trip.  d_out is my little struct with two bytes and a char.
>
>
>
> struct sk_buff *send_back(struct sk_buff *oldskb)
> {
>         struct sk_buff *skb;
>         struct iphdr *iph;
>         struct net_device *dev = (struct net_device *)oldskb->dev;
>         struct rtable *rt;
>         int iplen;
>         struct ethhdr *mac;
>         struct exp_packet *d_out;
>
>         skb = alloc_skb(sizeof(struct exp_packet) + LL_RESERVED_SPACE(dev), GFP_ATOMIC);
>         if(skb == NULL)
>                 return NULL;
>
>         /* insert the data probably need to allocatd differently */
>         d_out = (struct exp_packet *)skb->data;
>         d_out->headbits = 0xAA;
>         d_out->sequence = 0xBB;
>         d_out->payload = 0xCCDD;
>
>         /* from igmp... configure the rt */
>         {
>                 struct flowi fl = { .oif = dev->ifindex,
>                                         .nl_u = { .ip4_u = {
>                                                 .daddr = htonl(oldskb->nh.iph->saddr) } },
>                                                 .proto = IPPROTO_EXP };
>                 if (ip_route_output_key(&rt,&fl)) {
>                         printk("No route?\n");
>                         kfree_skb(skb);
>                         return NULL;
>                 }
>         }
>         if (rt->rt_src == 0) {
>                 printk("No source info?\n");
>                 ip_rt_put(rt);
>                 return NULL;
>         }
>
>         skb->dst = &rt->u.dst;
>         skb->dev = dev;
>
>         skb_reserve(skb,LL_RESERVED_SPACE(dev));
>
>         /* configure the ipheader */
>  skb->nh.iph = iph = (struct iphdr *)skb_put(skb,sizeof(struct iphdr)+4);
>
>         iph->version    = 4;
>         iph->ihl        = (sizeof(struct iphdr)+4)>>2;
>         iph->protocol   = IPPROTO_EXP;
>         iph->saddr      = rt->rt_src;
>         iph->daddr      = htonl(rt->rt_dst);
>         iph->tos        = 0;
>         iph->ttl        = 5;
>         ip_select_ident(iph,&rt->u.dst,NULL);
>         iplen = skb->tail - (unsigned char *)skb->nh.iph;
>         iph->tot_len = htons(iplen);
>         ip_send_check(iph);
>
>
>         skb->pkt_type = PACKET_OUTGOING;
>
>         mac = (struct ethhdr *)oldskb->mac.raw;
>
>         /* configure the mac addresses */
>         if(dev->hard_header && dev->hard_header(skb,dev,ETH_P_IP,mac->h_source,mac->h_dest,skb->len) < 0)
>                 printk("hard header worked?");
>
>         return skb;
> }
>
> === the packets look like this and they should be the same save for swapped src/dst:
>
> 00:12:3f:56:bf:1c > 00:0c:29:71:67:1e, ethertype IPv4 (0x0800), length 60: (tos 0x0, ttl  20, id 153, offset 0, flags [DF], proto: unknown (253), length: 24) src.src.src.src > dst.dst.dst.dst:  ip-proto-253 4
>         0x0000:  4500 0018 0099 4000 14fd c4ed 8cbe 414d  E.....@.......AM
>         0x0010:  8cbe 4599 001b ddee 0000 0000 0000 0000  ..E.............
>         0x0020:  0000 0000 0000 0000 0000 0000 0000       ..............
> 00:0c:29:71:67:1e > 00:12:3f:56:bf:1c, ethertype IPv4 (0x0800), length 38: (tos 0x0, ttl   5, id 0, offset 65528, flags [+, DF, rsvd], proto: unknown (253), length: 24, options ( unknown (243) len 252[|ip] )) src.src.src.src > dst.dst.dst.dst: ip-proto-253
>         0x0000:  4600 0018 0000 ffff 05fd 1f8a 8cbe 4599  F.............E.
>         0x0010:  8cbe 414d f3fc 0000                      ..AM....
>
>
> --
> To unsubscribe from this list: send an email with
> "unsubscribe kernelnewbies" to ecartis@nl.linux.org
> Please read the FAQ at http://kernelnewbies.org/FAQ
>
>
>   
Am I missing something or the d_out struct hadn't been put inside the skb?

--
Best Regards

Alan Menegotto

