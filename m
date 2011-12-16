From: igorm@etf.rs
Subject: [PATCH 06/10 net-next] include:net:icmp: Tuned up ICMP_*_STATS macros for per device statistics and changed prototype for icmp_out_count
Date: Fri, 16 Dec 2011 16:25:59 +0100
Message-ID: <1324049163-11207-7-git-send-email-igorm@etf.rs>
References: <igorm@etf.rs>
 <1324049163-11207-1-git-send-email-igorm@etf.rs>
Cc: davem@davemloft.net, Igor Maravic <igorm@etf.rs>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.etf.rs ([147.91.14.169]:53867 "EHLO mx1.etf.bg.ac.rs"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1760002Ab1LPP0U (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Dec 2011 10:26:20 -0500
In-Reply-To: <1324049163-11207-1-git-send-email-igorm@etf.rs>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Igor Maravic <igorm@etf.rs>

Changed ICMP_*_STATS so now they call _DEV* macros.
They call _DEV* macros under rcu_read_lock,
so we could get in_device from net_device with function
__in_dev_get_rcu_safely. This function is safe if dev==NULL.

Changed prototype for icmp_out_count so we can have per device statistics.

Signed-off-by: Igor Maravic <igorm@etf.rs>
---
 include/net/icmp.h |   37 ++++++++++++++++++++++++++++++++-----
 1 files changed, 32 insertions(+), 5 deletions(-)

diff --git a/include/net/icmp.h b/include/net/icmp.h
index 75d6156..aa71b9a 100644
--- a/include/net/icmp.h
+++ b/include/net/icmp.h
@@ -29,10 +29,37 @@ struct icmp_err {
 };
 
 extern const struct icmp_err icmp_err_convert[];
-#define ICMP_INC_STATS(net, field)	SNMP_INC_STATS((net)->mib.icmp_statistics, field)
-#define ICMP_INC_STATS_BH(net, field)	SNMP_INC_STATS_BH((net)->mib.icmp_statistics, field)
-#define ICMPMSGOUT_INC_STATS(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field+256)
-#define ICMPMSGIN_INC_STATS_BH(net, field)	SNMP_INC_STATS_ATOMIC_LONG((net)->mib.icmpmsg_statistics, field)
+#define ICMP_INC_STATS(net, dev, field)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVINCATOMIC(net, icmp, , struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field);	\
+		rcu_read_unlock();	\
+	})
+			
+#define ICMP_INC_STATS_BH(net, dev, field)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVINCATOMIC(net, icmp, _BH, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field);	\
+		rcu_read_unlock();	\
+	})
+
+#define ICMPMSGOUT_INC_STATS(net, dev, field)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVINC_ATOMIC_ATOMIC(net, icmpmsg, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field +256);	\
+		rcu_read_unlock();	\
+	})
+
+#define ICMPMSGIN_INC_STATS_BH(net, dev, field)	\
+	({	\
+		rcu_read_lock();	\
+		_DEVINC_ATOMIC_ATOMIC(net, icmpmsg, struct in_device,	\
+			__in_dev_get_rcu_safely(dev), field);	\
+		rcu_read_unlock();	\
+	})
 
 struct dst_entry;
 struct net_proto_family;
@@ -43,6 +70,6 @@ extern void	icmp_send(struct sk_buff *skb_in,  int type, int code, __be32 info);
 extern int	icmp_rcv(struct sk_buff *skb);
 extern int	icmp_ioctl(struct sock *sk, int cmd, unsigned long arg);
 extern int	icmp_init(void);
-extern void	icmp_out_count(struct net *net, unsigned char type);
+extern void	icmp_out_count(struct net_device *dev, unsigned char type);
 
 #endif	/* _ICMP_H */
-- 
1.7.5.4
