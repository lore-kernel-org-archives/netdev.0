From: Wei Yongjun <yjwei@cn.fujitsu.com>
Subject: [PATCH net-next-2.6 3/5] sctp: make sctp over IPv6 work with IPsec
Date: Wed, 27 Apr 2011 15:52:27 +0800
Message-ID: <4DB7CB3B.6030307@cn.fujitsu.com>
References: <4DB7C73D.3000406@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	lksctp <linux-sctp@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:57251 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753276Ab1D0Hwp (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 27 Apr 2011 03:52:45 -0400
In-Reply-To: <4DB7C73D.3000406@cn.fujitsu.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Vlad Yasevich <vladislav.yasevich@hp.com>

SCTP never called xfrm_output after it's v6 route lookups so
that never really worked with ipsec.  Additioanlly, we never
passed port nubmers and protocol in the flowi, so any port
based policies were never applied as well.  Now that we can
fixed ipv6 routing lookup code, using ip6_dst_lookup_flow()
and pass port numbers.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
Signed-off-by: Wei Yongjun <yjwei@cn.fujitsu.com>
---
 net/sctp/ipv6.c |   16 +++++++++++-----
 1 files changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/sctp/ipv6.c b/net/sctp/ipv6.c
index 51c048d..593c801 100644
--- a/net/sctp/ipv6.c
+++ b/net/sctp/ipv6.c
@@ -262,22 +262,27 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	__u8 matchlen = 0;
 	__u8 bmatchlen;
 	sctp_scope_t scope;
-	int err = 0;
 
 	memset(fl6, 0, sizeof(struct flowi6));
 	ipv6_addr_copy(&fl6->daddr, &daddr->v6.sin6_addr);
+	fl6->fl6_dport = daddr->v6.sin6_port;
+	fl6->flowi6_proto = IPPROTO_SCTP;
 	if (ipv6_addr_type(&daddr->v6.sin6_addr) & IPV6_ADDR_LINKLOCAL)
 		fl6->flowi6_oif = daddr->v6.sin6_scope_id;
 
 
 	SCTP_DEBUG_PRINTK("%s: DST=%pI6 ", __func__, &fl6->daddr);
 
+	if (asoc)
+		fl6->fl6_sport = htons(asoc->base.bind_addr.port);
+
 	if (saddr) {
 		ipv6_addr_copy(&fl6->saddr, &saddr->v6.sin6_addr);
+		fl6->fl6_sport = saddr->v6.sin6_port;
 		SCTP_DEBUG_PRINTK("SRC=%pI6 - ", &fl6->saddr);
 	}
 
-	err = ip6_dst_lookup(sk, &dst, fl6);
+	dst = ip6_dst_lookup_flow(sk, fl6, NULL, false);
 	if (!asoc || saddr)
 		goto out;
 
@@ -286,7 +291,7 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	/* ip6_dst_lookup has filled in the fl6->saddr for us.  Check
 	 * to see if we can use it.
 	 */
-	if (!err) {
+	if (!IS_ERR(dst)) {
 		/* Walk through the bind address list and look for a bind
 		 * address that matches the source address of the returned dst.
 		 */
@@ -330,11 +335,12 @@ static struct dst_entry *sctp_v6_get_dst(struct sctp_association *asoc,
 	rcu_read_unlock();
 	if (baddr) {
 		ipv6_addr_copy(&fl6->saddr, &baddr->v6.sin6_addr);
-		err = ip6_dst_lookup(sk, &dst, fl6);
+		fl6->fl6_sport = baddr->v6.sin6_port;
+		dst = ip6_dst_lookup_flow(sk, fl6, NULL, false);
 	}
 
 out:
-	if (!err) {
+	if (!IS_ERR(dst)) {
 		struct rt6_info *rt;
 		rt = (struct rt6_info *)dst;
 		SCTP_DEBUG_PRINTK("rt6_dst:%pI6 rt6_src:%pI6\n",
-- 
1.6.5.2


