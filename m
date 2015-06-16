From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] x_table: align per cpu xt_counter
Date: Mon, 15 Jun 2015 18:10:13 -0700
Message-ID: <1434417013.27504.161.camel@edumazet-glaptop2.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netfilter-devel@vger.kernel.org, netdev <netdev@vger.kernel.org>,
	Florian Westphal <fw@strlen.de>
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f46.google.com ([209.85.220.46]:36579 "EHLO
	mail-pa0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753712AbbFPBKQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 15 Jun 2015 21:10:16 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

Let's force a 16 bytes alignment on xt_counter percpu allocations,
so that bytes and packets sit in same cache line.

xt_counter being exported to user space, we cannot add __align(16) on
the structure itself.

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Florian Westphal <fw@strlen.de>
---
 include/linux/netfilter/x_tables.h |    6 ++++--
 1 file changed, 4 insertions(+), 2 deletions(-)

diff --git a/include/linux/netfilter/x_tables.h b/include/linux/netfilter/x_tables.h
index 95693c4cebdda473a2f3e427dcc2511e83bf7405..1c97a2204379e14676ee33f0b15c5174b7afe680 100644
--- a/include/linux/netfilter/x_tables.h
+++ b/include/linux/netfilter/x_tables.h
@@ -356,7 +356,8 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
  * so nothing needs to be done there.
  *
  * xt_percpu_counter_alloc returns the address of the percpu
- * counter, or 0 on !SMP.
+ * counter, or 0 on !SMP. We force an alignment of 16 bytes
+ * so that bytes/packets share a common cache line.
  *
  * Hence caller must use IS_ERR_VALUE to check for error, this
  * allows us to return 0 for single core systems without forcing
@@ -365,7 +366,8 @@ static inline unsigned long ifname_compare_aligned(const char *_a,
 static inline u64 xt_percpu_counter_alloc(void)
 {
 	if (nr_cpu_ids > 1) {
-		void __percpu *res = alloc_percpu(struct xt_counters);
+		void __percpu *res = __alloc_percpu(sizeof(struct xt_counters),
+						    sizeof(struct xt_counters));
 
 		if (res == NULL)
 			return (u64) -ENOMEM;
