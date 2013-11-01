From: Steffen Klassert <steffen.klassert@secunet.com>
Subject: [PATCH 1/4] xfrm: use vmalloc_node() for percpu scratches
Date: Fri,  1 Nov 2013 08:50:54 +0100
Message-ID: <1383292257-4634-2-git-send-email-steffen.klassert@secunet.com>
References: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	Steffen Klassert <steffen.klassert@secunet.com>,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from a.mx.secunet.com ([195.81.216.161]:49097 "EHLO a.mx.secunet.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754889Ab3KAHvI (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 1 Nov 2013 03:51:08 -0400
In-Reply-To: <1383292257-4634-1-git-send-email-steffen.klassert@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

scratches are per cpu, we can use vmalloc_node() for proper
NUMA affinity.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Acked-by: Herbert Xu <herbert@gondor.apana.org.au>
Signed-off-by: Steffen Klassert <steffen.klassert@secunet.com>
---
 net/xfrm/xfrm_ipcomp.c |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/net/xfrm/xfrm_ipcomp.c b/net/xfrm/xfrm_ipcomp.c
index 2906d52..b943c7f 100644
--- a/net/xfrm/xfrm_ipcomp.c
+++ b/net/xfrm/xfrm_ipcomp.c
@@ -220,8 +220,8 @@ static void ipcomp_free_scratches(void)
 
 static void * __percpu *ipcomp_alloc_scratches(void)
 {
-	int i;
 	void * __percpu *scratches;
+	int i;
 
 	if (ipcomp_scratch_users++)
 		return ipcomp_scratches;
@@ -233,7 +233,9 @@ static void * __percpu *ipcomp_alloc_scratches(void)
 	ipcomp_scratches = scratches;
 
 	for_each_possible_cpu(i) {
-		void *scratch = vmalloc(IPCOMP_SCRATCH_SIZE);
+		void *scratch;
+
+		scratch = vmalloc_node(IPCOMP_SCRATCH_SIZE, cpu_to_node(i));
 		if (!scratch)
 			return NULL;
 		*per_cpu_ptr(scratches, i) = scratch;
-- 
1.7.9.5
