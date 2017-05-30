From: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
Subject: [PATCH net-next 2/7] net: dsa: remove useless rcv copy in DSA tree
Date: Tue, 30 May 2017 10:21:26 -0400
Message-ID: <20170530142131.23568-3-vivien.didelot@savoirfairelinux.com>
References: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Cc: linux-kernel@vger.kernel.org, kernel@savoirfairelinux.com,
        "David S. Miller" <davem@davemloft.net>,
        Florian Fainelli <f.fainelli@gmail.com>,
        Andrew Lunn <andrew@lunn.ch>,
        Vivien Didelot <vivien.didelot@savoirfairelinux.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.savoirfairelinux.com ([208.88.110.44]:43402 "EHLO
        mail.savoirfairelinux.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751340AbdE3OXq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 30 May 2017 10:23:46 -0400
In-Reply-To: <20170530142131.23568-1-vivien.didelot@savoirfairelinux.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The dsa_switch_tree holds a copy of the rcv member of the dsa_device_ops
structure. dst->rcv is always assigned to dst->tag_ops->rcv. Remove this
useless copy.

Signed-off-by: Vivien Didelot <vivien.didelot@savoirfairelinux.com>
---
 include/net/dsa.h | 4 ----
 net/dsa/dsa.c     | 4 ++--
 net/dsa/dsa2.c    | 2 --
 net/dsa/legacy.c  | 2 --
 4 files changed, 2 insertions(+), 10 deletions(-)

diff --git a/include/net/dsa.h b/include/net/dsa.h
index cb5d668b265d..4b82766715e9 100644
--- a/include/net/dsa.h
+++ b/include/net/dsa.h
@@ -126,10 +126,6 @@ struct dsa_switch_tree {
 	 * protocol to use.
 	 */
 	struct net_device	*master_netdev;
-	struct sk_buff *	(*rcv)(struct sk_buff *skb,
-				       struct net_device *dev,
-				       struct packet_type *pt,
-				       struct net_device *orig_dev);
 
 	/*
 	 * Original copy of the master netdev ethtool_ops
diff --git a/net/dsa/dsa.c b/net/dsa/dsa.c
index 7a8a0358299b..861dc0e5020d 100644
--- a/net/dsa/dsa.c
+++ b/net/dsa/dsa.c
@@ -29,7 +29,7 @@
 
 bool dsa_uses_tagged_protocol(struct dsa_switch_tree *dst)
 {
-	return !!dst->rcv;
+	return dst->tag_ops && dst->tag_ops->rcv;
 }
 
 static struct sk_buff *dsa_slave_notag_xmit(struct sk_buff *skb,
@@ -209,7 +209,7 @@ static int dsa_switch_rcv(struct sk_buff *skb, struct net_device *dev,
 	if (!skb)
 		return 0;
 
-	nskb = dst->rcv(skb, dev, pt, orig_dev);
+	nskb = dst->tag_ops->rcv(skb, dev, pt, orig_dev);
 	if (!nskb) {
 		kfree_skb(skb);
 		return 0;
diff --git a/net/dsa/dsa2.c b/net/dsa/dsa2.c
index 4301f52e4f5a..12306c15ed51 100644
--- a/net/dsa/dsa2.c
+++ b/net/dsa/dsa2.c
@@ -528,8 +528,6 @@ static int dsa_cpu_parse(struct dsa_port *port, u32 index,
 		return PTR_ERR(dst->tag_ops);
 	}
 
-	dst->rcv = dst->tag_ops->rcv;
-
 	return 0;
 }
 
diff --git a/net/dsa/legacy.c b/net/dsa/legacy.c
index ac4379b8d7ac..738c5c2d7d3c 100644
--- a/net/dsa/legacy.c
+++ b/net/dsa/legacy.c
@@ -150,8 +150,6 @@ static int dsa_switch_setup_one(struct dsa_switch *ds, struct device *parent)
 		dst->tag_ops = dsa_resolve_tag_protocol(tag_protocol);
 		if (IS_ERR(dst->tag_ops))
 			return PTR_ERR(dst->tag_ops);
-
-		dst->rcv = dst->tag_ops->rcv;
 	}
 
 	memcpy(ds->rtable, cd->rtable, sizeof(ds->rtable));
-- 
2.13.0
