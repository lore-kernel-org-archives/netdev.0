From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 6/7] net: dsa: remove useless copy of tagger xmit
Date: Tue, 30 May 2017 10:21:30 -0400
Message-ID: <20170530142131.23568-7-vivien.didelot@savoirfairelinux.com>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The dsa_slave_priv structure holds a copy of the dsa_device_ops xmit
function. It is always assigned to the switch tree xmit function.

Remove this useless copy.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 net/dsa/dsa_priv.h | 3 ---
 net/dsa/slave.c    | 4 +---
 2 files changed, 1 insertion(+), 6 deletions(-)

diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index 0fdd2a8a4ad8..282a55639285 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -71,9 +71,6 @@ struct dsa_device_ops {
 };
 
 struct dsa_slave_priv {
-	struct sk_buff *	(*xmit)(struct sk_buff *skb,
-					struct net_device *dev);
-
 	/* DSA port data, such as switch, port index, etc. */
 	struct dsa_port		*dp;
 
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index 887e26695519..ebad2af4d3a8 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -363,7 +363,7 @@ static netdev_tx_t dsa_slave_xmit(struct sk_buff *skb, struct net_device *dev)
 	dev->stats.tx_bytes += skb->len;
 
 	/* Transmit function may have to reallocate the original SKB */
-	nskb = p->xmit(skb, dev);
+	nskb = p->dp->ds->dst->tag_ops->xmit(skb, dev);
 	if (!nskb)
 		return NETDEV_TX_OK;
 
@@ -1136,7 +1136,6 @@ int dsa_slave_resume(struct net_device *slave_dev)
 int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 		     int port, const char *name)
 {
-	struct dsa_switch_tree *dst = ds->dst;
 	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
@@ -1172,7 +1171,6 @@ int dsa_slave_create(struct dsa_switch *ds, struct device *parent,
 	p = netdev_priv(slave_dev);
 	p->dp = &ds->ports[port];
 	INIT_LIST_HEAD(&p->mall_tc_list);
-	p->xmit = dst->tag_ops->xmit;
 
 	p->old_pause = -1;
 	p->old_link = -1;
-- 
2.13.0
