From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 12/12] netfilter: xtables: fix warnings on 32bit platforms
Date: Fri, 19 Jun 2015 19:17:49 +0200
Message-ID: <1434734269-4545-13-git-send-email-pablo@netfilter.org>
References: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:55565 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754840AbbFSRMk (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 19 Jun 2015 13:12:40 -0400
In-Reply-To: <1434734269-4545-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Florian Westphal <fw@strlen.de>

On 32bit archs gcc complains due to cast from void* to u64.
Add intermediate casts to long to silence these warnings.

include/linux/netfilter/x_tables.h:376:10: warning: cast from pointer to integer of different size [-Wpointer-to-int-cast]
include/linux/netfilter/x_tables.h:384:15: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
include/linux/netfilter/x_tables.h:391:23: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]
include/linux/netfilter/x_tables.h:400:22: warning: cast to pointer from integer of different size [-Wint-to-pointer-cast]

Fixes: 71ae0dff02d756e ("netfilter: xtables: use percpu rule counters")
Reported-by: kbuild test robot <fengguang.wu@intel.com>
Signed-off-by: Florian Westphal <fw@strlen.de>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/linux/netfilter/x_tables.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 1c97a22..286098a 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -372,7 +372,7 @@ static inline u64 xt_percpu_counter_alloc(void)
 		if (res == NULL)
 			return (u64) -ENOMEM;
 
-		return (__force u64) res;
+		return (u64) (__force unsigned long) res;
 	}
 
 	return 0;
@@ -380,14 +380,14 @@ static inline u64 xt_percpu_counter_alloc(void)
 static inline void xt_percpu_counter_free(u64 pcnt)
 {
 	if (nr_cpu_ids > 1)
-		free_percpu((void __percpu *) pcnt);
+		free_percpu((void __percpu *) (unsigned long) pcnt);
 }
 
 static inline struct xt_counters *
 xt_get_this_cpu_counter(struct xt_counters *cnt)
 {
 	if (nr_cpu_ids > 1)
-		return this_cpu_ptr((void __percpu *) cnt->pcnt);
+		return this_cpu_ptr((void __percpu *) (unsigned long) cnt->pcnt);
 
 	return cnt;
 }
@@ -396,7 +396,7 @@ static inline struct xt_counters *
 xt_get_per_cpu_counter(struct xt_counters *cnt, unsigned int cpu)
 {
 	if (nr_cpu_ids > 1)
-		return per_cpu_ptr((void __percpu *) cnt->pcnt, cpu);
+		return per_cpu_ptr((void __percpu *) (unsigned long) cnt->pcnt, cpu);
 
 	return cnt;
 }
-- 
1.7.10.4
