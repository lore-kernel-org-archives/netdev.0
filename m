From: Eric Dumazet <dada1@cosmosbay.com>
Subject: [PATCH] NET : Corrects a bug in ip_rt_acct_read()
Date: Fri, 16 Nov 2007 11:25:19 +0100
Message-ID: <20071116112519.ecbb96ae.dada1@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pfx2.jmh.fr ([194.153.89.55]:43172 "EHLO pfx2.jmh.fr"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756131AbXKPKZU (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 05:25:20 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi David

Before the patch to convert ip_rt_acct to percpu storage,
I believe this bug should be corrected.

(against net-2.6.25 but might apply on previous kernels as well)

Thank you

[PATCH] NET : Corrects a bug in ip_rt_acct_read()

It seems that stats of cpu 0 are counted twice, since 
for_each_possible_cpu() is looping on all possible cpus,
including 0

Before percpu conversion of ip_rt_acct, we should also remove
the assumption that CPU 0 is online (or even possible)

Signed-off-by: Eric Dumazet <dada1@cosmosbay.com>

diff --git a/net/ipv4/route.c b/net/ipv4/route.c
index f0b28f9..70529a9 100644
--- a/net/ipv4/route.c
+++ b/net/ipv4/route.c
@@ -2884,18 +2884,14 @@ static int ip_rt_acct_read(char *buffer, char **start, off_t offset,
 	offset /= sizeof(u32);
 
 	if (length > 0) {
-		u32 *src = ((u32 *) IP_RT_ACCT_CPU(0)) + offset;
 		u32 *dst = (u32 *) buffer;
 
-		/* Copy first cpu. */
 		*start = buffer;
-		memcpy(dst, src, length);
+		memset(dst, 0, length);
 
-		/* Add the other cpus in, one int at a time */
 		for_each_possible_cpu(i) {
 			unsigned int j;
-
-			src = ((u32 *) IP_RT_ACCT_CPU(i)) + offset;
+			u32 *src = ((u32 *) IP_RT_ACCT_CPU(i)) + offset;
 
 			for (j = 0; j < length/4; j++)
 				dst[j] += src[j];
