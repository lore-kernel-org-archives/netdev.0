From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] igb: Fix TX map failure path
Date: Thu, 19 Oct 2017 12:58:30 -0700
Message-ID: <CAKgT0UejqsfLmt+2kkCkU8oy80xdJE5mYvmDujF1kfR8TesBsA@mail.gmail.com>
References: <20171019190736.2770-1-jean-philippe.brucker@arm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        Netdev <netdev@vger.kernel.org>
To: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f195.google.com ([209.85.220.195]:44224 "EHLO
        mail-qk0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751496AbdJST6b (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Oct 2017 15:58:31 -0400
Received: by mail-qk0-f195.google.com with SMTP id r64so11856277qkc.1
        for <netdev@vger.kernel.org>; Thu, 19 Oct 2017 12:58:31 -0700 (PDT)
In-Reply-To: <20171019190736.2770-1-jean-philippe.brucker@arm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Oct 19, 2017 at 12:07 PM, Jean-Philippe Brucker
<jean-philippe.brucker@arm.com> wrote:
> When the driver cannot map a TX buffer, instead of rolling back
> gracefully and retrying later, we currently get a panic:
>
> [  159.885994] igb 0000:00:00.0: TX DMA map failed
> [  159.886588] Unable to handle kernel paging request at virtual address ffff00000a08c7a8
>                ...
> [  159.897031] PC is at igb_xmit_frame_ring+0x9c8/0xcb8
>
> Fix the erroneous test that leads to this situation.
>
> Signed-off-by: Jean-Philippe Brucker <jean-philippe.brucker@arm.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 2 +-
>  1 file changed, 1 insertion(+), 1 deletion(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index fd4a46b03cc8..ea69af267d63 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -5326,7 +5326,7 @@ static int igb_tx_map(struct igb_ring *tx_ring,
>                                        DMA_TO_DEVICE);
>                 dma_unmap_len_set(tx_buffer, len, 0);
>
> -               if (i--)
> +               if (i-- == 0)
>                         i += tx_ring->count;
>                 tx_buffer = &tx_ring->tx_buffer_info[i];
>         }

The fix looks fine to me, though I will probably want to go back and
update the code to simplify this since I realize part of the issue is
that there is a bunch of unneeded complexity I introduced here. It
looks like we have the same problem in ixgbe that needs to be
addressed as well.

Fixes: 7cc6fd4c60f2 ("igb: Don't bother clearing Tx buffer_info in
igb_clean_tx_ring")
Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
