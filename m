From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 19/26] tipc: Correct misnamed references to neighbor discovery domain
Date: Sun, 13 Mar 2011 17:34:07 -0400
Message-ID: <1300052054-7531-20-git-send-email-paul.gortmaker@windriver.com>
References: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, Allan.Stephens@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:49925 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932245Ab1CMVez (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Mar 2011 17:34:55 -0400
In-Reply-To: <1300052054-7531-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Renames items that are improperly labelled as "network scope" items
(which are represented by simple integer values) rather than "network
domain" items (which are represented by <Z.C.N>-type network addresses).
This change is purely cosmetic, and does not affect the operation of TIPC.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 include/linux/tipc_config.h |    2 +-
 net/tipc/bearer.c           |   14 +++++++-------
 net/tipc/bearer.h           |    2 +-
 net/tipc/config.c           |    2 +-
 4 files changed, 10 insertions(+), 10 deletions(-)

diff --git a/include/linux/tipc_config.h b/include/linux/tipc_config.h
index 64aba5a..0db2395 100644
--- a/include/linux/tipc_config.h
+++ b/include/linux/tipc_config.h
@@ -202,7 +202,7 @@ struct tipc_link_info {
 
 struct tipc_bearer_config {
 	__be32 priority;		/* Range [1,31]. Override per link  */
-	__be32 detect_scope;
+	__be32 disc_domain;		/* <Z.C.N> describing desired nodes */
 	char name[TIPC_MAX_BEARER_NAME];
 };
 
diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index f2839b0..9815797 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -474,7 +474,7 @@ int tipc_bearer_congested(struct tipc_bearer *b_ptr, struct link *l_ptr)
  * tipc_enable_bearer - enable bearer with the given name
  */
 
-int tipc_enable_bearer(const char *name, u32 bcast_scope, u32 priority)
+int tipc_enable_bearer(const char *name, u32 disc_domain, u32 priority)
 {
 	struct tipc_bearer *b_ptr;
 	struct media *m_ptr;
@@ -494,9 +494,9 @@ int tipc_enable_bearer(const char *name, u32 bcast_scope, u32 priority)
 		warn("Bearer <%s> rejected, illegal name\n", name);
 		return -EINVAL;
 	}
-	if (!tipc_addr_domain_valid(bcast_scope) ||
-	    !tipc_in_scope(bcast_scope, tipc_own_addr)) {
-		warn("Bearer <%s> rejected, illegal broadcast scope\n", name);
+	if (!tipc_addr_domain_valid(disc_domain) ||
+	    !tipc_in_scope(disc_domain, tipc_own_addr)) {
+		warn("Bearer <%s> rejected, illegal discovery domain\n", name);
 		return -EINVAL;
 	}
 	if ((priority < TIPC_MIN_LINK_PRI ||
@@ -560,18 +560,18 @@ restart:
 	b_ptr->media = m_ptr;
 	b_ptr->net_plane = bearer_id + 'A';
 	b_ptr->active = 1;
-	b_ptr->detect_scope = bcast_scope;
+	b_ptr->detect_scope = disc_domain;
 	b_ptr->priority = priority;
 	INIT_LIST_HEAD(&b_ptr->cong_links);
 	INIT_LIST_HEAD(&b_ptr->links);
 	if (m_ptr->bcast) {
 		b_ptr->link_req = tipc_disc_init_link_req(b_ptr, &m_ptr->bcast_addr,
-							  bcast_scope);
+							  disc_domain);
 	}
 	spin_lock_init(&b_ptr->lock);
 	write_unlock_bh(&tipc_net_lock);
 	info("Enabled bearer <%s>, discovery domain %s, priority %u\n",
-	     name, tipc_addr_string_fill(addr_string, bcast_scope), priority);
+	     name, tipc_addr_string_fill(addr_string, disc_domain), priority);
 	return 0;
 failed:
 	write_unlock_bh(&tipc_net_lock);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 255dea6..adebdaf 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -167,7 +167,7 @@ void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 int  tipc_block_bearer(const char *name);
 void tipc_continue(struct tipc_bearer *tb_ptr);
 
-int tipc_enable_bearer(const char *bearer_name, u32 bcast_scope, u32 priority);
+int tipc_enable_bearer(const char *bearer_name, u32 disc_domain, u32 priority);
 int tipc_disable_bearer(const char *name);
 
 /*
diff --git a/net/tipc/config.c b/net/tipc/config.c
index fa3d508..b25a396 100644
--- a/net/tipc/config.c
+++ b/net/tipc/config.c
@@ -148,7 +148,7 @@ static struct sk_buff *cfg_enable_bearer(void)
 
 	args = (struct tipc_bearer_config *)TLV_DATA(req_tlv_area);
 	if (tipc_enable_bearer(args->name,
-			       ntohl(args->detect_scope),
+			       ntohl(args->disc_domain),
 			       ntohl(args->priority)))
 		return tipc_cfg_reply_error_string("unable to enable bearer");
 
-- 
1.7.3.3

