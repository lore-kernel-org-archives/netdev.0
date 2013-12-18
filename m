From: Fan Du <fan.du@windriver.com>
Subject: [PATCHv2 iptables] iptables: Add IPv4/6 IPcomp match support
Date: Wed, 18 Dec 2013 11:27:22 +0800
Message-ID: <1387337242-28865-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail1.windriver.com ([147.11.146.13]:40930 "EHLO
	mail1.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751465Ab3LRD1V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Dec 2013 22:27:21 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables user to set iptables ACTIONs for IPcomp
flow specified by its SPI value.

For example:
iptables  -A OUTPUT -p 108 -m ipcomp --ipcompspi 0x12 -j DROP
ip6tables -A OUTPUT -p 108 -m ipcomp --ipcompspi 0x12 -j DROP

IPcomp packet with spi as 0x12 will be dropped.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
v2:
  Consolidate libipt_ipcomp.c and libip6t_ipcomp.c into one libxt_ipcomp.c
---
 extensions/libxt_ipcomp.c           |  116 +++++++++++++++++++++++++++++++++++
 extensions/libxt_ipcomp.c.man       |    7 +++
 include/linux/netfilter/xt_ipcomp.h |   16 +++++
 3 files changed, 139 insertions(+)
 create mode 100644 extensions/libxt_ipcomp.c
 create mode 100644 extensions/libxt_ipcomp.c.man
 create mode 100644 include/linux/netfilter/xt_ipcomp.h

diff --git a/extensions/libxt_ipcomp.c b/extensions/libxt_ipcomp.c
new file mode 100644
index 0000000..1753fc3
--- /dev/null
+++ b/extensions/libxt_ipcomp.c
@@ -0,0 +1,116 @@
+#include <stdio.h>
+#include <xtables.h>
+#include <linux/netfilter/xt_ipcomp.h>
+
+enum {
+	O_compSPI = 0,
+	O_compRES,
+};
+
+static void comp_help(void)
+{
+	printf(
+"comp match options:\n"
+"[!] --ipcompspi spi[:spi]\n"
+"				match spi (range)\n");
+}
+
+static const struct xt_option_entry comp_opts[] = {
+	{.name = "ipcompspi", .id = O_compSPI, .type = XTTYPE_UINT32RC,
+	 .flags = XTOPT_INVERT | XTOPT_PUT,
+	 XTOPT_POINTER(struct ipt_comp, spis)},
+	{.name = "compres", .id = O_compRES, .type = XTTYPE_NONE},
+	XTOPT_TABLEEND,
+};
+#undef s
+
+static void comp_parse(struct xt_option_call *cb)
+{
+	struct ipt_comp *compinfo = cb->data;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_compSPI:
+		if (cb->nvals == 1)
+			compinfo->spis[1] = compinfo->spis[0];
+		if (cb->invert)
+			compinfo->invflags |= IPT_IPCOMP_INV_SPI;
+		break;
+	case O_compRES:
+		compinfo->hdrres = 1;
+		break;
+	}
+}
+
+static void
+print_spis(const char *name, uint32_t min, uint32_t max,
+	    int invert)
+{
+	const char *inv = invert ? "!" : "";
+
+	if (min != 0 || max != 0xFFFFFFFF || invert) {
+		if (min == max)
+			printf("%s:%s%u", name, inv, min);
+		else
+			printf("%ss:%s%u:%u", name, inv, min, max);
+	}
+}
+
+static void comp_print(const void *ip, const struct xt_entry_match *match,
+                     int numeric)
+{
+	const struct ipt_comp *comp = (struct ipt_comp *)match->data;
+
+	printf(" comp ");
+	print_spis("spi", comp->spis[0], comp->spis[1],
+		    comp->invflags & IPT_IPCOMP_INV_SPI);
+
+	if (comp->hdrres)
+		printf(" reserved");
+
+	if (comp->invflags & ~IPT_IPCOMP_INV_MASK)
+		printf(" Unknown invflags: 0x%X",
+		       comp->invflags & ~IPT_IPCOMP_INV_MASK);
+}
+
+static void comp_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct ipt_comp *compinfo = (struct ipt_comp *)match->data;
+
+	if (!(compinfo->spis[0] == 0
+	    && compinfo->spis[1] == 0xFFFFFFFF)) {
+		printf("%s --ipcompspi ",
+			(compinfo->invflags & IPT_IPCOMP_INV_SPI) ? " !" : "");
+		if (compinfo->spis[0]
+		    != compinfo->spis[1])
+			printf("%u:%u",
+			       compinfo->spis[0],
+			       compinfo->spis[1]);
+		else
+			printf("%u",
+			       compinfo->spis[0]);
+	}
+
+	if (compinfo->hdrres != 0 )
+		printf(" --compres");
+}
+
+static struct xtables_match comp_mt_reg = {
+	.name          = "ipcomp",
+	.version       = XTABLES_VERSION,
+	.family        = NFPROTO_UNSPEC,
+	.size          = XT_ALIGN(sizeof(struct ipt_comp)),
+	.userspacesize = XT_ALIGN(sizeof(struct ipt_comp)),
+	.help          = comp_help,
+	.print         = comp_print,
+	.save          = comp_save,
+	.x6_parse      = comp_parse,
+	.x6_options    = comp_opts,
+};
+
+void
+_init(void)
+{
+	xtables_register_match(&comp_mt_reg);
+};
+
diff --git a/extensions/libxt_ipcomp.c.man b/extensions/libxt_ipcomp.c.man
new file mode 100644
index 0000000..f3b17d2
--- /dev/null
+++ b/extensions/libxt_ipcomp.c.man
@@ -0,0 +1,7 @@
+This module matches the parameters in IPcomp header of IPsec packets.
+.TP
+[\fB!\fP] \fB\-\-ipcompspi\fP \fIspi\fP[\fB:\fP\fIspi\fP]
+Matches IPcomp header CPI value.
+.TP
+\fB\-\-compres\fP
+Matches if the reserved field is filled with zero.
diff --git a/include/linux/netfilter/xt_ipcomp.h b/include/linux/netfilter/xt_ipcomp.h
new file mode 100644
index 0000000..5e4abb3
--- /dev/null
+++ b/include/linux/netfilter/xt_ipcomp.h
@@ -0,0 +1,16 @@
+#ifndef _IPT_COMP_H
+#define _IPT_COMP_H
+
+#include <linux/types.h>
+
+struct ipt_comp {
+	__u32 spis[2];	/* Security Parameter Index */
+	__u8 invflags;	/* Inverse flags */
+	__u8 hdrres;	/* Test of the Reserved Filed */
+};
+
+/* Values for "invflags" field in struct ipt_comp. */
+#define IPT_IPCOMP_INV_SPI	0x01	/* Invert the sense of spi. */
+#define IPT_IPCOMP_INV_MASK	0x01	/* All possible flags. */
+
+#endif /*_IPT_COMP_H*/
-- 
1.7.9.5
