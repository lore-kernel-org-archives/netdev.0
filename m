From: Richard Alpe <richard.alpe@ericsson.com>
Subject: [PATCH net-next 2/7] tipc: split UDP send function
Date: Fri, 26 Aug 2016 10:52:51 +0200
Message-ID: <1472201576-26588-3-git-send-email-richard.alpe@ericsson.com>
References: <1472201576-26588-1-git-send-email-richard.alpe@ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: tipc-discussion@lists.sourceforge.net
To: <netdev@vger.kernel.org>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
In-Reply-To: <1472201576-26588-1-git-send-email-richard.alpe@ericsson.com>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Split the UDP send function into two. One callback that prepares the
skb and one transmit function that sends the skb. This will come in
handy in later patches, when we introduce UDP replicast.

Signed-off-by: Richard Alpe <richard.alpe@ericsson.com>
Reviewed-by: Jon Maloy <jon.maloy@ericsson.com>
Acked-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/udp_media.c | 50 ++++++++++++++++++++++++++++++++------------------
 1 file changed, 32 insertions(+), 18 deletions(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index adb3c21..7033b4a 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -140,28 +140,13 @@ static int tipc_udp_addr2msg(char *msg, struct tipc_media_addr *a)
 }
 
 /* tipc_send_msg - enqueue a send request */
-static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
-			     struct tipc_bearer *b,
-			     struct tipc_media_addr *dest)
+static int tipc_udp_xmit(struct net *net, struct sk_buff *skb,
+			 struct udp_bearer *ub, struct udp_media_addr *src,
+			 struct udp_media_addr *dst)
 {
 	int ttl, err = 0;
-	struct udp_bearer *ub;
-	struct udp_media_addr *dst = (struct udp_media_addr *)&dest->value;
-	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
 	struct rtable *rt;
 
-	if (skb_headroom(skb) < UDP_MIN_HEADROOM) {
-		err = pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
-		if (err)
-			goto tx_error;
-	}
-
-	skb_set_inner_protocol(skb, htons(ETH_P_TIPC));
-	ub = rcu_dereference_rtnl(b->media_ptr);
-	if (!ub) {
-		err = -ENODEV;
-		goto tx_error;
-	}
 	if (dst->proto == htons(ETH_P_IP)) {
 		struct flowi4 fl = {
 			.daddr = dst->ipv4.s_addr,
@@ -207,6 +192,35 @@ tx_error:
 	return err;
 }
 
+static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
+			     struct tipc_bearer *b,
+			     struct tipc_media_addr *addr)
+{
+	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
+	struct udp_media_addr *dst = (struct udp_media_addr *)&addr->value;
+	struct udp_bearer *ub;
+	int err = 0;
+
+	if (skb_headroom(skb) < UDP_MIN_HEADROOM) {
+		err = pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
+		if (err)
+			goto tx_error;
+	}
+
+	skb_set_inner_protocol(skb, htons(ETH_P_TIPC));
+	ub = rcu_dereference_rtnl(b->media_ptr);
+	if (!ub) {
+		err = -ENODEV;
+		goto tx_error;
+	}
+
+	return tipc_udp_xmit(net, skb, ub, src, dst);
+
+tx_error:
+	kfree_skb(skb);
+	return err;
+}
+
 /* tipc_udp_recv - read data from bearer socket */
 static int tipc_udp_recv(struct sock *sk, struct sk_buff *skb)
 {
-- 
2.1.4


------------------------------------------------------------------------------
