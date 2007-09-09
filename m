From: Adrian Bunk <bunk@kernel.org>
Subject: [2.6 patch] make sctp_addto_param() static
Date: Sun, 9 Sep 2007 22:25:50 +0200
Message-ID: <20070909202550.GX3563@stusta.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: linux-kernel@vger.kernel.org,
	lksctp-developers@lists.sourceforge.net, netdev@vger.kernel.org
To: Wei Yongjun <yjwei@cn.fujitsu.com>,
	Vlad Yasevich <vladislav.yasevich@hp.com>, sri@us.ibm.com,
	davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mailout.stusta.mhn.de ([141.84.69.5]:60750 "EHLO
	mailhub.stusta.mhn.de" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1759535AbXIIUZn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Sep 2007 16:25:43 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

sctp_addto_param() can become static.

Signed-off-by: Adrian Bunk <bunk@kernel.org>

---

 include/net/sctp/structs.h |    1 
 net/sctp/sm_make_chunk.c   |   39 ++++++++++++++++++-------------------
 2 files changed, 20 insertions(+), 20 deletions(-)

38f8064114b9e89a6a911b2e3625a41cdb477bcd 
diff --git a/include/net/sctp/structs.h b/include/net/sctp/structs.h
index c0d5848..ee4559b 100644
--- a/include/net/sctp/structs.h
+++ b/include/net/sctp/structs.h
@@ -726,7 +726,6 @@ int sctp_user_addto_chunk(struct sctp_chunk *chunk, int off, int len,
 			  struct iovec *data);
 void sctp_chunk_free(struct sctp_chunk *);
 void  *sctp_addto_chunk(struct sctp_chunk *, int len, const void *data);
-void  *sctp_addto_param(struct sctp_chunk *, int len, const void *data);
 struct sctp_chunk *sctp_chunkify(struct sk_buff *,
 				 const struct sctp_association *,
 				 struct sock *);
diff --git a/net/sctp/sm_make_chunk.c b/net/sctp/sm_make_chunk.c
index 79856c9..cf3b560 100644
--- a/net/sctp/sm_make_chunk.c
+++ b/net/sctp/sm_make_chunk.c
@@ -839,6 +839,26 @@ err_chunk:
 	return retval;
 }
 
+/* Append bytes to the end of a parameter.  Will panic if chunk is not big
+ * enough.
+ */
+static void *sctp_addto_param(struct sctp_chunk *chunk, int len,
+			      const void *data)
+{
+	void *target;
+	int chunklen = ntohs(chunk->chunk_hdr->length);
+
+	target = skb_put(chunk->skb, len);
+
+	memcpy(target, data, len);
+
+	/* Adjust the chunk length field.  */
+	chunk->chunk_hdr->length = htons(chunklen + len);
+	chunk->chunk_end = skb_tail_pointer(chunk->skb);
+
+	return target;
+}
+
 /* Make an ABORT chunk with a PROTOCOL VIOLATION cause code. */
 struct sctp_chunk *sctp_make_abort_violation(
 	const struct sctp_association *asoc,
@@ -1146,25 +1166,6 @@ void *sctp_addto_chunk(struct sctp_chunk *chunk, int len, const void *data)
 	return target;
 }
 
-/* Append bytes to the end of a parameter.  Will panic if chunk is not big
- * enough.
- */
-void *sctp_addto_param(struct sctp_chunk *chunk, int len, const void *data)
-{
-	void *target;
-	int chunklen = ntohs(chunk->chunk_hdr->length);
-
-	target = skb_put(chunk->skb, len);
-
-	memcpy(target, data, len);
-
-	/* Adjust the chunk length field.  */
-	chunk->chunk_hdr->length = htons(chunklen + len);
-	chunk->chunk_end = skb_tail_pointer(chunk->skb);
-
-	return target;
-}
-
 /* Append bytes from user space to the end of a chunk.  Will panic if
  * chunk is not big enough.
  * Returns a kernel err value.

