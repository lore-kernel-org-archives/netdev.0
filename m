From: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Subject: Re: [net-next PATCH 6/8] mlx4: Add support for inner IPv6 checksum
 offloads and TSO
Date: Tue, 26 Apr 2016 23:23:17 +0300
Message-ID: <CALzJLG87ABt8O8MpT7GycdREfkYTv3eabRCWuBsJOBDf7+LhGg@mail.gmail.com>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
 <20160425183133.11331.54774.stgit@ahduyck-xeon-server> <571F7D14.7090504@dev.mellanox.co.il>
 <CAMt9YRqrk51Rx28FiBiR2RM-fern-UuUq7_A+FeZV+mfm_q+zg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Tal Alon <talal@mellanox.com>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	Gal Pressman <galp@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Eran Ben Elisha <eranbe@mellanox.com>
To: Alex Duyck <aduyck@mirantis.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f194.google.com ([209.85.161.194]:33944 "EHLO
	mail-yw0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752427AbcDZUXi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 16:23:38 -0400
Received: by mail-yw0-f194.google.com with SMTP id i22so4416666ywc.1
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 13:23:38 -0700 (PDT)
In-Reply-To: <CAMt9YRqrk51Rx28FiBiR2RM-fern-UuUq7_A+FeZV+mfm_q+zg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 6:50 PM, Alex Duyck <aduyck@mirantis.com> wrote:
>
> The setup is pretty straight forward.  Basically I left the first port
> in the default namespace and moved the second int a secondary
> namespace referred to below as $netns.  I then assigned the IPv6
> addresses fec0::10:1 and fec0::10:2. After that I ran the following:
>
>         VXLAN=vx$net
>         echo $VXLAN ${test_options[$i]}
>         ip link add $VXLAN type vxlan id $net \
>                 local fec0::10:1 remote $addr6 dev $PF0 \
>                 ${test_options[$i]} dstport `expr 8800 + $net`
>         ip netns exec $netns ip link add $VXLAN type vxlan id $net \
>                                   local $addr6 remote fec0::10:1 dev $port \
>                                   ${test_options[$i]} dstport `expr 8800 + $net`
>         ifconfig $VXLAN 192.168.${net}.1/24
>         ip netns exec $netns ifconfig $VXLAN 192.168.${net}.2/24
>

Thanks, indeed i see that GSO is not working with vxlan over IPv6 over
mlx5 device.
We will test out those patches on both mlx4 and mlx5, and debug mlx4
IPv6 issue you see.

>
>> Anyway, I suspect it might be related to a driver bug most likely in
>> get_real_size function @en_tx.c
>> specifically in : *lso_header_size = (skb_inner_transport_header(skb) -
>> skb->data) + inner_tcp_hdrlen(skb);
>>
>> will check this and get back to you.
>
> I'm not entirely convinced.  What I was seeing is t hat the hardware
> itself was performing Rx checksum offload only on tunnels with an
> outer IPv4 header and ignoring tunnels with an outer IPv6 header.

I don't get it, are you trying to say that the issue is in the RX side ?
what do you mean by ignoring ? Dropping ? or just not validating checksum ?
if so why would you disable GSO and IPv6 checksumming on TX ?

>>>   @@ -2431,7 +2435,18 @@ static netdev_features_t
>>> mlx4_en_features_check(struct sk_buff *skb,
>>>                                                 netdev_features_t
>>> features)
>>>   {
>>>         features = vlan_features_check(skb, features);
>>> -       return vxlan_features_check(skb, features);
>>> +       features = vxlan_features_check(skb, features);
>>> +
>>> +       /* The ConnectX-3 doesn't support outer IPv6 checksums but it does
>>> +        * support inner IPv6 checksums and segmentation so  we need to
>>> +        * strip that feature if this is an IPv6 encapsulated frame.
>>> +        */
>>> +       if (skb->encapsulation &&
>>> +           (skb->ip_summed == CHECKSUM_PARTIAL) &&
>>> +           (ip_hdr(skb)->version != 4))
>>> +               features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
>>
>> Dejavu, didn't you fix this already in harmonize_features, in
>> i.e, it is enough to do here:
>>
>> if (skb->encapsulation && (skb->ip_summed == CHECKSUM_PARTIAL))
>>             features &= ~NETIF_F_IPV6_CSUM;
>>
>
> So what this patch is doing is enabling an inner IPv6 header offloads.
> Up above we set the NETIF_F_IPV6_CSUM bit and we want it to stay set
> unless we have an outer IPv6 header because the inner headers may
> still need that bit set.  If I did what you suggest it strips IPv6
> checksum support for inner headers and if we have to use GSO partial I
> ended up encountering some of the other bugs that I have fixed for GSO
> partial where either sg or csum are not defined.
>

I see, you mean that you want to disable checksumming and GSO only for
packets with Outer(IPv6):Inner(X) and keep it in case for
Outer(IPv4):Inner(IPv6)
but i think it is weird that the driver decides to disable features it
didn't declare in first place (NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK)

Retry:

if (skb->encapsulation && (skb->ip_summed == CHECKSUM_PARTIAL) &&
    (ip_hdr(skb)->version != 4))
            features &= ~NETIF_F_IPV6_CSUM;

will this work ?

Anyway i prefer to debug the mlx4 issue first before we discuss the
best approach to disable checksumming & GSO for outer IPv6 in mlx4.

>>
>>> +
>>> +       return features;
>>>   }
>>>   #endif
>>>   diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> index c0d7b7296236..c9f5388ea22a 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> @@ -41,6 +41,7 @@
>>>   #include <linux/vmalloc.h>
>>>   #include <linux/tcp.h>
>>>   #include <linux/ip.h>
>>> +#include <linux/ipv6.h>
>>>   #include <linux/moduleparam.h>
>>>     #include "mlx4_en.h"
>>> @@ -918,8 +919,18 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct
>>> net_device *dev)
>>>                                  tx_ind, fragptr);
>>>         if (skb->encapsulation) {
>>> -               struct iphdr *ipv4 = (struct iphdr
>>> *)skb_inner_network_header(skb);
>>> -               if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol ==
>>> IPPROTO_UDP)
>>> +               union {
>>> +                       struct iphdr *v4;
>>> +                       struct ipv6hdr *v6;
>>> +                       unsigned char *hdr;
>>> +               } ip;
>>> +               u8 proto;
>>> +
>>> +               ip.hdr = skb_inner_network_header(skb);
>>> +               proto = (ip.v4->version == 4) ? ip.v4->protocol :
>>> +                                               ip.v6->nexthdr;
>>> +
>>> +               if (proto == IPPROTO_TCP || proto == IPPROTO_UDP)
>>>                         op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP |
>>> MLX4_WQE_CTRL_ILP);
>>>                 else
>>>                         op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
>>
>>
>> basically this is a bug fix, I don't know why the original author assumed it
>> will be ipv4 !
>
> Because the feature flags didn't allow it any other way.  I am adding
> the NETIF_F_TSO6 and NETIF_F_IPV6_CSUM flags in hw_enc_features and so
> situations such as this couldn't be encountered until you start adding
> those flags.
>

True.

Thanks,
- Saeed
