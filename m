From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH 2/3] can: add support for Janz VMOD-ICAN3 Intelligent
	CAN	module
Date: Fri, 19 Mar 2010 10:01:14 +0100
Message-ID: <4BA33D5A.8070000@grandegger.com>
References: <> <1268930324-29841-3-git-send-email-iws@ovro.caltech.edu>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, sameo-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: "Ira W. Snyder" <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1268930324-29841-3-git-send-email-iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/options/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Ira,

we already discussed this patch on the SocketCAN mailing list and there
are just a few minor issues and the request to add support for the new
"berr-reporting" option, if feasible. See:

  commit 52c793f24054f5dc30d228e37e0e19cc8313f086
  Author: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
  Date:   Mon Feb 22 22:21:17 2010 +0000

    can: netlink support for bus-error reporting and counters
    
    This patch makes the bus-error reporting configurable and allows to
    retrieve the CAN TX and RX bus error counters via netlink interface.
    I have added support for the SJA1000. The TX and RX bus error counters
    are also copied to the data fields 6..7 of error messages when state
    changes are reported.

Should not be a big deal.

More inline...

Ira W. Snyder wrote:
> The Janz VMOD-ICAN3 is a MODULbus daughterboard which fits onto any
> MODULbus carrier board. It is an intelligent CAN controller with a
> microcontroller and associated firmware.
> 
> Signed-off-by: Ira W. Snyder <iws-lulEs6mt1IksTUYHLfqkUA@public.gmane.org>
> Cc: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
> Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
> ---
>  drivers/net/can/Kconfig      |   10 +
>  drivers/net/can/Makefile     |    1 +
>  drivers/net/can/janz-ican3.c | 1659 ++++++++++++++++++++++++++++++++++++++++++
>  3 files changed, 1670 insertions(+), 0 deletions(-)
>  create mode 100644 drivers/net/can/janz-ican3.c
> 
> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
> index 05b7517..2c5227c 100644
> --- a/drivers/net/can/Kconfig
> +++ b/drivers/net/can/Kconfig
> @@ -63,6 +63,16 @@ config CAN_BFIN
>  	  To compile this driver as a module, choose M here: the
>  	  module will be called bfin_can.
>  
> +config CAN_JANZ_ICAN3
> +	tristate "Janz VMOD-ICAN3 Intelligent CAN controller"
> +	depends on CAN_DEV && MFD_JANZ_CMODIO
> +	---help---
> +	  Driver for Janz VMOD-ICAN3 Intelligent CAN controller module, which
> +	  connects to a MODULbus carrier board.
> +
> +	  This driver can also be built as a module. If so, the module will be
> +	  called janz-ican3.ko.
> +
>  source "drivers/net/can/mscan/Kconfig"
>  
>  source "drivers/net/can/sja1000/Kconfig"
> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
> index 7a702f2..9047cd0 100644
> --- a/drivers/net/can/Makefile
> +++ b/drivers/net/can/Makefile
> @@ -15,5 +15,6 @@ obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
> +obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
>  
>  ccflags-$(CONFIG_CAN_DEBUG_DEVICES) := -DDEBUG
> diff --git a/drivers/net/can/janz-ican3.c b/drivers/net/can/janz-ican3.c
> new file mode 100644
> index 0000000..94d4995
> --- /dev/null
> +++ b/drivers/net/can/janz-ican3.c
[snip]
 +struct ican3_dev {
> +
> +	/* must be the first member */
> +	struct can_priv can;
> +
> +	/* CAN network device */
> +	struct net_device *ndev;
> +	struct napi_struct napi;
> +
> +	/* Device for printing */
> +	struct device *dev;
> +
> +	/* module number */
> +	unsigned int num;
> +
> +	/* base address of registers and IRQ */
> +	struct janz_cmodio_onboard_regs __iomem *ctrl;
> +	struct ican3_dpm_control *dpmctrl;
> +	void __iomem *dpm;
> +	int irq;
> +
> +	/* old and new style host interface */
> +	unsigned int iftype;
> +	spinlock_t lock;

Please describe what the lock is used for.

> +	/* new host interface */
> +	unsigned int rx_int;
> +	unsigned int rx_num;
> +	unsigned int tx_num;
> +
> +	/* fast host interface */
> +	unsigned int fastrx_start;
> +	unsigned int fastrx_int;
> +	unsigned int fastrx_num;
> +	unsigned int fasttx_start;
> +	unsigned int fasttx_num;
> +
> +	/* first free DPM page */
> +	unsigned int free_page;
> +};

