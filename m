From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH iptables] iptables: snat: add randomize-full support
Date: Sun, 22 Dec 2013 04:15:38 +0100
Message-ID: <20131222031538.GJ14073@order.stressinduktion.org>
References: <20131219134007.GA24118@order.stressinduktion.org> <52B37F6B.9010105@redhat.com> <20131220004822.GC32129@order.stressinduktion.org> <20131220080118.GA4234@localhost> <20131220214029.GB14073@order.stressinduktion.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
To: Pablo Neira Ayuso <pablo@netfilter.org>,
	Daniel Borkmann <dborkman@redhat.com>,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20131220214029.GB14073@order.stressinduktion.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <dborkman@redhat.com>

This patch provides the user space part for dnat in order to make
randomize-full support available in {ip,nf}tables. It allows for
enabling full port randomization that was motivated in [1] and
introduced to the kernel in [2].

Joint work between Hannes Frederic Sowa and Daniel Borkmann.

 [1] https://sites.google.com/site/hayashulman/files/NIC-derandomisation.pdf
 [2] http://patchwork.ozlabs.org/patch/304306/

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 extensions/libip6t_SNAT.c        | 18 ++++++++++++++----
 extensions/libipt_SNAT.c         | 18 ++++++++++++++----
 extensions/libxt_SNAT.man        |  7 ++++++-
 include/linux/netfilter/nf_nat.h | 12 ++++++++----
 4 files changed, 42 insertions(+), 13 deletions(-)

diff --git a/extensions/libip6t_SNAT.c b/extensions/libip6t_SNAT.c
index 7382ad0..8eb50b8 100644
--- a/extensions/libip6t_SNAT.c
+++ b/extensions/libip6t_SNAT.c
@@ -18,11 +18,13 @@
 enum {
 	O_TO_SRC = 0,
 	O_RANDOM,
+	O_RANDOM_FULLY,
 	O_PERSISTENT,
 	O_X_TO_SRC,
-	F_TO_SRC   = 1 << O_TO_SRC,
-	F_RANDOM   = 1 << O_RANDOM,
-	F_X_TO_SRC = 1 << O_X_TO_SRC,
+	F_TO_SRC       = 1 << O_TO_SRC,
+	F_RANDOM       = 1 << O_RANDOM,
+	F_RANDOM_FULLY = 1 << O_RANDOM_FULLY,
+	F_X_TO_SRC     = 1 << O_X_TO_SRC,
 };
 
 static void SNAT_help(void)
@@ -31,13 +33,14 @@ static void SNAT_help(void)
 "SNAT target options:\n"
 " --to-source [<ipaddr>[-<ipaddr>]][:port[-port]]\n"
 "				Address to map source to.\n"
-"[--random] [--persistent]\n");
+"[--random] [--random-fully] [--persistent]\n");
 }
 
 static const struct xt_option_entry SNAT_opts[] = {
 	{.name = "to-source", .id = O_TO_SRC, .type = XTTYPE_STRING,
 	 .flags = XTOPT_MAND | XTOPT_MULTI},
 	{.name = "random", .id = O_RANDOM, .type = XTTYPE_NONE},
+	{.name = "random-fully", .id = O_RANDOM_FULLY, .type = XTTYPE_NONE},
 	{.name = "persistent", .id = O_PERSISTENT, .type = XTTYPE_NONE},
 	XTOPT_TABLEEND,
 };
@@ -180,10 +183,13 @@ static void SNAT_parse(struct xt_option_call *cb)
 static void SNAT_fcheck(struct xt_fcheck_call *cb)
 {
 	static const unsigned int f = F_TO_SRC | F_RANDOM;
+	static const unsigned int r = F_TO_SRC | F_RANDOM_FULLY;
 	struct nf_nat_range *range = cb->data;
 
 	if ((cb->xflags & f) == f)
 		range->flags |= NF_NAT_RANGE_PROTO_RANDOM;
+	if ((cb->xflags & r) == r)
+		range->flags |= NF_NAT_RANGE_PROTO_RANDOM_FULLY;
 }
 
 static void print_range(const struct nf_nat_range *range)
@@ -215,6 +221,8 @@ static void SNAT_print(const void *ip, const struct xt_entry_target *target,
 	print_range(range);
 	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM)
 		printf(" random");
+	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY)
+		printf(" random-fully");
 	if (range->flags & NF_NAT_RANGE_PERSISTENT)
 		printf(" persistent");
 }
@@ -227,6 +235,8 @@ static void SNAT_save(const void *ip, const struct xt_entry_target *target)
 	print_range(range);
 	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM)
 		printf(" --random");
+	if (range->flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY)
+		printf(" --random-fully");
 	if (range->flags & NF_NAT_RANGE_PERSISTENT)
 		printf(" --persistent");
 }
