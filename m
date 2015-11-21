From: Tejun Heo <tj@kernel.org>
Subject: [PATCH 1/2 iptables] libxt_cgroup: prepare for multi revisions
Date: Sat, 21 Nov 2015 11:18:46 -0500
Message-ID: <20151121161846.GB3428@htj.duckdns.org>
References: <1448122441-9335-1-git-send-email-tj@kernel.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: lizefan@huawei.com, hannes@cmpxchg.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, coreteam@netfilter.org,
	cgroups@vger.kernel.org, linux-kernel@vger.kernel.org,
	kernel-team@fb.com, ninasc@fb.com
To: davem@davemloft.net, pablo@netfilter.org, kaber@trash.net,
	kadlec@blackhole.kfki.hu, daniel@iogearbox.net,
	daniel.wagner@bmw-carit.de, nhorman@tuxdriver.com
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1448122441-9335-1-git-send-email-tj@kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

libxt_cgroup will grow cgroup2 path based match.  Postfix existing
symbols with _v0 and prepare for multi revision registration.  While
at it, rename O_CGROUP to O_CLASSID and fwid to classid.

Signed-off-by: Tejun Heo <tj@kernel.org>
Cc: Daniel Borkmann <dborkman@redhat.com>
Cc: Jan Engelhardt <jengelh@inai.de>
Cc: Pablo Neira Ayuso <pablo@netfilter.org>
---
 extensions/libxt_cgroup.c           |   51 +++++++++++++++++++-----------------
 include/linux/netfilter/xt_cgroup.h |    2 -
 2 files changed, 28 insertions(+), 25 deletions(-)

--- a/extensions/libxt_cgroup.c
+++ b/extensions/libxt_cgroup.c
@@ -3,30 +3,30 @@
 #include <linux/netfilter/xt_cgroup.h>
 
 enum {
-	O_CGROUP = 0,
+	O_CLASSID = 0,
 };
 
-static void cgroup_help(void)
+static void cgroup_help_v0(void)
 {
 	printf(
 "cgroup match options:\n"
-"[!] --cgroup fwid  Match cgroup fwid\n");
+"[!] --cgroup classid            Match cgroup classid\n");
 }
 
-static const struct xt_option_entry cgroup_opts[] = {
+static const struct xt_option_entry cgroup_opts_v0[] = {
 	{
 		.name = "cgroup",
-		.id = O_CGROUP,
+		.id = O_CLASSID,
 		.type = XTTYPE_UINT32,
 		.flags = XTOPT_INVERT | XTOPT_MAND | XTOPT_PUT,
-		XTOPT_POINTER(struct xt_cgroup_info, id)
+		XTOPT_POINTER(struct xt_cgroup_info_v0, id)
 	},
 	XTOPT_TABLEEND,
 };
 
-static void cgroup_parse(struct xt_option_call *cb)
+static void cgroup_parse_v0(struct xt_option_call *cb)
 {
-	struct xt_cgroup_info *cgroupinfo = cb->data;
+	struct xt_cgroup_info_v0 *cgroupinfo = cb->data;
 
 	xtables_option_parse(cb);
 	if (cb->invert)
@@ -34,34 +34,37 @@ static void cgroup_parse(struct xt_optio
 }
 
 static void
-cgroup_print(const void *ip, const struct xt_entry_match *match, int numeric)
+cgroup_print_v0(const void *ip, const struct xt_entry_match *match, int numeric)
 {
-	const struct xt_cgroup_info *info = (void *) match->data;
+	const struct xt_cgroup_info_v0 *info = (void *) match->data;
 
 	printf(" cgroup %s%u", info->invert ? "! ":"", info->id);
 }
 
-static void cgroup_save(const void *ip, const struct xt_entry_match *match)
+static void cgroup_save_v0(const void *ip, const struct xt_entry_match *match)
 {
-	const struct xt_cgroup_info *info = (void *) match->data;
+	const struct xt_cgroup_info_v0 *info = (void *) match->data;
 
 	printf("%s --cgroup %u", info->invert ? " !" : "", info->id);
 }
 
-static struct xtables_match cgroup_match = {
-	.family		= NFPROTO_UNSPEC,
-	.name		= "cgroup",
-	.version	= XTABLES_VERSION,
-	.size		= XT_ALIGN(sizeof(struct xt_cgroup_info)),
-	.userspacesize	= XT_ALIGN(sizeof(struct xt_cgroup_info)),
-	.help		= cgroup_help,
-	.print		= cgroup_print,
-	.save		= cgroup_save,
-	.x6_parse	= cgroup_parse,
-	.x6_options	= cgroup_opts,
+static struct xtables_match cgroup_match[] = {
+	{
+		.family		= NFPROTO_UNSPEC,
+		.revision	= 0,
+		.name		= "cgroup",
+		.version	= XTABLES_VERSION,
+		.size		= XT_ALIGN(sizeof(struct xt_cgroup_info_v0)),
+		.userspacesize	= XT_ALIGN(sizeof(struct xt_cgroup_info_v0)),
+		.help		= cgroup_help_v0,
+		.print		= cgroup_print_v0,
+		.save		= cgroup_save_v0,
+		.x6_parse	= cgroup_parse_v0,
+		.x6_options	= cgroup_opts_v0,
+	},
 };
 
 void _init(void)
 {
-	xtables_register_match(&cgroup_match);
+	xtables_register_matches(cgroup_match, ARRAY_SIZE(cgroup_match));
 }
--- a/include/linux/netfilter/xt_cgroup.h
+++ b/include/linux/netfilter/xt_cgroup.h
@@ -3,7 +3,7 @@
 
 #include <linux/types.h>
 
-struct xt_cgroup_info {
+struct xt_cgroup_info_v0 {
 	__u32 id;
 	__u32 invert;
 };
