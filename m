From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC PATCH 2/5] mlx5: Add support for UDP tunnel segmentation
 with outer checksum offload
Date: Thu, 28 Apr 2016 15:04:38 -0700
Message-ID: <CAKgT0UfsB+CbsCjerxDYkWgdGN01vmf4=VJRLEarFO4_nf-pow@mail.gmail.com>
References: <20160419185949.11723.50506.stgit@ahduyck-xeon-server>
	<20160419190603.11723.31623.stgit@ahduyck-xeon-server>
	<CALzJLG-8enmxxvjbVbcygVgM0VhX7Eo=6B=2pZF5jQzN9L9YEg@mail.gmail.com>
	<CAKgT0Uc5poLcTzkeA_8fi2jQeF08zbtj3+obTG1q0ha+ESZRCQ@mail.gmail.com>
	<800B6BE4-251F-4AA5-92FC-3A9393E7981E@mellanox.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Saeed Mahameed <saeedm@dev.mellanox.co.il>,
	Alexander Duyck <aduyck@mirantis.com>,
	Eugenia Emantayev <eugenia@mellanox.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	Saeed Mahameed <saeedm@mellanox.com>,
	Linux Netdev List <netdev@vger.kernel.org>,
	intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Ariel Elior <ariel.elior@qlogic.com>,
	Michael Chan <mchan@broadcom.com>
To: Matthew Finlay <Matt@mellanox.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f181.google.com ([209.85.213.181]:37749 "EHLO
	mail-ig0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753760AbcD1WEk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 18:04:40 -0400
Received: by mail-ig0-f181.google.com with SMTP id s8so4911860ign.0
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 15:04:39 -0700 (PDT)
In-Reply-To: <800B6BE4-251F-4AA5-92FC-3A9393E7981E@mellanox.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 28, 2016 at 2:43 PM, Matthew Finlay <Matt@mellanox.com> wrote:
>
>
>
>
>
> On 4/20/16, 11:06 AM, "Alexander Duyck" <alexander.duyck@gmail.com> wrote:
>
>>On Wed, Apr 20, 2016 at 10:40 AM, Saeed Mahameed
>><saeedm@dev.mellanox.co.il> wrote:
>>> On Tue, Apr 19, 2016 at 10:06 PM, Alexander Duyck <aduyck@mirantis.com> wrote:
>>>> This patch assumes that the mlx5 hardware will ignore existing IPv4/v6
>>>> header fields for length and checksum as well as the length and checksum
>>>> fields for outer UDP headers.
>>>>
>>>> I have no means of testing this as I do not have any mlx5 hardware but
>>>> thought I would submit it as an RFC to see if anyone out there wants to
>>>> test this and see if this does in fact enable this functionality allowing
>>>> us to to segment UDP tunneled frames that have an outer checksum.
>>>>
>>>> Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
>>>> ---
>>>>  drivers/net/ethernet/mellanox/mlx5/core/en_main.c |    7 ++++++-
>>>>  1 file changed, 6 insertions(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> index e0adb604f461..57d8da796d50 100644
>>>> --- a/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> +++ b/drivers/net/ethernet/mellanox/mlx5/core/en_main.c
>>>> @@ -2390,13 +2390,18 @@ static void mlx5e_build_netdev(struct net_device *netdev)
>>>>         netdev->hw_features      |= NETIF_F_HW_VLAN_CTAG_FILTER;
>>>>
>>>>         if (mlx5e_vxlan_allowed(mdev)) {
>>>> -               netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL;
>>>> +               netdev->hw_features     |= NETIF_F_GSO_UDP_TUNNEL |
>>>> +                                          NETIF_F_GSO_UDP_TUNNEL_CSUM |
>>>> +                                          NETIF_F_GSO_PARTIAL;
>>>>                 netdev->hw_enc_features |= NETIF_F_IP_CSUM;
>>>>                 netdev->hw_enc_features |= NETIF_F_RXCSUM;
>>>>                 netdev->hw_enc_features |= NETIF_F_TSO;
>>>>                 netdev->hw_enc_features |= NETIF_F_TSO6;
>>>>                 netdev->hw_enc_features |= NETIF_F_RXHASH;
>>>>                 netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL;
>>>> +               netdev->hw_enc_features |= NETIF_F_GSO_UDP_TUNNEL_CSUM |
>>>> +                                          NETIF_F_GSO_PARTIAL;
>>>> +               netdev->gso_partial_features = NETIF_F_GSO_UDP_TUNNEL_CSUM;
>>>>         }
>>>>
>>>>         netdev->features          = netdev->hw_features;
>>>>
>>>
>>> Hi Alex,
>>>
>>> Adding Matt, VxLAN feature owner from Mellanox,
>>> Matt please correct me if am wrong, but We already tested GSO VxLAN
>>> and we saw the TCP/IP checksum offloads for both inner and outer
>>> headers handled by the hardware.
>>>
>>> And looking at mlx5e_sq_xmit:
>>>
>>> if (likely(skb->ip_summed == CHECKSUM_PARTIAL)) {
>>>         eseg->cs_flags = MLX5_ETH_WQE_L3_CSUM;
>>> if (skb->encapsulation) {
>>>         eseg->cs_flags |= MLX5_ETH_WQE_L3_INNER_CSUM |
>>> MLX5_ETH_WQE_L4_INNER_CSUM;
>>>         sq->stats.csum_offload_inner++;
>>> } else {
>>>         eseg->cs_flags |= MLX5_ETH_WQE_L4_CSUM;
>>> }
>>>
>>> We enable inner/outer hardware checksumming unconditionally without
>>> looking at the features Alex is suggesting in this patch,
>>> Alex, can you elaborate more on the meaning of those features ? and
>>> why would it work for us without declaring them ?
>>
>>Well right now the feature list exposed by the device indicates that
>>TSO is not used if a VxLAN tunnel has a checksum in an outer header.
>>Since that is not exposed currently that is completely offloaded in
>>software via GSO.
>
> The mlx5 hardware requires the outer UDP checksum is not set when offloading encapsulated packets.

The Intel documentation said the same thing.  That was due to the fact
that the hardware didn't computer the outer UDP header checksum.  I
suspect the Mellanox hardware has the same issue.  Also I have tested
on a ConnectX-4 board with the latest firmware and what I am seeing is
that with my patches applied the outer checksum is being correctly
applied for segmentation offloads.

My thought is that that the hardware appears to ignore the UDP
checksum so if it is non-zero you cannot guarantee the checksum would
be correct on the last frame if it is a different size than the rest
of the segments.  In the case of these patches that issue has been
resolved as I have precomputed the UDP checksum for the outer UDP
header and all of the segments will be the same length so there should
be no variation in the UDP checksum of the outer header.  Unless you
can tell my exactly the reason why we cannot provide the outer UDP
checksum I would assume that the reason is due to the fact that the
hardware doesn't compute it so you cannot handle a fragment on the end
which is resolved already via GSO_PARTIAL.

- Alex
