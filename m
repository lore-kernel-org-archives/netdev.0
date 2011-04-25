From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [PATCH v4 1/1] can: add pruss CAN driver.
Date: Mon, 25 Apr 2011 22:06:42 +0200
Message-ID: <4DB5D452.9050500@grandegger.com>
References: <1303474267-6344-1-git-send-email-subhasish@mistralsolutions.com>	<1303474267-6344-2-git-send-email-subhasish@mistralsolutions.com>
	<4DB1A3B7.7060300@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: sachi-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org, davinci-linux-open-source-VycZQUHpC/PFrsHnngEfi1aTQe2KTcn/@public.gmane.org,
	Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>, nsekhar-l0cyMroinI0@public.gmane.org,
	open list <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	CAN NETWORK DRIVERS <socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>,
	Netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, m-watkins-l0cyMroinI0@public.gmane.org,
	linux-arm-kernel-IAPFreCvJWM7uuMidbF8XUB+6BGkLq7r@public.gmane.org
To: Marc Kleine-Budde <mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4DB1A3B7.7060300-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org>
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

Hi,

On 04/22/2011 05:50 PM, Marc Kleine-Budde wrote:
> On 04/22/2011 02:11 PM, Subhasish Ghosh wrote:
>> This patch adds support for the CAN device emulated on PRUSS.
> 
> After commenting the code inline, some remarks:
> - Your tx path looks broken, see commits inline
> - Please setup a proper struct to describe your register layout, make
>   use of arrays for rx and tx
> - don't use u32, s32 for not hardware related variables like return
>   codes and loop counter.
> - the routines that load and save the can data bytes from/into your
>   mailbox look way to complicated. Please write down the layout so that
>   we can think of a elegant way to do it
> - a lot of functions unconditionally return 0, make them void if no
>   error can happen
> - think about using managed devices, that would simplify the probe and
>   release function

I agree with Marc's comments and would like to add:

- Use just *one* value per sysfs file

A few more comments inline...