[snip]
> +static void ican3_to_can_frame(struct ican3_dev *mod,
> +			       struct ican3_fast_desc *desc,
> +			       struct can_frame *cf)
> +{
> +	if ((desc->command & ICAN3_CAN_TYPE_MASK) == ICAN3_CAN_TYPE_SFF) {
> +		dev_dbg(mod->dev, "%s: old frame format\n", __func__);

This prints a debug message for every message which is not really
useful for the user. Please remove.

> +		if (desc->data[1] & ICAN3_SFF_RTR)
> +			cf->can_id |= CAN_RTR_FLAG;
> +
> +		cf->can_id |= desc->data[0] << 3;
> +		cf->can_id |= (desc->data[1] & 0xe0) >> 5;
> +		cf->can_dlc = desc->data[1] & ICAN3_CAN_DLC_MASK;
> +		memcpy(cf->data, &desc->data[2], sizeof(cf->data));
> +	} else {
> +		dev_dbg(mod->dev, "%s: new frame format\n", __func__);

Ditto.

> +		cf->can_dlc = desc->data[0] & ICAN3_CAN_DLC_MASK;
> +		if (desc->data[0] & ICAN3_EFF_RTR)
> +			cf->can_id |= CAN_RTR_FLAG;
> +
> +		if (desc->data[0] & ICAN3_EFF) {
> +			cf->can_id |= CAN_EFF_FLAG;
> +			cf->can_id |= desc->data[2] << 21; /* 28-21 */
> +			cf->can_id |= desc->data[3] << 13; /* 20-13 */
> +			cf->can_id |= desc->data[4] << 5;  /* 12-5  */
> +			cf->can_id |= (desc->data[5] & 0xf8) >> 3;
> +		} else {
> +			cf->can_id |= desc->data[2] << 3;  /* 10-3  */
> +			cf->can_id |= desc->data[3] >> 5;  /* 2-0   */
> +		}
> +
> +		memcpy(cf->data, &desc->data[6], sizeof(cf->data));
> +	}
> +}
> +
> +static void can_frame_to_ican3(struct ican3_dev *mod,
> +			       struct can_frame *cf,
> +			       struct ican3_fast_desc *desc)
> +{
> +	/* clear out any stale data in the descriptor */
> +	memset(desc->data, 0, sizeof(desc->data));
> +
> +	/* we always use the extended format, with the ECHO flag set */
> +	desc->command = ICAN3_CAN_TYPE_EFF;
> +	desc->data[0] |= cf->can_dlc;
> +	desc->data[1] |= ICAN3_ECHO;
> +
> +	if (cf->can_id & CAN_RTR_FLAG)
> +		desc->data[0] |= ICAN3_EFF_RTR;
> +
> +	/* pack the id into the correct places */
> +	if (cf->can_id & CAN_EFF_FLAG) {
> +		dev_dbg(mod->dev, "%s: extended frame\n", __func__);

Ditto.

> +		desc->data[0] |= ICAN3_EFF;
> +		desc->data[2] = (cf->can_id & 0x1fe00000) >> 21; /* 28-21 */
> +		desc->data[3] = (cf->can_id & 0x001fe000) >> 13; /* 20-13 */
> +		desc->data[4] = (cf->can_id & 0x00001fe0) >> 5;  /* 12-5  */
> +		desc->data[5] = (cf->can_id & 0x0000001f) << 3;  /* 4-0   */
> +	} else {
> +		dev_dbg(mod->dev, "%s: standard frame\n", __func__);

Ditto.

> +		desc->data[2] = (cf->can_id & 0x7F8) >> 3; /* bits 10-3 */
> +		desc->data[3] = (cf->can_id & 0x007) << 5; /* bits 2-0  */
> +	}
> +
> +	/* copy the data bits into the descriptor */
> +	memcpy(&desc->data[6], cf->data, sizeof(cf->data));
> +}

