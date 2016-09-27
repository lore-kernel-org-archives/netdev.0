From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH RFC 1/3] net: Add dev_set_env_hdr_len to accept envelope frames
Date: Tue, 27 Sep 2016 17:55:37 +0900
Message-ID: <1474966541-4420-2-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: netdev@vger.kernel.org, Patrick McHardy <kaber@trash.net>,
        Stephen Hemminger <stephen@networkplumber.org>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:54964 "EHLO
        tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752934AbcI0I64 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 04:58:56 -0400
In-Reply-To: <1474966541-4420-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently most NICs support Q-tagged frames[1], i.e. 1522 bytes frames
to handle 4 bytes VLAN header. But some encapsulation protocols like
802.1ad requires them to handle larger frames.
This change introduces dev_set_env_hdr_len() and corresponding drivers'
operation .ndo_set_env_hdr_len(), which notifies drivers of needed
encapsulation header length. This enables devices to accept longer
frames with encapsulation headers, i.e. envelope frames[2], without
expanding MTU size for non-encapsulated frames.

Note 1:
Envelope frames are not jumbo frames. See IEEE 802.3as[3] for detail.
IEEE 802.3-2012 3.2.7 says:
          The envelope frame is intended to allow inclusion of additional
	  prefixes and suffixes required by higher layer encapusulation
	  protocols such as those defined by the IEEE 802.1 working
	  group (such as Provider Bridges and MAC Security), ITU-T or
	  IETF (such as MPLS). The original MAC Client Data field
	  maximum remains 1500 octets while the encapsulation protocols
	  may add up to an additional 482 octets. Use of these extra
	  octets for other purposes is not recommended, and may result
	  in MAC frames being dropped or corrupted as they may violate
	  maximum MAC frame size restrictions if encapsulation protocols
	  are required to operate on them.

Note 2:
Envelope frames in IEEE 802.3 defines the max size of envelope frames
as 2000 bytes. This change is more flexible than 802.3 in terms of max
allowed frame length.

[1] IEEE 802.3-2012, 1.4.334.
[2] IEEE 802.3-2012, 1.4.184.
[3] http://www.ieee802.org/3/as/public/0607/802.3as_overview.pdf

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 include/linux/netdevice.h | 21 +++++++++++++++++++++
 net/core/dev.c            | 32 ++++++++++++++++++++++++++++++++
 2 files changed, 53 insertions(+)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 136ae6bb..a0ac76a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1132,6 +1132,10 @@ struct netdev_xdp {
  * int (*ndo_xdp)(struct net_device *dev, struct netdev_xdp *xdp);
  *	This function is used to set or query state related to XDP on the
  *	netdevice. See definition of enum xdp_netdev_command for details.
+ * int (*ndo_set_env_hdr_len)(struct net_device *dev, int hdr_len);
+ *	This function is used to set the maximum header size of envelope
+ *	frames. The device must accept the size of MTU + envelope header
+ *	size on packet reception.
  *
  */
 struct net_device_ops {
@@ -1323,6 +1327,8 @@ struct net_device_ops {
 						       int needed_headroom);
 	int			(*ndo_xdp)(struct net_device *dev,
 					   struct netdev_xdp *xdp);
+	int			(*ndo_set_env_hdr_len)(struct net_device *dev,
+						       int hdr_len);
 };
 
 /**
@@ -1506,6 +1512,7 @@ enum netdev_priv_flags {
  *	@if_port:	Selectable AUI, TP, ...
  *	@dma:		DMA channel
  *	@mtu:		Interface MTU value
+ *	@env_hdr_len:	Additional encapsulation header length to MTU
  *	@type:		Interface hardware type
  *	@hard_header_len: Maximum hardware header length.
  *
@@ -1726,6 +1733,7 @@ struct net_device {
 	unsigned char		dma;
 
 	unsigned int		mtu;
+	unsigned int		env_hdr_len;
 	unsigned short		type;
 	unsigned short		hard_header_len;
 
@@ -3300,6 +3308,7 @@ int dev_change_name(struct net_device *, const char *);
 int dev_set_alias(struct net_device *, const char *, size_t);
 int dev_change_net_namespace(struct net_device *, struct net *, const char *);
 int dev_set_mtu(struct net_device *, int);
+int dev_set_env_hdr_len(struct net_device *, int);
 void dev_set_group(struct net_device *, int);
 int dev_set_mac_address(struct net_device *, struct sockaddr *);
 int dev_change_carrier(struct net_device *, bool new_carrier);
@@ -4233,6 +4242,18 @@ static inline bool netif_reduces_vlan_mtu(struct net_device *dev)
 	return dev->priv_flags & IFF_MACSEC;
 }
 
+/* return envelope header length */
+static inline int netif_get_env_hdr_len(struct net_device *dev)
+{
+	if (dev->netdev_ops->ndo_set_env_hdr_len)
+		return dev->env_hdr_len;
+
+	if (netif_reduces_vlan_mtu(dev))
+		return 0;
+
+	return 4; /* VLAN_HLEN */
+}
+
 extern struct pernet_operations __net_initdata loopback_net_ops;
 
 /* Logging, debugging and troubleshooting/diagnostic helpers. */
diff --git a/net/core/dev.c b/net/core/dev.c
index c0c291f..df75aaa 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -6524,6 +6524,38 @@ int dev_set_mtu(struct net_device *dev, int new_mtu)
 EXPORT_SYMBOL(dev_set_mtu);
 
 /**
+ *	dev_set_env_hdr_len - Set max envelope header length
+ *	@dev: device
+ *	@new_len: new length
+ */
+int dev_set_env_hdr_len(struct net_device *dev, int new_len)
+{
+	const struct net_device_ops *ops = dev->netdev_ops;
+	int err;
+
+	if (!ops->ndo_set_env_hdr_len)
+		return -EOPNOTSUPP;
+
+	if (new_len < 0)
+		return -EINVAL;
+
+	if (!netif_device_present(dev))
+		return -ENODEV;
+
+	if (new_len == dev->env_hdr_len)
+		return 0;
+
+	err = ops->ndo_set_env_hdr_len(dev, new_len);
+	if (err)
+		return err;
+
+	dev->env_hdr_len = new_len;
+
+	return 0;
+}
+EXPORT_SYMBOL(dev_set_env_hdr_len);
+
+/**
  *	dev_set_group - Change group this device belongs to
  *	@dev: device
  *	@new_group: group this device should belong to
-- 
1.8.3.1
