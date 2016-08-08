From: Andreas Werner <andreas.werner@men.de>
Subject: Re: [PATCH RESEND] net: can: Introduce MEN 16Z192-00 CAN controller
 driver
Date: Mon, 8 Aug 2016 16:05:46 +0200
Message-ID: <20160808140546.GA1733@awelinux>
References: <20160726091555.GA26227@awelinux>
 <9487fe77-dbd0-3a64-b648-cf76b897feda@grandegger.com>
 <20160808113938.GA17459@awelinux>
 <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Andreas Werner <andreas.werner@men.de>, <mkl@pengutronix.de>,
	<linux-can@vger.kernel.org>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>, <davem@davemloft.net>,
	<jthumshirn@suse.de>, <andy@wernerandy.de>,
	<michael.miehling@men.de>
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <456c4f82-6a53-e821-3396-63d413db9eb7@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Aug 08, 2016 at 02:28:39PM +0200, Wolfgang Grandegger wrote:
> Hello,
> 
> Am 08.08.2016 um 13:39 schrieb Andreas Werner:
> >On Mon, Aug 08, 2016 at 11:27:25AM +0200, Wolfgang Grandegger wrote:
> >>Hello Andreas,
> >>
> >>a first quick review....
> >>
> >>Am 26.07.2016 um 11:16 schrieb Andreas Werner:
> >>>This CAN Controller is found on MEN Chameleon FPGAs.
> >>>
> >>>The driver/device supports the CAN2.0 specification.
> >>>There are 255 RX and 255 Tx buffer within the IP. The
> >>>pointer for the buffer are handled by HW to make the
> >>>access from within the driver as simple as possible.
> >>>
> >>>The driver also supports parameters to configure the
> >>>buffer level interrupt for RX/TX as well as a RX timeout
> >>>interrupt.
> >>>
> >>>With this configuration options, the driver/device
> >>>provides flexibility for different types of usecases.
> >>>
> >>>Signed-off-by: Andreas Werner <andreas.werner@men.de>
> >>>---
> >>>drivers/net/can/Kconfig        |  10 +
> >>>drivers/net/can/Makefile       |   1 +
> >>>drivers/net/can/men_z192_can.c | 989 +++++++++++++++++++++++++++++++++++++++++
> >>>3 files changed, 1000 insertions(+)
> >>>create mode 100644 drivers/net/can/men_z192_can.c
> 
> ---snip---
> 
> >>>+/* Buffer level control values */
> >>>+#define MEN_Z192_MIN_BUF_LVL	0
> >>>+#define MEN_Z192_MAX_BUF_LVL	254
> >>>+#define MEN_Z192_RX_BUF_LVL_DEF	5
> >>>+#define MEN_Z192_TX_BUF_LVL_DEF	5
> >>>+#define MEN_Z192_RX_TOUT_MIN	0
> >>>+#define MEN_Z192_RX_TOUT_MAX	65535
> >>>+#define MEN_Z192_RX_TOUT_DEF	1000
> >>>+
> >>>+static int txlvl = MEN_Z192_TX_BUF_LVL_DEF;
> >>>+module_param(txlvl, int, S_IRUGO);
> >>>+MODULE_PARM_DESC(txlvl, "TX IRQ trigger level (in frames) 0-254, default="
> >>>+		 __MODULE_STRING(MEN_Z192_TX_BUF_LVL_DEF) ")");
> >>>+
> >>>+static int rxlvl = MEN_Z192_RX_BUF_LVL_DEF;
> >>>+module_param(rxlvl, int, S_IRUGO);
> >>>+MODULE_PARM_DESC(rxlvl, "RX IRQ trigger level (in frames) 0-254, default="
> >>>+		 __MODULE_STRING(MEN_Z192_RX_BUF_LVL_DEF) ")");
> >>>+
> >>
> >>What impact does the level have on the latency? Could you please add some
> >>comments.
> >
> >It has a impact on the latency.
> >rxlvl = 0 -> if one frame got received, a IRQ will be generated
> >rxlvl = 254 -> if 255 frames got received, a IRQ will be generated
> 
> Well, what's your usecase for rxlvl > 0? For me it's not obvious what it can
> be good for. The application usually wants the message as soon as possible.
> Anyway, the default should be *0*. For RX and TX.
> 

