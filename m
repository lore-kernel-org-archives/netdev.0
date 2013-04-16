From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net-next 1/9] net: sctp: sctp_ssnmap: remove 'malloced' element from struct
Date: Tue, 16 Apr 2013 23:07:10 +0200
Message-ID: <1366146438-8815-2-git-send-email-dborkman@redhat.com>
References: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, linux-sctp@vger.kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:5636 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S965213Ab3DPVHY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 16 Apr 2013 17:07:24 -0400
In-Reply-To: <1366146438-8815-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

sctp_ssnmap_init() can only be called from sctp_ssnmap_new()
where malloced is always set to 1. Thus, when we call
sctp_ssnmap_free() the test for map->malloced evaluates always
to true.

Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 include/net/sctp/structs.h |  1 -
 net/sctp/ssnmap.c          | 23 ++++++++++++-----------
 2 files changed, 12 insertions(+), 12 deletions(-)

diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index e12aa77..3c1bb8d 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -399,7 +399,6 @@ struct sctp_stream {
 struct sctp_ssnmap {
 	struct sctp_stream in;
 	struct sctp_stream out;
-	int malloced;
 };
 
 struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
diff --git a/net/sctp/ssnmap.c b/net/sctp/ssnmap.c
index 825ea94..da86035 100644
--- a/net/sctp/ssnmap.c
+++ b/net/sctp/ssnmap.c
@@ -74,7 +74,6 @@ struct sctp_ssnmap *sctp_ssnmap_new(__u16 in, __u16 out,
 	if (!sctp_ssnmap_init(retval, in, out))
 		goto fail_map;
 
-	retval->malloced = 1;
 	SCTP_DBG_OBJCNT_INC(ssnmap);
 
 	return retval;
@@ -118,14 +117,16 @@ void sctp_ssnmap_clear(struct sctp_ssnmap *map)
 /* Dispose of a ssnmap.  */
 void sctp_ssnmap_free(struct sctp_ssnmap *map)
 {
-	if (map && map->malloced) {
-		int size;
-
-		size = sctp_ssnmap_size(map->in.len, map->out.len);
-		if (size <= KMALLOC_MAX_SIZE)
-			kfree(map);
-		else
-			free_pages((unsigned long)map, get_order(size));
-		SCTP_DBG_OBJCNT_DEC(ssnmap);
-	}
+	int size;
+
+	if (unlikely(!map))
+		return;
+
+	size = sctp_ssnmap_size(map->in.len, map->out.len);
+	if (size <= KMALLOC_MAX_SIZE)
+		kfree(map);
+	else
+		free_pages((unsigned long)map, get_order(size));
+
+	SCTP_DBG_OBJCNT_DEC(ssnmap);
 }
-- 
1.7.11.7
