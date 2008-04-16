From: Paulius Zaleckas <paulius.zaleckas-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Subject: Re: [RFC] Patch to option HSO driver to the kernel
Date: Wed, 16 Apr 2008 18:15:48 +0300
Message-ID: <48061824.6050800@teltonika.lt>
References: <20080414213238.GB28833@kroah.com> <480530E6.8020700@teltonika.lt> <4805C469.7050408@teltonika.lt> <4805E8E1.3090200@teltonika.lt>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------010701050201080609060004"
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <4805E8E1.3090200-Ft0m5Q12RQ9xBelEqimL3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010701050201080609060004
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Paulius Zaleckas wrote:
> Paulius Zaleckas wrote:
>> Paulius Zaleckas wrote:
>>> Reworked MAC address generation from USB serial number
>>> Now it is very similar to the one done in the cdc_ether.c
>>>
>>> Filip: Does the dummy MAC address have to start with 0xFA?
>>>
>>
>> Hopefully fixed last bug in MAC address generation.
>> Patch against latest Greg unified patch.
>> Don't use my previous patch.
>>
> 
> Incremental patch. Converted ethtool ioctl to ethtool_ops.
> 
> Paulius
> 

Updated patch with the following change:
In function hso_get_drvinfo instead of writing to tmp buffer write
directly to fw_version.

Paulius

--------------010701050201080609060004
Content-Type: text/x-patch;
 name="hso_ethtool_ops2.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="hso_ethtool_ops2.patch"

--- linux-2.6-hso/drivers/net/usb/hso.c	2008-04-16 14:47:53.000000000 +0300
+++ linux-2.6-hso-my/drivers/net/usb/hso.c	2008-04-16 18:01:11.000000000 +0300
@@ -853,61 +853,22 @@ static int hso_net_start_xmit(struct sk_
 	return result;
 }
 
-static int hso_net_ioctl(struct net_device *net, struct ifreq *rq, int cmd)
+static void hso_get_drvinfo(struct net_device *net, struct ethtool_drvinfo *info)
 {
 	struct hso_net *odev = netdev_priv(net);
-	u32 usercmd = 0;
-	char tmp[40];
 
-	switch (cmd) {
-	case SIOCETHTOOL:
-		/* net specific */
-		if (copy_from_user(&usercmd, rq->ifr_data, sizeof(usercmd)))
-			return -EFAULT;
-
-		switch (usercmd) {
-		case ETHTOOL_GDRVINFO:
-			{
-			/* get driver info */
-			struct ethtool_drvinfo info = { ETHTOOL_GDRVINFO };
-			strncpy(info.driver, driver_name, ETHTOOL_BUSINFO_LEN);
-			strncpy(info.version, DRIVER_VERSION,
-				ETHTOOL_BUSINFO_LEN);
-			sprintf(tmp, "usb%d:%d",
-				odev->parent->usb->bus->busnum,
-				odev->parent->usb->devnum);
-			strncpy(info.bus_info, tmp, ETHTOOL_BUSINFO_LEN);
-			sprintf(tmp, "%s %x.%x", driver_name,
-				((odev->bcdCDC & 0xff00) >> 8),
-				(odev->bcdCDC & 0x00ff));
-			strncpy(info.fw_version, tmp, ETHTOOL_BUSINFO_LEN);
-			if (copy_to_user(rq->ifr_data, &info, sizeof(info)))
-				return -EFAULT;
-
-			return 0;
-			}
-		case ETHTOOL_GLINK:
-			{
-			/* get link status */
-			struct ethtool_value edata = { ETHTOOL_GLINK };
-
-			edata.data = netif_carrier_ok(net);
-			if (copy_to_user(rq->ifr_data, &edata, sizeof(edata)))
-				return -EFAULT;
-
-			return 0;
-			}
-		default:
-			dev_warn(&net->dev, "Got unsupported ioctl: %x\n",
-				 usercmd);
-			/* the ethtool user space tool relies on this */
-			return -EOPNOTSUPP;
-		}
-	default:
-		return -ENOTTY;	/* per ioctl man page */
-	}
+	strncpy(info->driver, driver_name, ETHTOOL_BUSINFO_LEN);
+	strncpy(info->version, DRIVER_VERSION, ETHTOOL_BUSINFO_LEN);
+	usb_make_path(odev->parent->usb, info->bus_info, sizeof info->bus_info);
+	snprintf(info->fw_version, ETHTOOL_BUSINFO_LEN, "%s %x.%x", driver_name,
+		 ((odev->bcdCDC & 0xff00) >> 8), (odev->bcdCDC & 0x00ff));
 }
 
+static struct ethtool_ops ops = {
+	.get_drvinfo = hso_get_drvinfo,
+	.get_link = ethtool_op_get_link
+};
+
 static struct net_device_stats *hso_net_get_stats(struct net_device *net)
 {
 	return &((struct hso_net *)netdev_priv(net))->stats;
@@ -2281,7 +2242,6 @@ static void hso_net_init(struct net_devi
 	net->open = hso_net_open;
 	net->stop = hso_net_close;
 	net->hard_start_xmit = hso_net_start_xmit;
-	net->do_ioctl = hso_net_ioctl;
 	net->get_stats = hso_net_get_stats;
 	net->tx_timeout = hso_net_tx_timeout;
 	net->watchdog_timeo = HSO_NET_TX_TIMEOUT;
@@ -2289,6 +2249,7 @@ static void hso_net_init(struct net_devi
 	net->flags |= IFF_NOARP;
 	net->mtu = DEFAULT_MTU - 14;
 	net->tx_queue_len = 10;
+	SET_ETHTOOL_OPS(net, &ops);
 	hso_net->skb_rx_buf = NULL;
 	hso_net->rx_parse_state = WAIT_IP;
 	hso_net->wMaxSegmentSize = DEFAULT_MTU;

--------------010701050201080609060004--

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
