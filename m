From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH v2 net-next] ixgbe: Avoid unaligned access in ixgbe_atr()
 for LLC packets
Date: Mon, 14 Mar 2016 10:55:45 -0700
Message-ID: <CAKgT0Ucnf7Yyzjp_vccimVmjx-ZbYnOfKoTt6rEEZOsOEhVboQ@mail.gmail.com>
References: <20160314174624.GG5084@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
	Netdev <netdev@vger.kernel.org>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	"Brandeburg, Jesse" <jesse.brandeburg@intel.com>,
	shannon nelson <shannon.nelson@intel.com>,
	Carolyn Wyborny <carolyn.wyborny@intel.com>,
	"Skidmore, Donald C" <donald.c.skidmore@intel.com>,
	Bruce W Allan <bruce.w.allan@intel.com>,
	John Ronciak <john.ronciak@intel.com>,
	Mitch Williams <mitch.a.williams@intel.com>
To: Sowmini Varadhan <sowmini.varadhan@oracle.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f170.google.com ([209.85.213.170]:36489 "EHLO
	mail-ig0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755025AbcCNRzq (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Mar 2016 13:55:46 -0400
Received: by mail-ig0-f170.google.com with SMTP id nk17so45800179igb.1
        for <netdev@vger.kernel.org>; Mon, 14 Mar 2016 10:55:46 -0700 (PDT)
In-Reply-To: <20160314174624.GG5084@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 14, 2016 at 10:46 AM, Sowmini Varadhan
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
> examining first->protocol.
>
> Signed-off-by: Sowmini Varadhan <sowmini.varadhan@oracle.com>
> ---
> v2: Alexander Duyck comments.
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c |    5 +++++
>  1 files changed, 5 insertions(+), 0 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> index 4d6223d..b25e603 100644
> --- a/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> +++ b/drivers/net/ethernet/intel/ixgbe/ixgbe_main.c
> @@ -7574,6 +7574,11 @@ static void ixgbe_atr(struct ixgbe_ring *ring,
>         if (!ring->atr_sample_rate)
>                 return;
>
> +       if (first->protocol != htons(ETH_P_IP) &&
> +           first->protocol != htons(ETH_P_IPV6) &&
> +           first->protocol != htons(ETH_P_ARP))
> +               return;
> +

One other thing I forgot to mention is that we don't support ARP so
that check could be dropped.  The ATR code only supports IPv4 or IPv6
with TCP.

- Alex
