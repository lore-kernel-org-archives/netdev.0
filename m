From: Alex Duyck <aduyck@mirantis.com>
Subject: Re: [net-next PATCH 6/8] mlx4: Add support for inner IPv6 checksum
 offloads and TSO
Date: Tue, 26 Apr 2016 08:50:01 -0700
Message-ID: <CAMt9YRqrk51Rx28FiBiR2RM-fern-UuUq7_A+FeZV+mfm_q+zg@mail.gmail.com>
References: <20160425182442.11331.88349.stgit@ahduyck-xeon-server>
	<20160425183133.11331.54774.stgit@ahduyck-xeon-server>
	<571F7D14.7090504@dev.mellanox.co.il>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: talal@mellanox.com,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>, galp@mellanox.com,
	ogerlitz@mellanox.com, Eran Ben Elisha <eranbe@mellanox.com>
To: Saeed Mahameed <saeedm@dev.mellanox.co.il>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f43.google.com ([209.85.213.43]:35073 "EHLO
	mail-vk0-f43.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751915AbcDZPuD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 26 Apr 2016 11:50:03 -0400
Received: by mail-vk0-f43.google.com with SMTP id u23so21643518vkb.2
        for <netdev@vger.kernel.org>; Tue, 26 Apr 2016 08:50:02 -0700 (PDT)
In-Reply-To: <571F7D14.7090504@dev.mellanox.co.il>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Apr 26, 2016 at 7:37 AM, Saeed Mahameed
<saeedm@dev.mellanox.co.il> wrote:
>
>
> On 4/25/2016 9:31 PM, Alexander Duyck wrote:
>>
>> >From what I can tell the ConnectX-3 will support an inner IPv6 checksum
>> and
>> segmentation offload, however it cannot support outer IPv6 headers.  For
>> this reason I am adding the feature to the hw_enc_features and adding an
>> extra check to the features_check call that will disable GSO and checksum
>> offload in the case that the encapsulated frame has an outer IP version of
>> that is not 4.
>
>
> Hi Alex,
>
> Can you share the testing commands of running vxlan over IPv6 and what
> exactly didn't work for you ?
> we would like to test this in house and understand what went wrong,
> theoretically there shouldn't be a difference between IPv6/IPv4 outer
> checksum offloading in ConnectX-3.

The setup is pretty straight forward.  Basically I left the first port
in the default namespace and moved the second int a secondary
namespace referred to below as $netns.  I then assigned the IPv6
addresses fec0::10:1 and fec0::10:2. After that I ran the following:

        VXLAN=vx$net
        echo $VXLAN ${test_options[$i]}
        ip link add $VXLAN type vxlan id $net \
                local fec0::10:1 remote $addr6 dev $PF0 \
                ${test_options[$i]} dstport `expr 8800 + $net`
        ip netns exec $netns ip link add $VXLAN type vxlan id $net \
                                  local $addr6 remote fec0::10:1 dev $port \
                                  ${test_options[$i]} dstport `expr 8800 + $net`
        ifconfig $VXLAN 192.168.${net}.1/24
        ip netns exec $netns ifconfig $VXLAN 192.168.${net}.2/24


> Anyway, I suspect it might be related to a driver bug most likely in
> get_real_size function @en_tx.c
> specifically in : *lso_header_size = (skb_inner_transport_header(skb) -
> skb->data) + inner_tcp_hdrlen(skb);
>
> will check this and get back to you.

I'm not entirely convinced.  What I was seeing is t hat the hardware
itself was performing Rx checksum offload only on tunnels with an
outer IPv4 header and ignoring tunnels with an outer IPv6 header.

> for the mlx5 patches I will also go through them later today.

Thanks.

>
>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>> ---
>>   drivers/net/ethernet/mellanox/mlx4/en_netdev.c |   25
>> +++++++++++++++++++-----
>>   drivers/net/ethernet/mellanox/mlx4/en_tx.c     |   15 ++++++++++++--
>>   2 files changed, 33 insertions(+), 7 deletions(-)
>>
>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> index bce37cbfde24..6f28ac58251c 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>> @@ -2357,8 +2357,10 @@ out:
>>         }
>>         /* set offloads */
>> -       priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>> -                                     NETIF_F_TSO | NETIF_F_GSO_UDP_TUNNEL
>> |
>> +       priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_IPV6_CSUM
>> |
>> +                                     NETIF_F_RXCSUM |
>> +                                     NETIF_F_TSO | NETIF_F_TSO6 |
>> +                                     NETIF_F_GSO_UDP_TUNNEL |
>>                                       NETIF_F_GSO_UDP_TUNNEL_CSUM |
>>                                       NETIF_F_GSO_PARTIAL;
>>   }
>> @@ -2369,8 +2371,10 @@ static void mlx4_en_del_vxlan_offloads(struct
>> work_struct *work)
>>         struct mlx4_en_priv *priv = container_of(work, struct
>> mlx4_en_priv,
>>                                                  vxlan_del_task);
>>         /* unset offloads */
>> -       priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>> -                                       NETIF_F_TSO |
>> NETIF_F_GSO_UDP_TUNNEL |
>> +       priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM |
>> NETIF_F_IPV6_CSUM |
>> +                                       NETIF_F_RXCSUM |
>> +                                       NETIF_F_TSO | NETIF_F_TSO6 |
>> +                                       NETIF_F_GSO_UDP_TUNNEL |
>>                                         NETIF_F_GSO_UDP_TUNNEL_CSUM |
>>                                         NETIF_F_GSO_PARTIAL);
>>   @@ -2431,7 +2435,18 @@ static netdev_features_t
>> mlx4_en_features_check(struct sk_buff *skb,
>>                                                 netdev_features_t
>> features)
>>   {
>>         features = vlan_features_check(skb, features);
>> -       return vxlan_features_check(skb, features);
>> +       features = vxlan_features_check(skb, features);
>> +
>> +       /* The ConnectX-3 doesn't support outer IPv6 checksums but it does
>> +        * support inner IPv6 checksums and segmentation so  we need to
>> +        * strip that feature if this is an IPv6 encapsulated frame.
>> +        */
>> +       if (skb->encapsulation &&
>> +           (skb->ip_summed == CHECKSUM_PARTIAL) &&
>> +           (ip_hdr(skb)->version != 4))
>> +               features &= ~(NETIF_F_CSUM_MASK | NETIF_F_GSO_MASK);
>
> Dejavu, didn't you fix this already in harmonize_features, in
> i.e, it is enough to do here:
>
> if (skb->encapsulation && (skb->ip_summed == CHECKSUM_PARTIAL))
>             features &= ~NETIF_F_IPV6_CSUM;
>

So what this patch is doing is enabling an inner IPv6 header offloads.
Up above we set the NETIF_F_IPV6_CSUM bit and we want it to stay set
unless we have an outer IPv6 header because the inner headers may
still need that bit set.  If I did what you suggest it strips IPv6
checksum support for inner headers and if we have to use GSO partial I
ended up encountering some of the other bugs that I have fixed for GSO
partial where either sg or csum are not defined.

>
>> +
>> +       return features;
>>   }
>>   #endif
>>   diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> index c0d7b7296236..c9f5388ea22a 100644
>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>> @@ -41,6 +41,7 @@
>>   #include <linux/vmalloc.h>
>>   #include <linux/tcp.h>
>>   #include <linux/ip.h>
>> +#include <linux/ipv6.h>
>>   #include <linux/moduleparam.h>
>>     #include "mlx4_en.h"
>> @@ -918,8 +919,18 @@ netdev_tx_t mlx4_en_xmit(struct sk_buff *skb, struct
>> net_device *dev)
>>                                  tx_ind, fragptr);
>>         if (skb->encapsulation) {
>> -               struct iphdr *ipv4 = (struct iphdr
>> *)skb_inner_network_header(skb);
>> -               if (ipv4->protocol == IPPROTO_TCP || ipv4->protocol ==
>> IPPROTO_UDP)
>> +               union {
>> +                       struct iphdr *v4;
>> +                       struct ipv6hdr *v6;
>> +                       unsigned char *hdr;
>> +               } ip;
>> +               u8 proto;
>> +
>> +               ip.hdr = skb_inner_network_header(skb);
>> +               proto = (ip.v4->version == 4) ? ip.v4->protocol :
>> +                                               ip.v6->nexthdr;
>> +
>> +               if (proto == IPPROTO_TCP || proto == IPPROTO_UDP)
>>                         op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP |
>> MLX4_WQE_CTRL_ILP);
>>                 else
>>                         op_own |= cpu_to_be32(MLX4_WQE_CTRL_IIP);
>
>
> basically this is a bug fix, I don't know why the original author assumed it
> will be ipv4 !

Because the feature flags didn't allow it any other way.  I am adding
the NETIF_F_TSO6 and NETIF_F_IPV6_CSUM flags in hw_enc_features and so
situations such as this couldn't be encountered until you start adding
those flags.

- Alex
