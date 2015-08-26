From: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
Subject: [PATCH RFC V2 1/2] net: Introduce helper functions to get the per cpu data
Date: Wed, 26 Aug 2015 23:07:32 +0530
Message-ID: <1440610653-14210-2-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
References: <y>
 <1440610653-14210-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Cc: <jiri@resnulli.us>, <edumazet@google.com>,
	<hannes@stressinduktion.org>, <tom@herbertland.com>,
	<azhou@nicira.com>, <ebiederm@xmission.com>,
	<ipm@chirality.org.uk>, <nicolas.dichtel@6wind.com>,
	<serge.hallyn@canonical.com>, <netdev@vger.kernel.org>,
	<linux-kernel@vger.kernel.org>,
	<raghavendra.kt@linux.vnet.ibm.com>, <anton@au1.ibm.com>,
	<nacc@linux.vnet.ibm.com>, <srikar@linux.vnet.ibm.com>
To: <davem@davemloft.net>, <kuznet@ms2.inr.ac.ru>, <jmorris@namei.org>,
	<yoshfuji@linux-ipv6.org>, <kaber@trash.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1440610653-14210-1-git-send-email-raghavendra.kt@linux.vnet.ibm.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Signed-off-by: Raghavendra K T <raghavendra.kt@linux.vnet.ibm.com>
---
 include/net/ip.h   | 10 ++++++++++
 net/ipv4/af_inet.c | 41 +++++++++++++++++++++++++++--------------
 2 files changed, 37 insertions(+), 14 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index d5fe9f2..93bf12e 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -202,10 +202,20 @@ void ip_send_unicast_reply(struct sock *sk, struct sk_buff *skb,
 #define NET_ADD_STATS_BH(net, field, adnd) SNMP_ADD_STATS_BH((net)->mib.net_statistics, field, adnd)
 #define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
+u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offct);
 unsigned long snmp_fold_field(void __percpu *mib, int offt);
 #if BITS_PER_LONG==32
+u64 snmp_get_cpu_field64(void __percpu *mib, int cpu, int offct,
+			 size_t syncp_offset);
 u64 snmp_fold_field64(void __percpu *mib, int offt, size_t sync_off);
 #else
+static inline u64  snmp_get_cpu_field64(void __percpu *mib, int cpu, int offct,
+					size_t syncp_offset)
+{
+	return snmp_get_cpu_field(mib, cpu, offct);
+
+}
+
 static inline u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_off)
 {
 	return snmp_fold_field(mib, offt);
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index 9532ee8..302e36b 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1448,38 +1448,51 @@ int inet_ctl_sock_create(struct sock **sk, unsigned short family,
 }
 EXPORT_SYMBOL_GPL(inet_ctl_sock_create);
 
+u64 snmp_get_cpu_field(void __percpu *mib, int cpu, int offt)
+{
+	return  *(((unsigned long *)per_cpu_ptr(mib, cpu)) + offt);
+}
+EXPORT_SYMBOL_GPL(snmp_get_cpu_field);
+
 unsigned long snmp_fold_field(void __percpu *mib, int offt)
 {
 	unsigned long res = 0;
 	int i;
 
 	for_each_possible_cpu(i)
-		res += *(((unsigned long *) per_cpu_ptr(mib, i)) + offt);
+		res += snmp_get_cpu_field(mib, i, offt);
 	return res;
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
 #if BITS_PER_LONG==32
 
+u64 snmp_get_cpu_field64(void __percpu *mib, int cpu, int offct,
+			 size_t syncp_offset)
+{
+	void *bhptr;
+	struct u64_stats_sync *syncp;
+	u64 v;
+	unsigned int start;
+
+	bhptr = per_cpu_ptr(mib, cpu);
+	syncp = (struct u64_stats_sync *)(bhptr + syncp_offset);
+	do {
+		start = u64_stats_fetch_begin_irq(syncp);
+		v = *(((u64 *)bhptr) + offt);
+	} while (u64_stats_fetch_retry_irq(syncp, start));
+
+	return v;
+}
+EXPORT_SYMBOL_GPL(snmp_get_cpu_field64);
+
 u64 snmp_fold_field64(void __percpu *mib, int offt, size_t syncp_offset)
 {
 	u64 res = 0;
 	int cpu;
 
 	for_each_possible_cpu(cpu) {
-		void *bhptr;
-		struct u64_stats_sync *syncp;
-		u64 v;
-		unsigned int start;
-
-		bhptr = per_cpu_ptr(mib, cpu);
-		syncp = (struct u64_stats_sync *)(bhptr + syncp_offset);
-		do {
-			start = u64_stats_fetch_begin_irq(syncp);
-			v = *(((u64 *) bhptr) + offt);
-		} while (u64_stats_fetch_retry_irq(syncp, start));
-
-		res += v;
+		res += snmp_get_cpu_field(mib, cpu, offct, syncp_offset);
 	}
 	return res;
 }
-- 
1.7.11.7