diff --git a/extensions/libipt_SNAT.c b/extensions/libipt_SNAT.c
index 1a24f3d..78d2c2b 100644
--- a/extensions/libipt_SNAT.c
+++ b/extensions/libipt_SNAT.c
@@ -11,11 +11,13 @@
 enum {
 	O_TO_SRC = 0,
 	O_RANDOM,
+	O_RANDOM_FULLY,
 	O_PERSISTENT,
 	O_X_TO_SRC,
-	F_TO_SRC   = 1 << O_TO_SRC,
-	F_RANDOM   = 1 << O_RANDOM,
-	F_X_TO_SRC = 1 << O_X_TO_SRC,
+	F_TO_SRC       = 1 << O_TO_SRC,
+	F_RANDOM       = 1 << O_RANDOM,
+	F_RANDOM_FULLY = 1 << O_RANDOM_FULLY,
+	F_X_TO_SRC     = 1 << O_X_TO_SRC,
 };
 
 /* Source NAT data consists of a multi-range, indicating where to map
@@ -32,13 +34,14 @@ static void SNAT_help(void)
 "SNAT target options:\n"
 " --to-source [<ipaddr>[-<ipaddr>]][:port[-port]]\n"
 "				Address to map source to.\n"
-"[--random] [--persistent]\n");
+"[--random] [--random-fully] [--persistent]\n");
 }
 
 static const struct xt_option_entry SNAT_opts[] = {
 	{.name = "to-source", .id = O_TO_SRC, .type = XTTYPE_STRING,
 	 .flags = XTOPT_MAND | XTOPT_MULTI},
 	{.name = "random", .id = O_RANDOM, .type = XTTYPE_NONE},
+	{.name = "random-fully", .id = O_RANDOM_FULLY, .type = XTTYPE_NONE},
 	{.name = "persistent", .id = O_PERSISTENT, .type = XTTYPE_NONE},
 	XTOPT_TABLEEND,
 };
@@ -185,10 +188,13 @@ static void SNAT_parse(struct xt_option_call *cb)
 static void SNAT_fcheck(struct xt_fcheck_call *cb)
 {
 	static const unsigned int f = F_TO_SRC | F_RANDOM;
+	static const unsigned int r = F_TO_SRC | F_RANDOM_FULLY;
 	struct nf_nat_ipv4_multi_range_compat *mr = cb->data;
 
 	if ((cb->xflags & f) == f)
 		mr->range[0].flags |= NF_NAT_RANGE_PROTO_RANDOM;
+	if ((cb->xflags & r) == r)
+		mr->range[0].flags |= NF_NAT_RANGE_PROTO_RANDOM_FULLY;
 }
 
 static void print_range(const struct nf_nat_ipv4_range *r)
@@ -222,6 +228,8 @@ static void SNAT_print(const void *ip, const struct xt_entry_target *target,
 		print_range(&info->mr.range[i]);
 		if (info->mr.range[i].flags & NF_NAT_RANGE_PROTO_RANDOM)
 			printf(" random");
+		if (info->mr.range[i].flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY)
+			printf(" random-fully");
 		if (info->mr.range[i].flags & NF_NAT_RANGE_PERSISTENT)
 			printf(" persistent");
 	}
@@ -237,6 +245,8 @@ static void SNAT_save(const void *ip, const struct xt_entry_target *target)
 		print_range(&info->mr.range[i]);
 		if (info->mr.range[i].flags & NF_NAT_RANGE_PROTO_RANDOM)
 			printf(" --random");
+		if (info->mr.range[i].flags & NF_NAT_RANGE_PROTO_RANDOM_FULLY)
+			printf(" --random-fully");
 		if (info->mr.range[i].flags & NF_NAT_RANGE_PERSISTENT)
 			printf(" --persistent");
 	}
diff --git a/extensions/libxt_SNAT.man b/extensions/libxt_SNAT.man
index f0620a2..8cd0b80 100644
--- a/extensions/libxt_SNAT.man
+++ b/extensions/libxt_SNAT.man
@@ -29,7 +29,12 @@ anymore.
 \fB\-\-random\fP
 If option
 \fB\-\-random\fP
-is used then port mapping will be randomized (kernel >= 2.6.21).
+is used then port mapping will be randomized through a hash-based algorithm (kernel >= 2.6.21).
+.TP
+\fB\-\-random-fully\fP
+If option
+\fB\-\-random-fully\fP
+is used then port mapping will be fully randomized through a PRNG (kernel >= 3.14).
 .TP
 \fB\-\-persistent\fP
 Gives a client the same source-/destination-address for each connection.
diff --git a/include/linux/netfilter/nf_nat.h b/include/linux/netfilter/nf_nat.h
index bf0cc37..1ad3659 100644
--- a/include/linux/netfilter/nf_nat.h
+++ b/include/linux/netfilter/nf_nat.h
@@ -4,10 +4,14 @@
 #include <linux/netfilter.h>
 #include <linux/netfilter/nf_conntrack_tuple_common.h>
 
-#define NF_NAT_RANGE_MAP_IPS		1
-#define NF_NAT_RANGE_PROTO_SPECIFIED	2
-#define NF_NAT_RANGE_PROTO_RANDOM	4
-#define NF_NAT_RANGE_PERSISTENT		8
+#define NF_NAT_RANGE_MAP_IPS			(1 << 0)
+#define NF_NAT_RANGE_PROTO_SPECIFIED		(1 << 1)
+#define NF_NAT_RANGE_PROTO_RANDOM		(1 << 2)
+#define NF_NAT_RANGE_PERSISTENT			(1 << 3)
+#define NF_NAT_RANGE_PROTO_RANDOM_FULLY		(1 << 4)
+
+#define NF_NAT_RANGE_PROTO_RANDOM_ALL		\
+	(NF_NAT_RANGE_PROTO_RANDOM | NF_NAT_RANGE_PROTO_RANDOM_FULLY)
 
 struct nf_nat_ipv4_range {
 	unsigned int			flags;
-- 
1.8.3.1

