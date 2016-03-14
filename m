From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH net-next] ixgbe: Avoid unaligned access
 in ixgbe_atr() for LLC packets
Date: Mon, 14 Mar 2016 10:12:49 -0700
Message-ID: <CAKgT0UfWuv1sui0ZDv3Qy1YnydzBMURF1ptr1XSxz_UE_g=1Fg@mail.gmail.com>
References: <20160314153216.GF5084@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:35543 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752012AbcCNRMu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:12:50 -0400
Received: by mail-ig0-f180.google.com with SMTP id vf5so66577687igb.0
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 10:12:50 -0700 (PDT)
In-Reply-To: <20160314153216.GF5084@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 8:32 AM, Sowmini Varadhan
<sowmini.varadhan@oracle.com> wrote:
>
> For LLC based protocols like lldp, stp etc., the ethernet header
> is an 802.3 header with a h_proto that is not 0x800, 0x86dd, or
> even 0x806.  In this world, the skb_network_header() points at
> the DSAP/SSAP/..  and is not likely to be NET_IP_ALIGNed in
> ixgbe_atr().
>
> With LLC, drivers are not likely to correctly find IPVERSION,
> or "6", at hdr.ipv4->version, but will instead just needlessly
> trigger an unaligned access. (IPv4/IPv6 over LLC is almost never
> implemented).
>
> The unaligned access is thus avoidable: bail out quickly after
> examining skb->protocol.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 4d6223d..c3885a8 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7602,6 +7602,11 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
>  #endif /* CONFIG_IXGBE_VXLAN */
>         }
>
> +       if (skb->protocol != htons(ETH_P_IP) &&
> +           skb->protocol != htons(ETH_P_IPV6) &&
> +           skb->protocol != htons(ETH_P_ARP))
> +               return;
> +

This is disabling too much as it snags VLAN along with everything
else.  Replace skb->protocol with first->protocol and this should work
correctly.

You may also want to move it up by several lines so that you don't
count it as a valid ATR frame via atr_count.

Thanks.

- Alex
