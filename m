From: Debashis Dutt <ddutt@Brocade.COM>
Subject: RE: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver
Date: Fri, 6 Aug 2010 20:23:21 -0700
Message-ID: <F363E7AC84E1B646A0358B281A46F4AEA9A0F6565F@HQ1-EXCH03.corp.brocade.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Stephen Hemminger <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:35663 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752469Ab0HGDXX convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Aug 2010 23:23:23 -0400
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Hi Stephen,=20

Thanks a lot for your comments.=20

> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (likely
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 (wi=
s > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0 =
vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 BNAD_UPDATE_CTR(bnad, netif_queue_stop);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 return NETDEV_TX_BUSY;

>The transmit routine should check for available space after
> queueing to device, so you can avoid having to return
>TX_BUSY.

However your above comment is not very clear to me.

Our Tx routine already cleans up the Tx buffers at the end, through a t=
asklet.

Cleaning of Tx buffers happens=20
1) In the sending context at the end of the Tx routine.
2) In the IRQ context when we get a Tx completion interrupt.

Only thing that we could have done, is do this check again at the end o=
f the Tx routine
and called netif_stop_queue() if required, so that the stack stops send=
ing. Even then I am=20
not sure that we could avoid the current check and returning TX_BUSY.

It would be nice if you clarify, so that I understand this better.

Thanks
--Debashis
Linux LL Driver Team.


-----Original Message-----
=46rom: Stephen Hemminger [mailto:shemminger@vyatta.com]=20
Sent: Wednesday, August 04, 2010 10:09 AM
To: Rasesh Mody
Cc: netdev@vger.kernel.org; Debashis Dutt; Jing Huang
Subject: Re: [PATCH 1/6] bna: Brocade 10Gb Ethernet device driver

On Tue, 3 Aug 2010 22:15:36 -0700
Rasesh Mody <rmody@brocade.com> wrote:

