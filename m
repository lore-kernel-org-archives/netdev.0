From: Denis Kirjanov <kirjanov@gmail.com>
Subject: Re: [PATCH 2/2 -next] r8169: use device model DMA API
Date: Thu, 23 Sep 2010 18:59:10 +0400
Message-ID: <AANLkTin-GPjkpp3gmS=1u5wxmxFMy_B6GL1MuDR79fDQ@mail.gmail.com>
References: <1285243291-4520-1-git-send-email-sgruszka@redhat.com>
	<1285243291-4520-2-git-send-email-sgruszka@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
To: Stanislaw Gruszka <sgruszka@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f46.google.com ([209.85.210.46]:34712 "EHLO
	mail-pz0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752938Ab0IWO73 convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Sep 2010 10:59:29 -0400
Received: by pzk34 with SMTP id 34so426019pzk.19
        for <netdev@vger.kernel.org>; Thu, 23 Sep 2010 07:59:28 -0700 (PDT)
In-Reply-To: <1285243291-4520-2-git-send-email-sgruszka@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Sep 23, 2010 at 4:01 PM, Stanislaw Gruszka <sgruszka@redhat.com=
> wrote:
> Use DMA API as PCI equivalents will be deprecated. This change also
> allow to allocate with GFP_KERNEL where possible.
>
> Signed-off-by: Stanislaw Gruszka <sgruszka@redhat.com>
> ---

dma_map_single and friend can fail. Thus, we should check for a return =
value.
Yes, this is not directly related to current patch, but it would be
great to fix this.

> =A0drivers/net/r8169.c | =A0 53 +++++++++++++++++++++++++++----------=
-------------
> =A01 files changed, 29 insertions(+), 24 deletions(-)
>
> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
> index 4f94073..51dd9ac 100644
> --- a/drivers/net/r8169.c
> +++ b/drivers/net/r8169.c
> @@ -1217,7 +1217,8 @@ static void rtl8169_update_counters(struct net_=
device *dev)
> =A0 =A0 =A0 =A0if ((RTL_R8(ChipCmd) & CmdRxEnb) =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> - =A0 =A0 =A0 counters =3D pci_alloc_consistent(tp->pci_dev, sizeof(*=
counters), &paddr);
> + =A0 =A0 =A0 counters =3D dma_alloc_coherent(&tp->pci_dev->dev, size=
of(*counters),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 &paddr, GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!counters)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> @@ -1238,7 +1239,8 @@ static void rtl8169_update_counters(struct net_=
device *dev)
> =A0 =A0 =A0 =A0RTL_W32(CounterAddrLow, 0);
> =A0 =A0 =A0 =A0RTL_W32(CounterAddrHigh, 0);
>
> - =A0 =A0 =A0 pci_free_consistent(tp->pci_dev, sizeof(*counters), cou=
nters, paddr);
> + =A0 =A0 =A0 dma_free_coherent(&tp->pci_dev->dev, sizeof(*counters),=
 counters,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 paddr);
> =A0}
>
> =A0static void rtl8169_get_ethtool_stats(struct net_device *dev,
> @@ -3298,15 +3300,15 @@ static int rtl8169_open(struct net_device *de=
v)
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Rx and Tx desscriptors needs 256 bytes alignment.
> - =A0 =A0 =A0 =A0* pci_alloc_consistent provides more.
> + =A0 =A0 =A0 =A0* dma_alloc_coherent provides more.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 tp->TxDescArray =3D pci_alloc_consistent(pdev, R8169_TX=
_RING_BYTES,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0&tp->TxPhyAddr);
> + =A0 =A0 =A0 tp->TxDescArray =3D dma_alloc_coherent(&pdev->dev, R816=
9_TX_RING_BYTES,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0&tp->TxPhyAddr, GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!tp->TxDescArray)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_pm_runtime_put;
>
> - =A0 =A0 =A0 tp->RxDescArray =3D pci_alloc_consistent(pdev, R8169_RX=
_RING_BYTES,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0&tp->RxPhyAddr);
> + =A0 =A0 =A0 tp->RxDescArray =3D dma_alloc_coherent(&pdev->dev, R816=
9_RX_RING_BYTES,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0&tp->RxPhyAddr, GFP_KERNEL);
> =A0 =A0 =A0 =A0if (!tp->RxDescArray)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto err_free_tx_0;
>
> @@ -3340,12 +3342,12 @@ out:
> =A0err_release_ring_2:
> =A0 =A0 =A0 =A0rtl8169_rx_clear(tp);
> =A0err_free_rx_1:
> - =A0 =A0 =A0 pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDe=
scArray,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->RxPhyAddr);
> + =A0 =A0 =A0 dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->=
RxDescArray,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->RxPhyAddr);
> =A0 =A0 =A0 =A0tp->RxDescArray =3D NULL;
> =A0err_free_tx_0:
> - =A0 =A0 =A0 pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDe=
scArray,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->TxPhyAddr);
> + =A0 =A0 =A0 dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->=
TxDescArray,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->TxPhyAddr);
> =A0 =A0 =A0 =A0tp->TxDescArray =3D NULL;
> =A0err_pm_runtime_put:
> =A0 =A0 =A0 =A0pm_runtime_put_noidle(&pdev->dev);
> @@ -3981,7 +3983,7 @@ static void rtl8169_free_rx_skb(struct rtl8169_=
private *tp,
> =A0{
> =A0 =A0 =A0 =A0struct pci_dev *pdev =3D tp->pci_dev;
>
> - =A0 =A0 =A0 pci_unmap_single(pdev, le64_to_cpu(desc->addr), tp->rx_=
buf_sz,
> + =A0 =A0 =A0 dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), t=
p->rx_buf_sz,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_FROMDEVICE);
> =A0 =A0 =A0 =A0dev_kfree_skb(*sk_buff);
> =A0 =A0 =A0 =A0*sk_buff =3D NULL;
> @@ -4020,7 +4022,7 @@ static struct sk_buff *rtl8169_alloc_rx_skb(str=
uct pci_dev *pdev,
>
> =A0 =A0 =A0 =A0skb_reserve(skb, align ? ((pad - 1) & (unsigned long)s=
kb->data) : pad);
>
> - =A0 =A0 =A0 mapping =3D pci_map_single(pdev, skb->data, rx_buf_sz,
> + =A0 =A0 =A0 mapping =3D dma_map_single(&pdev->dev, skb->data, rx_bu=
f_sz,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_D=
MA_FROMDEVICE);
>
> =A0 =A0 =A0 =A0rtl8169_map_to_asic(desc, mapping, rx_buf_sz);
> @@ -4105,7 +4107,8 @@ static void rtl8169_unmap_tx_skb(struct pci_dev=
 *pdev, struct ring_info *tx_skb,
> =A0{
> =A0 =A0 =A0 =A0unsigned int len =3D tx_skb->len;
>
> - =A0 =A0 =A0 pci_unmap_single(pdev, le64_to_cpu(desc->addr), len, PC=
I_DMA_TODEVICE);
> + =A0 =A0 =A0 dma_unmap_single(&pdev->dev, le64_to_cpu(desc->addr), l=
en,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PCI_DMA_TODEVICE);
> =A0 =A0 =A0 =A0desc->opts1 =3D 0x00;
> =A0 =A0 =A0 =A0desc->opts2 =3D 0x00;
> =A0 =A0 =A0 =A0desc->addr =3D 0x00;
> @@ -4249,7 +4252,8 @@ static int rtl8169_xmit_frags(struct rtl8169_pr=
ivate *tp, struct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0txd =3D tp->TxDescArray + entry;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0len =3D frag->size;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0addr =3D ((void *) page_address(frag->=
page)) + frag->page_offset;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping =3D pci_map_single(tp->pci_dev,=
 addr, len, PCI_DMA_TODEVICE);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mapping =3D dma_map_single(&tp->pci_dev=
->dev, addr, len,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0PCI_DMA_TODEVICE);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* anti gcc 2.95.3 bugware (sic) */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0status =3D opts1 | len | (RingEnd * !(=
(entry + 1) % NUM_TX_DESC));
> @@ -4319,7 +4323,8 @@ static netdev_tx_t rtl8169_start_xmit(struct sk=
_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->tx_skb[entry].skb =3D skb;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 mapping =3D pci_map_single(tp->pci_dev, skb->data, len,=
 PCI_DMA_TODEVICE);
> + =A0 =A0 =A0 mapping =3D dma_map_single(&tp->pci_dev->dev, skb->data=
, len,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0PCI_=
DMA_TODEVICE);
>
> =A0 =A0 =A0 =A0tp->tx_skb[entry].len =3D len;
> =A0 =A0 =A0 =A0txd->addr =3D cpu_to_le64(mapping);
> @@ -4482,8 +4487,8 @@ static inline bool rtl8169_try_rx_copy(struct s=
k_buff **sk_buff,
> =A0 =A0 =A0 =A0if (!skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto out;
>
> - =A0 =A0 =A0 pci_dma_sync_single_for_cpu(tp->pci_dev, addr, pkt_size=
,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 PCI_DMA_FROMDEVICE);
> + =A0 =A0 =A0 dma_sync_single_for_cpu(&tp->pci_dev->dev, addr, pkt_si=
ze,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA=
_FROMDEVICE);
> =A0 =A0 =A0 =A0skb_copy_from_linear_data(*sk_buff, skb->data, pkt_siz=
e);
> =A0 =A0 =A0 =A0*sk_buff =3D skb;
> =A0 =A0 =A0 =A0done =3D true;
> @@ -4552,11 +4557,11 @@ static int rtl8169_rx_interrupt(struct net_de=
vice *dev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rtl8169_try_rx_cop=
y(&skb, tp, pkt_size, addr)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_dma=
_sync_single_for_device(pdev, addr,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_syn=
c_single_for_device(&pdev->dev, addr,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0pkt_size, PCI_DMA_FROMDEVICE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rtl816=
9_mark_to_asic(desc, tp->rx_buf_sz);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_unm=
ap_single(pdev, addr, tp->rx_buf_sz,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_unm=
ap_single(&pdev->dev, addr, tp->rx_buf_sz,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 PCI_DMA_FROMDEVICE);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0tp->Rx=
_skbuff[entry] =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -4774,10 +4779,10 @@ static int rtl8169_close(struct net_device *d=
ev)
>
> =A0 =A0 =A0 =A0free_irq(dev->irq, dev);
>
> - =A0 =A0 =A0 pci_free_consistent(pdev, R8169_RX_RING_BYTES, tp->RxDe=
scArray,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->RxPhyAddr);
> - =A0 =A0 =A0 pci_free_consistent(pdev, R8169_TX_RING_BYTES, tp->TxDe=
scArray,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->TxPhyAddr);
> + =A0 =A0 =A0 dma_free_coherent(&pdev->dev, R8169_RX_RING_BYTES, tp->=
RxDescArray,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->RxPhyAddr);
> + =A0 =A0 =A0 dma_free_coherent(&pdev->dev, R8169_TX_RING_BYTES, tp->=
TxDescArray,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tp->TxPhyAddr);
> =A0 =A0 =A0 =A0tp->TxDescArray =3D NULL;
> =A0 =A0 =A0 =A0tp->RxDescArray =3D NULL;
>
> --
> 1.7.0.1
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>



--=20
Regards,
Denis
