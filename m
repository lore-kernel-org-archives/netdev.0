From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 09/16] tipc: make bearer list
	support net namespace
Date: Fri, 9 Jan 2015 15:27:06 +0800
Message-ID: <1420788433-17960-10-git-send-email-ying.xue@windriver.com>
References: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Tero.Aho@coriant.com, netdev@vger.kernel.org,
	Paul.Gortmaker@windriver.com, tipc-discussion@lists.sourceforge.net
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1420788433-17960-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Bearer list defined as a global variable is used to store bearer
instances. When tipc supports net namespace, bearers created in
one namespace must be isolated with others allocated in other
namespaces, which requires us that the bearer list(bearer_list)
must be moved to tipc_net structure. As a result, a net namespace
pointer has to be passed to functions which access the bearer list.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c    |   27 +++++++++++++--------
 net/tipc/bcast.h    |    7 +++---
 net/tipc/bearer.c   |   67 ++++++++++++++++++++++++++++++---------------------
 net/tipc/bearer.h   |   16 ++++++------
 net/tipc/config.c   |    2 +-
 net/tipc/core.h     |    4 +++
 net/tipc/discover.c |   12 ++++++---
 net/tipc/link.c     |   41 +++++++++++++++++++------------
 net/tipc/link.h     |    3 ++-
 net/tipc/net.c      |    4 +--
 10 files changed, 110 insertions(+), 73 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index 816c0e4..e7c5383 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -369,7 +369,7 @@ void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
 		msg_set_bcgap_to(msg, to);
 
 		tipc_bclink_lock();
-		tipc_bearer_send(MAX_BEARERS, buf, NULL);
+		tipc_bearer_send(net, MAX_BEARERS, buf, NULL);
 		bcl->stats.sent_nacks++;
 		tipc_bclink_unlock();
 		kfree_skb(buf);
