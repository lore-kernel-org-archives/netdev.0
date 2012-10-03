From: Joakim Tjernlund <joakim.tjernlund@transmode.se>
Subject: Re: [PATCH 5/5] ucc_geth: Add IRQ coalescing
Date: Wed, 3 Oct 2012 15:18:18 +0200
Message-ID: <OF9841663E.3905CD18-ONC1257A8C.0049109A-C1257A8C.00491663@transmode.se>
References: <1347987385-19071-1-git-send-email-Joakim.Tjernlund@transmode.se> <1347987385-19071-5-git-send-email-Joakim.Tjernlund@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Cc: netdev@vger.kernel.org
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.transmode.se ([195.58.98.146]:65387 "EHLO gw1.transmode.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754739Ab2JCNSU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 09:18:20 -0400
Received: from mail1.transmode.se (mail1.transmode.se [192.168.201.18])
	by gw1.transmode.se (Postfix) with ESMTP id 532A82581E3
	for <netdev@vger.kernel.org>; Wed,  3 Oct 2012 15:18:19 +0200 (CEST)
In-Reply-To: <1347987385-19071-5-git-send-email-Joakim.Tjernlund@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ping? Got no comments and I can see it in net or net-next trees either.

Joakim Tjernlund <Joakim.Tjernlund@transmode.se> wrote on 2012/09/18 18:56:25:

> From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> To: netdev@vger.kernel.org,
> Cc: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> Date: 2012/09/18 18:56
> Subject: [PATCH 5/5] ucc_geth: Add IRQ coalescing
>
> Enable modest IRQ coalescing(4 pks) to reduce IRQ load.
>
> Signed-off-by: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
> ---
>  arch/powerpc/include/asm/qe.h             |    1 +
>  drivers/net/ethernet/freescale/ucc_geth.c |   18 +++++++++++++++---
>  drivers/net/ethernet/freescale/ucc_geth.h |   20 ++++++++++++++++++++
>  3 files changed, 36 insertions(+), 3 deletions(-)
>
> diff --git a/arch/powerpc/include/asm/qe.h b/arch/powerpc/include/asm/qe.h
> index 5e0b6d5..12a8ac8 100644
> --- a/arch/powerpc/include/asm/qe.h
> +++ b/arch/powerpc/include/asm/qe.h
> @@ -373,6 +373,7 @@ enum comm_dir {
>  #define QE_MCC_STOP_RX         0x00000009
>  #define QE_ATM_TRANSMIT         0x0000000a
>  #define QE_HPAC_CLEAR_ALL      0x0000000b
> +#define QE_SET_LAST_RX_THLD      0x00000013
>  #define QE_GRACEFUL_STOP_RX      0x0000001a
>  #define QE_RESTART_RX         0x0000001b
>  #define QE_HPAC_SET_PRIORITY      0x0000010b
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.c b/drivers/net/ethernet/freescale/ucc_geth.c
> index 7d60b95..772f796 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.c
> +++ b/drivers/net/ethernet/freescale/ucc_geth.c
> @@ -124,7 +124,7 @@ static struct ucc_geth_info ugeth_primary_info = {
>     .ecamptr = ((uint32_t) NULL),
>     .eventRegMask = UCCE_OTHER,
>     .pausePeriod = 0xf000,
> -   .interruptcoalescingmaxvalue = {1, 1, 1, 1, 1, 1, 1, 1},
> +   .interruptcoalescingmaxvalue = {4, 4, 4, 4, 4, 4, 4, 4},
>     .bdRingLenTx = {
>           TX_BD_RING_LEN,
>           TX_BD_RING_LEN,
> @@ -237,7 +237,7 @@ static struct sk_buff *get_new_skb(struct ucc_geth_private *ugeth,
>                   DMA_FROM_DEVICE));
>     skb_reserve(skb, UCC_GETH_RX_IP_ALIGNMENT);
>     out_be32((u32 __iomem *)bd,
> -         (R_E | R_I | (in_be32((u32 __iomem*)bd) & R_W)));
> +       (R_E | (in_be32((u32 __iomem*)bd) & R_W)));
>
>     return skb;
>  }
> @@ -1606,6 +1606,7 @@ static void adjust_link(struct net_device *dev)
>     struct ucc_fast __iomem *uf_regs;
>     struct phy_device *phydev = ugeth->phydev;
>     int new_state = 0;
> +   u32 cecr_subblock;
>
>     ug_regs = ugeth->ug_regs;
>     uf_regs = ugeth->uccf->uf_regs;
> @@ -1657,6 +1658,17 @@ static void adjust_link(struct net_device *dev)
>                    dev->name, phydev->speed);
>              break;
>           }
> +         cecr_subblock =   ucc_fast_get_qe_cr_subblock(ugeth->ug_info->uf_info.ucc_num);
> +         if (phydev->speed == SPEED_10)
> +            qe_issue_cmd(QE_SET_LAST_RX_THLD, cecr_subblock,
> +                    QE_CR_PROTOCOL_ETHERNET, UCC_10_TIME);
> +         else if (phydev->speed == SPEED_100)
> +            qe_issue_cmd(QE_SET_LAST_RX_THLD, cecr_subblock,
> +                    QE_CR_PROTOCOL_ETHERNET, UCC_100_TIME);
> +         else if (phydev->speed == SPEED_1000)
> +            qe_issue_cmd(QE_SET_LAST_RX_THLD, cecr_subblock,
> +                    QE_CR_PROTOCOL_ETHERNET, UCC_GBIT_TIME);
> +
>           ugeth->oldspeed = phydev->speed;
>        }
>
> @@ -2390,7 +2402,7 @@ static int ucc_geth_alloc_rx(struct ucc_geth_private *ugeth)
>        bd = ugeth->rxBd[j] = ugeth->p_rx_bd_ring[j];
>        for (i = 0; i < ug_info->bdRingLenRx[j]; i++) {
>           /* set bd status and length */
> -         out_be32((u32 __iomem *)bd, R_I);
> +         out_be32((u32 __iomem *)bd, 0);
>           /* clear bd buffer */
>           out_be32(&((struct qe_bd __iomem *)bd)->buf, 0);
>           bd += sizeof(struct qe_bd);
> diff --git a/drivers/net/ethernet/freescale/ucc_geth.h b/drivers/net/ethernet/freescale/ucc_geth.h
> index b68637e..49165ce 100644
> --- a/drivers/net/ethernet/freescale/ucc_geth.h
> +++ b/drivers/net/ethernet/freescale/ucc_geth.h
> @@ -923,6 +923,26 @@ struct ucc_geth_hardware_statistics {
>  #define UCC_GETH_MACCFG1_INIT                   0
>  #define UCC_GETH_MACCFG2_INIT                   (MACCFG2_RESERVED_1)
>
> +/*
> + * From QUICC Engine Block Reference Manual, Chap 8.9:
> + * This command is used to set a timeout value for the Ethernet receiver
> + * interrupt coalescing mechanism.
> + * The timeout period is measured from the time that the last Ethernet frame
> + * was received. When the timeout expires, an interrupt is issued to the CPU
> + * even if the interrupt coalescing counter did not reach its maximum value. The
> + * timeout value should be written in the two least significant bytes of CECDR,
> + * and it should be specified in terms of serial clocks.
> + * For example, a value of 1000 in CECDR sets the timeout period to 1000 serial
> + * clocks.
> + * -------------------------------------------------------------------
> + * GBIT = 125MHz => 8ns/tick, 8 bits / tick
> + * 100 = 25 MHz => 40ns/tick, 4 bits / tick
> + * 10 = 2.5 MHz => 400ns/tick, 4 bits / tick
> + */
> +#define UCC_GBIT_TIME  64
> +#define UCC_100_TIME   64
> +#define UCC_10_TIME    8
> +
>  /* Ethernet Address Type. */
>  enum enet_addr_type {
>     ENET_ADDR_TYPE_INDIVIDUAL,
> --
> 1.7.8.6
>