> From: Rasesh Mody <rmody@brocade.com>
>=20
> This is patch 1/6 which contains linux driver source for
> Brocade's BR1010/BR1020 10Gb CEE capable ethernet adapter.
> Source is based against net-next-2.6.
>=20
> We wish this patch to be considered for inclusion in net-next-2.6
>=20
> Signed-off-by: Rasesh Mody <rmody@brocade.com>
> ---
>=A0 bnad.c=A0=A0=A0=A0=A0=A0=A0=A0 | 3326 ++++++++++++++++++++++++++++=
+++++++++++++++++++++++++++++
>=A0 bnad.h=A0=A0=A0=A0=A0=A0=A0=A0 |=A0 474 ++++++++
>=A0 bnad_ethtool.c | 1269 +++++++++++++++++++++
>=A0 3 files changed, 5069 insertions(+)
>=20
> diff -ruP net-next-2.6.35-rc1-orig/drivers/net/bna/bnad.c net-next-2.=
6.35-rc1-mod/drivers/net/bna/bnad.c
> --- net-next-2.6.35-rc1-orig/drivers/net/bna/bnad.c=A0=A0=A0=A0=A0=A0=
=A0=A0 1969-12-31 16:00:00.000000000 -0800
> +++ net-next-2.6.35-rc1-mod/drivers/net/bna/bnad.c=A0=A0=A0=A0 2010-0=
8-02 17:19:19.447239000 -0700
> @@ -0,0 +1,3326 @@
> +/*
> + * Linux network driver for Brocade Converged Network Adapter.
> + *
> + * This program is free software; you can redistribute it and/or mod=
ify it
> + * under the terms of the GNU General Public License (GPL) Version 2=
 as
> + * published by the Free Software Foundation
> + *
> + * This program is distributed in the hope that it will be useful, b=
ut
> + * WITHOUT ANY WARRANTY; without even the implied warranty of
> + * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.=A0 See the G=
NU
> + * General Public License for more details.
> + */
> +/*
> + * Copyright (c) 2005-2009 Brocade Communications Systems, Inc.
> + * All rights reserved
> + * www.brocade.com
> + */
> +#include <linux/netdevice.h>
> +#include <linux/skbuff.h>
> +#include <linux/etherdevice.h>
> +#include <linux/in.h>
> +#include <linux/ethtool.h>
> +#include <linux/if_vlan.h>
> +#include <linux/if_ether.h>
> +#include <linux/ip.h>
> +
> +#include "bnad.h"
> +#include "bna.h"
> +#include "cna.h"
> +
> +DEFINE_MUTEX(bnad_fwimg_mutex);
> +
> +/*
> + * Module params
> + */
> +static uint bnad_msix_disable;
> +module_param(bnad_msix_disable, uint, 0444);
> +MODULE_PARM_DESC(bnad_msix_disable, "Disable MSIX mode");
> +
> +static uint bnad_ioc_auto_recover =3D 1;
> +module_param(bnad_ioc_auto_recover, uint, 0444);
> +MODULE_PARM_DESC(bnad_ioc_auto_recover, "Enable / Disable auto recov=
ery");
> +
> +/*
> + * Global variables
> + */
> +u32 bna_id;
> +u32 bnad_rxqs_per_cq =3D 2;
> +
> +DECLARE_MUTEX(bnad_list_sem);
> +LIST_HEAD(bnad_list);
> +
> +const u8 bnad_bcast_addr[] =3D=A0 {0xff, 0xff, 0xff, 0xff, 0xff, 0xf=
f};

Surprised this isn't defined somewhere else.

> +
> +/*
> + * Local MACROS
> + */
> +#define BNAD_TX_UNMAPQ_DEPTH (bnad->txq_depth * 2)
> +
> +#define BNAD_RX_UNMAPQ_DEPTH (bnad->rxq_depth)
> +
> +#define BNAD_GET_MBOX_IRQ(_bnad)=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 (((_bnad)->cfg_flags & BNAD_CF_MSIX) ?=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 ((_bnad)->msix_table[(_bnad)->msix_num - 1].vecto=
r) : =A0 \
> +=A0=A0=A0=A0=A0=A0 ((_bnad)->pcidev->irq))
> +
> +#define BNAD_FILL_UNMAPQ_MEM_REQ(_res_info, _num, _depth)=A0 \
> +do {=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 (_res_info)->res_type =3D BNA_RES_T_MEM;=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 (_res_info)->res_u.mem_info.mem_type =3D BNA_MEM_=
T_KVA;=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 (_res_info)->res_u.mem_info.num =3D (_num);=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 (_res_info)->res_u.mem_info.len =3D=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 sizeof(struct bnad_unmap_q) +=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0 \
> +=A0=A0=A0=A0=A0=A0 (sizeof(struct bnad_skb_unmap) * ((_depth) - 1));=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 \
> +} while (0)
> +
> +void
> +bnad_add_to_list(struct bnad *bnad)
> +{
> +=A0=A0=A0=A0=A0=A0 down(&bnad_list_sem);
> +=A0=A0=A0=A0=A0=A0 list_add_tail(&bnad->list_entry, &bnad_list);
> +=A0=A0=A0=A0=A0=A0 bna_id++;
> +=A0=A0=A0=A0=A0=A0 up(&bnad_list_sem);
> +}

Why do you need to list semaphore? Isn't RTNL mutex held
when this is done. If you have to have own exclusion use
a mutex for this.

> +void
> +bnad_remove_from_list(struct bnad *bnad)
> +{
> +=A0=A0=A0=A0=A0=A0 down(&bnad_list_sem);
> +=A0=A0=A0=A0=A0=A0 list_del(&bnad->list_entry);
> +=A0=A0=A0=A0=A0=A0 up(&bnad_list_sem);
> +}
> +
> +const struct pci_device_id bnad_pci_id_table[] =3D {
> +=A0=A0=A0=A0=A0=A0 {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 PCI_DEVICE(PC=
I_VENDOR_ID_BROCADE,
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 PCI_DEVICE_ID_BROCADE_CT),
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .class =3D PCI_=
CLASS_NETWORK_ETHERNET << 8,
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 .class_mask =3D=
=A0 0xffff00
> +=A0=A0=A0=A0=A0=A0 }, {0,=A0 }
> +};

Why is this not static?


> +/* TX */
> +/* bnad_start_xmit : Netdev entry point for Transmit */
> +/*=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0 Call=
ed under lock held by net_device */
> +
> +netdev_tx_t
> +bnad_start_xmit(struct sk_buff *skb, struct net_device *netdev)

Should also be static...

