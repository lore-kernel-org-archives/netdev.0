From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 04/23] tipc: Eliminate duplication of media structures
Date: Tue, 27 Dec 2011 12:39:23 -0500
Message-ID: <1325007582-31610-5-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39371 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754775Ab1L0Rj4 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:56 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Changes TIPC's list of registered media types from an array of media
structures to an array of pointers to media structures. This eliminates
the need to copy of the contents of the structure passed in during media
registration.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   35 +++++++++++++++--------------------
 1 files changed, 15 insertions(+), 20 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9ff8920..9012a36 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -41,7 +41,7 @@
 
 #define MAX_ADDR_STR 32
 
-static struct media media_list[MAX_MEDIA];
+static struct media *media_list[MAX_MEDIA];
 static u32 media_count;
 
 struct tipc_bearer tipc_bearers[MAX_BEARERS];
@@ -70,12 +70,11 @@ static int media_name_valid(const char *name)
 
 static struct media *media_find(const char *name)
 {
-	struct media *m_ptr;
 	u32 i;
 
-	for (i = 0, m_ptr = media_list; i < media_count; i++, m_ptr++) {
-		if (!strcmp(m_ptr->name, name))
-			return m_ptr;
+	for (i = 0; i < media_count; i++) {
+		if (!strcmp(media_list[i]->name, name))
+			return media_list[i];
 	}
 	return NULL;
 }
@@ -89,8 +88,8 @@ static struct media *media_find_id(u8 type)
 	u32 i;
 
 	for (i = 0; i < media_count; i++) {
-		if (media_list[i].type_id == type)
-			return &media_list[i];
+		if (media_list[i]->type_id == type)
+			return media_list[i];
 	}
 	return NULL;
 }
@@ -144,7 +143,7 @@ int  tipc_register_media(struct media *m_ptr)
 		goto exit;
 	}
 
-	media_list[media_count] = *m_ptr;
+	media_list[media_count] = m_ptr;
 	media_count++;
 	res = 0;
 exit:
@@ -163,12 +162,9 @@ void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 	u32 i;
 
 	media_type = ntohl(a->type);
-	for (i = 0, m_ptr = media_list; i < media_count; i++, m_ptr++) {
-		if (m_ptr->type_id == media_type)
-			break;
-	}
+	m_ptr = media_find_id(media_type);
 
-	if ((i < media_count) && (m_ptr->addr2str != NULL)) {
+	if (m_ptr && (m_ptr->addr2str != NULL)) {
 		char addr_str[MAX_ADDR_STR];
 
 		tipc_printf(pb, "%s(%s)", m_ptr->name,
@@ -189,7 +185,6 @@ void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 struct sk_buff *tipc_media_get_names(void)
 {
 	struct sk_buff *buf;
-	struct media *m_ptr;
 	int i;
 
 	buf = tipc_cfg_reply_alloc(MAX_MEDIA * TLV_SPACE(TIPC_MAX_MEDIA_NAME));
@@ -197,9 +192,10 @@ struct sk_buff *tipc_media_get_names(void)
 		return NULL;
 
 	read_lock_bh(&tipc_net_lock);
-	for (i = 0, m_ptr = media_list; i < media_count; i++, m_ptr++) {
-		tipc_cfg_append_tlv(buf, TIPC_TLV_MEDIA_NAME, m_ptr->name,
-				    strlen(m_ptr->name) + 1);
+	for (i = 0; i < media_count; i++) {
+		tipc_cfg_append_tlv(buf, TIPC_TLV_MEDIA_NAME,
+				    media_list[i]->name,
+				    strlen(media_list[i]->name) + 1);
 	}
 	read_unlock_bh(&tipc_net_lock);
 	return buf;
@@ -300,7 +296,6 @@ struct tipc_bearer *tipc_bearer_find_interface(const char *if_name)
 struct sk_buff *tipc_bearer_get_names(void)
 {
 	struct sk_buff *buf;
-	struct media *m_ptr;
 	struct tipc_bearer *b_ptr;
 	int i, j;
 
@@ -309,10 +304,10 @@ struct sk_buff *tipc_bearer_get_names(void)
 		return NULL;
 
 	read_lock_bh(&tipc_net_lock);
-	for (i = 0, m_ptr = media_list; i < media_count; i++, m_ptr++) {
+	for (i = 0; i < media_count; i++) {
 		for (j = 0; j < MAX_BEARERS; j++) {
 			b_ptr = &tipc_bearers[j];
-			if (b_ptr->active && (b_ptr->media == m_ptr)) {
+			if (b_ptr->active && (b_ptr->media == media_list[i])) {
 				tipc_cfg_append_tlv(buf, TIPC_TLV_BEARER_NAME,
 						    b_ptr->name,
 						    strlen(b_ptr->name) + 1);
-- 
1.7.4.4
