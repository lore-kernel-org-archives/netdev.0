From: Vlad Yasevich <vyasevic@redhat.com>
Subject: [RFC PATCH 10/13] ipv6: Move exthdr offload support into separate file
Date: Tue, 13 Nov 2012 20:24:11 -0500
Message-ID: <1352856254-29667-11-git-send-email-vyasevic@redhat.com>
References: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Cc: eric.dumazet@gmail.com, davem@davemloft.com
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:19914 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932399Ab2KNBYe (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Nov 2012 20:24:34 -0500
In-Reply-To: <1352856254-29667-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Move the exthdr offload functionality into a separeate
file in preparate for moving it out of the module

Signed-off-by: Vlad Yasevich <vyasevic@redhat.com>
---
 net/ipv6/Makefile          |    2 +-
 net/ipv6/exthdrs.c         |   40 +++---------------------------------
 net/ipv6/exthdrs_offload.c |   48 ++++++++++++++++++++++++++++++++++++++++++++
 net/ipv6/ip6_offload.h     |    3 ++
 4 files changed, 56 insertions(+), 37 deletions(-)
 create mode 100644 net/ipv6/exthdrs_offload.c

diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 04b5c96..7f25077 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -10,7 +10,7 @@ ipv6-objs :=	af_inet6.o anycast.o ip6_output.o ip6_input.o addrconf.o \
 		raw.o protocol.o icmp.o mcast.o reassembly.o tcp_ipv6.o \
 		exthdrs.o datagram.o ip6_flowlabel.o inet6_connection_sock.o
 
-ipv6-offload :=	ip6_offload.o tcpv6_offload.o udp_offload.o
+ipv6-offload :=	ip6_offload.o tcpv6_offload.o udp_offload.o exthdrs_offload.o
 
 ipv6-$(CONFIG_SYSCTL) = sysctl_net_ipv6.o
 ipv6-$(CONFIG_IPV6_MROUTE) += ip6mr.o
diff --git a/net/ipv6/exthdrs.c b/net/ipv6/exthdrs.c
index d5a807d..dc0faab 100644
--- a/net/ipv6/exthdrs.c
+++ b/net/ipv6/exthdrs.c
@@ -48,6 +48,7 @@
 #endif
 
 #include <asm/uaccess.h>
+#include "ip6_offload.h"
 
 int ipv6_find_tlv(struct sk_buff *skb, int offset, int type)
 {
@@ -528,20 +529,12 @@ unknown_rh:
 
 static const struct inet6_protocol rthdr_protocol = {
 	.handler	=	ipv6_rthdr_rcv,
-	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
-};
-
-static const struct net_offload rthdr_offload = {
-	.flags		=	INET6_PROTO_GSO_EXTHDR,
+	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
 static const struct inet6_protocol destopt_protocol = {
 	.handler	=	ipv6_destopt_rcv,
-	.flags		=	INET6_PROTO_NOPOLICY | INET6_PROTO_GSO_EXTHDR,
-};
-
-static const struct net_offload dstopt_offload = {
-	.flags		=	INET6_PROTO_GSO_EXTHDR,
+	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
 static const struct inet6_protocol nodata_protocol = {
@@ -549,32 +542,6 @@ static const struct inet6_protocol nodata_protocol = {
 	.flags		=	INET6_PROTO_NOPOLICY,
 };
 
-static int ipv6_exthdrs_offload_init(void)
-{
-	int ret;
-
-	ret = inet6_add_offload(&rthdr_offload, IPPROTO_ROUTING);
-	if (!ret)
-		goto out;
-
-	ret = inet6_add_offload(&dstopt_offload, IPPROTO_DSTOPTS);
-	if (!ret)
-		goto out_rt;
-
-out:
-	return ret;
-
-out_rt:
-	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
-	goto out;
-}
-
-static void ipv6_exthdrs_offload_exit(void)
-{
-	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
-	inet_del_offload(&rthdr_offload, IPPROTO_DSTOPTS);
-}
-
 int __init ipv6_exthdrs_init(void)
 {
 	int ret;
@@ -608,6 +575,7 @@ out_offload:
 
 void ipv6_exthdrs_exit(void)
 {
+	ipv6_exthdrs_offload_exit();
 	inet6_del_protocol(&nodata_protocol, IPPROTO_NONE);
 	inet6_del_protocol(&destopt_protocol, IPPROTO_DSTOPTS);
 	inet6_del_protocol(&rthdr_protocol, IPPROTO_ROUTING);
diff --git a/net/ipv6/exthdrs_offload.c b/net/ipv6/exthdrs_offload.c
new file mode 100644
index 0000000..913b9fc
--- /dev/null
+++ b/net/ipv6/exthdrs_offload.c
@@ -0,0 +1,48 @@
+/*
+ *	IPV6 GSO/GRO offload support
+ *	Linux INET6 implementation
+ *
+ *	This program is free software; you can redistribute it and/or
+ *      modify it under the terms of the GNU General Public License
+ *      as published by the Free Software Foundation; either version
+ *      2 of the License, or (at your option) any later version.
+ *
+ *      IPV6 Extension Header GSO/GRO support
+ */
+#include <net/protocol.h>
+#include "ip6_offload.h"
+
+static const struct net_offload rthdr_offload = {
+	.flags		=	INET6_PROTO_GSO_EXTHDR,
+};
+
+static const struct net_offload dstopt_offload = {
+	.flags		=	INET6_PROTO_GSO_EXTHDR,
+};
+
+int __init ipv6_exthdrs_offload_init(void)
+{
+	int ret;
+
+	ret = inet6_add_offload(&rthdr_offload, IPPROTO_ROUTING);
+	if (!ret)
+		goto out;
+
+	ret = inet6_add_offload(&dstopt_offload, IPPROTO_DSTOPTS);
+	if (!ret)
+		goto out_rt;
+
+out:
+	return ret;
+
+out_rt:
+	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
+	goto out;
+}
+
+void ipv6_exthdrs_offload_exit(void)
+{
+	inet_del_offload(&rthdr_offload, IPPROTO_ROUTING);
+	inet_del_offload(&rthdr_offload, IPPROTO_DSTOPTS);
+}
+
diff --git a/net/ipv6/ip6_offload.h b/net/ipv6/ip6_offload.h
index dff7936..4e88ddb 100644
--- a/net/ipv6/ip6_offload.h
+++ b/net/ipv6/ip6_offload.h
@@ -11,6 +11,9 @@
 #ifndef __ip6_offload_h
 #define __ip6_offload_h
 
+int ipv6_exthdrs_offload_init(void);
+void ipv6_exthdrs_offload_exit(void);
+
 int udp_offload_init(void);
 void udp_offload_cleanup(void);
 
-- 
1.7.7.6
