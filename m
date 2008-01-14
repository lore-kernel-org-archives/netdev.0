From: Andrew Morton <akpm@linux-foundation.org>
Subject: Re: [PATCH 1/3] drivers/misc :UCC based TDM driver for MPC83xx
 platforms.
Date: Mon, 14 Jan 2008 13:14:41 -0800
Message-ID: <20080114131441.878979d2.akpm@linux-foundation.org>
References: <Pine.LNX.4.64.0712101710270.29623@linux121>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: rubini@vision.unipv.it, linux-kernel@vger.kernel.org,
	linuxppc-dev@ozlabs.org, netdev@vger.kernel.org,
	kumar.gala@freescale.co, michael.barkowski@freescale.com,
	kim.phillips@freescale.com, ashish.kalra@freescale.com,
	rich.cutler@freescale.com
To: Poonam_Aggrwal-b10812 <b10812@freescale.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:50685 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751208AbYANVPA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Jan 2008 16:15:00 -0500
In-Reply-To: <Pine.LNX.4.64.0712101710270.29623@linux121>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 10 Dec 2007 17:34:44 +0530 (IST)
Poonam_Aggrwal-b10812 <b10812@freescale.com> wrote:

> From: Poonam Aggrwal <b10812@freescale.com>
> 
> The UCC TDM driver basically multiplexes and demultiplexes data from 
> different channels. It can interface with for example SLIC kind of devices 
> to receive TDM data  demultiplex it and send to upper applications. At the 
> transmit end it receives data for different channels multiplexes it and 
> sends them on the TDM channel. It internally uses TSA( Time Slot Assigner) 
> which does multiplexing and demultiplexing, UCC to perform SDMA between 
> host buffers and the TSA, CMX to connect TSA to UCC.
> 
> This driver will run on MPC8323E-RDB platforms.
> 
> ...
>
> +#define PREV_PHASE(x) ((x == 0) ? MAX_PHASE : (x - 1))
> +#define NEXT_PHASE(x) (((x + 1) > MAX_PHASE) ? 0 : (x + 1))

These macros can reference their arg more than once and are hence
dangerous.  What does PREV_PHASE(foo++) do to foo?

And, in general: do not implement in cpp that which could have been
implemented in C.

> +static struct ucc_tdm_info utdm_primary_info = {
> +	.uf_info = {
> +		.tsa = 1,
> +		.cdp = 1,
> +		.cds = 1,
> +		.ctsp = 1,
> +		.ctss = 1,
> +		.revd = 1,
> +		.urfs = 0x128,
> +		.utfs = 0x128,
> +		.utfet = 0,
> +		.utftt = 0x128,
> +		.ufpt = 256,
> +		.ttx_trx = UCC_FAST_GUMR_TRANSPARENT_TTX_TRX_TRANSPARENT,
> +		.tenc = UCC_FAST_TX_ENCODING_NRZ,
> +		.renc = UCC_FAST_RX_ENCODING_NRZ,
> +		.tcrc = UCC_FAST_16_BIT_CRC,
> +		.synl = UCC_FAST_SYNC_LEN_NOT_USED,
> +	},
> +	.ucc_busy = 0,
> +};
> +
> +static struct ucc_tdm_info utdm_info[8];
> +
> +static void dump_siram(struct tdm_ctrl *tdm_c)
> +{
> +#if defined(DEBUG)

Microscopic note: kernel code tends to do

	#ifdef FOO

if only one identifier is being tested and

	#if defined(FOO) && defined(BAR)

if more than one is being tested.

There is no rational reason for this ;)

> +	int i;
> +	u16 phy_num_ts;
> +
> +	phy_num_ts = tdm_c->physical_num_ts;
> +
> +	pr_debug("SI TxRAM dump\n");
> +	/* each slot entry in SI RAM is of 2 bytes */
> +	for (i = 0; i < phy_num_ts * 2; i++)
> +		pr_debug("%x ", in_8(&qe_immr->sir.tx[i]));
> +	pr_debug("\nSI RxRAM dump\n");
> +	for (i = 0; i < phy_num_ts * 2; i++)
> +		pr_debug("%x ", in_8(&qe_immr->sir.rx[i]));
> +	pr_debug("\n");
> +#endif
> +}
> +
> +/*
> + * converts u-law compressed samples to linear PCM
> + * If the CONFIG_TDM_LINEAR_PCM flag is not set the
> + * TDM driver receives u-law compressed data from the
> + * SLIC device. This function converts the compressed
> + * data to linear PCM and sends it to upper layers.
> + */
> +static inline int ulaw2int(unsigned char log)
> +{
> +	u32 sign, segment, temp, quant;
> +	int val;
> +
> +	temp = log ^ 0xFF;
> +	sign = (temp & 0x80) >> 7;
> +	segment = (temp & 0x70) >> 4;
> +	quant = temp & 0x0F;
> +	quant <<= 1;
> +	quant += 33;
> +	quant <<= segment;
> +	if (sign)
> +		val = 33 - quant;
> +	else
> +		val = quant - 33;
> +
> +	val *= 4;
> +	return val;
> +}
> +
> +/*
> + * converts linear PCM samples to u-law compressed format.
> + * If the CONFIG_TDM_LINEAR_PCM flag is not set the
> + * TDM driver calls this function to convert the PCM samples
> + * to u-law compressed format before sending them to SLIC
> + * device.
> + */
> +static inline u8 int2ulaw(short linear)
> +{
> +	u8  quant, ret;
> +	u16 output, absol, temp;
> +	u32 i, sign;
> +	char segment;
> +
> +	ret = 0;
> +	if (linear >= 0)
> +		linear = (linear >> 2);
> +	else
> +		linear = (0xc000 | (linear >> 2));
> +
> +	absol = abs(linear) + 33;
> +	temp = absol;
> +	sign = (linear >= 0) ? 1 : 0;
> +	for (i = 0; i < 16; i++) {
> +		output = temp & 0x8000;
> +		if (output)
> +			break;
> +		temp <<= 1;
> +	}
> +	segment = 11 - i;
> +	quant = (absol >> segment) & 0x0F;
> +	segment--;
> +	segment <<= 4;
> +	output = segment + quant;
> +	if (absol > 8191)
> +		output = 0x7F;
> +	if (sign)
> +		ret ^= 0xFF;
> +	else
> +		ret ^= 0x7F;
> +	return ret;
> +}

