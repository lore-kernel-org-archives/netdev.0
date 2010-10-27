From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH 2/4] tipc: Fix bugs in tipc_msg_build()
Date: Wed, 27 Oct 2010 15:29:31 -0400
Message-ID: <1288207773-25448-3-git-send-email-paul.gortmaker@windriver.com>
References: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	drosenberg@vsecurity.com, jon.maloy@ericsson.com,
	torvalds@linux-foundation.org, security@kernel.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43522 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756193Ab0J0Tdw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Oct 2010 15:33:52 -0400
In-Reply-To: <1288207773-25448-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <Allan.Stephens@windriver.com>

Enhances TIPC's creation of message buffers so that it works properly
when large amounts of data are involved. Calculations are now done
using "size_t" where needed, and comparisons no longer mix signed and
unsigned size values.

Signed-off-by: Allan Stephens <Allan.Stephens@windriver.com>
---
 net/tipc/msg.c |   25 +++++++++++++++++--------
 net/tipc/msg.h |    4 ++--
 2 files changed, 19 insertions(+), 10 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 38360a9..b67e831 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -96,27 +96,36 @@ size_t tipc_msg_calc_data_size(struct iovec const *msg_sect, size_t num_sect)
  *
  * Note: Caller must not hold any locks in case copy_from_user() is interrupted!
  *
- * Returns message data size or errno
+ * If successful, creates message buffer and returns message data size
+ * (which must be <= TIPC_MAX_USER_MSG_SIZE).
+ * If fails only because message data size exceeds the specified maximum
+ * returns message data size, but doesn't created a message buffer.
+ * If fails for any other reason returns errno and doesn't create a buffer.
  */
 
 int tipc_msg_build(struct tipc_msg *hdr,
-			    struct iovec const *msg_sect, u32 num_sect,
-			    int max_size, int usrmem, struct sk_buff** buf)
+		   struct iovec const *msg_sect, size_t num_sect,
+		   u32 max_size, int usrmem, struct sk_buff **buf)
 {
-	int dsz, sz, hsz, pos, res, cnt;
+	size_t dsz;
+	u32 hsz;
+	u32 sz;
+	size_t pos;
+	size_t cnt;
+	int res;
 
 	dsz = tipc_msg_calc_data_size(msg_sect, num_sect);
-	if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
+	if (unlikely(dsz > (size_t)TIPC_MAX_USER_MSG_SIZE)) {
 		*buf = NULL;
 		return -EINVAL;
 	}
 
 	pos = hsz = msg_hdr_sz(hdr);
-	sz = hsz + dsz;
+	sz = hsz + (u32)dsz;
 	msg_set_size(hdr, sz);
 	if (unlikely(sz > max_size)) {
 		*buf = NULL;
-		return dsz;
+		return (int)dsz;
 	}
 
 	*buf = tipc_buf_acquire(sz);
@@ -135,7 +144,7 @@ int tipc_msg_build(struct tipc_msg *hdr,
 		pos += msg_sect[cnt].iov_len;
 	}
 	if (likely(res))
-		return dsz;
+		return (int)dsz;
 
 	buf_discard(*buf);
 	*buf = NULL;
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index a132800..41fb532 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -713,8 +713,8 @@ void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
 			    u32 hsize, u32 destnode);
 size_t tipc_msg_calc_data_size(struct iovec const *msg_sect, size_t num_sect);
 int tipc_msg_build(struct tipc_msg *hdr,
-			    struct iovec const *msg_sect, u32 num_sect,
-			    int max_size, int usrmem, struct sk_buff** buf);
+		   struct iovec const *msg_sect, size_t num_sect,
+		   u32 max_size, int usrmem, struct sk_buff **buf);
 
 static inline void msg_set_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
 {
-- 
1.7.1.GIT

