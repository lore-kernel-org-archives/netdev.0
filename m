From: Jason Wang <jasowang@redhat.com>
Subject: [PATCH net-next] tuntap: calculate rps hash only when needed
Date: Mon, 25 Apr 2016 21:55:41 -0400
Message-ID: <1461635741-18857-1-git-send-email-jasowang@redhat.com>
Cc: Jason Wang <jasowang@redhat.com>,
	"Michael S. Tsirkin" <mst@redhat.com>
To: davem@davemloft.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:51407 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750821AbcDZBzq (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2016 21:55:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
---
 drivers/net/tun.c | 2 +-
 net/core/dev.c    | 1 +
 2 files changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index afdf950..746877f 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -819,7 +819,7 @@ static netdev_tx_t tun_net_xmit(struct sk_buff *skb, struct net_device *dev)
 	if (txq >= numqueues)
 		goto drop;
 
-	if (numqueues == 1) {
+	if (numqueues == 1 && static_key_false(&rps_needed)) {
 		/* Select queue was not called for the skbuff, so we extract the
 		 * RPS hash and save it into the flow_table here.
 		 */
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
