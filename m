From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH RFC 3/3] mlx4: Call skb_csum_offload_check to check
 offloadability
Date: Tue, 6 Oct 2015 09:54:11 -0700
Message-ID: <5613FCB3.1020005@gmail.com>
References: <1444088364-2839440-1-git-send-email-tom@herbertland.com>
 <1444088364-2839440-4-git-send-email-tom@herbertland.com>
 <56134812.3000303@gmail.com>
 <CALx6S35XHzp=1b=XpiG2Vrc4ZRUiMyfbLCb5Q840ZWuK-PRVyQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "David S. Miller" <davem@davemloft.net>,
	Linux Kernel Network Developers <netdev@vger.kernel.org>,
	Kernel Team <kernel-team@fb.com>,
	David Woodhouse <dwmw2@infradead.org>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f50.google.com ([209.85.220.50]:36580 "EHLO
	mail-pa0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751204AbbJFQyN (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Oct 2015 12:54:13 -0400
Received: by pablk4 with SMTP id lk4so214504513pab.3
        for <netdev@vger.kernel.org>; Tue, 06 Oct 2015 09:54:12 -0700 (PDT)
In-Reply-To: <CALx6S35XHzp=1b=XpiG2Vrc4ZRUiMyfbLCb5Q840ZWuK-PRVyQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/06/2015 09:22 AM, Tom Herbert wrote:
> On Mon, Oct 5, 2015 at 9:03 PM, Alexander Duyck
> <alexander.duyck@gmail.com> wrote:
>> On 10/05/2015 04:39 PM, Tom Herbert wrote:
>>> This provides an example of a driver calling the skb_csum_offload_check.
>>>
>>> Signed-off-by: Tom Herbert <tom@herbertland.com>
>>> ---
>>>    drivers/net/ethernet/mellanox/mlx4/en_netdev.c |  6 +++---
>>>    drivers/net/ethernet/mellanox/mlx4/en_tx.c     | 20 +++++++++++++++-----
>>>    2 files changed, 18 insertions(+), 8 deletions(-)
>>>
>>> diff --git a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> index 4726122..f2ed8d0 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_netdev.c
>>> @@ -2360,7 +2360,7 @@ out:
>>>          }
>>>          /* set offloads */
>>> -       priv->dev->hw_enc_features |= NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>>> +       priv->dev->hw_enc_features |= NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
>>>                                        NETIF_F_TSO |
>>> NETIF_F_GSO_UDP_TUNNEL;
>>>          priv->dev->hw_features |= NETIF_F_GSO_UDP_TUNNEL;
>>>          priv->dev->features    |= NETIF_F_GSO_UDP_TUNNEL;
>>> @@ -2372,7 +2372,7 @@ static void mlx4_en_del_vxlan_offloads(struct
>>> work_struct *work)
>>>          struct mlx4_en_priv *priv = container_of(work, struct
>>> mlx4_en_priv,
>>>                                                   vxlan_del_task);
>>>          /* unset offloads */
>>> -       priv->dev->hw_enc_features &= ~(NETIF_F_IP_CSUM | NETIF_F_RXCSUM |
>>> +       priv->dev->hw_enc_features &= ~(NETIF_F_HW_CSUM | NETIF_F_RXCSUM |
>>>                                        NETIF_F_TSO |
>>> NETIF_F_GSO_UDP_TUNNEL);
>>>          priv->dev->hw_features &= ~NETIF_F_GSO_UDP_TUNNEL;
>>>          priv->dev->features    &= ~NETIF_F_GSO_UDP_TUNNEL;
>>> @@ -2943,7 +2943,7 @@ int mlx4_en_init_netdev(struct mlx4_en_dev *mdev,
>>> int port,
>>>          /*
>>>           * Set driver features
>>>           */
>>> -       dev->hw_features = NETIF_F_SG | NETIF_F_IP_CSUM |
>>> NETIF_F_IPV6_CSUM;
>>> +       dev->hw_features = NETIF_F_SG | NETIF_F_HW_CSUM;
>>>          if (mdev->LSO_support)
>>>                  dev->hw_features |= NETIF_F_TSO | NETIF_F_TSO6;
>>>    diff --git a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> index 494e776..f364ffd 100644
>>> --- a/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> +++ b/drivers/net/ethernet/mellanox/mlx4/en_tx.c
>>> @@ -702,6 +702,14 @@ static void mlx4_bf_copy(void __iomem *dst, const
>>> void *src,
>>>          __iowrite64_copy(dst, src, bytecnt / 8);
>>>    }
>>>    +static const struct skb_csum_offl_spec csum_offl_spec = {
>>> +       .ipv4_okay = 1,
>>> +       .ipv6_okay = 1,
>>> +       .encap_okay = 1,
>>> +       .tcp_okay = 1,
>>> +       .udp_okay = 1,
>>> +};
>>> +
>>
>> The question I would have is if inner IPv6 checksum is supported by this
>> driver.  The code before didn't seem to indicate it was, and after the
>> csum_offl_spec would seem to indicate it is.  One of my concerns about a
>> change like this is that it is likely prone to introduce regressions as
>> features are going to be toggling due to interpretations of flags and
>> assumptions about what is good for the outer headers is good for the inner
>> ones.
> Do you mean to say that there could be a device that supports an inner
> and outer checksum for IPv4, but only an outer checksum for IPv6 and
> not inner checksum?
>
> Tom

Yes, that is what I mean.  The fact is hardware designs are often short 
sighted like that.  Somebody may have decided to save a few gates by 
only supporting IPv4 because somebody somewhere didn't make it a hard 
requirement to support IPv6, or perhaps the implementation wasn't quite 
right and instead of spinning a new silicon they decided to de-feature 
IPv6 inner checksum offload.

I don't know if that is the case for the mlx4, maybe it is just a driver 
oversight, but the fact that it didn't list IPv6 as being a supported 
encapsulation before kind of implies that it doesn't support TCP/UDP 
checksums on top of encapsulated IPv6.

- Alex