[snip]
> +/*
> + * Handle CAN Event Indication Messages from the firmware
> + *
> + * The ICAN3 firmware provides the values of some SJA1000 registers when it
> + * generates this message. The code below is largely copied from the
> + * drivers/net/can/sja1000/sja1000.c file, and adapted as necessary
> + */
> +static int ican3_handle_cevtind(struct ican3_dev *mod, struct ican3_msg *msg)
> +{
> +	struct net_device *dev = mod->ndev;
> +	struct net_device_stats *stats = &dev->stats;
> +	enum can_state state = mod->can.state;
> +	struct can_frame *cf;
> +	struct sk_buff *skb;
> +	u8 status, isrc;
> +
> +	/* we can only handle the SJA1000 part */
> +	if (msg->data[1] != CEVTIND_CHIP_SJA1000) {
> +		dev_err(mod->dev, "unable to handle errors on non-SJA1000\n");
> +		return -ENODEV;
> +	}
> +
> +	/* check the message length for sanity */
> +	if (msg->len < 6) {
> +		dev_err(mod->dev, "error message too short\n");
> +		return -EINVAL;
> +	}
> +
> +	skb = alloc_can_err_skb(dev, &cf);
> +	if (skb == NULL)
> +		return -ENOMEM;
> +
> +	isrc = msg->data[0];
> +	status = msg->data[3];
> +
> +	/* data overrun interrupt */
> +	if (isrc == CEVTIND_DOI || isrc == CEVTIND_LOST) {

Here and for the other errors below a dev_dbg() would be useful. Please
check sja1000.c.

> +		cf->can_id |= CAN_ERR_CRTL;
> +		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
> +		stats->rx_over_errors++;
> +		stats->rx_errors++;
> +		dev_info(mod->dev, "%s: overflow frame generated\n", __func__);

s/dev_info/dev_dbg/ ?

> +	}
> +
> +	/* error warning interrupt */
> +	if (isrc == CEVTIND_EI) {
> +		if (status & SR_BS) {
> +			state = CAN_STATE_BUS_OFF;
> +			cf->can_id |= CAN_ERR_BUSOFF;
> +			can_bus_off(dev);
> +		} else if (status & SR_ES) {
> +			state = CAN_STATE_ERROR_WARNING;
> +		} else {
> +			state = CAN_STATE_ERROR_ACTIVE;
> +		}
> +	}
> +
> +	/* bus error interrupt */
> +	if (isrc == CEVTIND_BEI) {
> +		u8 ecc = msg->data[2];

Add an empty line, please.

> +		mod->can.can_stats.bus_error++;
> +		stats->rx_errors++;
> +		cf->can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
> +
> +		switch (ecc & ECC_MASK) {
> +		case ECC_BIT:
> +			cf->data[2] |= CAN_ERR_PROT_BIT;
> +			break;
> +		case ECC_FORM:
> +			cf->data[2] |= CAN_ERR_PROT_FORM;
> +			break;
> +		case ECC_STUFF:
> +			cf->data[2] |= CAN_ERR_PROT_STUFF;
> +			break;
> +		default:
> +			cf->data[2] |= CAN_ERR_PROT_UNSPEC;
> +			cf->data[3] = ecc & ECC_SEG;
> +			break;
> +		}
> +
> +		if ((ecc & ECC_DIR) == 0)
> +			cf->data[2] |= CAN_ERR_PROT_TX;
> +	}
> +
> +	if (state != mod->can.state && (state == CAN_STATE_ERROR_WARNING ||
> +					state == CAN_STATE_ERROR_PASSIVE)) {
> +		u8 rxerr = msg->data[4];
> +		u8 txerr = msg->data[5];

Ditto.

> +		cf->can_id |= CAN_ERR_CRTL;
> +		if (state == CAN_STATE_ERROR_WARNING) {
> +			mod->can.can_stats.error_warning++;
> +			cf->data[1] = (txerr > rxerr) ?
> +				CAN_ERR_CRTL_TX_WARNING :
> +				CAN_ERR_CRTL_RX_WARNING;
> +		} else {
> +			mod->can.can_stats.error_passive++;
> +			cf->data[1] = (txerr > rxerr) ?
> +				CAN_ERR_CRTL_TX_PASSIVE :
> +				CAN_ERR_CRTL_RX_PASSIVE;
> +		}
> +	}
> +
> +	mod->can.state = state;
> +	stats->rx_errors++;
> +	stats->rx_bytes += cf->can_dlc;
> +	netif_rx(skb);
> +	return 0;
> +}

