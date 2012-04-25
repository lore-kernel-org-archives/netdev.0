From: Antonio Quartulli <ordex@autistici.org>
Subject: [PATCH 07/15] batman-adv: Distributed ARP Table - increase default soft_iface ARP table timeout
Date: Wed, 25 Apr 2012 15:27:03 +0200
Message-ID: <1335360431-30027-8-git-send-email-ordex@autistici.org>
References: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <ordex@autistici.org>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from investici.nine.ch ([217.150.252.179]:38990 "EHLO
	confino.investici.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756805Ab2DYN0X (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 25 Apr 2012 09:26:23 -0400
In-Reply-To: <1335360431-30027-1-git-send-email-ordex@autistici.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The default timeout value for ARP entries belonging to any soft_iface
ARP table has been incremented by a factor 4. This is necessary because the DHT
will store several network entries in the soft_iface ARP table.

Signed-off-by: Antonio Quartulli <ordex@autistici.org>
---
 net/batman-adv/distributed-arp-table.c |   20 ++++++++++++++++++++
 net/batman-adv/distributed-arp-table.h |    1 +
 net/batman-adv/main.h                  |    4 ++++
 net/batman-adv/soft-interface.c        |    2 ++
 4 files changed, 27 insertions(+)

diff --git a/net/batman-adv/distributed-arp-table.c b/net/batman-adv/distributed-arp-table.c
index f3b63ef..24b17131 100644
--- a/net/batman-adv/distributed-arp-table.c
+++ b/net/batman-adv/distributed-arp-table.c
@@ -23,6 +23,7 @@
 #include <linux/if_arp.h>
 /* needed to use arp_tbl */
 #include <net/arp.h>
+#include <linux/inetdevice.h>
 
 #include "main.h"
 #include "distributed-arp-table.h"
@@ -583,3 +584,22 @@ bool dat_drop_broadcast_packet(struct bat_priv *bat_priv,
 	}
 	return false;
 }
+
+void arp_change_timeout(struct net_device *soft_iface, const char *name)
+{
+	struct in_device *in_dev = in_dev_get(soft_iface);
+	if (!in_dev) {
+		pr_err("Unable to set ARP parameters for the batman interface '%s'\n",
+		       name);
+		return;
+	}
+
+	/* Introduce a delay in the ARP state-machine transactions. Entries
+	 * will be kept in the ARP table for the default time multiplied by 4
+	 */
+	in_dev->arp_parms->base_reachable_time *= ARP_TIMEOUT_FACTOR;
+	in_dev->arp_parms->gc_staletime *= ARP_TIMEOUT_FACTOR;
+	in_dev->arp_parms->reachable_time *= ARP_TIMEOUT_FACTOR;
+
+	in_dev_put(in_dev);
+}
diff --git a/net/batman-adv/distributed-arp-table.h b/net/batman-adv/distributed-arp-table.h
index 8b7aa87..3a4f710 100644
--- a/net/batman-adv/distributed-arp-table.h
+++ b/net/batman-adv/distributed-arp-table.h
@@ -47,6 +47,7 @@ bool dat_snoop_incoming_arp_reply(struct bat_priv *bat_priv,
 				  struct sk_buff *skb, int hdr_size);
 bool dat_drop_broadcast_packet(struct bat_priv *bat_priv,
 			       struct forw_packet *forw_packet);
+void arp_change_timeout(struct net_device *soft_iface, const char *name);
 
 /* hash function to choose an entry in a hash table of given size.
  * hash algorithm from http://en.wikipedia.org/wiki/Hash_table
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 57023c3..c11c8df 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -71,6 +71,10 @@
 #define ARP_REQ_DELAY 250
 /* numbers of originator to contact for any PUT/GET DHT operation */
 #define DHT_CANDIDATES_NUM 3
+/* Factor which default ARP timeout values of the soft_iface table are
+ * multiplied by
+ */
+#define ARP_TIMEOUT_FACTOR 4
 
 #define LOG_BUF_LEN 8192	  /* has to be a power of 2 */
 
diff --git a/net/batman-adv/soft-interface.c b/net/batman-adv/soft-interface.c
index 3a1483a..b56dafd 100644
--- a/net/batman-adv/soft-interface.c
+++ b/net/batman-adv/soft-interface.c
@@ -381,6 +381,8 @@ struct net_device *softif_create(const char *name)
 		goto free_soft_iface;
 	}
 
+	arp_change_timeout(soft_iface, name);
+
 	bat_priv = netdev_priv(soft_iface);
 
 	atomic_set(&bat_priv->aggregated_ogms, 1);
-- 
1.7.9.4
