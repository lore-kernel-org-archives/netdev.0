From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 5/6] ipvs: stats should not depend on CPU 0
Date: Tue,  1 Oct 2013 11:35:31 +0200
Message-ID: <1380620132-7388-5-git-send-email-pablo@netfilter.org>
References: <1380620132-7388-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from slan-550-85.anhosting.com ([209.236.71.68]:42618 "EHLO
	slan-550-85.anhosting.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752799Ab3JAKEh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 1 Oct 2013 06:04:37 -0400
In-Reply-To: <1380620132-7388-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Julian Anastasov <ja@ssi.bg>

When reading percpu stats we need to properly reset
the sum when CPU 0 is not present in the possible mask.

Signed-off-by: Julian Anastasov <ja@ssi.bg>
Signed-off-by: Simon Horman <horms@verge.net.au>
---
 net/netfilter/ipvs/ip_vs_est.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/netfilter/ipvs/ip_vs_est.c b/net/netfilter/ipvs/ip_vs_est.c
index 6bee6d0..1425e9a 100644
--- a/net/netfilter/ipvs/ip_vs_est.c
+++ b/net/netfilter/ipvs/ip_vs_est.c
@@ -59,12 +59,13 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 				 struct ip_vs_cpu_stats __percpu *stats)
 {
 	int i;
+	bool add = false;
 
 	for_each_possible_cpu(i) {
 		struct ip_vs_cpu_stats *s = per_cpu_ptr(stats, i);
 		unsigned int start;
 		__u64 inbytes, outbytes;
-		if (i) {
+		if (add) {
 			sum->conns += s->ustats.conns;
 			sum->inpkts += s->ustats.inpkts;
 			sum->outpkts += s->ustats.outpkts;
@@ -76,6 +77,7 @@ static void ip_vs_read_cpu_stats(struct ip_vs_stats_user *sum,
 			sum->inbytes += inbytes;
 			sum->outbytes += outbytes;
 		} else {
+			add = true;
 			sum->conns = s->ustats.conns;
 			sum->inpkts = s->ustats.inpkts;
 			sum->outpkts = s->ustats.outpkts;
-- 
1.7.10.4
