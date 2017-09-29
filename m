From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 4/7] net: dsa: add tagging ops to port
Date: Fri, 29 Sep 2017 17:19:18 -0400
Message-ID: <20170929211921.5571-5-vivien.didelot@savoirfairelinux.com>
References: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20170929211921.5571-1-vivien.didelot@savoirfairelinux.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The DSA tagging protocol operations are specific to each CPU port,
thus the dsa_device_ops pointer belongs to the dsa_port structure.

>From now on assign a slave's xmit copy from its CPU port tagging
operations. This will ease the future support for multiple CPU ports.

Also keep the tag_ops at the beginning of the dsa_port structure so that
we ensure copies for hot path are in cacheline 1.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h  | 3 +++
 net/dsa/dsa2.c     | 1 +
 net/dsa/dsa_priv.h | 2 +-
 net/dsa/legacy.c   | 1 +
 net/dsa/slave.c    | 3 +--
 5 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 8dee216a5a9b..4d1df2f086e8 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -175,6 +175,9 @@ struct dsa_mall_tc_entry {
 
 
 struct dsa_port {
+	/* CPU port tagging operations used by master or slave devices */
+	const struct dsa_device_ops *tag_ops;
+
 	struct dsa_switch	*ds;
 	unsigned int		index;
 	const char		*name;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 6a10c5c1639f..9eac4726dc0c 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -522,6 +522,7 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 		return PTR_ERR(tag_ops);
 	}
 
+	dst->cpu_dp->tag_ops = tag_ops;
 	dst->tag_ops = tag_ops;
 	dst->rcv = dst->tag_ops->rcv;
 
diff --git a/net/dsa/dsa_priv.h b/net/dsa/dsa_priv.h
index d429505dc4e7..9397291bb3aa 100644
--- a/net/dsa/dsa_priv.h
+++ b/net/dsa/dsa_priv.h
@@ -66,7 +66,7 @@ struct dsa_notifier_vlan_info {
 };
 
 struct dsa_slave_priv {
-	/* Copy of dp->ds->dst->tag_ops->xmit for faster access in hot path */
+	/* Copy of CPU port xmit for faster access in slave transmit hot path */
 	struct sk_buff *	(*xmit)(struct sk_buff *skb,
 					struct net_device *dev);
 
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 8e849013f69d..4d374541815a 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -152,6 +152,7 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 		if (IS_ERR(tag_ops))
 			return PTR_ERR(tag_ops);
 
+		dst->cpu_dp->tag_ops = tag_ops;
 		dst->tag_ops = tag_ops;
 		dst->rcv = dst->tag_ops->rcv;
 	}
diff --git a/net/dsa/slave.c b/net/dsa/slave.c
index bf8800de13c1..4b634db05cee 100644
--- a/net/dsa/slave.c
+++ b/net/dsa/slave.c
@@ -1117,7 +1117,6 @@ int dsa_slave_resume(struct net_device *slave_dev)
 int dsa_slave_create(struct dsa_port *port, const char *name)
 {
 	struct dsa_switch *ds = port->ds;
-	struct dsa_switch_tree *dst = ds->dst;
 	struct net_device *master;
 	struct net_device *slave_dev;
 	struct dsa_slave_priv *p;
@@ -1162,7 +1161,7 @@ int dsa_slave_create(struct dsa_port *port, const char *name)
 	}
 	p->dp = port;
 	INIT_LIST_HEAD(&p->mall_tc_list);
-	p->xmit = dst->tag_ops->xmit;
+	p->xmit = cpu_dp->tag_ops->xmit;
 
 	p->old_pause = -1;
 	p->old_link = -1;
-- 
2.14.1
