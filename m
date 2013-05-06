From: Dan Carpenter <dan.carpenter@oracle.com>
Subject: [patch 1/2] tipc: add a bounds check in link_recv_changeover_msg()
Date: Mon, 6 May 2013 21:28:41 +0300
Message-ID: <20130506182840.GA21347@elgon.mountain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Allan Stephens <allan.stephens@windriver.com>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	tipc-discussion@lists.sourceforge.net,
	kernel-janitors@vger.kernel.org
To: Jon Maloy <jon.maloy@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:41168 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754031Ab3EFS3A (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 May 2013 14:29:00 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bearer_id here comes from skb->data and it can be a number from 0 to
7.  The problem is that the ->links[] array has only 2 elements so I
have added a range check.

Signed-off-by: Dan Carpenter <dan.carpenter@oracle.com>
---
This is static analysis work.  I am not very familiar with this
subsystem and I haven't tested this.

diff --git a/net/tipc/link.c b/net/tipc/link.c
index daa6080..3a6064b3 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -2306,8 +2306,11 @@ static int link_recv_changeover_msg(struct tipc_link **l_ptr,
 	struct tipc_msg *tunnel_msg = buf_msg(tunnel_buf);
 	u32 msg_typ = msg_type(tunnel_msg);
 	u32 msg_count = msg_msgcnt(tunnel_msg);
+	u32 bearer_id = msg_bearer_id(tunnel_msg);
 
-	dest_link = (*l_ptr)->owner->links[msg_bearer_id(tunnel_msg)];
+	if (bearer_id >= MAX_BEARERS)
+		goto exit;
+	dest_link = (*l_ptr)->owner->links[bearer_id];
 	if (!dest_link)
 		goto exit;
 	if (dest_link == *l_ptr) {
