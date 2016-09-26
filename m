From: Jia He <hejianet@gmail.com>
Subject: [PATCH v4 1/7] net:snmp: Introduce generic interfaces for snmp_get_cpu_field{,64}
Date: Mon, 26 Sep 2016 16:09:09 +0800
Message-ID: <1474877355-12920-2-git-send-email-hejianet@gmail.com>
References: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
Cc: linux-sctp@vger.kernel.org, linux-kernel@vger.kernel.org,
        davem@davemloft.net, Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Vlad Yasevich <vyasevich@gmail.com>,
        Neil Horman <nhorman@tuxdriver.com>,
        Steffen Klassert <steffen.klassert@secunet.com>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        marcelo.leitner@gmail.com, Jia He <hejianet@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f194.google.com ([209.85.220.194]:33091 "EHLO
        mail-qk0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932244AbcIZILn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 26 Sep 2016 04:11:43 -0400
In-Reply-To: <1474877355-12920-1-git-send-email-hejianet@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is to introduce the generic interfaces for snmp_get_cpu_field{,64}.
It exchanges the two for-loops for collecting the percpu statistics data.
This can aggregate the data by going through all the items of each cpu
sequentially.

Signed-off-by: Jia He <hejianet@gmail.com>
Suggested-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 include/net/ip.h | 23 +++++++++++++++++++++++
 1 file changed, 23 insertions(+)

diff --git a/include/net/ip.h b/include/net/ip.h
index 9742b92..bc43c0f 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -219,6 +219,29 @@ static inline u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_o
 }
 #endif
 
+#define snmp_get_cpu_field64_batch(buff64, stats_list, mib_statistic, offset) \
+{ \
+	int i, c; \
+	for_each_possible_cpu(c) { \
+		for (i = 0; stats_list[i].name; i++) \
+			buff64[i] += snmp_get_cpu_field64( \
+					mib_statistic, \
+					c, stats_list[i].entry, \
+					offset); \
+	} \
+}
+
+#define snmp_get_cpu_field_batch(buff, stats_list, mib_statistic) \
+{ \
+	int i, c; \
+	for_each_possible_cpu(c) { \
+		for (i = 0; stats_list[i].name; i++) \
+			buff[i] += snmp_get_cpu_field( \
+						mib_statistic, \
+						c, stats_list[i].entry); \
+	} \
+}
+
 void inet_get_local_port_range(struct net *net, int *low, int *high);
 
 #ifdef CONFIG_SYSCTL
-- 
2.5.5