> +{
> +=A0=A0=A0=A0=A0=A0 struct bnad *bnad =3D netdev_priv(netdev);
> +
> +=A0=A0=A0=A0=A0=A0 u16 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 txq_prod, vlan_tag =3D 0;
> +=A0=A0=A0=A0=A0=A0 u32 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 unmap_prod, wis, wis_used, wi_range;
> +=A0=A0=A0=A0=A0=A0 u32 =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 vectors, vect_id, i, acked;
> +=A0=A0=A0=A0=A0=A0 u32=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0 tx_id;
> +=A0=A0=A0=A0=A0=A0 int =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 err;
> +
> +=A0=A0=A0=A0=A0=A0 struct bnad_tx_info *tx_info;
> +=A0=A0=A0=A0=A0=A0 struct bna_tcb *tcb;
> +=A0=A0=A0=A0=A0=A0 struct bnad_unmap_q *unmap_q;
> +=A0=A0=A0=A0=A0=A0 dma_addr_t =A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0 dma_addr;
> +=A0=A0=A0=A0=A0=A0 struct bna_txq_entry *txqent;
> +=A0=A0=A0=A0=A0=A0 bna_txq_wi_ctrl_flag_t =A0 flags;
> +
> +=A0=A0=A0=A0=A0=A0 if (unlikely
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0 (skb->len <=3D ETH_HLEN || skb->len > B=
=46I_TX_MAX_DATA_PER_PKT)) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 dev_kfree_skb=
(skb);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return NETDEV=
_TX_OK;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 /*
> +=A0=A0=A0=A0=A0=A0 * Takes care of the Tx that is scheduled between =
clearing the flag
> +=A0=A0=A0=A0=A0=A0 * and the netif_stop_queue() call.
> +=A0=A0=A0=A0=A0=A0 */
> +=A0=A0=A0=A0=A0=A0 if (unlikely(!test_bit(BNAD_RF_TX_STARTED, &bnad-=
>run_flags))) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 dev_kfree_skb=
(skb);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return NETDEV=
_TX_OK;
> +=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0 tx_id =3D BNAD_GET_TX_ID(skb);
> +
> +=A0=A0=A0=A0=A0=A0 tx_info =3D &bnad->tx_info[tx_id];
> +=A0=A0=A0=A0=A0=A0 tcb =3D tx_info->tcb[tx_id];
> +=A0=A0=A0=A0=A0=A0 unmap_q =3D tcb->unmap_q;
> +
> +=A0=A0=A0=A0=A0=A0 vectors =3D 1 + skb_shinfo(skb)->nr_frags;
> +=A0=A0=A0=A0=A0=A0 if (vectors > BFI_TX_MAX_VECTORS_PER_PKT) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 dev_kfree_skb=
(skb);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 return NETDEV=
_TX_OK;
> +=A0=A0=A0=A0=A0=A0 }
> +=A0=A0=A0=A0=A0=A0 wis =3D BNA_TXQ_WI_NEEDED(vectors); /* 4 vectors =
per work item */
> +=A0=A0=A0=A0=A0=A0 acked =3D 0;
> +=A0=A0=A0=A0=A0=A0 if (unlikely
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0 (wis > BNA_QE_FREE_CNT(tcb, tcb->q_dept=
h) ||
> +=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0 vectors > BNA_QE_FREE_CNT(unmap_q, u=
nmap_q->q_depth))) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if ((u16) (*t=
cb->hw_consumer_index) !=3D
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 tcb=
->consumer_index &&
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 !te=
st_and_set_bit(BNAD_TXQ_FREE_SENT, &tcb->flags)) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 acked =3D bnad_free_txbufs(bnad, tcb);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 bna_ib_ack(tcb->i_dbell, acked);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 smp_mb__before_clear_bit();
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 clear_bit(BNAD_TXQ_FREE_SENT, &tcb->flags);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 } else {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 netif_stop_queue(netdev);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 BNAD_UPDATE_CTR(bnad, netif_queue_stop);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 }
> +
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 smp_mb();
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 /*
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 * Check again=
 to deal with race condition between
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 * netif_stop_=
queue here, and netif_wake_queue in
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 * interrupt h=
andler which is not inside netif tx lock.
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 */
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 if (likely
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0 (wi=
s > BNA_QE_FREE_CNT(tcb, tcb->q_depth) ||
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0 =A0=A0=A0=A0 =
vectors > BNA_QE_FREE_CNT(unmap_q, unmap_q->q_depth))) {
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 BNAD_UPDATE_CTR(bnad, netif_queue_stop);
> +=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=A0=
=A0=A0=A0=A0=A0=A0=A0 return NETDEV_TX_BUSY;

The transmit routine should check for available space after
queueing to device, so you can avoid having to return
TX_BUSY.
