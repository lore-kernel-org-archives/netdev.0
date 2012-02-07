From: Paul Gortmaker <paul.gortmaker@windriver.com>
Subject: [PATCH net-next 12/15] tipc: Prevent loss of fragmented messages over unicast links
Date: Mon,  6 Feb 2012 19:52:45 -0500
Message-ID: <1328575968-20643-13-git-send-email-paul.gortmaker@windriver.com>
References: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Cc: netdev@vger.kernel.org, allan.stephens@windriver.com,
	ying.xue@windriver.com
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:50217 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756533Ab2BGAxT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Feb 2012 19:53:19 -0500
In-Reply-To: <1328575968-20643-1-git-send-email-paul.gortmaker@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Allan Stephens <allan.stephens@windriver.com>

Modifies unicast link endpoint logic so an incoming fragmented message
is not lost if reassembly cannot begin because there is no buffer big
enough to hold the entire reassembled message. The link endpoint now
ignores the first fragment completely, which causes the sending node to
retransmit the first fragment so that reassembly can be re-attempted.

Previously, the sender would have had no reason to retransmit the 1st
fragment, so we would never have a chance to re-try the allocation.

Signed-off-by: Allan Stephens <allan.stephens@windriver.com>
---
 net/tipc/link.c |   13 ++++++++++---
 1 files changed, 10 insertions(+), 3 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index cce9537..d8b0a22 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1774,6 +1774,7 @@ protocol_check:
 					head = link_insert_deferred_queue(l_ptr,
 									  head);
 				if (likely(msg_is_dest(msg, tipc_own_addr))) {
+					int ret;
 deliver:
 					if (likely(msg_isdata(msg))) {
 						tipc_node_unlock(n_ptr);
@@ -1798,11 +1799,15 @@ deliver:
 						continue;
 					case MSG_FRAGMENTER:
 						l_ptr->stats.recv_fragments++;
-						if (tipc_link_recv_fragment(&l_ptr->defragm_buf,
-									    &buf, &msg)) {
+						ret = tipc_link_recv_fragment(
+							&l_ptr->defragm_buf,
+							&buf, &msg);
+						if (ret == 1) {
 							l_ptr->stats.recv_fragmented++;
 							goto deliver;
 						}
+						if (ret == -1)
+							l_ptr->next_in_no--;
 						break;
 					case CHANGEOVER_PROTOCOL:
 						type = msg_type(msg);
@@ -2632,7 +2637,9 @@ int tipc_link_recv_fragment(struct sk_buff **pending, struct sk_buff **fb,
 			set_fragm_size(pbuf, fragm_sz);
 			set_expected_frags(pbuf, exp_fragm_cnt - 1);
 		} else {
-			warn("Link unable to reassemble fragmented message\n");
+			dbg("Link unable to reassemble fragmented message\n");
+			buf_discard(fbuf);
+			return -1;
 		}
 		buf_discard(fbuf);
 		return 0;
-- 
1.7.9