The HW provides such feature and the driver should be able to control it.
It was developed to control the IRQ load (like NAPI) by defining a level of the buffer
when the IRQ got asserted.

I aggree with you to set the default to "0" which is the main usecase.

> >>>+static int rx_timeout = MEN_Z192_RX_TOUT_DEF;
> >>>+module_param(rx_timeout, int, S_IRUGO);
> >>>+MODULE_PARM_DESC(rx_timeout, "RX IRQ timeout (in 100usec steps), default="
> >>>+		 __MODULE_STRING(MEN_Z192_RX_TOUT_DEF) ")");
> >>
> >>Ditto. What is "rx_timeout" good for.
> >>
> >
> >The rx timeout is used im combination with the rxlvl to assert the
> >if the buffer level is not reached within this timeout.
> 
> What event will the application receive in case of a timeout.
> 

Its just to control the time when the RX IRQ will be asserted if the buffer
level is not reached.
Imagine if the rx_timeout is not existing and the rxlvl is set to 50 and 
only 30 packets are received. The RX IRQ will be never asserted.

By defining the rx_timeout, we can control the time when the RX IRQ is asserted
if the buffer level is not reached.

The application does not receive any special signal, its just the RX IRQ.

> >Both, the timeout and the level are used to give the user as much
> >control over the latency and the IRQ handling as possible.
> >With this two options, the driver can be configured for different
> >use cases.
> >
> >I will add this as the comment to make it more clear.
> 
> Even a bit more would be appreciated.
> 

Sure...

