From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] updated Patch to option HSO driver to the kernel
Date: Mon, 21 Apr 2008 04:04:21 +0300
Message-ID: <480BE815.2000409@teltonika.lt>
References: <20080417214719.GF17664@kroah.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050506000101090905080400"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20080417214719.GF17664-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050506000101090905080400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

- Cleaned up unused defines and variables
- Remove broken firmware info from ethtool_ops
- Const for usb IDs table

Signed-off-by: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>

--------------050506000101090905080400
Content-Type: text/x-patch;
 name="hso_cleanup.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_cleanup.patch"

--- linux-2.6-hso/drivers/net/usb/hso.c	2008-04-21 03:53:53.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-21 03:47:36.000000000 +0300
@@ -82,7 +82,6 @@
 #define BULK_URB_RX_SIZE		4096
 #define BULK_URB_TX_SIZE		8192
 
-#define MUX_INTR_BUF_SIZE		16
 #define MUX_BULK_RX_BUF_SIZE		HSO__MAX_MTU
 #define MUX_BULK_TX_BUF_SIZE		HSO__MAX_MTU
 #define MUX_BULK_RX_BUF_COUNT		4
@@ -91,18 +90,11 @@
 /* These definitions are used with the struct hso_net flags element */
 /* - use *_bit operations on it. (bit indices not values.) */
 #define HSO_NET_RUNNING			0
-#define HSO_NET_TX_BUSY			1
-#define HSO_TERMINATE			2
 
 #define	HSO_NET_TX_TIMEOUT		(HZ*10)
 
 /* Serial port defines and structs. */
-#define HSO_THRESHOLD_THROTTLE		(7*1024)
-#define HSO_THRESHOLD_UNTHROTTLE	(2*1024)
-
-#define HSO_SERIAL_FLAG_THROTTLED	0
-#define HSO_SERIAL_FLAG_TX_SENT		1
-#define HSO_SERIAL_FLAG_RX_SENT		2
+#define HSO_SERIAL_FLAG_RX_SENT		0
 
 #define HSO_SERIAL_MAGIC		0x48534f31
 
