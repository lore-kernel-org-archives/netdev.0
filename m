From: Or Gerlitz <ogerlitz@mellanox.com>
Subject: [PATCH net-next] net/udp_offload: Handle static checker complaints
Date: Wed, 22 Jan 2014 15:23:29 +0200
Message-ID: <1390397009-28280-1-git-send-email-ogerlitz@mellanox.com>
Cc: netdev@vger.kernel.org, Shlomo Pongratz <shlomop@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailp.voltaire.com ([193.47.165.129]:51097 "EHLO mellanox.co.il"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1755612AbaAVNXg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 22 Jan 2014 08:23:36 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shlomo Pongratz <shlomop@mellanox.com>

Fixed few issues around using __rcu prefix and rcu_assign_pointer, also
fixed a warning print to use ntohs(port) and not htons(port).

net/ipv4/udp_offload.c:112:9: error: incompatible types in comparison expression (different address spaces)
net/ipv4/udp_offload.c:113:9: error: incompatible types in comparison expression (different address spaces)
net/ipv4/udp_offload.c:176:19: error: incompatible types in comparison expression (different address spaces)

Signed-off-by: Shlomo Pongratz <shlomop@mellanox.com>
Signed-off-by: Or Gerlitz <ogerlitz@mellanox.com>
---
 net/ipv4/udp_offload.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index ee853c5..25f5cee 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -15,7 +15,7 @@
 #include <net/protocol.h>
 
 static DEFINE_SPINLOCK(udp_offload_lock);
-static struct udp_offload_priv *udp_offload_base __read_mostly;
+static struct udp_offload_priv __rcu *udp_offload_base __read_mostly;
 
 struct udp_offload_priv {
 	struct udp_offload	*offload;
@@ -100,7 +100,7 @@ out:
 
 int udp_add_offload(struct udp_offload *uo)
 {
-	struct udp_offload_priv **head = &udp_offload_base;
+	struct udp_offload_priv __rcu **head = &udp_offload_base;
 	struct udp_offload_priv *new_offload = kzalloc(sizeof(*new_offload), GFP_KERNEL);
 
 	if (!new_offload)
@@ -110,7 +110,7 @@ int udp_add_offload(struct udp_offload *uo)
 
 	spin_lock(&udp_offload_lock);
 	rcu_assign_pointer(new_offload->next, rcu_dereference(*head));
-	rcu_assign_pointer(*head, rcu_dereference(new_offload));
+	rcu_assign_pointer(*head, new_offload);
 	spin_unlock(&udp_offload_lock);
 
 	return 0;
@@ -140,7 +140,7 @@ void udp_del_offload(struct udp_offload *uo)
 		}
 		head = &uo_priv->next;
 	}
-	pr_warn("udp_del_offload: didn't find offload for port %d\n", htons(uo->port));
+	pr_warn("udp_del_offload: didn't find offload for port %d\n", ntohs(uo->port));
 unlock:
 	spin_unlock(&udp_offload_lock);
 	if (uo_priv != NULL)
-- 
1.7.1
