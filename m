From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH] can: m_can: fix bitrate setup on latest silicon
Date: Tue, 26 Apr 2016 21:11:26 +0200
Message-ID: <571FBD5E.9040807@hartkopp.net>
References: <1461678379-28257-1-git-send-email-fvallee@eukrea.fr>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, ebenard@eukrea.com
To: Florian Vallee <fvallee@eukrea.fr>,
	Wolfgang Grandegger <wg@grandegger.com>,
	Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1461678379-28257-1-git-send-email-fvallee@eukrea.fr>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 04/26/2016 03:46 PM, Florian Vallee wrote:
> According to the m_can user manual changelog the BTP register layout was
> updated with core revision 3.1.0

Hello Florian,

nice to see a real v3.1.0 user emerging on the mailing list :-)

I wonder whether this small change covers the updates made between
v3.0.1 and v3.1.0.

IIRC

v3.0.1:
NON_ISO operation / general CAN/CANFD and BRS switch in register CCCR
v3.1.0:
ISO operation / per frame CAN/CANFD switch (FDF/BRS bit in TX/RX buffer)
v3.2.x:
Ability to switch ISO/NON_ISO operation (NISO bit on register CCCR)
updated range of NBTP.NTSEG2

The current v3.0.1 driver is fixed to tell to be a NON_ISO controller:

https://git.kernel.org/cgit/linux/kernel/git/mkl/linux-can-next.git/diff/drivers/net/can/m_can/m_can.c?h=testing

The v3.1.0 is a fixed ISO controller and additional it does not make 
sense anymore to configure the CCCR register each time, before sending a 
frame:

https://git.kernel.org/cgit/linux/kernel/git/mkl/linux-can-next.git/tree/drivers/net/can/m_can/m_can.c?h=testing&id=885cc17abad6c3064f266099a6ded2d357012380#n1075

Just as the new TX/RX buffer layout contains a FDF and BRS bits for this 
reason.

> +static inline int m_can_read_core_rev(const struct m_can_priv *priv)
> +{
> +	u32 reg = m_can_read(priv, M_CAN_CREL);
> +
> +	return ((reg >> CRR_REL_SHIFT) & CRR_REL_MASK);
> +}
> +
>   static void m_can_read_fifo(struct net_device *dev, u32 rxfs)
>   {
>   	struct net_device_stats *stats = &dev->stats;
> @@ -814,8 +838,16 @@ static int m_can_set_bittiming(struct net_device *dev)
>   	sjw = bt->sjw - 1;
>   	tseg1 = bt->prop_seg + bt->phase_seg1 - 1;
>   	tseg2 = bt->phase_seg2 - 1;
> -	reg_btp = (brp << BTR_BRP_SHIFT) | (sjw << BTR_SJW_SHIFT) |
> -			(tseg1 << BTR_TSEG1_SHIFT) | (tseg2 << BTR_TSEG2_SHIFT);
> +
> +	if (m_can_read_core_rev(priv) < M_CAN_COREREL_3_1_0)

Your patch looks very good so far. I would appreciate if you could 
update the other register changes too as I don't have a hardware to 
test. I can provide the ISO/NON_ISO config for the netlink interface 
updates then :-)

Best regards,
Oliver
