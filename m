From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next v2 1/8] tipc: don't use memcpy to copy from user space
Date: Fri, 18 Oct 2013 07:23:14 +0200
Message-ID: <1382073801-22128-2-git-send-email-jon.maloy@ericsson.com>
References: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	erik.hugne@ericsson.com, ying.xue@windriver.com, maloy@donjonn.com,
	tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp104.biz.mail.gq1.yahoo.com ([98.137.12.179]:46710 "HELO
	smtp104.biz.mail.gq1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with SMTP id S1750816Ab3JRFaO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 01:30:14 -0400
In-Reply-To: <1382073801-22128-1-git-send-email-jon.maloy@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

tipc_msg_build() calls skb_copy_to_linear_data_offset() to copy data
from user space to kernel space. However, the latter function does
in its turn call memcpy() to perform the actual copying. This poses
an obvious security and robustness risk, since memcpy() never makes
any validity check on the pointer it is copying from.

To correct this, we the replace the offending function call with
a call to memcpy_fromiovecend(), which uses copy_from_user() to
perform the copying.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Reviewed-by: Paul Gortmaker <paul.gortmaker@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c |   22 +++++++++-------------
 1 file changed, 9 insertions(+), 13 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index ced60e2..1e76d91 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -76,10 +76,11 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 		   u32 num_sect, unsigned int total_len, int max_size,
 		   struct sk_buff **buf)
 {
-	int dsz, sz, hsz, pos, res, cnt;
+	int dsz, sz, hsz;
+	unsigned char *to;
 
 	dsz = total_len;
-	pos = hsz = msg_hdr_sz(hdr);
+	hsz = msg_hdr_sz(hdr);
 	sz = hsz + dsz;
 	msg_set_size(hdr, sz);
 	if (unlikely(sz > max_size)) {
@@ -91,16 +92,11 @@ int tipc_msg_build(struct tipc_msg *hdr, struct iovec const *msg_sect,
 	if (!(*buf))
 		return -ENOMEM;
 	skb_copy_to_linear_data(*buf, hdr, hsz);
-	for (res = 1, cnt = 0; res && (cnt < num_sect); cnt++) {
-		skb_copy_to_linear_data_offset(*buf, pos,
-					       msg_sect[cnt].iov_base,
-					       msg_sect[cnt].iov_len);
-		pos += msg_sect[cnt].iov_len;
+	to = (*buf)->data + hsz;
+	if (total_len && memcpy_fromiovecend(to, msg_sect, 0, dsz)) {
+		kfree_skb(*buf);
+		*buf = NULL;
+		return -EFAULT;
 	}
-	if (likely(res))
-		return dsz;
-
-	kfree_skb(*buf);
-	*buf = NULL;
-	return -EFAULT;
+	return dsz;
 }
-- 
1.7.9.5
