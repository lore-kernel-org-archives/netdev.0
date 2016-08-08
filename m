From: Wolfgang Grandegger <wg@grandegger.com>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Mon, 8 Aug 2016 14:28:39 +0200
Message-ID: <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: mkl@pengutronix.de, linux-can@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	davem@davemloft.net, jthumshirn@suse.de, andy@wernerandy.de,
	michael.miehling@men.de
To: Andreas Werner <andreas.werner@men.de>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20160808113938.GA17459@awelinux>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

Am 08.08.2016 um 13:39 schrieb Andreas Werner:
> On Mon, Aug 08, 2016 at 11:27:25AM +0200, Wolfgang Grandegger wrote:
>> Hello Andreas,
>>
>> a first quick review....
>>
>> Am 26.07.2016 um 11:16 schrieb Andreas Werner:
>>> This CAN Controller is found on MEN Chameleon FPGAs.
>>>
>>> The driver/device supports the CAN2.0 specification.
>>> There are 255 RX and 255 Tx buffer within the IP. The
>>> pointer for the buffer are handled by HW to make the
>>> access from within the driver as simple as possible.
>>>
>>> The driver also supports parameters to configure the
>>> buffer level interrupt for RX/TX as well as a RX timeout
>>> interrupt.
>>>
>>> With this configuration options, the driver/device
>>> provides flexibility for different types of usecases.
>>>
>>> Signed-off-by: Andreas Werner <andreas.werner@men.de>
>>> ---
>>> drivers/net/can/Kconfig        |  10 +
>>> drivers/net/can/Makefile       |   1 +
>>> drivers/net/can/men_z192_can.c | 989 +++++++++++++++++++++++++++++++++++++++++
>>> 3 files changed, 1000 insertions(+)
>>> create mode 100644 drivers/net/can/men_z192_can.c

---snip---

>>> +/* Buffer level control values */
>>> +#define MEN_Z192_MIN_BUF_LVL	0
>>> +#define MEN_Z192_MAX_BUF_LVL	254
>>> +#define MEN_Z192_RX_BUF_LVL_DEF	5
>>> +#define MEN_Z192_TX_BUF_LVL_DEF	5
>>> +#define MEN_Z192_RX_TOUT_MIN	0
>>> +#define MEN_Z192_RX_TOUT_MAX	65535
>>> +#define MEN_Z192_RX_TOUT_DEF	1000
>>> +
>>> +static int txlvl = MEN_Z192_TX_BUF_LVL_DEF;
>>> +module_param(txlvl, int, S_IRUGO);
>>> +MODULE_PARM_DESC(txlvl, "TX IRQ trigger level (in frames) 0-254, default="
>>> +		 __MODULE_STRING(MEN_Z192_TX_BUF_LVL_DEF) ")");
>>> +
>>> +static int rxlvl = MEN_Z192_RX_BUF_LVL_DEF;
>>> +module_param(rxlvl, int, S_IRUGO);
>>> +MODULE_PARM_DESC(rxlvl, "RX IRQ trigger level (in frames) 0-254, default="
>>> +		 __MODULE_STRING(MEN_Z192_RX_BUF_LVL_DEF) ")");
>>> +
>>
>> What impact does the level have on the latency? Could you please add some
>> comments.
>
> It has a impact on the latency.
> rxlvl = 0 -> if one frame got received, a IRQ will be generated
> rxlvl = 254 -> if 255 frames got received, a IRQ will be generated

Well, what's your usecase for rxlvl > 0? For me it's not obvious what it 
can be good for. The application usually wants the message as soon as 
possible. Anyway, the default should be *0*. For RX and TX.

>>> +static int rx_timeout = MEN_Z192_RX_TOUT_DEF;
>>> +module_param(rx_timeout, int, S_IRUGO);
>>> +MODULE_PARM_DESC(rx_timeout, "RX IRQ timeout (in 100usec steps), default="
>>> +		 __MODULE_STRING(MEN_Z192_RX_TOUT_DEF) ")");
>>
>> Ditto. What is "rx_timeout" good for.
>>
>
> The rx timeout is used im combination with the rxlvl to assert the
> if the buffer level is not reached within this timeout.

What event will the application receive in case of a timeout.

> Both, the timeout and the level are used to give the user as much
> control over the latency and the IRQ handling as possible.
> With this two options, the driver can be configured for different
> use cases.
 >
> I will add this as the comment to make it more clear.

Even a bit more would be appreciated.


---snip---

