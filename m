From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [PATCH] igb: use igb_adapter->io_addr instead of e1000_hw->hw_addr
Date: Wed, 9 Nov 2016 08:28:34 -0800
Message-ID: <CAKgT0UfA5jcr_1bB1=iVoBJuwLkwagNL_MUeoAq8q=Ep_OATXg@mail.gmail.com>
References: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>,
        =?UTF-8?B?SXp1bWksIFRha3Uv5rOJIOaLkw==?=
        <izumi.taku@jp.fujitsu.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: Cao jin <caoj.fnst@cn.fujitsu.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1478588780-24480-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 7, 2016 at 11:06 PM, Cao jin <caoj.fnst@cn.fujitsu.com> wrote:
> When running as guest, under certain condition, it will oops as following.
> writel() in igb_configure_tx_ring() results in oops, because hw->hw_addr
> is NULL. While other register access won't oops kernel because they use
> wr32/rd32 which have a defense against NULL pointer.
>
>     [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fatal)
>     error received: id=0101
>     [  141.225523] igb 0000:01:00.1: PCIe Bus Error:
>     severity=Uncorrected (Fatal), type=Unaccessible,
>     id=0101(Unregistered Agent ID)
>     [  141.299442] igb 0000:01:00.1: broadcast error_detected message
>     [  141.300539] igb 0000:01:00.0 enp1s0f0: PCIe link lost, device now
>     detached
>     [  141.351019] igb 0000:01:00.1 enp1s0f1: PCIe link lost, device now
>     detached
>     [  143.465904] pcieport 0000:00:1c.0: Root Port link has been reset
>     [  143.465994] igb 0000:01:00.1: broadcast slot_reset message
>     [  143.466039] igb 0000:01:00.0: enabling device (0000 -> 0002)
>     [  144.389078] igb 0000:01:00.1: enabling device (0000 -> 0002)
>     [  145.312078] igb 0000:01:00.1: broadcast resume message
>     [  145.322211] BUG: unable to handle kernel paging request at
>     0000000000003818
>     [  145.361275] IP: [<ffffffffa02fd38d>]
>     igb_configure_tx_ring+0x14d/0x280 [igb]
>     [  145.400048] PGD 0
>     [  145.438007] Oops: 0002 [#1] SMP
>
> A similiar issue & solution could be found at:
>     http://patchwork.ozlabs.org/patch/689592/
>
> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/igb/igb_main.c | 4 ++--
>  1 file changed, 2 insertions(+), 2 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index edc9a6a..3f240ac 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -3390,7 +3390,7 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
>              tdba & 0x00000000ffffffffULL);
>         wr32(E1000_TDBAH(reg_idx), tdba >> 32);
>
> -       ring->tail = hw->hw_addr + E1000_TDT(reg_idx);
> +       ring->tail = adapter->io_addr + E1000_TDT(reg_idx);
>         wr32(E1000_TDH(reg_idx), 0);
>         writel(0, ring->tail);
>
> @@ -3729,7 +3729,7 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
>              ring->count * sizeof(union e1000_adv_rx_desc));
>
>         /* initialize head and tail */
> -       ring->tail = hw->hw_addr + E1000_RDT(reg_idx);
> +       ring->tail = adapter->io_addr + E1000_RDT(reg_idx);
>         wr32(E1000_RDH(reg_idx), 0);
>         writel(0, ring->tail);
>

This patch looks good to me.

Acked-by: Alexander Duyck <alexander.h.duyck@intel.com>
