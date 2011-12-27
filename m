From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 02/23] tipc: Register new media using pre-compiled structure
Date: Tue, 27 Dec 2011 12:39:21 -0500
Message-ID: <1325007582-31610-3-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39363 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab1L0Rjy (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:54 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Speeds up the registration of TIPC media types by passing in a structure
containing the required information, rather than by passing in the various
fields describing the media type individually.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c    |   70 ++++++++++++++++++--------------------------------
 net/tipc/bearer.h    |   11 +-------
 net/tipc/eth_media.c |   30 +++++++++++++--------
 3 files changed, 45 insertions(+), 66 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index e2202de..75af271 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -86,21 +86,8 @@ static struct media *media_find(const char *name)
  * Bearers for this media type must be activated separately at a later stage.
  */
 
-int  tipc_register_media(u32 media_type,
-			 char *name,
-			 int (*enable)(struct tipc_bearer *),
-			 void (*disable)(struct tipc_bearer *),
-			 int (*send_msg)(struct sk_buff *,
-					 struct tipc_bearer *,
-					 struct tipc_media_addr *),
-			 char *(*addr2str)(struct tipc_media_addr *a,
-					   char *str_buf, int str_size),
-			 struct tipc_media_addr *bcast_addr,
-			 const u32 bearer_priority,
-			 const u32 link_tolerance,  /* [ms] */
-			 const u32 send_window_limit)
+int  tipc_register_media(struct media *m_ptr)
 {
-	struct media *m_ptr;
 	u32 media_id;
 	u32 i;
 	int res = -EINVAL;
@@ -108,62 +95,55 @@ int  tipc_register_media(u32 media_type,
 	write_lock_bh(&tipc_net_lock);
 
 	if (tipc_mode != TIPC_NET_MODE) {
-		warn("Media <%s> rejected, not in networked mode yet\n", name);
+		warn("Media <%s> rejected, not in networked mode yet\n",
+		     m_ptr->name);
 		goto exit;
 	}
-	if (!media_name_valid(name)) {
-		warn("Media <%s> rejected, illegal name\n", name);
+	if (!media_name_valid(m_ptr->name)) {
+		warn("Media <%s> rejected, illegal name\n", m_ptr->name);
 		goto exit;
 	}
-	if (!bcast_addr) {
-		warn("Media <%s> rejected, no broadcast address\n", name);
+	if (m_ptr->bcast_addr.type != htonl(m_ptr->type_id)) {
+		warn("Media <%s> rejected, illegal broadcast address\n",
+		     m_ptr->name);
 		goto exit;
 	}
-	if ((bearer_priority < TIPC_MIN_LINK_PRI) ||
-	    (bearer_priority > TIPC_MAX_LINK_PRI)) {
-		warn("Media <%s> rejected, illegal priority (%u)\n", name,
-		     bearer_priority);
+	if ((m_ptr->priority < TIPC_MIN_LINK_PRI) ||
+	    (m_ptr->priority > TIPC_MAX_LINK_PRI)) {
+		warn("Media <%s> rejected, illegal priority (%u)\n",
+		     m_ptr->name, m_ptr->priority);
 		goto exit;
 	}
-	if ((link_tolerance < TIPC_MIN_LINK_TOL) ||
-	    (link_tolerance > TIPC_MAX_LINK_TOL)) {
-		warn("Media <%s> rejected, illegal tolerance (%u)\n", name,
-		     link_tolerance);
+	if ((m_ptr->tolerance < TIPC_MIN_LINK_TOL) ||
+	    (m_ptr->tolerance > TIPC_MAX_LINK_TOL)) {
+		warn("Media <%s> rejected, illegal tolerance (%u)\n",
+		     m_ptr->name, m_ptr->tolerance);
 		goto exit;
 	}
 
 	media_id = media_count++;
 	if (media_id >= MAX_MEDIA) {
-		warn("Media <%s> rejected, media limit reached (%u)\n", name,
-		     MAX_MEDIA);
+		warn("Media <%s> rejected, media limit reached (%u)\n",
+		     m_ptr->name, MAX_MEDIA);
 		media_count--;
 		goto exit;
 	}
 	for (i = 0; i < media_id; i++) {
-		if (media_list[i].type_id == media_type) {
-			warn("Media <%s> rejected, duplicate type (%u)\n", name,
-			     media_type);
+		if (media_list[i].type_id == m_ptr->type_id) {
+			warn("Media <%s> rejected, duplicate type (%u)\n",
+			     m_ptr->name, m_ptr->type_id);
 			media_count--;
 			goto exit;
 		}
-		if (!strcmp(name, media_list[i].name)) {
-			warn("Media <%s> rejected, duplicate name\n", name);
+		if (!strcmp(m_ptr->name, media_list[i].name)) {
+			warn("Media <%s> rejected, duplicate name\n",
+			     m_ptr->name);
 			media_count--;
 			goto exit;
 		}
 	}
 
-	m_ptr = &media_list[media_id];
-	m_ptr->type_id = media_type;
-	m_ptr->send_msg = send_msg;
-	m_ptr->enable_bearer = enable;
-	m_ptr->disable_bearer = disable;
-	m_ptr->addr2str = addr2str;
-	memcpy(&m_ptr->bcast_addr, bcast_addr, sizeof(*bcast_addr));
-	strcpy(m_ptr->name, name);
-	m_ptr->priority = bearer_priority;
-	m_ptr->tolerance = link_tolerance;
-	m_ptr->window = send_window_limit;
+	media_list[media_id] = *m_ptr;
 	res = 0;
 exit:
 	write_unlock_bh(&tipc_net_lock);
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index d696f9e..148ed04 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -145,16 +145,7 @@ extern struct tipc_bearer tipc_bearers[];
 /*
  * TIPC routines available to supported media types
  */
-int tipc_register_media(u32 media_type,
-		 char *media_name, int (*enable)(struct tipc_bearer *),
-		 void (*disable)(struct tipc_bearer *),
-		 int (*send_msg)(struct sk_buff *,
-			struct tipc_bearer *, struct tipc_media_addr *),
-		 char *(*addr2str)(struct tipc_media_addr *a,
-			char *str_buf, int str_size),
-		 struct tipc_media_addr *bcast_addr, const u32 bearer_priority,
-		 const u32 link_tolerance,  /* [ms] */
-		 const u32 send_window_limit);
+int tipc_register_media(struct media *m_ptr);
 
 void tipc_recv_msg(struct sk_buff *buf, struct tipc_bearer *tb_ptr);
 
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index e728d4c..15c685b 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -38,9 +38,6 @@
 #include "bearer.h"
 
 #define MAX_ETH_BEARERS		MAX_BEARERS
-#define ETH_LINK_PRIORITY	TIPC_DEF_LINK_PRI
-#define ETH_LINK_TOLERANCE	TIPC_DEF_LINK_TOL
-#define ETH_LINK_WINDOW		TIPC_DEF_LINK_WIN
 
 /**
  * struct eth_bearer - Ethernet bearer data structure
@@ -257,6 +254,24 @@ static char *eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size
 	return str_buf;
 }
 
+/*
+ * Ethernet media registration info
+ */
+
+static struct media eth_media_info = {
+	.send_msg	= send_msg,
+	.enable_bearer	= enable_bearer,
+	.disable_bearer	= disable_bearer,
+	.addr2str	= eth_addr2str,
+	.bcast_addr	= { htonl(TIPC_MEDIA_TYPE_ETH),
+			    { {0xff, 0xff, 0xff, 0xff, 0xff, 0xff} } },
+	.priority	= TIPC_DEF_LINK_PRI,
+	.tolerance	= TIPC_DEF_LINK_TOL,
+	.window		= TIPC_DEF_LINK_WIN,
+	.type_id	= TIPC_MEDIA_TYPE_ETH,
+	.name		= "eth"
+};
+
 /**
  * tipc_eth_media_start - activate Ethernet bearer support
  *
@@ -266,21 +281,14 @@ static char *eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size
 
 int tipc_eth_media_start(void)
 {
-	struct tipc_media_addr bcast_addr;
 	int res;
 
 	if (eth_started)
 		return -EINVAL;
 
-	bcast_addr.type = htonl(TIPC_MEDIA_TYPE_ETH);
-	memset(&bcast_addr.dev_addr, 0xff, ETH_ALEN);
-
 	memset(eth_bearers, 0, sizeof(eth_bearers));
 
-	res = tipc_register_media(TIPC_MEDIA_TYPE_ETH, "eth",
-				  enable_bearer, disable_bearer, send_msg,
-				  eth_addr2str, &bcast_addr, ETH_LINK_PRIORITY,
-				  ETH_LINK_TOLERANCE, ETH_LINK_WINDOW);
+	res = tipc_register_media(&eth_media_info);
 	if (res)
 		return res;
 
-- 
1.7.4.4
