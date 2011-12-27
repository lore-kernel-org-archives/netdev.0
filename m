From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 03/23] tipc: Optimize detection of duplicate media registration
Date: Tue, 27 Dec 2011 12:39:22 -0500
Message-ID: <1325007582-31610-4-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39367 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754773Ab1L0Rjz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:55 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Streamlines the detection of an attempt to register a TIPC media structure
using an already registered name or type identifier. The revised logic now
reuses an existing routine to detect an existing name and no longer
unnecessarily manipulates the media type counter during an unsuccessful
registration attempt.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   40 +++++++++++++++++++++-------------------
 1 files changed, 21 insertions(+), 19 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 75af271..9ff8920 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -81,6 +81,21 @@ static struct media *media_find(const char *name)
 }
 
 /**
+ * media_find_id - locates specified media object by type identifier
+ */
+
+static struct media *media_find_id(u8 type)
+{
+	u32 i;
+
+	for (i = 0; i < media_count; i++) {
+		if (media_list[i].type_id == type)
+			return &media_list[i];
+	}
+	return NULL;
+}
+
+/**
  * tipc_register_media - register a media type
  *
  * Bearers for this media type must be activated separately at a later stage.
@@ -88,8 +103,6 @@ static struct media *media_find(const char *name)
 
 int  tipc_register_media(struct media *m_ptr)
 {
-	u32 media_id;
-	u32 i;
 	int res = -EINVAL;
 
 	write_lock_bh(&tipc_net_lock);
@@ -121,29 +134,18 @@ int  tipc_register_media(struct media *m_ptr)
 		goto exit;
 	}
 
-	media_id = media_count++;
-	if (media_id >= MAX_MEDIA) {
+	if (media_count >= MAX_MEDIA) {
 		warn("Media <%s> rejected, media limit reached (%u)\n",
 		     m_ptr->name, MAX_MEDIA);
-		media_count--;
 		goto exit;
 	}
-	for (i = 0; i < media_id; i++) {
-		if (media_list[i].type_id == m_ptr->type_id) {
-			warn("Media <%s> rejected, duplicate type (%u)\n",
-			     m_ptr->name, m_ptr->type_id);
-			media_count--;
-			goto exit;
-		}
-		if (!strcmp(m_ptr->name, media_list[i].name)) {
-			warn("Media <%s> rejected, duplicate name\n",
-			     m_ptr->name);
-			media_count--;
-			goto exit;
-		}
+	if (media_find(m_ptr->name) || media_find_id(m_ptr->type_id)) {
+		warn("Media <%s> rejected, already registered\n", m_ptr->name);
+		goto exit;
 	}
 
-	media_list[media_id] = *m_ptr;
+	media_list[media_count] = *m_ptr;
+	media_count++;
 	res = 0;
 exit:
 	write_unlock_bh(&tipc_net_lock);
-- 
1.7.4.4
