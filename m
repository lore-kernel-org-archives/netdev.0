From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 07/16] tipc: involve namespace
	infrastructure
Date: Fri, 9 Jan 2015 15:27:04 +0800
Message-ID: <1420788433-17960-8-git-send-email-ying.xue@windriver.com>
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

Involve namespace infrastructure, make the "tipc_net_id" global
variable aware of per namespace, and rename it to "net_id". In
order that the conversion can be successfully done, an instance
of networking namespace must be passed to relevant functions,
allowing them to access the "net_id" variable of per namespace.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Tested-by: Tero Aho <Tero.Aho@coriant.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/bcast.c    |   15 ++++++++++-----
 net/tipc/bcast.h    |    5 +++--
 net/tipc/bearer.c   |   29 ++++++++++++-----------------
 net/tipc/bearer.h   |    5 +++--
 net/tipc/config.c   |   29 ++++++++++++++++-------------
 net/tipc/config.h   |    2 +-
 net/tipc/core.c     |   28 +++++++++++++++++++++++++++-
 net/tipc/core.h     |    5 +++++
 net/tipc/discover.c |   26 +++++++++++++++++---------
 net/tipc/discover.h |    8 +++++---
 net/tipc/link.c     |   47 +++++++++++++++++++++++++++--------------------
 net/tipc/msg.c      |    4 ++++
 net/tipc/net.c      |   22 ++++++++++++++--------
 net/tipc/net.h      |    2 +-
 net/tipc/netlink.c  |   10 ++++++----
 15 files changed, 151 insertions(+), 86 deletions(-)

diff --git a/net/tipc/bcast.c b/net/tipc/bcast.c
index a9e174f..f982311 100644
--- a/net/tipc/bcast.c
+++ b/net/tipc/bcast.c
@@ -327,9 +327,11 @@ exit:
  *
  * RCU and node lock set
  */
-void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
+void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
+				   u32 last_sent)
 {
 	struct sk_buff *buf;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	/* Ignore "stale" link state info */
 	if (less_eq(last_sent, n_ptr->bclink.last_in))
@@ -362,7 +364,7 @@ void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent)
 		tipc_msg_init(msg, BCAST_PROTOCOL, STATE_MSG,
 			      INT_H_SIZE, n_ptr->addr);
 		msg_set_non_seq(msg, 1);
-		msg_set_mc_netid(msg, tipc_net_id);
+		msg_set_mc_netid(msg, tn->net_id);
 		msg_set_bcast_ack(msg, n_ptr->bclink.last_in);
 		msg_set_bcgap_after(msg, n_ptr->bclink.last_in);
 		msg_set_bcgap_to(msg, to);
@@ -476,8 +478,9 @@ static void bclink_accept_pkt(struct tipc_node *node, u32 seqno)
  *
  * RCU is locked, no other locks set
  */
-void tipc_bclink_rcv(struct sk_buff *buf)
+void tipc_bclink_rcv(struct net *net, struct sk_buff *buf)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_msg *msg = buf_msg(buf);
 	struct tipc_node *node;
 	u32 next_in;
@@ -485,7 +488,7 @@ void tipc_bclink_rcv(struct sk_buff *buf)
 	int deferred = 0;
 
 	/* Screen out unwanted broadcast messages */
-	if (msg_mc_netid(msg) != tipc_net_id)
+	if (msg_mc_netid(msg) != tn->net_id)
 		goto exit;
 
 	node = tipc_node_find(msg_prevnode(msg));
