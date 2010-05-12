From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 16/16] tipc: Reduce footprint by un-inlining tipc_msg_* routines
Date: Tue, 11 May 2010 20:30:18 -0400
Message-ID: <79d1887b83b86ff06f0d0e8677c654c33fabf6af.1273621271.git.paul.gortmaker@windriver.com>
References: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
Cc: allan.stephens@windriver.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:35273 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754205Ab0ELAag (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 11 May 2010 20:30:36 -0400
Received: from ALA-MAIL03.corp.ad.wrs.com (ala-mail03 [147.11.57.144])
	by mail.windriver.com (8.14.3/8.14.3) with ESMTP id o4C0UYPR000152
	for <netdev@vger.kernel.org>; Tue, 11 May 2010 17:30:35 -0700 (PDT)
In-Reply-To: <1273624218-22514-1-git-send-email-paul.gortmaker@windriver.com>
In-Reply-To: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
References: <f90800f460df4ef216412e83e148771d2b6a7183.1273621271.git.paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Convert tipc_msg_* inline routines that are more than one line into
standard functions, thereby eliminating some repeated code.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/msg.c |   94 +++++++++++++++++++++++++++++++++++++++++++++++++++++
 net/tipc/msg.h |   99 +++----------------------------------------------------
 2 files changed, 100 insertions(+), 93 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 73dcd00..3810638 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -40,6 +40,100 @@
 #include "msg.h"
 #include "bearer.h"
 
+u32 tipc_msg_tot_importance(struct tipc_msg *m)
+{
+	if (likely(msg_isdata(m))) {
+		if (likely(msg_orignode(m) == tipc_own_addr))
+			return msg_importance(m);
+		return msg_importance(m) + 4;
+	}
+	if ((msg_user(m) == MSG_FRAGMENTER)  &&
+	    (msg_type(m) == FIRST_FRAGMENT))
+		return msg_importance(msg_get_wrapped(m));
+	return msg_importance(m);
+}
+
+
+void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
+			    u32 hsize, u32 destnode)
+{
+	memset(m, 0, hsize);
+	msg_set_version(m);
+	msg_set_user(m, user);
+	msg_set_hdr_sz(m, hsize);
+	msg_set_size(m, hsize);
+	msg_set_prevnode(m, tipc_own_addr);
+	msg_set_type(m, type);
+	if (!msg_short(m)) {
+		msg_set_orignode(m, tipc_own_addr);
+		msg_set_destnode(m, destnode);
+	}
+}
+
+/**
+ * tipc_msg_calc_data_size - determine total data size for message
+ */
+
+int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
+{
+	int dsz = 0;
+	int i;
+
+	for (i = 0; i < num_sect; i++)
+		dsz += msg_sect[i].iov_len;
+	return dsz;
+}
+
+/**
+ * tipc_msg_build - create message using specified header and data
+ *
+ * Note: Caller must not hold any locks in case copy_from_user() is interrupted!
+ *
+ * Returns message data size or errno
+ */
+
+int tipc_msg_build(struct tipc_msg *hdr,
+			    struct iovec const *msg_sect, u32 num_sect,
+			    int max_size, int usrmem, struct sk_buff** buf)
+{
+	int dsz, sz, hsz, pos, res, cnt;
+
+	dsz = tipc_msg_calc_data_size(msg_sect, num_sect);
+	if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
+		*buf = NULL;
+		return -EINVAL;
+	}
+
+	pos = hsz = msg_hdr_sz(hdr);
+	sz = hsz + dsz;
+	msg_set_size(hdr, sz);
+	if (unlikely(sz > max_size)) {
+		*buf = NULL;
+		return dsz;
+	}
+
+	*buf = buf_acquire(sz);
+	if (!(*buf))
+		return -ENOMEM;
+	skb_copy_to_linear_data(*buf, hdr, hsz);
+	for (res = 1, cnt = 0; res && (cnt < num_sect); cnt++) {
+		if (likely(usrmem))
+			res = !copy_from_user((*buf)->data + pos,
+					      msg_sect[cnt].iov_base,
+					      msg_sect[cnt].iov_len);
+		else
+			skb_copy_to_linear_data_offset(*buf, pos,
+						       msg_sect[cnt].iov_base,
+						       msg_sect[cnt].iov_len);
+		pos += msg_sect[cnt].iov_len;
+	}
+	if (likely(res))
+		return dsz;
+
+	buf_discard(*buf);
+	*buf = NULL;
+	return -EFAULT;
+}
 
 #ifdef CONFIG_TIPC_DEBUG
 
