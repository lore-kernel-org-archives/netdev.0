From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 04/50] netfilter: built-in NAT support for DCCP
Date: Wed,  7 Dec 2016 22:52:10 +0100
Message-ID: <1481147576-5690-5-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davide Caratti <dcaratti@redhat.com>

CONFIG_NF_NAT_PROTO_DCCP is no more a tristate. When set to y, NAT
support for DCCP protocol is built-in into nf_nat.ko.

footprint test:

(nf_nat_proto_)           | dccp   || nf_nat
--------------------------+--------++--------
no builtin                | 409800 || 2241312
DCCP builtin              |   -    || 2578968

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat_l4proto.h |  3 +++
 net/netfilter/Kconfig                  |  2 +-
 net/netfilter/Makefile                 |  3 ++-
 net/netfilter/nf_nat_core.c            |  4 ++++
 net/netfilter/nf_nat_proto_dccp.c      | 36 +---------------------------------
 5 files changed, 11 insertions(+), 37 deletions(-)

diff --git a/include/net/netfilter/nf_nat_l4proto.h b/include/net/netfilter/nf_nat_l4proto.h
index 12f4cc841b6e..92b147be00ef 100644
--- a/include/net/netfilter/nf_nat_l4proto.h
+++ b/include/net/netfilter/nf_nat_l4proto.h
@@ -54,6 +54,9 @@ extern const struct nf_nat_l4proto nf_nat_l4proto_udp;
 extern const struct nf_nat_l4proto nf_nat_l4proto_icmp;
 extern const struct nf_nat_l4proto nf_nat_l4proto_icmpv6;
 extern const struct nf_nat_l4proto nf_nat_l4proto_unknown;
+#ifdef CONFIG_NF_NAT_PROTO_DCCP
+extern const struct nf_nat_l4proto nf_nat_l4proto_dccp;
+#endif
 
 bool nf_nat_l4proto_in_range(const struct nf_conntrack_tuple *tuple,
 			     enum nf_nat_manip_type maniptype,
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 44410d30d461..13092e5cd245 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -384,7 +384,7 @@ config NF_NAT_NEEDED
 	default y
 
 config NF_NAT_PROTO_DCCP
-	tristate
+	bool
 	depends on NF_NAT && NF_CT_PROTO_DCCP
 	default NF_NAT && NF_CT_PROTO_DCCP
 
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 5bbf767672ec..9ea0c98e51e6 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -45,6 +45,8 @@ obj-$(CONFIG_NF_CONNTRACK_TFTP) += nf_conntrack_tftp.o
 nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 		   nf_nat_proto_udp.o nf_nat_proto_tcp.o nf_nat_helper.o
 
+nf_nat-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
+
 # generic transport layer logging
 obj-$(CONFIG_NF_LOG_COMMON) += nf_log_common.o
 
@@ -55,7 +57,6 @@ obj-$(CONFIG_NF_NAT) += nf_nat.o
 obj-$(CONFIG_NF_NAT_REDIRECT) += nf_nat_redirect.o
 
 # NAT protocols (nf_nat)
-obj-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
 obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
 obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 5b9c884a452e..69b121d11275 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -682,6 +682,10 @@ int nf_nat_l3proto_register(const struct nf_nat_l3proto *l3proto)
 			 &nf_nat_l4proto_tcp);
 	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_UDP],
 			 &nf_nat_l4proto_udp);
+#ifdef CONFIG_NF_NAT_PROTO_DCCP
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_DCCP],
+			 &nf_nat_l4proto_dccp);
+#endif
 	mutex_unlock(&nf_nat_proto_mutex);
 
 	RCU_INIT_POINTER(nf_nat_l3protos[l3proto->l3proto], l3proto);
diff --git a/net/netfilter/nf_nat_proto_dccp.c b/net/netfilter/nf_nat_proto_dccp.c
index 15c47b246d0d..269fcd5dc34c 100644
--- a/net/netfilter/nf_nat_proto_dccp.c
+++ b/net/netfilter/nf_nat_proto_dccp.c
@@ -10,8 +10,6 @@
  */
 
 #include <linux/kernel.h>
-#include <linux/module.h>
-#include <linux/init.h>
 #include <linux/skbuff.h>
 #include <linux/dccp.h>
 
@@ -73,7 +71,7 @@ dccp_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-static const struct nf_nat_l4proto nf_nat_l4proto_dccp = {
+const struct nf_nat_l4proto nf_nat_l4proto_dccp = {
 	.l4proto		= IPPROTO_DCCP,
 	.manip_pkt		= dccp_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
@@ -82,35 +80,3 @@ static const struct nf_nat_l4proto nf_nat_l4proto_dccp = {
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
-
-static int __init nf_nat_proto_dccp_init(void)
-{
-	int err;
-
-	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_dccp);
-	if (err < 0)
-		goto err1;
-	err = nf_nat_l4proto_register(NFPROTO_IPV6, &nf_nat_l4proto_dccp);
-	if (err < 0)
-		goto err2;
-	return 0;
-
-err2:
-	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_dccp);
-err1:
-	return err;
-}
-
-static void __exit nf_nat_proto_dccp_fini(void)
-{
-	nf_nat_l4proto_unregister(NFPROTO_IPV6, &nf_nat_l4proto_dccp);
-	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_dccp);
-
-}
-
-module_init(nf_nat_proto_dccp_init);
-module_exit(nf_nat_proto_dccp_fini);
-
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-MODULE_DESCRIPTION("DCCP NAT protocol helper");
-MODULE_LICENSE("GPL");
-- 
2.1.4

