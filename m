From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 1/2] iptables: Add IPv4 IPcomp match support
Date: Fri, 13 Dec 2013 20:18:41 +0800
Message-ID: <1386937122-30453-2-git-send-email-fan.du@windriver.com>
References: <1386937122-30453-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1386937122-30453-1-git-send-email-fan.du@windriver.com>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch enables user to set iptables ACTIONs for IPcomp
flow specified by its SPI value.

For example:
iptables -A OUTPUT -p 108 -m ipcomp --ipcompspi 0x12 -j DROP

IPcomp packet with spi as 0x12 will be dropped.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 extensions/libipt_ipcomp.c              |  116 +++++++++++++++++++++++++++++++
 extensions/libipt_ipcomp.man            |    7 ++
 include/linux/netfilter_ipv4/ipt_comp.h |   18 +++++
 3 files changed, 141 insertions(+)
 create mode 100644 extensions/libipt_ipcomp.c
 create mode 100644 extensions/libipt_ipcomp.man
 create mode 100644 include/linux/netfilter_ipv4/ipt_comp.h

diff --git a/extensions/libipt_ipcomp.c b/extensions/libipt_ipcomp.c
new file mode 100644
index 0000000..cf5918c
--- /dev/null
+++ b/extensions/libipt_ipcomp.c
@@ -0,0 +1,116 @@
+#include <stdio.h>
+#include <xtables.h>
+#include <linux/netfilter_ipv4/ipt_comp.h>
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
+	.family        = NFPROTO_IPV4,
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
diff --git a/extensions/libipt_ipcomp.man b/extensions/libipt_ipcomp.man
new file mode 100644
index 0000000..f3b17d2
--- /dev/null
+++ b/extensions/libipt_ipcomp.man
@@ -0,0 +1,7 @@
+This module matches the parameters in IPcomp header of IPsec packets.
+.TP
+[\fB!\fP] \fB\-\-ipcompspi\fP \fIspi\fP[\fB:\fP\fIspi\fP]
+Matches IPcomp header CPI value.
+.TP
+\fB\-\-compres\fP
+Matches if the reserved field is filled with zero.
diff --git a/include/linux/netfilter_ipv4/ipt_comp.h b/include/linux/netfilter_ipv4/ipt_comp.h
new file mode 100644
index 0000000..37172fa
--- /dev/null
+++ b/include/linux/netfilter_ipv4/ipt_comp.h
@@ -0,0 +1,18 @@
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
+
+
+/* Values for "invflags" field in struct ipt_comp. */
+#define IPT_IPCOMP_INV_SPI	0x01	/* Invert the sense of spi. */
+#define IPT_IPCOMP_INV_MASK	0x01	/* All possible flags. */
+
+#endif /*_IPT_COMP_H*/
-- 
1.7.9.5

