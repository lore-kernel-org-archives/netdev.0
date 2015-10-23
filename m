From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net-next 1/4] net: Add ndo_enc_hdr_len to notify extra header room for encapsulated frames
Date: Fri, 23 Oct 2015 12:49:30 +0900
Message-ID: <1445572173-15402-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1445572173-15402-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama500.ecl.ntt.co.jp ([129.60.39.148]:37474 "EHLO
	tama500.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752488AbbJWDuE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 22 Oct 2015 23:50:04 -0400
In-Reply-To: <1445572173-15402-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently most NICs reserve 1522 bytes space for frames to handle 4
bytes VLAN header in addition to 1518, maximum size of ethernet frame.
This is, however, not sufficient when stacked vlan or other encapsulation
protocols are used.
To accommodate this, add .ndo_enc_hdr_len() and inform drivers of needed
encapsulation header size.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/netdevice.h |  9 +++++++++
 net/core/dev.c            | 36 ++++++++++++++++++++++++++++++++++++
 2 files changed, 45 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 69fdd42..4d2ce91 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1054,6 +1054,10 @@ typedef u16 (*select_queue_fallback_t)(struct net_device *dev,
  *	This function is used to pass protocol port error state information
  *	to the switch driver. The switch driver can react to the proto_down
  *      by doing a phys down on the associated switch port.
+ * int (*ndo_enc_hdr_len)(struct net_device *dev, int hdr_len);
+ *	Called to notify addtional encapsulation header length to reserve.
+ *	Implements should reserve hdr_len room in addition to MTU to handle
+ *	encapsulated frames.
  *
  */
 struct net_device_ops {
@@ -1227,6 +1231,8 @@ struct net_device_ops {
 	int			(*ndo_get_iflink)(const struct net_device *dev);
 	int			(*ndo_change_proto_down)(struct net_device *dev,
 							 bool proto_down);
+	int			(*ndo_enc_hdr_len)(struct net_device *dev,
+						   int hdr_len);
 };
 
 /**
@@ -1387,6 +1393,7 @@ enum netdev_priv_flags {
  *	@if_port:	Selectable AUI, TP, ...
  *	@dma:		DMA channel
  *	@mtu:		Interface MTU value
+ *	@enc_hdr_len:	Additional encapsulation header length to MTU
  *	@type:		Interface hardware type
  *	@hard_header_len: Hardware header length
  *
@@ -1607,6 +1614,7 @@ struct net_device {
 	unsigned char		dma;
 
 	unsigned int		mtu;
+	unsigned int		enc_hdr_len;
 	unsigned short		type;
 	unsigned short		hard_header_len;
 
@@ -3021,6 +3029,7 @@ int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int dev_set_mtu(struct net_device *, int);
+int dev_set_enc_hdr_len(struct net_device *, int);
 void dev_set_group(struct net_device *, int);
 int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
diff --git a/net/core/dev.c b/net/core/dev.c
index 1225b4b..056a16e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6024,6 +6024,42 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 EXPORT_SYMBOL(dev_set_mtu);
 
 /**
+ *	dev_set_enc_hdr_len - Expand encapsulation header room
+ *	@dev: device
+ *	@new_len: new length
+ */
+int dev_set_enc_hdr_len(struct net_device *dev, int new_len)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+
+	if (new_len < 0)
+		return -EINVAL;
+
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	if (new_len <= dev->enc_hdr_len)
+		return 0;
+
+	if (ops->ndo_enc_hdr_len) {
+		int err;
+
+		/* This function can be called from child user/net namespace */
+		if (!ns_capable(dev_net(dev)->user_ns, CAP_NET_ADMIN))
+			return -EPERM;
+
+		err = ops->ndo_enc_hdr_len(dev, new_len);
+		if (err)
+			return err;
+	}
+
+	dev->enc_hdr_len = new_len;
+
+	return 0;
+}
+EXPORT_SYMBOL(dev_set_enc_hdr_len);
+
+/**
  *	dev_set_group - Change group this device belongs to
  *	@dev: device
  *	@new_group: group this device should belong to
-- 
1.8.1.2
