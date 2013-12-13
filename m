From: Fan Du <fan.du@windriver.com>
Subject: [PATCH 2/2] iptables: Add IPv6 IPcomp match support
Date: Fri, 13 Dec 2013 20:18:42 +0800
Message-ID: <1386937122-30453-3-git-send-email-fan.du@windriver.com>
References: <1386937122-30453-1-git-send-email-fan.du@windriver.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <davem@davemloft.net>, <netfilter-devel@vger.kernel.org>,
	<netdev@vger.kernel.org>
To: <pablo@netfilter.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.windriver.com ([147.11.1.11]:43207 "EHLO
	mail.windriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752647Ab3LMMSv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 13 Dec 2013 07:18:51 -0500
In-Reply-To: <1386937122-30453-1-git-send-email-fan.du@windriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables user to set iptables ACTIONs for IPcomp
flow specified by its SPI value.

For example:
ip6tables -A OUTPUT -p 108 -m ipcomp --ipcompspi 0x12 -j DROP

IPcomp packet with spi as 0x12 will be dropped.

Signed-off-by: Fan Du <fan.du@windriver.com>
---
 extensions/libip6t_ipcomp.c              |  115 ++++++++++++++++++++++++++++++
 extensions/libip6t_ipcomp.man            |    7 ++
 include/linux/netfilter_ipv6/ip6t_comp.h |   18 +++++
 3 files changed, 140 insertions(+)
 create mode 100644 extensions/libip6t_ipcomp.c
 create mode 100644 extensions/libip6t_ipcomp.man
 create mode 100644 include/linux/netfilter_ipv6/ip6t_comp.h

diff --git a/extensions/libip6t_ipcomp.c b/extensions/libip6t_ipcomp.c
new file mode 100644
index 0000000..d88648d
--- /dev/null
+++ b/extensions/libip6t_ipcomp.c
@@ -0,0 +1,115 @@
+#include <stdio.h>
+#include <xtables.h>
+#include <linux/netfilter_ipv6/ip6t_comp.h>
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
+"[!] --ipcompspi spi[:spi]          match spi (range)\n"
+" --compres                       check the reserved field too\n");
+}
+
+#define s struct ip6t_comp
+static const struct xt_option_entry comp_opts[] = {
+	{.name = "ipcompspi", .id = O_compSPI, .type = XTTYPE_UINT32RC,
+	 .flags = XTOPT_INVERT | XTOPT_PUT, XTOPT_POINTER(s, spis)},
+	{.name = "compres", .id = O_compRES, .type = XTTYPE_NONE},
+	XTOPT_TABLEEND,
+};
+#undef s
+
+static void comp_parse(struct xt_option_call *cb)
+{
+	struct ip6t_comp *compinfo = cb->data;
+
+	xtables_option_parse(cb);
+	switch (cb->entry->id) {
+	case O_compSPI:
+		if (cb->nvals == 1)
+			compinfo->spis[1] = compinfo->spis[0];
+		if (cb->invert)
+			compinfo->invflags |= IP6T_IPCOMP_INV_SPI;
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
+	const struct ip6t_comp *comp = (struct ip6t_comp *)match->data;
+
+	printf(" comp ");
+	print_spis("spi", comp->spis[0], comp->spis[1],
+		    comp->invflags & IP6T_IPCOMP_INV_SPI);
+
+	if (comp->hdrres)
+		printf(" reserved");
+
+	if (comp->invflags & ~IP6T_IPCOMP_INV_MASK)
+		printf(" Unknown invflags: 0x%X",
+		       comp->invflags & ~IP6T_IPCOMP_INV_MASK);
+}
+
+static void comp_save(const void *ip, const struct xt_entry_match *match)
+{
+	const struct ip6t_comp *compinfo = (struct ip6t_comp *)match->data;
+
+	if (!(compinfo->spis[0] == 0
+	    && compinfo->spis[1] == 0xFFFFFFFF)) {
+		printf("%s --ipcompspi ",
+			(compinfo->invflags & IP6T_IPCOMP_INV_SPI) ? " !" : "");
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
+static struct xtables_match comp_mt6_reg = {
+	.name          = "ipcomp",
+	.version       = XTABLES_VERSION,
+	.family        = NFPROTO_IPV6,
+	.size          = XT_ALIGN(sizeof(struct ip6t_comp)),
+	.userspacesize = XT_ALIGN(sizeof(struct ip6t_comp)),
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
+	xtables_register_match(&comp_mt6_reg);
+}
diff --git a/extensions/libip6t_ipcomp.man b/extensions/libip6t_ipcomp.man
new file mode 100644
index 0000000..f3b17d2
--- /dev/null
+++ b/extensions/libip6t_ipcomp.man
@@ -0,0 +1,7 @@
+This module matches the parameters in IPcomp header of IPsec packets.
+.TP
+[\fB!\fP] \fB\-\-ipcompspi\fP \fIspi\fP[\fB:\fP\fIspi\fP]
+Matches IPcomp header CPI value.
+.TP
+\fB\-\-compres\fP
+Matches if the reserved field is filled with zero.
diff --git a/include/linux/netfilter_ipv6/ip6t_comp.h b/include/linux/netfilter_ipv6/ip6t_comp.h
new file mode 100644
index 0000000..a1064c4
--- /dev/null
+++ b/include/linux/netfilter_ipv6/ip6t_comp.h
@@ -0,0 +1,18 @@
+#ifndef _IP6T_COMP_H
+#define _IP6T_COMP_H
+
+#include <linux/types.h>
+
+struct ip6t_comp {
+	__u32 spis[2];			/* Security Parameter Index */
+	__u8  hdrres;			/* Test of the Reserved Filed */
+	__u8  invflags;			/* Inverse flags */
+};
+
+#define IP6T_IPCOMP_SPI 0x01
+#define IP6T_IPCOMP_RES 0x02
+
+#define IP6T_IPCOMP_INV_SPI		0x01	/* Invert the sense of spi. */
+#define IP6T_IPCOMP_INV_MASK	0x03	/* All possible flags. */
+
+#endif /*_IP6T_COMP_H*/
-- 
1.7.9.5
