From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net 1/1] tipc: linearize arriving NAME_DISTR and LINK_PROTO buffers
Date: Wed, 28 Oct 2015 13:09:53 -0400
Message-ID: <1446052193-27155-1-git-send-email-jon.maloy@ericsson.com>
Cc: netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com,
	richard.alpe@ericsson.com, ying.xue@windriver.com,
	maloy@donjonn.com, tipc-discussion@lists.sourceforge.net,
	Jon Maloy <jon.maloy@ericsson.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp101.biz.mail.bf1.yahoo.com ([98.139.221.60]:27332 "EHLO
	smtp101.biz.mail.bf1.yahoo.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752022AbbJ1RKA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 28 Oct 2015 13:10:00 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Testing of the new UDP bearer has revealed that reception of
NAME_DISTRIBUTOR, LINK_PROTOCOL/RESET and LINK_PROTOCOL/ACTIVATE
message buffers is not prepared for the case that those may be
non-linear.

We now linearize all such buffers before they are delivered up to the
generic reception layer.

In order for the commit to apply cleanly to 'net' and 'stable', we do
the change in the function tipc_udp_recv() for now. Later, we will post
a commit to 'net-next' moving the linearization to generic code, in
tipc_named_rcv() and tipc_link_proto_rcv().

Fixes: commit d0f91938bede ("tipc: add ip/udp media type")
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/udp_media.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 6e648d9..cd7c5f1 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -48,6 +48,7 @@
 #include <linux/tipc_netlink.h>
 #include "core.h"
 #include "bearer.h"
+#include "msg.h"
 
 /* IANA assigned UDP port */
 #define UDP_PORT_DEFAULT	6118
@@ -222,6 +223,10 @@ static int tipc_udp_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_bearer *ub;
 	struct tipc_bearer *b;
+	int usr = msg_user(buf_msg(skb));
+
+	if ((usr == LINK_PROTOCOL) || (usr == NAME_DISTRIBUTOR))
+		skb_linearize(skb);
 
 	ub = rcu_dereference_sk_user_data(sk);
 	if (!ub) {
-- 
1.9.1