hrm, how many copies of ulaw/alaw conversion functions do we need in the
tree before someone writes a library function for it?

> +	out_be16(&rx_bd->status, bd_status);
> +	out_be32(&rx_bd->buf,
> +		 tdm_c->dma_input_addr + i * SAMPLE_DEPTH * act_num_ts);
> +
> +	bd_status = (u16) ((T_R | T_CM | T_W) >> 16);
> +	bd_len =  SAMPLE_DEPTH * act_num_ts;
> +	out_be16(&tx_bd->length, bd_len);
> +	out_be16(&tx_bd->status, bd_status);
> +	out_be32(&tx_bd->buf,
> +		 tdm_c->dma_output_addr + i * SAMPLE_DEPTH * act_num_ts);
> +
> +	config_si(tdm_c);
> +
> +	setbits32(&qe_immr->ic.qimr, (0x80000000 >> ucc));

The compiler treats 0xNNN constants as unsigned so this works OK.  I'd have
put a UL on the end of the constant to be sure ;)

> +static int tdm_start(struct tdm_ctrl *tdm_c)
> +{
> +	if (request_irq(tdm_c->ut_info->uf_info.irq, tdm_isr,
> +					0, "tdm", tdm_c)) {
> +		printk(KERN_ERR "%s: request_irq for tdm_isr failed\n",
> +			__FUNCTION__);
> +		return -ENODEV;
> +	}
> +
> +	ucc_fast_enable(tdm_c->uf_private, COMM_DIR_RX | COMM_DIR_TX);
> +
> +#if !defined(CONFIG_TDM_LINEAR_PCM)
> +	pr_info("%s 8-bit u-law compressed mode active\n", __FUNCTION__);
> +#else
> +	pr_info("%s 16-bit linear pcm mode active with"
> +		" slots 0 & 2\n", __FUNCTION__);
> +#endif

Is this the sort of thing which should be controlled at compile-time?  I'd
have thought that a runtime control would be more appropriate (a sysfs knob
or a module parameter).  Or just work it out automagically?


> +	dump_siram(tdm_c);
> +	dump_ucc(tdm_c);
> +
> +	setbits8(&(qe_immr->si1.siglmr1_h), (0x1 << tdm_c->tdm_port));
> +	pr_info("%s UCC based TDM enabled\n", __FUNCTION__);
> +
> +	return 0;
> +}
>
> ...
>
> +static void tdm_read(u32 driver_handle, short chn_id, short *pcm_buffer,
> +								short len)
> +{
> +	int i;
> +	u32 phase_rx;
> +	/* point to where to start for the current phase data processing */
> +	u32 temp_rx;
> +
> +	struct tdm_ctrl *tdm_c = (struct tdm_ctrl *)(driver_handle);

eek.  What are we doing here, casting a 32-bit quantity to a kernel pointer?

a) Seems to rule out ever using this driver on a 64-bit system

b) It's generally suspicious and indicates that some rethinking is needed.

> +#if !defined(CONFIG_TDM_LINEAR_PCM)
> +	u8 *input_tdm_buffer = tdm_c->tdm_input_data;
> +
> +#else
> +	u16 *input_tdm_buffer =
> +		(u16 *)tdm_c->tdm_input_data;
> +
> +#endif
> +	phase_rx = tdm_c->phase_rx;
> +	phase_rx = PREV_PHASE(phase_rx);
> +
> +	temp_rx = phase_rx * SAMPLE_DEPTH * EFF_ACTIVE_CH;
> +
> +#if defined(UCC_CACHE_SNOOPING_DISABLED)
> +	flush_dcache_range((size_t) &input_tdm_buffer[temp_rx],
> +				(size_t) &input_tdm_buffer[temp_rx +
> +						SAMPLE_DEPTH * ACTIVE_CH]);
> +#endif

