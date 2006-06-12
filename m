From: Gerrit Renker <gerrit@erg.abdn.ac.uk>
Subject: Re: [ PATCH 2.6.17-rc6 1/1] udp.c: counting InDatagrams which are never delivered
Date: Mon, 12 Jun 2006 08:22:36 +0100
Message-ID: <200606120822.36907@strip-the-willow>
References: <200606061925.40327@this-message-has-been-logged> <200606120702.46014@strip-the-willow> <20060611.231300.95505265.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, kaber@coreworks.de, jmorris@namei.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dee.erg.abdn.ac.uk ([139.133.204.82]:54692 "EHLO erg.abdn.ac.uk")
	by vger.kernel.org with ESMTP id S1751073AbWFLHWz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Jun 2006 03:22:55 -0400
To: David Miller <davem@davemloft.net>
In-Reply-To: <20060611.231300.95505265.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The code below implements the discussed solution of decrementing
InDatagrams if a datagram fails the checksum within udp_recvmsg().

I have given it a quick test / build and checked the outcome against
previous results: I now obtained correct counter values, i.e. the application
counted exactly InDatagrams datagrams, whereas with the same settings before
this was not the case (datagrams with checksum errors were counted both as
InErrors and as InDatagrams). 

Will add this patch to http://bugzilla.kernel.org/show_bug.cgi?id=6660
where this problem is also described. Patches under 2.6.16 with no complaints.

Signed-off-by: Gerrit Renker <gerrit@erg.abdn.ac.uk>
---

 include/net/snmp.h |    2 ++
 include/net/udp.h  |    1 +
 net/ipv4/udp.c     |    1 +
 3 files changed, 4 insertions(+)


diff -Nurp  a/include/net/snmp.h b/include/net/snmp.h
--- a/include/net/snmp.h	2006-06-05 21:52:55.000000000 +0100
+++ b/include/net/snmp.h	2006-06-12 07:38:11.000000000 +0100
@@ -137,6 +137,8 @@ struct linux_mib {
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]++)
 #define SNMP_DEC_STATS(mib, field) 	\
 	(per_cpu_ptr(mib[!in_softirq()], raw_smp_processor_id())->mibs[field]--)
+#define SNMP_DEC_STATS_BH(mib, field) 	\
+	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field]--)
 #define SNMP_ADD_STATS_BH(mib, field, addend) 	\
 	(per_cpu_ptr(mib[0], raw_smp_processor_id())->mibs[field] += addend)
 #define SNMP_ADD_STATS_USER(mib, field, addend) 	\
diff -Nurp  a/include/net/udp.h b/include/net/udp.h
--- a/include/net/udp.h	2006-06-06 18:04:36.000000000 +0100
+++ b/include/net/udp.h	2006-06-12 07:39:29.000000000 +0100
@@ -78,6 +78,7 @@ DECLARE_SNMP_STAT(struct udp_mib, udp_st
 #define UDP_INC_STATS(field)		SNMP_INC_STATS(udp_statistics, field)
 #define UDP_INC_STATS_BH(field)		SNMP_INC_STATS_BH(udp_statistics, field)
 #define UDP_INC_STATS_USER(field) 	SNMP_INC_STATS_USER(udp_statistics, field)
+#define UDP_DEC_STATS_BH(field)		SNMP_DEC_STATS_BH(udp_statistics, field)
 
 /* /proc */
 struct udp_seq_afinfo {
diff -Nurp  a/net/ipv4/udp.c b/net/ipv4/udp.c
--- a/net/ipv4/udp.c	2006-06-07 20:44:13.000000000 +0100
+++ b/net/ipv4/udp.c	2006-06-12 07:40:02.000000000 +0100
@@ -846,6 +846,7 @@ out:
 
 csum_copy_err:
 	UDP_INC_STATS_BH(UDP_MIB_INERRORS);
+	UDP_DEC_STATS_BH(UDP_MIB_INDATAGRAMS);
 
 	skb_kill_datagram(sk, skb, flags);
 

