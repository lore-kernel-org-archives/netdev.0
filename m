From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] snmp: SNMP_UPD_PO_STATS_BH() always called from softirq
Date: Mon, 21 Mar 2011 12:30:55 +0100
Message-ID: <1300707055.2884.144.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-fx0-f46.google.com ([209.85.161.46]:37149 "EHLO
	mail-fx0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753194Ab1CULbs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 Mar 2011 07:31:48 -0400
Received: by fxm17 with SMTP id 17so5368670fxm.19
        for <netdev@vger.kernel.org>; Mon, 21 Mar 2011 04:31:47 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We dont need to test if we run from softirq context, we definitely are.

This saves few instructions in ip_rcv() & ip_rcv_finish()

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
diff --git a/include/net/snmp.h b/include/net/snmp.h
index 762e2ab..27461d6 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -150,7 +150,7 @@ struct linux_xfrm_mib {
 #define SNMP_UPD_PO_STATS_BH(mib, basefield, addend)	\
 	do { \
 		__typeof__(*mib[0]) *ptr = \
-			__this_cpu_ptr((mib)[!in_softirq()]); \
+			__this_cpu_ptr((mib)[0]); \
 		ptr->mibs[basefield##PKTS]++; \
 		ptr->mibs[basefield##OCTETS] += addend;\
 	} while (0)
@@ -202,7 +202,7 @@ struct linux_xfrm_mib {
 #define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend)			\
 	do {								\
 		__typeof__(*mib[0]) *ptr;				\
-		ptr = __this_cpu_ptr((mib)[!in_softirq()]);		\
+		ptr = __this_cpu_ptr((mib)[0]);				\
 		u64_stats_update_begin(&ptr->syncp);			\
 		ptr->mibs[basefield##PKTS]++;				\
 		ptr->mibs[basefield##OCTETS] += addend;			\


