From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 15/16] tipc: fix wrong return value for link_send_sections_long routine
Date: Mon, 17 Jun 2013 10:54:50 -0400
Message-ID: <1371480891-5264-16-git-send-email-paul.gortmaker@windriver.com>
References: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jon Maloy <jon.maloy@ericsson.com>,
	Ying Xue <ying.xue@windriver.com>,
	Erik Hugne <erik.hugne@ericsson.com>,
	Paul Gortmaker <paul.gortmaker@windriver.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:63284 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751518Ab3FQOzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Jun 2013 10:55:24 -0400
In-Reply-To: <1371480891-5264-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ying Xue <ying.xue@windriver.com>

When skb buffer cannot be allocated in link_send_sections_long(),
-ENOMEM error code instead of -EFAULT should be returned to its
caller.

Signed-off-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Paul Gortmaker <paul.gortmaker@windriver.com>
---
 net/tipc/link.c | 8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index b6ffa9f..0cc3d90 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1168,6 +1168,7 @@ static int link_send_sections_long(struct tipc_port *sender,
 	const unchar *sect_crs;
 	int curr_sect;
 	u32 fragm_no;
+	int res = 0;
 
 again:
 	fragm_no = 1;
@@ -1215,12 +1216,13 @@ again:
 			sz = fragm_rest;
 
 		if (copy_from_user(buf->data + fragm_crs, sect_crs, sz)) {
+			res = -EFAULT;
 error:
 			for (; buf_chain; buf_chain = buf) {
 				buf = buf_chain->next;
 				kfree_skb(buf_chain);
 			}
-			return -EFAULT;
+			return res;
 		}
 		sect_crs += sz;
 		sect_rest -= sz;
@@ -1241,8 +1243,10 @@ error:
 			msg_set_fragm_no(&fragm_hdr, ++fragm_no);
 			prev = buf;
 			buf = tipc_buf_acquire(fragm_sz + INT_H_SIZE);
-			if (!buf)
+			if (!buf) {
+				res = -ENOMEM;
 				goto error;
+			}
 
 			buf->next = NULL;
 			prev->next = buf;
-- 
1.8.1.2
