From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH net-next 11/11] tipc: fix race in disc
	create/delete
Date: Mon, 21 Apr 2014 10:55:52 +0800
Message-ID: <1398048952-7825-12-git-send-email-ying.xue@windriver.com>
References: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, Paul.Gortmaker@windriver.com,
	tipc-discussion@lists.sourceforge.net, netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1398048952-7825-1-git-send-email-ying.xue@windriver.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Commit a21a584d6720ce349b05795b9bcfab3de8e58419 (tipc: fix neighbor
detection problem after hw address change) introduces a race condition
involving tipc_disc_delete() and tipc_disc_add/remove_dest that can
cause TIPC to dereference the pointer to the bearer discovery request
structure after it has been freed since a stray pointer is left in the
bearer structure.

In order to fix the issue, the process of resetting the discovery
request handler is optimized: the discovery request handler and request
buffer are just reset instead of being freed, allocated and initialized.
As the request point is always valid and the request's lock is taken
while the request handler is reset, the race doesn't happen any more.

Reported-by: Erik Hugne <erik.hugne@ericsson.com>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Erik Hugne <erik.hugne@ericsson.com>
Tested-by: Erik Hugne <erik.hugne@ericsson.com>
---
 net/tipc/bearer.c   |    3 +--
 net/tipc/discover.c |   53 ++++++++++++++++++++++++++++++++++-----------------
 net/tipc/discover.h |    1 +
 3 files changed, 37 insertions(+), 20 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 3abd970..f3259d4 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -365,9 +365,8 @@ restart:
 static int tipc_reset_bearer(struct tipc_bearer *b_ptr)
 {
 	pr_info("Resetting bearer <%s>\n", b_ptr->name);
-	tipc_disc_delete(b_ptr->link_req);
 	tipc_link_reset_list(b_ptr->identity);
-	tipc_disc_create(b_ptr, &b_ptr->bcast_addr);
+	tipc_disc_reset(b_ptr);
 	return 0;
 }
 
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 3a8f211..ada42e4 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -71,22 +71,19 @@ struct tipc_link_req {
  * @type: message type (request or response)
  * @b_ptr: ptr to bearer issuing message
  */
-static struct sk_buff *tipc_disc_init_msg(u32 type, struct tipc_bearer *b_ptr)
+static void tipc_disc_init_msg(struct sk_buff *buf, u32 type,
+			       struct tipc_bearer *b_ptr)
 {
-	struct sk_buff *buf = tipc_buf_acquire(INT_H_SIZE);
 	struct tipc_msg *msg;
 	u32 dest_domain = b_ptr->domain;
 
-	if (buf) {
-		msg = buf_msg(buf);
-		tipc_msg_init(msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
-		msg_set_non_seq(msg, 1);
-		msg_set_node_sig(msg, tipc_random);
-		msg_set_dest_domain(msg, dest_domain);
-		msg_set_bc_netid(msg, tipc_net_id);
-		b_ptr->media->addr2msg(&b_ptr->addr, msg_media_addr(msg));
-	}
-	return buf;
+	msg = buf_msg(buf);
+	tipc_msg_init(msg, LINK_CONFIG, type, INT_H_SIZE, dest_domain);
+	msg_set_non_seq(msg, 1);
+	msg_set_node_sig(msg, tipc_random);
+	msg_set_dest_domain(msg, dest_domain);
+	msg_set_bc_netid(msg, tipc_net_id);
+	b_ptr->media->addr2msg(&b_ptr->addr, msg_media_addr(msg));
 }
 
 /**
@@ -241,8 +238,9 @@ void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	link_fully_up = link_working_working(link);
 
 	if ((type == DSC_REQ_MSG) && !link_fully_up) {
-		rbuf = tipc_disc_init_msg(DSC_RESP_MSG, b_ptr);
+		rbuf = tipc_buf_acquire(INT_H_SIZE);
 		if (rbuf) {
+			tipc_disc_init_msg(rbuf, DSC_RESP_MSG, b_ptr);
 			tipc_bearer_send(b_ptr->identity, rbuf, &media_addr);
 			kfree_skb(rbuf);
 		}
@@ -349,12 +347,11 @@ int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest)
 	if (!req)
 		return -ENOMEM;
 
-	req->buf = tipc_disc_init_msg(DSC_REQ_MSG, b_ptr);
-	if (!req->buf) {
-		kfree(req);
-		return -ENOMSG;
-	}
+	req->buf = tipc_buf_acquire(INT_H_SIZE);
+	if (!req->buf)
+		return -ENOMEM;
 
+	tipc_disc_init_msg(req->buf, DSC_REQ_MSG, b_ptr);
 	memcpy(&req->dest, dest, sizeof(*dest));
 	req->bearer_id = b_ptr->identity;
 	req->domain = b_ptr->domain;
@@ -379,3 +376,23 @@ void tipc_disc_delete(struct tipc_link_req *req)
 	kfree_skb(req->buf);
 	kfree(req);
 }
+
+/**
+ * tipc_disc_reset - reset object to send periodic link setup requests
+ * @b_ptr: ptr to bearer issuing requests
+ * @dest_domain: network domain to which links can be established
+ */
+void tipc_disc_reset(struct tipc_bearer *b_ptr)
+{
+	struct tipc_link_req *req = b_ptr->link_req;
+
+	spin_lock_bh(&req->lock);
+	tipc_disc_init_msg(req->buf, DSC_REQ_MSG, b_ptr);
+	req->bearer_id = b_ptr->identity;
+	req->domain = b_ptr->domain;
+	req->num_nodes = 0;
+	req->timer_intv = TIPC_LINK_REQ_INIT;
+	k_start_timer(&req->timer, req->timer_intv);
+	tipc_bearer_send(req->bearer_id, req->buf, &req->dest);
+	spin_unlock_bh(&req->lock);
+}
diff --git a/net/tipc/discover.h b/net/tipc/discover.h
index 07f3472..515b573 100644
--- a/net/tipc/discover.h
+++ b/net/tipc/discover.h
@@ -41,6 +41,7 @@ struct tipc_link_req;
 
 int tipc_disc_create(struct tipc_bearer *b_ptr, struct tipc_media_addr *dest);
 void tipc_disc_delete(struct tipc_link_req *req);
+void tipc_disc_reset(struct tipc_bearer *b_ptr);
 void tipc_disc_add_dest(struct tipc_link_req *req);
 void tipc_disc_remove_dest(struct tipc_link_req *req);
 void tipc_disc_rcv(struct sk_buff *buf, struct tipc_bearer *b_ptr);
-- 
1.7.9.5


------------------------------------------------------------------------------
Start Your Social Network Today - Download eXo Platform
Build your Enterprise Intranet with eXo Platform Software
Java Based Open Source Intranet - Social, Extensible, Cloud Ready
Get Started Now And Turn Your Intranet Into A Collaboration Platform
http://p.sf.net/sfu/ExoPlatform
