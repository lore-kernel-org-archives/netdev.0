From: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
Subject: [PATCH 8/44] [XFRM] STATE: Introduce route optimization mode.
Date: Thu, 24 Aug 2006 00:02:09 +0900
Message-ID: <1156345365312-git-send-email-yoshfuji@linux-ipv6.org>
References: <11563453651167-git-send-email-yoshfuji@linux-ipv6.org> <11563453651533-git-send-email-yoshfuji@linux-ipv6.org> <11563453653169-git-send-email-yoshfuji@linux-ipv6.org> <1156345365325-git-send-email-yoshfuji@linux-ipv6.org> <11563453653851-git-send-email-yoshfuji@linux-ipv6.org> <11563453653575-git-send-email-yoshfuji@linux-ipv6.org> <1156345365651-git-send-email-yoshfuji@linux-ipv6.org> <1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
Cc: yoshfuji@linux-ipv6.org, anttit@tcs.hut.fi, vnuorval@tcs.hut.fi,
	netdev@vger.kernel.org, usagi-core@linux-ipv6.org,
	Masahide NAKAMURA <nakam@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pc9.nezu.wide.ad.jp ([203.178.142.216]:62600 "EHLO
	jupiter.linux-ipv6.org") by vger.kernel.org with ESMTP
	id S964918AbWHWPCu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 23 Aug 2006 11:02:50 -0400
To: davem@davemloft.net
In-Reply-To: <1156345365264-git-send-email-yoshfuji@linux-ipv6.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Masahide NAKAMURA <nakam@linux-ipv6.org>

Route optimization is used with routing header and destination options
header for Mobile IPv6.
At outbound it makes header space like IPsec transport. At inbound
it does nothing because exhdrs.c functions have responsibility to
update skbuff information for these headers.

Signed-off-by: Masahide NAKAMURA <nakam@linux-ipv6.org>
Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
---
 net/ipv6/Kconfig         |    7 +++
 net/ipv6/Makefile        |    1 
 net/ipv6/xfrm6_mode_ro.c |   94 ++++++++++++++++++++++++++++++++++++++++++++++
 3 files changed, 102 insertions(+), 0 deletions(-)

diff --git a/net/ipv6/Kconfig b/net/ipv6/Kconfig
index 540e800..5067665 100644
--- a/net/ipv6/Kconfig
+++ b/net/ipv6/Kconfig
@@ -126,6 +126,13 @@ config INET6_XFRM_MODE_TUNNEL
 
 	  If unsure, say Y.
 
+config INET6_XFRM_MODE_ROUTEOPTIMIZATION
+	tristate "IPv6: MIPv6 route optimization mode (EXPERIMENTAL)"
+	depends on IPV6 && EXPERIMENTAL
+	select XFRM
+	---help---
+	  Support for MIPv6 route optimization mode.
+
 config IPV6_TUNNEL
 	tristate "IPv6: IPv6-in-IPv6 tunnel"
 	select INET6_TUNNEL
diff --git a/net/ipv6/Makefile b/net/ipv6/Makefile
index 9eebf60..87e912e 100644
--- a/net/ipv6/Makefile
+++ b/net/ipv6/Makefile
@@ -23,6 +23,7 @@ obj-$(CONFIG_INET6_XFRM_TUNNEL) += xfrm6
 obj-$(CONFIG_INET6_TUNNEL) += tunnel6.o
 obj-$(CONFIG_INET6_XFRM_MODE_TRANSPORT) += xfrm6_mode_transport.o
 obj-$(CONFIG_INET6_XFRM_MODE_TUNNEL) += xfrm6_mode_tunnel.o
+obj-$(CONFIG_INET6_XFRM_MODE_ROUTEOPTIMIZATION) += xfrm6_mode_ro.o
 obj-$(CONFIG_NETFILTER)	+= netfilter/
 
 obj-$(CONFIG_IPV6_TUNNEL) += ip6_tunnel.o
diff --git a/net/ipv6/xfrm6_mode_ro.c b/net/ipv6/xfrm6_mode_ro.c
new file mode 100644
index 0000000..c11c335
--- /dev/null
+++ b/net/ipv6/xfrm6_mode_ro.c
@@ -0,0 +1,94 @@
+/*
+ * xfrm6_mode_ro.c - Route optimization mode for IPv6.
+ *
+ * Copyright (C)2003-2006 Helsinki University of Technology
+ * Copyright (C)2003-2006 USAGI/WIDE Project
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307  USA
+ */
+/*
+ * Authors:
+ *	Noriaki TAKAMIYA @USAGI
+ *	Masahide NAKAMURA @USAGI
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/stringify.h>
+#include <net/ipv6.h>
+#include <net/xfrm.h>
+
+/* Add route optimization header space.
+ *
+ * The IP header and mutable extension headers will be moved forward to make
+ * space for the route optimization header.
+ *
+ * On exit, skb->h will be set to the start of the encapsulation header to be
+ * filled in by x->type->output and skb->nh will be set to the nextheader field
+ * of the extension header directly preceding the encapsulation header, or in
+ * its absence, that of the top IP header.  The value of skb->data will always
+ * point to the top IP header.
+ */
+static int xfrm6_ro_output(struct sk_buff *skb)
+{
+	struct xfrm_state *x = skb->dst->xfrm;
+	struct ipv6hdr *iph;
+	u8 *prevhdr;
+	int hdr_len;
+
+	skb_push(skb, x->props.header_len);
+	iph = skb->nh.ipv6h;
+
+	hdr_len = x->type->hdr_offset(x, skb, &prevhdr);
+	skb->nh.raw = prevhdr - x->props.header_len;
+	skb->h.raw = skb->data + hdr_len;
+	memmove(skb->data, iph, hdr_len);
+	return 0;
+}
+
+/*
+ * Do nothing about routing optimization header unlike IPsec.
+ */
+static int xfrm6_ro_input(struct xfrm_state *x, struct sk_buff *skb)
+{
+	return 0;
+}
+
+static struct xfrm_mode xfrm6_ro_mode = {
+	.input = xfrm6_ro_input,
+	.output = xfrm6_ro_output,
+	.owner = THIS_MODULE,
+	.encap = XFRM_MODE_ROUTEOPTIMIZATION,
+};
+
+static int __init xfrm6_ro_init(void)
+{
+	return xfrm_register_mode(&xfrm6_ro_mode, AF_INET6);
+}
+
+static void __exit xfrm6_ro_exit(void)
+{
+	int err;
+
+	err = xfrm_unregister_mode(&xfrm6_ro_mode, AF_INET6);
+	BUG_ON(err);
+}
+
+module_init(xfrm6_ro_init);
+module_exit(xfrm6_ro_exit);
+MODULE_LICENSE("GPL");
+MODULE_ALIAS_XFRM_MODE(AF_INET6, XFRM_MODE_ROUTEOPTIMIZATION);
-- 
1.4.0

