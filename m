From: Juerg Haefliger <juerg.haefliger@hpe.com>
Subject: [PATCH stable 4.4] tipc: move linearization of buffers to generic code
Date: Wed, 21 Sep 2016 15:00:02 +0200
Message-ID: <20160921130002.24939-1-juerg.haefliger@hpe.com>
Cc: jonas.arndt@hpe.com, Jon Paul Maloy <jon.maloy@ericsson.com>,
        Juerg Haefliger <juerg.haefliger@hpe.com>
To: netdev@vger.kernel.org, davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from g2t1383g.austin.hpe.com ([15.233.16.89]:35323 "EHLO
        g2t1383g.austin.hpe.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S933101AbcIUNA3 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 21 Sep 2016 09:00:29 -0400
Received: from g2t2352.austin.hpe.com (g2t2352.austin.hpe.com [15.233.44.25])
        (using TLSv1.2 with cipher AECDH-AES256-SHA (256/256 bits))
        (No client certificate requested)
        by g2t1383g.austin.hpe.com (Postfix) with ESMTPS id 9672320E1
        for <netdev@vger.kernel.org>; Wed, 21 Sep 2016 13:00:28 +0000 (UTC)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jon Paul Maloy <jon.maloy@ericsson.com>

commit c7cad0d6f70cd4ce8644ffe528a4df1cdc2e77f5 upstream.

In commit 5cbb28a4bf65c7e4 ("tipc: linearize arriving NAME_DISTR
and LINK_PROTO buffers") we added linearization of NAME_DISTRIBUTOR,
LINK_PROTOCOL/RESET and LINK_PROTOCOL/ACTIVATE to the function
tipc_udp_recv(). The location of the change was selected in order
to make the commit easily appliable to 'net' and 'stable'.

We now move this linearization to where it should be done, in the
functions tipc_named_rcv() and tipc_link_proto_rcv() respectively.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
Signed-off-by: David S. Miller <davem@davemloft.net>
Signed-off-by: Juerg Haefliger <juerg.haefliger@hpe.com>

---
This commit fixes an issue with nodes not joining a cluster over TIPC
after reboots. Upstream TIPC recommends to include this commit in the
stable kernel:
https://sourceforge.net/p/tipc/mailman/message/35368150/
---
 net/tipc/link.c       | 2 ++
 net/tipc/name_distr.c | 1 +
 net/tipc/udp_media.c  | 5 -----
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 91aea071ab27..72268eac4ec7 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1262,6 +1262,8 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 		/* fall thru' */
 
 	case ACTIVATE_MSG:
+		skb_linearize(skb);
+		hdr = buf_msg(skb);
 
 		/* Complete own link name with peer's interface name */
 		if_name =  strrchr(l->name, ':') + 1;
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c07612bab95c..f51c8bdbea1c 100644
--- a/net/tipc/name_distr.c
+++ b/net/tipc/name_distr.c
@@ -397,6 +397,7 @@ void tipc_named_rcv(struct net *net, struct sk_buff_head *inputq)
 
 	spin_lock_bh(&tn->nametbl_lock);
 	for (skb = skb_dequeue(inputq); skb; skb = skb_dequeue(inputq)) {
+		skb_linearize(skb);
 		msg = buf_msg(skb);
 		mtype = msg_type(msg);
 		item = (struct distr_item *)msg_data(msg);
diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index 70c03271b798..6af78c6276b4 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -48,7 +48,6 @@
 #include <linux/tipc_netlink.h>
 #include "core.h"
 #include "bearer.h"
-#include "msg.h"
 
 /* IANA assigned UDP port */
 #define UDP_PORT_DEFAULT	6118
@@ -224,10 +223,6 @@ static int tipc_udp_recv(struct sock *sk, struct sk_buff *skb)
 {
 	struct udp_bearer *ub;
 	struct tipc_bearer *b;
-	int usr = msg_user(buf_msg(skb));
-
-	if ((usr == LINK_PROTOCOL) || (usr == NAME_DISTRIBUTOR))
-		skb_linearize(skb);
 
 	ub = rcu_dereference_sk_user_data(sk);
 	if (!ub) {
-- 
2.9.3