Again, is it appropriate that this behaviour be determined at compile-time?
This is very user- and packager- and distributor-unfriendly.

> +	for (i = 0; i < len; i++) {
> +#if !defined(CONFIG_TDM_LINEAR_PCM)
> +		pcm_buffer[i] =
> +			ulaw2int(input_tdm_buffer[i * EFF_ACTIVE_CH +
> +						temp_rx + chn_id]);
> +#else
> +		pcm_buffer[i] =
> +			input_tdm_buffer[i * EFF_ACTIVE_CH + temp_rx + chn_id];
> +#endif
> +
> +	}
> +
> +}
> +
> +static int ucc_tdm_probe(struct of_device *ofdev,
> +			 const struct of_device_id *match)
> +{
> +	struct device_node *np = ofdev->node;
> +	struct resource res;
> +	const unsigned int *prop;
> +	u32 ucc_num, device_num, err, ret = 0;
> +	struct device_node *np_tmp = NULL;
> +	dma_addr_t physaddr;
> +	void *tdm_buff;
> +	struct ucc_tdm_info *ut_info;
> +
> +	prop = of_get_property(np, "device-id", NULL);
> +	ucc_num = *prop - 1;
> +	if ((ucc_num < 0) || (ucc_num > 7))
> +		return -ENODEV;
> +
> +	ut_info = &utdm_info[ucc_num];
> +	if (ut_info == NULL) {
> +		printk(KERN_ERR "additional data missing\n");
> +		return -ENODEV;
> +	}
> +	if (ut_info->ucc_busy) {
> +		printk(KERN_ERR "UCC in use by another TDM driver instance\n");
> +		return -EBUSY;
> +	}
> +
> +	ut_info->ucc_busy = 1;
> +	tdm_ctrl[num_tdm_devices++] =
> +		kzalloc(sizeof(struct tdm_ctrl), GFP_KERNEL);

Shouldn't this check for (num_tdm_devices > MAX_NUM_TDM_DEVICES))?

> +	if (!tdm_ctrl[num_tdm_devices - 1]) {
> +		printk(KERN_ERR "%s: no memory to allocate for"
> +			" tdm control structure\n", __FUNCTION__);
> +		num_tdm_devices--;
> +		return -ENOMEM;
> +	}
> +	device_num = num_tdm_devices - 1;
> +
> +	tdm_ctrl[device_num]->device = &ofdev->dev;
> +	tdm_ctrl[device_num]->ut_info = ut_info;
> +
> +	tdm_ctrl[device_num]->ut_info->uf_info.ucc_num = ucc_num;
> +
> +	prop = of_get_property(np, "fsl,tdm-num", NULL);
> +	if (prop == NULL) {
> +		ret = -EINVAL;
> +		goto get_property_error;
> +	}
>
> ...
>
> +
> +#define SET_RX_SI_RAM(n, val)		\
> +		out_be16((u16 *)&qe_immr->sir.rx[(n)*2], (u16)(val))
> +
> +#define SET_TX_SI_RAM(n, val)		\
> +		out_be16((u16 *)&qe_immr->sir.tx[(n)*2], (u16)(val))

I don't think there's anything which requires that these be imlemented in
the preprocessor?

> +struct tdm_cfg {
> +	u8 com_pin;		/* Common receive and transmit pins
> +				 * 0 = separate pins
> +				 * 1 = common pins
> +				 */
> +
> +	u8 fr_sync_level;	/* SLx bit Frame Sync Polarity
> +				 * 0 = L1R/TSYNC active logic "1"
> +				 * 1 = L1R/TSYNC active logic "0"
> +				 */
> +
> +	u8 clk_edge;		/* CEx bit Tx Rx Clock Edge
> +				 * 0 = TX data on rising edge of clock
> +				 * RX data on falling edge
> +				 * 1 = TX data on falling edge of clock
> +				 * RX data on rising edge
> +				 */
> +
> +	u8 fr_sync_edge;	/* FEx bit Frame sync edge
> +				 * Determine when the sync pulses are sampled
> +				 * 0 = Falling edge
> +				 * 1 = Rising edge
> +				 */
> +
> +	u8 rx_fr_sync_delay;	/* TFSDx/RFSDx bits Frame Sync Delay
> +				 * 00 = no bit delay
> +				 * 01 = 1 bit delay
> +				 * 10 = 2 bit delay
> +				 * 11 = 3 bit delay
> +				 */
> +
> +	u8 tx_fr_sync_delay;	/* TFSDx/RFSDx bits Frame Sync Delay
> +				 * 00 = no bit delay
> +				 * 01 = 1 bit delay
> +				 * 10 = 2 bit delay
> +				 * 11 = 3 bit delay
> +				 */
> +
> +	u8 active_num_ts;	/* Number of active time slots in TDM
> +				 * assume same active Rx/Tx time slots
> +				 */
> +};

Nice commenting.


