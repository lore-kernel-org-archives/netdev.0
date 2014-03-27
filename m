From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 02/10] tipc: obsolete the remote
	management feature
Date: Thu, 27 Mar 2014 12:54:31 +0800
Message-ID: <1395896080-7926-3-git-send-email-ying.xue@windriver.com>
References: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1395896080-7926-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Due to the lacking of any credential, it's allowed to accept commands
requested from remote nodes to query the local node status, which is
prone to involve potential security risks. Instead, if we login to
a remote node with ssh command, this approach is not only more safe
than the remote management feature, but also it can give us more
permissions like changing the remote node configuration. So it's
reasonable for us to obsolete the remote management feature now.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/config.c |  107 ++---------------------------------------------------
 net/tipc/config.h |    5 ---
 net/tipc/core.c   |    9 -----
 net/tipc/core.h   |    1 -
 net/tipc/net.c    |    2 -
 5 files changed, 3 insertions(+), 121 deletions(-)

diff --git a/net/tipc/config.c b/net/tipc/config.c
index e6d7216..4b981c0 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -43,13 +43,11 @@
 #define REPLY_TRUNCATED "<truncated>\n"
 
 static DEFINE_MUTEX(config_mutex);
-static struct tipc_server cfgsrv;
 
 static const void *req_tlv_area;	/* request message TLV area */
 static int req_tlv_space;		/* request message TLV area size */
 static int rep_headroom;		/* reply message headroom to use */
 
-
 struct sk_buff *tipc_cfg_reply_alloc(int payload_size)
 {
 	struct sk_buff *buf;
@@ -185,18 +183,6 @@ static struct sk_buff *cfg_set_own_addr(void)
 	return tipc_cfg_reply_none();
 }
 
-static struct sk_buff *cfg_set_remote_mng(void)
-{
-	u32 value;
-
-	if (!TLV_CHECK(req_tlv_area, req_tlv_space, TIPC_TLV_UNSIGNED))
-		return tipc_cfg_reply_error_string(TIPC_CFG_TLV_ERROR);
-
-	value = ntohl(*(__be32 *)TLV_DATA(req_tlv_area));
-	tipc_remote_management = (value != 0);
-	return tipc_cfg_reply_none();
-}
-
 static struct sk_buff *cfg_set_max_ports(void)
 {
 	u32 value;
@@ -247,21 +233,10 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	/* Check command authorization */
 	if (likely(in_own_node(orig_node))) {
 		/* command is permitted */
-	} else if (cmd >= 0x8000) {
+	} else {
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (cannot be done remotely)");
 		goto exit;
-	} else if (!tipc_remote_management) {
-		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NO_REMOTE);
-		goto exit;
-	} else if (cmd >= 0x4000) {
-		u32 domain = 0;
-
-		if ((tipc_nametbl_translate(TIPC_ZM_SRV, 0, &domain) == 0) ||
-		    (domain != orig_node)) {
-			rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_ZONE_MSTR);
-			goto exit;
-		}
 	}
 
 	/* Call appropriate processing routine */
@@ -310,18 +285,12 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_NODE_ADDR:
 		rep_tlv_buf = cfg_set_own_addr();
 		break;
-	case TIPC_CMD_SET_REMOTE_MNG:
-		rep_tlv_buf = cfg_set_remote_mng();
-		break;
 	case TIPC_CMD_SET_MAX_PORTS:
 		rep_tlv_buf = cfg_set_max_ports();
 		break;
 	case TIPC_CMD_SET_NETID:
 		rep_tlv_buf = cfg_set_netid();
 		break;
-	case TIPC_CMD_GET_REMOTE_MNG:
-		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_remote_management);
-		break;
 	case TIPC_CMD_GET_MAX_PORTS:
 		rep_tlv_buf = tipc_cfg_reply_unsigned(tipc_max_ports);
 		break;
@@ -345,6 +314,8 @@ struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd, const void *request_area
 	case TIPC_CMD_SET_MAX_PUBL:
 	case TIPC_CMD_GET_MAX_PUBL:
 	case TIPC_CMD_SET_LOG_SIZE:
+	case TIPC_CMD_SET_REMOTE_MNG:
+	case TIPC_CMD_GET_REMOTE_MNG:
 	case TIPC_CMD_DUMP_LOG:
 		rep_tlv_buf = tipc_cfg_reply_error_string(TIPC_CFG_NOT_SUPPORTED
 							  " (obsolete command)");
@@ -369,75 +340,3 @@ exit:
 	mutex_unlock(&config_mutex);
 	return rep_tlv_buf;
 }
