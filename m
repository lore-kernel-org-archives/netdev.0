From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH RFC 3/3] ipv6: Don't update pmtu on uncached routes.
Date: Mon, 30 Mar 2015 12:34:40 +0200
Message-ID: <20150330103439.GL3311@secunet.com>
References: <54CF3348.40207@huawei.com>
 <20150203092845.GT13046@secunet.com>
 <54D0A8DB.4010106@huawei.com>
 <20150203120140.GU13046@secunet.com>
 <54D17D1A.3020706@huawei.com>
 <20150205072125.GY13046@secunet.com>
 <54EFD87A.5080907@huawei.com>
 <20150330103210.GI3311@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<yangyingliang@huawei.com>, <hannes@redhat.com>
To: shengyong <shengyong1@huawei.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:60271 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752723AbbC3Kep (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 30 Mar 2015 06:34:45 -0400
Content-Disposition: inline
In-Reply-To: <20150330103210.GI3311@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

A pmtu update on an uncached route will delete the
original route after expiration time is elapsed.
As a result, the host is not reachable any more.

All routes where pmtu discovery can happen are
cached now, so it is ok to refuse pmtu updates
on uncached routes.

Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/ipv6/route.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv6/route.c b/net/ipv6/route.c
index e4b24c8..e0c6ac9 100644
--- a/net/ipv6/route.c
+++ b/net/ipv6/route.c
@@ -1174,7 +1174,8 @@ static void ip6_rt_update_pmtu(struct dst_entry *dst, struct sock *sk,
 	struct rt6_info *rt6 = (struct rt6_info *)dst;
 
 	dst_confirm(dst);
-	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128) {
+	if (mtu < dst_mtu(dst) && rt6->rt6i_dst.plen == 128 &&
+	    (rt6->rt6i_flags & RTF_CACHE)) {
 		struct net *net = dev_net(dst->dev);
 
 		rt6->rt6i_flags |= RTF_MODIFIED;
-- 
1.9.1
