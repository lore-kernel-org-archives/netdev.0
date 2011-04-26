From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 6/7] sctp: clean up IPv6 route and XFRM lookups
Date: Tue, 26 Apr 2011 11:48:55 +0800
Message-ID: <4DB640A7.9010802@cn.fujitsu.com>
References: <4DB63F85.2090609@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:55207 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1758005Ab1DZDtI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 25 Apr 2011 23:49:08 -0400
In-Reply-To: <4DB63F85.2090609@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Using ip6_dst_lookup_flow() instead of ip6_dst_lookup()
and then do xfrm_lookup().

Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/ipv6.c |   40 +++++++++-------------------------------
 1 files changed, 9 insertions(+), 31 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 60601f3..cbbfe20 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -244,30 +244,6 @@ static int sctp_v6_xmit(struct sk_buff *skb, struct sctp_transport *transport)
 	return ip6_xmit(sk, skb, &fl6, np->opt);
 }
 
-/* Small helper function that combines route and XFRM lookups.  This is
- * done since we might be looping through route lookups.
- */
-static int sctp_v6_dst_lookup(struct sock *sk, struct dst_entry **dst,
-				struct flowi6 *fl6)
-{
-	int err;
-
-	err = ip6_dst_lookup(sk, dst, fl6);
-	if (err)
-		goto done;
-
-	err = xfrm_lookup(sock_net(sk), *dst, flowi6_to_flowi(fl6), sk, 0);
-	if (err)
-		goto done;
-
-	return 0;
-
-done:
-	dst_release(*dst);
-	*dst = NULL;
-	return err;
-}
-
 /* Returns the dst cache entry for the given source and destination ip
  * addresses.
  */
@@ -285,7 +261,6 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
 	sctp_scope_t scope;
-	int err = 0;
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	ipv6_addr_copy(&fl6->daddr, &daddr->v6.sin6_addr);
@@ -304,7 +279,8 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6->saddr);
 	}
 
-	err = sctp_v6_dst_lookup(sk, &dst, fl6);
+	dst = ip6_dst_lookup_flow(sk, fl6, NULL, false);
+
 	if (!asoc || saddr)
 		goto out;
 
@@ -313,7 +289,7 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	/* ip6_dst_lookup has filled in the fl6->saddr for us.  Check
 	 * to see if we can use it.
 	 */
-	if (!err) {
+	if (!IS_ERR(dst)) {
 		/* Walk through the bind address list and look for a bind
 		 * address that matches the source address of the returned dst.
 		 */
@@ -359,18 +335,20 @@ static void sctp_v6_get_dst(struct sctp_transport *t, union sctp_addr *saddr,
 	if (baddr) {
 		ipv6_addr_copy(&fl6->saddr, &baddr->v6.sin6_addr);
 		fl6->fl6_sport = baddr->v6.sin6_port;
-		err = sctp_v6_dst_lookup(sk, &dst, fl6);
+		dst = ip6_dst_lookup_flow(sk, fl6, NULL, false);
 	}
 
 out:
-	t->dst = dst;
-	if (dst) {
+	if (!IS_ERR(dst)) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
+		t->dst = dst;
 		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
 			&rt->rt6i_dst.addr, &fl6->saddr);
-	} else
+	} else {
+		t->dst = NULL;
 		SCTP_DEBUG_PRINTK("NO ROUTE\n");
+	}
 }
 
 /* Returns the number of consecutive initial bits that match in the 2 ipv6
-- 
1.6.5.2


