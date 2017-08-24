From: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Subject: [PATCH net v1 2/3] tipc: reassign pointers after skb reallocation / linearization
Date: Thu, 24 Aug 2017 16:31:23 +0200
Message-ID: <1503585084-14079-3-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
References: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <tipc-discussion@lists.sourceforge.net>,
        <jon.maloy@ericsson.com>, <maloy@donjonn.com>,
        <ying.xue@windriver.com>
To: <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:45059 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753088AbdHXOcc (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 24 Aug 2017 10:32:32 -0400
In-Reply-To: <1503585084-14079-1-git-send-email-parthasarathy.bhuvaragan@ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In tipc_msg_reverse(), we assign skb attributes to local pointers
in stack at startup. This is followed by skb_linearize() and for
cloned buffers we perform skb relocation using pskb_expand_head().
Both these methods may update the skb attributes and thus making
the pointers incorrect.

In this commit, we fix this error by ensuring that the pointers
are re-assigned after any of these skb operations.

Fixes: 29042e19f2c60 ("tipc: let function tipc_msg_reverse() expand header
when needed")
Signed-off-by: Parthasarathy Bhuvaragan <parthasarathy.bhuvaragan@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c | 7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index dcd90e6fa7c3..6ef379f004ac 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -479,13 +479,14 @@ bool tipc_msg_make_bundle(struct sk_buff **skb,  struct tipc_msg *msg,
 bool tipc_msg_reverse(u32 own_node,  struct sk_buff **skb, int err)
 {
 	struct sk_buff *_skb = *skb;
-	struct tipc_msg *hdr = buf_msg(_skb);
+	struct tipc_msg *hdr;
 	struct tipc_msg ohdr;
-	int dlen = min_t(uint, msg_data_sz(hdr), MAX_FORWARD_SIZE);
+	int dlen;
 
 	if (skb_linearize(_skb))
 		goto exit;
 	hdr = buf_msg(_skb);
+	dlen = min_t(uint, msg_data_sz(hdr), MAX_FORWARD_SIZE);
 	if (msg_dest_droppable(hdr))
 		goto exit;
 	if (msg_errcode(hdr))
@@ -511,6 +512,8 @@ bool tipc_msg_reverse(u32 own_node,  struct sk_buff **skb, int err)
 	    pskb_expand_head(_skb, BUF_HEADROOM, BUF_TAILROOM, GFP_ATOMIC))
 		goto exit;
 
+	/* reassign after skb header modifications */
+	hdr = buf_msg(_skb);
 	/* Now reverse the concerned fields */
 	msg_set_errcode(hdr, err);
 	msg_set_non_seq(hdr, 0);
-- 
2.1.4
