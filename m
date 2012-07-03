From: Tom Herbert <therbert@google.com>
Subject: Re: [RFC PATCH 00/10] Make XPS usable within ixgbe
Date: Tue, 3 Jul 2012 15:30:33 -0700
Message-ID: <CA+mtBx-ZGFUT6JcxiLcTOMteN1-DS5_eoAC5CgU7UEFup1FaqQ@mail.gmail.com>
References: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	jeffrey.t.kirsher@intel.com, edumazet@google.com,
	bhutchings@solarflare.com, alexander.duyck@gmail.com
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:41966 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751913Ab2GCWae (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Jul 2012 18:30:34 -0400
Received: by yhmm54 with SMTP id m54so6667611yhm.19
        for <netdev@vger.kernel.org>; Tue, 03 Jul 2012 15:30:34 -0700 (PDT)
In-Reply-To: <20120630000652.29939.11108.stgit@gitlad.jf.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Alexander,

Thanks for this work!

Some general comments:

1) skb_tx_hash is called from a handful of drivers (bnx2x, ixgbe,
mlx4, and bonding).  Would it make sent to call xps_get_cpu from that
function (unfortunately the use of ndo_select_queue is likely
bypassing xps unnecessarily in these drivers).
2) Instead of (or maybe in addition to) allowing driver to program xps
maps, we could parameterize get_xps_cpu to optionally include a bit
map of acceptable queues.  This would be useful to define a
hierarchical queue selection (like first choose a set for QoS, then
amongst those chose one base on xps).

Tom

On Fri, Jun 29, 2012 at 5:16 PM, Alexander Duyck
<alexander.h.duyck@intel.com> wrote:
> The following patch series makes it so that the ixgbe driver can support
> ATR even when the number of queues is less than the number of CPUs.  To do
> this I have updated the kernel to support letting drivers set their own XPS
> configuration.  To do this it was necessary to move the code out of the
> sysfs specific code and into the dev specific regions.
>
> I am still working out a few issues such as the fact that with routing I
> only ever seem to be able to get the first queue that is mapped to the CPU
> when XPS is enabled.
>
> Also I am looking for input on if it is acceptable to only let the
> set_channels/get_channels calls report/set the number of queues per traffic
> class as I implemented the code this way to avoid any significant conflicts
> between the DCB traffic classes code and these functions.
>
> ---
>
> Alexander Duyck (10):
>       ixgbe: Add support for set_channels ethtool operation
>       ixgbe: Add support for displaying the number of Tx/Rx channels
>       ixgbe: Update ixgbe driver to use __dev_pick_tx in ixgbe_select_queue
>       ixgbe: Add function for setting XPS queue mapping
>       ixgbe: Define FCoE and Flow director limits much sooner to allow for changes
>       net: Add support for XPS without SYSFS being defined
>       net: Rewrite netif_set_xps_queues to address several issues
>       net: Rewrite netif_reset_xps_queue to allow for better code reuse
>       net: Add functions netif_reset_xps_queue and netif_set_xps_queue
>       net: Split core bits of dev_pick_tx into __dev_pick_tx
>
>
>  drivers/net/ethernet/intel/ixgbe/ixgbe_ethtool.c |  112 +++++++++
>  drivers/net/ethernet/intel/ixgbe/ixgbe_lib.c     |   10 -
>  drivers/net/ethernet/intel/ixgbe/ixgbe_main.c    |   48 +++-
>  include/linux/netdevice.h                        |   15 +
>  net/Kconfig                                      |    2
>  net/core/dev.c                                   |  283 ++++++++++++++++++++--
>  net/core/net-sysfs.c                             |  160 ------------
>  7 files changed, 428 insertions(+), 202 deletions(-)
>
> --
> Thanks,
>
> Alex
