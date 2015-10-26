From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH v2 net-next 3/4] vlan: Notify real device of encap header length
Date: Mon, 26 Oct 2015 12:40:58 +0900
Message-ID: <1445830859-4651-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1445830859-4651-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	Patrick McHardy <kaber@trash.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevich@gmail.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>,
	intel-wired-lan@lists.osuosl.org, toshiaki.makita1@gmail.com,
	netdev@vger.kernel.org
To: "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:40684 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751871AbbJZDlg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 25 Oct 2015 23:41:36 -0400
In-Reply-To: <1445830859-4651-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Reserve extra 4 bytes on real_dev in addition to the length notified
from upper device.
In 802.1ad mode, set enc_hdr_len to 4 bytes by default, since it is
likely to send already tagged frame.

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/8021q/vlan.c     | 16 ++++++++++++++--
 net/8021q/vlan_dev.c | 48 +++++++++++++++++++++++++++++++++++++++++++-----
 2 files changed, 57 insertions(+), 7 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index d2cd9de..bbafc5c 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -355,6 +355,7 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 	struct net_device *vlandev;
 	struct vlan_dev_priv *vlan;
 	bool last = false;
+	int dev_max_frame;
 	LIST_HEAD(list);
 
 	if (is_vlan_dev(dev)) {
@@ -399,11 +400,22 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		break;
 
 	case NETDEV_CHANGEMTU:
+		dev_max_frame = dev->mtu + dev->enc_hdr_len;
 		vlan_group_for_each_dev(grp, i, vlandev) {
-			if (vlandev->mtu <= dev->mtu)
+			int enc_hdr_len = vlandev->enc_hdr_len + VLAN_HLEN;
+
+			if (vlandev->mtu <= dev->mtu &&
+			    vlandev->mtu + enc_hdr_len <= dev_max_frame)
 				continue;
 
-			dev_set_mtu(vlandev, dev->mtu);
+			if (vlandev->mtu > dev->mtu) {
+				dev_set_mtu(vlandev, dev->mtu);
+			} else {
+				int mtu_room = dev->mtu - vlandev->mtu;
+
+				dev_set_enc_hdr_len(dev,
+						    enc_hdr_len - mtu_room);
+			}
 		}
 		break;
 
diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index fded865..ac377cf 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -143,17 +143,35 @@ static netdev_tx_t vlan_dev_hard_start_xmit(struct sk_buff *skb,
 	return ret;
 }
 
+static int vlan_dev_enc_hdr_len(struct net_device *dev, int new_len)
+{
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+	int mtu_room = real_dev->mtu - dev->mtu;
+
+	new_len += VLAN_HLEN;
+	if (new_len > mtu_room)
+		return dev_set_enc_hdr_len(real_dev, new_len - mtu_room);
+
+	return 0;
+}
+
 static int vlan_dev_change_mtu(struct net_device *dev, int new_mtu)
 {
-	/* TODO: gotta make sure the underlying layer can handle it,
-	 * maybe an IFF_VLAN_CAPABLE flag for devices?
-	 */
-	if (vlan_dev_priv(dev)->real_dev->mtu < new_mtu)
+	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+	int orig_mtu;
+	int err;
+
+	if (real_dev->mtu < new_mtu)
 		return -ERANGE;
 
+	orig_mtu = dev->mtu;
 	dev->mtu = new_mtu;
 
-	return 0;
+	err = vlan_dev_enc_hdr_len(dev, dev->enc_hdr_len);
+	if (err)
+		dev->mtu = orig_mtu;
+
+	return err;
 }
 
 void vlan_dev_set_ingress_priority(const struct net_device *dev,
@@ -532,6 +550,8 @@ static const struct net_device_ops vlan_netdev_ops;
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = vlan_dev_priv(dev)->real_dev;
+	int enc_hdr_len;
+	int err;
 
 	netif_carrier_off(dev);
 
@@ -583,6 +603,23 @@ static int vlan_dev_init(struct net_device *dev)
 
 	vlan_dev_set_lockdep_class(dev, vlan_dev_get_lock_subclass(dev));
 
+	if (vlan_dev_priv(dev)->vlan_proto == htons(ETH_P_8021AD))
+		dev->enc_hdr_len = VLAN_HLEN;
+
+	enc_hdr_len = dev->enc_hdr_len + VLAN_HLEN;
+	err = dev_set_enc_hdr_len(real_dev, enc_hdr_len);
+	if (err) {
+		int new_mtu = real_dev->mtu + real_dev->enc_hdr_len -
+			      enc_hdr_len;
+
+		if (new_mtu < 0)
+			return -ENOSPC;
+
+		netdev_warn(dev, "Failed to expand encap header room to %d on real device. Decrease MTU to %d on vlan device.\n",
+			    enc_hdr_len, new_mtu);
+		dev->mtu = new_mtu;
+	}
+
 	vlan_dev_priv(dev)->vlan_pcpu_stats = netdev_alloc_pcpu_stats(struct vlan_pcpu_stats);
 	if (!vlan_dev_priv(dev)->vlan_pcpu_stats)
 		return -ENOMEM;
@@ -776,6 +813,7 @@ static const struct net_device_ops vlan_netdev_ops = {
 	.ndo_fix_features	= vlan_dev_fix_features,
 	.ndo_get_lock_subclass  = vlan_dev_get_lock_subclass,
 	.ndo_get_iflink		= vlan_dev_get_iflink,
+	.ndo_enc_hdr_len	= vlan_dev_enc_hdr_len,
 };
 
 static void vlan_dev_free(struct net_device *dev)
-- 
1.8.1.2