>>> +static int men_z192_read_frame(struct net_device *ndev, unsigned int frame_nr)
>>> +{
>>> +	struct net_device_stats *stats = &ndev->stats;
>>> +	struct men_z192 *priv = netdev_priv(ndev);
>>> +	struct men_z192_cf_buf __iomem *cf_buf;
>>> +	struct can_frame *cf;
>>> +	struct sk_buff *skb;
>>> +	u32 cf_offset;
>>> +	u32 length;
>>> +	u32 data;
>>> +	u32 id;
>>> +
>>> +	skb = alloc_can_skb(ndev, &cf);
>>> +	if (unlikely(!skb)) {
>>> +		stats->rx_dropped++;
>>> +		return 0;
>>> +	}
>>> +
>>> +	cf_offset = sizeof(struct men_z192_cf_buf) * frame_nr;
>>> +
>>> +	cf_buf = priv->dev_base + MEN_Z192_RX_BUF_START + cf_offset;
>>> +	length = readl(&cf_buf->length) & MEN_Z192_CFBUF_LEN;
>>> +	id = readl(&cf_buf->can_id);
>>> +
>>> +	if (id & MEN_Z192_CFBUF_IDE) {
>>> +		/* Extended frame */
>>> +		cf->can_id = (id & MEN_Z192_CFBUF_ID1) >> 3;
>>> +		cf->can_id |= (id & MEN_Z192_CFBUF_ID2) >>
>>> +				MEN_Z192_CFBUF_ID2_SHIFT;
>>> +
>>> +		cf->can_id |= CAN_EFF_FLAG;
>>> +
>>> +		if (id & MEN_Z192_CFBUF_E_RTR)
>>> +			cf->can_id |= CAN_RTR_FLAG;
>>> +	} else {
>>> +		/* Standard frame */
>>> +		cf->can_id = (id & MEN_Z192_CFBUF_ID1) >>
>>> +				MEN_Z192_CFBUF_ID1_SHIFT;
>>> +
>>> +		if (id & MEN_Z192_CFBUF_S_RTR)
>>> +			cf->can_id |= CAN_RTR_FLAG;
>>> +	}
>>> +
>>> +	cf->can_dlc = get_can_dlc(length);
>>> +
>>> +	/* remote transmission request frame
>>> +	 * contains no data field even if the
>>> +	 * data length is set to a value > 0
>>> +	 */
>>> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
>>> +		if (cf->can_dlc > 0) {
>>> +			data = readl(&cf_buf->data[0]);
>>> +			*(__be32 *)cf->data = cpu_to_be32(data);
>>
>> Do you really need the extra copy?
>>
>>> +		}
>>> +		if (cf->can_dlc > 4) {
>>> +			data = readl(&cf_buf->data[1]);
>>> +			*(__be32 *)(cf->data + 4) = cpu_to_be32(data);
>>
>> Ditto.
>
> No its not really needed. I thought its more clean and more readable than
> putting this in one line withouth the copy.

It should be fast in the first place.

>>
>>> +		}
>>> +	}
>>> +
>>> +	stats->rx_bytes += cf->can_dlc;
>>> +	stats->rx_packets++;
>>> +	netif_receive_skb(skb);
>>> +
>>> +	return 1;
>>
>>> +}

---snip---

