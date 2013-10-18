From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH ipsec-next] xfrm: use vmalloc_node() for percpu scratches
Date: Fri, 18 Oct 2013 03:54:16 -0700
Message-ID: <1382093656.3284.14.camel@edumazet-glaptop.roam.corp.google.com>
References: <20131017095502.GD7660@secunet.com>
	 <20131017130740.D8741E8A5E@unicorn.suse.cz>
	 <20131018092512.GA31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org
To: Steffen Klassert <steffen.klassert@secunet.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f173.google.com ([209.85.192.173]:52760 "EHLO
	mail-pd0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752930Ab3JRKyS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 18 Oct 2013 06:54:18 -0400
Received: by mail-pd0-f173.google.com with SMTP id r10so2239290pdi.32
        for <netdev@vger.kernel.org>; Fri, 18 Oct 2013 03:54:17 -0700 (PDT)
In-Reply-To: <20131018092512.GA31491@secunet.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

scratches are per cpu, we can use vmalloc_node() for proper
NUMA affinity.

Signed-off-by: Eric Dumazet <edumazet@google.com>
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
