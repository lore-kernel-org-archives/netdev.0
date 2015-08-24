From: Tom Herbert <tom@herbertland.com>
Subject: [PATCH net-next] udp_offload: Allow device GRO without checksum-complete
Date: Mon, 24 Aug 2015 12:34:13 -0700
Message-ID: <1440444853-614524-1-git-send-email-tom@herbertland.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <kernel-team@fb.com>
To: <davem@davemloft.net>, <netdev@vger.kernel.org>,
	<sramamur@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0b-00082601.pphosted.com ([67.231.153.30]:35929 "EHLO
	mx0b-00082601.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1752361AbbHXTec (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Aug 2015 15:34:32 -0400
Received: from pps.filterd (m0004077 [127.0.0.1])
	by mx0b-00082601.pphosted.com (8.14.5/8.14.5) with SMTP id t7OJYQCB022904
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 12:34:31 -0700
Received: from mail.thefacebook.com ([199.201.64.23])
	by mx0b-00082601.pphosted.com with ESMTP id 1wg83mgdpe-4
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Mon, 24 Aug 2015 12:34:31 -0700
Received: from facebook.com (2401:db00:20:702e:face:0:23:0)	by
 mx-out.facebook.com (10.223.100.97) with ESMTP	id
 1b5592484a9711e5891a24be0593f280-35ffd240 for <netdev@vger.kernel.org>;	Mon,
 24 Aug 2015 12:34:16 -0700
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch adds a sysctl which allows GRO for a UDP offload protocol
to be performed in the device NAPI. This potentially is a performance
improvement if the savings of doing GRO in device NAPI outweighs the
cost of performing the checksum. Note that the performing the
checksum in device NAPI may negatively impact latency or throughput
of unrelated flows.

Performance results for VXLAN are below. Allowing GRO in device
NAPI does show performance improvement over doing GRO at the VXLAN
interface, however this performance is still less than what we see
with UDP checksums enabled (or getting checksum complete from the
device).

Test results: Running one netperf TCP_STREAM over VXLAN.

No UDP checksum, enable sysctl to allow GRO at device (this patch)
  TX CPU: 1.71
  RX CPU: 1.14
  6174 Mbps

UDP checksums and remote checksum offload enabled
  TX CPU: 1.97%
  RX CPU: 1.55%
  7527 Mbps

UDP checksums enabled
  TX CPU: 1.22%
  RX CPU: 1.86%
  6539 Mbps

No UDP checksums, GRO enabled on VXLAN interface
  TX CPU: 0.95%
  RX CPU: 1.78%
  4393 Mbps

No UDP checksum, GRO disabled VXLAN interface
  TX CPU: 1.31%
  RX CPU: 2.38%
  3613 Mbps

Signed-off-by: Tom Herbert <tom@herbertland.com>
---
 Documentation/networking/ip-sysctl.txt | 7 +++++++
 include/net/udp.h                      | 1 +
 net/ipv4/sysctl_net_ipv4.c             | 7 +++++++
 net/ipv4/udp.c                         | 3 +++
 net/ipv4/udp_offload.c                 | 7 ++++---
 5 files changed, 22 insertions(+), 3 deletions(-)

diff --git a/Documentation/networking/ip-sysctl.txt b/Documentation/networking/ip-sysctl.txt
index 46e88ed..d8563c08 100644
--- a/Documentation/networking/ip-sysctl.txt
+++ b/Documentation/networking/ip-sysctl.txt
@@ -711,6 +711,13 @@ udp_wmem_min - INTEGER
 	total pages of UDP sockets exceed udp_mem pressure. The unit is byte.
 	Default: 1 page
 
+udp_gro_nocsum_ok - BOOLEAN
+	If set, allow Generic Receive Offload (GRO) to be performed for UDP
+	offload protocols in the case that packets are being received
+	without an offloaded checksum. This implies that packets checksums
+	may be performed in the device NAPI routines which could negatively
+	impact unrelated flows.
+
 CIPSOv4 Variables:
 
 cipso_cache_enable - BOOLEAN
diff --git a/include/net/udp.h b/include/net/udp.h
index 6d4ed18..48eb6ae 100644
--- a/include/net/udp.h
+++ b/include/net/udp.h
@@ -103,6 +103,7 @@ extern atomic_long_t udp_memory_allocated;
 extern long sysctl_udp_mem[3];
 extern int sysctl_udp_rmem_min;
 extern int sysctl_udp_wmem_min;
+extern int sysctl_udp_gro_nocsum_ok;
 
 struct sk_buff;
 
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index 0330ab2..65fea78 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -766,6 +766,13 @@ static struct ctl_table ipv4_table[] = {
 		.proc_handler	= proc_dointvec_minmax,
 		.extra1		= &one
 	},
+	{
+		.procname	= "udp_gro_nocsum_ok",
+		.data		= &sysctl_udp_gro_nocsum_ok,
+		.maxlen		= sizeof(sysctl_udp_gro_nocsum_ok),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+	},
 	{ }
 };
 
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index c0a15e7..1d91227 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -130,6 +130,9 @@ EXPORT_SYMBOL(sysctl_udp_wmem_min);
 atomic_long_t udp_memory_allocated;
 EXPORT_SYMBOL(udp_memory_allocated);
 
+int sysctl_udp_gro_nocsum_ok;
+EXPORT_SYMBOL(sysctl_udp_gro_nocsum_ok);
+
 #define MAX_UDP_PORTS 65536
 #define PORTS_PER_CHAIN (MAX_UDP_PORTS / UDP_HTABLE_SIZE_MIN)
 
diff --git a/net/ipv4/udp_offload.c b/net/ipv4/udp_offload.c
index f938616..1666f44 100644
--- a/net/ipv4/udp_offload.c
+++ b/net/ipv4/udp_offload.c
@@ -300,9 +300,10 @@ struct sk_buff **udp_gro_receive(struct sk_buff **head, struct sk_buff *skb,
 	int flush = 1;
 
 	if (NAPI_GRO_CB(skb)->udp_mark ||
-	    (skb->ip_summed != CHECKSUM_PARTIAL &&
-	     NAPI_GRO_CB(skb)->csum_cnt == 0 &&
-	     !NAPI_GRO_CB(skb)->csum_valid))
+	    ((skb->ip_summed != CHECKSUM_PARTIAL &&
+	      NAPI_GRO_CB(skb)->csum_cnt == 0 &&
+	      !NAPI_GRO_CB(skb)->csum_valid) &&
+	      !sysctl_udp_gro_nocsum_ok))
 		goto out;
 
 	/* mark that this skb passed once through the udp gro layer */
-- 
1.8.1
