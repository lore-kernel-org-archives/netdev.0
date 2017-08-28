From: Jiri Benc <jbenc@redhat.com>
Subject: [PATCH net-next 4/4] nsh: add GSO support
Date: Mon, 28 Aug 2017 21:43:24 +0200
Message-ID: <e201e59a62a483c8c4919ab99aa27e0391ecb370.1503948295.git.jbenc@redhat.com>
References: <cover.1503948295.git.jbenc@redhat.com>
Cc: Yi Yang <yi.y.yang@intel.com>, Eric Garver <e@erig.me>,
        Jan Scheurich <jan.scheurich@ericsson.com>,
        Ben Pfaff <blp@ovn.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39846 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1751192AbdH1Tnp (ORCPT <rfc822;netdev@vger.kernel.org>);
        Mon, 28 Aug 2017 15:43:45 -0400
In-Reply-To: <cover.1503948295.git.jbenc@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a new nsh/ directory. It currently holds only GSO functions but more
will come: in particular, code shared by openvswitch and tc to manipulate
NSH headers.

For now, assume there's no hardware support for NSH segmentation. We can
always introduce netdev->nsh_features later.

Signed-off-by: Jiri Benc <jbenc@redhat.com>
---
 net/Kconfig      |  1 +
 net/Makefile     |  1 +
 net/nsh/Kconfig  |  9 ++++++
 net/nsh/Makefile |  1 +
 net/nsh/nsh.c    | 91 ++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 5 files changed, 103 insertions(+)
 create mode 100644 net/nsh/Kconfig
 create mode 100644 net/nsh/Makefile
 create mode 100644 net/nsh/nsh.c

diff --git a/net/Kconfig b/net/Kconfig
index 7d57ef34b79c..45def78912ce 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -235,6 +235,7 @@ source "net/openvswitch/Kconfig"
 source "net/vmw_vsock/Kconfig"
 source "net/netlink/Kconfig"
 source "net/mpls/Kconfig"
+source "net/nsh/Kconfig"
 source "net/hsr/Kconfig"
 source "net/switchdev/Kconfig"
 source "net/l3mdev/Kconfig"
diff --git a/net/Makefile b/net/Makefile
index bed80fa398b7..e03c3888179f 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -76,6 +76,7 @@ obj-$(CONFIG_NET_IFE)		+= ife/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
 obj-$(CONFIG_VSOCKETS)	+= vmw_vsock/
 obj-$(CONFIG_MPLS)		+= mpls/
+obj-$(CONFIG_NET_NSH)		+= nsh/
 obj-$(CONFIG_HSR)		+= hsr/
 ifneq ($(CONFIG_NET_SWITCHDEV),)
 obj-y				+= switchdev/
diff --git a/net/nsh/Kconfig b/net/nsh/Kconfig
new file mode 100644
index 000000000000..bafc3dd60c2c
--- /dev/null
+++ b/net/nsh/Kconfig
@@ -0,0 +1,9 @@
+menuconfig NET_NSH
+	tristate "Network Service Header (NSH) protocol"
+	default n
+	---help---
+	  Network Service Header is an implementation of Service Function
+	  Chaining (RFC 7665). The current implementation in Linux supports
+	  only MD type 1 and only with the openvswitch module.
+
+	  If unsure, say N.
diff --git a/net/nsh/Makefile b/net/nsh/Makefile
new file mode 100644
index 000000000000..c93c787385ca
--- /dev/null
+++ b/net/nsh/Makefile
@@ -0,0 +1 @@
+obj-$(CONFIG_NET_NSH) += nsh.o
diff --git a/net/nsh/nsh.c b/net/nsh/nsh.c
new file mode 100644
index 000000000000..58fb827439a8
--- /dev/null
+++ b/net/nsh/nsh.c
@@ -0,0 +1,91 @@
+/*
+ * Network Service Header
+ *
+ * Copyright (c) 2017 Red Hat, Inc. -- Jiri Benc <jbenc@redhat.com>
+ *
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License version 2 as
+ * published by the Free Software Foundation.
+ */
+
+#include <linux/module.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <net/nsh.h>
+#include <net/tun_proto.h>
+
+static struct sk_buff *nsh_gso_segment(struct sk_buff *skb,
+				       netdev_features_t features)
+{
+	struct sk_buff *segs = ERR_PTR(-EINVAL);
+	unsigned int nsh_len, mac_len;
+	__be16 proto;
+	int nhoff;
+
+	skb_reset_network_header(skb);
+
+	nhoff = skb->network_header - skb->mac_header;
+	mac_len = skb->mac_len;
+
+	if (unlikely(!pskb_may_pull(skb, NSH_BASE_HDR_LEN)))
+		goto out;
+	nsh_len = nsh_hdr_len(nsh_hdr(skb));
+	if (unlikely(!pskb_may_pull(skb, nsh_len)))
+		goto out;
+
+	proto = tun_p_to_eth_p(nsh_hdr(skb)->np);
+	if (!proto)
+		goto out;
+
+	__skb_pull(skb, nsh_len);
+
+	skb_reset_mac_header(skb);
+	skb_reset_mac_len(skb);
+	skb->protocol = proto;
+
+	features &= NETIF_F_SG;
+	segs = skb_mac_gso_segment(skb, features);
+	if (IS_ERR_OR_NULL(segs)) {
+		skb_gso_error_unwind(skb, htons(ETH_P_NSH), nsh_len,
+				     skb->network_header - nhoff,
+				     mac_len);
+		goto out;
+	}
+
+	for (skb = segs; skb; skb = skb->next) {
+		skb->protocol = htons(ETH_P_NSH);
+		__skb_push(skb, nsh_len);
+		skb_set_mac_header(skb, -nhoff);
+		skb->network_header = skb->mac_header + mac_len;
+		skb->mac_len = mac_len;
+	}
+
+out:
+	return segs;
+}
+
+static struct packet_offload nsh_packet_offload __read_mostly = {
+	.type = htons(ETH_P_NSH),
+	.priority = 15,
+	.callbacks = {
+		.gso_segment = nsh_gso_segment,
+	},
+};
+
+static int __init nsh_init_module(void)
+{
+	dev_add_offload(&nsh_packet_offload);
+	return 0;
+}
+
+static void __exit nsh_cleanup_module(void)
+{
+	dev_remove_offload(&nsh_packet_offload);
+}
+
+module_init(nsh_init_module);
+module_exit(nsh_cleanup_module);
+
+MODULE_AUTHOR("Jiri Benc <jbenc@redhat.com>");
+MODULE_DESCRIPTION("NSH protocol");
+MODULE_LICENSE("GPL v2");
-- 
1.8.3.1
