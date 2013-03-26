From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 1/5] macvtap: set transport header before passing skb to lower device
Date: Tue, 26 Mar 2013 14:19:55 +0800
Message-ID: <1364278799-37285-2-git-send-email-jasowang@redhat.com>
References: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Set the transport header for 1) some drivers (e.g ixgbe) needs l4 header 2)
precise packet length estimation (introduced in 1def9238) needs l4 header to
compute header length.

For the packets with partial checksum, the patch just set the transport header
to csum_start. Otherwise tries to use skb_flow_dissect() to get l4 offset, if it
fails, just pretend no l4 header.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/macvtap.c |    9 +++++++++
 1 files changed, 9 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvtap.c b/drivers/net/macvtap.c
index a449439..acf6450 100644
--- a/drivers/net/macvtap.c
+++ b/drivers/net/macvtap.c
@@ -21,6 +21,7 @@
 #include <net/rtnetlink.h>
 #include <net/sock.h>
 #include <linux/virtio_net.h>
+#include <net/flow_keys.h>
 
 /*
  * A macvtap queue is the central object of this driver, it connects
@@ -645,6 +646,7 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 	int vnet_hdr_len = 0;
 	int copylen = 0;
 	bool zerocopy = false;
+	struct flow_keys keys;
 
 	if (q->flags & IFF_VNET_HDR) {
 		vnet_hdr_len = q->vnet_hdr_sz;
@@ -725,6 +727,13 @@ static ssize_t macvtap_get_user(struct macvtap_queue *q, struct msghdr *m,
 			goto err_kfree;
 	}
 
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		skb_set_transport_header(skb, skb_checksum_start_offset(skb));
+	else if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_set_transport_header(skb, ETH_HLEN);
+
 	rcu_read_lock_bh();
 	vlan = rcu_dereference_bh(q->vlan);
 	/* copy skb_ubuf_info for callback when skb has no error */
-- 
1.7.1
