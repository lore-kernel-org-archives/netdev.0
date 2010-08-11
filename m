From: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Subject: Re: [MeeGo-Dev][PATCH] Topcliff: Update PCH_CAN driver to 2.6.35
Date: Wed, 11 Aug 2010 14:31:23 +0200
Message-ID: <4C62981B.8050402@grandegger.com>
References: <4C61EDE5.4030505@dsn.okisemi.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: andrew.chih.howe.khor-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, qi.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	gregkh-l3A5Bk7waGM@public.gmane.org, yong.y.wang-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, meego-dev-WXzIur8shnEAvxtiuMwx3w@public.gmane.org, arjan-VuQAYsv1563Yd54FQh9/CA@public.gmane.org
To: Masayuki Ohtak <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <4C61EDE5.4030505-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>
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

Hello,

On 08/11/2010 02:25 AM, Masayuki Ohtak wrote:
> CAN driver of Topcliff PCH
> 
> Topcliff PCH is the platform controller hub that is going to be used in
> Intel's upcoming general embedded platform. All IO peripherals in
> Topcliff PCH are actually devices sitting on AMBA bus. 

That's interesting. Where can I/we find more information about this CAN
controller, e.g. data-sheets. It seems to have a few interesting
features (message scheduler, etc.).

> Topcliff PCH has CAN I/F. This driver enables CAN function.
> 
> Signed-off-by: Masayuki Ohtake <masa-korg-ECg8zkTtlr0C6LszWs/t0g@public.gmane.org>

Thanks for your contribution. Unfortunately, there are many issues,
especially the driver is not yet conform with the Socket-CAN driver API:

- My first observation was:

  $ wc -l pch_can.c
  4076 pch_can.c
  $ grep dev_dbg pch_can.c | wc -l
  143

  That's a lot of code, mainly debugging code, I think. This needs to
  be cleaned up sooner than later. dev_dbg's should be restricted to a
  few useful for the real users.

- The values for the hw-specific bit-timing registers should be derived
  from the calculated values in "priv->can.bittiming":

  http://lxr.linux.no/#linux+v2.6.35/include/linux/can/netlink.h#L17

- The driver should handle state changes and communicate them to the
  user space via error messages, if possible.

- The driver should report errors to the user space via error messages.

- Bus errors seem not to be handled properly.I'm missing can_bus_off().
  Does the controller recover from bus-off automatically?

- I see that the driver uses many TX and RX objects. How do you avoid
  out-of-order transmission and reception?

- Various CAN controller modes, like listen_only and loopback can be
  handled via "priv->can.ctrlmode". Please use that interface if
  appropriate.

- Please use a structure to describe the register layout, instead of
  defines to profit from type checking.

- As you are at it, please also fix coding style issues, especially for
  comments as described here:

  http://lxr.linux.no/#linux+v2.6.35/Documentation/CodingStyle#L425

You can take the SJA1000 driver as example. Further useful information
is here:

 http://lxr.linux.no/#linux+v2.6.35/Documentation/networking/can.txt
 http://svn.berlios.de/wsvn/socketcan/trunk/README.submitting-patches

It follows a quick review. It's to early for a detailed one:

...

