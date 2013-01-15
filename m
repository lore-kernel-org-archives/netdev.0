From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [RFC(v2) net-next 08/13] ipv6: Do not deoend on rt->n in ip6_dst_lookup_tail().
Date: Wed, 16 Jan 2013 01:46:07 +0900
Message-ID: <50F587CF.1090306@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-2022-JP
Content-Transfer-Encoding: 7bit
Cc: yoshfuji@linux-ipv6.org, xiyou.wangcong@gmail.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 94.43.138.210.xn.2iij.net ([210.138.43.94]:41316 "EHLO
	mail.st-paulia.net" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1756428Ab3AOQqI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 15 Jan 2013 11:46:08 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/ip6_output.c |    8 ++++++--
 1 file changed, 6 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/ip6_output.c b/net/ipv6/ip6_output.c
index 9fc5d1d..b2fe048 100644
--- a/net/ipv6/ip6_output.c
+++ b/net/ipv6/ip6_output.c
@@ -921,8 +921,12 @@ static int ip6_dst_lookup_tail(struct sock *sk,
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
