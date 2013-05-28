From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net] hyperv: Fix vlan_proto setting in netvsc_recv_callback()
Date: Tue, 28 May 2013 09:15:56 -0700
Message-ID: <1369757756-24572-1-git-send-email-haiyangz@microsoft.com>
Cc: haiyangz@microsoft.com, kys@microsoft.com, olaf@aepfle.de,
	jasowang@redhat.com, linux-kernel@vger.kernel.org,
	devel@linuxdriverproject.org
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since the recent addition of 8021AD, we need to set the new field vlan_proto in
sk_buff. Otherwise, it will trigger BUG() call in vlan_proto_idx().

This patch fixes the problem.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>

---
 drivers/net/hyperv/netvsc_drv.c |    3 ++-
 1 files changed, 2 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index 088c554..ab2307b 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -31,6 +31,7 @@
 #include <linux/inetdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/skbuff.h>
+#include <linux/if_vlan.h>
 #include <linux/in.h>
 #include <linux/slab.h>
 #include <net/arp.h>
@@ -284,7 +285,7 @@ int netvsc_recv_callback(struct hv_device *device_obj,
 
 	skb->protocol = eth_type_trans(skb, net);
 	skb->ip_summed = CHECKSUM_NONE;
-	skb->vlan_tci = packet->vlan_tci;
+	__vlan_hwaccel_put_tag(skb, htons(ETH_P_8021Q), packet->vlan_tci);
 
 	net->stats.rx_packets++;
 	net->stats.rx_bytes += packet->total_data_buflen;
-- 
1.7.4.1