> +/* Array to store the timing settings. */
> +static struct pch_can_timing can_rec_timing[] = {
> +	/* <Baud rate>   <BRP>   <TS1>   <TS2>   <SJW> */
> +	/* settings for 62.5MHz */
> +	{0xa, 0x250, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 10 kbits/s */
> +	{0x14, 0x8D, 0xB, 0x5, 0x0, 0x0, 0x0},	/* < 20 kbits/s */
> +	{0x32, 0x5C, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 50 kbits/s */
> +	{0x7d, 0x18, 0xC, 0x5, 0x0, 0x0, 0x0},	/* < 125 kbits/s */
> +	{0xfa, 0x18, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 250 kbits/s */
> +	{0x1f4, 0x8, 0x9, 0x2, 0x0, 0x0, 0x0},	/* < 500 kbits/s */
> +	{0x320, 0x5, 0x8, 0x2, 0x0, 0x0, 0x0},	/* < 800 kbits/s  */
> +	{0x3e8, 0x2, 0xC, 0x6, 0x0, 0x0, 0x0},	/* < 1000 kbits/s */
> +
> +	/* settings for 24MHz */
> +	{0xa, 0xCF, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 10 kbits/s */
> +	{0x14, 0x57, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 20 kbits/s */
> +	{0x32, 0xF, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 50 kbits/s */
> +	{0x7d, 0xF, 0x8, 0x1, 0x0, 0x0, 0x0},	/* < 125 kbits/s */
> +	{0xfa, 0x7, 0x8, 0x1, 0x0, 0x0, 0x0},	/* < 250 kbits/s */
> +	{0x1f4, 0x3, 0x8, 0x1, 0x0, 0x0, 0x0},	/* < 500 kbits/s */
> +	{0x320, 0x2, 0x7, 0x0, 0x0, 0x0, 0x0},	/* < 800 kbits/s  */
> +	{0x3e8, 0x1, 0x8, 0x1, 0x0, 0x0, 0x0},	/* < 1000 kbits/s */
> +
> +	/* settings for 50MHz */
> +	{0xa, 0xFA, 0xC, 0x5, 0x1, 0x0, 0x0},	/* < 10 kbits/s */
> +	{0x14, 0x7D, 0xC, 0x5, 0x1, 0x0, 0x0},	/* < 20 kbits/s */
> +	{0x32, 0x32, 0xF, 0x2, 0x0, 0x0, 0x0},	/* < 50 kbits/s */
> +	{0x7d, 0x19, 0xC, 0x1, 0x0, 0x0, 0x0},	/* < 125 kbits/s */
> +	{0xfa, 0xA, 0xF, 0x2, 0x0, 0x0, 0x0},	/* < 250 kbits/s */
> +	{0x1f4, 0x5, 0xF, 0x2, 0x0, 0x0, 0x0},	/* < 500 kbits/s */
> +	{0x320, 0x5, 0x8, 0x2, 0x1, 0x0, 0x0},	/* < 800 kbits/s  */
> +	{0x3e8, 0x2, 0xF, 0x7, 0x0, 0x0, 0x0}	/* < 1000 kbits/s */
> +	/* Add the new clock settings here. */
> +};

Can't the register values be determined from the calculated one in
"priv->can.bittiming"? See comment above. Be aware the the user might
want to set custom values as described here:

http://lxr.linux.no/#linux+v2.6.35/Documentation/networking/can.txt#L730

> +
> +static DEFINE_MUTEX(pch_can_mutex);

What is this mutex good for. At a first glance, I don't think it's needed.

> +
> +#ifdef PCH_CAN_FIFO_MODE

The functions above are not used anywhere! Dead code? Please clean up.

> +static int check_can_fifo_status(int handle)
> +{
> +	int ret_val;
> +	struct can_fifo *f = (struct can_fifo *) handle;
> +
> +	if (f->head == f->tail)
> +		ret_val = PCH_CAN_FIFO_EMPTY;
> +	else if (f->head->next == f->tail)
> +		ret_val = PCH_CAN_FIFO_FULL;
> +	else
> +		ret_val = PCH_CAN_FIFO_NOT_EMPTY;
> +
> +	return ret_val;
> +}
> +

...

> +static netdev_tx_t pch_xmit(struct sk_buff *skb, struct net_device *ndev)
> +{
> +	int err;		/* error variable. */
> +	int ret;
> +	struct pch_can_msg msg;	/* The message object for writing. */
> +	struct pch_can_priv *priv = netdev_priv(ndev);
> +	struct pch_can_os *can_os = priv->pch_can_os_p;
> +	struct can_frame *canframe_dat = (struct can_frame *)skb->data;
> +	struct net_device_stats *stats = &ndev->stats;
> +
> +	ret = mutex_lock_interruptible(&pch_can_mutex);
> +	if (ret)
> +		return -ERESTARTSYS;


This is an invalid return code.

> +
> +	/* Translate CAN core format to CAN PCH's HW format */
> +	memset(&msg, 0, sizeof(msg));
> +	msg.ide = canframe_dat->can_id & 0x80000000;
> +	if (canframe_dat->can_id & 0x80000000) {
> +		msg.ide = 1;
> +		msg.id =  canframe_dat->can_id & 0x1fffffff;/* Extended
> +								Message */
> +	} else {
> +		msg.ide = 0;
> +		msg.id =  canframe_dat->can_id & 0x00000fff;/* Standard
> +								Message */
> +
> +	}
> +
> +	msg.dlc = canframe_dat->can_dlc;
> +	memcpy(&msg.data, canframe_dat->data, 8);
> +
> +	if (canframe_dat->can_id & 0x40000000)
> +		msg.rtr = 1;
> +	else
> +		msg.rtr = 0;
> +
> +	/* If device suspended. */
> +	if ((can_os->is_suspending) == 1) {
> +		dev_err(&ndev->dev,
> +				"%s -> Device is in suspend mode.\n", __func__);
> +		dev_dbg(&ndev->dev, "%s returns %d\n", __func__, -EAGAIN);
> +		err = -EAGAIN;
> +		goto err_out;
> +	}
> +
> +	can_put_echo_skb(skb, ndev, 0);

This will not work, as you are using more than one TX object.



> +MODULE_DESCRIPTION("Controller Area Network Driver");
> +MODULE_LICENSE("GPL");
> +MODULE_VERSION("0.94");

> +module_param_named(pch_can_rx_buf_size, pch_can_rx_buf_size, int, 444);
> +module_param_named(pch_can_tx_buf_size, pch_can_tx_buf_size, int, 444);
> +module_param_named(pch_can_clock, pch_can_clock, int, 444);
> +MODULE_DEVICE_TABLE(pci, pch_can_pcidev_id);

Please move these calls up to the beginning where the variables are
defined and provide a proper description.

> +
> +module_init(pch_can_pci_init);
> +module_exit(pch_can_pci_exit);
> diff --git a/drivers/net/can/pch_can.h b/drivers/net/can/pch_can.h
> new file mode 100644
> index 0000000..88a9559
> --- /dev/null
> +++ b/drivers/net/can/pch_can.h

...

> +/**
> + * struct pch_can_msg - CAN message structure
> + * @ide:	Standard/extended msg
> + * @id:		11 or 29 bit msg id
> + * @dlc:	Size of data
> + * @data:	Message pay load
> + * @rtr:	RTR message
> + */
> +struct pch_can_msg {
> +	unsigned short ide;
> +	unsigned int id;
> +	unsigned short dlc;
> +	unsigned char data[PCH_CAN_MSG_DATA_LEN];
> +	unsigned short rtr;
> +};

Hm, why you can't use "struct can_frame".

> +
> +/**
> + * pch_can_timing - CAN bittiming structure
> + * @bitrate:	Bitrate (kbps)
> + * @cfg_bitrate:	Bitrate
> + * @cfg_tseg1:	Tseg1
> + * @cfg_tseg2:	Tseg2
> + * @cfg_sjw:	Sync jump width
> + * @smpl_mode:	Sampling mode
> + * @edge_mode:	Edge R / D
> + */
> +struct pch_can_timing {
> +	unsigned int bitrate;
> +	unsigned int cfg_bitrate;
> +	unsigned int cfg_tseg1;
> +	unsigned int cfg_tseg2;
> +	unsigned int cfg_sjw;
> +	unsigned int smpl_mode;
> +	unsigned int edge_mode;
> +};

Ditto.

> +/**
> + * struct pch_can_error - CAN error structure
> + * @rxgte96:	Rx err cnt >=96
> + * @txgte96:	Tx err cnt >=96
> + * @error_stat:	Error state of CAN node,
> + *		00=error active (normal)
> + *		01=error passive
> + *		1x=bus off
> + * @rx_err_cnt:	Rx error count
> + * @tx_err_cnt:	Tx error count
> + */
> +struct pch_can_error {
> +	unsigned int rxgte96;
> +	unsigned int txgte96;
> +	unsigned int error_stat;
> +	unsigned int rx_err_cnt;
> +	unsigned int tx_err_cnt;
> +};
> +
> +/**
> + * struct pch_can_acc_filter - CAN Filter structure
> + * @id:		The id/mask data
> + * @id_ext:	Standard/extended ID
> + * @rtr:	RTR message
> + */
> +struct pch_can_acc_filter {
> +	unsigned int id;
> +	unsigned int id_ext;
> +	unsigned int rtr;
> +};
> +
> +/**
> + * struct pch_can_rx_filter - CAN RX filter
> + * @num:	Filter number
> + * @umask:	UMask value
> + * @amr:	Acceptance Mask Reg
> + * @aidr:	Acceptance Control Reg
> + */
> +struct pch_can_rx_filter {
> +	unsigned int num;
> +	unsigned int umask;
> +	struct pch_can_acc_filter amr;
> +	struct pch_can_acc_filter aidr;
> +};
> +
> +/**
> + * struct pch_can_os - structure to store the CAN device information.
> + * @can:		CAN: device handle
> + * @opened:		Linux opened device
> + * @can_num:		Linux: CAN Number
> + * @pci_remap:		Linux: MMap regs
> + * @dev:		Linux: PCI Device
> + * @irq:		Linux: IRQ
> + * @block_mode:		Blocking / non-blocking
> + * @rx_fifo:		Rx FIFO
> + * @read_wait_queue:	Linux: Read wait queue
> + * @write_wait_queue:	Linux: Write wait queue
> + * @write_wait_flag:	Linux: Write wait flag
> + * @read_wait_flag:	Linux: Read wait flag
> + * @open_spinlock:	Linux: Open lock variable
> + * @is_suspending:	Linux: Is suspending state
> + * @inode:		Linux: inode
> + * @timing:		CAN: timing
> + * @run_mode:		CAN: run mode
> + * @listen_mode:	CAN: listen mode
> + * @arbiter_mode:	CAN: arbiter mode
> + * @tx_enable:		CAN: Tx buffer state
> + * @rx_enable:		CAN: Rx buffer state
> + * @rx_link:		CAN: Rx link set
> + * @int_enables:	CAN: ints enabled
> + * @int_stat:		CAN: int status
> + * @bus_off_interrupt:	CAN: Buss off int flag
> + * @rx_filter:		CAN: Rx filters
> + * @can_callback:	CAN: callback function pointer
> + * @ndev:		net_device pointer
> + * @tx_spinlock:	CAN: transmission lock variable
> + */
> +struct pch_can_os {
> +	int can;
> +	unsigned int opened;
> +	unsigned int can_num;
> +	void __iomem *pci_remap;
> +	struct pci_dev *dev;
> +	unsigned int irq;
> +	int block_mode;
> +	int rx_fifo;
> +	wait_queue_head_t read_wait_queue;
> +	wait_queue_head_t write_wait_queue;
> +	unsigned int write_wait_flag;
> +	unsigned int read_wait_flag;
> +	spinlock_t open_spinlock;
> +	unsigned int is_suspending;
> +	struct inode *inode;
> +	struct pch_can_timing timing;
> +	enum pch_can_run_mode run_mode;
> +	enum pch_can_listen_mode listen_mode;
> +	enum pch_can_arbiter arbiter_mode;
> +	unsigned int tx_enable[MAX_MSG_OBJ];
> +	unsigned int rx_enable[MAX_MSG_OBJ];
> +	unsigned int rx_link[MAX_MSG_OBJ];
> +	unsigned int int_enables;
> +	unsigned int int_stat;
> +	unsigned int bus_off_interrupt;
> +	struct pch_can_rx_filter rx_filter[MAX_MSG_OBJ];
> +	void (*can_callback) (struct pch_can_os *);
> +	struct net_device *ndev;
> +	spinlock_t tx_spinlock;
> +};
> +
> +/**
> + * struct pch_can_priv - CAN driver private data structure
> + * @can:		MUST be first member/field
> + * @ndev:		Pointer to net_device structure
> + * @clk:		unused
> + * @base:		Base address
> + * @scc_ram_offset:	unused
> + * @hecc_ram_offset:	unused
> + * @mbx_offset:		unused
> + * @int_line:		unused
> + * @mbx_lock:		unused
> + * @tx_head:		unused
> + * @tx_tail:		unused
> + * @rx_next:		unused

Hm, if it's not used, what is it then good for? I stop reviewing here.
It seems that you ported an existing driver to Linux!? I'm looking
forward for an optimized and efficient solution.

Thanks,

Wolfgang.
