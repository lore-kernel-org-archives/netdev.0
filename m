From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] snmp: add align parameter to snmp_mib_init()
Date: Wed, 23 Jun 2010 08:58:41 +0200
Message-ID: <1277276321.2591.755.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Arnaldo Carvalho de Melo <acme@ghostprotocols.net>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f46.google.com ([74.125.82.46]:50341 "EHLO
	mail-ww0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751167Ab0FWG6r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 23 Jun 2010 02:58:47 -0400
Received: by wwc33 with SMTP id 33so714582wwc.19
        for <netdev@vger.kernel.org>; Tue, 22 Jun 2010 23:58:46 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In preparation for 64bit snmp counters for some mibs,
add an 'align' parameter to snmp_mib_init(), instead
of assuming mibs only contain 'unsigned long' fields.

Callers can use __alignof__(type) to provide correct
alignment.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
CC: Herbert Xu <herbert@gondor.apana.org.au>
CC: Arnaldo Carvalho de Melo <acme@ghostprotocols.net>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Vlad Yasevich <vladislav.yasevich@hp.com>
---
 include/net/ip.h       |    2 +-
 net/dccp/proto.c       |    3 ++-
 net/ipv4/af_inet.c     |   27 +++++++++++++++++----------
 net/ipv6/addrconf.c    |    9 ++++++---
 net/ipv6/af_inet6.c    |   15 ++++++++++-----
 net/sctp/protocol.c    |    3 ++-
 net/xfrm/xfrm_policy.c |    3 ++-
 7 files changed, 40 insertions(+), 22 deletions(-)

diff --git a/include/net/ip.h b/include/net/ip.h
index d52f011..3b524df 100644
--- a/include/net/ip.h
+++ b/include/net/ip.h
@@ -178,7 +178,7 @@ extern struct ipv4_config ipv4_config;
 #define NET_ADD_STATS_USER(net, field, adnd) SNMP_ADD_STATS_USER((net)->mib.net_statistics, field, adnd)
 
 extern unsigned long snmp_fold_field(void __percpu *mib[], int offt);
-extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize);
+extern int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align);
 extern void snmp_mib_free(void __percpu *ptr[2]);
 
 extern struct local_ports {
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index f79bcef..096250d 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -1002,7 +1002,8 @@ EXPORT_SYMBOL_GPL(dccp_shutdown);
 static inline int dccp_mib_init(void)
 {
 	return snmp_mib_init((void __percpu **)dccp_statistics,
-			     sizeof(struct dccp_mib));
+			     sizeof(struct dccp_mib),
+			     __alignof__(struct dccp_mib));
 }
 
 static inline void dccp_mib_exit(void)
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index d99e7e0..711de7c 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -1425,13 +1425,13 @@ unsigned long snmp_fold_field(void __percpu *mib[], int offt)
 }
 EXPORT_SYMBOL_GPL(snmp_fold_field);
 
-int snmp_mib_init(void __percpu *ptr[2], size_t mibsize)
+int snmp_mib_init(void __percpu *ptr[2], size_t mibsize, size_t align)
 {
 	BUG_ON(ptr == NULL);
-	ptr[0] = __alloc_percpu(mibsize, __alignof__(unsigned long));
+	ptr[0] = __alloc_percpu(mibsize, align);
 	if (!ptr[0])
 		goto err0;
-	ptr[1] = __alloc_percpu(mibsize, __alignof__(unsigned long));
+	ptr[1] = __alloc_percpu(mibsize, align);
 	if (!ptr[1])
 		goto err1;
 	return 0;
@@ -1488,25 +1488,32 @@ static const struct net_protocol icmp_protocol = {
 static __net_init int ipv4_mib_init_net(struct net *net)
 {
 	if (snmp_mib_init((void __percpu **)net->mib.tcp_statistics,
-			  sizeof(struct tcp_mib)) < 0)
+			  sizeof(struct tcp_mib),
+			  __alignof__(struct tcp_mib)) < 0)
 		goto err_tcp_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.ip_statistics,
-			  sizeof(struct ipstats_mib)) < 0)
+			  sizeof(struct ipstats_mib),
+			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.net_statistics,
-			  sizeof(struct linux_mib)) < 0)
+			  sizeof(struct linux_mib),
+			  __alignof__(struct linux_mib)) < 0)
 		goto err_net_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.udp_statistics,