@@ -638,6 +641,8 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 {
 	int bp_index;
 	struct tipc_msg *msg = buf_msg(buf);
+	struct net *net = sock_net(buf->sk);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	/* Prepare broadcast link message for reliable transmission,
 	 * if first time trying to send it;
@@ -647,7 +652,7 @@ static int tipc_bcbearer_send(struct sk_buff *buf, struct tipc_bearer *unused1,
 	if (likely(!msg_non_seq(buf_msg(buf)))) {
 		bcbuf_set_acks(buf, bclink->bcast_nodes.count);
 		msg_set_non_seq(msg, 1);
-		msg_set_mc_netid(msg, tipc_net_id);
+		msg_set_mc_netid(msg, tn->net_id);
 		bcl->stats.sent_info++;
 
 		if (WARN_ON(!bclink->bcast_nodes.count)) {
diff --git a/net/tipc/bcast.h b/net/tipc/bcast.h
index 644d791..a5fd224 100644
--- a/net/tipc/bcast.h
+++ b/net/tipc/bcast.h
@@ -91,10 +91,11 @@ void tipc_bclink_add_node(u32 addr);
 void tipc_bclink_remove_node(u32 addr);
 struct tipc_node *tipc_bclink_retransmit_to(void);
 void tipc_bclink_acknowledge(struct tipc_node *n_ptr, u32 acked);
-void tipc_bclink_rcv(struct sk_buff *buf);
+void tipc_bclink_rcv(struct net *net, struct sk_buff *buf);
 u32  tipc_bclink_get_last_sent(void);
 u32  tipc_bclink_acks_missing(struct tipc_node *n_ptr);
-void tipc_bclink_update_link_state(struct tipc_node *n_ptr, u32 last_sent);
+void tipc_bclink_update_link_state(struct net *net, struct tipc_node *n_ptr,
+				   u32 last_sent);
 int  tipc_bclink_stats(char *stats_buf, const u32 buf_size);
 int  tipc_bclink_reset_stats(void);
 int  tipc_bclink_set_queue_limits(u32 limit);
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 463db5b..cdd3033 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -260,7 +260,8 @@ void tipc_bearer_remove_dest(u32 bearer_id, u32 dest)
 /**
  * tipc_enable_bearer - enable bearer with the given name
  */
-int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
+int tipc_enable_bearer(struct net *net, const char *name, u32 disc_domain,
+		       u32 priority)
 {
 	struct tipc_bearer *b_ptr;
 	struct tipc_media *m_ptr;
@@ -361,7 +362,7 @@ restart:
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->priority = priority;
 
-	res = tipc_disc_create(b_ptr, &b_ptr->bcast_addr);
+	res = tipc_disc_create(net, b_ptr, &b_ptr->bcast_addr);
 	if (res) {
 		bearer_disable(b_ptr, false);
 		pr_warn("Bearer <%s> rejected, discovery object creation failed\n",
@@ -380,11 +381,11 @@ restart:
 /**
  * tipc_reset_bearer - Reset all links established over this bearer
  */
-static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
+static int tipc_reset_bearer(struct net *net, struct tipc_bearer *b_ptr)
 {
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
 	tipc_link_reset_list(b_ptr->identity);
-	tipc_disc_reset(b_ptr);
+	tipc_disc_reset(net, b_ptr);
 	return 0;
 }
 
@@ -539,17 +540,12 @@ static int tipc_l2_rcv_msg(struct sk_buff *buf, struct net_device *dev,
 {
 	struct tipc_bearer *b_ptr;
 
-	if (!net_eq(dev_net(dev), &init_net)) {
-		kfree_skb(buf);
-		return NET_RX_DROP;
-	}
-
 	rcu_read_lock();
 	b_ptr = rcu_dereference_rtnl(dev->tipc_ptr);
 	if (likely(b_ptr)) {
 		if (likely(buf->pkt_type <= PACKET_BROADCAST)) {
 			buf->next = NULL;
-			tipc_rcv(buf, b_ptr);
+			tipc_rcv(dev_net(dev), buf, b_ptr);
 			rcu_read_unlock();
 			return NET_RX_SUCCESS;
 		}
@@ -572,11 +568,9 @@ static int tipc_l2_rcv_msg(struct sk_buff *buf, struct net_device *dev,
 static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 				void *ptr)
 {
-	struct tipc_bearer *b_ptr;
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
-
-	if (!net_eq(dev_net(dev), &init_net))
-		return NOTIFY_DONE;
+	struct net *net = dev_net(dev);
+	struct tipc_bearer *b_ptr;
 
 	b_ptr = rtnl_dereference(dev->tipc_ptr);
 	if (!b_ptr)
@@ -590,12 +584,12 @@ static int tipc_l2_device_event(struct notifier_block *nb, unsigned long evt,
 			break;
 	case NETDEV_DOWN:
 	case NETDEV_CHANGEMTU:
-		tipc_reset_bearer(b_ptr);
+		tipc_reset_bearer(net, b_ptr);
 		break;
 	case NETDEV_CHANGEADDR:
 		b_ptr->media->raw2addr(b_ptr, &b_ptr->addr,
 				       (char *)dev->dev_addr);
-		tipc_reset_bearer(b_ptr);
+		tipc_reset_bearer(net, b_ptr);
 		break;
 	case NETDEV_UNREGISTER:
 	case NETDEV_CHANGENAME:
@@ -808,6 +802,7 @@ int tipc_nl_bearer_disable(struct sk_buff *skb, struct genl_info *info)
 
 int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = genl_info_net(info);
 	int err;
 	char *bearer;
 	struct nlattr *attrs[TIPC_NLA_BEARER_MAX + 1];
@@ -847,7 +842,7 @@ int tipc_nl_bearer_enable(struct sk_buff *skb, struct genl_info *info)
 	}
 
 	rtnl_lock();
-	err = tipc_enable_bearer(bearer, domain, prio);
+	err = tipc_enable_bearer(net, bearer, domain, prio);
 	if (err) {
 		rtnl_unlock();
 		return err;
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 2c1230a..43f683a 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -165,8 +165,9 @@ extern struct tipc_bearer __rcu *bearer_list[];
  * TIPC routines available to supported media types
  */
 
-void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *tb_ptr);
-int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
+void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr);
+int tipc_enable_bearer(struct net *net, const char *bearer_name,
+		       u32 disc_domain, u32 priority);
 int tipc_disable_bearer(const char *name);
 
 /*
diff --git a/net/tipc/config.c b/net/tipc/config.c
index 0b3a90e..28d4272 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -134,7 +134,7 @@ static struct sk_buff *tipc_show_stats(void)
 	return buf;
 }
 
-static struct sk_buff *cfg_enable_bearer(void)
+static struct sk_buff *cfg_enable_bearer(struct net *net)
 {
 	struct tipc_bearer_config *args;
 
@@ -142,7 +142,7 @@ static struct sk_buff *cfg_enable_bearer(void)
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 
 	args = (struct tipc_bearer_config *)TLV_DATA(req_tlv_area);
-	if (tipc_enable_bearer(args->name,
+	if (tipc_enable_bearer(net, args->name,
 			       ntohl(args->disc_domain),
 			       ntohl(args->priority)))
 		return tipc_cfg_reply_error_string("unable to enable bearer");
@@ -161,7 +161,7 @@ static struct sk_buff *cfg_disable_bearer(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_own_addr(void)
+static struct sk_buff *cfg_set_own_addr(struct net *net)
 {
 	u32 addr;
 
@@ -177,20 +177,21 @@ static struct sk_buff *cfg_set_own_addr(void)
 	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 						   " (cannot change node address once assigned)");
-	if (!tipc_net_start(addr))
+	if (!tipc_net_start(net, addr))
 		return tipc_cfg_reply_none();
 
 	return tipc_cfg_reply_error_string("cannot change to network mode");
 }
 
-static struct sk_buff *cfg_set_netid(void)
+static struct sk_buff *cfg_set_netid(struct net *net)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	u32 value;
 
 	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
 		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
 	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	if (value == tipc_net_id)
+	if (value == tn->net_id)
 		return tipc_cfg_reply_none();
 	if (value < 1 || value > 9999)
 		return tipc_cfg_reply_error_string(TIPC_CFG_INVALID_VALUE
@@ -198,14 +199,16 @@ static struct sk_buff *cfg_set_netid(void)
 	if (tipc_own_addr)
 		return tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 			" (cannot change network id once TIPC has joined a network)");
-	tipc_net_id = value;
+	tn->net_id = value;
 	return tipc_cfg_reply_none();
 }
 
-struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area,
-				int request_space, int reply_headroom)
+struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
+				const void *request_area, int request_space,
+				int reply_headroom)
 {
 	struct sk_buff *rep_tlv_buf;
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 
 	rtnl_lock();
 
@@ -261,19 +264,19 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 		rep_tlv_buf = tipc_link_cmd_config(req_tlv_area, req_tlv_space, cmd);
 		break;
 	case TIPC_CMD_ENABLE_BEARER:
-		rep_tlv_buf = cfg_enable_bearer();
+		rep_tlv_buf = cfg_enable_bearer(net);
 		break;
 	case TIPC_CMD_DISABLE_BEARER:
 		rep_tlv_buf = cfg_disable_bearer();
 		break;
 	case TIPC_CMD_SET_NODE_ADDR:
-		rep_tlv_buf = cfg_set_own_addr();
+		rep_tlv_buf = cfg_set_own_addr(net);
 		break;
 	case TIPC_CMD_SET_NETID:
-		rep_tlv_buf = cfg_set_netid();
+		rep_tlv_buf = cfg_set_netid(net);
 		break;
 	case TIPC_CMD_GET_NETID:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_net_id);
+		rep_tlv_buf = tipc_cfg_reply_unsigned(tn->net_id);
 		break;
 	case TIPC_CMD_NOT_NET_ADMIN:
 		rep_tlv_buf =
diff --git a/net/tipc/config.h b/net/tipc/config.h
index a41a41c..9e9b575 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -61,7 +61,7 @@ static inline struct sk_buff *tipc_cfg_reply_ultra_string(char *string)
 	return tipc_cfg_reply_string_type(TIPC_TLV_ULTRA_STRING, string);
 }
 
-struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd,
+struct sk_buff *tipc_cfg_do_cmd(struct net *net, u32 orig_node, u16 cmd,
 				const void *req_tlv_area, int req_tlv_space,
 				int headroom);
 #endif
diff --git a/net/tipc/core.c b/net/tipc/core.c
index b6ec3d7..a230248 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -52,6 +52,26 @@ u32 tipc_own_addr __read_mostly;
 int tipc_net_id __read_mostly;
 int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
 
+static int __net_init tipc_init_net(struct net *net)
+{
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
+
+	tn->net_id = 4711;
+
+	return 0;
+}
+
+static void __net_exit tipc_exit_net(struct net *net)
+{
+}
+
+static struct pernet_operations tipc_net_ops = {
+	.init = tipc_init_net,
+	.exit = tipc_exit_net,
+	.id   = &tipc_net_id,
+	.size = sizeof(struct tipc_net),
+};
+
 static int __init tipc_init(void)
 {
 	int err;
@@ -59,7 +79,6 @@ static int __init tipc_init(void)
 	pr_info("Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
-	tipc_net_id = 4711;
 
 	sysctl_tipc_rmem[0] = TIPC_CONN_OVERLOAD_LIMIT >> 4 <<
 			      TIPC_LOW_IMPORTANCE;
@@ -69,6 +88,10 @@ static int __init tipc_init(void)
 
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 
+	err = register_pernet_subsys(&tipc_net_ops);
+	if (err)
+		goto out_pernet;
+
 	err = tipc_sk_rht_init();
 	if (err)
 		goto out_reftbl;
@@ -112,12 +135,15 @@ out_netlink:
 out_nametbl:
 	tipc_sk_rht_destroy();
 out_reftbl:
+	unregister_pernet_subsys(&tipc_net_ops);
+out_pernet:
 	pr_err("Unable to start in single node mode\n");
 	return err;
 }
 
 static void __exit tipc_exit(void)
 {
+	unregister_pernet_subsys(&tipc_net_ops);
 	tipc_net_stop();
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
diff --git a/net/tipc/core.h b/net/tipc/core.h
index a5b3140..106e815 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -57,6 +57,7 @@
 #include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
 #include <linux/etherdevice.h>
+#include <net/netns/generic.h>
 
 #define TIPC_MOD_VER "2.0.0"
 
@@ -75,6 +76,10 @@ extern int sysctl_tipc_named_timeout __read_mostly;
  */
 extern int tipc_random __read_mostly;
 
+struct tipc_net {
+	int net_id;
+};
+
 #ifdef CONFIG_SYSCTL
 int tipc_register_sysctl(void);
 void tipc_unregister_sysctl(void);
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 1a3a985..246a237 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -72,12 +72,14 @@ struct tipc_link_req {
 
 /**
  * tipc_disc_init_msg - initialize a link setup message
+ * @net: the applicable net namespace
  * @type: message type (request or response)
  * @b_ptr: ptr to bearer issuing message
  */
-static void tipc_disc_init_msg(struct sk_buff *buf, u32 type,
+static void tipc_disc_init_msg(struct net *net, struct sk_buff *buf, u32 type,
 			       struct tipc_bearer *b_ptr)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_msg *msg;
 	u32 dest_domain = b_ptr->domain;
 
@@ -86,7 +88,7 @@ static void tipc_disc_init_msg(struct sk_buff *buf, u32 type,
 	msg_set_non_seq(msg, 1);
 	msg_set_node_sig(msg, tipc_random);
 	msg_set_dest_domain(msg, dest_domain);
-	msg_set_bc_netid(msg, tipc_net_id);
+	msg_set_bc_netid(msg, tn->net_id);
 	b_ptr->media->addr2msg(msg_media_addr(msg), &b_ptr->addr);
 }
 
@@ -111,11 +113,14 @@ static void disc_dupl_alert(struct tipc_bearer *b_ptr, u32 node_addr,
 
 /**
  * tipc_disc_rcv - handle incoming discovery message (request or response)
+ * @net: the applicable net namespace
  * @buf: buffer containing message
  * @bearer: bearer that message arrived on
  */
-void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *bearer)
+void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
+		   struct tipc_bearer *bearer)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct tipc_node *node;
 	struct tipc_link *link;
 	struct tipc_media_addr maddr;
@@ -137,7 +142,7 @@ void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *bearer)
 	kfree_skb(buf);
 
 	/* Ensure message from node is valid and communication is permitted */
-	if (net_id != tipc_net_id)
+	if (net_id != tn->net_id)
 		return;
 	if (maddr.broadcast)
 		return;
@@ -248,7 +253,7 @@ void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *bearer)
 	if (respond && (mtyp == DSC_REQ_MSG)) {
 		rbuf = tipc_buf_acquire(INT_H_SIZE);
 		if (rbuf) {
-			tipc_disc_init_msg(rbuf, DSC_RESP_MSG, bearer);
+			tipc_disc_init_msg(net, rbuf, DSC_RESP_MSG, bearer);
 			tipc_bearer_send(bearer->identity, rbuf, &maddr);
 			kfree_skb(rbuf);
 		}
@@ -341,13 +346,15 @@ exit:
 
 /**
  * tipc_disc_create - create object to send periodic link setup requests
+ * @net: the applicable net namespace
  * @b_ptr: ptr to bearer issuing requests
  * @dest: destination address for request messages
  * @dest_domain: network domain to which links can be established
  *
  * Returns 0 if successful, otherwise -errno.
  */
-int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
+int tipc_disc_create(struct net *net, struct tipc_bearer *b_ptr,
+		     struct tipc_media_addr *dest)
 {
 	struct tipc_link_req *req;
 
@@ -361,7 +368,7 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
 		return -ENOMEM;
 	}
 
-	tipc_disc_init_msg(req->buf, DSC_REQ_MSG, b_ptr);
+	tipc_disc_init_msg(net, req->buf, DSC_REQ_MSG, b_ptr);
 	memcpy(&req->dest, dest, sizeof(*dest));
 	req->bearer_id = b_ptr->identity;
 	req->domain = b_ptr->domain;
@@ -388,15 +395,16 @@ void tipc_disc_delete(struct tipc_link_req *req)
 
 /**
  * tipc_disc_reset - reset object to send periodic link setup requests
+ * @net: the applicable net namespace
  * @b_ptr: ptr to bearer issuing requests
  * @dest_domain: network domain to which links can be established
  */
-void tipc_disc_reset(struct tipc_bearer *b_ptr)
+void tipc_disc_reset(struct net *net, struct tipc_bearer *b_ptr)
 {
 	struct tipc_link_req *req = b_ptr->link_req;
 
 	spin_lock_bh(&req->lock);
-	tipc_disc_init_msg(req->buf, DSC_REQ_MSG, b_ptr);
+	tipc_disc_init_msg(net, req->buf, DSC_REQ_MSG, b_ptr);
 	req->bearer_id = b_ptr->identity;
 	req->domain = b_ptr->domain;
 	req->num_nodes = 0;
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index 515b573..c9b1277 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -39,11 +39,13 @@
 
 struct tipc_link_req;
 
-int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest);
+int tipc_disc_create(struct net *net, struct tipc_bearer *b_ptr,
+		     struct tipc_media_addr *dest);
 void tipc_disc_delete(struct tipc_link_req *req);
-void tipc_disc_reset(struct tipc_bearer *b_ptr);
+void tipc_disc_reset(struct net *net, struct tipc_bearer *b_ptr);
 void tipc_disc_add_dest(struct tipc_link_req *req);
 void tipc_disc_remove_dest(struct tipc_link_req *req);
-void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr);
+void tipc_disc_rcv(struct net *net, struct sk_buff *buf,
+		   struct tipc_bearer *b_ptr);
 
 #endif
diff --git a/net/tipc/link.c b/net/tipc/link.c
index f231058..248813c 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -101,10 +101,12 @@ static const struct nla_policy tipc_nl_prop_policy[TIPC_NLA_PROP_MAX + 1] = {
  */
 #define START_CHANGEOVER 100000u
 
-static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
+static void link_handle_out_of_seq_msg(struct net *net,
+				       struct tipc_link *l_ptr,
 				       struct sk_buff *buf);
-static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf);
-static int  tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
+static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
+				struct sk_buff *buf);
+static int  tipc_link_tunnel_rcv(struct net *net, struct tipc_node *n_ptr,
 				 struct sk_buff **buf);
 static void link_set_supervision_props(struct tipc_link *l_ptr, u32 tol);
 static void link_state_event(struct tipc_link *l_ptr, u32 event);
@@ -113,7 +115,8 @@ static void link_print(struct tipc_link *l_ptr, const char *str);
 static void tipc_link_sync_xmit(struct tipc_link *l);
 static void tipc_link_sync_rcv(struct tipc_node *n, struct sk_buff *buf);
 static int tipc_link_input(struct tipc_link *l, struct sk_buff *buf);
-static int tipc_link_prepare_input(struct tipc_link *l, struct sk_buff **buf);
+static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
+				   struct sk_buff **buf);
 
 /*
  *  Simple link routines
@@ -1063,13 +1066,14 @@ static int link_recv_buf_validate(struct sk_buff *buf)
 
 /**
  * tipc_rcv - process TIPC packets/messages arriving from off-node
+ * @net: net namespace handler
  * @skb: TIPC packet
  * @b_ptr: pointer to bearer message arrived on
  *
  * Invoked with no locks held.  Bearer pointer must point to a valid bearer
  * structure (i.e. cannot be NULL), but bearer can be inactive.
  */
-void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
+void tipc_rcv(struct net *net, struct sk_buff *skb, struct tipc_bearer *b_ptr)
 {
 	struct sk_buff_head head;
 	struct tipc_node *n_ptr;
@@ -1096,9 +1100,9 @@ void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
 
 		if (unlikely(msg_non_seq(msg))) {
 			if (msg_user(msg) ==  LINK_CONFIG)
-				tipc_disc_rcv(skb, b_ptr);
+				tipc_disc_rcv(net, skb, b_ptr);
 			else
-				tipc_bclink_rcv(skb);
+				tipc_bclink_rcv(net, skb);
 			continue;
 		}
 
@@ -1159,7 +1163,7 @@ void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
 		/* Process the incoming packet */
 		if (unlikely(!link_working_working(l_ptr))) {
 			if (msg_user(msg) == LINK_PROTOCOL) {
-				tipc_link_proto_rcv(l_ptr, skb);
+				tipc_link_proto_rcv(net, l_ptr, skb);
 				link_retrieve_defq(l_ptr, &head);
 				tipc_node_unlock(n_ptr);
 				continue;
@@ -1179,7 +1183,7 @@ void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
 
 		/* Link is now in state WORKING_WORKING */
 		if (unlikely(seq_no != mod(l_ptr->next_in_no))) {
-			link_handle_out_of_seq_msg(l_ptr, skb);
+			link_handle_out_of_seq_msg(net, l_ptr, skb);
 			link_retrieve_defq(l_ptr, &head);
 			tipc_node_unlock(n_ptr);
 			continue;
@@ -1193,7 +1197,7 @@ void tipc_rcv(struct sk_buff *skb, struct tipc_bearer *b_ptr)
 			tipc_link_proto_xmit(l_ptr, STATE_MSG, 0, 0, 0, 0, 0);
 		}
 
-		if (tipc_link_prepare_input(l_ptr, &skb)) {
+		if (tipc_link_prepare_input(net, l_ptr, &skb)) {
 			tipc_node_unlock(n_ptr);
 			continue;
 		}
@@ -1216,7 +1220,8 @@ discard:
  *
  * Node lock must be held
  */
-static int tipc_link_prepare_input(struct tipc_link *l, struct sk_buff **buf)
+static int tipc_link_prepare_input(struct net *net, struct tipc_link *l,
+				   struct sk_buff **buf)
 {
 	struct tipc_node *n;
 	struct tipc_msg *msg;
@@ -1226,7 +1231,7 @@ static int tipc_link_prepare_input(struct tipc_link *l, struct sk_buff **buf)
 	msg = buf_msg(*buf);
 	switch (msg_user(msg)) {
 	case CHANGEOVER_PROTOCOL:
-		if (tipc_link_tunnel_rcv(n, buf))
+		if (tipc_link_tunnel_rcv(net, n, buf))
 			res = 0;
 		break;
 	case MSG_FRAGMENTER:
@@ -1325,13 +1330,14 @@ u32 tipc_link_defer_pkt(struct sk_buff_head *list, struct sk_buff *skb)
 /*
  * link_handle_out_of_seq_msg - handle arrival of out-of-sequence packet
  */
-static void link_handle_out_of_seq_msg(struct tipc_link *l_ptr,
+static void link_handle_out_of_seq_msg(struct net *net,
+				       struct tipc_link *l_ptr,
 				       struct sk_buff *buf)
 {
 	u32 seq_no = buf_seqno(buf);
 
 	if (likely(msg_user(buf_msg(buf)) == LINK_PROTOCOL)) {
-		tipc_link_proto_rcv(l_ptr, buf);
+		tipc_link_proto_rcv(net, l_ptr, buf);
 		return;
 	}
 
@@ -1455,7 +1461,8 @@ void tipc_link_proto_xmit(struct tipc_link *l_ptr, u32 msg_typ, int probe_msg,
  * Note that network plane id propagates through the network, and may
  * change at any time. The node with lowest address rules
  */
-static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
+static void tipc_link_proto_rcv(struct net *net, struct tipc_link *l_ptr,
+				struct sk_buff *buf)
 {
 	u32 rec_gap = 0;
 	u32 max_pkt_info;
@@ -1571,7 +1578,7 @@ static void tipc_link_proto_rcv(struct tipc_link *l_ptr, struct sk_buff *buf)
 
 		/* Protocol message before retransmits, reduce loss risk */
 		if (l_ptr->owner->bclink.recv_permitted)
-			tipc_bclink_update_link_state(l_ptr->owner,
+			tipc_bclink_update_link_state(net, l_ptr->owner,
 						      msg_last_bcast(msg));
 
 		if (rec_gap || (msg_probe(msg))) {
@@ -1748,7 +1755,7 @@ static struct sk_buff *buf_extract(struct sk_buff *skb, u32 from_pos)
 /* tipc_link_dup_rcv(): Receive a tunnelled DUPLICATE_MSG packet.
  * Owner node is locked.
  */
-static void tipc_link_dup_rcv(struct tipc_link *l_ptr,
+static void tipc_link_dup_rcv(struct net *net, struct tipc_link *l_ptr,
 			      struct sk_buff *t_buf)
 {
 	struct sk_buff *buf;
@@ -1763,7 +1770,7 @@ static void tipc_link_dup_rcv(struct tipc_link *l_ptr,
 	}
 
 	/* Add buffer to deferred queue, if applicable: */
-	link_handle_out_of_seq_msg(l_ptr, buf);
+	link_handle_out_of_seq_msg(net, l_ptr, buf);
 }
 
 /*  tipc_link_failover_rcv(): Receive a tunnelled ORIGINAL_MSG packet
@@ -1817,7 +1824,7 @@ exit:
  *  returned to the active link for delivery upwards.
  *  Owner node is locked.
  */
-static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
+static int tipc_link_tunnel_rcv(struct net *net, struct tipc_node *n_ptr,
 				struct sk_buff **buf)
 {
 	struct sk_buff *t_buf = *buf;
@@ -1835,7 +1842,7 @@ static int tipc_link_tunnel_rcv(struct tipc_node *n_ptr,
 		goto exit;
 
 	if (msg_type(t_msg) == DUPLICATE_MSG)
-		tipc_link_dup_rcv(l_ptr, t_buf);
+		tipc_link_dup_rcv(net, l_ptr, t_buf);
 	else if (msg_type(t_msg) == ORIGINAL_MSG)
 		*buf = tipc_link_failover_rcv(l_ptr, t_buf);
 	else
diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 35523fb..a38f6a6 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -34,6 +34,7 @@
  * POSSIBILITY OF SUCH DAMAGE.
  */
 
+#include <net/sock.h>
 #include "core.h"
 #include "msg.h"
 #include "addr.h"
@@ -214,6 +215,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 		skb = tipc_buf_acquire(msz);
 		if (unlikely(!skb))
 			return -ENOMEM;
+		skb_orphan(skb);
 		__skb_queue_tail(list, skb);
 		skb_copy_to_linear_data(skb, mhdr, mhsz);
 		pktpos = skb->data + mhsz;
@@ -234,6 +236,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 	skb = tipc_buf_acquire(pktmax);
 	if (!skb)
 		return -ENOMEM;
+	skb_orphan(skb);
 	__skb_queue_tail(list, skb);
 	pktpos = skb->data;
 	skb_copy_to_linear_data(skb, &pkthdr, INT_H_SIZE);
@@ -267,6 +270,7 @@ int tipc_msg_build(struct tipc_msg *mhdr, struct msghdr *m, int offset,
 			rc = -ENOMEM;
 			goto error;
 		}
+		skb_orphan(skb);
 		__skb_queue_tail(list, skb);
 		msg_set_type(&pkthdr, FRAGMENT);
 		msg_set_size(&pkthdr, pktsz);
diff --git a/net/tipc/net.c b/net/tipc/net.c
index cf13df3..5ce9d62 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -108,8 +108,9 @@ static const struct nla_policy tipc_nl_net_policy[TIPC_NLA_NET_MAX + 1] = {
  *     - A local spin_lock protecting the queue of subscriber events.
 */
 
-int tipc_net_start(u32 addr)
+int tipc_net_start(struct net *net, u32 addr)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	char addr_string[16];
 	int res;
 
@@ -125,7 +126,8 @@ int tipc_net_start(u32 addr)
 
 	pr_info("Started in network mode\n");
 	pr_info("Own node address %s, network identity %u\n",
-		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
+		tipc_addr_string_fill(addr_string, tipc_own_addr),
+		tn->net_id);
 	return 0;
 }
 
@@ -144,8 +146,9 @@ void tipc_net_stop(void)
 	pr_info("Left network mode\n");
 }
 
-static int __tipc_nl_add_net(struct tipc_nl_msg *msg)
+static int __tipc_nl_add_net(struct net *net, struct tipc_nl_msg *msg)
 {
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	void *hdr;
 	struct nlattr *attrs;
 
@@ -158,7 +161,7 @@ static int __tipc_nl_add_net(struct tipc_nl_msg *msg)
 	if (!attrs)
 		goto msg_full;
 
-	if (nla_put_u32(msg->skb, TIPC_NLA_NET_ID, tipc_net_id))
+	if (nla_put_u32(msg->skb, TIPC_NLA_NET_ID, tn->net_id))
 		goto attr_msg_full;
 
 	nla_nest_end(msg->skb, attrs);
@@ -176,6 +179,7 @@ msg_full:
 
 int tipc_nl_net_dump(struct sk_buff *skb, struct netlink_callback *cb)
 {
+	struct net *net = sock_net(skb->sk);
 	int err;
 	int done = cb->args[0];
 	struct tipc_nl_msg msg;
@@ -187,7 +191,7 @@ int tipc_nl_net_dump(struct sk_buff *skb, struct netlink_callback *cb)
 	msg.portid = NETLINK_CB(cb->skb).portid;
 	msg.seq = cb->nlh->nlmsg_seq;
 
-	err = __tipc_nl_add_net(&msg);
+	err = __tipc_nl_add_net(net, &msg);
 	if (err)
 		goto out;
 
@@ -200,8 +204,10 @@ out:
 
 int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 {
-	int err;
+	struct net *net = genl_info_net(info);
+	struct tipc_net *tn = net_generic(net, tipc_net_id);
 	struct nlattr *attrs[TIPC_NLA_NET_MAX + 1];
+	int err;
 
 	if (!info->attrs[TIPC_NLA_NET])
 		return -EINVAL;
@@ -223,7 +229,7 @@ int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 		if (val < 1 || val > 9999)
 			return -EINVAL;
 
-		tipc_net_id = val;
+		tn->net_id = val;
 	}
 
 	if (attrs[TIPC_NLA_NET_ADDR]) {
@@ -238,7 +244,7 @@ int tipc_nl_net_set(struct sk_buff *skb, struct genl_info *info)
 			return -EINVAL;
 
 		rtnl_lock();
-		tipc_net_start(addr);
+		tipc_net_start(net, addr);
 		rtnl_unlock();
 	}
 
diff --git a/net/tipc/net.h b/net/tipc/net.h
index a81c1b9..2c4812f 100644
--- a/net/tipc/net.h
+++ b/net/tipc/net.h
@@ -39,7 +39,7 @@
 
 #include <net/genetlink.h>
 
-int tipc_net_start(u32 addr);
+int tipc_net_start(struct net *net, u32 addr);
 
 void tipc_net_stop(void);
 
diff --git a/net/tipc/netlink.c b/net/tipc/netlink.c
index b891e39..282b596 100644
--- a/net/tipc/netlink.c
+++ b/net/tipc/netlink.c
@@ -46,6 +46,7 @@
 
 static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 {
+	struct net *net = genl_info_net(info);
 	struct sk_buff *rep_buf;
 	struct nlmsghdr *rep_nlh;
 	struct nlmsghdr *req_nlh = info->nlhdr;
@@ -58,10 +59,11 @@ static int handle_cmd(struct sk_buff *skb, struct genl_info *info)
 	else
 		cmd = req_userhdr->cmd;
 
-	rep_buf = tipc_cfg_do_cmd(req_userhdr->dest, cmd,
-			nlmsg_data(req_nlh) + GENL_HDRLEN + TIPC_GENL_HDRLEN,
-			nlmsg_attrlen(req_nlh, GENL_HDRLEN + TIPC_GENL_HDRLEN),
-			hdr_space);
+	rep_buf = tipc_cfg_do_cmd(net, req_userhdr->dest, cmd,
+				  nlmsg_data(req_nlh) + GENL_HDRLEN +
+				  TIPC_GENL_HDRLEN,
+				  nlmsg_attrlen(req_nlh, GENL_HDRLEN +
+				  TIPC_GENL_HDRLEN), hdr_space);
 
 	if (rep_buf) {
 		skb_push(rep_buf, hdr_space);
-- 
1.7.9.5


------------------------------------------------------------------------------
Dive into the World of Parallel Programming! The Go Parallel Website,
sponsored by Intel and developed in partnership with Slashdot Media, is your
hub for all things parallel software development, from weekly thought
leadership blogs to news, videos, case studies, tutorials and more. Take a
look and join the conversation now. http://goparallel.sourceforge.net
