From: Antonio Quartulli <a@unstable.cc>
Subject: [PATCH 09/15] batman-adv: ELP - compute the metric based on the estimated throughput
Date: Mon, 29 Feb 2016 19:06:02 +0800
Message-ID: <1456743968-17562-10-git-send-email-a@unstable.cc>
References: <1456743968-17562-1-git-send-email-a@unstable.cc>
Cc: netdev@vger.kernel.org, b.a.t.m.a.n@lists.open-mesh.org,
	Antonio Quartulli <antonio@open-mesh.com>,
	Marek Lindner <mareklindner@neomailbox.ch>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([5.148.176.60]:11113 "EHLO s2.neomailbox.net"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1754097AbcB2LI4 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Feb 2016 06:08:56 -0500
In-Reply-To: <1456743968-17562-1-git-send-email-a@unstable.cc>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

In case of wireless interface retrieve the throughput by
querying cfg80211. To perform this call a separate work
must be scheduled because the function may sleep and this
is not allowed within an RCU protected context (RCU in this
case is used to iterate over all the neighbours).

Use ethtool to retrieve information about an Ethernet link
like HALF/FULL_DUPLEX and advertised bandwidth (e.g.
100/10Mbps).

The metric is updated each time a new ELP packet is sent,
this way it is possible to timely react to a metric
variation which can imply (for example) a neighbour
disconnection.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
Signed-off-by: Marek Lindner <mareklindner@neomailbox.ch>
---
 net/batman-adv/Kconfig     |   2 +-
 net/batman-adv/bat_v.c     |   3 +
 net/batman-adv/bat_v_elp.c | 140 +++++++++++++++++++++++++++++++++++++++++++++
 net/batman-adv/bat_v_elp.h |   2 +
 net/batman-adv/bat_v_ogm.c |   2 +-
 net/batman-adv/main.h      |   1 +
 net/batman-adv/types.h     |  16 ++++++
 7 files changed, 164 insertions(+), 2 deletions(-)

diff --git a/net/batman-adv/Kconfig b/net/batman-adv/Kconfig
index 5c148a8489da..e651dc927bfd 100644
--- a/net/batman-adv/Kconfig
+++ b/net/batman-adv/Kconfig
@@ -17,7 +17,7 @@ config BATMAN_ADV
 
 config BATMAN_ADV_BATMAN_V
 	bool "B.A.T.M.A.N. V protocol (experimental)"
-	depends on BATMAN_ADV
+	depends on BATMAN_ADV && CFG80211
 	default n
 	help
 	  This option enables the B.A.T.M.A.N. V protocol, the successor
diff --git a/net/batman-adv/bat_v.c b/net/batman-adv/bat_v.c
index d9cb5c4922c1..ff31f2af9cfe 100644
--- a/net/batman-adv/bat_v.c
+++ b/net/batman-adv/bat_v.c
@@ -21,6 +21,7 @@
 #include <linux/atomic.h>
 #include <linux/cache.h>
 #include <linux/init.h>
+#include <linux/workqueue.h>
 
 #include "bat_v_elp.h"
 #include "bat_v_ogm.h"
@@ -65,6 +66,8 @@ static void
 batadv_v_hardif_neigh_init(struct batadv_hardif_neigh_node *hardif_neigh)
 {
 	ewma_throughput_init(&hardif_neigh->bat_v.throughput);
+	INIT_WORK(&hardif_neigh->bat_v.metric_work,
+		  batadv_v_elp_throughput_metric_update);
 }
 
 static void batadv_v_ogm_schedule(struct batadv_hard_iface *hard_iface)
diff --git a/net/batman-adv/bat_v_elp.c b/net/batman-adv/bat_v_elp.c
index 1e4d13cc267f..8376730ebd69 100644
--- a/net/batman-adv/bat_v_elp.c
+++ b/net/batman-adv/bat_v_elp.c
@@ -22,19 +22,23 @@
 #include <linux/byteorder/generic.h>
 #include <linux/errno.h>
 #include <linux/etherdevice.h>
+#include <linux/ethtool.h>
 #include <linux/fs.h>
 #include <linux/if_ether.h>
 #include <linux/jiffies.h>
 #include <linux/kernel.h>
+#include <linux/kref.h>
 #include <linux/netdevice.h>
 #include <linux/random.h>
 #include <linux/rculist.h>
 #include <linux/rcupdate.h>
+#include <linux/rtnetlink.h>
 #include <linux/skbuff.h>
 #include <linux/stddef.h>
 #include <linux/string.h>
 #include <linux/types.h>
 #include <linux/workqueue.h>
+#include <net/cfg80211.h>
 
 #include "bat_algo.h"
 #include "bat_v_ogm.h"
@@ -60,6 +64,107 @@ static void batadv_v_elp_start_timer(struct batadv_hard_iface *hard_iface)
 }
 
 /**
+ * batadv_v_elp_get_throughput - get the throughput towards a neighbour
+ * @neigh: the neighbour for which the throughput has to be obtained
+ *
+ * Return: The throughput towards the given neighbour in multiples of 100kpbs
+ *         (a value of '1' equals to 0.1Mbps, '10' equals 1Mbps, etc).
+ */
+static u32 batadv_v_elp_get_throughput(struct batadv_hardif_neigh_node *neigh)
+{
+	struct batadv_hard_iface *hard_iface = neigh->if_incoming;
+	struct ethtool_link_ksettings link_settings;
+	struct station_info sinfo;
+	u32 throughput;
+	int ret;
+
+	/* if the user specified a customised value for this interface, then
+	 * return it directly
+	 */
+	throughput =  atomic_read(&hard_iface->bat_v.throughput_override);
+	if (throughput != 0)
+		return throughput;
+
+	/* if this is a wireless device, then ask its throughput through
+	 * cfg80211 API
+	 */
+	if (batadv_is_wifi_netdev(hard_iface->net_dev)) {
+		if (hard_iface->net_dev->ieee80211_ptr) {
+			ret = cfg80211_get_station(hard_iface->net_dev,
+						   neigh->addr, &sinfo);
+			if (ret == -ENOENT) {
+				/* Node is not associated anymore! It would be
+				 * possible to delete this neighbor. For now set
+				 * the throughput metric to 0.
+				 */
+				return 0;
+			}
+			if (!ret)
+				return sinfo.expected_throughput / 100;
+		}
+
+		/* unsupported WiFi driver version */
+		goto default_throughput;
+	}
+
+	/* if not a wifi interface, check if this device provides data via
+	 * ethtool (e.g. an Ethernet adapter)
+	 */
+	memset(&link_settings, 0, sizeof(link_settings));
+	rtnl_lock();
+	ret = __ethtool_get_link_ksettings(hard_iface->net_dev, &link_settings);
+	rtnl_unlock();
+	if (ret == 0) {
+		/* link characteristics might change over time */
+		if (link_settings.base.duplex == DUPLEX_FULL)
+			hard_iface->bat_v.flags |= BATADV_FULL_DUPLEX;
+		else
+			hard_iface->bat_v.flags &= ~BATADV_FULL_DUPLEX;
+
+		throughput = link_settings.base.speed;
+		if (throughput && (throughput != SPEED_UNKNOWN))
+			return throughput * 10;
+	}
+
+default_throughput:
+	if (!(hard_iface->bat_v.flags & BATADV_WARNING_DEFAULT)) {
+		batadv_info(hard_iface->soft_iface,
+			    "WiFi driver or ethtool info does not provide information about link speeds on interface %s, therefore defaulting to hardcoded throughput values of %u.%1u Mbps. Consider overriding the throughput manually or checking your driver.\n",
+			    hard_iface->net_dev->name,
+			    BATADV_THROUGHPUT_DEFAULT_VALUE / 10,
+			    BATADV_THROUGHPUT_DEFAULT_VALUE % 10);
+		hard_iface->bat_v.flags |= BATADV_WARNING_DEFAULT;
+	}
+
+	/* if none of the above cases apply, return the base_throughput */
+	return BATADV_THROUGHPUT_DEFAULT_VALUE;
+}
+
+/**
+ * batadv_v_elp_throughput_metric_update - worker updating the throughput metric
+ *  of a single hop neighbour
+ * @work: the work queue item
+ */
+void batadv_v_elp_throughput_metric_update(struct work_struct *work)
+{
+	struct batadv_hardif_neigh_node_bat_v *neigh_bat_v;
+	struct batadv_hardif_neigh_node *neigh;
+
+	neigh_bat_v = container_of(work, struct batadv_hardif_neigh_node_bat_v,
+				   metric_work);
+	neigh = container_of(neigh_bat_v, struct batadv_hardif_neigh_node,
+			     bat_v);
+
+	ewma_throughput_add(&neigh->bat_v.throughput,
+			    batadv_v_elp_get_throughput(neigh));
+
+	/* decrement refcounter to balance increment performed before scheduling
+	 * this task
+	 */
+	batadv_hardif_neigh_put(neigh);
+}
+
+/**
  * batadv_v_elp_periodic_work - ELP periodic task per interface
  * @work: work queue item
  *
@@ -67,6 +172,7 @@ static void batadv_v_elp_start_timer(struct batadv_hard_iface *hard_iface)
  */
 static void batadv_v_elp_periodic_work(struct work_struct *work)
 {
+	struct batadv_hardif_neigh_node *hardif_neigh;
 	struct batadv_hard_iface *hard_iface;
 	struct batadv_hard_iface_bat_v *bat_v;
 	struct batadv_elp_packet *elp_packet;
@@ -108,6 +214,31 @@ static void batadv_v_elp_periodic_work(struct work_struct *work)
 
 	atomic_inc(&hard_iface->bat_v.elp_seqno);
 
+	/* The throughput metric is updated on each sent packet. This way, if a
+	 * node is dead and no longer sends packets, batman-adv is still able to
+	 * react timely to its death.
+	 *
+	 * The throughput metric is updated by following these steps:
+	 * 1) if the hard_iface is wifi => send a number of unicast ELPs for
+	 *    probing/sampling to each neighbor
+	 * 2) update the throughput metric value of each neighbor (note that the
+	 *    value retrieved in this step might be 100ms old because the
+	 *    probing packets at point 1) could still be in the HW queue)
+	 */
+	rcu_read_lock();
+	hlist_for_each_entry_rcu(hardif_neigh, &hard_iface->neigh_list, list) {
+		if (!kref_get_unless_zero(&hardif_neigh->refcount))
+			continue;
+
+		/* Reading the estimated throughput from cfg80211 is a task that
+		 * may sleep and that is not allowed in an rcu protected
+		 * context. Therefore schedule a task for that.
+		 */
+		queue_work(batadv_event_workqueue,
+			   &hardif_neigh->bat_v.metric_work);
+	}
+	rcu_read_unlock();
+
 restart_timer:
 	batadv_v_elp_start_timer(hard_iface);
 out:
@@ -146,6 +277,15 @@ int batadv_v_elp_iface_enable(struct batadv_hard_iface *hard_iface)
 	atomic_set(&hard_iface->bat_v.elp_seqno, random_seqno);
 	atomic_set(&hard_iface->bat_v.elp_interval, 500);
 
+	/* assume full-duplex by default */
+	hard_iface->bat_v.flags |= BATADV_FULL_DUPLEX;
+
+	/* warn the user (again) if there is no throughput data is available */
+	hard_iface->bat_v.flags &= ~BATADV_WARNING_DEFAULT;
+
+	if (batadv_is_wifi_netdev(hard_iface->net_dev))
+		hard_iface->bat_v.flags &= ~BATADV_FULL_DUPLEX;
+
 	INIT_DELAYED_WORK(&hard_iface->bat_v.elp_wq,
 			  batadv_v_elp_periodic_work);
 	batadv_v_elp_start_timer(hard_iface);
diff --git a/net/batman-adv/bat_v_elp.h b/net/batman-adv/bat_v_elp.h
index 5a7bc398a9ef..e95f1bca0785 100644
--- a/net/batman-adv/bat_v_elp.h
+++ b/net/batman-adv/bat_v_elp.h
@@ -21,11 +21,13 @@
 #define _NET_BATMAN_ADV_BAT_V_ELP_H_
 
 struct sk_buff;
+struct work_struct;
 
 int batadv_v_elp_iface_enable(struct batadv_hard_iface *hard_iface);
 void batadv_v_elp_iface_disable(struct batadv_hard_iface *hard_iface);
 void batadv_v_elp_primary_iface_set(struct batadv_hard_iface *primary_iface);
 int batadv_v_elp_packet_recv(struct sk_buff *skb,
 			     struct batadv_hard_iface *if_incoming);
+void batadv_v_elp_throughput_metric_update(struct work_struct *work);
 
 #endif /* _NET_BATMAN_ADV_BAT_V_ELP_H_ */
diff --git a/net/batman-adv/bat_v_ogm.c b/net/batman-adv/bat_v_ogm.c
index c8000962a266..d9bcbe6e7d65 100644
--- a/net/batman-adv/bat_v_ogm.c
+++ b/net/batman-adv/bat_v_ogm.c
@@ -339,7 +339,7 @@ static u32 batadv_v_forward_penalty(struct batadv_priv *bat_priv,
 	 */
 	if ((throughput > 10) &&
 	    (if_incoming == if_outgoing) &&
-	    (batadv_is_wifi_netdev(if_incoming->net_dev)))
+	    !(if_incoming->bat_v.flags & BATADV_FULL_DUPLEX))
 		return throughput / 2;
 
 	/* hop penalty of 255 equals 100% */
diff --git a/net/batman-adv/main.h b/net/batman-adv/main.h
index 2e795446208f..5c68bf2618c7 100644
--- a/net/batman-adv/main.h
+++ b/net/batman-adv/main.h
@@ -62,6 +62,7 @@
 #define BATADV_TQ_TOTAL_BIDRECT_LIMIT 1
 
 /* B.A.T.M.A.N. V */
+#define BATADV_THROUGHPUT_DEFAULT_VALUE 10 /* 1 Mbps */
 #define BATADV_ELP_MAX_AGE 64
 #define BATADV_OGM_MAX_ORIGDIFF 5
 #define BATADV_OGM_MAX_AGE 64
diff --git a/net/batman-adv/types.h b/net/batman-adv/types.h
index c56bb8835e60..9abfb3e73c34 100644
--- a/net/batman-adv/types.h
+++ b/net/batman-adv/types.h
@@ -87,12 +87,25 @@ struct batadv_hard_iface_bat_iv {
 };
 
 /**
+ * enum batadv_v_hard_iface_flags - interface flags useful to B.A.T.M.A.N. V
+ * @BATADV_FULL_DUPLEX: tells if the connection over this link is full-duplex
+ * @BATADV_WARNING_DEFAULT: tells whether we have warned the user that no
+ *  throughput data is available for this interface and that default values are
+ *  assumed.
+ */
+enum batadv_v_hard_iface_flags {
+	BATADV_FULL_DUPLEX	= BIT(0),
+	BATADV_WARNING_DEFAULT	= BIT(1),
+};
+
+/**
  * struct batadv_hard_iface_bat_v - per hard-interface B.A.T.M.A.N. V data
  * @elp_interval: time interval between two ELP transmissions
  * @elp_seqno: current ELP sequence number
  * @elp_skb: base skb containing the ELP message to send
  * @elp_wq: workqueue used to schedule ELP transmissions
  * @throughput_override: throughput override to disable link auto-detection
+ * @flags: interface specific flags
  */
 struct batadv_hard_iface_bat_v {
 	atomic_t elp_interval;
@@ -100,6 +113,7 @@ struct batadv_hard_iface_bat_v {
 	struct sk_buff *elp_skb;
 	struct delayed_work elp_wq;
 	atomic_t throughput_override;
+	u8 flags;
 };
 
 /**
@@ -378,12 +392,14 @@ DECLARE_EWMA(throughput, 1024, 8)
  * @elp_interval: time interval between two ELP transmissions
  * @elp_latest_seqno: latest and best known ELP sequence number
  * @last_unicast_tx: when the last unicast packet has been sent to this neighbor
+ * @metric_work: work queue callback item for metric update
  */
 struct batadv_hardif_neigh_node_bat_v {
 	struct ewma_throughput throughput;
 	u32 elp_interval;
 	u32 elp_latest_seqno;
 	unsigned long last_unicast_tx;
+	struct work_struct metric_work;
 };
 
 /**
-- 
2.7.2
