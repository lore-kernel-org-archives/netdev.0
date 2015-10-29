From: Paolo Abeni <pabeni@redhat.com>
Subject: [PATCH net-next v2] ipv4: use l4 hash for locally generated multipath flows
Date: Thu, 29 Oct 2015 22:20:40 +0100
Message-ID: <63c7c10d710fb30e886121ac33ef66cedb101cd9.1446139106.git.pabeni@redhat.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, pch@ordbogen.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:35103 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757858AbbJ2VU6 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Oct 2015 17:20:58 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes how the multipath hash is computed for locally
generated flows: now the hash comprises l4 information.

This allows better utilization of the available paths when the existing
flows have the same source IP and the same destination IP: with l3 hash,
even when multiple connections are in place simultaneously, a single path
will be used, while with l4 hash we can use all the available paths.

v2 changes:
- use get_hash_from_flowi4() instead of implementing just another l4 hash
  function

Signed-off-by: Paolo Abeni <pabeni@redhat.com>
---
 net/ipv4/fib_semantics.c | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_semantics.c b/net/ipv4/fib_semantics.c
index 42778d9..f30df0e 100644
--- a/net/ipv4/fib_semantics.c
+++ b/net/ipv4/fib_semantics.c
@@ -1564,7 +1564,8 @@ void fib_select_path(struct net *net, struct fib_result *res,
 #ifdef CONFIG_IP_ROUTE_MULTIPATH
 	if (res->fi->fib_nhs > 1 && fl4->flowi4_oif == 0) {
 		if (mp_hash < 0)
-			mp_hash = fib_multipath_hash(fl4->saddr, fl4->daddr);
+			mp_hash = get_hash_from_flowi4(fl4) >> 1;
+
 		fib_select_multipath(res, mp_hash);
 	}
 	else
-- 
1.8.3.1
