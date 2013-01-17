From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH net-next 09/11] ipv6: Do not depend on rt->n in ip6_dst_lookup_tail().
Date: Fri, 18 Jan 2013 02:43:08 +0900
Message-ID: <50F8382C.2040103@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: davem@davemloft.net, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:44415 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756062Ab3AQRnJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 Jan 2013 12:43:09 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_output.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9250c69..7c00edb 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -913,8 +913,12 @@ static int ip6_dst_lookup_tail(struct sock *sk,
 	 * dst entry of the nexthop router
 	 */
 	rt = (struct rt6_info *) *dst;
-	n = rt->n;
-	if (n && !(n->nud_state & NUD_VALID)) {
+	rcu_read_lock_bh();
+	n = __ipv6_neigh_lookup_noref(rt->dst.dev, rt6_nexthop(rt, &fl6->daddr));
+	err = n && !(n->nud_state & NUD_VALID) ? -EINVAL : 0;
+	rcu_read_unlock_bh();
+
+	if (err) {
 		struct inet6_ifaddr *ifp;
 		struct flowi6 fl_gw6;
 		int redirect;
-- 
1.7.9.5
