From: Jon Maloy <jon.maloy@ericsson.com>
Subject: [PATCH net-next 1/8] tipc: move linearization of
	buffers to generic code
Date: Thu, 19 Nov 2015 14:30:40 -0500
Message-ID: <1447961447-13025-3-git-send-email-jon.maloy@ericsson.com>
References: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jon Maloy <jon.maloy@ericsson.com>,
	parthasarathy.xx.bhuvaragan@ericsson.com, netdev@vger.kernel.org,
	Paul Gortmaker <paul.gortmaker@windriver.com>,
	tipc-discussion@lists.sourceforge.net
To: davem@davemloft.net
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1447961447-13025-1-git-send-email-jon.maloy@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

In commit 5cbb28a4bf65c7e4 ("tipc: linearize arriving NAME_DISTR
and LINK_PROTO buffers") we added linearization of NAME_DISTRIBUTOR,
LINK_PROTOCOL/RESET and LINK_PROTOCOL/ACTIVATE to the function
tipc_udp_recv(). The location of the change was selected in order
to make the commit easily appliable to 'net' and 'stable'.

We now move this linearization to where it should be done, in the
functions tipc_named_rcv() and tipc_link_proto_rcv() respectively.

Reviewed-by: Ying Xue <ying.xue@windriver.com>
Signed-off-by: Jon Maloy <jon.maloy@ericsson.com>
---
 net/tipc/link.c       | 2 ++
 net/tipc/name_distr.c | 1 +
 net/tipc/udp_media.c  | 5 -----
 3 files changed, 3 insertions(+), 5 deletions(-)

diff --git a/net/tipc/link.c b/net/tipc/link.c
index 9efbdbd..fa452fb 100644
--- a/net/tipc/link.c
+++ b/net/tipc/link.c
@@ -1260,6 +1260,8 @@ static int tipc_link_proto_rcv(struct tipc_link *l, struct sk_buff *skb,
 		/* fall thru' */
 
 	case ACTIVATE_MSG:
+		skb_linearize(skb);
+		hdr = buf_msg(skb);
 
 		/* Complete own link name with peer's interface name */
 		if_name =  strrchr(l->name, ':') + 1;
diff --git a/net/tipc/name_distr.c b/net/tipc/name_distr.c
index c07612b..f51c8bd 100644
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
index ad2719a..816914e 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -48,7 +48,6 @@
 #include <linux/tipc_netlink.h>
 #include "core.h"
 #include "bearer.h"
-#include "msg.h"
 
 /* IANA assigned UDP port */
 #define UDP_PORT_DEFAULT	6118
@@ -221,10 +220,6 @@ static int tipc_udp_recv(struct sock *sk, struct sk_buff *skb)
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
1.9.1


------------------------------------------------------------------------------
