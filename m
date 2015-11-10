From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH nf 1/2] net: add __netdev_alloc_pcpu_stats() to indicate gfp flags
Date: Tue, 10 Nov 2015 17:36:28 +0100
Message-ID: <1447173390-2993-1-git-send-email-pablo@netfilter.org>
Cc: kaber@trash.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:52894 "EHLO salida-rhel7.int"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1753240AbbKJQgr (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2015 11:36:47 -0500
Received: from antivirus1-rhel7.int (antivirus1.int [192.168.2.11])
	by salida-rhel7.int (Postfix) with ESMTP id DA3121373B3
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:36:43 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 6A13091ADE
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:36:42 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
	by antivirus1-rhel7.int (Postfix) with ESMTP id 2387D4EEE3
	for <netdev@vger.kernel.org>; Tue, 10 Nov 2015 17:36:40 +0100 (CET)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

nf_tables may create percpu counters from the packet path through its
dynamic set instantiation infrastructure, so we need a way to allocate
this through GFP_ATOMIC.

Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
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
