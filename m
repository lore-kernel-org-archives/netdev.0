From: Basil Gor <basil.gor@gmail.com>
Subject: [PATCH v4 2/2] macvtap: restore vlan header on user read
Date: Fri,  4 May 2012 12:55:24 +0400
Message-ID: <1336121724-31902-2-git-send-email-basil.gor@gmail.com>
Cc: "Eric W. Biederman" <ebiederm@xmission.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: "Michael S. Tsirkin" <mst@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:36173 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753610Ab2EDI4R (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 May 2012 04:56:17 -0400
Received: by mail-bk0-f46.google.com with SMTP id ji2so2013904bkc.19
        for <netdev@vger.kernel.org>; Fri, 04 May 2012 01:56:17 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ethernet vlan header is not on the packet and kept in the skb->vlan_tci
when it comes from lower dev. This patch inserts vlan header in user
buffer during skb copy on user read.

Signed-off-by: Basil Gor <basil.gor@gmail.com>
---
 drivers/net/macvtap.c |   43 ++++++++++++++++++++++++++++++++++++++-----
 1 files changed, 38 insertions(+), 5 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index 0427c65..cb8fd50 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -1,5 +1,6 @@
 #include <linux/etherdevice.h>
 #include <linux/if_macvlan.h>
+#include <linux/if_vlan.h>
 #include <linux/interrupt.h>
 #include <linux/nsproxy.h>
 #include <linux/compat.h>
@@ -759,6 +760,8 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 	struct macvlan_dev *vlan;
 	int ret;
 	int vnet_hdr_len = 0;
+	int vlan_offset = 0;
+	int copied;
 
 	if (q->flags & IFF_VNET_HDR) {
 		struct virtio_net_hdr vnet_hdr;
@@ -773,18 +776,48 @@ static ssize_t macvtap_put_user(struct macvtap_queue *q,
 		if (memcpy_toiovecend(iv, (void *)&vnet_hdr, 0, sizeof(vnet_hdr)))
 			return -EFAULT;
 	}
+	copied = vnet_hdr_len;
+
+	if (!vlan_tx_tag_present(skb))
+		len = min_t(int, skb->len, len);
+	else {
+		int copy;
+		struct {
+			__be16 h_vlan_proto;
+			__be16 h_vlan_TCI;
+		} veth;
+		veth.h_vlan_proto = htons(ETH_P_8021Q);
+		veth.h_vlan_TCI = htons(vlan_tx_tag_get(skb));
+
+		vlan_offset = offsetof(struct vlan_ethhdr, h_vlan_proto);
+		len = min_t(int, skb->len + VLAN_HLEN, len);
+
+		copy = min_t(int, vlan_offset, len);
+		ret = skb_copy_datagram_const_iovec(skb, 0, iv, copied, copy);
+		len -= copy;
+		copied += copy;
+		if (ret || !len)
+			goto done;
+
+		copy = min_t(int, sizeof(veth), len);
+		ret = memcpy_toiovecend(iv, (void *)&veth, copied, copy);
+		len -= copy;
+		copied += copy;
+		if (ret || !len)
+			goto done;
+	}
 
-	len = min_t(int, skb->len, len);
-
-	ret = skb_copy_datagram_const_iovec(skb, 0, iv, vnet_hdr_len, len);
+	ret = skb_copy_datagram_const_iovec(skb, vlan_offset, iv, copied, len);
+	copied += len;
 
+done:
 	rcu_read_lock_bh();
 	vlan = rcu_dereference_bh(q->vlan);
 	if (vlan)
-		macvlan_count_rx(vlan, len, ret == 0, 0);
+		macvlan_count_rx(vlan, copied - vnet_hdr_len, ret == 0, 0);
 	rcu_read_unlock_bh();
 
-	return ret ? ret : (len + vnet_hdr_len);
+	return ret ? ret : copied;
 }
 
 static ssize_t macvtap_do_read(struct macvtap_queue *q, struct kiocb *iocb,
-- 
1.7.6.5