diff --git a/net/tipc/msg.h b/net/tipc/msg.h
index fbcd46f..995d2da 100644
--- a/net/tipc/msg.h
+++ b/net/tipc/msg.h
@@ -708,100 +708,13 @@ static inline void msg_set_dataoctet(struct tipc_msg *m, u32 pos)
 #define DSC_REQ_MSG          0
 #define DSC_RESP_MSG         1
 
-static inline u32 tipc_msg_tot_importance(struct tipc_msg *m)
-{
-	if (likely(msg_isdata(m))) {
-		if (likely(msg_orignode(m) == tipc_own_addr))
-			return msg_importance(m);
-		return msg_importance(m) + 4;
-	}
-	if ((msg_user(m) == MSG_FRAGMENTER)  &&
-	    (msg_type(m) == FIRST_FRAGMENT))
-		return msg_importance(msg_get_wrapped(m));
-	return msg_importance(m);
-}
-
-
-static inline void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
-			    u32 hsize, u32 destnode)
-{
-	memset(m, 0, hsize);
-	msg_set_version(m);
-	msg_set_user(m, user);
-	msg_set_hdr_sz(m, hsize);
-	msg_set_size(m, hsize);
-	msg_set_prevnode(m, tipc_own_addr);
-	msg_set_type(m, type);
-	if (!msg_short(m)) {
-		msg_set_orignode(m, tipc_own_addr);
-		msg_set_destnode(m, destnode);
-	}
-}
-
-/**
- * tipc_msg_calc_data_size - determine total data size for message
- */
-
-static inline int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect)
-{
-	int dsz = 0;
-	int i;
-
-	for (i = 0; i < num_sect; i++)
-		dsz += msg_sect[i].iov_len;
-	return dsz;
-}
-
-/**
- * tipc_msg_build - create message using specified header and data
- *
- * Note: Caller must not hold any locks in case copy_from_user() is interrupted!
- *
- * Returns message data size or errno
- */
-
-static inline int tipc_msg_build(struct tipc_msg *hdr,
+u32 tipc_msg_tot_importance(struct tipc_msg *m);
+void tipc_msg_init(struct tipc_msg *m, u32 user, u32 type,
+			    u32 hsize, u32 destnode);
+int tipc_msg_calc_data_size(struct iovec const *msg_sect, u32 num_sect);
+int tipc_msg_build(struct tipc_msg *hdr,
 			    struct iovec const *msg_sect, u32 num_sect,
-			    int max_size, int usrmem, struct sk_buff** buf)
-{
-	int dsz, sz, hsz, pos, res, cnt;
-
-	dsz = tipc_msg_calc_data_size(msg_sect, num_sect);
-	if (unlikely(dsz > TIPC_MAX_USER_MSG_SIZE)) {
-		*buf = NULL;
-		return -EINVAL;
-	}
-
-	pos = hsz = msg_hdr_sz(hdr);
-	sz = hsz + dsz;
-	msg_set_size(hdr, sz);
-	if (unlikely(sz > max_size)) {
-		*buf = NULL;
-		return dsz;
-	}
-
-	*buf = buf_acquire(sz);
-	if (!(*buf))
-		return -ENOMEM;
-	skb_copy_to_linear_data(*buf, hdr, hsz);
-	for (res = 1, cnt = 0; res && (cnt < num_sect); cnt++) {
-		if (likely(usrmem))
-			res = !copy_from_user((*buf)->data + pos,
-					      msg_sect[cnt].iov_base,
-					      msg_sect[cnt].iov_len);
-		else
-			skb_copy_to_linear_data_offset(*buf, pos,
-						       msg_sect[cnt].iov_base,
-						       msg_sect[cnt].iov_len);
-		pos += msg_sect[cnt].iov_len;
-	}
-	if (likely(res))
-		return dsz;
-
-	buf_discard(*buf);
-	*buf = NULL;
-	return -EFAULT;
-}
+			    int max_size, int usrmem, struct sk_buff** buf);
 
 static inline void msg_set_media_addr(struct tipc_msg *m, struct tipc_media_addr *a)
 {
-- 
1.7.1.rc2

