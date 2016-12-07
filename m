From: Pablo Neira Ayuso <pablo@netfilter.org>
Subject: [PATCH 05/50] netfilter: built-in NAT support for SCTP
Date: Wed,  7 Dec 2016 22:52:11 +0100
Message-ID: <1481147576-5690-6-git-send-email-pablo@netfilter.org>
References: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: netfilter-devel@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1481147576-5690-1-git-send-email-pablo@netfilter.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Davide Caratti <dcaratti@redhat.com>

CONFIG_NF_NAT_PROTO_SCTP is no more a tristate. When set to y, NAT
support for SCTP protocol is built-in into nf_nat.ko.

footprint test:

(nf_nat_proto_)           | sctp   || nf_nat
--------------------------+--------++--------
no builtin                | 428344 || 2241312
SCTP builtin              |   -    || 2597032

Signed-off-by: Davide Caratti <dcaratti@redhat.com>
Signed-off-by: Pablo Neira Ayuso <pablo@netfilter.org>
---
 include/net/netfilter/nf_nat_l4proto.h |  3 +++
 net/netfilter/Kconfig                  |  2 +-
 net/netfilter/Makefile                 |  2 +-
 net/netfilter/nf_nat_core.c            |  4 ++++
 net/netfilter/nf_nat_proto_sctp.c      | 35 +---------------------------------
 5 files changed, 10 insertions(+), 36 deletions(-)

diff --git a/include/net/netfilter/nf_nat_l4proto.h b/include/net/netfilter/nf_nat_l4proto.h
index 92b147be00ef..2cbaf3856e21 100644
--- a/include/net/netfilter/nf_nat_l4proto.h
+++ b/include/net/netfilter/nf_nat_l4proto.h
@@ -57,6 +57,9 @@ extern const struct nf_nat_l4proto nf_nat_l4proto_unknown;
 #ifdef CONFIG_NF_NAT_PROTO_DCCP
 extern const struct nf_nat_l4proto nf_nat_l4proto_dccp;
 #endif
+#ifdef CONFIG_NF_NAT_PROTO_SCTP
+extern const struct nf_nat_l4proto nf_nat_l4proto_sctp;
+#endif
 
 bool nf_nat_l4proto_in_range(const struct nf_conntrack_tuple *tuple,
 			     enum nf_nat_manip_type maniptype,
diff --git a/net/netfilter/Kconfig b/net/netfilter/Kconfig
index 13092e5cd245..ad72edf1f6ec 100644
--- a/net/netfilter/Kconfig
+++ b/net/netfilter/Kconfig
@@ -394,7 +394,7 @@ config NF_NAT_PROTO_UDPLITE
 	default NF_NAT && NF_CT_PROTO_UDPLITE
 
 config NF_NAT_PROTO_SCTP
-	tristate
+	bool
 	default NF_NAT && NF_CT_PROTO_SCTP
 	depends on NF_NAT && NF_CT_PROTO_SCTP
 	select LIBCRC32C
diff --git a/net/netfilter/Makefile b/net/netfilter/Makefile
index 9ea0c98e51e6..02ef6decf94d 100644
--- a/net/netfilter/Makefile
+++ b/net/netfilter/Makefile
@@ -46,6 +46,7 @@ nf_nat-y	:= nf_nat_core.o nf_nat_proto_unknown.o nf_nat_proto_common.o \
 		   nf_nat_proto_udp.o nf_nat_proto_tcp.o nf_nat_helper.o
 
 nf_nat-$(CONFIG_NF_NAT_PROTO_DCCP) += nf_nat_proto_dccp.o
+nf_nat-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
 # generic transport layer logging
 obj-$(CONFIG_NF_LOG_COMMON) += nf_log_common.o
@@ -58,7 +59,6 @@ obj-$(CONFIG_NF_NAT_REDIRECT) += nf_nat_redirect.o
 
 # NAT protocols (nf_nat)
 obj-$(CONFIG_NF_NAT_PROTO_UDPLITE) += nf_nat_proto_udplite.o
-obj-$(CONFIG_NF_NAT_PROTO_SCTP) += nf_nat_proto_sctp.o
 
 # NAT helpers
 obj-$(CONFIG_NF_NAT_AMANDA) += nf_nat_amanda.o
diff --git a/net/netfilter/nf_nat_core.c b/net/netfilter/nf_nat_core.c
index 69b121d11275..80858bd110cc 100644
--- a/net/netfilter/nf_nat_core.c
+++ b/net/netfilter/nf_nat_core.c
@@ -686,6 +686,10 @@ int nf_nat_l3proto_register(const struct nf_nat_l3proto *l3proto)
 	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_DCCP],
 			 &nf_nat_l4proto_dccp);
 #endif
+#ifdef CONFIG_NF_NAT_PROTO_SCTP
+	RCU_INIT_POINTER(nf_nat_l4protos[l3proto->l3proto][IPPROTO_SCTP],
+			 &nf_nat_l4proto_sctp);
+#endif
 	mutex_unlock(&nf_nat_proto_mutex);
 
 	RCU_INIT_POINTER(nf_nat_l3protos[l3proto->l3proto], l3proto);
diff --git a/net/netfilter/nf_nat_proto_sctp.c b/net/netfilter/nf_nat_proto_sctp.c
index cbc7ade1487b..2e14108ff697 100644
--- a/net/netfilter/nf_nat_proto_sctp.c
+++ b/net/netfilter/nf_nat_proto_sctp.c
@@ -7,9 +7,7 @@
  */
 
 #include <linux/types.h>
-#include <linux/init.h>
 #include <linux/sctp.h>
-#include <linux/module.h>
 #include <net/sctp/checksum.h>
 
 #include <net/netfilter/nf_nat_l4proto.h>
@@ -54,7 +52,7 @@ sctp_manip_pkt(struct sk_buff *skb,
 	return true;
 }
 
-static const struct nf_nat_l4proto nf_nat_l4proto_sctp = {
+const struct nf_nat_l4proto nf_nat_l4proto_sctp = {
 	.l4proto		= IPPROTO_SCTP,
 	.manip_pkt		= sctp_manip_pkt,
 	.in_range		= nf_nat_l4proto_in_range,
@@ -63,34 +61,3 @@ static const struct nf_nat_l4proto nf_nat_l4proto_sctp = {
 	.nlattr_to_range	= nf_nat_l4proto_nlattr_to_range,
 #endif
 };
-
-static int __init nf_nat_proto_sctp_init(void)
-{
-	int err;
-
-	err = nf_nat_l4proto_register(NFPROTO_IPV4, &nf_nat_l4proto_sctp);
-	if (err < 0)
-		goto err1;
-	err = nf_nat_l4proto_register(NFPROTO_IPV6, &nf_nat_l4proto_sctp);
-	if (err < 0)
-		goto err2;
-	return 0;
-
-err2:
-	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_sctp);
-err1:
-	return err;
-}
-
-static void __exit nf_nat_proto_sctp_exit(void)
-{
-	nf_nat_l4proto_unregister(NFPROTO_IPV6, &nf_nat_l4proto_sctp);
-	nf_nat_l4proto_unregister(NFPROTO_IPV4, &nf_nat_l4proto_sctp);
-}
-
-module_init(nf_nat_proto_sctp_init);
-module_exit(nf_nat_proto_sctp_exit);
-
-MODULE_LICENSE("GPL");
-MODULE_DESCRIPTION("SCTP NAT protocol helper");
-MODULE_AUTHOR("Patrick McHardy <kaber@trash.net>");
-- 
2.1.4

