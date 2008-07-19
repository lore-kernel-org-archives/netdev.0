From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: [PATCH 7/7] sctp: Update sctp global memory limit allocations.
Date: Sat, 19 Jul 2008 00:26:52 -0400
Message-ID: <12164416202182-git-send-email-vladislav.yasevich@hp.com>
References: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Cc: davem@davemloft.net, linux-sctp@vger.kernel.org,
	Vlad Yasevich <vladislav.yasevich@hp.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0017.houston.hp.com ([15.201.24.20]:45829 "EHLO
	g4t0017.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752670AbYGSE21 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 19 Jul 2008 00:28:27 -0400
In-Reply-To: <12164416121552-git-send-email-vladislav.yasevich@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Update sctp global memory limit allocations to be the same as
TCP.

Signed-off-by: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 net/sctp/protocol.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index cdd8811..ed9acff 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -52,6 +52,8 @@
 #include <linux/inetdevice.h>
 #include <linux/seq_file.h>
 #include <linux/bootmem.h>
+#include <linux/highmem.h>
+#include <linux/swap.h>
 #include <net/net_namespace.h>
 #include <net/protocol.h>
 #include <net/ip.h>
@@ -1080,6 +1082,7 @@ SCTP_STATIC __init int sctp_init(void)
 	int status = -EINVAL;
 	unsigned long goal;
 	unsigned long limit;
+	unsigned long nr_pages;
 	int max_share;
 	int order;
 
@@ -1175,8 +1178,9 @@ SCTP_STATIC __init int sctp_init(void)
 	 * Note this initalizes the data in sctpv6_prot too
 	 * Unabashedly stolen from tcp_init
 	 */
-	limit = min(num_physpages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
-	limit = (limit * (num_physpages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
+	nr_pages = totalram_pages - totalhigh_pages;
+	limit = min(nr_pages, 1UL<<(28-PAGE_SHIFT)) >> (20-PAGE_SHIFT);
+	limit = (limit * (nr_pages >> (20-PAGE_SHIFT))) >> (PAGE_SHIFT-11);
 	limit = max(limit, 128UL);
 	sysctl_sctp_mem[0] = limit / 4 * 3;
 	sysctl_sctp_mem[1] = limit;
@@ -1186,7 +1190,7 @@ SCTP_STATIC __init int sctp_init(void)
 	limit = (sysctl_sctp_mem[1]) << (PAGE_SHIFT - 7);
 	max_share = min(4UL*1024*1024, limit);
 
-	sysctl_sctp_rmem[0] = PAGE_SIZE; /* give each asoc 1 page min */
+	sysctl_sctp_rmem[0] = SK_MEM_QUANTUM; /* give each asoc 1 page min */
 	sysctl_sctp_rmem[1] = (1500 *(sizeof(struct sk_buff) + 1));
 	sysctl_sctp_rmem[2] = max(sysctl_sctp_rmem[1], max_share);
 
-- 
1.5.2.5

