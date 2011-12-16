From: igorm@etf.rs
Subject: [PATCH 02/10 net-next] include: net: snmp: Create icmp per device counters and add macros for per device stats
Date: Fri, 16 Dec 2011 16:25:55 +0100
Message-ID: <1324049163-11207-3-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.etf.rs ([147.91.14.170]:35805 "EHLO mx2.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759977Ab1LPP0T (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:19 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Added per device counters for ipv4 icmp statistics.

Moved _DEV* macros here, from include/net/ipv6.h.
Also, made them more generic, by adding new argument - type.
Because of that, they can be used for in_device stats accounting
in the same way as for inet6_dev.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 include/net/snmp.h |   55 ++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/include/net/snmp.h b/include/net/snmp.h
index 2f65e16..65f4052 100644
--- a/include/net/snmp.h
+++ b/include/net/snmp.h
@@ -61,14 +61,24 @@ struct ipstats_mib {
 
 /* ICMP */
 #define ICMP_MIB_MAX	__ICMP_MIB_MAX
+/* per network ns counters */
 struct icmp_mib {
 	unsigned long	mibs[ICMP_MIB_MAX];
 };
+/*per device counters, (shared on all cpus) */
+struct icmp_mib_dev {
+	atomic_long_t	mibs[ICMP_MIB_MAX];
+};
 
 #define ICMPMSG_MIB_MAX	__ICMPMSG_MIB_MAX
+/* per network ns counters */
 struct icmpmsg_mib {
 	atomic_long_t	mibs[ICMPMSG_MIB_MAX];
 };
+/* per device counters, (shared on all cpus) */
+struct icmpmsg_mib_dev {
+	atomic_long_t	mibs[ICMPMSG_MIB_MAX];
+};
 
 /* ICMP6 (IPv6-ICMP) */
 #define ICMP6_MIB_MAX	__ICMP6_MIB_MAX
@@ -214,4 +224,49 @@ struct linux_xfrm_mib {
 #define SNMP_UPD_PO_STATS64_BH(mib, basefield, addend) SNMP_UPD_PO_STATS_BH(mib, basefield, addend)
 #endif
 
+/* Macros for enabling per device statistics */
+
+#define _DEVINC(net, statname, modifier, type, idev, field)			\
+({	\
+	__typeof__(type) *_idev = (idev);	\
+	if (likely(_idev))	\
+		SNMP_INC_STATS##modifier((_idev)->stats.statname, (field));	\
+	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));	\
+})
+
+/* per device counters are atomic_long_t */
+#define _DEVINCATOMIC(net, statname, modifier, type, idev, field)	\
+({	\
+	__typeof__(type) *_idev = (idev);	\
+	if (likely(_idev))	\
+		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field));	\
+	SNMP_INC_STATS##modifier((net)->mib.statname##_statistics, (field));	\
+})
+
+/* per device and per net counters are atomic_long_t */
+
+#define _DEVINC_ATOMIC_ATOMIC(net, statname, type, idev, field)	\
+({	\
+	__typeof__(type) *_idev = (idev);	\
+	if (likely(_idev))	\
+		SNMP_INC_STATS_ATOMIC_LONG((_idev)->stats.statname##dev, (field));	\
+	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.statname##_statistics, (field));	\
+})
+
+#define _DEVADD(net, statname, modifier, type, idev, field, val)		\
+({	\
+	__typeof__(type) *_idev = (idev);	\
+	if (likely(_idev))	\
+		SNMP_ADD_STATS##modifier((_idev)->stats.statname, (field), (val));	\
+	SNMP_ADD_STATS##modifier((net)->mib.statname##_statistics, (field), (val));	\
+})
+
+#define _DEVUPD(net, statname, modifier, type, idev, field, val)		\
+({	\
+	__typeof__(type) *_idev = (idev);	\
+	if (likely(_idev))	\
+		SNMP_UPD_PO_STATS##modifier((_idev)->stats.statname, field, (val));	\
+	SNMP_UPD_PO_STATS##modifier((net)->mib.statname##_statistics, field, (val));	\
+})
+
 #endif
-- 
1.7.5.4
