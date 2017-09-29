From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next v2 5/7] net: dsa: prepare master receive hot path
Date: Fri, 29 Sep 2017 17:19:19 -0400
Message-ID: <20170929211921.5571-6-vivien.didelot@savoirfairelinux.com>
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

In preparation to make DSA master devices point to their corresponding
CPU port instead of the whole tree, add copies of dst and rcv in the
dsa_port structure so that we keep fast access in the receive hot path.

Also keep the copies at the beginning of the dsa_port structure in order
to ensure they are available in cacheline 1.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 5 +++++
 net/dsa/dsa2.c    | 4 ++++
 net/dsa/legacy.c  | 4 ++++
 3 files changed, 13 insertions(+)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index 4d1df2f086e8..6bda01fa5747 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -178,6 +178,11 @@ struct dsa_port {
 	/* CPU port tagging operations used by master or slave devices */
 	const struct dsa_device_ops *tag_ops;
 
+	/* Copies for faster access in master receive hot path */
+	struct dsa_switch_tree *dst;
+	struct sk_buff *(*rcv)(struct sk_buff *skb, struct net_device *dev,
+			       struct packet_type *pt);
+
 	struct dsa_switch	*ds;
 	unsigned int		index;
 	const char		*name;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 9eac4726dc0c..b71e3bb478e4 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -524,7 +524,11 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 
 	dst->cpu_dp->tag_ops = tag_ops;
 	dst->tag_ops = tag_ops;
+
+	/* Make a few copies for faster access in master receive hot path */
+	dst->cpu_dp->rcv = dst->cpu_dp->tag_ops->rcv;
 	dst->rcv = dst->tag_ops->rcv;
+	dst->cpu_dp->dst = dst;
 
 	return 0;
 }
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index 4d374541815a..96c7e3f8b8bb 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -154,7 +154,11 @@ static int dsa_switch_setup_one(struct dsa_switch *ds,
 
 		dst->cpu_dp->tag_ops = tag_ops;
 		dst->tag_ops = tag_ops;
+
+		/* Few copies for faster access in master receive hot path */
+		dst->cpu_dp->rcv = dst->cpu_dp->tag_ops->rcv;
 		dst->rcv = dst->tag_ops->rcv;
+		dst->cpu_dp->dst = dst;
 	}
 
 	memcpy(ds->rtable, cd->rtable, sizeof(ds->rtable));
-- 
2.14.1