> 
> ---snip---
> 
> >>>+static int men_z192_read_frame(struct net_device *ndev, unsigned int frame_nr)
> >>>+{
> >>>+	struct net_device_stats *stats = &ndev->stats;
> >>>+	struct men_z192 *priv = netdev_priv(ndev);
> >>>+	struct men_z192_cf_buf __iomem *cf_buf;
> >>>+	struct can_frame *cf;
> >>>+	struct sk_buff *skb;
> >>>+	u32 cf_offset;
> >>>+	u32 length;
> >>>+	u32 data;
> >>>+	u32 id;
> >>>+
> >>>+	skb = alloc_can_skb(ndev, &cf);
> >>>+	if (unlikely(!skb)) {
> >>>+		stats->rx_dropped++;
> >>>+		return 0;
> >>>+	}
> >>>+
> >>>+	cf_offset = sizeof(struct men_z192_cf_buf) * frame_nr;
> >>>+
> >>>+	cf_buf = priv->dev_base + MEN_Z192_RX_BUF_START + cf_offset;
> >>>+	length = readl(&cf_buf->length) & MEN_Z192_CFBUF_LEN;
> >>>+	id = readl(&cf_buf->can_id);
> >>>+
> >>>+	if (id & MEN_Z192_CFBUF_IDE) {
> >>>+		/* Extended frame */
> >>>+		cf->can_id = (id & MEN_Z192_CFBUF_ID1) >> 3;
> >>>+		cf->can_id |= (id & MEN_Z192_CFBUF_ID2) >>
> >>>+				MEN_Z192_CFBUF_ID2_SHIFT;
> >>>+
> >>>+		cf->can_id |= CAN_EFF_FLAG;
> >>>+
> >>>+		if (id & MEN_Z192_CFBUF_E_RTR)
> >>>+			cf->can_id |= CAN_RTR_FLAG;
> >>>+	} else {
> >>>+		/* Standard frame */
> >>>+		cf->can_id = (id & MEN_Z192_CFBUF_ID1) >>
> >>>+				MEN_Z192_CFBUF_ID1_SHIFT;
> >>>+
> >>>+		if (id & MEN_Z192_CFBUF_S_RTR)
> >>>+			cf->can_id |= CAN_RTR_FLAG;
> >>>+	}
> >>>+
> >>>+	cf->can_dlc = get_can_dlc(length);
> >>>+
> >>>+	/* remote transmission request frame
> >>>+	 * contains no data field even if the
> >>>+	 * data length is set to a value > 0
> >>>+	 */
> >>>+	if (!(cf->can_id & CAN_RTR_FLAG)) {
> >>>+		if (cf->can_dlc > 0) {
> >>>+			data = readl(&cf_buf->data[0]);
> >>>+			*(__be32 *)cf->data = cpu_to_be32(data);
> >>
> >>Do you really need the extra copy?
> >>
> >>>+		}
> >>>+		if (cf->can_dlc > 4) {
> >>>+			data = readl(&cf_buf->data[1]);
> >>>+			*(__be32 *)(cf->data + 4) = cpu_to_be32(data);
> >>
> >>Ditto.
> >
> >No its not really needed. I thought its more clean and more readable than
> >putting this in one line withouth the copy.
> 
> It should be fast in the first place.
> 

Ok, will change that.

[...]

> 
> >>>+static int men_z192_set_mode(struct net_device *ndev, enum can_mode mode)
> >>>+{
> >>>+	int ret;
> >>>+
> >>>+	switch (mode) {
> >>>+	case CAN_MODE_START:
> >>>+		ret = men_z192_start(ndev);
> >>>+		if (ret)
> >>>+			return ret;
> >>
> >>"if (ret)" means always an error. Therefore s/ret/err/ is clearer. Here and
> >>in many other places.
> >>
> >
> >Yes and no. I think its a general question about the naming of those variables.
> >I will check all the variables in the driver if it really makes sense
> >to rename it.
> >
> >For my opinion, "ret" is more generic. But you are right, "err" would be more
> >readable in some places.
> 
> 	if (err)
> 
> makes immediately clear that it's an error case. ret is more general, e.g.
> for the return value of read/write:
> 
>         if (ret < 0)
> 		error-case
>         else if (ret == 0)
> 		end-of-file
> 	else
> 		btyes-read
> 		
> Just my personal preference to make the code more readable.

Ok, I will think about it.

> 
> >>>+
> >>>+		netif_wake_queue(ndev);
> >>>+		break;
> >>>+	default:
> >>>+		return -EOPNOTSUPP;
> >>>+	}
> >>>+
> >>>+	return 0;
> >>>+static int men_z192_probe(struct mcb_device *mdev,
> >>>+			  const struct mcb_device_id *id)
> >>>+{
> >>>+	struct device *dev = &mdev->dev;
> >>>+	struct men_z192 *priv;
> >>>+	struct net_device *ndev;
> >>>+	void __iomem *dev_base;
> >>>+	struct resource *mem;
> >>>+	u32 timebase;
> >>>+	int ret = 0;
> >>>+	int irq;
> >>>+
> >>>+	mem = mcb_request_mem(mdev, dev_name(dev));
> >>>+	if (IS_ERR(mem)) {
> >>>+		dev_err(dev, "failed to request device memory");
> >>>+		return PTR_ERR(mem);
> >>>+	}
> >>>+
> >>>+	dev_base = ioremap(mem->start, resource_size(mem));
> >>>+	if (!dev_base) {
> >>>+		dev_err(dev, "failed to ioremap device memory");
> >>>+		ret = -ENXIO;
> >>>+		goto out_release;
> >>>+	}
> >>>+
> >>>+	irq = mcb_get_irq(mdev);
> >>>+	if (irq <= 0) {
> >>>+		ret = -ENODEV;
> >>>+		goto out_unmap;
> >>>+	}
> >>>+
> >>>+	ndev = alloc_candev(sizeof(struct men_z192), 1);
> >>
> >>You specify here one echo_skb but it's not used anywhere. Local loopback
> >>seems not to be implemented.
> >>
> >
> >Agree with you, will set it to "0".
> 
> No, the local loopback is mandetory!
> 

Hm ok, but if i check alloc_candev() in drivers/net/can/dev.c
it is not mandatory. In the Documentation/networking/can.txt
there is also a "should" and a fallback mechnism if the driver
does not support the local loopback.
I'm currently ok with this fallback mechanism.

Anyway I am not sure that the driver can handle the echo skb correctly.
If i understand it correctly, the can_get_echo_skb() is normally called
on a "TX done IRQ" to get the skb and loop it back. 
I do not have such a "TX done IRQ" and have not implemented implemented
and added the local looback.

May be I can put and get the echo skb within the xmit function?
Does this make sense?

Regards
Andy


> Wolfgang.