@@ -182,12 +174,8 @@ struct hso_net {
 	struct iphdr rx_ip_hdr;
 	struct ethhdr dummy_eth_head;
 
-	__u16 bcdCDC;
-	__u16 wMaxSegmentSize;
 	__u16 wNumberMCFilters;
-	__u16 mode_flags;
 	unsigned long flags;
-
 };
 
 struct hso_serial {
@@ -210,7 +198,6 @@ struct hso_serial {
 	u16 tx_data_length;	/* should contain allocated length */
 	u16 tx_data_count;
 	u16 tx_buffer_count;
-	spinlock_t buffer_lock;
 	struct usb_ctrlrequest ctrl_req_tx;
 	struct usb_ctrlrequest ctrl_req_rx;
 
@@ -226,7 +213,6 @@ struct hso_serial {
 	struct tty_struct *tty;
 	int open_count;
 	spinlock_t serial_lock;
-	void *private;
 
 	int (*write_data) (struct hso_serial *serial);
 };
@@ -240,7 +226,6 @@ struct hso_device {
 	u32 port_spec;
 
 	u8 is_active;
-	u8 suspend_disabled;
 	u8 usb_gone;
 	struct work_struct async_get_intf;
 	struct work_struct async_put_intf;
@@ -252,9 +237,6 @@ struct hso_device {
 	struct device *dev;
 	struct kref ref;
 	struct mutex mutex;
-
-	/* TODO: Not sure about the ones below */
-	struct proc_dir_entry *ourproc;
 };
 
 /* Type of interface */
@@ -327,8 +309,6 @@ static unsigned char hex2dec(unsigned ch
 	return 0;
 }
 
-#define SIOCSETRADIO   (SIOCDEVPRIVATE+4)
-
 /* #define DEBUG */
 
 #define dev2net(x) (x->port_data.dev_net)
@@ -411,7 +391,7 @@ static const s32 icon321_port_spec[] = {
 		.driver_info = (kernel_ulong_t)icon321_port_spec
 
 /* list of devices we support */
-static struct usb_device_id hso_ids[] = {
+static const struct usb_device_id hso_ids[] = {
 	{default_port_device(0x0af0, 0x6711)},
 	{default_port_device(0x0af0, 0x6731)},
 	{default_port_device(0x0af0, 0x6751)},
@@ -610,7 +590,7 @@ static void set_serial_by_index(unsigned
 	spin_unlock_irqrestore(&serial_table_lock, flags);
 }
 
-/* log a meaningfull explanation of an USB status to syslog */
+/* log a meaningfull explanation of an USB status */
 static void log_usb_status(int status, const char *function)
 {
 	char *explanation = NULL;
@@ -858,8 +838,6 @@ static void hso_get_drvinfo(struct net_d
 	strncpy(info->driver, driver_name, ETHTOOL_BUSINFO_LEN);
 	strncpy(info->version, DRIVER_VERSION, ETHTOOL_BUSINFO_LEN);
 	usb_make_path(odev->parent->usb, info->bus_info, sizeof info->bus_info);
-	snprintf(info->fw_version, ETHTOOL_BUSINFO_LEN, "%s %x.%x", driver_name,
-		 ((odev->bcdCDC & 0xff00) >> 8), (odev->bcdCDC & 0x00ff));
 }
 
 static struct ethtool_ops ops = {
@@ -907,34 +885,17 @@ static void hso_net_set_multicast(struct
 	if (net->flags & IFF_PROMISC) {
 		/* Unconditionally log net taps. */
 		D1("%s: Promiscuous mode enabled", net->name);
-		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
-				   USB_CDC_PACKET_TYPE_DIRECTED |
-				   USB_CDC_PACKET_TYPE_BROADCAST |
-				   USB_CDC_PACKET_TYPE_MULTICAST |
-				   USB_CDC_PACKET_TYPE_PROMISCUOUS;
 	} else if (net->mc_count > odev->wNumberMCFilters) {
 		/* Too many to filter perfectly -- accept all multicasts. */
 		D1("%s: too many MC filters for hardware, using allmulti",
 		   net->name);
-		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
-				   USB_CDC_PACKET_TYPE_DIRECTED |
-				   USB_CDC_PACKET_TYPE_BROADCAST |
-				   USB_CDC_PACKET_TYPE_MULTICAST;
 	} else if (net->flags & IFF_ALLMULTI) {
 		/* Filter in software */
 		D1("%s: using allmulti", net->name);
-		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
-				   USB_CDC_PACKET_TYPE_DIRECTED |
-				   USB_CDC_PACKET_TYPE_BROADCAST |
-				   USB_CDC_PACKET_TYPE_MULTICAST;
 	} else {
 		/* do multicast filtering in hardware */
 		struct dev_mc_list *mclist;
 		D1("%s: set multicast filters", net->name);
-		odev->mode_flags = USB_CDC_PACKET_TYPE_ALL_MULTICAST |
-				   USB_CDC_PACKET_TYPE_DIRECTED |
-				   USB_CDC_PACKET_TYPE_BROADCAST |
-				   USB_CDC_PACKET_TYPE_MULTICAST;
 		buf = kmalloc(6 * net->mc_count, GFP_ATOMIC);
 		if (!buf) {
 			dev_err(&net->dev, "No memory to allocate?");
@@ -2213,7 +2174,6 @@ static void hso_net_init(struct net_devi
 	SET_ETHTOOL_OPS(net, &ops);
 	hso_net->skb_rx_buf = NULL;
 	hso_net->rx_parse_state = WAIT_IP;
-	hso_net->wMaxSegmentSize = DEFAULT_MTU;
 	/* always use all multi, no lists of multicasts */
 	hso_net->wNumberMCFilters = 0;
 

--------------050506000101090905080400--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
