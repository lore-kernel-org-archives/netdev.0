From: Paul Moore <pmoore@redhat.com>
Subject: [PATCH] netlabel: handle sparse category maps in
 netlbl_catmap_getlong()
Date: Mon, 13 Jun 2016 10:16:32 -0400
Message-ID: <146582739278.15237.7893325845379293452.stgit@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	selinux@tycho.nsa.gov
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:47917 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1423525AbcFMOQe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 13 Jun 2016 10:16:34 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Paul Moore <paul@paul-moore.com>

In cases where the category bitmap is sparse enough that gaps exist
between netlbl_lsm_catmap structs, callers to netlbl_catmap_getlong()
could find themselves prematurely ending their search through the
category bitmap.  Further, the methods used to calculate the 'idx'
and 'off' values were incorrect for bitmaps this large.  This patch
changes the netlbl_catmap_getlong() behavior so that it always skips
over gaps and calculates the index and offset values correctly.

Signed-off-by: Paul Moore <paul@paul-moore.com>
---
 net/netlabel/netlabel_kapi.c |    9 ++++-----
 1 file changed, 4 insertions(+), 5 deletions(-)

diff --git a/net/netlabel/netlabel_kapi.c b/net/netlabel/netlabel_kapi.c
index bd007a9..3c070f2 100644
--- a/net/netlabel/netlabel_kapi.c
+++ b/net/netlabel/netlabel_kapi.c
@@ -609,20 +609,19 @@ int netlbl_catmap_getlong(struct netlbl_lsm_catmap *catmap,
 		off = catmap->startbit;
 		*offset = off;
 	}
-	iter = _netlbl_catmap_getnode(&catmap, off, _CM_F_NONE, 0);
+	iter = _netlbl_catmap_getnode(&catmap, off, _CM_F_WALK, 0);
 	if (iter == NULL) {
 		*offset = (u32)-1;
 		return 0;
 	}
 
 	if (off < iter->startbit) {
-		off = iter->startbit;
-		*offset = off;
+		*offset = iter->startbit;
+		off = 0;
 	} else
 		off -= iter->startbit;
-
 	idx = off / NETLBL_CATMAP_MAPSIZE;
-	*bitmap = iter->bitmap[idx] >> (off % NETLBL_CATMAP_SIZE);
+	*bitmap = iter->bitmap[idx] >> (off % NETLBL_CATMAP_MAPSIZE);
 
 	return 0;
 }
