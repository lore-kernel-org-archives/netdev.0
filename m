From: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: [PATCH 1/2] net: usb: qmi_wwan: add qmap mux protocol support
Date: Fri, 24 Mar 2017 14:22:45 +0100
Message-ID: <1490361766-24114-2-git-send-email-dnlplm@gmail.com>
References: <1490361766-24114-1-git-send-email-dnlplm@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: =?UTF-8?q?Bj=C3=B8rn=20Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1490361766-24114-1-git-send-email-dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This patch adds support for qmap mux protocol available in recent
Qualcomm based modems.

The qmap mux protocol can be used for multiplexing data packets in
order to have multiple ip streams through the same physical device.

Two new sysfs files are added for adding/removing the qmap mux based
interfaces (named qmimux):

- /sys/class/net/<iface>/qmi/add_mux
- /sys/class/net/<iface>/qmi/del_mux

Main patch author is Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>

Signed-off-by: Bjørn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
Signed-off-by: Daniele Palmas <dnlplm-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
---
 drivers/net/usb/qmi_wwan.c | 317 ++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 316 insertions(+), 1 deletion(-)

diff --git a/drivers/net/usb/qmi_wwan.c b/drivers/net/usb/qmi_wwan.c
index 8056745..55f2303 100644
--- a/drivers/net/usb/qmi_wwan.c
+++ b/drivers/net/usb/qmi_wwan.c
@@ -58,12 +58,198 @@ struct qmi_wwan_state {
 
 enum qmi_wwan_flags {
 	QMI_WWAN_FLAG_RAWIP = 1 << 0,
+	QMI_WWAN_FLAG_MUX = 1 << 1,
 };
 
 enum qmi_wwan_quirks {
 	QMI_WWAN_QUIRK_DTR = 1 << 0,	/* needs "set DTR" request */
 };
 
+struct qmimux_hdr {
+	u8 pad;
+	u8 mux_id;
+	__be16 pkt_len;
+};
+
+struct qmimux_priv {
+	struct net_device *real_dev;
+	u8 mux_id;
+};
+
+static int qmimux_open(struct net_device *dev)
+{
+	struct qmimux_priv *priv = netdev_priv(dev);
+	struct net_device *real_dev = priv->real_dev;
+
+	if (!(priv->real_dev->flags & IFF_UP))
+		return -ENETDOWN;
+
+	if (netif_carrier_ok(real_dev))
+		netif_carrier_on(dev);
+	return 0;
+}
+
+static int qmimux_stop(struct net_device *dev)
+{
+	netif_carrier_off(dev);
+	return 0;
+}
+
+static netdev_tx_t qmimux_start_xmit(struct sk_buff *skb, struct net_device *dev)
+{
+	struct qmimux_priv *priv = netdev_priv(dev);
+	unsigned int len = skb->len;
+	struct qmimux_hdr *hdr;
+
+	hdr = (struct qmimux_hdr *)skb_push(skb, sizeof(struct qmimux_hdr));
+	hdr->pad = 0;
+	hdr->mux_id = priv->mux_id;
+	hdr->pkt_len = cpu_to_be16(len);
+	skb->dev = priv->real_dev;
+	return dev_queue_xmit(skb);
+}
+
+static const struct net_device_ops qmimux_netdev_ops = {
+	.ndo_open       = qmimux_open,
+	.ndo_stop       = qmimux_stop,
+	.ndo_start_xmit = qmimux_start_xmit,
+};
+
+static void qmimux_setup(struct net_device *dev)
+{
+	dev->header_ops      = NULL;  /* No header */
+	dev->type            = ARPHRD_NONE;
+	dev->hard_header_len = 0;
+	dev->addr_len        = 0;
+	dev->flags           = IFF_POINTOPOINT | IFF_NOARP | IFF_MULTICAST;
+	dev->netdev_ops      = &qmimux_netdev_ops;
+	dev->destructor      = free_netdev;
+}
+
+static struct net_device *qmimux_find_dev(struct usbnet *dev, u8 mux_id)
+{
+	struct qmimux_priv *priv;
+	struct list_head *iter;
+	struct net_device *ldev;
+
+	rcu_read_lock();
+	netdev_for_each_upper_dev_rcu(dev->net, ldev, iter) {
+		priv = netdev_priv(ldev);
+		if (priv->mux_id == mux_id) {
+			rcu_read_unlock();
+			return ldev;
+		}
+	}
+	rcu_read_unlock();
+	return NULL;
+}
+
+static bool qmimux_has_slaves(struct usbnet *dev)
+{
+	return !list_empty(&dev->net->adj_list.upper);
+}
+
+static int qmimux_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
+{
+	unsigned int len, offset = sizeof(struct qmimux_hdr);
+	struct qmimux_hdr *hdr;
+	struct net_device *net;
+	struct sk_buff *skbn;
+
+	while (offset < skb->len) {
+		hdr = (struct qmimux_hdr *)skb->data;
+		len = be16_to_cpu(hdr->pkt_len);
+
+		/* drop the packet, bogus length */
+		if (offset + len > skb->len)
+			return 0;
+
+		/* control packet, we do not know what to do */
+		if (hdr->pad & 0x80)
+			goto skip;
+
+		net = qmimux_find_dev(dev, hdr->mux_id);
+		if (!net)
+			goto skip;
+		skbn = netdev_alloc_skb(net, len);
+		if (!skbn)
+			return 0;
+		skbn->dev = net;
+
+		switch (skb->data[offset] & 0xf0) {
+		case 0x40:
+			skbn->protocol = htons(ETH_P_IP);
+			break;
+		case 0x60:
+			skbn->protocol = htons(ETH_P_IPV6);
+			break;
+		default:
+			/* not ip - do not know what to do */
+			goto skip;
+		}
+
+		memcpy(skb_put(skbn, len), skb->data + offset, len);
+		if (netif_rx(skbn) != NET_RX_SUCCESS)
+			return 0;
+
+skip:
+		offset += len + sizeof(struct qmimux_hdr);
+	}
+	return 1;
+}
+
+static int qmimux_register_device(struct net_device *real_dev, u8 mux_id)
+{
+	struct net_device *new_dev;
+	struct qmimux_priv *priv;
+	int err;
+
+	new_dev = alloc_netdev(sizeof(struct qmimux_priv),
+			       "qmimux%d", NET_NAME_UNKNOWN, qmimux_setup);
+	if (!new_dev)
+		return -ENOBUFS;
+
+	dev_net_set(new_dev, dev_net(real_dev));
+	priv = netdev_priv(new_dev);
+	priv->mux_id = mux_id;
+	priv->real_dev = real_dev;
+
+	err = register_netdevice(new_dev);
+	if (err < 0)
+		goto out_free_newdev;
+
+	/* Account for reference in struct qmimux_priv_priv */
+	dev_hold(real_dev);
+
+	err = netdev_upper_dev_link(real_dev, new_dev);
+	if (err)
+		goto out_unregister_netdev;
+
+	netif_stacked_transfer_operstate(real_dev, new_dev);
+
+	return 0;
+
+out_unregister_netdev:
+	unregister_netdevice(new_dev);
+	dev_put(real_dev);
+
+out_free_newdev:
+	free_netdev(new_dev);
+	return err;
+}
+
+static void qmimux_unregister_device(struct net_device *dev)
+{
+	struct qmimux_priv *priv = netdev_priv(dev);
+	struct net_device *real_dev = priv->real_dev;
+
+	netdev_upper_dev_unlink(real_dev, dev);
+	unregister_netdevice(dev);
+
+	/* Get rid of the reference to real_dev */
+	dev_put(real_dev);
+}
+
 static void qmi_wwan_netdev_setup(struct net_device *net)
 {
 	struct usbnet *dev = netdev_priv(net);
@@ -137,10 +323,114 @@ static ssize_t raw_ip_store(struct device *d,  struct device_attribute *attr, co
 	return ret;
 }
 
+static ssize_t add_mux_show(struct device *d, struct device_attribute *attr, char *buf)
+{
+	struct net_device *dev = to_net_dev(d);
+	struct qmimux_priv *priv;
+	struct list_head *iter;
+	struct net_device *ldev;
+	ssize_t count = 0;
+
+	rcu_read_lock();
+	netdev_for_each_upper_dev_rcu(dev, ldev, iter) {
+		priv = netdev_priv(ldev);
+		count += scnprintf(&buf[count], PAGE_SIZE - count,
+				   "0x%02x\n", priv->mux_id);
+	}
+	rcu_read_unlock();
+	return count;
+}
+
+static ssize_t add_mux_store(struct device *d,  struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev = netdev_priv(to_net_dev(d));
+	struct qmi_wwan_state *info = (void *)&dev->data;
+	u8 mux_id;
+	int ret;
+
+	if (kstrtou8(buf, 0, &mux_id))
+		return -EINVAL;
+
+	/* mux_id [1 - 0x7f] range empirically found */
+	if (mux_id < 1 || mux_id > 0x7f)
+		return -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	if (qmimux_find_dev(dev, mux_id)) {
+		netdev_err(dev->net, "mux_id already present\n");
+		ret = -EINVAL;
+		goto err;
+	}
+
+	/* we don't want to modify a running netdev */
+	if (netif_running(dev->net)) {
+		netdev_err(dev->net, "Cannot change a running device\n");
+		ret = -EBUSY;
+		goto err;
+	}
+
+	ret = qmimux_register_device(dev->net, mux_id);
+	if (!ret) {
+		info->flags |= QMI_WWAN_FLAG_MUX;
+		ret = len;
+	}
+err:
+	rtnl_unlock();
+	return ret;
+}
+
+static ssize_t del_mux_show(struct device *d, struct device_attribute *attr, char *buf)
+{
+	return add_mux_show(d, attr, buf);
+}
+
+static ssize_t del_mux_store(struct device *d,  struct device_attribute *attr, const char *buf, size_t len)
+{
+	struct usbnet *dev = netdev_priv(to_net_dev(d));
+	struct qmi_wwan_state *info = (void *)&dev->data;
+	struct net_device *del_dev;
+	u8 mux_id;
+	int ret = 0;
+
+	if (kstrtou8(buf, 0, &mux_id))
+		return -EINVAL;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+
+	/* we don't want to modify a running netdev */
+	if (netif_running(dev->net)) {
+		netdev_err(dev->net, "Cannot change a running device\n");
+		ret = -EBUSY;
+		goto err;
+	}
+
+	del_dev = qmimux_find_dev(dev, mux_id);
+	if (!del_dev) {
+		netdev_err(dev->net, "mux_id not present\n");
+		ret = -EINVAL;
+		goto err;
+	}
+	qmimux_unregister_device(del_dev);
+
+	if (!qmimux_has_slaves(dev))
+		info->flags &= ~QMI_WWAN_FLAG_MUX;
+	ret = len;
+err:
+	rtnl_unlock();
+	return ret;
+}
+
 static DEVICE_ATTR_RW(raw_ip);
+static DEVICE_ATTR_RW(add_mux);
+static DEVICE_ATTR_RW(del_mux);
 
 static struct attribute *qmi_wwan_sysfs_attrs[] = {
 	&dev_attr_raw_ip.attr,
+	&dev_attr_add_mux.attr,
+	&dev_attr_del_mux.attr,
 	NULL,
 };
 
@@ -184,6 +474,9 @@ static int qmi_wwan_rx_fixup(struct usbnet *dev, struct sk_buff *skb)
 	if (skb->len < dev->net->hard_header_len)
 		return 0;
 
+	if (info->flags & QMI_WWAN_FLAG_MUX)
+		return qmimux_rx_fixup(dev, skb);
+
 	switch (skb->data[0] & 0xf0) {
 	case 0x40:
 		proto = htons(ETH_P_IP);
@@ -1030,11 +1323,33 @@ static int qmi_wwan_probe(struct usb_interface *intf,
 	return usbnet_probe(intf, id);
 }
 
+static void qmi_wwan_disconnect(struct usb_interface *intf)
+{
+	struct usbnet *dev = usb_get_intfdata(intf);
+	struct qmi_wwan_state *info = (void *)&dev->data;
+	struct list_head *iter;
+	struct net_device *ldev;
+
+	if (info->flags & QMI_WWAN_FLAG_MUX) {
+		if (!rtnl_trylock()) {
+			restart_syscall();
+			return;
+		}
+		rcu_read_lock();
+		netdev_for_each_upper_dev_rcu(dev->net, ldev, iter)
+			qmimux_unregister_device(ldev);
+		rcu_read_unlock();
+		rtnl_unlock();
+		info->flags &= ~QMI_WWAN_FLAG_MUX;
+	}
+	usbnet_disconnect(intf);
+}
+
 static struct usb_driver qmi_wwan_driver = {
 	.name		      = "qmi_wwan",
 	.id_table	      = products,
 	.probe		      = qmi_wwan_probe,
-	.disconnect	      = usbnet_disconnect,
+	.disconnect	      = qmi_wwan_disconnect,
 	.suspend	      = qmi_wwan_suspend,
 	.resume		      =	qmi_wwan_resume,
 	.reset_resume         = qmi_wwan_resume,
-- 
2.8.1

--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
