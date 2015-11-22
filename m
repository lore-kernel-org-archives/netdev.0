From: Ying Xue <ying.xue@windriver.com>
Subject: [PATCH] tipc: fix error handling of expanding
	buffer headroom
Date: Sun, 22 Nov 2015 15:38:39 +0800
Message-ID: <1448177919-8646-1-git-send-email-ying.xue@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: jon.maloy@ericsson.com, stephen@networkplumber.org,
	tipc-discussion@lists.sourceforge.net, scan-admin@coverity.com,
	netdev@vger.kernel.org
To: <davem@davemloft.net>
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Coverity says:

*** CID 1338065:  Error handling issues  (CHECKED_RETURN)
/net/tipc/udp_media.c: 162 in tipc_udp_send_msg()
156     	struct udp_media_addr *dst = (struct udp_media_addr *)&dest->value;
157     	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
158     	struct sk_buff *clone;
159     	struct rtable *rt;
160
161     	if (skb_headroom(skb) < UDP_MIN_HEADROOM)
>>>     CID 1338065:  Error handling issues  (CHECKED_RETURN)
>>>     Calling "pskb_expand_head" without checking return value (as is done elsewhere 51 out of 56 times).
162     		pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
163
164     	clone = skb_clone(skb, GFP_ATOMIC);
165     	skb_set_inner_protocol(clone, htons(ETH_P_TIPC));
166     	ub = rcu_dereference_rtnl(b->media_ptr);
167     	if (!ub) {

When expanding buffer headroom over udp tunnel with pskb_expand_head(),
it's unfortunate that we don't check its return value. As a result, if
the function returns an error code due to the lack of memory, it may
cause unpredictable consequence as we unconditionally consider that
it's always successful.

Fixes: e53567948f82 ("tipc: conditionally expand buffer headroom over udp tunnel")
Reported-by: <scan-admin@coverity.com>
Cc: Stephen Hemminger <stephen@networkplumber.org>
Signed-off-by: Ying Xue <ying.xue@windriver.com>
---
 net/tipc/udp_media.c |    7 +++++--
 1 file changed, 5 insertions(+), 2 deletions(-)

diff --git a/net/tipc/udp_media.c b/net/tipc/udp_media.c
index ad2719a..f01ff16 100644
--- a/net/tipc/udp_media.c
+++ b/net/tipc/udp_media.c
@@ -158,8 +158,11 @@ static int tipc_udp_send_msg(struct net *net, struct sk_buff *skb,
 	struct udp_media_addr *src = (struct udp_media_addr *)&b->addr.value;
 	struct rtable *rt;
 
-	if (skb_headroom(skb) < UDP_MIN_HEADROOM)
-		pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
+	if (skb_headroom(skb) < UDP_MIN_HEADROOM) {
+		err = pskb_expand_head(skb, UDP_MIN_HEADROOM, 0, GFP_ATOMIC);
+		if (!err)
+			goto tx_error;
+	}
 
 	skb_set_inner_protocol(skb, htons(ETH_P_TIPC));
 	ub = rcu_dereference_rtnl(b->media_ptr);
-- 
1.7.9.5


------------------------------------------------------------------------------
