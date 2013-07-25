From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2] tuntap: hardware vlan tx support
Date: Thu, 25 Jul 2013 13:00:33 +0800
Message-ID: <1374728433-19843-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>, Basil Gor <basil.gor@gmail.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22637 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751504Ab3GYFLi (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 25 Jul 2013 01:11:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Inspired by commit f09e2249c4f5c7c13261ec73f5a7807076af0c8e (macvtap: restore
vlan header on user read). This patch adds hardware vlan tx support for
tuntap. This is done by copying vlan header directly into userspace in
tun_put_user() instead of doing it through __vlan_put_tag() in
dev_hard_start_xmit(). This eliminates one unnecessary memmove() in
vlan_insert_tag() for 802.1ad and 802.1q traffic.

pktgen test shows about 20% improvement for 802.1q traffic:

Before:
  662149pps 317Mb/sec (317831520bps) errors: 0
After:
  801033pps 384Mb/sec (384495840bps) errors: 0

Cc: Basil Gor <basil.gor@gmail.com>
Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
Changes from V1:
- typo and style fixes
---
 drivers/net/tun.c |   40 ++++++++++++++++++++++++++++++++++++----
 1 files changed, 36 insertions(+), 4 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index a72d141..5dce262 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -60,6 +60,7 @@
 #include <linux/if_arp.h>
 #include <linux/if_ether.h>
 #include <linux/if_tun.h>
+#include <linux/if_vlan.h>
 #include <linux/crc32.h>
 #include <linux/nsproxy.h>
 #include <linux/virtio_net.h>
@@ -1265,6 +1266,7 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 {
 	struct tun_pi pi = { 0, skb->protocol };
 	ssize_t total = 0;
+	int vlan_offset = 0;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) < 0)
@@ -1328,11 +1330,40 @@ static ssize_t tun_put_user(struct tun_struct *tun,
 		total += tun->vnet_hdr_sz;
 	}
 
-	len = min_t(int, skb->len, len);
+	if (!vlan_tx_tag_present(skb)) {
+		len = min_t(int, skb->len, len);
+	} else {
+		int copy, ret;
+		struct {
+			__be16 h_vlan_proto;
+			__be16 h_vlan_TCI;
+		} veth;
+
+		veth.h_vlan_proto = skb->vlan_proto;
+		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
+
+		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
+		len = min_t(int, skb->len + VLAN_HLEN, len);
+
+		copy = min_t(int, vlan_offset, len);
+		ret = skb_copy_datagram_const_iovec(skb, 0, iv, total, copy);
+		len -= copy;
+		total += copy;
+		if (ret || !len)
+			goto done;
+
+		copy = min_t(int, sizeof(veth), len);
+		ret = memcpy_toiovecend(iv, (void *)&veth, total, copy);
+		len -= copy;
+		total += copy;
+		if (ret || !len)
+			goto done;
+	}
 
-	skb_copy_datagram_const_iovec(skb, 0, iv, total, len);
-	total += skb->len;
+	skb_copy_datagram_const_iovec(skb, vlan_offset, iv, total, len);
+	total += len;
 
+done:
 	tun->dev->stats.tx_packets++;
 	tun->dev->stats.tx_bytes += len;
 
@@ -1691,7 +1722,8 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
 		tun_flow_init(tun);
 
 		dev->hw_features = NETIF_F_SG | NETIF_F_FRAGLIST |
-			TUN_USER_FEATURES;
+				   TUN_USER_FEATURES | NETIF_F_HW_VLAN_CTAG_TX |
+				   NETIF_F_HW_VLAN_STAG_TX;
 		dev->features = dev->hw_features;
 		dev->vlan_features = dev->features;
 
-- 
1.7.1
