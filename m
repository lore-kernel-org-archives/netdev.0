From: Ramesh Shanmugasundaram <ramesh.shanmugasundaram@bp.renesas.com>
Subject: RE: [PATCH v2] can: rcar_canfd: Add Renesas R-Car CAN FD driver
Date: Mon, 7 Mar 2016 08:02:10 +0000
Message-ID: <SG2PR06MB10386D712BC8C345DF726523C3B10@SG2PR06MB1038.apcprd06.prod.outlook.com>
References: <1456824849-7987-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <1457019515-21158-1-git-send-email-ramesh.shanmugasundaram@bp.renesas.com>
 <56DC1561.9060306@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "linux-renesas-soc@vger.kernel.org"
	<linux-renesas-soc@vger.kernel.org>,
	"devicetree@vger.kernel.org" <devicetree@vger.kernel.org>,
	"linux-can@vger.kernel.org" <linux-can@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-doc@vger.kernel.org" <linux-doc@vger.kernel.org>,
	"geert+renesas@glider.be" <geert+renesas@glider.be>,
	Chris Paterson <Chris.Paterson2@renesas.com>
To: Oliver Hartkopp <socketcan@hartkopp.net>,
	"mkl@pengutronix.de" <mkl@pengutronix.de>,
	"wg@grandegger.com" <wg@grandegger.com>,
	"robh+dt@kernel.org" <robh+dt@kernel.org>,
	"pawel.moll@arm.com" <pawel.moll@arm.com>,
	"mark.rutland@arm.com" <mark.rutland@arm.com>,
	"ijc+devicetree@hellion.org.uk" <ijc+devicetree@hellion.org.uk>,
	"galak@codeaurora.org" <galak@codeaurora.org>,
	"corbet@lwn.net" <corbet@lwn.net>
Return-path: <linux-renesas-soc-owner@vger.kernel.org>
In-Reply-To: <56DC1561.9060306@hartkopp.net>
Content-Language: en-US
Sender: linux-renesas-soc-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Oliver,

Thanks for the review comments.

> On 03/03/2016 04:38 PM, Ramesh Shanmugasundaram wrote:
> 
> > Changes since v1:
> > 	* Removed testmodes & debugfs code (suggested by Oliver H)
> > 	* Fixed tx path race issue by introducing lock (suggested by Marc K)
> > 	* Removed __maybe_unused attribute of rcar_canfd_of_table
> >
> 
> 
> >  obj-$(CONFIG_CAN_M_CAN)		+= m_can/
> >  obj-$(CONFIG_CAN_RCAR)		+= rcar_can.o
> > +obj-$(CONFIG_CANFD_RCAR)	+= rcar_canfd.o
> 
> Just for the sake of an ordered directory structure:
> 
> Would it make sense to create a rcar directory where rcar_can.c and
> rcar_canfd.c are placed?
> 
Yes. I'll place them in rcar dir.

> Additionally (besides of one accident with the obsolete PCH_CAN) all CAN
> drivers start with CONFIG_CAN_...
> 
> Following that scheme the config option should be named
> 
> 	CONFIG_CAN_RCAR_CANFD
> 
> as we had in CONFIG_CAN_IFI_CANFD.

Agreed.

> 
> >  obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
> >  obj-$(CONFIG_CAN_SUN4I)		+= sun4i_can.o
> >  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
> > diff --git a/drivers/net/can/rcar_canfd.c
> > b/drivers/net/can/rcar_canfd.c
> 
> (..)
> 
> > +/* Channel priv data */
> > +struct rcar_canfd_channel {
> > +	struct can_priv can;			/* Must be the first member */
> > +	struct net_device *ndev;
> > +	struct rcar_canfd_global *gpriv;	/* Controller reference */
> > +	void __iomem *base;			/* Register base address */
> > +#ifdef CONFIG_DEBUG_FS
> > +	struct dentry *dev_root;
> > +#endif /* CONFIG_DEBUG_FS */
> 
> Some missed stuff from debugfs removal?

:-(. Sorry. Will clean up.

> 
> > +	struct napi_struct napi;
> > +	u8  tx_len[RCANFD_FIFO_DEPTH];		/* For net stats */
> > +	u32 tx_head;				/* Incremented on xmit */
> > +	u32 tx_tail;				/* Incremented on xmit done */
> > +	u32 channel;				/* Channel number */
> > +	spinlock_t tx_lock;			/* To protect tx path */
> > +};
> 
> (..)
> 
> > +static int rcar_canfd_start(struct net_device *ndev) {
> > +	struct rcar_canfd_channel *priv = netdev_priv(ndev);
> > +	int err = -EOPNOTSUPP;
> > +	u32 sts, ch = priv->channel;
> > +	u32 ridx = ch + RCANFD_RFFIFO_IDX;
> > +
> > +	/* Ensure channel starts in FD mode */
> > +	if (!(priv->can.ctrlmode & CAN_CTRLMODE_FD)) {
> > +		netdev_err(ndev, "enable can fd mode for channel %d\n", ch);
> > +		goto fail_mode;
> > +	}
> 
> What's the reason behind this check?
> 
> A CAN FD capable CAN controller can be either configured to run as CAN 2.0
> (Classic CAN) or as CAN FD controller.
> 
> So why are to throwing an error here and produce an initialization
> failure?

When this controller is configured in FD mode and used only with CAN 2.0 nodes, it still expects a DTSEG (data bitrate) configuration same as NTSEG (nominal bitrate). This check, specifically in ndo_open, ensures both are configured and will work fine with CAN 2.0 nodes (e.g.)

"ip link set can0 up type can bitrate 1000000 dbitrate 1000000 fd on"

If I don't have this check, a configuration like this

"ip link set can0 up type can bitrate 1000000"

will bring up the controller without DTSEG configured. 

Thanks,
Ramesh
