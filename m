From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 19/20] mib: add net to NET_ADD_STATS_BH
Date: Wed, 16 Jul 2008 12:37:21 +0400
Message-ID: <487DB341.5070008@openvz.org>
References: <487DABB6.5080905@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:56776 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753674AbYGPIhY (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Jul 2008 04:37:24 -0400
In-Reply-To: <487DABB6.5080905@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This one is tricky. 

The thing is that this macro is only used when killing tw buckets, 
but since this killer is promiscuous wrt to which net each particular
tw belongs to, I have to use it only when NET_NS is off. When the net
namespaces are on, I use the INET_INC_STATS_BH for each bucket.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>
---
 include/net/ip.h              |    2 +-
 net/ipv4/inet_timewait_sock.c |   15 ++++++++++++---
 2 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index 79d1319..a8275b1 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -164,7 +164,7 @@ DECLARE_SNMP_STAT(struct linux_mib, net_statistics);
 #define NET_INC_STATS(net, field)	do { (void)net; SNMP_INC_STATS(net_statistics, field); } while (0)
 #define NET_INC_STATS_BH(net, field)	do { (void)net; SNMP_INC_STATS_BH(net_statistics, field); } while (0)
 #define NET_INC_STATS_USER(net, field) 	do { (void)net; SNMP_INC_STATS_USER(net_statistics, field); } while (0)
-#define NET_ADD_STATS_BH(field, adnd)	SNMP_ADD_STATS_BH(net_statistics, field, adnd)
+#define NET_ADD_STATS_BH(net, field, adnd) do { (void)net; SNMP_ADD_STATS_BH(net_statistics, field, adnd); } while (0)
 #define NET_ADD_STATS_USER(field, adnd)	SNMP_ADD_STATS_USER(net_statistics, field, adnd)
 
 extern unsigned long snmp_fold_field(void *mib[], int offt);
diff --git a/net/ipv4/inet_timewait_sock.c b/net/ipv4/inet_timewait_sock.c
index 06006a5..75c2def 100644
--- a/net/ipv4/inet_timewait_sock.c
+++ b/net/ipv4/inet_timewait_sock.c
@@ -160,6 +160,9 @@ rescan:
 		__inet_twsk_del_dead_node(tw);
 		spin_unlock(&twdr->death_lock);
 		__inet_twsk_kill(tw, twdr->hashinfo);
+#ifdef CONFIG_NET_NS
+		NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITED);
+#endif
 		inet_twsk_put(tw);
 		killed++;
 		spin_lock(&twdr->death_lock);
@@ -178,8 +181,9 @@ rescan:
 	}
 
 	twdr->tw_count -= killed;
-	NET_ADD_STATS_BH(LINUX_MIB_TIMEWAITED, killed);
-
+#ifndef CONFIG_NET_NS
+	NET_ADD_STATS_BH(&init_net, LINUX_MIB_TIMEWAITED, killed);
+#endif
 	return ret;
 }
 
@@ -372,6 +376,9 @@ void inet_twdr_twcal_tick(unsigned long data)
 						       &twdr->twcal_row[slot]) {
 				__inet_twsk_del_dead_node(tw);
 				__inet_twsk_kill(tw, twdr->hashinfo);
+#ifdef CONFIG_NET_NS
+				NET_INC_STATS_BH(twsk_net(tw), LINUX_MIB_TIMEWAITKILLED);
+#endif
 				inet_twsk_put(tw);
 				killed++;
 			}
@@ -395,7 +402,9 @@ void inet_twdr_twcal_tick(unsigned long data)
 out:
 	if ((twdr->tw_count -= killed) == 0)
 		del_timer(&twdr->tw_timer);
-	NET_ADD_STATS_BH(LINUX_MIB_TIMEWAITKILLED, killed);
+#ifndef CONFIG_NET_NS
+	NET_ADD_STATS_BH(&init_net, LINUX_MIB_TIMEWAITKILLED, killed);
+#endif
 	spin_unlock(&twdr->death_lock);
 }
 
-- 
1.5.5.1

