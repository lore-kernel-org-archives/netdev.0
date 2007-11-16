From: Wang Chen <wangchen@cn.fujitsu.com>
Subject: [PATCH 1/2] [IPV4] SNMP: Decrement of UDP InDatagrams for bad checksum
Date: Fri, 16 Nov 2007 17:31:25 +0800
Message-ID: <473D636D.7090304@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gerrit@erg.abdn.ac.uk
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from [222.73.24.84] ([222.73.24.84]:54848 "EHLO song.cn.fujitsu.com"
	rhost-flags-FAIL-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751432AbXKPJdj (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 16 Nov 2007 04:33:39 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Dave

If there is no socket filter, a bad checksum udp packet will be queued and
ready for user to read. At the same time the InDatagrams is increased.
So we need to decrement InDatagrams when recvmsg() or poll() notice the
bad checksum.

Seems Gerrit had fix it a year ago.(http://lkml.org/lkml/2006/8/28/218)
But it's not in kernel now. So I make the same patch for 2.6.24.rc2.

If this patch ok, I will make the same one for IPv6 UDP.

[PATCH 1/2] [IPV4] SNMP: Decrement of UDP InDatagrams for bad checksum
Decrement UDP InDatagrams for bad checksum UDP packet in ready queue.

Signed-off-by: Wang Chen <wangchen@cn.fujitsu.com>
---
 include/net/snmp.h |    2 ++
 include/net/udp.h  |    3 +++
 net/ipv4/udp.c     |    2 ++
 3 files changed, 7 insertions(+)

diff -Nurp linux-2.6.24-rc2.org/include/net/snmp.h linux-2.6.24-rc2/include/net/snmp.h
--- linux-2.6.24-rc2.org/include/net/snmp.h	2007-11-09 16:37:08.000000000 +0800
+++ linux-2.6.24-rc2/include/net/snmp.h	2007-11-16 16:57:51.000000000 +0800
@@ -142,6 +142,8 @@ struct linux_mib {
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]++)
 #define SNMP_DEC_STATS(mib, field) 	\
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]--)
+#define SNMP_DEC_STATS_BH(mib, field)	\
+	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]--)
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
diff -Nurp linux-2.6.24-rc2.org/include/net/udp.h linux-2.6.24-rc2/include/net/udp.h
--- linux-2.6.24-rc2.org/include/net/udp.h	2007-11-09 16:37:08.000000000 +0800
+++ linux-2.6.24-rc2/include/net/udp.h	2007-11-16 16:58:41.000000000 +0800
@@ -148,6 +148,9 @@ DECLARE_SNMP_STAT(struct udp_mib, udp_st
 #define UDP_INC_STATS_BH(field, is_udplite) 			       do  {  \
 	if (is_udplite) SNMP_INC_STATS_BH(udplite_statistics, field);         \
 	else		SNMP_INC_STATS_BH(udp_statistics, field);    }  while(0)
+#define UDP_DEC_STATS_BH(field, is_udplite)			       do {   \
+	if (is_udplite) SNMP_DEC_STATS_BH(udplite_statistics, field);         \
+	else		SNMP_DEC_STATS_BH(udp_statistics, field);    }  while(0)
 
 /* /proc */
 struct udp_seq_afinfo {
diff -Nurp linux-2.6.24-rc2.org/net/ipv4/udp.c linux-2.6.24-rc2/net/ipv4/udp.c
--- linux-2.6.24-rc2.org/net/ipv4/udp.c	2007-11-09 16:37:57.000000000 +0800
+++ linux-2.6.24-rc2/net/ipv4/udp.c	2007-11-16 15:02:44.000000000 +0800
@@ -897,6 +897,7 @@ out:
 
 csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_udplite);
+	UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_udplite);
 
 	skb_kill_datagram(sk, skb, flags);
 
@@ -1416,6 +1417,7 @@ unsigned int udp_poll(struct file *file,
 		while ((skb = skb_peek(rcvq)) != NULL &&
 		       udp_lib_checksum_complete(skb)) {
 			UDP_INC_STATS_BH(UDP_MIB_INERRORS, is_lite);
+			UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS, is_lite);
 			__skb_unlink(skb, rcvq);
 			kfree_skb(skb);
 		}

