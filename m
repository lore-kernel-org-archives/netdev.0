From: Cong Wang <amwang@redhat.com>
Subject: [PATCH net-next v2] bridge: implement multicast fast leave
Date: Tue,  4 Dec 2012 17:56:40 +0800
Message-ID: <1354615000-19660-1-git-send-email-amwang@redhat.com>
Cc: Herbert Xu <herbert@gondor.hengli.com.au>,
	Stephen Hemminger <shemminger@vyatta.com>,
	bridge@lists.linux-foundation.org, "David S. Miller" <davem@davemloft.net>,
	Cong Wang <amwang@redhat.com>
To: netdev@vger.kernel.org
Return-path: <bridge-bounces@lists.linux-foundation.org>
List-Unsubscribe: <https://lists.linuxfoundation.org/mailman/options/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=unsubscribe>
List-Archive: <http://lists.linuxfoundation.org/pipermail/bridge/>
List-Post: <mailto:bridge@lists.linux-foundation.org>
List-Help: <mailto:bridge-request@lists.linux-foundation.org?subject=help>
List-Subscribe: <https://lists.linuxfoundation.org/mailman/listinfo/bridge>,
	<mailto:bridge-request@lists.linux-foundation.org?subject=subscribe>
Sender: bridge-bounces@lists.linux-foundation.org
Errors-To: bridge-bounces@lists.linux-foundation.org
List-Id: netdev.vger.kernel.org

V2: make the toggle per-port

Fast leave allows bridge to immediately stops the multicast
traffic on the port receives IGMP Leave when IGMP snooping is enabled,
no timeouts are observed.

Cc: Herbert Xu <herbert@gondor.apana.org.au>
Cc: Stephen Hemminger <shemminger@vyatta.com>
Cc: "David S. Miller" <davem@davemloft.net>
Signed-off-by: Cong Wang <amwang@redhat.com>

---
 net/bridge/br_multicast.c |   21 +++++++++++++++++++++
 net/bridge/br_private.h   |    1 +
 net/bridge/br_sysfs_if.c  |   20 ++++++++++++++++++++
 3 files changed, 42 insertions(+), 0 deletions(-)

diff --git a/net/bridge/br_multicast.c b/net/bridge/br_multicast.c
index d53e4f4..02da618 100644
--- a/net/bridge/br_multicast.c
+++ b/net/bridge/br_multicast.c
@@ -1226,6 +1226,27 @@ static void br_multicast_leave_group(struct net_bridge *br,
 	if (!mp)
 		goto out;
 
+	if (port && port->multicast_fast_leave) {
+		struct net_bridge_port_group __rcu **pp;
+
+		for (pp = &mp->ports;
+		     (p = mlock_dereference(*pp, br)) != NULL;
+		     pp = &p->next) {
+			if (p->port != port)
+				continue;
+
+			rcu_assign_pointer(*pp, p->next);
+			hlist_del_init(&p->mglist);
+			del_timer(&p->timer);
+			call_rcu_bh(&p->rcu, br_multicast_free_pg);
+
+			if (!mp->ports && !mp->mglist &&
+			    netif_running(br->dev))
+				mod_timer(&mp->timer, jiffies);
+		}
+		goto out;
+	}
+
 	now = jiffies;
 	time = now + br->multicast_last_member_count *
 		     br->multicast_last_member_interval;
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 6484069..8f0e789 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -142,6 +142,7 @@ struct net_bridge_port
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	u32				multicast_startup_queries_sent;
 	unsigned char			multicast_router;
+	unsigned char			multicast_fast_leave;
 	struct timer_list		multicast_router_timer;
 	struct timer_list		multicast_query_timer;
 	struct hlist_head		mglist;
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 7ff95ba..dc484ac 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -172,6 +172,25 @@ static int store_multicast_router(struct net_bridge_port *p,
 }
 static BRPORT_ATTR(multicast_router, S_IRUGO | S_IWUSR, show_multicast_router,
 		   store_multicast_router);
+
+static ssize_t show_multicast_fast_leave(struct net_bridge_port *p,
+					 char *buf)
+{
+	return sprintf(buf, "%d\n", p->multicast_fast_leave);
+}
+
+static int store_multicast_fast_leave(struct net_bridge_port *p,
+				      unsigned long v)
+{
+	if (p->br->multicast_disabled)
+		return -EINVAL;
+
+	p->multicast_fast_leave = !!v;
+	return 0;
+}
+
+static BRPORT_ATTR(multicast_fast_leave, S_IRUGO | S_IWUSR,
+		   show_multicast_fast_leave, store_multicast_fast_leave);
 #endif
 
 static const struct brport_attribute *brport_attrs[] = {
@@ -195,6 +214,7 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_root_block,
 #ifdef CONFIG_BRIDGE_IGMP_SNOOPING
 	&brport_attr_multicast_router,
+	&brport_attr_multicast_fast_leave,
 #endif
 	NULL
 };
