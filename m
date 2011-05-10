From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 14/21] tipc: Strengthen checks for neighboring node discovery
Date: Tue, 10 May 2011 16:44:30 -0400
Message-ID: <1305060277-15600-15-git-send-email-paul.gortmaker@windriver.com>
References: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:52416 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752687Ab1EJUpH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 10 May 2011 16:45:07 -0400
In-Reply-To: <1305060277-15600-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances existing checks on the discovery domain associated with a TIPC
bearer. A bearer can no longer be configured to accept links from itself
only (which would be pointless), or to nodes outside its own cluster
(since multi-cluster support has now been removed from TIPC). Also, the
neighbor discovery routine now validates link setup requests against the
configured discovery domain for the bearer, rather than simply ensuring
the requesting node belongs to the node's own cluster.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c   |   11 +++++++++--
 net/tipc/discover.c |    7 +++++--
 2 files changed, 14 insertions(+), 4 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 411719f..f7c29af 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -493,8 +493,15 @@ int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 		warn("Bearer <%s> rejected, illegal name\n", name);
 		return -EINVAL;
 	}
-	if (!tipc_addr_domain_valid(disc_domain) ||
-	    !tipc_in_scope(disc_domain, tipc_own_addr)) {
+	if (tipc_addr_domain_valid(disc_domain) &&
+	    (disc_domain != tipc_own_addr)) {
+		if (tipc_in_scope(disc_domain, tipc_own_addr)) {
+			disc_domain = tipc_own_addr & TIPC_CLUSTER_MASK;
+			res = 0;   /* accept any node in own cluster */
+		} else if (in_own_cluster(disc_domain))
+			res = 0;   /* accept specified node in own cluster */
+	}
+	if (res) {
 		warn("Bearer <%s> rejected, illegal discovery domain\n", name);
 		return -EINVAL;
 	}
diff --git a/net/tipc/discover.c b/net/tipc/discover.c
index 491eff5..d2163bd 100644
--- a/net/tipc/discover.c
+++ b/net/tipc/discover.c
@@ -52,6 +52,7 @@
  * struct link_req - information about an ongoing link setup request
  * @bearer: bearer issuing requests
  * @dest: destination address for request messages
+ * @domain: network domain to which links can be established
  * @buf: request message to be (repeatedly) sent
  * @timer: timer governing period between requests
  * @timer_intv: current interval between requests (in ms)
@@ -59,6 +60,7 @@
 struct link_req {
 	struct tipc_bearer *bearer;
 	struct tipc_media_addr dest;
+	u32 domain;
 	struct sk_buff *buf;
 	struct timer_list timer;
 	unsigned int timer_intv;
@@ -147,7 +149,7 @@ void tipc_disc_recv_msg(struct sk_buff *buf, struct tipc_bearer *b_ptr)
 	}
 	if (!tipc_in_scope(dest, tipc_own_addr))
 		return;
-	if (!in_own_cluster(orig))
+	if (!tipc_in_scope(b_ptr->link_req->domain, orig))
 		return;
 
 	/* Locate structure corresponding to requesting node */
@@ -287,7 +289,7 @@ static void disc_timeout(struct link_req *req)
  * tipc_disc_init_link_req - start sending periodic link setup requests
  * @b_ptr: ptr to bearer issuing requests
  * @dest: destination address for request messages
- * @dest_domain: network domain of node(s) which should respond to message
+ * @dest_domain: network domain to which links can be established
  *
  * Returns pointer to link request structure, or NULL if unable to create.
  */
@@ -310,6 +312,7 @@ struct link_req *tipc_disc_init_link_req(struct tipc_bearer *b_ptr,
 
 	memcpy(&req->dest, dest, sizeof(*dest));
 	req->bearer = b_ptr;
+	req->domain = dest_domain;
 	req->timer_intv = TIPC_LINK_REQ_INIT;
 	k_init_timer(&req->timer, (Handler)disc_timeout, (unsigned long)req);
 	k_start_timer(&req->timer, req->timer_intv);
-- 
1.7.4.4

