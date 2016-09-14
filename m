From: Grygorii Strashko <grygorii.strashko@ti.com>
Subject: [PATCH 5/9] net: ethernet: ti: cpts: add return value to tx and rx timestamp funcitons
Date: Wed, 14 Sep 2016 16:02:27 +0300
Message-ID: <20160914130231.3035-6-grygorii.strashko@ti.com>
References: <20160914130231.3035-1-grygorii.strashko@ti.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Sekhar Nori <nsekhar@ti.com>, <linux-kernel@vger.kernel.org>,
        <linux-omap@vger.kernel.org>, WingMan Kwok <w-kwok2@ti.com>,
        Grygorii Strashko <grygorii.strashko@ti.com>
To: "David S. Miller" <davem@davemloft.net>, <netdev@vger.kernel.org>,
        Mugunthan V N <mugunthanvnm@ti.com>,
        Richard Cochran <richardcochran@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from comal.ext.ti.com ([198.47.26.152]:51700 "EHLO comal.ext.ti.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1762008AbcINNCp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 14 Sep 2016 09:02:45 -0400
In-Reply-To: <20160914130231.3035-1-grygorii.strashko@ti.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: WingMan Kwok <w-kwok2@ti.com>

Added return values in tx and rx timestamp funcitons facilitate the
possibililies of timestamping by CPSW modules other than CPTS, such as
packet accelerator on Keystone 2 devices.

Signed-off-by: WingMan Kwok <w-kwok2@ti.com>
Signed-off-by: Grygorii Strashko <grygorii.strashko@ti.com>
---
 drivers/net/ethernet/ti/cpts.c | 16 ++++++++++------
 drivers/net/ethernet/ti/cpts.h | 11 +++++++----
 2 files changed, 17 insertions(+), 10 deletions(-)

diff --git a/drivers/net/ethernet/ti/cpts.c b/drivers/net/ethernet/ti/cpts.c
index 1ee64c6..970d4e2 100644
--- a/drivers/net/ethernet/ti/cpts.c
+++ b/drivers/net/ethernet/ti/cpts.c
@@ -302,34 +302,38 @@ static u64 cpts_find_ts(struct cpts *cpts, struct sk_buff *skb, int ev_type)
 	return ns;
 }
 
-void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
+int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
 	u64 ns;
 	struct skb_shared_hwtstamps *ssh;
 
 	if (!cpts || !cpts->rx_enable)
-		return;
+		return -EPERM;
 	ns = cpts_find_ts(cpts, skb, CPTS_EV_RX);
 	if (!ns)
-		return;
+		return -ENOENT;
 	ssh = skb_hwtstamps(skb);
 	memset(ssh, 0, sizeof(*ssh));
 	ssh->hwtstamp = ns_to_ktime(ns);
+
+	return 0;
 }
 
-void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
+int cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
 	u64 ns;
 	struct skb_shared_hwtstamps ssh;
 
 	if (!cpts || !(skb_shinfo(skb)->tx_flags & SKBTX_IN_PROGRESS))
-		return;
+		return -EPERM;
 	ns = cpts_find_ts(cpts, skb, CPTS_EV_TX);
 	if (!ns)
-		return;
+		return -ENOENT;
 	memset(&ssh, 0, sizeof(ssh));
 	ssh.hwtstamp = ns_to_ktime(ns);
 	skb_tstamp_tx(skb, &ssh);
+
+	return 0;
 }
 
 int cpts_register(struct cpts *cpts)
diff --git a/drivers/net/ethernet/ti/cpts.h b/drivers/net/ethernet/ti/cpts.h
index a865193..47026ec 100644
--- a/drivers/net/ethernet/ti/cpts.h
+++ b/drivers/net/ethernet/ti/cpts.h
@@ -129,8 +129,8 @@ struct cpts {
 	struct cpts_event pool_data[CPTS_MAX_EVENTS];
 };
 
-void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
-void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
+int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb);
+int cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb);
 int cpts_register(struct cpts *cpts);
 void cpts_unregister(struct cpts *cpts);
 struct cpts *cpts_create(struct device *dev, void __iomem *regs,
@@ -162,11 +162,14 @@ static inline bool cpts_is_tx_enabled(struct cpts *cpts)
 #else
 struct cpts;
 
-static inline void cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
+static inline int cpts_rx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
+	return -EOPNOTSUPP;
 }
-static inline void cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
+
+static inline int cpts_tx_timestamp(struct cpts *cpts, struct sk_buff *skb)
 {
+	return -EOPNOTSUPP;
 }
 
 static inline
-- 
2.9.3
