From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon as
	possible after transfer
Date: Fri, 4 Jun 2010 11:29:44 +0800
Message-ID: <AANLkTik4aWREeblhnbI3DU7a_CE11Rx0GvXi56O2yHzy@mail.gmail.com>
References: <1275536881.18536.5.camel@eight.analog.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>,
	uclinux-dist-devel <uclinux-dist-devel@blackfin.uclinux.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pw0-f46.google.com ([209.85.160.46]:42275 "EHLO
	mail-pw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757105Ab0FDD3p convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Jun 2010 23:29:45 -0400
Received: by pwj2 with SMTP id 2so392546pwj.19
        for <netdev@vger.kernel.org>; Thu, 03 Jun 2010 20:29:45 -0700 (PDT)
In-Reply-To: <1275536881.18536.5.camel@eight.analog.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David,

Any comments?

Thanks

Sonic

On Thu, Jun 3, 2010 at 11:48 AM, sonic zhang <sonic.adi@gmail.com> wrot=
e:
> >From 40560ae9e8db42e2d2259b791ace160534c9a0f2 Mon Sep 17 00:00:00 20=
01
> From: Sonic Zhang <sonic.zhang@analog.com>
> Date: Thu, 3 Jun 2010 11:44:33 +0800
> Subject: [PATCH v2] netdev:bfin_mac: reclaim and free tx skb as soon =
as possible after transfer
>
> SKBs hold onto resources that can't be held indefinitely, such as TCP
> socket references and netfilter conntrack state. =A0So if a packet is=
 left
> in TX ring for a long time, there might be a TCP socket that cannot b=
e
> closed and freed up.
>
> Current blackfin EMAC driver always reclaim and free used tx skbs in =
future
> transfers. The problem is that future transfer may not come as soon a=
s
> possible. This patch start a timer after transfer to reclaim and free=
 skb.
> There is nearly no performance drop with this patch.
>
> TX interrupt is not enabled for 2 reasons:
>
> 1) If Blackfin EMAC TX transfer control is turned on, endless TX
> interrupts are triggered no matter if TX DMA is enabled. Since DMA wa=
lks
> down the ring automatically, TX transfer control can't be turned off =
in the
> middle. The only way is to disable TX interrupt completely.
>
> 2) skb can not be freed from interrupt context. A work queue or taskl=
et
> has to be created, which introduce more overhead than timer only solu=
tion.
>
> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
> ---
> =A0drivers/net/bfin_mac.c | =A0114 ++++++++++++++++++++++++++++++----=
--------------
> =A0drivers/net/bfin_mac.h | =A0 =A05 ++
> =A02 files changed, 77 insertions(+), 42 deletions(-)
>
> diff --git a/drivers/net/bfin_mac.c b/drivers/net/bfin_mac.c
> index 368f333..6f0755f 100644
> --- a/drivers/net/bfin_mac.c
> +++ b/drivers/net/bfin_mac.c
> @@ -922,61 +922,73 @@ static void bfin_mac_hwtstamp_init(struct net_d=
evice *netdev)
> =A0# define bfin_tx_hwtstamp(dev, skb)
> =A0#endif
>
> -static void adjust_tx_list(void)
> +static inline void _tx_reclaim_skb(void)
> +{
> + =A0 =A0 =A0 do {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head->desc_a.config &=3D ~DMAEN=
;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head->status.status_word =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_list_head->skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(tx_list_h=
ead->skb);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head->skb =3D N=
ULL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head =3D tx_list_head->next;
> +
> + =A0 =A0 =A0 } while (tx_list_head->status.status_word !=3D 0);
> +}
> +
> +static void tx_reclaim_skb(struct bfin_mac_local *lp)
> =A0{
> =A0 =A0 =A0 =A0int timeout_cnt =3D MAX_TIMEOUT_CNT;
>
> - =A0 =A0 =A0 if (tx_list_head->status.status_word !=3D 0 &&
> - =A0 =A0 =A0 =A0 =A0 current_tx_ptr !=3D tx_list_head) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto adjust_head; =A0 =A0 =A0 /* releas=
ed something, just return; */
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (tx_list_head->status.status_word !=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 _tx_reclaim_skb();
>
> - =A0 =A0 =A0 /*
> - =A0 =A0 =A0 =A0* if nothing released, check wait condition
> - =A0 =A0 =A0 =A0* current's next can not be the head,
> - =A0 =A0 =A0 =A0* otherwise the dma will not stop as we want
> - =A0 =A0 =A0 =A0*/
> - =A0 =A0 =A0 if (current_tx_ptr->next->next =3D=3D tx_list_head) {
> + =A0 =A0 =A0 if (current_tx_ptr->next =3D=3D tx_list_head) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0while (tx_list_head->status.status_wor=
d =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* slow down polling to=
 avoid too many queue stop. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0udelay(10);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_list_head->statu=
s.status_word !=3D 0 ||
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 !(bfin_read_DMA=
2_IRQ_STATUS() & DMA_RUN)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto ad=
just_head;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout_cnt-- < 0) =
{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(=
KERN_ERR DRV_NAME
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ": wait=
 for adjust tx list head timeout\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* reclaim skb if DMA i=
s not running. */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(bfin_read_DMA2_IR=
Q_STATUS() & DMA_RUN))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout_cnt-- < 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_list_head->status.status_word !=3D=
 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto adjust_head;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (timeout_cnt >=3D 0)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 _tx_reclaim_skb();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(lp->nd=
ev);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 return;
> + =A0 =A0 =A0 if (current_tx_ptr->next !=3D tx_list_head &&
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_queue_stopped(lp->ndev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(lp->ndev);
> +
> + =A0 =A0 =A0 if (tx_list_head !=3D current_tx_ptr) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* shorten the timer interval if tx que=
ue is stopped */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_queue_stopped(lp->ndev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_reclaim_timer.ex=
pires =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jiffies=
 + (TX_RECLAIM_JIFFIES >> 4);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 else
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_reclaim_timer.ex=
pires =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 jiffies=
 + TX_RECLAIM_JIFFIES;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mod_timer(&lp->tx_reclaim_timer,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 lp->tx_reclaim_timer.ex=
pires);
> + =A0 =A0 =A0 }
>
> -adjust_head:
> - =A0 =A0 =A0 do {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head->desc_a.config &=3D ~DMAEN=
;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head->status.status_word =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (tx_list_head->skb) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_kfree_skb(tx_list_h=
ead->skb);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head->skb =3D N=
ULL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 printk(KERN_ERR DRV_NAM=
E
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0": no sk=
_buff in a transmitted frame!\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 tx_list_head =3D tx_list_head->next;
> - =A0 =A0 =A0 } while (tx_list_head->status.status_word !=3D 0 &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0current_tx_ptr !=3D tx_list_head);
> =A0 =A0 =A0 =A0return;
> +}
>
> +static void tx_reclaim_skb_timeout(unsigned long lp)
> +{
> + =A0 =A0 =A0 tx_reclaim_skb((struct bfin_mac_local *)lp);
> =A0}
>
> =A0static int bfin_mac_hard_start_xmit(struct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0struct=
 net_device *dev)
> =A0{
> + =A0 =A0 =A0 struct bfin_mac_local *lp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0u16 *data;
> =A0 =A0 =A0 =A0u32 data_align =3D (unsigned long)(skb->data) & 0x3;
> =A0 =A0 =A0 =A0union skb_shared_tx *shtx =3D skb_tx(skb);
> @@ -1009,8 +1021,6 @@ static int bfin_mac_hard_start_xmit(struct sk_b=
uff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0skb->len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0current_tx_ptr->desc_a.start_addr =3D
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u32)current_tx_ptr->p=
acket;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (current_tx_ptr->status.status_word =
!=3D 0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 current_tx_ptr->status.=
status_word =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0blackfin_dcache_flush_range(
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u32)current_tx_ptr->p=
acket,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(u32)(current_tx_ptr->=
packet + skb->len + 2));
> @@ -1022,6 +1032,9 @@ static int bfin_mac_hard_start_xmit(struct sk_b=
uff *skb,
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0SSYNC();
>
> + =A0 =A0 =A0 /* always clear status buffer before start tx dma */
> + =A0 =A0 =A0 current_tx_ptr->status.status_word =3D 0;
> +
> =A0 =A0 =A0 =A0/* enable this packet's dma */
> =A0 =A0 =A0 =A0current_tx_ptr->desc_a.config |=3D DMAEN;
>
> @@ -1037,13 +1050,14 @@ static int bfin_mac_hard_start_xmit(struct sk=
_buff *skb,
> =A0 =A0 =A0 =A0bfin_write_EMAC_OPMODE(bfin_read_EMAC_OPMODE() | TE);
>
> =A0out:
> - =A0 =A0 =A0 adjust_tx_list();
> -
> =A0 =A0 =A0 =A0bfin_tx_hwtstamp(dev, skb);
>
> =A0 =A0 =A0 =A0current_tx_ptr =3D current_tx_ptr->next;
> =A0 =A0 =A0 =A0dev->stats.tx_packets++;
> =A0 =A0 =A0 =A0dev->stats.tx_bytes +=3D (skb->len);
> +
> + =A0 =A0 =A0 tx_reclaim_skb(lp);
> +
> =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0}
>
> @@ -1167,8 +1181,11 @@ real_rx:
> =A0#ifdef CONFIG_NET_POLL_CONTROLLER
> =A0static void bfin_mac_poll(struct net_device *dev)
> =A0{
> + =A0 =A0 =A0 struct bfin_mac_local *lp =3D netdev_priv(dev);
> +
> =A0 =A0 =A0 =A0disable_irq(IRQ_MAC_RX);
> =A0 =A0 =A0 =A0bfin_mac_interrupt(IRQ_MAC_RX, dev);
> + =A0 =A0 =A0 tx_reclaim_skb(lp);
> =A0 =A0 =A0 =A0enable_irq(IRQ_MAC_RX);
> =A0}
> =A0#endif =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* CONFIG_N=
ET_POLL_CONTROLLER */
> @@ -1232,12 +1249,20 @@ static int bfin_mac_enable(void)
> =A0/* Our watchdog timed out. Called by the networking layer */
> =A0static void bfin_mac_timeout(struct net_device *dev)
> =A0{
> + =A0 =A0 =A0 struct bfin_mac_local *lp =3D netdev_priv(dev);
> +
> =A0 =A0 =A0 =A0pr_debug("%s: %s\n", dev->name, __func__);
>
> =A0 =A0 =A0 =A0bfin_mac_disable();
>
> + =A0 =A0 =A0 if (timer_pending(&lp->tx_reclaim_timer))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 del_timer(&(lp->tx_reclaim_timer));
> +
> =A0 =A0 =A0 =A0/* reset tx queue */
> - =A0 =A0 =A0 tx_list_tail =3D tx_list_head->next;
> + =A0 =A0 =A0 current_tx_ptr =3D tx_list_head;
> +
> + =A0 =A0 =A0 if (netif_queue_stopped(lp->ndev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(lp->ndev);
>
> =A0 =A0 =A0 =A0bfin_mac_enable();
>
> @@ -1430,6 +1455,7 @@ static int __devinit bfin_mac_probe(struct plat=
form_device *pdev)
> =A0 =A0 =A0 =A0SET_NETDEV_DEV(ndev, &pdev->dev);
> =A0 =A0 =A0 =A0platform_set_drvdata(pdev, ndev);
> =A0 =A0 =A0 =A0lp =3D netdev_priv(ndev);
> + =A0 =A0 =A0 lp->ndev =3D ndev;
>
> =A0 =A0 =A0 =A0/* Grab the MAC address in the MAC */
> =A0 =A0 =A0 =A0*(__le32 *) (&(ndev->dev_addr[0])) =3D cpu_to_le32(bfi=
n_read_EMAC_ADDRLO());
> @@ -1485,6 +1511,10 @@ static int __devinit bfin_mac_probe(struct pla=
tform_device *pdev)
> =A0 =A0 =A0 =A0ndev->netdev_ops =3D &bfin_mac_netdev_ops;
> =A0 =A0 =A0 =A0ndev->ethtool_ops =3D &bfin_mac_ethtool_ops;
>
> + =A0 =A0 =A0 init_timer(&lp->tx_reclaim_timer);
> + =A0 =A0 =A0 lp->tx_reclaim_timer.data =3D (unsigned long)lp;
> + =A0 =A0 =A0 lp->tx_reclaim_timer.function =3D tx_reclaim_skb_timeou=
t;
> +
> =A0 =A0 =A0 =A0spin_lock_init(&lp->lock);
>
> =A0 =A0 =A0 =A0/* now, enable interrupts */
> diff --git a/drivers/net/bfin_mac.h b/drivers/net/bfin_mac.h
> index 1ae7b82..04e4050 100644
> --- a/drivers/net/bfin_mac.h
> +++ b/drivers/net/bfin_mac.h
> @@ -13,9 +13,12 @@
> =A0#include <linux/net_tstamp.h>
> =A0#include <linux/clocksource.h>
> =A0#include <linux/timecompare.h>
> +#include <linux/timer.h>
>
> =A0#define BFIN_MAC_CSUM_OFFLOAD
>
> +#define TX_RECLAIM_JIFFIES (HZ / 5)
> +
> =A0struct dma_descriptor {
> =A0 =A0 =A0 =A0struct dma_descriptor *next_dma_desc;
> =A0 =A0 =A0 =A0unsigned long start_addr;
> @@ -68,6 +71,8 @@ struct bfin_mac_local {
>
> =A0 =A0 =A0 =A0int wol; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Wake On Lan=
 */
> =A0 =A0 =A0 =A0int irq_wake_requested;
> + =A0 =A0 =A0 struct timer_list tx_reclaim_timer;
> + =A0 =A0 =A0 struct net_device *ndev;
>
> =A0 =A0 =A0 =A0/* MII and PHY stuffs */
> =A0 =A0 =A0 =A0int old_link; =A0 =A0 =A0 =A0 =A0/* used by bf537_adju=
st_link */
> --
> 1.6.0
>
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
>
