From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [RESEND PATCH 1/1] can: m_can: fix bitrate setup on latest
 silicon
Date: Sun, 19 Feb 2017 16:37:50 +0100
Message-ID: <b1140be9-1811-1512-b32e-436e8bb25824@hartkopp.net>
References: <20170215140819.879-1-quentin.schulz@free-electrons.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: wg@grandegger.com, mkl@pengutronix.de, linux-can@vger.kernel.org,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
        boris.brezillon@free-electrons.com,
        alexandre.belloni@free-electrons.com, nicolas.ferre@atmel.com
To: Quentin Schulz <quentin.schulz@free-electrons.com>,
        fvallee@eukrea.fr
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170215140819.879-1-quentin.schulz@free-electrons.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,

On 02/15/2017 03:08 PM, Quentin Schulz wrote:
> From: Florian Vallee <fvallee@eukrea.fr>
>
> According to the m_can user manual changelog the BTP register layout was
> updated with core revision 3.1.0
>
> This change is not backward-compatible and using the current driver along
> with a recent IP results in an incorrect bitrate on the wire.

the BTP register layout is only one of eleven changes between 3.0.1 and 
3.1.0:

1. Register FBTP renamed to DBTP and restructured
2. Register TEST restructured
3. Register CCCR restructured
4. Register BTP renamed to NBTP and restructured <<<---- HERE
5. Register PSR updated
6. Register TDCR added
7. Register IR updated
8. Register IE updated
9. Register ILS updated
10. Rx Buffer and FIFO Element updated
11. Tx Buffer Element updated

Especially the change #11 allows the switch between CAN and CAN FD 
frames on a per-frame setting without switching the entire controller 
mode via CCCR register in IP core 3.0.1:

https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/tree/drivers/net/can/m_can/m_can.c?h=linux-4.9.y#n1075

Fortunately I was contacted by Bosch this Friday as they want to 
contribute a driver upgrade to support IP cores up to 3.2.x.
Additionally their plan is to use Device Tree information to determine 
the IP core revision - or at least to cross check its information with 
the register information used in your suggestion.

For that reason I would suggest to wait for the driver updates from 
Bosch instead of adding an incomplete fix for only one change of eleven.

Btw. it would be very cool if you could provide some testing for the 
upcoming changes from Bosch when they are posted.

Best regards,
Oliver

>
> Tested with a SAMA5D2 SoC (CREL = 0x31040730)
>
> Signed-off-by: Florian Vallee <fvallee@eukrea.fr>
> Tested-by: Quentin Schulz <quentin.schulz@free-electrons.com>
> ---
>  drivers/net/can/m_can/m_can.c | 38 +++++++++++++++++++++++++++++++++++---
>  1 file changed, 35 insertions(+), 3 deletions(-)
>
> diff --git a/drivers/net/can/m_can/m_can.c b/drivers/net/can/m_can/m_can.c
> index 195f15e..246584e 100644
> --- a/drivers/net/can/m_can/m_can.c
> +++ b/drivers/net/can/m_can/m_can.c
> @@ -105,6 +105,10 @@ enum m_can_mram_cfg {
>  	MRAM_CFG_NUM,
>  };
>
> +/* Core Release Register (CREL) */
> +#define CRR_REL_MASK		0xfff
> +#define CRR_REL_SHIFT		20
> +
>  /* Fast Bit Timing & Prescaler Register (FBTP) */
>  #define FBTR_FBRP_MASK		0x1f
>  #define FBTR_FBRP_SHIFT		16
> @@ -136,7 +140,7 @@ enum m_can_mram_cfg {
>  #define CCCR_INIT		BIT(0)
>  #define CCCR_CANFD		0x10
>
> -/* Bit Timing & Prescaler Register (BTP) */
> +/* Bit Timing & Prescaler Register (BTP) (M_CAN IP < 3.1.0) */
>  #define BTR_BRP_MASK		0x3ff
>  #define BTR_BRP_SHIFT		16
>  #define BTR_TSEG1_SHIFT		8
> @@ -146,6 +150,16 @@ enum m_can_mram_cfg {
>  #define BTR_SJW_SHIFT		0
>  #define BTR_SJW_MASK		0xf
>
> +/* Nominal Bit Timing & Prescaler Register (NBTP) (M_CAN IP >= 3.1.0) */
> +#define NBTR_SJW_SHIFT		25
> +#define NBTR_SJW_MASK		(0x7f << NBTR_SJW_SHIFT)
> +#define NBTR_BRP_SHIFT		16
> +#define NBTR_BRP_MASK		(0x3ff << NBTR_BRP_SHIFT)
> +#define NBTR_TSEG1_SHIFT	8
> +#define NBTR_TSEG1_MASK		(0xff << NBTR_TSEG1_SHIFT)
> +#define NBTR_TSEG2_SHIFT	0
> +#define NBTR_TSEG2_MASK		(0x7f << NBTR_TSEG2_SHIFT)
> +
>  /* Error Counter Register(ECR) */
>  #define ECR_RP			BIT(15)
>  #define ECR_REC_SHIFT		8
> @@ -200,6 +214,9 @@ enum m_can_mram_cfg {
>  			 IR_RF1L | IR_RF0L)
>  #define IR_ERR_ALL	(IR_ERR_STATE | IR_ERR_BUS)
>
> +/* Core Version */
> +#define M_CAN_COREREL_3_1_0	0x310
> +
>  /* Interrupt Line Select (ILS) */
>  #define ILS_ALL_INT0	0x0
>  #define ILS_ALL_INT1	0xFFFFFFFF
> @@ -357,6 +374,13 @@ static inline void m_can_disable_all_interrupts(const struct m_can_priv *priv)
>  	m_can_write(priv, M_CAN_ILE, 0x0);
>  }
>
> +static inline int m_can_read_core_rev(const struct m_can_priv *priv)
> +{
> +	u32 reg = m_can_read(priv, M_CAN_CREL);
> +
> +	return ((reg >> CRR_REL_SHIFT) & CRR_REL_MASK);
> +}
> +
>  static void m_can_read_fifo(struct net_device *dev, u32 rxfs)
>  {
>  	struct net_device_stats *stats = &dev->stats;
> @@ -811,8 +835,16 @@ static int m_can_set_bittiming(struct net_device *dev)
>  	sjw = bt->sjw - 1;
>  	tseg1 = bt->prop_seg + bt->phase_seg1 - 1;
>  	tseg2 = bt->phase_seg2 - 1;
> -	reg_btp = (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
> -			(tseg1 << BTR_TSEG1_SHIFT) | (tseg2 << BTR_TSEG2_SHIFT);
> +
> +	if (m_can_read_core_rev(priv) < M_CAN_COREREL_3_1_0)
> +		reg_btp = (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
> +				(tseg1 << BTR_TSEG1_SHIFT) |
> +				(tseg2 << BTR_TSEG2_SHIFT);
> +	else
> +		reg_btp = (brp << NBTR_BRP_SHIFT) | (sjw << NBTR_SJW_SHIFT) |
> +				(tseg1 << NBTR_TSEG1_SHIFT) |
> +				(tseg2 << NBTR_TSEG2_SHIFT);
> +
>  	m_can_write(priv, M_CAN_BTP, reg_btp);
>
>  	if (priv->can.ctrlmode & CAN_CTRLMODE_FD) {
>
