From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net: snmp: fix 64bit stats on 32bit arches
Date: Thu, 28 Apr 2016 06:33:24 -0700
Message-ID: <1461850404.5535.103.camel@edumazet-glaptop3.roam.corp.google.com>
References: <1461800683-25034-1-git-send-email-edumazet@google.com>
	 <5721E05B.1030603@6wind.com>
	 <1461844854.5535.93.camel@edumazet-glaptop3.roam.corp.google.com>
	 <5721FFFC.9010808@6wind.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	"David S . Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>
To: nicolas.dichtel@6wind.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f169.google.com ([209.85.220.169]:35538 "EHLO
	mail-qk0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752793AbcD1Nd1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 28 Apr 2016 09:33:27 -0400
Received: by mail-qk0-f169.google.com with SMTP id q76so28245686qke.2
        for <netdev@vger.kernel.org>; Thu, 28 Apr 2016 06:33:27 -0700 (PDT)
In-Reply-To: <5721FFFC.9010808@6wind.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

I accidentally replaced BH disabling by preemption disabling
in SNMP_ADD_STATS64() and SNMP_UPD_PO_STATS64() on 32bit builds.

For 64bit stats on 32bit arch, we really need to disable BH,
since the "struct u64_stats_sync syncp" might be manipulated
both from process and BH contexts.

Fixes: 6aef70a851ac ("net: snmp: kill various STATS_USER() helpers")
Reported-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Tested-by: Nicolas Dichtel <nicolas.dichtel@6wind.com>
Signed-off-by: Eric Dumazet <edumazet@google.com>
---
 include/net/snmp.h |    8 ++++----
 1 file changed, 4 insertions(+), 4 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 6bdd255b2250..c9228ad7ee91 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -166,9 +166,9 @@ struct linux_xfrm_mib {
 
 #define SNMP_ADD_STATS64(mib, field, addend) 				\
 	do {								\
-		preempt_disable();					\
+		local_bh_disable();					\
 		__SNMP_ADD_STATS64(mib, field, addend);			\
-		preempt_enable();					\
+		local_bh_enable();				\
 	} while (0)
 
 #define __SNMP_INC_STATS64(mib, field) SNMP_ADD_STATS64(mib, field, 1)
@@ -184,9 +184,9 @@ struct linux_xfrm_mib {
 	} while (0)
 #define SNMP_UPD_PO_STATS64(mib, basefield, addend)			\
 	do {								\
-		preempt_disable();					\
+		local_bh_disable();					\
 		__SNMP_UPD_PO_STATS64(mib, basefield, addend);		\
-		preempt_enable();					\
+		local_bh_enable();				\
 	} while (0)
 #else
 #define __SNMP_INC_STATS64(mib, field)		__SNMP_INC_STATS(mib, field)
