From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 09/10] net: add __netdev_alloc_pcpu_stats() to indicate gfp flags
Date: Wed, 11 Nov 2015 18:33:42 +0100
Message-ID: <1447263223-22662-10-git-send-email-pablo@netfilter.org>
References: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:48400 "EHLO mail.us.es"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752597AbbKKReA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 11 Nov 2015 12:34:00 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by mail.us.es (Postfix) with ESMTP id 3B51D1392C1
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2E9125AE
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:59 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 35CE812302A
	for <netdev@vger.kernel.org>; Wed, 11 Nov 2015 18:33:57 +0100 (CET)
In-Reply-To: <1447263223-22662-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_tables may create percpu counters from the packet path through its
dynamic set instantiation infrastructure, so we need a way to allocate
this through GFP_ATOMIC.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
Acked-by: David S. Miller <davem@davemloft.net>
---
 include/linux/netdevice.h | 27 +++++++++++++++------------
 1 file changed, 15 insertions(+), 12 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 2c00772..e9d0c8a 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -2068,20 +2068,23 @@ struct pcpu_sw_netstats {
 	struct u64_stats_sync   syncp;
 };
 
-#define netdev_alloc_pcpu_stats(type)				\
-({								\
-	typeof(type) __percpu *pcpu_stats = alloc_percpu(type); \
-	if (pcpu_stats)	{					\
-		int __cpu;					\
-		for_each_possible_cpu(__cpu) {			\
-			typeof(type) *stat;			\
-			stat = per_cpu_ptr(pcpu_stats, __cpu);	\
-			u64_stats_init(&stat->syncp);		\
-		}						\
-	}							\
-	pcpu_stats;						\
+#define __netdev_alloc_pcpu_stats(type, gfp)				\
+({									\
+	typeof(type) __percpu *pcpu_stats = alloc_percpu_gfp(type, gfp);\
+	if (pcpu_stats)	{						\
+		int __cpu;						\
+		for_each_possible_cpu(__cpu) {				\
+			typeof(type) *stat;				\
+			stat = per_cpu_ptr(pcpu_stats, __cpu);		\
+			u64_stats_init(&stat->syncp);			\
+		}							\
+	}								\
+	pcpu_stats;							\
 })
 
+#define netdev_alloc_pcpu_stats(type)					\
+	__netdev_alloc_pcpu_stats(type, GFP_KERNEL);
+
 #include <linux/notifier.h>
 
 /* netdevice notifier chain. Please remember to update the rtnetlink
-- 
2.1.4
