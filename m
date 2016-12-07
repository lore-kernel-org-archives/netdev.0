From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 06/50] netfilter: built-in NAT support for UDPlite
Date: Wed,  7 Dec 2016 22:52:12 +0100
Message-ID: <1481147576-5690-7-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.us.es ([193.147.175.20]:60052 "EHLO mail.us.es"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S933042AbcLGVxN (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 7 Dec 2016 16:53:13 -0500
Received: from antivirus1-rhel7.int (unknown [192.168.2.11])
        by mail.us.es (Postfix) with ESMTP id 20B62C9EDB
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:12 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id 0C3A9DA843
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:12 +0100 (CET)
Received: from antivirus1-rhel7.int (localhost [127.0.0.1])
        by antivirus1-rhel7.int (Postfix) with ESMTP id D5D40DA861
        for <netdev@vger.kernel.org>; Wed,  7 Dec 2016 22:53:09 +0100 (CET)
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Davide Caratti <dcaratti@redhat.com>

CONFIG_NF_NAT_PROTO_UDPLITE is no more a tristate. When set to y, NAT
support for UDPlite protocol is built-in into nf_nat.ko.

footprint test:

(nf_nat_proto_)           |udplite || nf_nat
--------------------------+--------++--------
no builtin                | 408048 || 2241312
UDPLITE builtin           |   -    || 2577256

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat_l4proto.h |  3 +++
 net/netfilter/Kconfig                  |  2 +-
 net/netfilter/Makefile                 |  5 ++---
 net/netfilter/nf_nat_core.c            |  4 ++++
 net/netfilter/nf_nat_proto_udplite.c   | 35 +---------------------------------
 5 files changed, 11 insertions(+), 38 deletions(-)

diff --git a/include/net/netfilter/nf_nat_l4proto.h b/include/net/netfilter/nf_nat_l4proto.h
index 2cbaf3856e21..3923150f2a1e 100644
--- a/include/net/netfilter/nf_nat_l4proto.h
+++ b/include/net/netfilter/nf_nat_l4proto.h
@@ -60,6 +60,9 @@ extern const struct nf_nat_l4proto nf_nat_l4proto_dccp;
 #ifdef CONFIG_NF_NAT_PROTO_SCTP
 extern const struct nf_nat_l4proto nf_nat_l4proto_sctp;
 #endif
+#ifdef CONFIG_NF_NAT_PROTO_UDPLITE
+extern const struct nf_nat_l4proto nf_nat_l4proto_udplite;
+#endif
 
 bool nf_nat_l4proto_in_range(const struct nf_conntrack_tuple *tuple,
 			     enum nf_nat_manip_type maniptype,
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index ad72edf1f6ec..496e1dcbd003 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -389,7 +389,7 @@ config NF_NAT_PROTO_DCCP
 	default NF_NAT && NF_CT_PROTO_DCCP
 
 config NF_NAT_PROTO_UDPLITE
-	tristate
+	bool
 	depends on NF_NAT && NF_CT_PROTO_UDPLITE
 	default NF_NAT && NF_CT_PROTO_UDPLITE
 
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 02ef6decf94d..3b97d89df2cd 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -45,8 +45,10 @@ obj-$(CONFIG_NF_CONNTRACK_TFTP) += nf_conntrack_tftp.o
 nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 		   nf_nat_proto_udp.o nf_nat_proto_tcp.o nf_nat_helper.o
 
+# NAT protocols (nf_nat)
 nf_nat-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
 nf_nat-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
+nf_nat-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 
 # generic transport layer logging
 obj-$(CONFIG_NF_LOG_COMMON) += nf_log_common.o
@@ -57,9 +59,6 @@ obj-$(CONFIG_NF_LOG_NETDEV) += nf_log_netdev.o
 obj-$(CONFIG_NF_NAT) += nf_nat.o
 obj-$(CONFIG_NF_NAT_REDIRECT) += nf_nat_redirect.o
 
-# NAT protocols (nf_nat)
-obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
-
 # NAT helpers
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
 obj-$(CONFIG_NF_NAT_FTP) += nf_nat_ftp.o
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 80858bd110cc..94b14c5a8b17 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -690,6 +690,10 @@ int nf_nat_l3proto_register(const struct nf_nat_l3proto *l3proto)
 	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_SCTP],
 			 &nf_nat_l4proto_sctp);
 #endif
+#ifdef CONFIG_NF_NAT_PROTO_UDPLITE
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_UDPLITE],
+			 &nf_nat_l4proto_udplite);
+#endif
 	mutex_unlock(&nf_nat_proto_mutex);
 
 	RCU_INIT_POINTER(nf_nat_l3protos[l3proto->l3proto], l3proto);
diff --git a/net/netfilter/nf_nat_proto_udplite.c b/net/netfilter/nf_nat_proto_udplite.c
index 58340c97bd83..366bfbfd82a1 100644
--- a/net/netfilter/nf_nat_proto_udplite.c
+++ b/net/netfilter/nf_nat_proto_udplite.c
@@ -8,11 +8,9 @@
  */
 
 #include <linux/types.h>
-#include <linux/init.h>
 #include <linux/udp.h>
 
 #include <linux/netfilter.h>
-#include <linux/module.h>
 #include <net/netfilter/nf_nat.h>
 #include <net/netfilter/nf_nat_l3proto.h>
 #include <net/netfilter/nf_nat_l4proto.h>
@@ -64,7 +62,7 @@ udplite_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-static const struct nf_nat_l4proto nf_nat_l4proto_udplite = {
+const struct nf_nat_l4proto nf_nat_l4proto_udplite = {
 	.l4proto		= IPPROTO_UDPLITE,
 	.manip_pkt		= udplite_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
@@ -73,34 +71,3 @@ static const struct nf_nat_l4proto nf_nat_l4proto_udplite = {
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
-
-static int __init nf_nat_proto_udplite_init(void)
-{
-	int err;
-
-	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_udplite);
-	if (err < 0)
-		goto err1;
-	err = nf_nat_l4proto_register(NFPROTO_IPV6, &nf_nat_l4proto_udplite);
-	if (err < 0)
-		goto err2;
-	return 0;
-
-err2:
-	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_udplite);
-err1:
-	return err;
-}
-
-static void __exit nf_nat_proto_udplite_fini(void)
-{
-	nf_nat_l4proto_unregister(NFPROTO_IPV6, &nf_nat_l4proto_udplite);
-	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_udplite);
-}
-
-module_init(nf_nat_proto_udplite_init);
-module_exit(nf_nat_proto_udplite_fini);
-
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("UDP-Lite NAT protocol helper");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-- 
2.1.4