[snip]
> +static irqreturn_t ican3_irq(int irq, void *dev_id)
> +{
> +	struct ican3_dev *mod = dev_id;
> +	u8 stat;
> +
> +	/*
> +	 * The interrupt status register on this device reports interrupts
> +	 * as zeroes instead of using ones like most other devices
> +	 */
> +	stat = ioread8(&mod->ctrl->int_disable) & (1 << mod->num);
> +	if (stat == (1 << mod->num))
> +		return IRQ_NONE;
> +
> +	dev_dbg(mod->dev, "IRQ: module %d\n", mod->num);

Please remove this dev_dbg() as well.

[snip]
> +/*
> + * Startup an ICAN module, bringing it into fast mode
> + */
> +static int __devinit ican3_startup_module(struct ican3_dev *mod)
> +{
> +	int ret;
> +
> +	ret = ican3_reset_module(mod);
> +	if (ret) {
> +		dev_err(mod->dev, "unable to reset module\n");
> +		return ret;
> +	}
> +
> +	/* re-enable interrupts so we can send messages */
> +	iowrite8(1 << mod->num, &mod->ctrl->int_enable);
> +
> +	ret = ican3_msg_connect(mod);
> +	if (ret) {
> +		dev_err(mod->dev, "unable to connect to module\n");
> +		return ret;
> +	}
> +
> +	ican3_init_new_host_interface(mod);
> +	ret = ican3_msg_newhostif(mod);
> +	if (ret) {
> +		dev_err(mod->dev, "unable to switch to new-style interface\n");
> +		return ret;
> +	}
> +
> +	ret = ican3_set_termination(mod, true);
> +	if (ret) {
> +		dev_err(mod->dev, "unable to enable termination\n");
> +		return ret;
> +	}


Could you please allow the user to disable termination, e.g. via module parameter
"bus_termination=0" in case he uses a cable with built-in termination.

[snip]
> +static int __devinit ican3_probe(struct platform_device *pdev)
> +{
> +	struct janz_platform_data *pdata;
> +	struct net_device *ndev;
> +	struct ican3_dev *mod;
> +	struct resource *res;
> +	struct device *dev;
> +	int ret;
> +
> +	pdata = pdev->dev.platform_data;
> +	if (!pdata)
> +		return -ENXIO;
> +
> +	dev_dbg(&pdev->dev, "probe: module number %d\n", pdata->modno);
> +
> +	/* save the struct device for printing */
> +	dev = &pdev->dev;
> +
> +	/* allocate the CAN device and private data */
> +	ndev = alloc_candev(sizeof(*mod), 0);
> +	if (!ndev) {
> +		dev_err(dev, "unable to allocate CANdev\n");
> +		ret = -ENOMEM;
> +		goto out_return;
> +	}
> +
> +	platform_set_drvdata(pdev, ndev);
> +	mod = netdev_priv(ndev);
> +	mod->ndev = ndev;
> +	mod->dev = &pdev->dev;
> +	mod->num = pdata->modno;
> +	netif_napi_add(ndev, &mod->napi, ican3_napi, ICAN3_RX_BUFFERS);
> +	spin_lock_init(&mod->lock);
> +
> +	/* the first unallocated page in the DPM is 9 */
> +	mod->free_page = DPM_FREE_START;
> +
> +	ndev->netdev_ops = &ican3_netdev_ops;
> +	ndev->flags |= IFF_ECHO;
> +	SET_NETDEV_DEV(ndev, &pdev->dev);
> +
> +	mod->can.clock.freq = 8000000;

Please use a constant here.
[snip]

Please fix and resubmit with my:

"Acked-by: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>"

for the SocketCAN part.

Thanks,

Wolfgang.