>> Signed-off-by: Subhasish Ghosh <subhasish-EvXpCiN+lbve9wHmmfpqLFaTQe2KTcn/@public.gmane.org>
>> ---
>>  drivers/net/can/Kconfig     |    7 +
>>  drivers/net/can/Makefile    |    1 +
>>  drivers/net/can/pruss_can.c | 1074 +++++++++++++++++++++++++++++++++++++++++++
>>  3 files changed, 1082 insertions(+), 0 deletions(-)
>>  create mode 100644 drivers/net/can/pruss_can.c
>>
>> diff --git a/drivers/net/can/Kconfig b/drivers/net/can/Kconfig
>> index 5dec456..4682a4f 100644
>> --- a/drivers/net/can/Kconfig
>> +++ b/drivers/net/can/Kconfig
>> @@ -111,6 +111,13 @@ config PCH_CAN
>>  	  embedded processor.
>>  	  This driver can access CAN bus.
>>  
>> +config CAN_TI_DA8XX_PRU
>> +	depends on CAN_DEV && ARCH_DAVINCI && ARCH_DAVINCI_DA850
>> +	tristate "PRU based CAN emulation for DA8XX"
>> +	---help---
>> +	Enable this to emulate a CAN controller on the PRU of DA8XX.
>> +	If not sure, mark N
> 
> Please indent the help text with 1 tab and 2 spaces
> 
>> +
>>  source "drivers/net/can/mscan/Kconfig"
>>  
>>  source "drivers/net/can/sja1000/Kconfig"
>> diff --git a/drivers/net/can/Makefile b/drivers/net/can/Makefile
>> index 53c82a7..d0b7cbd 100644
>> --- a/drivers/net/can/Makefile
>> +++ b/drivers/net/can/Makefile
>> @@ -15,6 +15,7 @@ obj-$(CONFIG_CAN_SJA1000)	+= sja1000/
>>  obj-$(CONFIG_CAN_MSCAN)		+= mscan/
>>  obj-$(CONFIG_CAN_AT91)		+= at91_can.o
>>  obj-$(CONFIG_CAN_TI_HECC)	+= ti_hecc.o
>> +obj-$(CONFIG_CAN_TI_DA8XX_PRU)	+= pruss_can.o
>>  obj-$(CONFIG_CAN_MCP251X)	+= mcp251x.o
>>  obj-$(CONFIG_CAN_BFIN)		+= bfin_can.o
>>  obj-$(CONFIG_CAN_JANZ_ICAN3)	+= janz-ican3.o
>> diff --git a/drivers/net/can/pruss_can.c b/drivers/net/can/pruss_can.c
>> new file mode 100644
>> index 0000000..7702509
>> --- /dev/null
>> +++ b/drivers/net/can/pruss_can.c
...
> is this array const?
>> +static u32 pruss_intc_init[19][3] = {
>> +	{PRUSS_INTC_POLARITY0,		PRU_INTC_REGMAP_MASK,	0xFFFFFFFF},
>> +	{PRUSS_INTC_POLARITY1,		PRU_INTC_REGMAP_MASK,	0xFFFFFFFF},
>> +	{PRUSS_INTC_TYPE0,		PRU_INTC_REGMAP_MASK,	0x1C000000},
>> +	{PRUSS_INTC_TYPE1,		PRU_INTC_REGMAP_MASK,	0},
>> +	{PRUSS_INTC_GLBLEN,		0,			1},
>> +	{PRUSS_INTC_HOSTMAP0,		PRU_INTC_REGMAP_MASK,	0x03020100},
>> +	{PRUSS_INTC_HOSTMAP1,		PRU_INTC_REGMAP_MASK,	0x07060504},
>> +	{PRUSS_INTC_HOSTMAP2,		PRU_INTC_REGMAP_MASK,	0x0000908},
>> +	{PRUSS_INTC_CHANMAP0,		PRU_INTC_REGMAP_MASK,	0},
>> +	{PRUSS_INTC_CHANMAP8,		PRU_INTC_REGMAP_MASK,	0x00020200},
>> +	{PRUSS_INTC_STATIDXCLR,		0,			32},
>> +	{PRUSS_INTC_STATIDXCLR,		0,			19},
>> +	{PRUSS_INTC_ENIDXSET,		0,			19},
>> +	{PRUSS_INTC_STATIDXCLR,		0,			18},
>> +	{PRUSS_INTC_ENIDXSET,		0,			18},
>> +	{PRUSS_INTC_STATIDXCLR,		0,			34},
>> +	{PRUSS_INTC_ENIDXSET,		0,			34},
>> +	{PRUSS_INTC_ENIDXSET,		0,			32},
>> +	{PRUSS_INTC_HOSTINTEN,		0,			5}
> 
> please add ","

Also a struct to describe each entry would improve readability.
Then you could also use ARRAY_SIZE.

>> +};
...
>> +static int pru_can_set_bittiming(struct net_device *ndev)
>> +{
>> +	struct can_emu_priv *priv = netdev_priv(ndev);
>> +	struct can_bittiming *bt = &priv->can.bittiming;
>> +	u32 value;
>> +
>> +	value = priv->can.clock.freq / bt->bitrate;
>> +	pruss_writel(priv->dev, PRUSS_CAN_TIMING_VAL_TX, value);
>> +	pruss_writel(priv->dev, PRUSS_CAN_BIT_TIMING_VAL_RX, value);
>> +
>> +	value = (bt->phase_seg2 + bt->phase_seg1 +
>> +			bt->prop_seg + 1) * bt->brp;
>> +	value = (value >> 1) - PRUSS_CAN_TIMER_SETUP_DELAY;
>> +	value = (value << 16) | value;
>> +	pruss_writel(priv->dev, PRUSS_CAN_TIMING_VAL_RX, value);
>> +
>> +	value = (PRUSS_CAN_GPIO_SETUP_DELAY *
>> +		(priv->clk_freq_pru / 1000000) / 1000) /
>> +		PRUSS_CAN_DELAY_LOOP_LENGTH;

This calculation looks delicate. 64-bit math would be safer.

>> +
>> +	pruss_writel(priv->dev, PRUSS_CAN_TIMING_SETUP, value);
>> +	return 0;
>> +}
...
>> +static int pru_can_err(struct net_device *ndev, int int_status,
>> +			     int err_status)
>> +{
>> +	struct can_emu_priv *priv = netdev_priv(ndev);
>> +	struct net_device_stats *stats = &ndev->stats;
>> +	struct can_frame *cf;
>> +	struct sk_buff *skb;
>> +	u32 tx_err_cnt, rx_err_cnt;
>> +
>> +	skb = alloc_can_err_skb(ndev, &cf);
>> +	if (!skb) {
>> +		if (printk_ratelimit())
>> +			dev_err(priv->dev,
>> +				"alloc_can_err_skb() failed\n");
>> +		return -ENOMEM;
>> +	}
>> +
>> +	if (err_status & PRUSS_CAN_GSR_BIT_EPM) {	/* error passive int */
>> +		priv->can.state = CAN_STATE_ERROR_PASSIVE;
>> +		++priv->can.can_stats.error_passive;
>> +		cf->can_id |= CAN_ERR_CRTL;
>> +		tx_err_cnt = pru_can_get_error_cnt(priv->dev,
>> +						PRUSS_CAN_TX_PRU_1);
>> +		rx_err_cnt = pru_can_get_error_cnt(priv->dev,
>> +						PRUSS_CAN_RX_PRU_0);
>> +		if (tx_err_cnt > PRUSS_CAN_ERROR_ACTIVE - 1)
>> +			cf->data[1] |= CAN_ERR_CRTL_TX_PASSIVE;
>> +		if (rx_err_cnt > PRUSS_CAN_ERROR_ACTIVE - 1)
>> +			cf->data[1] |= CAN_ERR_CRTL_RX_PASSIVE;
>> +
>> +		dev_dbg(priv->ndev->dev.parent, "Error passive interrupt\n");
>> +	}
>> +
>> +	if (err_status & PRUSS_CAN_GSR_BIT_BFM) {
>> +		priv->can.state = CAN_STATE_BUS_OFF;
>> +		cf->can_id |= CAN_ERR_BUSOFF;
>> +		/*
>> +		 *      Disable all interrupts in bus-off to avoid int hog
>> +		 *      this should be handled by the pru
>> +		 */
>> +		pru_can_mask_ints(priv->dev, PRUSS_CAN_TX_PRU_1, false);
>> +		pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, false);
>> +		can_bus_off(ndev);
>> +		dev_dbg(priv->ndev->dev.parent, "Bus off mode\n");
>> +	}
>> +
>> +	netif_rx(skb);