-
-static void cfg_conn_msg_event(int conid, struct sockaddr_tipc *addr,
-			       void *usr_data, void *buf, size_t len)
-{
-	struct tipc_cfg_msg_hdr *req_hdr;
-	struct tipc_cfg_msg_hdr *rep_hdr;
-	struct sk_buff *rep_buf;
-
-	/* Validate configuration message header (ignore invalid message) */
-	req_hdr = (struct tipc_cfg_msg_hdr *)buf;
-	if ((len < sizeof(*req_hdr)) ||
-	    (len != TCM_ALIGN(ntohl(req_hdr->tcm_len))) ||
-	    (ntohs(req_hdr->tcm_flags) != TCM_F_REQUEST)) {
-		pr_warn("Invalid configuration message discarded\n");
-		return;
-	}
-
-	/* Generate reply for request (if can't, return request) */
-	rep_buf = tipc_cfg_do_cmd(addr->addr.id.node, ntohs(req_hdr->tcm_type),
-				  buf + sizeof(*req_hdr),
-				  len - sizeof(*req_hdr),
-				  BUF_HEADROOM + MAX_H_SIZE + sizeof(*rep_hdr));
-	if (rep_buf) {
-		skb_push(rep_buf, sizeof(*rep_hdr));
-		rep_hdr = (struct tipc_cfg_msg_hdr *)rep_buf->data;
-		memcpy(rep_hdr, req_hdr, sizeof(*rep_hdr));
-		rep_hdr->tcm_len = htonl(rep_buf->len);
-		rep_hdr->tcm_flags &= htons(~TCM_F_REQUEST);
-		tipc_conn_sendmsg(&cfgsrv, conid, addr, rep_buf->data,
-				  rep_buf->len);
-		kfree_skb(rep_buf);
-	}
-}
-
-static struct sockaddr_tipc cfgsrv_addr __read_mostly = {
-	.family			= AF_TIPC,
-	.addrtype		= TIPC_ADDR_NAMESEQ,
-	.addr.nameseq.type	= TIPC_CFG_SRV,
-	.addr.nameseq.lower	= 0,
-	.addr.nameseq.upper	= 0,
-	.scope			= TIPC_ZONE_SCOPE
-};
-
-static struct tipc_server cfgsrv __read_mostly = {
-	.saddr			= &cfgsrv_addr,
-	.imp			= TIPC_CRITICAL_IMPORTANCE,
-	.type			= SOCK_RDM,
-	.max_rcvbuf_size	= 64 * 1024,
-	.name			= "cfg_server",
-	.tipc_conn_recvmsg	= cfg_conn_msg_event,
-	.tipc_conn_new		= NULL,
-	.tipc_conn_shutdown	= NULL
-};
-
-int tipc_cfg_init(void)
-{
-	return tipc_server_start(&cfgsrv);
-}
-
-void tipc_cfg_reinit(void)
-{
-	tipc_server_stop(&cfgsrv);
-
-	cfgsrv_addr.addr.nameseq.lower = tipc_own_addr;
-	cfgsrv_addr.addr.nameseq.upper = tipc_own_addr;
-	tipc_server_start(&cfgsrv);
-}
-
-void tipc_cfg_stop(void)
-{
-	tipc_server_stop(&cfgsrv);
-}
diff --git a/net/tipc/config.h b/net/tipc/config.h
index 1f252f3..47b1bf1 100644
--- a/net/tipc/config.h
+++ b/net/tipc/config.h
@@ -64,9 +64,4 @@ static inline struct sk_buff *tipc_cfg_reply_ultra_string(char *string)
 struct sk_buff *tipc_cfg_do_cmd(u32 orig_node, u16 cmd,
 				const void *req_tlv_area, int req_tlv_space,
 				int headroom);
-
-int  tipc_cfg_init(void);
-void tipc_cfg_reinit(void);
-void tipc_cfg_stop(void);
-
 #endif
diff --git a/net/tipc/core.c b/net/tipc/core.c
index e2491b3..50d5742 100644
--- a/net/tipc/core.c
+++ b/net/tipc/core.c
@@ -50,7 +50,6 @@ int tipc_random __read_mostly;
 u32 tipc_own_addr __read_mostly;
 int tipc_max_ports __read_mostly;
 int tipc_net_id __read_mostly;
-int tipc_remote_management __read_mostly;
 int sysctl_tipc_rmem[3] __read_mostly;	/* min/default/max */
 
 /**
@@ -85,7 +84,6 @@ static void tipc_core_stop(void)
 	tipc_net_stop();
 	tipc_bearer_cleanup();
 	tipc_netlink_stop();
-	tipc_cfg_stop();
 	tipc_subscr_stop();
 	tipc_nametbl_stop();
 	tipc_ref_table_stop();
@@ -130,18 +128,12 @@ static int tipc_core_start(void)
 	if (err)
 		goto out_subscr;
 
-	err = tipc_cfg_init();
-	if (err)
-		goto out_cfg;
-
 	err = tipc_bearer_setup();
 	if (err)
 		goto out_bearer;
 
 	return 0;
 out_bearer:
-	tipc_cfg_stop();
-out_cfg:
 	tipc_subscr_stop();
 out_subscr:
 	tipc_unregister_sysctl();
@@ -166,7 +158,6 @@ static int __init tipc_init(void)
 	pr_info("Activated (version " TIPC_MOD_VER ")\n");
 
 	tipc_own_addr = 0;
-	tipc_remote_management = 1;
 	tipc_max_ports = CONFIG_TIPC_PORTS;
 	tipc_net_id = 4711;
 
diff --git a/net/tipc/core.h b/net/tipc/core.h
index 4dfe137..8985bbc 100644
--- a/net/tipc/core.h
+++ b/net/tipc/core.h
@@ -79,7 +79,6 @@ int tipc_snprintf(char *buf, int len, const char *fmt, ...);
 extern u32 tipc_own_addr __read_mostly;
 extern int tipc_max_ports __read_mostly;
 extern int tipc_net_id __read_mostly;
-extern int tipc_remote_management __read_mostly;
 extern int sysctl_tipc_rmem[3] __read_mostly;
 
 /*
diff --git a/net/tipc/net.c b/net/tipc/net.c
index 31b606e..bb171c3 100644
--- a/net/tipc/net.c
+++ b/net/tipc/net.c
@@ -182,8 +182,6 @@ void tipc_net_start(u32 addr)
 	tipc_bclink_init();
 	write_unlock_bh(&tipc_net_lock);
 
-	tipc_cfg_reinit();
-
 	pr_info("Started in network mode\n");
 	pr_info("Own node address %s, network identity %u\n",
 		tipc_addr_string_fill(addr_string, tipc_own_addr), tipc_net_id);
-- 
1.7.9.5


------------------------------------------------------------------------------
