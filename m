From: Oliver Hartkopp <socketcan@hartkopp.net>
Subject: Re: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Sun, 6 Mar 2016 12:32:49 +0100
Message-ID: <56DC1561.9060306@hartkopp.net>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: 7bit
Cc: linux-renesas-soc@vger.kernel.org, devicetree@vger.kernel.org,
	linux-can@vger.kernel.org, netdev@vger.kernel.org,
	linux-doc@vger.kernel.org, geert+renesas@glider.be,
	chris.paterson2@renesas.com
To: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>,
	mkl@pengutronix.de, wg@grandegger.com, robh+dt@kernel.org,
	pawel.moll@arm.com, mark.rutland@arm.com,
	ijc+devicetree@hellion.org.uk, galak@codeaurora.org, corbet@lwn.net
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 03/03/2016 04:38 PM, Ramesh Shanmugasundaram wrote:

> Changes since v1:
> 	* Removed testmodes & debugfs code (suggested by Oliver H)
> 	* Fixed tx path race issue by introducing lock (suggested by Marc K)
> 	* Removed __maybe_unused attribute of rcar_canfd_of_table
> 


>  obj-$(CONFIG_CAN_M_CAN)		+= m_can/
>  obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
> +obj-$(CONFIG_CANFD_RCAR)	+= rcar_canfd.o

Just for the sake of an ordered directory structure:

Would it make sense to create a rcar directory where rcar_can.c and
rcar_canfd.c are placed?

Additionally (besides of one accident with the obsolete PCH_CAN) all CAN
drivers start with CONFIG_CAN_...

Following that scheme the config option should be named

	CONFIG_CAN_RCAR_CANFD

as we had in CONFIG_CAN_IFI_CANFD.


>  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>  obj-$(CONFIG_CAN_SUN4I)		+= sun4i_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
> diff --git a/drivers/net/can/rcar_canfd.c b/drivers/net/can/rcar_canfd.c

(..)

> +/* Channel priv data */
> +struct rcar_canfd_channel {
> +	struct can_priv can;			/* Must be the first member */
> +	struct net_device *ndev;
> +	struct rcar_canfd_global *gpriv;	/* Controller reference */
> +	void __iomem *base;			/* Register base address */
> +#ifdef CONFIG_DEBUG_FS
> +	struct dentry *dev_root;
> +#endif /* CONFIG_DEBUG_FS */

Some missed stuff from debugfs removal?

> +	struct napi_struct napi;
> +	u8  tx_len[RCANFD_FIFO_DEPTH];		/* For net stats */
> +	u32 tx_head;				/* Incremented on xmit */
> +	u32 tx_tail;				/* Incremented on xmit done */
> +	u32 channel;				/* Channel number */
> +	spinlock_t tx_lock;			/* To protect tx path */
> +};

(..)

> +static int rcar_canfd_start(struct net_device *ndev)
> +{
> +	struct rcar_canfd_channel *priv = netdev_priv(ndev);
> +	int err = -EOPNOTSUPP;
> +	u32 sts, ch = priv->channel;
> +	u32 ridx = ch + RCANFD_RFFIFO_IDX;
> +
> +	/* Ensure channel starts in FD mode */
> +	if (!(priv->can.ctrlmode & CAN_CTRLMODE_FD)) {
> +		netdev_err(ndev, "enable can fd mode for channel %d\n", ch);
> +		goto fail_mode;
> +	}

What's the reason behind this check?

A CAN FD capable CAN controller can be either configured to run as CAN 2.0
(Classic CAN) or as CAN FD controller.

So why are to throwing an error here and produce an initialization failure?

Regards,
Oliver