-			  sizeof(struct udp_mib)) < 0)
+			  sizeof(struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
 		goto err_udp_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.udplite_statistics,
-			  sizeof(struct udp_mib)) < 0)
+			  sizeof(struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
 		goto err_udplite_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.icmp_statistics,
-			  sizeof(struct icmp_mib)) < 0)
+			  sizeof(struct icmp_mib),
+			  __alignof__(struct icmp_mib)) < 0)
 		goto err_icmp_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.icmpmsg_statistics,
-			  sizeof(struct icmpmsg_mib)) < 0)
+			  sizeof(struct icmpmsg_mib),
+			  __alignof__(struct icmpmsg_mib)) < 0)
 		goto err_icmpmsg_mib;
 
 	tcp_mib_init(net);
diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index b97bb1f..c20a7c2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -284,13 +284,16 @@ static void addrconf_mod_timer(struct inet6_ifaddr *ifp,
 static int snmp6_alloc_dev(struct inet6_dev *idev)
 {
 	if (snmp_mib_init((void __percpu **)idev->stats.ipv6,
-			  sizeof(struct ipstats_mib)) < 0)
+			  sizeof(struct ipstats_mib),
+			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip;
 	if (snmp_mib_init((void __percpu **)idev->stats.icmpv6,
-			  sizeof(struct icmpv6_mib)) < 0)
+			  sizeof(struct icmpv6_mib),
+			  __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp;
 	if (snmp_mib_init((void __percpu **)idev->stats.icmpv6msg,
-			  sizeof(struct icmpv6msg_mib)) < 0)
+			  sizeof(struct icmpv6msg_mib),
+			  __alignof__(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg;
 
 	return 0;
diff --git a/net/ipv6/af_inet6.c b/net/ipv6/af_inet6.c
index 94b1b9c..e830cd4 100644
--- a/net/ipv6/af_inet6.c
+++ b/net/ipv6/af_inet6.c
@@ -971,19 +971,24 @@ static void ipv6_packet_cleanup(void)
 static int __net_init ipv6_init_mibs(struct net *net)
 {
 	if (snmp_mib_init((void __percpu **)net->mib.udp_stats_in6,
-			  sizeof (struct udp_mib)) < 0)
+			  sizeof(struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
 		return -ENOMEM;
 	if (snmp_mib_init((void __percpu **)net->mib.udplite_stats_in6,
-			  sizeof (struct udp_mib)) < 0)
+			  sizeof(struct udp_mib),
+			  __alignof__(struct udp_mib)) < 0)
 		goto err_udplite_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.ipv6_statistics,
-			  sizeof(struct ipstats_mib)) < 0)
+			  sizeof(struct ipstats_mib),
+			  __alignof__(struct ipstats_mib)) < 0)
 		goto err_ip_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.icmpv6_statistics,
-			  sizeof(struct icmpv6_mib)) < 0)
+			  sizeof(struct icmpv6_mib),
+			  __alignof__(struct icmpv6_mib)) < 0)
 		goto err_icmp_mib;
 	if (snmp_mib_init((void __percpu **)net->mib.icmpv6msg_statistics,
-			  sizeof(struct icmpv6msg_mib)) < 0)
+			  sizeof(struct icmpv6msg_mib),
+			  __alignof__(struct icmpv6msg_mib)) < 0)
 		goto err_icmpmsg_mib;
 	return 0;
 
diff --git a/net/sctp/protocol.c b/net/sctp/protocol.c
index a0e1a7f..c0e162a 100644
--- a/net/sctp/protocol.c
+++ b/net/sctp/protocol.c
@@ -1002,7 +1002,8 @@ int sctp_register_pf(struct sctp_pf *pf, sa_family_t family)
 static inline int init_sctp_mibs(void)
 {
 	return snmp_mib_init((void __percpu **)sctp_statistics,
-			     sizeof(struct sctp_mib));
+			     sizeof(struct sctp_mib),
+			     __alignof__(struct sctp_mib));
 }
 
 static inline void cleanup_sctp_mibs(void)
diff --git a/net/xfrm/xfrm_policy.c b/net/xfrm/xfrm_policy.c
index 4bf27d9..593c06b 100644
--- a/net/xfrm/xfrm_policy.c
+++ b/net/xfrm/xfrm_policy.c
@@ -2480,7 +2480,8 @@ static int __net_init xfrm_statistics_init(struct net *net)
 	int rv;
 
 	if (snmp_mib_init((void __percpu **)net->mib.xfrm_statistics,
-			  sizeof(struct linux_xfrm_mib)) < 0)
+			  sizeof(struct linux_xfrm_mib),
+			  __alignof__(struct linux_xfrm_mib)) < 0)
 		return -ENOMEM;
 	rv = xfrm_proc_init(net);
 	if (rv < 0)