>>> +static int men_z192_xmit(struct sk_buff *skb, struct net_device *ndev)
>>> +{
>>> +	struct can_frame *cf = (struct can_frame *)skb->data;
>>> +	struct men_z192 *priv = netdev_priv(ndev);
>>> +	struct men_z192_regs __iomem *regs = priv->regs;
>>> +	struct net_device_stats *stats = &ndev->stats;
>>> +	struct men_z192_cf_buf __iomem *cf_buf;
>>> +	u32 data[2] = {0, 0};
>>> +	int status;
>>> +	u32 id;
>>> +
>>> +	if (can_dropped_invalid_skb(ndev, skb))
>>> +		return NETDEV_TX_OK;
>>> +
>>> +	status = readl(&regs->rx_tx_sts);
>>> +
>>> +	if (MEN_Z192_TX_BUF_CNT(status) >= 255) {
>>> +		netif_stop_queue(ndev);
>>> +		netdev_err(ndev, "not enough space in TX buffer\n");
>>> +
>>> +		return NETDEV_TX_BUSY;
>>> +	}
>>
>> Please try to avoid NETDEV_TX_BUSY by stopping the queue earlier (if buf_cnt
>> == 254).
>>
>
> Agree with you, will fix that.
>
>>> +	cf_buf = priv->dev_base + MEN_Z192_TX_BUF_START;
>>> +
>>> +	if (cf->can_id & CAN_EFF_FLAG) {
>>> +		/* Extended frame */
>>> +		id = ((cf->can_id & CAN_EFF_MASK) <<
>>> +			MEN_Z192_CFBUF_ID2_SHIFT) & MEN_Z192_CFBUF_ID2;
>>> +
>>> +		id |= (((cf->can_id & CAN_EFF_MASK) >>
>>> +			(CAN_EFF_ID_BITS - CAN_SFF_ID_BITS)) <<
>>> +			 MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
>>> +
>>> +		id |= MEN_Z192_CFBUF_IDE;
>>> +		id |= MEN_Z192_CFBUF_SRR;
>>> +
>>> +		if (cf->can_id & CAN_RTR_FLAG)
>>> +			id |= MEN_Z192_CFBUF_E_RTR;
>>> +	} else {
>>> +		/* Standard frame */
>>> +		id = ((cf->can_id & CAN_SFF_MASK) <<
>>> +		       MEN_Z192_CFBUF_ID1_SHIFT) & MEN_Z192_CFBUF_ID1;
>>> +
>>> +		if (cf->can_id & CAN_RTR_FLAG)
>>> +			id |= MEN_Z192_CFBUF_S_RTR;
>>> +	}
>>> +
>>> +	if (cf->can_dlc > 0)
>>> +		data[0] = be32_to_cpup((__be32 *)(cf->data));
>>> +	if (cf->can_dlc > 3)
>>> +		data[1] = be32_to_cpup((__be32 *)(cf->data + 4));
>>
>> Not necessary if RTR.
>>
>
> Argh, right...
>
>>> +	writel(id, &cf_buf->can_id);
>>> +	writel(cf->can_dlc, &cf_buf->length);
>>> +
>>> +	if (!(cf->can_id & CAN_RTR_FLAG)) {
>>> +		writel(data[0], &cf_buf->data[0]);
>>> +		writel(data[1], &cf_buf->data[1]);
>>
>> Why do you not check cf->can_dlc here as well. And is the extra copy
>> necessary.
>>
>
> Yes, I agree with you. The extra copy could be also avoided.
>
>>> +
>>> +		stats->tx_bytes += cf->can_dlc;
>>> +	}
>>
>> If I look to other drivers, they write the data even in case of RTR.
>>
>
> But why?
>
> A RTR does not have any data, therefore there is no need to write the data.
> Only the length is required as the request size.

Yes; I'm wondering as well.

>
> If there is a reason behind writing the data of a RTR frame, I can
> change that, but for now there is no reason.

Yep.

>
>>> +	/* be sure everything is written to the
>>> +	 * device before acknowledge the data.
>>> +	 */
>>> +	mmiowb();
>>> +
>>> +	/* trigger the transmission */
>>> +	men_z192_ack_tx_pkg(priv, 1);
>>> +
>>> +	stats->tx_packets++;
>>> +
>>> +	kfree_skb(skb);
>>> +
>>> +	return NETDEV_TX_OK;
>>> +}
>>> +
>>> +static void men_z192_err_interrupt(struct net_device *ndev, u32 status)
>>> +{
>>> +	struct net_device_stats *stats = &ndev->stats;
>>> +	struct men_z192 *priv = netdev_priv(ndev);
>>> +	struct can_berr_counter bec;
>>> +	struct can_frame *cf;
>>> +	struct sk_buff *skb;
>>> +	enum can_state rx_state = 0, tx_state = 0;
>>> +
>>> +	skb = alloc_can_err_skb(ndev, &cf);
>>> +	if (unlikely(!skb))
>>> +		return;
>>> +
>>> +	/* put the rx/tx error counter to
>>> +	 * the additional controller specific
>>> +	 * section of the error frame.
>>> +	 */
>>> +	men_z192_get_berr_counter(ndev, &bec);
>>> +	cf->data[6] = bec.txerr;
>>> +	cf->data[7] = bec.rxerr;
>>> +
>>> +	/* overrun interrupt */
>>> +	if (status & MEN_Z192_RFLG_OVRF) {
>>> +		cf->can_id |= CAN_ERR_CRTL;
>>> +		cf->data[1] = CAN_ERR_CRTL_RX_OVERFLOW;
>>> +		stats->rx_over_errors++;
>>> +		stats->rx_errors++;
>>> +	}
>>> +
>>> +	/* bus change interrupt */
>>> +	if (status & MEN_Z192_RFLG_CSCIF) {
>>> +		rx_state = bus_state_map[MEN_Z192_GET_RSTATE(status)];
>>> +		tx_state = bus_state_map[MEN_Z192_GET_TSTATE(status)];
>>> +		can_change_state(ndev, cf, tx_state, rx_state);
>>> +
>>> +		if (priv->can.state == CAN_STATE_BUS_OFF)
>>> +			can_bus_off(ndev);
>>> +	}
>>
>> Does the controller only provide state change events? What about other
>> errors?
>>
>
> I thought that somebody will ask. The controller does only the state change events
> and the overrun error. Nothing more.
>
> I saw the error flags in many other drivers, but they are not existing
> in my controller.

No problem. Just to be sure.

>
>>> +
>>> +	stats->rx_packets++;
>>> +	stats->rx_bytes += cf->can_dlc;
>>> +	netif_receive_skb(skb);
>>> +}

---snip---

>>> +void men_z192_set_can_state(struct net_device *ndev)
>>> +{
>>> +	struct men_z192 *priv = netdev_priv(ndev);
>>> +	struct men_z192_regs __iomem *regs = priv->regs;
>>> +	enum can_state rx_state, tx_state;
>>> +	u32 status;
>>> +
>>> +	status = readl(&regs->rx_tx_sts);
>>> +
>>> +	rx_state = bus_state_map[MEN_Z192_GET_RSTATE(status)];
>>> +	tx_state = bus_state_map[MEN_Z192_GET_TSTATE(status)];
>>> +
>>> +	priv->can.state = max(tx_state, rx_state);
>>> +}
>>> +
>>> +static int men_z192_start(struct net_device *ndev)
>>> +{
>>> +	struct men_z192 *priv = netdev_priv(ndev);
>>> +	int ret;
>>> +
>>> +	ret = men_z192_req_init_mode(priv);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	ret = men_z192_set_bittiming(ndev);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	ret = men_z192_req_run_mode(priv);
>>> +	if (ret)
>>> +		return ret;
>>> +
>>> +	men_z192_init_idac(ndev);
>>> +
>>> +	/* The 16z192 CAN IP does not reset the can bus state
>>> +	 * if we enter the init mode. There is also
>>> +	 * no software reset to reset the state machine.
>>> +	 * We need to read the current state, and
>>> +	 * inform the upper layer about the current state.
>>> +	 */
>>> +	men_z192_set_can_state(ndev);
>>
>> Hm, the application expected the state to be reset. Calling
>> "can_change_state()" in "men_z192_set_can_state()" does make sense.
>>
>
> Hm yes, but the IP is saving the state, this cannot be avoided.
> can_change_state() makes sense yes, I will add it.
>
>>> +
>>> +	men_z192_set_int(priv, MEN_Z192_CAN_EN);
>>> +
>>> +	return 0;
>>> +}
>>> +

>>> +static int men_z192_set_mode(struct net_device *ndev, enum can_mode mode)
>>> +{
>>> +	int ret;
>>> +
>>> +	switch (mode) {
>>> +	case CAN_MODE_START:
>>> +		ret = men_z192_start(ndev);
>>> +		if (ret)
>>> +			return ret;
>>
>> "if (ret)" means always an error. Therefore s/ret/err/ is clearer. Here and
>> in many other places.
>>
>
> Yes and no. I think its a general question about the naming of those variables.
> I will check all the variables in the driver if it really makes sense
> to rename it.
>
> For my opinion, "ret" is more generic. But you are right, "err" would be more
> readable in some places.

	if (err)

makes immediately clear that it's an error case. ret is more general, 
e.g. for the return value of read/write:

         if (ret < 0)
		error-case
         else if (ret == 0)
		end-of-file
	else
		btyes-read
		
Just my personal preference to make the code more readable.

>>> +
>>> +		netif_wake_queue(ndev);
>>> +		break;
>>> +	default:
>>> +		return -EOPNOTSUPP;
>>> +	}
>>> +
>>> +	return 0;
>>> +static int men_z192_probe(struct mcb_device *mdev,
>>> +			  const struct mcb_device_id *id)
>>> +{
>>> +	struct device *dev = &mdev->dev;
>>> +	struct men_z192 *priv;
>>> +	struct net_device *ndev;
>>> +	void __iomem *dev_base;
>>> +	struct resource *mem;
>>> +	u32 timebase;
>>> +	int ret = 0;
>>> +	int irq;
>>> +
>>> +	mem = mcb_request_mem(mdev, dev_name(dev));
>>> +	if (IS_ERR(mem)) {
>>> +		dev_err(dev, "failed to request device memory");
>>> +		return PTR_ERR(mem);
>>> +	}
>>> +
>>> +	dev_base = ioremap(mem->start, resource_size(mem));
>>> +	if (!dev_base) {
>>> +		dev_err(dev, "failed to ioremap device memory");
>>> +		ret = -ENXIO;
>>> +		goto out_release;
>>> +	}
>>> +
>>> +	irq = mcb_get_irq(mdev);
>>> +	if (irq <= 0) {
>>> +		ret = -ENODEV;
>>> +		goto out_unmap;
>>> +	}
>>> +
>>> +	ndev = alloc_candev(sizeof(struct men_z192), 1);
>>
>> You specify here one echo_skb but it's not used anywhere. Local loopback
>> seems not to be implemented.
>>
>
> Agree with you, will set it to "0".

No, the local loopback is mandetory!

Wolfgang.
