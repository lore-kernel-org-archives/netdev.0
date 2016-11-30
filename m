From: Amir Vadai <amir@vadai.me>
Subject: [PATCH iproute2 V3 1/3] libnetlink: Introduce rta_getattr_be*()
Date: Wed, 30 Nov 2016 09:38:38 +0200
Message-ID: <20161130073840.5269-2-amir@vadai.me>
References: <20161130073840.5269-1-amir@vadai.me>
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
        Or Gerlitz <ogerlitz@mellanox.com>,
        Hadar Har-Zion <hadarh@mellanox.com>,
        Jiri Pirko <jiri@mellanox.com>, Jiri Benc <jbenc@redhat.com>,
        Amir Vadai <amir@vadai.me>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f196.google.com ([209.85.210.196]:36614 "EHLO
        mail-wj0-f196.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755401AbcK3HnJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 30 Nov 2016 02:43:09 -0500
Received: by mail-wj0-f196.google.com with SMTP id jb2so21015101wjb.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 23:43:09 -0800 (PST)
In-Reply-To: <20161130073840.5269-1-amir@vadai.me>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add the utility functions rta_getattr_be16() and rta_getattr_be32(), and
change existing code to use it.

Signed-off-by: Amir Vadai <amir@vadai.me>
---
 bridge/fdb.c         | 4 ++--
 include/libnetlink.h | 9 +++++++++
 ip/iplink_geneve.c   | 2 +-
 ip/iplink_vxlan.c    | 2 +-
 4 files changed, 13 insertions(+), 4 deletions(-)

diff --git a/bridge/fdb.c b/bridge/fdb.c
index 90f4b154c5dc..a91521776e99 100644
--- a/bridge/fdb.c
+++ b/bridge/fdb.c
@@ -168,10 +168,10 @@ int print_fdb(const struct sockaddr_nl *who, struct nlmsghdr *n, void *arg)
 	if (tb[NDA_PORT]) {
 		if (jw_global)
 			jsonw_uint_field(jw_global, "port",
-					 ntohs(rta_getattr_u16(tb[NDA_PORT])));
+					 rta_getattr_be16(tb[NDA_PORT]));
 		else
 			fprintf(fp, "port %d ",
-				ntohs(rta_getattr_u16(tb[NDA_PORT])));
+				rta_getattr_be16(tb[NDA_PORT]));
 	}
 
 	if (tb[NDA_VNI]) {
diff --git a/include/libnetlink.h b/include/libnetlink.h
index 483509ca9635..751ebf186dd4 100644
--- a/include/libnetlink.h
+++ b/include/libnetlink.h
@@ -10,6 +10,7 @@
 #include <linux/if_addr.h>
 #include <linux/neighbour.h>
 #include <linux/netconf.h>
+#include <arpa/inet.h>
 
 struct rtnl_handle {
 	int			fd;
@@ -140,10 +141,18 @@ static inline __u16 rta_getattr_u16(const struct rtattr *rta)
 {
 	return *(__u16 *)RTA_DATA(rta);
 }
+static inline __be16 rta_getattr_be16(const struct rtattr *rta)
+{
+	return ntohs(rta_getattr_u16(rta));
+}
 static inline __u32 rta_getattr_u32(const struct rtattr *rta)
 {
 	return *(__u32 *)RTA_DATA(rta);
 }
+static inline __be32 rta_getattr_be32(const struct rtattr *rta)
+{
+	return ntohl(rta_getattr_u32(rta));
+}
 static inline __u64 rta_getattr_u64(const struct rtattr *rta)
 {
 	__u64 tmp;
diff --git a/ip/iplink_geneve.c b/ip/iplink_geneve.c
index 3bfba91c644c..1e6669d07d60 100644
--- a/ip/iplink_geneve.c
+++ b/ip/iplink_geneve.c
@@ -234,7 +234,7 @@ static void geneve_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_GENEVE_PORT])
 		fprintf(f, "dstport %u ",
-			ntohs(rta_getattr_u16(tb[IFLA_GENEVE_PORT])));
+			rta_getattr_be16(tb[IFLA_GENEVE_PORT]));
 
 	if (tb[IFLA_GENEVE_COLLECT_METADATA])
 		fputs("external ", f);
diff --git a/ip/iplink_vxlan.c b/ip/iplink_vxlan.c
index 93af979a1e97..6d02bb47b2f0 100644
--- a/ip/iplink_vxlan.c
+++ b/ip/iplink_vxlan.c
@@ -413,7 +413,7 @@ static void vxlan_print_opt(struct link_util *lu, FILE *f, struct rtattr *tb[])
 
 	if (tb[IFLA_VXLAN_PORT])
 		fprintf(f, "dstport %u ",
-			ntohs(rta_getattr_u16(tb[IFLA_VXLAN_PORT])));
+			rta_getattr_be16(tb[IFLA_VXLAN_PORT]));
 
 	if (tb[IFLA_VXLAN_LEARNING] &&
 	    !rta_getattr_u8(tb[IFLA_VXLAN_LEARNING]))
-- 
2.10.2
