From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 2/2 v2] tipc: potential divide by zero in
 tipc_link_recv_fragment()
Date: Mon, 6 May 2013 22:31:17 +0300
Message-ID: <20130506193117.GA11399@elgon.mountain>
References: <5187F8BD.1080900@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:39599 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755232Ab3EFTbe (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 15:31:34 -0400
Content-Disposition: inline
In-Reply-To: <5187F8BD.1080900@cogentembedded.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The worry here is that fragm_sz could be zero since it comes from
skb->data.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
v2: fix a whitespace issue

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 3a6064b3..de94493 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2524,14 +2524,16 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 		struct tipc_msg *imsg = (struct tipc_msg *)msg_data(fragm);
 		u32 msg_sz = msg_size(imsg);
 		u32 fragm_sz = msg_data_sz(fragm);
-		u32 exp_fragm_cnt = msg_sz/fragm_sz + !!(msg_sz % fragm_sz);
+		u32 exp_fragm_cnt;
 		u32 max =  TIPC_MAX_USER_MSG_SIZE + NAMED_H_SIZE;
+
 		if (msg_type(imsg) == TIPC_MCAST_MSG)
 			max = TIPC_MAX_USER_MSG_SIZE + MCAST_H_SIZE;
-		if (msg_size(imsg) > max) {
+		if (fragm_sz == 0 || msg_size(imsg) > max) {
 			kfree_skb(fbuf);
 			return 0;
 		}
+		exp_fragm_cnt = msg_sz / fragm_sz + !!(msg_sz % fragm_sz);
 		pbuf = tipc_buf_acquire(msg_size(imsg));
 		if (pbuf != NULL) {
 			pbuf->next = *pending;
