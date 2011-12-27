From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 05/23] tipc: Streamline media registration error checking
Date: Tue, 27 Dec 2011 12:39:24 -0500
Message-ID: <1325007582-31610-6-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39376 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754741Ab1L0Rj5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:57 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Simplifies error handling performed during media registration, since
TIPC no longer supports the dynamic addition of new media types that
are potentially error-prone. These simplifications include the following:

1) No longer check for premature registration of a new media type.
2) No longer check for negative link priority values (which was pointless
   since such values are unsigned, and could cause a compiler warning).
3) No longer generate a warning describing the exact cause of any
   registration failure (just warns that overall registration failed).

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c |   37 ++++++++-----------------------------
 1 files changed, 8 insertions(+), 29 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index 9012a36..f908b80 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -106,48 +106,27 @@ int  tipc_register_media(struct media *m_ptr)
 
 	write_lock_bh(&tipc_net_lock);
 
-	if (tipc_mode != TIPC_NET_MODE) {
-		warn("Media <%s> rejected, not in networked mode yet\n",
-		     m_ptr->name);
+	if (!media_name_valid(m_ptr->name))
 		goto exit;
-	}
-	if (!media_name_valid(m_ptr->name)) {
-		warn("Media <%s> rejected, illegal name\n", m_ptr->name);
+	if (m_ptr->bcast_addr.type != htonl(m_ptr->type_id))
 		goto exit;
-	}
-	if (m_ptr->bcast_addr.type != htonl(m_ptr->type_id)) {
-		warn("Media <%s> rejected, illegal broadcast address\n",
-		     m_ptr->name);
-		goto exit;
-	}
-	if ((m_ptr->priority < TIPC_MIN_LINK_PRI) ||
-	    (m_ptr->priority > TIPC_MAX_LINK_PRI)) {
-		warn("Media <%s> rejected, illegal priority (%u)\n",
-		     m_ptr->name, m_ptr->priority);
+	if (m_ptr->priority > TIPC_MAX_LINK_PRI)
 		goto exit;
-	}
 	if ((m_ptr->tolerance < TIPC_MIN_LINK_TOL) ||
-	    (m_ptr->tolerance > TIPC_MAX_LINK_TOL)) {
-		warn("Media <%s> rejected, illegal tolerance (%u)\n",
-		     m_ptr->name, m_ptr->tolerance);
+	    (m_ptr->tolerance > TIPC_MAX_LINK_TOL))
 		goto exit;
-	}
-
-	if (media_count >= MAX_MEDIA) {
-		warn("Media <%s> rejected, media limit reached (%u)\n",
-		     m_ptr->name, MAX_MEDIA);
+	if (media_count >= MAX_MEDIA)
 		goto exit;
-	}
-	if (media_find(m_ptr->name) || media_find_id(m_ptr->type_id)) {
-		warn("Media <%s> rejected, already registered\n", m_ptr->name);
+	if (media_find(m_ptr->name) || media_find_id(m_ptr->type_id))
 		goto exit;
-	}
 
 	media_list[media_count] = m_ptr;
 	media_count++;
 	res = 0;
 exit:
 	write_unlock_bh(&tipc_net_lock);
+	if (res)
+		warn("Media <%s> registration error\n", m_ptr->name);
 	return res;
 }
 
-- 
1.7.4.4
