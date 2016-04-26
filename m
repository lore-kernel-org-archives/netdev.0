From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next V2] tuntap: calculate rps hash only when needed
Date: Mon, 25 Apr 2016 23:13:42 -0400
Message-ID: <1461640422-20779-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.ne, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

There's no need to calculate rps hash if it was not enabled. So this
patch export rps_needed and check it before trying to get rps
hash. Tests (using pktgen to inject packets to guest) shows this can
improve pps about 13% (when rps is disabled).

Before:
~1150000 pps
After:
~1300000 pps

Cc: Michael S. Tsirkin <mst@redhat.com>
Signed-off-by: Jason Wang <jasowang@redhat.com>
----
Changes from V1:
- Fix build when CONFIG_RPS is not set
---
 drivers/net/tun.c | 4 +++-
 net/core/dev.c    | 1 +
 2 files changed, 4 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950..8df9e23 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -819,7 +819,8 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (txq >= numqueues)
 		goto drop;
 
-	if (numqueues == 1) {
+#ifdef CONFIG_RPS
+	if (numqueues == 1 && static_key_false(&rps_needed)) {
 		/* Select queue was not called for the skbuff, so we extract the
 		 * RPS hash and save it into the flow_table here.
 		 */
@@ -834,6 +835,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 				tun_flow_save_rps_rxhash(e, rxhash);
 		}
 	}
+#endif
 
 	tun_debug(KERN_INFO, tun, "tun_net_xmit %d\n", skb->len);
 
diff --git a/net/core/dev.c b/net/core/dev.c
index b9bcbe7..d4ba936 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3428,6 +3428,7 @@ u32 rps_cpu_mask __read_mostly;
 EXPORT_SYMBOL(rps_cpu_mask);
 
 struct static_key rps_needed __read_mostly;
+EXPORT_SYMBOL(rps_needed);
 
 static struct rps_dev_flow *
 set_rps_cpu(struct net_device *dev, struct sk_buff *skb,
-- 
1.8.3.1
