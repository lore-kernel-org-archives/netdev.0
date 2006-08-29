From: paul.moore@hp.com
Subject: [PATCH 4/6] NetLabel: cleanup ebitmap_import()
Date: Tue, 29 Aug 2006 10:42:55 -0400
Message-ID: <20060829144446.324001000@hp.com>
References: <20060829144251.452774000@hp.com>
Cc: jmorris@namei.org, sds@tycho.nsa.gov, akpm@osdl.org,
	Paul Moore <paul.moore@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel9.hp.com ([156.153.255.214]:63950 "EHLO atlrel9.hp.com")
	by vger.kernel.org with ESMTP id S965012AbWH2Oos (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Aug 2006 10:44:48 -0400
To: netdev@vger.kernel.org, selinux@tycho.nsa.gov
Content-Disposition: inline; filename=netlabel-loop_fixups
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Rewrite ebitmap_import() so it is a bit cleaner and easier to read.

Signed-off-by: Paul Moore <paul.moore@hp.com>
---
 security/selinux/ss/ebitmap.c |   36 ++++++++++++++++--------------------
 1 files changed, 16 insertions(+), 20 deletions(-)

Index: net-2.6.19/security/selinux/ss/ebitmap.c
===================================================================
--- net-2.6.19.orig/security/selinux/ss/ebitmap.c
+++ net-2.6.19/security/selinux/ss/ebitmap.c
@@ -145,29 +145,28 @@ int ebitmap_import(const unsigned char *
 		   struct ebitmap *dst)
 {
 	size_t src_off = 0;
+	size_t node_limit;
 	struct ebitmap_node *node_new;
 	struct ebitmap_node *node_last = NULL;
-	size_t iter;
-	size_t iter_bit;
-	size_t iter_limit;
+	u32 i_byte;
+	u32 i_bit;
 	unsigned char src_byte;
 
-	do {
-		iter_limit = src_len - src_off;
-		if (iter_limit >= sizeof(MAPTYPE)) {
+	while (src_off < src_len) {
+		if (src_len - src_off >= sizeof(MAPTYPE)) {
 			if (*(MAPTYPE *)&src[src_off] == 0) {
 				src_off += sizeof(MAPTYPE);
 				continue;
 			}
-			iter_limit = sizeof(MAPTYPE);
+			node_limit = sizeof(MAPTYPE);
 		} else {
-			iter = src_off;
-			src_byte = 0;
-			do {
-				src_byte |= src[iter++];
-			} while (iter < src_len && src_byte == 0);
+			for (src_byte = 0, i_byte = src_off;
+			     i_byte < src_len && src_byte == 0;
+			     i_byte++)
+				src_byte |= src[i_byte];
 			if (src_byte == 0)
 				break;
+			node_limit = src_len - src_off;
 		}
 
 		node_new = kzalloc(sizeof(*node_new), GFP_ATOMIC);
@@ -176,24 +175,21 @@ int ebitmap_import(const unsigned char *
 			return -ENOMEM;
 		}
 		node_new->startbit = src_off * 8;
-		iter = 0;
-		do {
+		for (i_byte = 0; i_byte < node_limit; i_byte++) {
 			src_byte = src[src_off++];
-			iter_bit = iter++ * 8;
-			while (src_byte != 0) {
+			for (i_bit = i_byte * 8; src_byte != 0; i_bit++) {
 				if (src_byte & 0x80)
-					node_new->map |= MAPBIT << iter_bit;
-				iter_bit++;
+					node_new->map |= MAPBIT << i_bit;
 				src_byte <<= 1;
 			}
-		} while (iter < iter_limit);
+		}
 
 		if (node_last != NULL)
 			node_last->next = node_new;
 		else
 			dst->node = node_new;
 		node_last = node_new;
-	} while (src_off < src_len);
+	}
 
 	if (likely(node_last != NULL))
 		dst->highbit = node_last->startbit + MAPSIZE;

--
paul moore
linux security @ hp
