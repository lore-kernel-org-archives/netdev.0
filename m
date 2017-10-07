From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [net 1/1] tipc: Unclone message at secondary destination lookup
Date: Sat, 7 Oct 2017 15:07:20 +0200
Message-ID: <1507381640-29340-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <parthasarathy.bhuvaragan@ericsson.com>, <ying.xue@windriver.com>,
        <tipc-discussion@lists.sourceforge.net>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sesbmg22.ericsson.net ([193.180.251.48]:51854 "EHLO
        sesbmg22.ericsson.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751119AbdJGNHf (ORCPT
        <rfc822;netdev@vger.kernel.org>); Sat, 7 Oct 2017 09:07:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When a bundling message is received, the function tipc_link_input()
calls function tipc_msg_extract() to unbundle all inner messages of
the bundling message before adding them to input queue.

The function tipc_msg_extract() just clones all inner skb for all
inner messagges from the bundling skb. This means that the skb
headroom of an inner message overlaps with the data part of the
preceding message in the bundle.

If the message in question is a name addressed message, it may be
subject to a secondary destination lookup, and eventually be sent out
on one of the interfaces again. But, since what is perceived as headroom
by the device driver in reality is the last bytes of the preceding
message in the bundle, the latter will be overwritten by the MAC
addresses of the L2 header. If the preceding message has not yet been
consumed by the user, it will evenually be delivered with corrupted
contents.

This commit fixes this by uncloning all messages passing through the
function tipc_msg_lookup_dest(), hence ensuring that the headroom
is always valid when the message is passed on.

Signed-off-by: Tung Nguyen <tung.q.nguyen@dektech.com.au>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/msg.c | 8 ++++++++
 1 file changed, 8 insertions(+)

diff --git a/net/tipc/msg.c b/net/tipc/msg.c
index 121e59a..17146c1 100644
--- a/net/tipc/msg.c
+++ b/net/tipc/msg.c
@@ -568,6 +568,14 @@ bool tipc_msg_lookup_dest(struct net *net, struct sk_buff *skb, int *err)
 	msg_set_destnode(msg, dnode);
 	msg_set_destport(msg, dport);
 	*err = TIPC_OK;
+
+	if (!skb_cloned(skb))
+		return true;
+
+	/* Unclone buffer in case it was bundled */
+	if (pskb_expand_head(skb, BUF_HEADROOM, BUF_TAILROOM, GFP_ATOMIC))
+		return false;
+
 	return true;
 }
 
-- 
2.1.4