@@ -425,7 +425,7 @@ int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list)
 	if (likely(bclink)) {
 		tipc_bclink_lock();
 		if (likely(bclink->bcast_nodes.count)) {
-			rc = __tipc_link_xmit(bcl, list);
+			rc = __tipc_link_xmit(net, bcl, list);
 			if (likely(!rc)) {
 				u32 len = skb_queue_len(&bcl->outqueue);
 
@@ -682,13 +682,14 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 
 		if (bp_index == 0) {
 			/* Use original buffer for first bearer */
-			tipc_bearer_send(b->identity, buf, &b->bcast_addr);
+			tipc_bearer_send(net, b->identity, buf, &b->bcast_addr);
 		} else {
 			/* Avoid concurrent buffer access */
 			tbuf = pskb_copy_for_clone(buf, GFP_ATOMIC);
 			if (!tbuf)
 				break;
-			tipc_bearer_send(b->identity, tbuf, &b->bcast_addr);
+			tipc_bearer_send(net, b->identity, tbuf,
+					 &b->bcast_addr);
 			kfree_skb(tbuf); /* Bearer keeps a clone */
 		}
 		if (bcbearer->remains_new.count == 0)
@@ -703,8 +704,10 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 /**
  * tipc_bcbearer_sort - create sets of bearer pairs used by broadcast bearer
  */
-void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
+void tipc_bcbearer_sort(struct net *net, struct tipc_node_map *nm_ptr,
+			u32 node, bool action)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bcbearer_pair *bp_temp = bcbearer->bpairs_temp;
 	struct tipc_bcbearer_pair *bp_curr;
 	struct tipc_bearer *b;
@@ -723,7 +726,7 @@ void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action)
 
 	rcu_read_lock();
 	for (b_index = 0; b_index < MAX_BEARERS; b_index++) {
-		b = rcu_dereference_rtnl(bearer_list[b_index]);
+		b = rcu_dereference_rtnl(tn->bearer_list[b_index]);
 		if (!b || !b->nodes.count)
 			continue;
 
@@ -939,8 +942,10 @@ int tipc_bclink_set_queue_limits(u32 limit)
 	return 0;
 }
 
-int tipc_bclink_init(void)
+int tipc_bclink_init(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
 	bcbearer = kzalloc(sizeof(*bcbearer), GFP_ATOMIC);
 	if (!bcbearer)
 		return -ENOMEM;
@@ -967,19 +972,21 @@ int tipc_bclink_init(void)
 	bcl->max_pkt = MAX_PKT_DEFAULT_MCAST;
 	tipc_link_set_queue_limits(bcl, BCLINK_WIN_DEFAULT);
 	bcl->bearer_id = MAX_BEARERS;
-	rcu_assign_pointer(bearer_list[MAX_BEARERS], &bcbearer->bearer);
+	rcu_assign_pointer(tn->bearer_list[MAX_BEARERS], &bcbearer->bearer);
 	bcl->state = WORKING_WORKING;
 	strlcpy(bcl->name, tipc_bclink_name, TIPC_MAX_LINK_NAME);
 	return 0;
 }
 
-void tipc_bclink_stop(void)
+void tipc_bclink_stop(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
 	tipc_bclink_lock();
 	tipc_link_purge_queues(bcl);
 	tipc_bclink_unlock();
 
-	RCU_INIT_POINTER(bearer_list[BCBEARER], NULL);
+	RCU_INIT_POINTER(tn->bearer_list[BCBEARER], NULL);
 	synchronize_net();
 	kfree(bcbearer);
 	kfree(bclink);
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index fd0d17a..692efb6 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -84,8 +84,8 @@ static inline int tipc_nmap_equal(struct tipc_node_map *nm_a,
 void tipc_port_list_add(struct tipc_port_list *pl_ptr, u32 port);
 void tipc_port_list_free(struct tipc_port_list *pl_ptr);
 
-int tipc_bclink_init(void);
-void tipc_bclink_stop(void);
+int tipc_bclink_init(struct net *net);
+void tipc_bclink_stop(struct net *net);
 void tipc_bclink_set_flags(unsigned int flags);
 void tipc_bclink_add_node(u32 addr);
 void tipc_bclink_remove_node(u32 addr);
@@ -99,7 +99,8 @@ void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
 int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
-void tipc_bcbearer_sort(struct tipc_node_map *nm_ptr, u32 node, bool action);
+void tipc_bcbearer_sort(struct net *net, struct tipc_node_map *nm_ptr,
+			u32 node, bool action);
 uint  tipc_bclink_get_mtu(void);
 int tipc_bclink_xmit(struct net *net, struct sk_buff_head *list);
 void tipc_bclink_wakeup_users(struct net *net);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index a735c08..2fe9dcb 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -34,6 +34,7 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <net/sock.h>
 #include "core.h"
 #include "config.h"
 #include "bearer.h"
@@ -67,8 +68,6 @@ static const struct nla_policy tipc_nl_media_policy[TIPC_NLA_MEDIA_MAX + 1] = {
 	[TIPC_NLA_MEDIA_PROP]		= { .type = NLA_NESTED }
 };
 
-struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
-
 static void bearer_disable(struct net *net, struct tipc_bearer *b_ptr,
 			   bool shutting_down);
 
@@ -191,13 +190,14 @@ static int bearer_name_validate(const char *name,
 /**
  * tipc_bearer_find - locates bearer object with matching bearer name
  */
-struct tipc_bearer *tipc_bearer_find(const char *name)
+struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 	u32 i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		b_ptr = rtnl_dereference(bearer_list[i]);
+		b_ptr = rtnl_dereference(tn->bearer_list[i]);
 		if (b_ptr && (!strcmp(b_ptr->name, name)))
 			return b_ptr;
 	}
@@ -207,8 +207,9 @@ struct tipc_bearer *tipc_bearer_find(const char *name)
 /**
  * tipc_bearer_get_names - record names of bearers in buffer
  */
-struct sk_buff *tipc_bearer_get_names(void)
+struct sk_buff *tipc_bearer_get_names(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct sk_buff *buf;
 	struct tipc_bearer *b;
 	int i, j;
@@ -219,7 +220,7 @@ struct sk_buff *tipc_bearer_get_names(void)
 
 	for (i = 0; media_info_array[i] != NULL; i++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
-			b = rtnl_dereference(bearer_list[j]);
+			b = rtnl_dereference(tn->bearer_list[j]);
 			if (!b)
 				continue;
 			if (b->media == media_info_array[i]) {
@@ -232,27 +233,29 @@ struct sk_buff *tipc_bearer_get_names(void)
 	return buf;
 }
 
-void tipc_bearer_add_dest(u32 bearer_id, u32 dest)
+void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 
 	rcu_read_lock();
-	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
+	b_ptr = rcu_dereference_rtnl(tn->bearer_list[bearer_id]);
 	if (b_ptr) {
-		tipc_bcbearer_sort(&b_ptr->nodes, dest, true);
+		tipc_bcbearer_sort(net, &b_ptr->nodes, dest, true);
 		tipc_disc_add_dest(b_ptr->link_req);
 	}
 	rcu_read_unlock();
 }
 
-void tipc_bearer_remove_dest(u32 bearer_id, u32 dest)
+void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 
 	rcu_read_lock();
-	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
+	b_ptr = rcu_dereference_rtnl(tn->bearer_list[bearer_id]);
 	if (b_ptr) {
-		tipc_bcbearer_sort(&b_ptr->nodes, dest, false);
+		tipc_bcbearer_sort(net, &b_ptr->nodes, dest, false);
 		tipc_disc_remove_dest(b_ptr->link_req);
 	}
 	rcu_read_unlock();
@@ -264,6 +267,7 @@ void tipc_bearer_remove_dest(u32 bearer_id, u32 dest)
 int tipc_enable_bearer(struct net *net, const char *name, u32 disc_domain,
 		       u32 priority)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 	struct tipc_media *m_ptr;
 	struct tipc_bearer_names b_names;
@@ -315,7 +319,7 @@ restart:
 	bearer_id = MAX_BEARERS;
 	with_this_prio = 1;
 	for (i = MAX_BEARERS; i-- != 0; ) {
-		b_ptr = rtnl_dereference(bearer_list[i]);
+		b_ptr = rtnl_dereference(tn->bearer_list[i]);
 		if (!b_ptr) {
 			bearer_id = i;
 			continue;
@@ -349,7 +353,7 @@ restart:
 
 	strcpy(b_ptr->name, name);
 	b_ptr->media = m_ptr;
-	res = m_ptr->enable_media(b_ptr);
+	res = m_ptr->enable_media(net, b_ptr);
 	if (res) {
 		pr_warn("Bearer <%s> rejected, enable failure (%d)\n",
 			name, -res);
@@ -371,7 +375,7 @@ restart:
 		return -EINVAL;
 	}
 
-	rcu_assign_pointer(bearer_list[bearer_id], b_ptr);
+	rcu_assign_pointer(tn->bearer_list[bearer_id], b_ptr);
 
 	pr_info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
 		name,
@@ -398,6 +402,7 @@ static int tipc_reset_bearer(struct net *net, struct tipc_bearer *b_ptr)
 static void bearer_disable(struct net *net, struct tipc_bearer *b_ptr,
 			   bool shutting_down)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 i;
 
 	pr_info("Disabling bearer <%s>\n", b_ptr->name);
@@ -408,8 +413,8 @@ static void bearer_disable(struct net *net, struct tipc_bearer *b_ptr,
 		tipc_disc_delete(b_ptr->link_req);
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		if (b_ptr == rtnl_dereference(bearer_list[i])) {
-			RCU_INIT_POINTER(bearer_list[i], NULL);
+		if (b_ptr == rtnl_dereference(tn->bearer_list[i])) {
+			RCU_INIT_POINTER(tn->bearer_list[i], NULL);
 			break;
 		}
 	}
@@ -421,7 +426,7 @@ int tipc_disable_bearer(struct net *net, const char *name)
 	struct tipc_bearer *b_ptr;
 	int res;
 
-	b_ptr = tipc_bearer_find(name);
+	b_ptr = tipc_bearer_find(net, name);
 	if (b_ptr == NULL) {
 		pr_warn("Attempt to disable unknown bearer <%s>\n", name);
 		res = -EINVAL;
@@ -432,13 +437,13 @@ int tipc_disable_bearer(struct net *net, const char *name)
 	return res;
 }
 
-int tipc_enable_l2_media(struct tipc_bearer *b)
+int tipc_enable_l2_media(struct net *net, struct tipc_bearer *b)
 {
 	struct net_device *dev;
 	char *driver_name = strchr((const char *)b->name, ':') + 1;
 
 	/* Find device with specified name */
-	dev = dev_get_by_name(&init_net, driver_name);
+	dev = dev_get_by_name(net, driver_name);
 	if (!dev)
 		return -ENODEV;
 
@@ -514,13 +519,14 @@ int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
  * The media send routine must not alter the buffer being passed in
  * as it may be needed for later retransmission!
  */
-void tipc_bearer_send(u32 bearer_id, struct sk_buff *buf,
+void tipc_bearer_send(struct net *net, u32 bearer_id, struct sk_buff *buf,
 		      struct tipc_media_addr *dest)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 
 	rcu_read_lock();
-	b_ptr = rcu_dereference_rtnl(bearer_list[bearer_id]);
+	b_ptr = rcu_dereference_rtnl(tn->bearer_list[bearer_id]);
 	if (likely(b_ptr))
 		b_ptr->media->send_msg(buf, b_ptr, dest);
 	rcu_read_unlock();
@@ -630,14 +636,15 @@ void tipc_bearer_cleanup(void)
 
 void tipc_bearer_stop(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 	u32 i;
 
 	for (i = 0; i < MAX_BEARERS; i++) {
-		b_ptr = rtnl_dereference(bearer_list[i]);
+		b_ptr = rtnl_dereference(tn->bearer_list[i]);
 		if (b_ptr) {
 			bearer_disable(net, b_ptr, true);
-			bearer_list[i] = NULL;
+			tn->bearer_list[i] = NULL;
 		}
 	}
 }
@@ -694,6 +701,8 @@ int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	int i = cb->args[0];
 	struct tipc_bearer *bearer;
 	struct tipc_nl_msg msg;
+	struct net *net = sock_net(skb->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	if (i == MAX_BEARERS)
 		return 0;
@@ -704,7 +713,7 @@ int tipc_nl_bearer_dump(struct sk_buff *skb, struct netlink_callback *cb)
 
 	rtnl_lock();
 	for (i = 0; i < MAX_BEARERS; i++) {
-		bearer = rtnl_dereference(bearer_list[i]);
+		bearer = rtnl_dereference(tn->bearer_list[i]);
 		if (!bearer)
 			continue;
 
@@ -726,6 +735,7 @@ int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
 	struct tipc_bearer *bearer;
 	struct tipc_nl_msg msg;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+	struct net *net = genl_info_net(info);
 
 	if (!info->attrs[TIPC_NLA_BEARER])
 		return -EINVAL;
@@ -749,7 +759,7 @@ int tipc_nl_bearer_get(struct sk_buff *skb, struct genl_info *info)
 	msg.seq = info->snd_seq;
 
 	rtnl_lock();
-	bearer = tipc_bearer_find(name);
+	bearer = tipc_bearer_find(net, name);
 	if (!bearer) {
 		err = -EINVAL;
 		goto err_out;
@@ -791,7 +801,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 	name = nla_data(attrs[TIPC_NLA_BEARER_NAME]);
 
 	rtnl_lock();
-	bearer = tipc_bearer_find(name);
+	bearer = tipc_bearer_find(net, name);
 	if (!bearer) {
 		rtnl_unlock();
 		return -EINVAL;
@@ -861,6 +871,7 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 	char *name;
 	struct tipc_bearer *b;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
+	struct net *net = genl_info_net(info);
 
 	if (!info->attrs[TIPC_NLA_BEARER])
 		return -EINVAL;
@@ -876,7 +887,7 @@ int tipc_nl_bearer_set(struct sk_buff *skb, struct genl_info *info)
 	name = nla_data(attrs[TIPC_NLA_BEARER_NAME]);
 
 	rtnl_lock();
-	b = tipc_bearer_find(name);
+	b = tipc_bearer_find(net, name);
 	if (!b) {
 		rtnl_unlock();
 		return -EINVAL;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 91a8eee..01722d6 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -92,7 +92,7 @@ struct tipc_media {
 	int (*send_msg)(struct sk_buff *buf,
 			struct tipc_bearer *b_ptr,
 			struct tipc_media_addr *dest);
-	int (*enable_media)(struct tipc_bearer *b_ptr);
+	int (*enable_media)(struct net *net, struct tipc_bearer *b_ptr);
 	void (*disable_media)(struct tipc_bearer *b_ptr);
 	int (*addr2str)(struct tipc_media_addr *addr,
 			char *strbuf,
@@ -159,8 +159,6 @@ struct tipc_bearer_names {
 
 struct tipc_link;
 
-extern struct tipc_bearer __rcu *bearer_list[];
-
 /*
  * TIPC routines available to supported media types
  */
@@ -193,20 +191,20 @@ int tipc_media_set_priority(const char *name, u32 new_value);
 int tipc_media_set_window(const char *name, u32 new_value);
 void tipc_media_addr_printf(char *buf, int len, struct tipc_media_addr *a);
 struct sk_buff *tipc_media_get_names(void);
-int tipc_enable_l2_media(struct tipc_bearer *b);
+int tipc_enable_l2_media(struct net *net, struct tipc_bearer *b);
 void tipc_disable_l2_media(struct tipc_bearer *b);
 int tipc_l2_send_msg(struct sk_buff *buf, struct tipc_bearer *b,
 		     struct tipc_media_addr *dest);
 
-struct sk_buff *tipc_bearer_get_names(void);
-void tipc_bearer_add_dest(u32 bearer_id, u32 dest);
-void tipc_bearer_remove_dest(u32 bearer_id, u32 dest);
-struct tipc_bearer *tipc_bearer_find(const char *name);
+struct sk_buff *tipc_bearer_get_names(struct net *net);
+void tipc_bearer_add_dest(struct net *net, u32 bearer_id, u32 dest);
+void tipc_bearer_remove_dest(struct net *net, u32 bearer_id, u32 dest);
+struct tipc_bearer *tipc_bearer_find(struct net *net, const char *name);
 struct tipc_media *tipc_media_find(const char *name);
 int tipc_bearer_setup(void);
 void tipc_bearer_cleanup(void);
 void tipc_bearer_stop(struct net *net);
-void tipc_bearer_send(u32 bearer_id, struct sk_buff *buf,
+void tipc_bearer_send(struct net *net, u32 bearer_id, struct sk_buff *buf,
 		      struct tipc_media_addr *dest);
 
 #endif	/* _TIPC_BEARER_H */
diff --git a/net/tipc/config.c b/net/tipc/config.c
index cf2d417..ac73291 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -251,7 +251,7 @@ struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 		rep_tlv_buf = tipc_nametbl_get(req_tlv_area, req_tlv_space);
 		break;
 	case TIPC_CMD_GET_BEARER_NAMES:
-		rep_tlv_buf = tipc_bearer_get_names();
+		rep_tlv_buf = tipc_bearer_get_names(net);
 		break;
 	case TIPC_CMD_GET_MEDIA_NAMES:
 		rep_tlv_buf = tipc_media_get_names();
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 4fb1133..75a332b 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -60,6 +60,7 @@
 #include <net/netns/generic.h>
 
 #include "node.h"
+#include "bearer.h"
 
 #define TIPC_MOD_VER "2.0.0"
 
@@ -87,6 +88,9 @@ struct tipc_net {
 	struct list_head node_list;
 	u32 num_nodes;
 	u32 num_links;
+
+	/* Bearer list */
+	struct tipc_bearer __rcu *bearer_list[MAX_BEARERS + 1];
 };
 
 #ifdef CONFIG_SYSCTL
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index f0fd8b4..f93dd3d 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -51,6 +51,7 @@
 /**
  * struct tipc_link_req - information about an ongoing link setup request
  * @bearer_id: identity of bearer issuing requests
+ * @net: network namespace instance
  * @dest: destination address for request messages
  * @domain: network domain to which links can be established
  * @num_nodes: number of nodes currently discovered (i.e. with an active link)
@@ -62,6 +63,7 @@
 struct tipc_link_req {
 	u32 bearer_id;
 	struct tipc_media_addr dest;
+	struct net *net;
 	u32 domain;
 	int num_nodes;
 	spinlock_t lock;
@@ -254,7 +256,7 @@ void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
 		rbuf = tipc_buf_acquire(INT_H_SIZE);
 		if (rbuf) {
 			tipc_disc_init_msg(net, rbuf, DSC_RESP_MSG, bearer);
-			tipc_bearer_send(bearer->identity, rbuf, &maddr);
+			tipc_bearer_send(net, bearer->identity, rbuf, &maddr);
 			kfree_skb(rbuf);
 		}
 	}
@@ -328,7 +330,7 @@ static void disc_timeout(unsigned long data)
 	 * hold at fast polling rate if don't have any associated nodes,
 	 * otherwise hold at slow polling rate
 	 */
-	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
+	tipc_bearer_send(req->net, req->bearer_id, req->buf, &req->dest);
 
 
 	req->timer_intv *= 2;
@@ -370,6 +372,7 @@ int tipc_disc_create(struct net *net, struct tipc_bearer *b_ptr,
 
 	tipc_disc_init_msg(net, req->buf, DSC_REQ_MSG, b_ptr);
 	memcpy(&req->dest, dest, sizeof(*dest));
+	req->net = net;
 	req->bearer_id = b_ptr->identity;
 	req->domain = b_ptr->domain;
 	req->num_nodes = 0;
@@ -378,7 +381,7 @@ int tipc_disc_create(struct net *net, struct tipc_bearer *b_ptr,
 	setup_timer(&req->timer, disc_timeout, (unsigned long)req);
 	mod_timer(&req->timer, jiffies + req->timer_intv);
 	b_ptr->link_req = req;
-	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
+	tipc_bearer_send(net, req->bearer_id, req->buf, &req->dest);
 	return 0;
 }
 
@@ -405,11 +408,12 @@ void tipc_disc_reset(struct net *net, struct tipc_bearer *b_ptr)
 
 	spin_lock_bh(&req->lock);
 	tipc_disc_init_msg(net, req->buf, DSC_REQ_MSG, b_ptr);
+	req->net = net;
 	req->bearer_id = b_ptr->identity;
 	req->domain = b_ptr->domain;
 	req->num_nodes = 0;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	mod_timer(&req->timer, jiffies + req->timer_intv);
-	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
+	tipc_bearer_send(net, req->bearer_id, req->buf, &req->dest);
 	spin_unlock_bh(&req->lock);
 }
diff --git a/net/tipc/link.c b/net/tipc/link.c
index f650565..be21e6a 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -129,11 +129,13 @@ static unsigned int align(unsigned int i)
 
 static void link_init_max_pkt(struct tipc_link *l_ptr)
 {
+	struct tipc_node *node = l_ptr->owner;
+	struct tipc_net *tn = net_generic(node->net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 	u32 max_pkt;
 
 	rcu_read_lock();
-	b_ptr = rcu_dereference_rtnl(bearer_list[l_ptr->bearer_id]);
+	b_ptr = rcu_dereference_rtnl(tn->bearer_list[l_ptr->bearer_id]);
 	if (!b_ptr) {
 		rcu_read_unlock();
 		return;
@@ -431,7 +433,7 @@ void tipc_link_reset(struct tipc_link *l_ptr)
 		return;
 
 	tipc_node_link_down(l_ptr->owner, l_ptr);
-	tipc_bearer_remove_dest(l_ptr->bearer_id, l_ptr->addr);
+	tipc_bearer_remove_dest(owner->net, l_ptr->bearer_id, l_ptr->addr);
 
 	if (was_active_link && tipc_node_active_links(l_ptr->owner)) {
 		l_ptr->reset_checkpoint = checkpoint;
@@ -471,11 +473,14 @@ void tipc_link_reset_list(struct net *net, unsigned int bearer_id)
 	rcu_read_unlock();
 }
 
-static void link_activate(struct tipc_link *l_ptr)
+static void link_activate(struct tipc_link *link)
 {
-	l_ptr->next_in_no = l_ptr->stats.recv_info = 1;
-	tipc_node_link_up(l_ptr->owner, l_ptr);
-	tipc_bearer_add_dest(l_ptr->bearer_id, l_ptr->addr);
+	struct tipc_node *node = link->owner;
+
+	link->next_in_no = 1;
+	link->stats.recv_info = 1;
+	tipc_node_link_up(node, link);
+	tipc_bearer_add_dest(node->net, link->bearer_id, link->addr);
 }
 
 /**
@@ -707,7 +712,8 @@ drop:
  * Only the socket functions tipc_send_stream() and tipc_send_packet() need
  * to act on the return value, since they may need to do more send attempts.
  */
-int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list)
+int __tipc_link_xmit(struct net *net, struct tipc_link *link,
+		     struct sk_buff_head *list)
 {
 	struct tipc_msg *msg = buf_msg(skb_peek(list));
 	uint psz = msg_size(msg);
@@ -740,7 +746,8 @@ int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list)
 
 		if (skb_queue_len(outqueue) < sndlim) {
 			__skb_queue_tail(outqueue, skb);
-			tipc_bearer_send(link->bearer_id, skb, addr);
+			tipc_bearer_send(net, link->bearer_id,
+					 skb, addr);
 			link->next_out = NULL;
 			link->unacked_window = 0;
 		} else if (tipc_msg_bundle(outqueue, skb, mtu)) {
@@ -774,7 +781,7 @@ static int __tipc_link_xmit_skb(struct tipc_link *link, struct sk_buff *skb)
 	struct sk_buff_head head;
 
 	skb2list(skb, &head);
-	return __tipc_link_xmit(link, &head);
+	return __tipc_link_xmit(link->owner->net, link, &head);
 }
 
 int tipc_link_xmit_skb(struct net *net, struct sk_buff *skb, u32 dnode,
@@ -808,7 +815,7 @@ int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dnode,
 		tipc_node_lock(node);
 		link = node->active_links[selector & 1];
 		if (link)
-			rc = __tipc_link_xmit(link, list);
+			rc = __tipc_link_xmit(net, link, list);
 		tipc_node_unlock(node);
 	}
 
@@ -900,7 +907,8 @@ void tipc_link_push_packets(struct tipc_link *l_ptr)
 			msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
 			if (msg_user(msg) == MSG_BUNDLER)
 				TIPC_SKB_CB(skb)->bundling = false;
-			tipc_bearer_send(l_ptr->bearer_id, skb,
+			tipc_bearer_send(l_ptr->owner->net,
+					 l_ptr->bearer_id, skb,
 					 &l_ptr->media_addr);
 			l_ptr->next_out = tipc_skb_queue_next(outqueue, skb);
 		} else {
@@ -997,7 +1005,8 @@ void tipc_link_retransmit(struct tipc_link *l_ptr, struct sk_buff *skb,
 		msg = buf_msg(skb);
 		msg_set_ack(msg, mod(l_ptr->next_in_no - 1));
 		msg_set_bcast_ack(msg, l_ptr->owner->bclink.last_in);
-		tipc_bearer_send(l_ptr->bearer_id, skb, &l_ptr->media_addr);
+		tipc_bearer_send(l_ptr->owner->net, l_ptr->bearer_id, skb,
+				 &l_ptr->media_addr);
 		retransmits--;
 		l_ptr->stats.retransmitted++;
 	}
@@ -1459,7 +1468,8 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
 	skb_copy_to_linear_data(buf, msg, sizeof(l_ptr->proto_msg));
 	buf->priority = TC_PRIO_CONTROL;
 
-	tipc_bearer_send(l_ptr->bearer_id, buf, &l_ptr->media_addr);
+	tipc_bearer_send(l_ptr->owner->net, l_ptr->bearer_id, buf,
+			 &l_ptr->media_addr);
 	l_ptr->unacked_window = 0;
 	kfree_skb(buf);
 }
@@ -2037,7 +2047,7 @@ static int link_cmd_set_value(struct net *net, const char *name, u32 new_value,
 		return res;
 	}
 
-	b_ptr = tipc_bearer_find(name);
+	b_ptr = tipc_bearer_find(net, name);
 	if (b_ptr) {
 		switch (cmd) {
 		case TIPC_CMD_SET_LINK_TOL:
@@ -2295,10 +2305,11 @@ struct sk_buff *tipc_link_cmd_show_stats(struct net *net,
 
 static void link_print(struct tipc_link *l_ptr, const char *str)
 {
+	struct tipc_net *tn = net_generic(l_ptr->owner->net, tipc_net_id);
 	struct tipc_bearer *b_ptr;
 
 	rcu_read_lock();
-	b_ptr = rcu_dereference_rtnl(bearer_list[l_ptr->bearer_id]);
+	b_ptr = rcu_dereference_rtnl(tn->bearer_list[l_ptr->bearer_id]);
 	if (b_ptr)
 		pr_info("%s Link %x<%s>:", str, l_ptr->addr, b_ptr->name);
 	rcu_read_unlock();
diff --git a/net/tipc/link.h b/net/tipc/link.h
index 380e27e..9df7fa4 100644
--- a/net/tipc/link.h
+++ b/net/tipc/link.h
@@ -223,7 +223,8 @@ int tipc_link_xmit_skb(struct net *net, struct sk_buff *skb, u32 dest,
 		       u32 selector);
 int tipc_link_xmit(struct net *net, struct sk_buff_head *list, u32 dest,
 		   u32 selector);
-int __tipc_link_xmit(struct tipc_link *link, struct sk_buff_head *list);
+int __tipc_link_xmit(struct net *net, struct tipc_link *link,
+		     struct sk_buff_head *list);
 void tipc_link_bundle_rcv(struct net *net, struct sk_buff *buf);
 void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int prob,
 			  u32 gap, u32 tolerance, u32 priority, u32 acked_mtu);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index de18aac..38633e5 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -117,7 +117,7 @@ int tipc_net_start(struct net *net, u32 addr)
 	tipc_own_addr = addr;
 	tipc_named_reinit();
 	tipc_sk_reinit();
-	res = tipc_bclink_init();
+	res = tipc_bclink_init(net);
 	if (res)
 		return res;
 
@@ -140,7 +140,7 @@ void tipc_net_stop(struct net *net)
 			      tipc_own_addr);
 	rtnl_lock();
 	tipc_bearer_stop(net);
-	tipc_bclink_stop();
+	tipc_bclink_stop(net);
 	tipc_node_stop(net);
 	rtnl_unlock();
 
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
