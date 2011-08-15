From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] bridge: allow passing link-local multicast
Date: Mon, 15 Aug 2011 15:05:01 -0700
Message-ID: <20110815150501.3a6cc432@nehalam.ftrdhcpuser.net>
References: <CAF5U64C+WgQhfJL3zfVnvzE7p=G61humQCObHGUxAvY2-MGAFQ@mail.gmail.com>
	<CAF5U64CJTWDn8E9+XVLFsdaSbiu-4Rd9XmxZq7ReziRNZviO6Q@mail.gmail.com>
	<20110812154545.79d8313f@nehalam.ftrdhcpuser.net>
	<CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Nick Carter <ncarter100@gmail.com>,
	David Lamparter <equinox@diac24.net>,
	bridge@linux-foundation.org
To: Ed Swierk <eswierk@bigswitch.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:32862 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752028Ab1HOWEw (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 15 Aug 2011 18:04:52 -0400
In-Reply-To: <CAF5U64B_fb2tFMLHmK+zw3n6gmq+bYDyFnXhLE0ayssK5m+THA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Several users have wanted to forward 802.1x EAP multicast
packets through a bridge. And there has been a couple of
attempts at allowing some form of this in the past.

If a bridge does not have spanning tree turned on, then it should
act like a pure hub and forward all traffic. This makes it fully
transparent, and if there is another bridge using spanning tree
the STP packets will still work for detecting loops in the network.

If bridge has STP enabled, then the default behavior is to
process all link-local multicasts locally. The expectation is
that if 802.1x or other protocol using link-local multicasts
that a service (or proxy) for that protocol will be used.

Optionally, a sysctl value can be set to allow non STP packets
to still be forwarded.  I chose sysctl for this because it is
where such modifications exist when doing IP or netfilter.
There are other filtering/configuration options that are needed
and this is a better way to enable them.

Thanks to David Lamparter, and others for bringing this up.
Users who need this facility should provide feedback, is this
a usable solution?

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

---
Patch against net-next

 Documentation/networking/ip-sysctl.txt |    4 ++
 net/bridge/Makefile                    |    2 -
 net/bridge/br.c                        |   12 ++++++
 net/bridge/br_input.c                  |   30 ++++++++++++++++-
 net/bridge/br_private.h                |    5 ++
 net/bridge/br_sysctl.c                 |   57 +++++++++++++++++++++++++++++++++
 6 files changed, 107 insertions(+), 3 deletions(-)

--- a/Documentation/networking/ip-sysctl.txt	2011-08-15 10:58:36.451532115 -0700
+++ b/Documentation/networking/ip-sysctl.txt	2011-08-15 11:39:57.719438766 -0700
@@ -1289,6 +1289,10 @@ bridge-nf-filter-pppoe-tagged - BOOLEAN
 	0 : disable this.
 	Default: 1
 
+bridge-forward-link-local - BOOLEAN
+	1 : pass link-local multicasts through bridge in STP mode
+	0 : disable this.
+	Default: 0
 
 proc/sys/net/sctp/* Variables:
 
--- a/net/bridge/Makefile	2011-08-15 10:30:25.203595742 -0700
+++ b/net/bridge/Makefile	2011-08-15 11:22:38.139477877 -0700
@@ -9,7 +9,7 @@ bridge-y	:= br.o br_device.o br_fdb.o br
 			br_stp_if.o br_stp_timer.o br_netlink.o
 
 bridge-$(CONFIG_SYSFS) += br_sysfs_if.o br_sysfs_br.o
-
+bridge-$(CONFIG_SYSCTL) += br_sysctl.o
 bridge-$(CONFIG_BRIDGE_NETFILTER) += br_netfilter.o
 
 bridge-$(CONFIG_BRIDGE_IGMP_SNOOPING) += br_multicast.o
--- a/net/bridge/br.c	2011-08-15 10:30:48.755594855 -0700
+++ b/net/bridge/br.c	2011-08-15 10:33:07.215589647 -0700
@@ -60,6 +60,12 @@ static int __init br_init(void)
 	if (err)
 		goto err_out4;
 
+#ifdef CONFIG_SYSCTL
+	err = br_sysctl_init();
+	if (err)
+		goto err_out5;
+#endif
+
 	brioctl_set(br_ioctl_deviceless_stub);
 
 #if defined(CONFIG_ATM_LANE) || defined(CONFIG_ATM_LANE_MODULE)
@@ -67,6 +73,9 @@ static int __init br_init(void)
 #endif
 
 	return 0;
+
+err_out5:
+	br_netlink_fini();
 err_out4:
 	unregister_netdevice_notifier(&br_device_notifier);
 err_out3:
@@ -84,6 +93,9 @@ static void __exit br_deinit(void)
 {
 	stp_proto_unregister(&br_stp_proto);
 
+#ifdef CONFIG_SYSCTL
+	br_sysctl_fini();
+#endif
 	br_netlink_fini();
 	unregister_netdevice_notifier(&br_device_notifier);
 	brioctl_set(NULL);
--- a/net/bridge/br_input.c	2011-08-15 10:40:21.435573311 -0700
+++ b/net/bridge/br_input.c	2011-08-15 11:39:57.719438766 -0700
@@ -16,11 +16,18 @@
 #include <linux/netdevice.h>
 #include <linux/etherdevice.h>
 #include <linux/netfilter_bridge.h>
+#include <linux/llc.h>
+#include <net/llc.h>
+#include <net/llc_pdu.h>
+
 #include "br_private.h"
 
 /* Bridge group multicast address 802.1d (pg 51). */
 const u8 br_group_address[ETH_ALEN] = { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
 
+/* Should link-local packets be forwarded (in STP mode) */
+int br_forward_link_local;
+
 /* Hook for brouter */
 br_should_route_hook_t __rcu *br_should_route_hook __read_mostly;
 EXPORT_SYMBOL(br_should_route_hook);
@@ -138,6 +145,17 @@ static inline int is_link_local(const un
 	return ((a[0] ^ b[0]) | (a[1] ^ b[1]) | ((a[2] ^ b[2]) & m)) == 0;
 }
 
+/* Identify Spanning Tree packets based on header */
+static bool is_stp_bpdu(struct sk_buff *skb)
+{
+	struct llc_pdu_un *pdu = llc_pdu_un_hdr(skb);
+
+	return skb->protocol == htons(ETH_P_802_2) &&
+		pdu->ctrl_1 == LLC_PDU_TYPE_U &&
+		pdu->dsap == LLC_SAP_BSPAN &&
+		pdu->ssap == LLC_SAP_BSPAN;
+}
+
 /*
  * Return NULL if skb is handled
  * note: already called with rcu_read_lock
@@ -166,8 +184,16 @@ rx_handler_result_t br_handle_frame(stru
 		if (skb->protocol == htons(ETH_P_PAUSE))
 			goto drop;
 
-		/* If STP is turned off, then forward */
-		if (p->br->stp_enabled == BR_NO_STP && dest[5] == 0)
+		/* If STP is turned off, then in hub mode */
+		if (p->br->stp_enabled == BR_NO_STP)
+			goto forward;
+
+		/*
+		 * If STP is on
+		 * then Always handle STP packets locally,
+		 *      other packets can be forwarded if sysctl is enabled.
+		 */
+		if (!is_stp_bpdu(skb) && br_forward_link_local)
 			goto forward;
 
 		if (NF_HOOK(NFPROTO_BRIDGE, NF_BR_LOCAL_IN, skb, skb->dev,
--- a/net/bridge/br_private.h	2011-08-15 10:38:35.587577293 -0700
+++ b/net/bridge/br_private.h	2011-08-15 10:57:36.983534352 -0700
@@ -284,6 +284,7 @@ struct br_input_skb_cb {
 	pr_debug("%s: " format,  (br)->dev->name, ##args)
 
 extern struct notifier_block br_device_notifier;
+extern int br_forward_link_local;
 extern const u8 br_group_address[ETH_ALEN];
 
 /* called under bridge lock */
@@ -546,6 +547,10 @@ extern int br_sysfs_renameif(struct net_
 extern int br_sysfs_addbr(struct net_device *dev);
 extern void br_sysfs_delbr(struct net_device *dev);
 
+/* br_sysctl.c */
+extern int br_sysctl_init(void);
+extern void br_sysctl_fini(void);
+
 #else
 
 #define br_sysfs_addif(p)	(0)
--- /dev/null	1970-01-01 00:00:00.000000000 +0000
+++ b/net/bridge/br_sysctl.c	2011-08-15 11:41:00.819436393 -0700
@@ -0,0 +1,57 @@
+/*
+ *	Sysctl settings for bridge
+ *
+ *	Authors:
+ *	Stephen Hemminger		<shemminger@osdl.org>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */
+
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/ip.h>
+#include <linux/netdevice.h>
+#include <linux/skbuff.h>
+#include <linux/if_arp.h>
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/if_pppox.h>
+#include <linux/sysctl.h>
+
+#include "br_private.h"
+
+static struct ctl_table bridge_table[] = {
+	{
+		.procname	= "bridge-forward-link-local",
+		.data		= &br_forward_link_local,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec
+	},
+};
+
+static struct ctl_path bridge_ctl_path[] = {
+	{ .procname = "net", },
+	{ .procname = "bridge", },
+	{ },
+};
+
+static struct ctl_table_header *br_sysctl;
+
+int __init br_sysctl_init(void)
+{
+	br_sysctl = register_sysctl_paths(bridge_ctl_path, bridge_table);
+	if (br_sysctl == NULL)
+		return -ENOMEM;
+
+	return 0;
+}
+
+void __exit br_sysctl_fini(void)
+{
+	unregister_net_sysctl_table(br_sysctl);
+}
