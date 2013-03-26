From: Jason Wang <jasowang@redhat.com>
Subject: [net-next 2/5] tuntap: set transport header before passing it to kernel
Date: Tue, 26 Mar 2013 14:19:56 +0800
Message-ID: <1364278799-37285-3-git-send-email-jasowang@redhat.com>
References: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Cc: mst@redhat.com, Jason Wang <jasowang@redhat.com>,
	Eric Dumazet <edumazet@google.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1364278799-37285-1-git-send-email-jasowang@redhat.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Currently, for the packets receives from tuntap, before doing header check,
kernel just reset the transport header in netif_receive_skb() which pretends no
l4 header. This is suboptimal for precise packet length estimation (introduced
in 1def9238) which needs correct l4 header for gso packets.

So this patch set the transport header to csum_start for partial checksum
packets, otherwise it first try skb_flow_dissect(), if it fails, just reset the
transport header.

Cc: Eric Dumazet <edumazet@google.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
---
 drivers/net/tun.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 95837c1..48cd73a 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -70,6 +70,7 @@
 #include <net/sock.h>
 
 #include <asm/uaccess.h>
+#include <net/flow_keys.h>
 
 /* Uncomment to enable debugging */
 /* #define TUN_DEBUG 1 */
@@ -1049,6 +1050,7 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	bool zerocopy = false;
 	int err;
 	u32 rxhash;
+	struct flow_keys keys;
 
 	if (!(tun->flags & TUN_NO_PI)) {
 		if ((len -= sizeof(pi)) > total_len)
@@ -1203,6 +1205,14 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	}
 
 	skb_reset_network_header(skb);
+
+	if (skb->ip_summed == CHECKSUM_PARTIAL)
+		skb_set_transport_header(skb, skb_checksum_start_offset(skb));
+	else if (skb_flow_dissect(skb, &keys))
+		skb_set_transport_header(skb, keys.thoff);
+	else
+		skb_reset_transport_header(skb);
+
 	rxhash = skb_get_rxhash(skb);
 	netif_rx_ni(skb);
 
-- 
1.7.1
