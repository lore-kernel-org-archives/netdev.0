From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 06/23] tipc: Improve handling of media address printing errors
Date: Tue, 27 Dec 2011 12:39:25 -0500
Message-ID: <1325007582-31610-7-git-send-email-paul.gortmaker@windriver.com>
References: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:39377 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754758Ab1L0Rj6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 27 Dec 2011 12:39:58 -0500
In-Reply-To: <1325007582-31610-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Enhances conversion of a media address to printable form so that an
unconvertable address will be displayed as a string of hex digits,
rather than not being displayed at all. (Also removes a pointless check
for the existence of the media-specific address conversion routine,
since the routine is not optional.)

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/bearer.c    |   12 +++++-------
 net/tipc/bearer.h    |    3 +--
 net/tipc/eth_media.c |   12 ++++++------
 3 files changed, 12 insertions(+), 15 deletions(-)

diff --git a/net/tipc/bearer.c b/net/tipc/bearer.c
index f908b80..17652f2 100644
--- a/net/tipc/bearer.c
+++ b/net/tipc/bearer.c
@@ -136,20 +136,18 @@ exit:
 
 void tipc_media_addr_printf(struct print_buf *pb, struct tipc_media_addr *a)
 {
+	char addr_str[MAX_ADDR_STR];
 	struct media *m_ptr;
 	u32 media_type;
-	u32 i;
 
 	media_type = ntohl(a->type);
 	m_ptr = media_find_id(media_type);
 
-	if (m_ptr && (m_ptr->addr2str != NULL)) {
-		char addr_str[MAX_ADDR_STR];
-
-		tipc_printf(pb, "%s(%s)", m_ptr->name,
-			    m_ptr->addr2str(a, addr_str, sizeof(addr_str)));
-	} else {
+	if (m_ptr && !m_ptr->addr2str(a, addr_str, sizeof(addr_str)))
+		tipc_printf(pb, "%s(%s)", m_ptr->name, addr_str);
+	else {
 		unchar *addr = (unchar *)&a->dev_addr;
+		u32 i;
 
 		tipc_printf(pb, "UNKNOWN(%u)", media_type);
 		for (i = 0; i < (sizeof(*a) - sizeof(a->type)); i++)
diff --git a/net/tipc/bearer.h b/net/tipc/bearer.h
index 148ed04..4e9367f 100644
--- a/net/tipc/bearer.h
+++ b/net/tipc/bearer.h
@@ -83,8 +83,7 @@ struct media {
 			struct tipc_media_addr *dest);
 	int (*enable_bearer)(struct tipc_bearer *b_ptr);
 	void (*disable_bearer)(struct tipc_bearer *b_ptr);
-	char *(*addr2str)(struct tipc_media_addr *a,
-			  char *str_buf, int str_size);
+	int (*addr2str)(struct tipc_media_addr *a, char *str_buf, int str_size);
 	struct tipc_media_addr bcast_addr;
 	u32 priority;
 	u32 tolerance;
diff --git a/net/tipc/eth_media.c b/net/tipc/eth_media.c
index 15c685b..67f616a 100644
--- a/net/tipc/eth_media.c
+++ b/net/tipc/eth_media.c
@@ -243,15 +243,15 @@ static int recv_notification(struct notifier_block *nb, unsigned long evt,
  * eth_addr2str - convert Ethernet address to string
  */
 
-static char *eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
+static int eth_addr2str(struct tipc_media_addr *a, char *str_buf, int str_size)
 {
 	unchar *addr = (unchar *)&a->dev_addr;
 
-	if (str_size < 18)
-		*str_buf = '\0';
-	else
-		sprintf(str_buf, "%pM", addr);
-	return str_buf;
+	if (str_size < 18)	/* 18 = strlen("aa:bb:cc:dd:ee:ff\0") */
+		return 1;
+
+	sprintf(str_buf, "%pM", addr);
+	return 0;
 }
 
 /*
-- 
1.7.4.4
