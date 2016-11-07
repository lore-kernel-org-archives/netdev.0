From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [Intel-wired-lan] [PATCH] igb: drop field "tail" of struct igb_ring
Date: Mon, 7 Nov 2016 10:49:16 -0800
Message-ID: <CAKgT0UcHutO9kotxN2-MTH=rrB1PjmyMdjyeT4PkYbBXkBquFw@mail.gmail.com>
References: <1478522697-4773-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        Netdev <netdev@vger.kernel.org>,
        =?UTF-8?B?SXp1bWksIFRha3Uv5rOJIOaLkw==?=
        <izumi.taku@jp.fujitsu.com>,
        intel-wired-lan <intel-wired-lan@lists.osuosl.org>
To: Cao jin <caoj.fnst@cn.fujitsu.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f65.google.com ([209.85.214.65]:35687 "EHLO
        mail-it0-f65.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933504AbcKGStS (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 7 Nov 2016 13:49:18 -0500
In-Reply-To: <1478522697-4773-1-git-send-email-caoj.fnst@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 7, 2016 at 4:44 AM, Cao jin <caoj.fnst@cn.fujitsu.com> wrote:
> Under certain condition, I find guest will oops on writel() in
> igb_configure_tx_ring(), because hw->hw_address is NULL. While other
> register access won't oops kernel because they use wr32/rd32 which have
> a defense against NULL pointer. The oops message are as following:
>
>     [  141.225449] pcieport 0000:00:1c.0: AER: Multiple Uncorrected (Fatal)
>     error received: id=0101
>     [  141.225523] igb 0000:01:00.1: PCIe Bus Error: severity=Uncorrected
>     (Fatal), type=Unaccessible, id=0101(Unregistered Agent ID)
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
>     [  145.361275] IP: [<ffffffffa02fd38d>] igb_configure_tx_ring+0x14d/0x280 [igb]
>     [  145.438007] Oops: 0002 [#1] SMP
>
> On the other hand, commit 238ac817 does some optimization which
> dropped the field "head". So I think it is time to drop "tail" as well.

There is a bug here, but removing tail isn't the fix.

> Signed-off-by: Cao jin <caoj.fnst@cn.fujitsu.com>
> ---
>  drivers/net/ethernet/intel/igb/igb.h      |  1 -
>  drivers/net/ethernet/intel/igb/igb_main.c | 16 +++++++++-------
>  2 files changed, 9 insertions(+), 8 deletions(-)
>
> diff --git a/drivers/net/ethernet/intel/igb/igb.h b/drivers/net/ethernet/intel/igb/igb.h
> index d11093d..0df06bc 100644
> --- a/drivers/net/ethernet/intel/igb/igb.h
> +++ b/drivers/net/ethernet/intel/igb/igb.h
> @@ -247,7 +247,6 @@ struct igb_ring {
>         };
>         void *desc;                     /* descriptor ring memory */
>         unsigned long flags;            /* ring specific flags */
> -       void __iomem *tail;             /* pointer to ring tail register */
>         dma_addr_t dma;                 /* phys address of the ring */
>         unsigned int  size;             /* length of desc. ring in bytes */
>
> diff --git a/drivers/net/ethernet/intel/igb/igb_main.c b/drivers/net/ethernet/intel/igb/igb_main.c
> index edc9a6a..e177d0e 100644
> --- a/drivers/net/ethernet/intel/igb/igb_main.c
> +++ b/drivers/net/ethernet/intel/igb/igb_main.c
> @@ -3390,9 +3390,8 @@ void igb_configure_tx_ring(struct igb_adapter *adapter,
>              tdba & 0x00000000ffffffffULL);
>         wr32(E1000_TDBAH(reg_idx), tdba >> 32);
>
> -       ring->tail = hw->hw_addr + E1000_TDT(reg_idx);

This line is where the bug is.  This should be adapter->io_addr, not
hw->hw_addr.

>         wr32(E1000_TDH(reg_idx), 0);
> -       writel(0, ring->tail);
> +        wr32(E1000_TDT(reg_idx), 0);
>
>         txdctl |= IGB_TX_PTHRESH;
>         txdctl |= IGB_TX_HTHRESH << 8;
> @@ -3729,9 +3728,8 @@ void igb_configure_rx_ring(struct igb_adapter *adapter,
>              ring->count * sizeof(union e1000_adv_rx_desc));
>
>         /* initialize head and tail */
> -       ring->tail = hw->hw_addr + E1000_RDT(reg_idx);

Same thing here.  It looks like the wrong values where used.

>         wr32(E1000_RDH(reg_idx), 0);
> -       writel(0, ring->tail);
> +       wr32(E1000_RDT(reg_idx), 0);
>
>         /* set descriptor configuration */

Would you prefer to submit the patch for this or should I?  Basically
all you need to do is change the two lines where ring->tail is
populated so that you use adapter->io_addr instead of hw->hw_addr.

Thanks.

- Alex