You should use netif_receive_skb(skb) here as well.

>> +	stats->rx_packets++;
>> +	stats->rx_bytes += cf->can_dlc;
>> +	return 0;
>> +}
>> +
>> +static int pru_can_rx_poll(struct napi_struct *napi, int quota)
>> +{
>> +	struct net_device *ndev = napi->dev;
>> +	struct can_emu_priv *priv = netdev_priv(ndev);
>> +	u32 bit_set, mbxno = 0;
>> +	u32 num_pkts = 0;
>> +
>> +	if (!netif_running(ndev))
>> +		return 0;
>> +
>> +	do {
>> +		/* rx int sys_evt -> 33 */
>> +		pru_can_clr_intc_status(priv->dev, PRUSS_CAN_RX_PRU_0);
>> +		if (pru_can_intr_stat_get(priv->dev, &priv->can_rx_cntx))
>> +			return num_pkts;
>> +
>> +		if (PRUSS_CAN_ISR_BIT_RRI & priv->can_rx_cntx.intr_stat) {
>> +			mbxno = PRUSS_CAN_RTR_BUFF_NUM;
>> +			pru_can_rx(ndev, mbxno);
>> +			num_pkts++;
>> +		} else {
>> +			/* Extract the mboxno from the status */
>> +			bit_set = fls(priv->can_rx_cntx.intr_stat & 0xFF);
>> +			if (bit_set) {
>> +				num_pkts++;
>> +				mbxno = bit_set - 1;
>> +				if (PRUSS_CAN_ISR_BIT_ESI & priv->can_rx_cntx.
>> +				    intr_stat) {

				if (PRUSS_CAN_ISR_BIT_ESI &
				    priv->can_rx_cntx.intr_stat) {

Is more readable.


>> +					pru_can_gbl_stat_get(priv->dev,
>> +						&priv->can_rx_cntx);
>> +						pru_can_err(ndev,
>> +					priv->can_rx_cntx.intr_stat,
>> +					priv->can_rx_cntx.gbl_stat);

Please fix bogous indention.

>> +				} else
>> +					pru_can_rx(ndev, mbxno);
>> +			} else
>> +				break;
>> +		}
>> +	} while (((PRUSS_CAN_TX_INT_STAT & pru_can_get_intc_status(priv->dev))
>> +						&& (num_pkts < quota)));
>> +
>> +	/* Enable packet interrupt if all pkts are handled */
>> +	if (!(PRUSS_CAN_TX_INT_STAT & pru_can_get_intc_status(priv->dev))) {
>> +		napi_complete(napi);
>> +		/* Re-enable RX mailbox interrupts */
>> +		pru_can_mask_ints(priv->dev, PRUSS_CAN_RX_PRU_0, true);
>> +	}
>> +	return num_pkts;
>> +}
...
>> +/* Shows all the mailbox IDs */
>> +static ssize_t pru_sysfs_mbx_id_show(struct device *dev,
>> +		struct device_attribute *attr, char *buf)
>> +{
>> +	struct can_emu_priv *priv = netdev_priv(to_net_dev(dev));
>> +
>> +	return snprintf(buf, PAGE_SIZE, "<mbx_no:mbx_id>\n"
>> +					"0:0x%X 1:0x%X 2:0x%X 3:0x%X "
>> +					"4:0x%X 5:0x%X 6:0x%X 7:0x%X\n",
>> +					priv->mbx_id[0], priv->mbx_id[1],
>> +					priv->mbx_id[2], priv->mbx_id[3],
>> +					priv->mbx_id[4], priv->mbx_id[5],
>> +					priv->mbx_id[6], priv->mbx_id[7]);
>> +}

As mentioned above, just one value per sysfs file, please...

>> +/*
>> + * Sets Mailbox IDs
>> + * This should be programmed as mbx_num:mbx_id (in hex)
>> + * eg: $ echo 0:0x123 > /sys/class/net/can0/mbx_id
>> + */

... which would also avoid string parsing.

>> +static int __devinit pru_can_probe(struct platform_device *pdev)
>> +{
>> +	struct net_device *ndev = NULL;
>> +	const struct da850_evm_pruss_can_data *pdata;
>> +	struct can_emu_priv *priv = NULL;
>> +	struct device *dev = &pdev->dev;
>> +	struct clk *clk_pruss;
>> +	const struct firmware *fw_rx;
>> +	const struct firmware *fw_tx;
>> +	u32 err;
> use int
>> +
>> +	pdata = dev->platform_data;
>> +	if (!pdata) {
>> +		dev_err(&pdev->dev, "platform data not found\n");
>> +		return -EINVAL;
>> +	}
>> +	(pdata->setup)();
> 
> no need fot the ( )
> 
>> +
>> +	ndev = alloc_candev(sizeof(struct can_emu_priv), PRUSS_CAN_MB_MAX + 1);
>> +	if (!ndev) {
>> +		dev_err(&pdev->dev, "alloc_candev failed\n");
>> +		err = -ENOMEM;
>> +		goto probe_exit;
>> +	}
>> +
>> +	ndev->sysfs_groups[0] = &pru_sysfs_attr_group;
>> +
>> +	priv = netdev_priv(ndev);
>> +
>> +	priv->trx_irq = platform_get_irq(to_platform_device(dev->parent), 0);
>> +	if (!priv->trx_irq) {
>> +		dev_err(&pdev->dev, "unable to get pru "
>> +						"interrupt resources!\n");
>> +		err = -ENODEV;
>> +		goto probe_exit;
>> +	}
>> +
>> +	priv->ndev = ndev;
>> +	priv->dev = dev;
>> +
>> +	priv->can.bittiming_const = &pru_can_bittiming_const;
>> +	priv->can.do_set_bittiming = pru_can_set_bittiming;
>> +	priv->can.do_set_mode = pru_can_set_mode;
>> +	priv->can.do_get_state = pru_can_get_state;

Please remove that callback. It's not needed as state changes are
handled properly.

>> +	priv->can_tx_cntx.pruno = PRUSS_CAN_TX_PRU_1;
>> +	priv->can_rx_cntx.pruno = PRUSS_CAN_RX_PRU_0;
>> +
>> +	/* we support local echo, no arp */
>> +	ndev->flags |= (IFF_ECHO | IFF_NOARP);
> 
> no need to se NOARP
> 
>> +
>> +	/* pdev->dev->device_private->driver_data = ndev */
>> +	platform_set_drvdata(pdev, ndev);
>> +	SET_NETDEV_DEV(ndev, &pdev->dev);
>> +	ndev->netdev_ops = &pru_can_netdev_ops;
>> +
>> +	priv->clk_timer = clk_get(&pdev->dev, "pll1_sysclk2");
>> +	if (IS_ERR(priv->clk_timer)) {
>> +		dev_err(&pdev->dev, "no timer clock available\n");
>> +		err = PTR_ERR(priv->clk_timer);
>> +		priv->clk_timer = NULL;
>> +		goto probe_exit_candev;
>> +	}
>> +
>> +	priv->can.clock.freq = clk_get_rate(priv->clk_timer);
>> +
>> +	clk_pruss = clk_get(NULL, "pruss");
>> +	if (IS_ERR(clk_pruss)) {
>> +		dev_err(&pdev->dev, "no clock available: pruss\n");
>> +		err = -ENODEV;
>> +		goto probe_exit_clk;
>> +	}
>> +	priv->clk_freq_pru = clk_get_rate(clk_pruss);
>> +	clk_put(clk_pruss);
> 
> why do you put the clock here?
>> +
>> +	err = register_candev(ndev);
>> +	if (err) {
>> +		dev_err(&pdev->dev, "register_candev() failed\n");
>> +		err = -ENODEV;
>> +		goto probe_exit_clk;
>> +	}
>> +
>> +	err = request_firmware(&fw_tx, "PRU_CAN_Emulation_Tx.bin",
>> +			&pdev->dev);
>> +	if (err) {
>> +		dev_err(&pdev->dev, "can't load firmware\n");
>> +		err = -ENODEV;
>> +		goto probe_exit_clk;
>> +	}
>> +
>> +	dev_info(&pdev->dev, "fw_tx size %d. downloading...\n", fw_tx->size);
>> +
>> +	err = request_firmware(&fw_rx, "PRU_CAN_Emulation_Rx.bin",
>> +			&pdev->dev);
>> +	if (err) {
>> +		dev_err(&pdev->dev, "can't load firmware\n");
>> +		err = -ENODEV;
>> +		goto probe_release_fw;
>> +	}
>> +	dev_info(&pdev->dev, "fw_rx size %d. downloading...\n", fw_rx->size);
>> +
>> +	/* init the pru */
>> +	pru_can_emu_init(priv->dev, priv->can.clock.freq);
>> +	udelay(200);
>> +
>> +	netif_napi_add(ndev, &priv->napi, pru_can_rx_poll,
>> +					PRUSS_DEF_NAPI_WEIGHT);
> 
> personally I'd wait to add the interface to napi until the firmware is
> loaded.
> 
>> +
>> +	pruss_enable(priv->dev, PRUSS_CAN_RX_PRU_0);
>> +	pruss_enable(priv->dev, PRUSS_CAN_TX_PRU_1);
>> +
>> +	/* download firmware into pru */
>> +	err = pruss_load(priv->dev, PRUSS_CAN_RX_PRU_0,
>> +		(u32 *)fw_rx->data, (fw_rx->size / 4));
>> +	if (err) {
>> +		dev_err(&pdev->dev, "firmware download error\n");
>> +		err = -ENODEV;
>> +		goto probe_release_fw_1;
>> +	}
>> +	release_firmware(fw_rx);
>> +	err = pruss_load(priv->dev, PRUSS_CAN_TX_PRU_1,
>> +		(u32 *)fw_tx->data, (fw_tx->size / 4));
>> +	if (err) {
>> +		dev_err(&pdev->dev, "firmware download error\n");
>> +		err = -ENODEV;
>> +		goto probe_release_fw_1;
>> +	}
>> +	release_firmware(fw_tx);
>> +
>> +	pruss_run(priv->dev, PRUSS_CAN_RX_PRU_0);
>> +	pruss_run(priv->dev, PRUSS_CAN_TX_PRU_1);
>> +
>> +	dev_info(&pdev->dev,
>> +		 "%s device registered (trx_irq = %d,  clk = %d)\n",
>> +		 PRUSS_CAN_DRV_NAME, priv->trx_irq, priv->can.clock.freq);
>> +
>> +	return 0;
>> +
>> +probe_release_fw_1:
>> +	release_firmware(fw_rx);
>> +probe_release_fw:
>> +	release_firmware(fw_tx);
>> +probe_exit_clk:
>> +	clk_put(priv->clk_timer);
>> +probe_exit_candev:
>> +	if (NULL != ndev)
>> +		free_candev(ndev);
>> +probe_exit:
>> +	return err;
>> +}

Thanks,

Wolfgang.
