From: Bart De Schuymer <bart.de.schuymer@pandora.be>
Subject: [PATCH] ebtables - Ethernet bridge tables, for 2.5.34
Date: Thu, 12 Sep 2002 19:07:12 +0200
Sender: netdev-bounce@oss.sgi.com
Message-ID: <200209121907.12936.bart.de.schuymer@pandora.be>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com, linux-net@vger.kernel.org
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hello list,

I sent this message to lkml too, but without the actual patch. I hope I'm=
=20
allowed to send the full patch here. It's quite large.

Ebtables is a project similar to iptables, but working on the bridge netf=
ilter=20
hooks. It allows for a basic transparent firewall, making a brouter and d=
oing=20
MAC source address and destination address manipulation. The firewall par=
t=20
has currently modules for basic IP filtering, 802.1q filtering, ARP=20
filtering, logging and a mark match/target.
Ebtables has been under development for over 1.5 year and has more than 1=
00
users, I think.
You can also download the patch here:
http://users.pandora.be/bart.de.schuymer/ebtables/v2.0/ebtables-v2.0_vs_2=
.5.34.diff
http://users.pandora.be/bart.de.schuymer/ebtables/v2.0/ebtables-v2.0_vs_2=
.5.34.diff.gz

For more information, see
http://users.pandora.be/bart.de.schuymer/ebtables/
There is an ebtables hacking howto, some basic examples and some real lif=
e
examples from users. And ofcourse the userspace program.

This is the first time I'm submitting a large patch, so feel free to rant=
 if=20
I'm doing something wrong... Here it goes:

ebtables-v2.0 - 11 September 2002

Bart De Schuymer
****** Add ebtables project info

--- linux-2.5.34/MAINTAINERS	Mon Sep  9 19:35:13 2002
+++ linux-2.5.34-ebtables/MAINTAINERS	Wed Sep 11 23:06:55 2002
@@ -531,6 +531,14 @@ M:	mike@i-Connect.Net
 L:	linux-eata@i-connect.net, linux-scsi@vger.kernel.org
 S:	Maintained
=20
+EBTABLES
+P:	Bart De Schuymer
+M:	bart.de.schuymer@pandora.be
+L:	ebtables-user@lists.sourceforge.net
+L:	ebtables-devel@lists.sourceforge.net
+W:	http://ebtables.sourceforge.net/
+S:	Maintained
+
 EEPRO100 NETWORK DRIVER
 P:	Andrey V. Savochkin
 M:	saw@saw.sw.com.sg

****** Clear nf_debug, we will be dealing with different netfilter hooks:
       the bridge hooks.

--- linux-2.5.34/net/bridge/br_forward.c	Mon Sep  9 19:35:07 2002
+++ linux-2.5.34-ebtables/net/bridge/br_forward.c	Wed Sep 11 23:06:55 200=
2
@@ -49,6 +49,9 @@ static int __br_forward_finish(struct sk
 static void __br_deliver(struct net_bridge_port *to, struct sk_buff *skb=
)
 {
 	skb->dev =3D to->dev;
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug =3D 0;
+#endif
 	NF_HOOK(PF_BRIDGE, NF_BR_LOCAL_OUT, skb, NULL, skb->dev,
 			__br_forward_finish);
 }

****** modification for brouter support

--- linux-2.5.34/net/bridge/br_private.h	Mon Sep  9 19:35:05 2002
+++ linux-2.5.34-ebtables/net/bridge/br_private.h	Wed Sep 11 23:06:55 200=
2
@@ -166,7 +166,7 @@ extern void br_get_port_ifindices(struct
 			   int *ifindices);
=20
 /* br_input.c */
-extern void br_handle_frame(struct sk_buff *skb);
+extern int br_handle_frame(struct sk_buff *skb);
=20
 /* br_ioctl.c */
 extern void br_call_ioctl_atomic(void (*fn)(void));

****** modification for brouter support

--- linux-2.5.34/include/linux/if_bridge.h	Mon Sep  9 19:35:11 2002
+++ linux-2.5.34-ebtables/include/linux/if_bridge.h	Wed Sep 11 23:06:55 2=
002
@@ -102,8 +102,13 @@ struct net_bridge;
 struct net_bridge_port;
=20
 extern int (*br_ioctl_hook)(unsigned long arg);
-extern void (*br_handle_frame_hook)(struct sk_buff *skb);
-
+extern int (*br_handle_frame_hook)(struct sk_buff *skb);
+#if defined(CONFIG_BRIDGE_EBT_BROUTE) || \
+    defined(CONFIG_BRIDGE_EBT_BROUTE_MODULE)
+extern unsigned int (*broute_decision) (unsigned int hook, struct sk_buf=
f=20
**pskb,
+   const struct net_device *in, const struct net_device *out,
+   int (*okfn)(struct sk_buff *));
+#endif
 #endif
=20
 #endif

****** modification for brouter support
       br_handle_frame_hook return non-zero if the frame has to be routed=
,
       else the frame has been bridged.

--- linux-2.5.34/net/core/dev.c	Mon Sep  9 19:35:12 2002
+++ linux-2.5.34-ebtables/net/core/dev.c	Wed Sep 11 23:06:55 2002
@@ -1395,7 +1395,7 @@ void net_call_rx_atomic(void (*fn)(void)
 }
=20
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
-void (*br_handle_frame_hook)(struct sk_buff *skb) =3D NULL;
+int (*br_handle_frame_hook)(struct sk_buff *skb) =3D NULL;
 #endif
=20
 static __inline__ int handle_bridge(struct sk_buff *skb,
@@ -1412,7 +1412,6 @@ static __inline__ int handle_bridge(stru
 		}
 	}
=20
-	br_handle_frame_hook(skb);
 	return ret;
 }
=20
@@ -1473,7 +1472,11 @@ int netif_receive_skb(struct sk_buff *sk
=20
 #if defined(CONFIG_BRIDGE) || defined(CONFIG_BRIDGE_MODULE)
 	if (skb->dev->br_port && br_handle_frame_hook) {
-		return handle_bridge(skb, pt_prev);
+                int ret;
+
+                ret =3D handle_bridge(skb, pt_prev);
+                if (br_handle_frame_hook(skb) =3D=3D 0)
+                        return ret;
 	}
 #endif
=20
****** modification for brouter support + clear nf_debug
       br_handle_frame_hook calls broute_decision(), which traverses
       the ebtables brouting table to get the decision to bridge or route
       the frame. Return value -1 means route, 0 means the frame has been
       bridged.

--- linux-2.5.34/net/bridge/br_input.c	Mon Sep  9 19:35:06 2002
+++ linux-2.5.34-ebtables/net/bridge/br_input.c	Wed Sep 11 23:06:55 2002
@@ -19,11 +19,18 @@
 #include <linux/if_bridge.h>
 #include <linux/netfilter_bridge.h>
 #include "br_private.h"
+#if defined(CONFIG_BRIDGE_EBT_BROUTE) || \
+    defined(CONFIG_BRIDGE_EBT_BROUTE_MODULE)
+#include <linux/netfilter.h>
+#endif
=20
 unsigned char bridge_ula[6] =3D { 0x01, 0x80, 0xc2, 0x00, 0x00, 0x00 };
=20
 static int br_pass_frame_up_finish(struct sk_buff *skb)
 {
+#ifdef CONFIG_NETFILTER_DEBUG
+	skb->nf_debug =3D 0;
+#endif
 	netif_rx(skb);
=20
 	return 0;
@@ -112,7 +119,7 @@ err_nolock:
 	return 0;
 }
=20
-void br_handle_frame(struct sk_buff *skb)
+int br_handle_frame(struct sk_buff *skb)
 {
 	struct net_bridge *br;
 	unsigned char *dest;
@@ -146,25 +153,32 @@ void br_handle_frame(struct sk_buff *skb
 		goto handle_special_frame;
=20
 	if (p->state =3D=3D BR_STATE_FORWARDING) {
+#if defined(CONFIG_BRIDGE_EBT_BROUTE) || \
+    defined(CONFIG_BRIDGE_EBT_BROUTE_MODULE)
+		if (broute_decision && broute_decision(NF_BR_BROUTING, &skb,
+		   skb->dev, NULL, NULL) =3D=3D NF_DROP)
+			return -1;
+#endif
 		NF_HOOK(PF_BRIDGE, NF_BR_PRE_ROUTING, skb, skb->dev, NULL,
 			br_handle_frame_finish);
 		read_unlock(&br->lock);
-		return;
+		return 0;
 	}
=20
 err:
 	read_unlock(&br->lock);
 err_nolock:
 	kfree_skb(skb);
-	return;
+	return 0;
=20
 handle_special_frame:
 	if (!dest[5]) {
 		br_stp_handle_bpdu(skb);
 		read_unlock(&br->lock);
-		return;
+		return 0;
 	}
=20
 	kfree_skb(skb);
 	read_unlock(&br->lock);
+	return 0;
 }

****** broute_decision is defined here.

--- linux-2.5.34/net/bridge/br.c	Mon Sep  9 19:35:04 2002
+++ linux-2.5.34-ebtables/net/bridge/br.c	Wed Sep 11 23:06:55 2002
@@ -28,6 +28,14 @@
 #include "../atm/lec.h"
 #endif
=20
+#if defined(CONFIG_BRIDGE_EBT_BROUTE) || \
+    defined(CONFIG_BRIDGE_EBT_BROUTE_MODULE)
+unsigned int (*broute_decision) (unsigned int hook, struct sk_buff **psk=
b,
+                        const struct net_device *in,
+                        const struct net_device *out,
+                        int (*okfn)(struct sk_buff *)) =3D NULL;
+#endif
+
 void br_dec_use_count()
 {
 	MOD_DEC_USE_COUNT;
@@ -73,6 +81,11 @@ static void __exit br_deinit(void)
 	br_fdb_put_hook =3D NULL;
 #endif
 }
+
+#if defined(CONFIG_BRIDGE_EBT_BROUTE) || \
+    defined(CONFIG_BRIDGE_EBT_BROUTE_MODULE)
+EXPORT_SYMBOL(broute_decision);
+#endif
=20
 module_init(br_init)
 module_exit(br_deinit)

****** br.o may have to export broute_decision.
       Add the bridge/netfilter directory.

--- linux-2.5.34/net/bridge/Makefile	Mon Sep  9 19:35:21 2002
+++ linux-2.5.34-ebtables/net/bridge/Makefile	Wed Sep 11 23:06:55 2002
@@ -2,10 +2,17 @@
 # Makefile for the IEEE 802.1d ethernet bridging layer.
 #
=20
+ifneq ($(CONFIG_BRIDGE_EBT_BROUTE),n)
+ifneq ($(CONFIG_BRIDGE_EBT_BROUTE),)
+export-objs :=3D br.o
+endif
+endif
+
 obj-$(CONFIG_BRIDGE) +=3D bridge.o
=20
 bridge-objs	:=3D br.o br_device.o br_fdb.o br_forward.o br_if.o br_input=
.o \
 			br_ioctl.o br_notify.o br_stp.o br_stp_bpdu.o \
 			br_stp_if.o br_stp_timer.o
+obj-$(CONFIG_BRIDGE_EBT) +=3D netfilter/
=20
 include $(TOPDIR)/Rules.make

****** Add the NF_BR_BROUTING "hook"

--- linux-2.5.34/include/linux/netfilter_bridge.h	Mon Sep  9 19:35:12 200=
2
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge.h	Wed Sep 11 23:=
06:55=20
2002
@@ -18,7 +18,18 @@
 #define NF_BR_LOCAL_OUT		3
 /* Packets about to hit the wire. */
 #define NF_BR_POST_ROUTING	4
-#define NF_BR_NUMHOOKS		5
+/* Not really a hook, but used for the ebtables broute table */
+#define NF_BR_BROUTING		5
+#define NF_BR_NUMHOOKS		6
=20
+enum nf_br_hook_priorities {
+        NF_BR_PRI_FIRST =3D INT_MIN,
+        NF_BR_PRI_FILTER_BRIDGED =3D -200,
+        NF_BR_PRI_FILTER_OTHER =3D 200,
+        NF_BR_PRI_NAT_DST_BRIDGED =3D -300,
+        NF_BR_PRI_NAT_DST_OTHER =3D 100,
+        NF_BR_PRI_NAT_SRC =3D 300,
+        NF_BR_PRI_LAST =3D INT_MAX,
+};
=20
 #endif

****** Include the ebtables Config.in

--- linux-2.5.34/net/Config.in	Mon Sep  9 19:35:05 2002
+++ linux-2.5.34-ebtables/net/Config.in	Wed Sep 11 23:06:55 2002
@@ -65,6 +65,9 @@ if [ "$CONFIG_DECNET" !=3D "n" ]; then
    source net/decnet/Config.in
 fi
 dep_tristate '802.1d Ethernet Bridging' CONFIG_BRIDGE $CONFIG_INET
+if [ "$CONFIG_BRIDGE" !=3D "n" -a "$CONFIG_NETFILTER" !=3D "n" ]; then
+   source net/bridge/netfilter/Config.in
+fi
 if [ "$CONFIG_EXPERIMENTAL" =3D "y" ]; then
    tristate 'CCITT X.25 Packet Layer (EXPERIMENTAL)' CONFIG_X25
    tristate 'LAPB Data Link Driver (EXPERIMENTAL)' CONFIG_LAPB

****** Now follow all the new files, without much comment.
       ebtables is modular like iptables, currently there are 3 tables:
       broute, nat and filter. There are some mark modules and target
       modules too. Also one watcher module, the log module.

--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/Makefile	Wed Sep 11 23:06:=
55=20
2002
@@ -0,0 +1,20 @@
+#
+# Makefile for the netfilter modules for Link Layer filtering on a bridg=
e.
+#
+
+export-objs :=3D ebtables.o
+
+obj-$(CONFIG_BRIDGE_EBT) +=3D ebtables.o
+obj-$(CONFIG_BRIDGE_EBT_T_FILTER) +=3D ebtable_filter.o
+obj-$(CONFIG_BRIDGE_EBT_T_NAT) +=3D ebtable_nat.o
+obj-$(CONFIG_BRIDGE_EBT_BROUTE) +=3D ebtable_broute.o
+obj-$(CONFIG_BRIDGE_EBT_IPF) +=3D ebt_ip.o
+obj-$(CONFIG_BRIDGE_EBT_ARPF) +=3D ebt_arp.o
+obj-$(CONFIG_BRIDGE_EBT_VLANF) +=3D ebt_vlan.o
+obj-$(CONFIG_BRIDGE_EBT_MARKF) +=3D ebt_mark_m.o
+obj-$(CONFIG_BRIDGE_EBT_LOG) +=3D ebt_log.o
+obj-$(CONFIG_BRIDGE_EBT_SNAT) +=3D ebt_snat.o
+obj-$(CONFIG_BRIDGE_EBT_DNAT) +=3D ebt_dnat.o
+obj-$(CONFIG_BRIDGE_EBT_REDIRECT) +=3D ebt_redirect.o
+obj-$(CONFIG_BRIDGE_EBT_MARK_T) +=3D ebt_mark.o
+include $(TOPDIR)/Rules.make
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/Config.in	Wed Sep 11 23:06=
:55=20
2002
@@ -0,0 +1,17 @@
+#
+# Bridge netfilter configuration
+#
+dep_tristate '  Bridge: ebtables' CONFIG_BRIDGE_EBT $CONFIG_BRIDGE
+dep_tristate '    ebt: filter table support' CONFIG_BRIDGE_EBT_T_FILTER=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: nat table support' CONFIG_BRIDGE_EBT_T_NAT=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: broute table support' CONFIG_BRIDGE_EBT_BROUTE=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: log support' CONFIG_BRIDGE_EBT_LOG $CONFIG_BRIDGE=
_EBT
+dep_tristate '    ebt: IP filter support' CONFIG_BRIDGE_EBT_IPF=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: ARP filter support' CONFIG_BRIDGE_EBT_ARPF=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: 802.1Q VLAN filter support (EXPERIMENTAL)'=20
CONFIG_BRIDGE_EBT_VLANF $CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: mark filter support' CONFIG_BRIDGE_EBT_MARKF=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: snat target support' CONFIG_BRIDGE_EBT_SNAT=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: dnat target support' CONFIG_BRIDGE_EBT_DNAT=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: redirect target support' CONFIG_BRIDGE_EBT_REDIRE=
CT=20
$CONFIG_BRIDGE_EBT
+dep_tristate '    ebt: mark target support' CONFIG_BRIDGE_EBT_MARK_T=20
$CONFIG_BRIDGE_EBT
+
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/Config.help	Wed Sep 11 23:=
06:55=20
2002
@@ -0,0 +1,105 @@
+CONFIG_BRIDGE_EBT
+  ebtables is an extendable frame filtering system for the Linux
+  Ethernet bridge. Its usage and implementation is very similar to that
+  of iptables.
+  The difference is that ebtables works on the Link Layer, while iptable=
s
+  works on the Network Layer. ebtables can filter all frames that come
+  into contact with a logical bridge device.
+  Apart from filtering, ebtables also allows MAC source and destination
+  alterations (we call it MAC SNAT and MAC DNAT) and also provides
+  functionality for making Linux a brouter.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_T_FILTER
+  The ebtables filter table is used to define frame filtering rules at
+  local input, forwarding and local output. See the man page for
+  ebtables(8).
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_T_NAT
+  The ebtables nat table is used to define rules that alter the MAC
+  source address (MAC SNAT) or the MAC destination address (MAC DNAT).
+  See the man page for ebtables(8).
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_BROUTE
+  The ebtables broute table is used to define rules that decide between
+  bridging and routing frames, giving Linux the functionality of a
+  brouter. See the man page for ebtables(8) and examples on the ebtables
+  website.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_LOG
+  This option adds the log target, that you can use in any rule in
+  any ebtables table. It records the frame header to the syslog.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_IPF
+  This option adds the IP match, which allows basic IP header field
+  filtering.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_ARPF
+  This option adds the ARP match, which allows ARP and RARP header field
+  filtering.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_VLANF
+  This option adds the 802.1Q vlan match, which allows the filtering of
+  802.1Q vlan fields.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_MARKF
+  This option adds the mark match, which allows matching frames based on
+  the 'nfmark' value in the frame. This can be set by the mark target.
+  This value is the same as the one used in the iptables mark match and
+  target.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_SNAT
+  This option adds the MAC SNAT target, which allows altering the MAC
+  source address of frames.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_DNAT
+  This option adds the MAC DNAT target, which allows altering the MAC
+  destination address of frames.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_REDIRECT
+  This option adds the MAC redirect target, which allows altering the MA=
C
+  destination address of a frame to that of the device it arrived on.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
+
+CONFIG_BRIDGE_EBT_MARK_T
+  This option adds the mark target, which allows marking frames by
+  setting the 'nfmark' value in the frame.
+  This value is the same as the one used in the iptables mark match and
+  target.
+
+  If you want to compile it as a module, say M here and read
+  <file:Documentation/modules.txt>.  If unsure, say `N'.
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebtable_filter.c	Wed Sep 1=
1=20
23:06:55 2002
@@ -0,0 +1,90 @@
+/*
+ *  ebtable_filter
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  April, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/module.h>
+
+#define FILTER_VALID_HOOKS ((1 << NF_BR_LOCAL_IN) | (1 << NF_BR_FORWARD)=
 | \
+   (1 << NF_BR_LOCAL_OUT))
+
+static struct ebt_entries initial_chains[] =3D
+{
+  {0, "INPUT", 0, EBT_ACCEPT, 0},
+  {0, "FORWARD", 0, EBT_ACCEPT, 0},
+  {0, "OUTPUT", 0, EBT_ACCEPT, 0}
+};
+
+static struct ebt_replace initial_table =3D
+{
+  "filter", FILTER_VALID_HOOKS, 0, 3 * sizeof(struct ebt_entries),
+  { [NF_BR_LOCAL_IN]&initial_chains[0], [NF_BR_FORWARD]&initial_chains[1=
],
+    [NF_BR_LOCAL_OUT]&initial_chains[2] }, 0, NULL, (char *)initial_chai=
ns
+};
+
+static int check(const struct ebt_table_info *info, unsigned int valid_h=
ooks)
+{
+	if (valid_hooks & ~FILTER_VALID_HOOKS)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_table frame_filter =3D
+{=20
+  {NULL, NULL}, "filter", &initial_table, FILTER_VALID_HOOKS,=20
+  RW_LOCK_UNLOCKED, check, NULL
+};
+
+static unsigned int
+ebt_hook (unsigned int hook, struct sk_buff **pskb, const struct net_dev=
ice=20
*in,
+   const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, pskb, in, out, &frame_filter);
+}
+
+static struct nf_hook_ops ebt_ops_filter[] =3D {
+	{ { NULL, NULL }, ebt_hook, PF_BRIDGE, NF_BR_LOCAL_IN,
+	   NF_BR_PRI_FILTER_BRIDGED},
+	{ { NULL, NULL }, ebt_hook, PF_BRIDGE, NF_BR_FORWARD,
+	   NF_BR_PRI_FILTER_BRIDGED},
+	{ { NULL, NULL }, ebt_hook, PF_BRIDGE, NF_BR_LOCAL_OUT,
+	   NF_BR_PRI_FILTER_OTHER}
+};
+
+static int __init init(void)
+{
+	int i, j, ret;
+
+	ret =3D ebt_register_table(&frame_filter);
+	if (ret < 0)
+		return ret;
+	for (i =3D 0; i < sizeof(ebt_ops_filter) / sizeof(ebt_ops_filter[0]); i=
++)
+		if ((ret =3D nf_register_hook(&ebt_ops_filter[i])) < 0)
+			goto cleanup;
+	return ret;
+cleanup:
+	for (j =3D 0; j < i; j++)
+		nf_unregister_hook(&ebt_ops_filter[j]);
+	ebt_unregister_table(&frame_filter);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	int i;
+
+	for (i =3D 0; i < sizeof(ebt_ops_filter) / sizeof(ebt_ops_filter[0]); i=
++)
+		nf_unregister_hook(&ebt_ops_filter[i]);
+	ebt_unregister_table(&frame_filter);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebtable_nat.c	Wed Sep 11=20
23:06:55 2002
@@ -0,0 +1,96 @@
+/*
+ *  ebtable_nat
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  April, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/module.h>
+#define NAT_VALID_HOOKS ((1 << NF_BR_PRE_ROUTING) | (1 << NF_BR_LOCAL_OU=
T) |=20
\
+   (1 << NF_BR_POST_ROUTING))
+
+static struct ebt_entries initial_chains[] =3D
+{
+  {0, "PREROUTING", 0, EBT_ACCEPT, 0},
+  {0, "OUTPUT", 0, EBT_ACCEPT, 0},
+  {0, "POSTROUTING", 0, EBT_ACCEPT, 0}
+};
+
+static struct ebt_replace initial_table =3D
+{
+  "nat", NAT_VALID_HOOKS, 0, 3 * sizeof(struct ebt_entries),
+  { [NF_BR_PRE_ROUTING]&initial_chains[0],=20
[NF_BR_LOCAL_OUT]&initial_chains[1],
+    [NF_BR_POST_ROUTING]&initial_chains[2] }, 0, NULL, (char *)initial_c=
hains
+};
+
+static int check(const struct ebt_table_info *info, unsigned int valid_h=
ooks)
+{
+	if (valid_hooks & ~NAT_VALID_HOOKS)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_table frame_nat =3D
+{
+  {NULL, NULL}, "nat", &initial_table, NAT_VALID_HOOKS,
+  RW_LOCK_UNLOCKED, check, NULL
+};
+
+static unsigned int
+ebt_nat_dst(unsigned int hook, struct sk_buff **pskb, const struct net_d=
evice=20
*in
+   , const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, pskb, in, out, &frame_nat);
+}
+
+static unsigned int
+ebt_nat_src(unsigned int hook, struct sk_buff **pskb, const struct net_d=
evice=20
*in
+   , const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, pskb, in, out, &frame_nat);
+}
+
+static struct nf_hook_ops ebt_ops_nat[] =3D {
+	{ { NULL, NULL }, ebt_nat_dst, PF_BRIDGE, NF_BR_LOCAL_OUT,
+	   NF_BR_PRI_NAT_DST_OTHER},
+	{ { NULL, NULL }, ebt_nat_src, PF_BRIDGE, NF_BR_POST_ROUTING,
+	   NF_BR_PRI_NAT_SRC},
+	{ { NULL, NULL }, ebt_nat_dst, PF_BRIDGE, NF_BR_PRE_ROUTING,
+	   NF_BR_PRI_NAT_DST_BRIDGED},
+};
+
+static int __init init(void)
+{
+	int i, ret, j;
+
+	ret =3D ebt_register_table(&frame_nat);
+	if (ret < 0)
+		return ret;
+	for (i =3D 0; i < sizeof(ebt_ops_nat) / sizeof(ebt_ops_nat[0]); i++)
+		if ((ret =3D nf_register_hook(&ebt_ops_nat[i])) < 0)
+			goto cleanup;
+	return ret;
+cleanup:
+	for (j =3D 0; j < i; j++)
+		nf_unregister_hook(&ebt_ops_nat[j]);
+	ebt_unregister_table(&frame_nat);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	int i;
+
+	for (i =3D 0; i < sizeof(ebt_ops_nat) / sizeof(ebt_ops_nat[0]); i++)
+		nf_unregister_hook(&ebt_ops_nat[i]);
+	ebt_unregister_table(&frame_nat);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebtable_broute.c	Wed Sep 1=
1=20
23:06:55 2002
@@ -0,0 +1,75 @@
+/*
+ *  ebtable_broute
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  April, 2002
+ *
+ *  This table lets you choose between routing and bridging for frames
+ *  entering on a bridge enslaved nic. This table is traversed before an=
y
+ *  other ebtables table. See net/bridge/br_input.c.
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/module.h>
+#include <linux/if_bridge.h>
+#include <linux/brlock.h>
+
+// EBT_ACCEPT means the frame will be bridged
+// EBT_DROP means the frame will be routed
+static struct ebt_entries initial_chain =3D
+  {0, "BROUTING", 0, EBT_ACCEPT, 0};
+
+static struct ebt_replace initial_table =3D
+{
+  "broute", 1 << NF_BR_BROUTING, 0, sizeof(struct ebt_entries),
+  { [NF_BR_BROUTING]&initial_chain}, 0, NULL, (char *)&initial_chain
+};
+
+static int check(const struct ebt_table_info *info, unsigned int valid_h=
ooks)
+{
+	if (valid_hooks & ~(1 << NF_BR_BROUTING))
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_table broute_table =3D
+{
+  {NULL, NULL}, "broute", &initial_table, 1 << NF_BR_BROUTING,
+  RW_LOCK_UNLOCKED, check, NULL
+};
+
+static unsigned int
+ebt_broute(unsigned int hook, struct sk_buff **pskb, const struct net_de=
vice=20
*in,
+   const struct net_device *out, int (*okfn)(struct sk_buff *))
+{
+	return ebt_do_table(hook, pskb, in, out, &broute_table);
+}
+
+static int __init init(void)
+{
+	int ret;
+
+	ret =3D ebt_register_table(&broute_table);
+	if (ret < 0)
+		return ret;
+	br_write_lock_bh(BR_NETPROTO_LOCK);
+	// in br_input.c, br_handle_frame() wants to call broute_decision()
+	broute_decision =3D ebt_broute;
+	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	return ret;
+}
+
+static void __exit fini(void)
+{
+	br_write_lock_bh(BR_NETPROTO_LOCK);
+	broute_decision =3D NULL;
+	br_write_unlock_bh(BR_NETPROTO_LOCK);
+	ebt_unregister_table(&broute_table);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_mark.c	Wed Sep 11 23:0=
6:55=20
2002
@@ -0,0 +1,66 @@
+/*
+ *  ebt_mark
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  July, 2002
+ *
+ */
+
+// The mark target can be used in any chain
+// I believe adding a mangle table just for marking is total overkill
+// Marking a frame doesn't really change anything in the frame anyway
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_mark_t.h>
+#include <linux/module.h>
+
+static int ebt_target_mark(struct sk_buff **pskb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_mark_t_info *info =3D (struct ebt_mark_t_info *)data;
+
+	if ((*pskb)->nfmark !=3D info->mark) {
+		(*pskb)->nfmark =3D info->mark;
+		(*pskb)->nfcache |=3D NFC_ALTERED;
+	}
+	return info->target;
+}
+
+static int ebt_target_mark_check(const char *tablename, unsigned int=20
hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_mark_t_info *info =3D (struct ebt_mark_t_info *)data;
+
+	if (datalen !=3D sizeof(struct ebt_mark_t_info))
+		return -EINVAL;
+	if (BASE_CHAIN && info->target =3D=3D EBT_RETURN)
+		return -EINVAL;
+	CLEAR_BASE_CHAIN_BIT;
+	if (INVALID_TARGET)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_target mark_target =3D
+{
+	{NULL, NULL}, EBT_MARK_TARGET, ebt_target_mark,
+	ebt_target_mark_check, NULL, THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_target(&mark_target);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_target(&mark_target);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_mark_m.c	Wed Sep 11=20
23:06:55 2002
@@ -0,0 +1,61 @@
+/*
+ *  ebt_mark_m
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  July, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_mark_m.h>
+#include <linux/module.h>
+
+static int ebt_filter_mark(const struct sk_buff *skb,
+   const struct net_device *in, const struct net_device *out, const void=
=20
*data,
+   unsigned int datalen)
+{
+	struct ebt_mark_m_info *info =3D (struct ebt_mark_m_info *) data;
+
+	if (info->bitmask & EBT_MARK_OR)
+		return !(!!(skb->nfmark & info->mask) ^ info->invert);
+	return !(((skb->nfmark & info->mask) =3D=3D info->mark) ^ info->invert)=
;
+}
+
+static int ebt_mark_check(const char *tablename, unsigned int hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+        struct ebt_mark_m_info *info =3D (struct ebt_mark_m_info *) data=
;
+
+	if (datalen !=3D sizeof(struct ebt_mark_m_info))
+		return -EINVAL;
+	if (info->bitmask & ~EBT_MARK_MASK)
+		return -EINVAL;
+	if ((info->bitmask & EBT_MARK_OR) && (info->bitmask & EBT_MARK_AND))
+		return -EINVAL;
+	if (!info->bitmask)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_match filter_mark =3D
+{
+	{NULL, NULL}, EBT_MARK_MATCH, ebt_filter_mark, ebt_mark_check, NULL,
+	THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_match(&filter_mark);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_match(&filter_mark);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_redirect.c	Wed Sep 11=20
23:06:55 2002
@@ -0,0 +1,71 @@
+/*
+ *  ebt_redirect
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  April, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_redirect.h>
+#include <linux/module.h>
+#include <net/sock.h>
+#include "../br_private.h"
+
+static int ebt_target_redirect(struct sk_buff **pskb, unsigned int hookn=
r,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_redirect_info *info =3D (struct ebt_redirect_info *)data;
+
+	if (hooknr !=3D NF_BR_BROUTING)
+		memcpy((**pskb).mac.ethernet->h_dest,
+		   in->br_port->br->dev.dev_addr, ETH_ALEN);
+	else {
+		memcpy((**pskb).mac.ethernet->h_dest,
+		   in->dev_addr, ETH_ALEN);
+		(*pskb)->pkt_type =3D PACKET_HOST;
+	}
+	return info->target;
+}
+
+static int ebt_target_redirect_check(const char *tablename, unsigned int=
=20
hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_redirect_info *info =3D (struct ebt_redirect_info *)data;
+
+	if (datalen !=3D sizeof(struct ebt_redirect_info))
+		return -EINVAL;
+	if (BASE_CHAIN && info->target =3D=3D EBT_RETURN)
+		return -EINVAL;
+	CLEAR_BASE_CHAIN_BIT;
+	if ( (strcmp(tablename, "nat") || hookmask & ~(1 << NF_BR_PRE_ROUTING))=
 &&
+	     (strcmp(tablename, "broute") || hookmask & ~(1 << NF_BR_BROUTING))=
 )
+		return -EINVAL;
+	if (INVALID_TARGET)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_target redirect_target =3D
+{
+	{NULL, NULL}, EBT_REDIRECT_TARGET, ebt_target_redirect,
+	ebt_target_redirect_check, NULL, THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_target(&redirect_target);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_target(&redirect_target);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_arp.c	Wed Sep 11 23:06=
:55=20
2002
@@ -0,0 +1,102 @@
+/*
+ *  ebt_arp
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *	Tim Gardner <timg@tpi.com>
+ *
+ *  April, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_arp.h>
+#include <linux/if_arp.h>
+#include <linux/module.h>
+
+static int ebt_filter_arp(const struct sk_buff *skb, const struct net_de=
vice=20
*in,
+   const struct net_device *out, const void *data, unsigned int datalen)
+{
+	struct ebt_arp_info *info =3D (struct ebt_arp_info *)data;
+
+	if (info->bitmask & EBT_ARP_OPCODE && FWINV(info->opcode !=3D
+	   ((*skb).nh.arph)->ar_op, EBT_ARP_OPCODE))
+		return EBT_NOMATCH;
+	if (info->bitmask & EBT_ARP_HTYPE && FWINV(info->htype !=3D
+	   ((*skb).nh.arph)->ar_hrd, EBT_ARP_HTYPE))
+		return EBT_NOMATCH;
+	if (info->bitmask & EBT_ARP_PTYPE && FWINV(info->ptype !=3D
+	   ((*skb).nh.arph)->ar_pro, EBT_ARP_PTYPE))
+		return EBT_NOMATCH;
+
+	if (info->bitmask & (EBT_ARP_SRC_IP | EBT_ARP_DST_IP))
+	{
+		uint32_t arp_len =3D sizeof(struct arphdr) +
+		   (2 * (((*skb).nh.arph)->ar_hln)) +
+		   (2 * (((*skb).nh.arph)->ar_pln));
+		uint32_t dst;
+		uint32_t src;
+
+		// Make sure the packet is long enough.
+		if ((((*skb).nh.raw) + arp_len) > (*skb).tail)
+			return EBT_NOMATCH;
+		// IPv4 addresses are always 4 bytes.
+		if (((*skb).nh.arph)->ar_pln !=3D sizeof(uint32_t))
+			return EBT_NOMATCH;
+
+		if (info->bitmask & EBT_ARP_SRC_IP) {
+			memcpy(&src, ((*skb).nh.raw) + sizeof(struct arphdr) +
+			   ((*skb).nh.arph)->ar_hln, sizeof(uint32_t));
+			if (FWINV(info->saddr !=3D (src & info->smsk),
+			   EBT_ARP_SRC_IP))
+				return EBT_NOMATCH;
+		}
+
+		if (info->bitmask & EBT_ARP_DST_IP) {
+			memcpy(&dst, ((*skb).nh.raw)+sizeof(struct arphdr) +
+			   (2*(((*skb).nh.arph)->ar_hln)) +
+			   (((*skb).nh.arph)->ar_pln), sizeof(uint32_t));
+			if (FWINV(info->daddr !=3D (dst & info->dmsk),
+			   EBT_ARP_DST_IP))
+				return EBT_NOMATCH;
+		}
+	}
+	return EBT_MATCH;
+}
+
+static int ebt_arp_check(const char *tablename, unsigned int hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_arp_info *info =3D (struct ebt_arp_info *)data;
+
+	if (datalen !=3D sizeof(struct ebt_arp_info))
+		return -EINVAL;
+	if ((e->ethproto !=3D __constant_htons(ETH_P_ARP) &&
+	   e->ethproto !=3D __constant_htons(ETH_P_RARP)) ||
+	   e->invflags & EBT_IPROTO)
+		return -EINVAL;
+	if (info->bitmask & ~EBT_ARP_MASK || info->invflags & ~EBT_ARP_MASK)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_match filter_arp =3D
+{
+	{NULL, NULL}, EBT_ARP_MATCH, ebt_filter_arp, ebt_arp_check, NULL,
+	THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_match(&filter_arp);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_match(&filter_arp);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_ip.c	Wed Sep 11 23:06:=
55=20
2002
@@ -0,0 +1,73 @@
+/*
+ *  ebt_ip
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  April, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_ip.h>
+#include <linux/ip.h>
+#include <linux/module.h>
+
+static int ebt_filter_ip(const struct sk_buff *skb, const struct net_dev=
ice=20
*in,
+   const struct net_device *out, const void *data,
+   unsigned int datalen)
+{
+	struct ebt_ip_info *info =3D (struct ebt_ip_info *)data;
+
+	if (info->bitmask & EBT_IP_TOS &&
+	   FWINV(info->tos !=3D ((*skb).nh.iph)->tos, EBT_IP_TOS))
+		return EBT_NOMATCH;
+	if (info->bitmask & EBT_IP_PROTO && FWINV(info->protocol !=3D
+	   ((*skb).nh.iph)->protocol, EBT_IP_PROTO))
+		return EBT_NOMATCH;
+	if (info->bitmask & EBT_IP_SOURCE &&
+	   FWINV((((*skb).nh.iph)->saddr & info->smsk) !=3D
+	   info->saddr, EBT_IP_SOURCE))
+		return EBT_NOMATCH;
+	if ((info->bitmask & EBT_IP_DEST) &&
+	   FWINV((((*skb).nh.iph)->daddr & info->dmsk) !=3D
+	   info->daddr, EBT_IP_DEST))
+		return EBT_NOMATCH;
+	return EBT_MATCH;
+}
+
+static int ebt_ip_check(const char *tablename, unsigned int hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_ip_info *info =3D (struct ebt_ip_info *)data;
+
+	if (datalen !=3D sizeof(struct ebt_ip_info))
+		return -EINVAL;
+	if (e->ethproto !=3D __constant_htons(ETH_P_IP) ||
+	   e->invflags & EBT_IPROTO)
+		return -EINVAL;
+	if (info->bitmask & ~EBT_IP_MASK || info->invflags & ~EBT_IP_MASK)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_match filter_ip =3D
+{
+	{NULL, NULL}, EBT_IP_MATCH, ebt_filter_ip, ebt_ip_check, NULL,
+	THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_match(&filter_ip);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_match(&filter_ip);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_vlan.c	Wed Sep 11 23:5=
6:37=20
2002
@@ -0,0 +1,318 @@
+/*
+ * Description: EBTables 802.1Q match extension kernelspace module.
+ * Authors: Nick Fedchik <nick@fedchik.org.ua>
+ *          Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *   =20
+ * This program is free software; you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *=20
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY; without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
+ * GNU General Public License for more details.
+ * =20
+ * You should have received a copy of the GNU General Public License
+ * along with this program; if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA  02111-1307 =
 USA
+ */
+
+#include <linux/if_ether.h>
+#include <linux/if_vlan.h>
+#include <linux/module.h>
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_vlan.h>
+
+static unsigned char debug;
+#define MODULE_VERSION "0.4 (" __DATE__ " " __TIME__ ")"
+
+MODULE_PARM (debug, "0-1b");
+MODULE_PARM_DESC (debug, "debug=3D1 is turn on debug messages");
+MODULE_AUTHOR ("Nick Fedchik <nick@fedchik.org.ua>");
+MODULE_DESCRIPTION ("802.1Q match module (ebtables extension), v"
+		    MODULE_VERSION);
+MODULE_LICENSE ("GPL");
+
+
+#define DEBUG_MSG(...) if (debug) printk (KERN_DEBUG __FILE__ ":"=20
__VA_ARGS__)
+#define INV_FLAG(_inv_flag_) (info->invflags & _inv_flag_) ? "!" : ""
+#define GET_BITMASK(_BIT_MASK_) info->bitmask & _BIT_MASK_
+#define SET_BITMASK(_BIT_MASK_) info->bitmask |=3D _BIT_MASK_
+#define EXIT_ON_MISMATCH(_MATCH_,_MASK_) if (!((info->_MATCH_ =3D=3D=20
_MATCH_)^!!(info->invflags & _MASK_))) return 1;
+
+/*
+ * Function description: ebt_filter_vlan() is main engine for=20
+ * checking passed 802.1Q frame according to=20
+ * the passed extension parameters (in the *data buffer)
+ * ebt_filter_vlan() is called after successfull check the rule params
+ * by ebt_check_vlan() function.
+ * Parameters:
+ * const struct sk_buff *skb - pointer to passed ethernet frame buffer
+ * const void *data - pointer to passed extension parameters
+ * unsigned int datalen - length of passed *data buffer
+ * const struct net_device *in  -
+ * const struct net_device *out -
+ * const struct ebt_counter *c -
+ * Returned values:
+ * 0 - ok (all rule params matched)
+ * 1 - miss (rule params not acceptable to the parsed frame)
+ */
+static int
+ebt_filter_vlan (const struct sk_buff *skb,
+		 const struct net_device *in,
+		 const struct net_device *out,
+		 const void *data,
+		 unsigned int datalen)
+{
+	struct ebt_vlan_info *info =3D (struct ebt_vlan_info *) data;	/* usersp=
ace=20
data */
+	struct vlan_ethhdr *frame =3D (struct vlan_ethhdr *) skb->mac.raw;	/* P=
assed=20
tagged frame */
+
+	unsigned short TCI;	/* Whole TCI, given from parsed frame */
+	unsigned short id;	/* VLAN ID, given from frame TCI */
+	unsigned char prio;	/* user_priority, given from frame TCI */
+	unsigned short encap;	/* VLAN encapsulated Type/Length field, given fro=
m=20
orig frame */
+
+	/*
+	 * Tag Control Information (TCI) consists of the following elements:
+	 * - User_priority. This field allows the tagged frame to carry=20
user_priority
+	 * information across Bridged LANs in which individual LAN segments may=
 be=20
unable to signal
+	 * priority information (e.g., 802.3/Ethernet segments).=20
+	 * The user_priority field is three bits in length,=20
+	 * interpreted as a binary number. The user_priority is therefore
+	 * capable of representing eight priority levels, 0 through 7.=20
+	 * The use and interpretation of this field is defined in ISO/IEC 15802=
-3.
+	 * - Canonical Format Indicator (CFI). This field is used,
+	 * in 802.3/Ethernet, to signal the presence or absence
+	 * of a RIF field, and, in combination with the Non-canonical Format=20
Indicator (NCFI) carried
+	 * in the RIF, to signal the bit order of address information carried i=
n the=20
encapsulated
+	 * frame. The Canonical Format Indicator (CFI) is a single bit flag val=
ue.
+	 * - VLAN Identifier (VID). This field uniquely identifies the VLAN to
+	 * which the frame belongs. The twelve-bit VLAN Identifier (VID) field=20
+	 * uniquely identify the VLAN to which the frame belongs.=20
+	 * The VID is encoded as an unsigned binary number.=20
+	 */
+	TCI =3D ntohs (frame->h_vlan_TCI);
+	id =3D TCI & 0xFFF;
+	prio =3D TCI >> 13;
+	encap =3D frame->h_vlan_encapsulated_proto;
+
+	/*
+	 * First step is to check is null VLAN ID present
+	 * in the parsed frame
+	 */
+	if (!(id)) {
+		/*
+		 * Checking VLAN Identifier (VID)
+		 */
+		if (GET_BITMASK (EBT_VLAN_ID)) {	/* Is VLAN ID parsed? */
+			EXIT_ON_MISMATCH (id, EBT_VLAN_ID);
+			DEBUG_MSG
+			    ("matched rule id=3D%s%d for frame id=3D%d\n",
+			     INV_FLAG (EBT_VLAN_ID), info->id, id);
+		}
+	} else {
+		/*
+		 * Checking user_priority
+		 */
+		if (GET_BITMASK (EBT_VLAN_PRIO)) {	/* Is VLAN user_priority parsed? */
+			EXIT_ON_MISMATCH (prio, EBT_VLAN_PRIO);
+			DEBUG_MSG
+			    ("matched rule prio=3D%s%d for frame prio=3D%d\n",
+			     INV_FLAG (EBT_VLAN_PRIO), info->prio,
+			     prio);
+		}
+	}
+	/*
+	 * Checking Encapsulated Proto (Length/Type) field
+	 */
+	if (GET_BITMASK (EBT_VLAN_ENCAP)) {	/* Is VLAN Encap parsed? */
+		EXIT_ON_MISMATCH (encap, EBT_VLAN_ENCAP);
+		DEBUG_MSG ("matched encap=3D%s%2.4X for frame encap=3D%2.4X\n",
+			   INV_FLAG (EBT_VLAN_ENCAP),
+			   ntohs (info->encap), ntohs (encap));
+	}
+	/*
+	 * All possible extension parameters was parsed.
+	 * If rule never returned by missmatch, then all ok.
+	 */
+	return 0;
+}
+
+/*
+ * Function description: ebt_vlan_check() is called when userspace=20
+ * delivers the table to the kernel,=20
+ * and to check that userspace doesn't give a bad table.
+ * Parameters:
+ * const char *tablename - table name string
+ * unsigned int hooknr - hook number
+ * const struct ebt_entry *e - ebtables entry basic set
+ * const void *data - pointer to passed extension parameters
+ * unsigned int datalen - length of passed *data buffer
+ * Returned values:
+ * 0 - ok (all delivered rule params are correct)
+ * 1 - miss (rule params is out of range, invalid, incompatible, etc.)
+ */
+static int
+ebt_check_vlan (const char *tablename,
+		unsigned int hooknr,
+		const struct ebt_entry *e, void *data,
+		unsigned int datalen)
+{
+	struct ebt_vlan_info *info =3D (struct ebt_vlan_info *) data;
+
+	/*
+	 * Parameters buffer overflow check=20
+	 */
+	if (datalen !=3D sizeof (struct ebt_vlan_info)) {
+		DEBUG_MSG
+		    ("params size %d is not eq to ebt_vlan_info (%d)\n",
+		     datalen, sizeof (struct ebt_vlan_info));
+		return -EINVAL;
+	}
+
+	/*
+	 * Is it 802.1Q frame checked?
+	 */
+	if (e->ethproto !=3D __constant_htons (ETH_P_8021Q)) {
+		DEBUG_MSG ("passed entry proto %2.4X is not 802.1Q (8100)\n",
+			   (unsigned short) ntohs (e->ethproto));
+		return -EINVAL;
+	}
+
+	/*
+	 * Check for bitmask range=20
+	 * True if even one bit is out of mask
+	 */
+	if (info->bitmask & ~EBT_VLAN_MASK) {
+		DEBUG_MSG ("bitmask %2X is out of mask (%2X)\n",
+			   info->bitmask, EBT_VLAN_MASK);
+		return -EINVAL;
+	}
+
+	/*
+	 * Check for inversion flags range=20
+	 */
+	if (info->invflags & ~EBT_VLAN_MASK) {
+		DEBUG_MSG ("inversion flags %2X is out of mask (%2X)\n",
+			   info->invflags, EBT_VLAN_MASK);
+		return -EINVAL;
+	}
+
+	/*
+	 * Reserved VLAN ID (VID) values
+	 * -----------------------------
+	 * 0 - The null VLAN ID. Indicates that the tag header contains only=20
user_priority information;
+	 * no VLAN identifier is present in the frame. This VID value shall not=
 be
+	 * configured as a PVID, configured in any Filtering Database entry, or=
 used=20
in any
+	 * Management operation.
+	 *=20
+	 * 1 - The default Port VID (PVID) value used for classifying frames on=
=20
ingress through a Bridge
+	 * Port. The PVID value can be changed by management on a per-Port basi=
s.
+	 *=20
+	 * 0x0FFF - Reserved for implementation use. This VID value shall not b=
e=20
configured as a
+	 * PVID or transmitted in a tag header.
+	 *=20
+	 * The remaining values of VID are available for general use as VLAN=20
identifiers.
+	 * A Bridge may implement the ability to support less than the full ran=
ge of=20
VID values;=20
+	 * i.e., for a given implementation,
+	 * an upper limit, N, is defined for the VID values supported, where N =
is=20
less than or equal to 4094.
+	 * All implementations shall support the use of all VID values in the r=
ange=20
0 through their defined maximum
+	 * VID, N.
+	 *=20
+	 * For Linux, N =3D 4094.
+	 */
+	if (GET_BITMASK (EBT_VLAN_ID)) {	/* when vlan-id param was spec-ed */
+		if (!!info->id) {	/* if id!=3D0 =3D> check vid range */
+			if (info->id > 4094) {	/* check if id > than (0x0FFE) */
+				DEBUG_MSG
+				    ("vlan id %d is out of range (1-4094)\n",
+				     info->id);
+				return -EINVAL;
+			}
+			/*
+			 * Note: This is valid VLAN-tagged frame point.
+			 * Any value of user_priority are acceptable, but could be ignored
+			 * according to 802.1Q Std.
+			 */
+		} else {
+			/*
+			 * if id=3D0 (null VLAN ID)  =3D> Check for user_priority range=20
+			 */
+			if (GET_BITMASK (EBT_VLAN_PRIO)) {
+				if ((unsigned char) info->prio > 7) {
+					DEBUG_MSG
+					    ("prio %d is out of range (0-7)\n",
+					     info->prio);
+					return -EINVAL;
+				}
+			}
+			/*
+			 * Note2: This is valid priority-tagged frame point
+			 * with null VID field.
+			 */
+		}
+	} else {		/* VLAN Id not set */
+		if (GET_BITMASK (EBT_VLAN_PRIO)) {	/* But user_priority is set - abnor=
mal!=20
*/
+			info->id =3D 0;	/* Set null VID (case for Priority-tagged frames) */
+			SET_BITMASK (EBT_VLAN_ID);	/* and set id flag */
+		}
+	}
+	/*
+	 * Check for encapsulated proto range - it is possible to be any value =
for=20
u_short range.
+	 * When relaying a tagged frame between 802.3/Ethernet MACs,=20
+	 * a Bridge may adjust the padding field such that
+	 * the minimum size of a transmitted tagged frame is 68 octets (7.2).
+	 * if_ether.h:  ETH_ZLEN        60   -  Min. octets in frame sans FCS
+	 */
+	if (GET_BITMASK (EBT_VLAN_ENCAP)) {
+		if ((unsigned short) ntohs (info->encap) < ETH_ZLEN) {
+			DEBUG_MSG
+			    ("encap packet length %d is less than minimal %d\n",
+			     ntohs (info->encap), ETH_ZLEN);
+			return -EINVAL;
+		}
+	}
+
+	/*
+	 * Otherwise is all correct=20
+	 */
+	DEBUG_MSG ("802.1Q tagged frame checked (%s table, %d hook)\n",
+		   tablename, hooknr);
+	return 0;
+}
+
+static struct ebt_match filter_vlan =3D {
+	{NULL, NULL},
+	EBT_VLAN_MATCH,
+	ebt_filter_vlan,
+	ebt_check_vlan,
+	NULL,
+	THIS_MODULE
+};
+
+/*
+ * Module initialization function.
+ * Called when module is loaded to kernelspace
+ */
+static int __init init (void)
+{
+	DEBUG_MSG ("ebtables 802.1Q extension module v"
+		   MODULE_VERSION "\n");
+	DEBUG_MSG ("module debug=3D%d\n", !!debug);
+	return ebt_register_match (&filter_vlan);
+}
+
+/*
+ * Module "finalization" function
+ * Called when download module from kernelspace
+ */
+static void __exit fini (void)
+{
+	ebt_unregister_match (&filter_vlan);
+}
+
+module_init (init);
+module_exit (fini);
+
+EXPORT_NO_SYMBOLS;
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_log.c	Wed Sep 11 23:06=
:55=20
2002
@@ -0,0 +1,100 @@
+/*
+ *  ebt_log
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  April, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_log.h>
+#include <linux/module.h>
+#include <linux/ip.h>
+#include <linux/if_arp.h>
+#include <linux/spinlock.h>
+
+static spinlock_t ebt_log_lock =3D SPIN_LOCK_UNLOCKED;
+
+static int ebt_log_check(const char *tablename, unsigned int hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_log_info *info =3D (struct ebt_log_info *)data;
+
+	if (datalen !=3D sizeof(struct ebt_log_info))
+		return -EINVAL;
+	if (info->bitmask & ~EBT_LOG_MASK)
+		return -EINVAL;
+	if (info->loglevel >=3D 8)
+		return -EINVAL;
+	info->prefix[EBT_LOG_PREFIX_SIZE - 1] =3D '\0';
+	return 0;
+}
+
+static void ebt_log(const struct sk_buff *skb, const struct net_device *=
in,
+   const struct net_device *out, const void *data, unsigned int datalen)
+{
+	struct ebt_log_info *info =3D (struct ebt_log_info *)data;
+	char level_string[4] =3D "< >";
+	level_string[1] =3D '0' + info->loglevel;
+
+	spin_lock_bh(&ebt_log_lock);
+	printk(level_string);
+	printk("%s IN=3D%s OUT=3D%s ", info->prefix, in ? in->name : "",
+	   out ? out->name : "");
+
+	if (skb->dev->hard_header_len) {
+		int i;
+		unsigned char *p =3D (skb->mac.ethernet)->h_source;
+
+		printk("MAC source =3D ");
+		for (i =3D 0; i < ETH_ALEN; i++,p++)
+			printk("%02x%c", *p, i =3D=3D ETH_ALEN - 1 ? ' ':':');
+		printk("MAC dest =3D ");
+		p =3D (skb->mac.ethernet)->h_dest;
+		for (i =3D 0; i < ETH_ALEN; i++,p++)
+			printk("%02x%c", *p, i =3D=3D ETH_ALEN - 1 ? ' ':':');
+	}
+	printk("proto =3D 0x%04x", ntohs(((*skb).mac.ethernet)->h_proto));
+
+	if ((info->bitmask & EBT_LOG_IP) && skb->mac.ethernet->h_proto =3D=3D
+	   htons(ETH_P_IP)){
+		struct iphdr *iph =3D skb->nh.iph;
+		printk(" IP SRC=3D%u.%u.%u.%u IP DST=3D%u.%u.%u.%u,",
+		   NIPQUAD(iph->saddr), NIPQUAD(iph->daddr));
+		printk(" IP tos=3D0x%02X, IP proto=3D%d", iph->tos, iph->protocol);
+	}
+
+	if ((info->bitmask & EBT_LOG_ARP) &&
+	    ((skb->mac.ethernet->h_proto =3D=3D __constant_htons(ETH_P_ARP)) ||
+	    (skb->mac.ethernet->h_proto =3D=3D __constant_htons(ETH_P_RARP)))) =
{
+		struct arphdr * arph =3D skb->nh.arph;
+		printk(" ARP HTYPE=3D%d, PTYPE=3D0x%04x, OPCODE=3D%d",
+		   ntohs(arph->ar_hrd), ntohs(arph->ar_pro),
+		   ntohs(arph->ar_op));
+	}
+	printk("\n");
+	spin_unlock_bh(&ebt_log_lock);
+}
+
+struct ebt_watcher log =3D
+{
+	{NULL, NULL}, EBT_LOG_WATCHER, ebt_log, ebt_log_check, NULL,
+	THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_watcher(&log);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_watcher(&log);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_snat.c	Wed Sep 11 23:0=
6:55=20
2002
@@ -0,0 +1,64 @@
+/*
+ *  ebt_snat
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  June, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_nat.h>
+#include <linux/module.h>
+
+static int ebt_target_snat(struct sk_buff **pskb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_nat_info *info =3D (struct ebt_nat_info *) data;
+
+	memcpy(((**pskb).mac.ethernet)->h_source, info->mac,
+	   ETH_ALEN * sizeof(unsigned char));
+	return info->target;
+}
+
+static int ebt_target_snat_check(const char *tablename, unsigned int=20
hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_nat_info *info =3D (struct ebt_nat_info *) data;
+
+	if (datalen !=3D sizeof(struct ebt_nat_info))
+		return -EINVAL;
+	if (BASE_CHAIN && info->target =3D=3D EBT_RETURN)
+		return -EINVAL;
+	CLEAR_BASE_CHAIN_BIT;
+	if (strcmp(tablename, "nat"))
+		return -EINVAL;
+	if (hookmask & ~(1 << NF_BR_POST_ROUTING))
+		return -EINVAL;
+	if (INVALID_TARGET)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_target snat =3D
+{
+	{NULL, NULL}, EBT_SNAT_TARGET, ebt_target_snat, ebt_target_snat_check,
+	NULL, THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_target(&snat);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_target(&snat);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebt_dnat.c	Wed Sep 11 23:0=
6:55=20
2002
@@ -0,0 +1,65 @@
+/*
+ *  ebt_dnat
+ *
+ *	Authors:
+ *	Bart De Schuymer <bart.de.schuymer@pandora.be>
+ *
+ *  June, 2002
+ *
+ */
+
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/netfilter_bridge/ebt_nat.h>
+#include <linux/module.h>
+#include <net/sock.h>
+
+static int ebt_target_dnat(struct sk_buff **pskb, unsigned int hooknr,
+   const struct net_device *in, const struct net_device *out,
+   const void *data, unsigned int datalen)
+{
+	struct ebt_nat_info *info =3D (struct ebt_nat_info *)data;
+
+	memcpy(((**pskb).mac.ethernet)->h_dest, info->mac,
+	   ETH_ALEN * sizeof(unsigned char));
+	return info->target;
+}
+
+static int ebt_target_dnat_check(const char *tablename, unsigned int=20
hookmask,
+   const struct ebt_entry *e, void *data, unsigned int datalen)
+{
+	struct ebt_nat_info *info =3D (struct ebt_nat_info *)data;
+
+	if (BASE_CHAIN && info->target =3D=3D EBT_RETURN)
+		return -EINVAL;
+	CLEAR_BASE_CHAIN_BIT;
+	if ( (strcmp(tablename, "nat") ||
+	   (hookmask & ~((1 << NF_BR_PRE_ROUTING) | (1 << NF_BR_LOCAL_OUT)))) &=
&
+	   (strcmp(tablename, "broute") || hookmask & ~(1 << NF_BR_BROUTING)) )
+		return -EINVAL;
+	if (datalen !=3D sizeof(struct ebt_nat_info))
+		return -EINVAL;
+	if (INVALID_TARGET)
+		return -EINVAL;
+	return 0;
+}
+
+static struct ebt_target dnat =3D
+{
+	{NULL, NULL}, EBT_DNAT_TARGET, ebt_target_dnat, ebt_target_dnat_check,
+	NULL, THIS_MODULE
+};
+
+static int __init init(void)
+{
+	return ebt_register_target(&dnat);
+}
+
+static void __exit fini(void)
+{
+	ebt_unregister_target(&dnat);
+}
+
+module_init(init);
+module_exit(fini);
+EXPORT_NO_SYMBOLS;
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/net/bridge/netfilter/ebtables.c	Wed Sep 11 23:0=
6:55=20
2002
@@ -0,0 +1,1484 @@
+/*
+ *  ebtables
+ *
+ *  Author:
+ *  Bart De Schuymer		<bart.de.schuymer@pandora.be>
+ *
+ *  ebtables.c,v 2.0, July, 2002
+ *
+ *  This code is stongly inspired on the iptables code which is
+ *  Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
+ *
+ *  This program is free software; you can redistribute it and/or
+ *  modify it under the terms of the GNU General Public License
+ *  as published by the Free Software Foundation; either version
+ *  2 of the License, or (at your option) any later version.
+ */
+
+// used for print_string
+#include <linux/sched.h>
+#include <linux/tty.h>
+
+#include <linux/kmod.h>
+#include <linux/module.h>
+#include <linux/vmalloc.h>
+#include <linux/netfilter_bridge/ebtables.h>
+#include <linux/spinlock.h>
+#include <asm/uaccess.h>
+#include <linux/smp.h>
+#include <net/sock.h>
+// needed for logical [in,out]-dev filtering
+#include "../br_private.h"
+
+// list_named_find
+#define ASSERT_READ_LOCK(x)
+#define ASSERT_WRITE_LOCK(x)
+#include <linux/netfilter_ipv4/listhelp.h>
+
+#if 0 // use this for remote debugging
+// Copyright (C) 1998 by Ori Pomerantz
+// Print the string to the appropriate tty, the one
+// the current task uses
+static void print_string(char *str)
+{
+	struct tty_struct *my_tty;
+
+	/* The tty for the current task */
+	my_tty =3D current->tty;
+	if (my_tty !=3D NULL) {
+		(*(my_tty->driver).write)(my_tty, 0, str, strlen(str));
+		(*(my_tty->driver).write)(my_tty, 0, "\015\012", 2);
+	}
+}
+
+#define BUGPRINT(args) print_string(args);
+#else
+#define BUGPRINT(format, args...) printk("kernel msg: ebtables bug: plea=
se "\
+                                         "report to author: "format, ## =
args)
+// #define BUGPRINT(format, args...)
+#endif
+#define MEMPRINT(format, args...) printk("kernel msg: ebtables "\
+                                         ": out of memory: "format, ## a=
rgs)
+// #define MEMPRINT(format, args...)
+
+
+
+// Each cpu has its own set of counters, so there is no need for write_l=
ock=20
in
+// the softirq
+// For reading or updating the counters, the user context needs to
+// get a write_lock
+
+// The size of each set of counters is altered to get cache alignment
+#define SMP_ALIGN(x) (((x) + SMP_CACHE_BYTES-1) & ~(SMP_CACHE_BYTES-1))
+#define COUNTER_OFFSET(n) (SMP_ALIGN(n * sizeof(struct ebt_counter)))
+#define COUNTER_BASE(c, n, cpu) ((struct ebt_counter *)(((char *)c) + \
+   COUNTER_OFFSET(n) * cpu))
+
+
+
+static DECLARE_MUTEX(ebt_mutex);
+static LIST_HEAD(ebt_tables);
+static LIST_HEAD(ebt_targets);
+static LIST_HEAD(ebt_matches);
+static LIST_HEAD(ebt_watchers);
+
+static struct ebt_target ebt_standard_target =3D
+{ {NULL, NULL}, EBT_STANDARD_TARGET, NULL, NULL, NULL, NULL};
+
+static inline int ebt_do_watcher (struct ebt_entry_watcher *w,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out)
+{
+	w->u.watcher->watcher(skb, in, out, w->data,
+	   w->watcher_size);
+	// watchers don't give a verdict
+	return 0;
+}
+
+static inline int ebt_do_match (struct ebt_entry_match *m,
+   const struct sk_buff *skb, const struct net_device *in,
+   const struct net_device *out)
+{
+	return m->u.match->match(skb, in, out, m->data,
+	   m->match_size);
+}
+
+static inline int ebt_dev_check(char *entry, const struct net_device *de=
vice)
+{
+	if (*entry =3D=3D '\0')
+		return 0;
+	if (!device)
+		return 1;
+	return !!strcmp(entry, device->name);
+}
+
+#define FWINV2(bool,invflg) ((bool) ^ !!(e->invflags & invflg))
+// process standard matches
+static inline int ebt_basic_match(struct ebt_entry *e, struct ethhdr *h,
+   const struct net_device *in, const struct net_device *out)
+{
+	int verdict, i;
+
+	if (e->bitmask & EBT_802_3) {
+		if (FWINV2(ntohs(h->h_proto) >=3D 1536, EBT_IPROTO))
+			return 1;
+	} else if (!(e->bitmask & EBT_NOPROTO) &&
+	   FWINV2(e->ethproto !=3D h->h_proto, EBT_IPROTO))
+		return 1;
+
+	if (FWINV2(ebt_dev_check(e->in, in), EBT_IIN))
+		return 1;
+	if (FWINV2(ebt_dev_check(e->out, out), EBT_IOUT))
+		return 1;
+	if ((!in || !in->br_port) ? 0 : FWINV2(ebt_dev_check(
+	   e->logical_in, &in->br_port->br->dev), EBT_ILOGICALIN))
+		return 1;
+	if ((!out || !out->br_port) ? 0 : FWINV2(ebt_dev_check(
+	   e->logical_out, &out->br_port->br->dev), EBT_ILOGICALOUT))
+		return 1;
+
+	if (e->bitmask & EBT_SOURCEMAC) {
+		verdict =3D 0;
+		for (i =3D 0; i < 6; i++)
+			verdict |=3D (h->h_source[i] ^ e->sourcemac[i]) &
+			   e->sourcemsk[i];
+		if (FWINV2(verdict !=3D 0, EBT_ISOURCE) )
+			return 1;
+	}
+	if (e->bitmask & EBT_DESTMAC) {
+		verdict =3D 0;
+		for (i =3D 0; i < 6; i++)
+			verdict |=3D (h->h_dest[i] ^ e->destmac[i]) &
+			   e->destmsk[i];
+		if (FWINV2(verdict !=3D 0, EBT_IDEST) )
+			return 1;
+	}
+	return 0;
+}
+
+// Do some firewalling
+unsigned int ebt_do_table (unsigned int hook, struct sk_buff **pskb,
+   const struct net_device *in, const struct net_device *out,
+   struct ebt_table *table)
+{
+	int i, nentries;
+	struct ebt_entry *point;
+	struct ebt_counter *counter_base, *cb_base;
+	struct ebt_entry_target *t;
+	int verdict, sp =3D 0;
+	struct ebt_chainstack *cs;
+	struct ebt_entries *chaininfo;
+	char *base;
+	struct ebt_table_info *private =3D table->private;
+
+	read_lock_bh(&table->lock);
+	cb_base =3D COUNTER_BASE(private->counters, private->nentries,
+	   smp_processor_id());
+	if (private->chainstack)
+		cs =3D private->chainstack[smp_processor_id()];
+	else
+		cs =3D NULL;
+	chaininfo =3D private->hook_entry[hook];
+	nentries =3D private->hook_entry[hook]->nentries;
+	point =3D (struct ebt_entry *)(private->hook_entry[hook]->data);
+	counter_base =3D cb_base + private->hook_entry[hook]->counter_offset;
+	// base for chain jumps
+	base =3D (char *)chaininfo;
+	i =3D 0;
+	while (i < nentries) {
+		if (ebt_basic_match(point, (**pskb).mac.ethernet, in, out))
+			goto letscontinue;
+
+		if (EBT_MATCH_ITERATE(point, ebt_do_match, *pskb, in, out) !=3D 0)
+			goto letscontinue;
+
+		// increase counter
+		(*(counter_base + i)).pcnt++;
+
+		// these should only watch: not modify, nor tell us
+		// what to do with the packet
+		EBT_WATCHER_ITERATE(point, ebt_do_watcher, *pskb, in,
+		   out);
+
+		t =3D (struct ebt_entry_target *)
+		   (((char *)point) + point->target_offset);
+		// standard target
+		if (!t->u.target->target)
+			verdict =3D ((struct ebt_standard_target *)t)->verdict;
+		else
+			verdict =3D t->u.target->target(pskb, hook,
+			   in, out, t->data, t->target_size);
+		if (verdict =3D=3D EBT_ACCEPT) {
+			read_unlock_bh(&table->lock);
+			return NF_ACCEPT;
+		}
+		if (verdict =3D=3D EBT_DROP) {
+			read_unlock_bh(&table->lock);
+			return NF_DROP;
+		}
+		if (verdict =3D=3D EBT_RETURN) {
+letsreturn:
+#ifdef CONFIG_NETFILTER_DEBUG
+			if (sp =3D=3D 0) {
+				BUGPRINT("RETURN on base chain");
+				// act like this is EBT_CONTINUE
+				goto letscontinue;
+			}
+#endif
+			sp--;
+			// put all the local variables right
+			i =3D cs[sp].n;
+			chaininfo =3D cs[sp].chaininfo;
+			nentries =3D chaininfo->nentries;
+			point =3D cs[sp].e;
+			counter_base =3D cb_base +
+			   chaininfo->counter_offset;
+			continue;
+		}
+		if (verdict =3D=3D EBT_CONTINUE)
+			goto letscontinue;
+#ifdef CONFIG_NETFILTER_DEBUG
+		if (verdict < 0) {
+			BUGPRINT("bogus standard verdict\n");
+			read_unlock_bh(&table->lock);
+			return NF_DROP;
+		}
+#endif
+		// jump to a udc
+		cs[sp].n =3D i + 1;
+		cs[sp].chaininfo =3D chaininfo;
+		cs[sp].e =3D (struct ebt_entry *)
+		   (((char *)point) + point->next_offset);
+		i =3D 0;
+		chaininfo =3D (struct ebt_entries *) (base + verdict);
+#ifdef CONFIG_NETFILTER_DEBUG
+		if (chaininfo->distinguisher) {
+			BUGPRINT("jump to non-chain\n");
+			read_unlock_bh(&table->lock);
+			return NF_DROP;
+		}
+#endif
+		nentries =3D chaininfo->nentries;
+		point =3D (struct ebt_entry *)chaininfo->data;
+		counter_base =3D cb_base + chaininfo->counter_offset;
+		sp++;
+		continue;
+letscontinue:
+		point =3D (struct ebt_entry *)
+		   (((char *)point) + point->next_offset);
+		i++;
+	}
+
+	// I actually like this :)
+	if (chaininfo->policy =3D=3D EBT_RETURN)
+		goto letsreturn;
+	if (chaininfo->policy =3D=3D EBT_ACCEPT) {
+		read_unlock_bh(&table->lock);
+		return NF_ACCEPT;
+	}
+	read_unlock_bh(&table->lock);
+	return NF_DROP;
+}
+
+// If it succeeds, returns element and locks mutex
+static inline void *
+find_inlist_lock_noload(struct list_head *head, const char *name, int *e=
rror,
+   struct semaphore *mutex)
+{
+	void *ret;
+
+	*error =3D down_interruptible(mutex);
+	if (*error !=3D 0)
+		return NULL;
+
+	ret =3D list_named_find(head, name);
+	if (!ret) {
+		*error =3D -ENOENT;
+		up(mutex);
+	}
+	return ret;
+}
+
+#ifndef CONFIG_KMOD
+#define find_inlist_lock(h,n,p,e,m) find_inlist_lock_noload((h),(n),(e),=
(m))
+#else
+static void *
+find_inlist_lock(struct list_head *head, const char *name, const char=20
*prefix,
+   int *error, struct semaphore *mutex)
+{
+	void *ret;
+
+	ret =3D find_inlist_lock_noload(head, name, error, mutex);
+	if (!ret) {
+		char modulename[EBT_FUNCTION_MAXNAMELEN + strlen(prefix) + 1];
+		strcpy(modulename, prefix);
+		strcat(modulename, name);
+		request_module(modulename);
+		ret =3D find_inlist_lock_noload(head, name, error, mutex);
+	}
+	return ret;
+}
+#endif
+
+static inline struct ebt_table *
+find_table_lock(const char *name, int *error, struct semaphore *mutex)
+{
+	return find_inlist_lock(&ebt_tables, name, "ebtable_", error, mutex);
+}
+
+static inline struct ebt_match *
+find_match_lock(const char *name, int *error, struct semaphore *mutex)
+{
+	return find_inlist_lock(&ebt_matches, name, "ebt_", error, mutex);
+}
+
+static inline struct ebt_watcher *
+find_watcher_lock(const char *name, int *error, struct semaphore *mutex)
+{
+	return find_inlist_lock(&ebt_watchers, name, "ebt_", error, mutex);
+}
+
+static inline struct ebt_target *
+find_target_lock(const char *name, int *error, struct semaphore *mutex)
+{
+	return find_inlist_lock(&ebt_targets, name, "ebt_", error, mutex);
+}
+
+static inline int
+ebt_check_match(struct ebt_entry_match *m, struct ebt_entry *e,
+   const char *name, unsigned int hookmask, unsigned int *cnt)
+{
+	struct ebt_match *match;
+	int ret;
+
+	if (((char *)m) + m->match_size + sizeof(struct ebt_entry_match) >
+	   ((char *)e) + e->watchers_offset)
+		return -EINVAL;
+	match =3D find_match_lock(m->u.name, &ret, &ebt_mutex);
+	if (!match)
+		return ret;
+	m->u.match =3D match;
+	if (match->me)
+		__MOD_INC_USE_COUNT(match->me);
+	up(&ebt_mutex);
+	if (match->check &&
+	   match->check(name, hookmask, e, m->data, m->match_size) !=3D 0) {
+		BUGPRINT("match->check failed\n");
+		if (match->me)
+			__MOD_DEC_USE_COUNT(match->me);
+		return -EINVAL;
+	}
+	(*cnt)++;
+	return 0;
+}
+
+static inline int
+ebt_check_watcher(struct ebt_entry_watcher *w, struct ebt_entry *e,
+   const char *name, unsigned int hookmask, unsigned int *cnt)
+{
+	struct ebt_watcher *watcher;
+	int ret;
+
+	if (((char *)w) + w->watcher_size + sizeof(struct ebt_entry_watcher) >
+	   ((char *)e) + e->target_offset)
+		return -EINVAL;
+	watcher =3D find_watcher_lock(w->u.name, &ret, &ebt_mutex);
+	if (!watcher)
+		return ret;
+	w->u.watcher =3D watcher;
+	if (watcher->me)
+		__MOD_INC_USE_COUNT(watcher->me);
+	up(&ebt_mutex);
+	if (watcher->check &&
+	   watcher->check(name, hookmask, e, w->data, w->watcher_size) !=3D 0) =
{
+		BUGPRINT("watcher->check failed\n");
+		if (watcher->me)
+			__MOD_DEC_USE_COUNT(watcher->me);
+		return -EINVAL;
+	}
+	(*cnt)++;
+	return 0;
+}
+
+// this one is very careful, as it is the first function
+// to parse the userspace data
+static inline int
+ebt_check_entry_size_and_hooks(struct ebt_entry *e,
+   struct ebt_table_info *newinfo, char *base, char *limit,
+   struct ebt_entries **hook_entries, unsigned int *n, unsigned int *cnt=
,
+   unsigned int *totalcnt, unsigned int *udc_cnt, unsigned int valid_hoo=
ks)
+{
+	int i;
+
+	for (i =3D 0; i < NF_BR_NUMHOOKS; i++) {
+		if ((valid_hooks & (1 << i)) =3D=3D 0)
+			continue;
+		if ( (char *)hook_entries[i] - base =3D=3D
+		   (char *)e - newinfo->entries)
+			break;
+	}
+	// beginning of a new chain
+	// if i =3D=3D NF_BR_NUMHOOKS it must be a user defined chain
+	if (i !=3D NF_BR_NUMHOOKS || !(e->bitmask & EBT_ENTRY_OR_ENTRIES)) {
+		if ((e->bitmask & EBT_ENTRY_OR_ENTRIES) !=3D 0) {
+			// we make userspace set this right,
+			// so there is no misunderstanding
+			BUGPRINT("EBT_ENTRY_OR_ENTRIES shouldn't be set "
+			         "in distinguisher\n");
+			return -EINVAL;
+		}
+		// this checks if the previous chain has as many entries
+		// as it said it has
+		if (*n !=3D *cnt) {
+			BUGPRINT("nentries does not equal the nr of entries "
+		                 "in the chain\n");
+			return -EINVAL;
+		}
+		// before we look at the struct, be sure it is not too big
+		if ((char *)hook_entries[i] + sizeof(struct ebt_entries)
+		   > limit) {
+			BUGPRINT("entries_size too small\n");
+			return -EINVAL;
+		}
+		if (((struct ebt_entries *)e)->policy !=3D EBT_DROP &&
+		   ((struct ebt_entries *)e)->policy !=3D EBT_ACCEPT) {
+			// only RETURN from udc
+			if (i !=3D NF_BR_NUMHOOKS ||
+			   ((struct ebt_entries *)e)->policy !=3D EBT_RETURN) {
+				BUGPRINT("bad policy\n");
+				return -EINVAL;
+			}
+		}
+		if (i =3D=3D NF_BR_NUMHOOKS) // it's a user defined chain
+			(*udc_cnt)++;
+		else
+			newinfo->hook_entry[i] =3D (struct ebt_entries *)e;
+		if (((struct ebt_entries *)e)->counter_offset !=3D *totalcnt) {
+			BUGPRINT("counter_offset !=3D totalcnt");
+			return -EINVAL;
+		}
+		*n =3D ((struct ebt_entries *)e)->nentries;
+		*cnt =3D 0;
+		return 0;
+	}
+	// a plain old entry, heh
+	if (sizeof(struct ebt_entry) > e->watchers_offset ||
+	   e->watchers_offset > e->target_offset ||
+	   e->target_offset >=3D e->next_offset) {
+		BUGPRINT("entry offsets not in right order\n");
+		return -EINVAL;
+	}
+	// this is not checked anywhere else
+	if (e->next_offset - e->target_offset < sizeof(struct ebt_entry_target)=
) {
+		BUGPRINT("target size too small\n");
+		return -EINVAL;
+	}
+
+	(*cnt)++;
+	(*totalcnt)++;
+	return 0;
+}
+
+struct ebt_cl_stack
+{
+	struct ebt_chainstack cs;
+	int from;
+	unsigned int hookmask;
+};
+
+// we need these positions to check that the jumps to a different part o=
f the
+// entries is a jump to the beginning of a new chain.
+static inline int
+ebt_get_udc_positions(struct ebt_entry *e, struct ebt_table_info *newinf=
o,
+   struct ebt_entries **hook_entries, unsigned int *n, unsigned int=20
valid_hooks,
+   struct ebt_cl_stack *udc)
+{
+	int i;
+
+	// we're only interested in chain starts
+	if (e->bitmask & EBT_ENTRY_OR_ENTRIES)
+		return 0;
+	for (i =3D 0; i < NF_BR_NUMHOOKS; i++) {
+		if ((valid_hooks & (1 << i)) =3D=3D 0)
+			continue;
+		if (newinfo->hook_entry[i] =3D=3D (struct ebt_entries *)e)
+			break;
+	}
+	// only care about udc
+	if (i !=3D NF_BR_NUMHOOKS)
+		return 0;
+
+	udc[*n].cs.chaininfo =3D (struct ebt_entries *)e;
+	// these initialisations are depended on later in check_chainloops()
+	udc[*n].cs.n =3D 0;
+	udc[*n].hookmask =3D 0;
+
+	(*n)++;
+	return 0;
+}
+
+static inline int
+ebt_cleanup_match(struct ebt_entry_match *m, unsigned int *i)
+{
+	if (i && (*i)-- =3D=3D 0)
+		return 1;
+	if (m->u.match->destroy)
+		m->u.match->destroy(m->data, m->match_size);
+	if (m->u.match->me)
+		__MOD_DEC_USE_COUNT(m->u.match->me);
+
+	return 0;
+}
+
+static inline int
+ebt_cleanup_watcher(struct ebt_entry_watcher *w, unsigned int *i)
+{
+	if (i && (*i)-- =3D=3D 0)
+		return 1;
+	if (w->u.watcher->destroy)
+		w->u.watcher->destroy(w->data, w->watcher_size);
+	if (w->u.watcher->me)
+		__MOD_DEC_USE_COUNT(w->u.watcher->me);
+
+	return 0;
+}
+
+static inline int
+ebt_cleanup_entry(struct ebt_entry *e, unsigned int *cnt)
+{
+	struct ebt_entry_target *t;
+
+	if ((e->bitmask & EBT_ENTRY_OR_ENTRIES) =3D=3D 0)
+		return 0;
+	// we're done
+	if (cnt && (*cnt)-- =3D=3D 0)
+		return 1;
+	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, NULL);
+	EBT_MATCH_ITERATE(e, ebt_cleanup_match, NULL);
+	t =3D (struct ebt_entry_target *)(((char *)e) + e->target_offset);
+	if (t->u.target->destroy)
+		t->u.target->destroy(t->data, t->target_size);
+	if (t->u.target->me)
+		__MOD_DEC_USE_COUNT(t->u.target->me);
+
+	return 0;
+}
+
+static inline int
+ebt_check_entry(struct ebt_entry *e, struct ebt_table_info *newinfo,
+   const char *name, unsigned int *cnt, unsigned int valid_hooks,
+   struct ebt_cl_stack *cl_s, unsigned int udc_cnt)
+{
+	struct ebt_entry_target *t;
+	struct ebt_target *target;
+	unsigned int i, j, hook =3D 0, hookmask =3D 0;
+	int ret;
+
+	// Don't mess with the struct ebt_entries
+	if ((e->bitmask & EBT_ENTRY_OR_ENTRIES) =3D=3D 0)
+		return 0;
+
+	if (e->bitmask & ~EBT_F_MASK) {
+		BUGPRINT("Unknown flag for bitmask\n");
+		return -EINVAL;
+	}
+	if (e->invflags & ~EBT_INV_MASK) {
+		BUGPRINT("Unknown flag for inv bitmask\n");
+		return -EINVAL;
+	}
+	if ( (e->bitmask & EBT_NOPROTO) && (e->bitmask & EBT_802_3) ) {
+		BUGPRINT("NOPROTO & 802_3 not allowed\n");
+		return -EINVAL;
+	}
+	// what hook do we belong to?
+	for (i =3D 0; i < NF_BR_NUMHOOKS; i++) {
+		if ((valid_hooks & (1 << i)) =3D=3D 0)
+			continue;
+		if ((char *)newinfo->hook_entry[i] < (char *)e)
+			hook =3D i;
+		else
+			break;
+	}
+	// (1 << NF_BR_NUMHOOKS) tells the check functions the rule is on
+	// a base chain
+	if (i < NF_BR_NUMHOOKS)
+		hookmask =3D (1 << hook) | (1 << NF_BR_NUMHOOKS);
+	else {
+		for (i =3D 0; i < udc_cnt; i++)
+			if ((char *)(cl_s[i].cs.chaininfo) > (char *)e)
+				break;
+		if (i =3D=3D 0)
+			hookmask =3D (1 << hook) | (1 << NF_BR_NUMHOOKS);
+		else
+			hookmask =3D cl_s[i - 1].hookmask;
+	}
+	i =3D 0;
+	ret =3D EBT_MATCH_ITERATE(e, ebt_check_match, e, name, hookmask, &i);
+	if (ret !=3D 0)
+		goto cleanup_matches;
+	j =3D 0;
+	ret =3D EBT_WATCHER_ITERATE(e, ebt_check_watcher, e, name, hookmask, &j=
);
+	if (ret !=3D 0)
+		goto cleanup_watchers;
+	t =3D (struct ebt_entry_target *)(((char *)e) + e->target_offset);
+	target =3D find_target_lock(t->u.name, &ret, &ebt_mutex);
+	if (!target)
+		goto cleanup_watchers;
+	if (target->me)
+		__MOD_INC_USE_COUNT(target->me);
+	up(&ebt_mutex);
+
+	t->u.target =3D target;
+	if (t->u.target =3D=3D &ebt_standard_target) {
+		if (e->target_offset + sizeof(struct ebt_standard_target) >
+		   e->next_offset) {
+			BUGPRINT("Standard target size too big\n");
+			ret =3D -EFAULT;
+			goto cleanup_watchers;
+		}
+		if (((struct ebt_standard_target *)t)->verdict <
+		   -NUM_STANDARD_TARGETS) {
+			BUGPRINT("Invalid standard target\n");
+			ret =3D -EFAULT;
+			goto cleanup_watchers;
+		}
+	} else if ((e->target_offset + t->target_size +
+	   sizeof(struct ebt_entry_target) > e->next_offset) ||
+	   (t->u.target->check &&
+	   t->u.target->check(name, hookmask, e, t->data, t->target_size) !=3D =
0)){
+		if (t->u.target->me)
+			__MOD_DEC_USE_COUNT(t->u.target->me);
+		ret =3D -EFAULT;
+		goto cleanup_watchers;
+	}
+	(*cnt)++;
+	return 0;
+cleanup_watchers:
+	EBT_WATCHER_ITERATE(e, ebt_cleanup_watcher, &j);
+cleanup_matches:
+	EBT_MATCH_ITERATE(e, ebt_cleanup_match, &i);
+	return ret;
+}
+
+// checks for loops and sets the hook mask for udc
+// the hook mask for udc tells us from which base chains the udc can be
+// accessed. This mask is a parameter to the check() functions of the=20
extensions
+int check_chainloops(struct ebt_entries *chain, struct ebt_cl_stack *cl_=
s,
+   unsigned int udc_cnt, unsigned int hooknr, char *base)
+{
+	int i, chain_nr =3D -1, pos =3D 0, nentries =3D chain->nentries, verdic=
t;
+	struct ebt_entry *e =3D (struct ebt_entry *)chain->data;
+	struct ebt_entry_target *t;
+
+	while (pos < nentries || chain_nr !=3D -1) {
+		// end of udc, go back one 'recursion' step
+		if (pos =3D=3D nentries) {
+			// put back values of the time when this chain was called
+			e =3D cl_s[chain_nr].cs.e;
+			if (cl_s[chain_nr].from !=3D -1)
+				nentries =3D
+				cl_s[cl_s[chain_nr].from].cs.chaininfo->nentries;
+			else
+				nentries =3D chain->nentries;
+			pos =3D cl_s[chain_nr].cs.n;
+			// make sure we won't see a loop that isn't one
+			cl_s[chain_nr].cs.n =3D 0;
+			chain_nr =3D cl_s[chain_nr].from;
+			if (pos =3D=3D nentries)
+				continue;
+		}
+		t =3D (struct ebt_entry_target *)
+		   (((char *)e) + e->target_offset);
+		if (strcmp(t->u.name, EBT_STANDARD_TARGET))
+			goto letscontinue;
+		if (e->target_offset + sizeof(struct ebt_standard_target) >
+		   e->next_offset) {
+			BUGPRINT("Standard target size too big\n");
+			return -1;
+		}
+		verdict =3D ((struct ebt_standard_target *)t)->verdict;
+		if (verdict >=3D 0) { // jump to another chain
+			struct ebt_entries *hlp2 =3D
+			   (struct ebt_entries *)(base + verdict);
+			for (i =3D 0; i < udc_cnt; i++)
+				if (hlp2 =3D=3D cl_s[i].cs.chaininfo)
+					break;
+			// bad destination or loop
+			if (i =3D=3D udc_cnt) {
+				BUGPRINT("bad destination\n");
+				return -1;
+			}
+			if (cl_s[i].cs.n) {
+				BUGPRINT("loop\n");
+				return -1;
+			}
+			// this can't be 0, so the above test is correct
+			cl_s[i].cs.n =3D pos + 1;
+			pos =3D 0;
+			cl_s[i].cs.e =3D ((void *)e + e->next_offset);
+			e =3D (struct ebt_entry *)(hlp2->data);
+			nentries =3D hlp2->nentries;
+			cl_s[i].from =3D chain_nr;
+			chain_nr =3D i;
+			// this udc is accessible from the base chain for hooknr
+			cl_s[i].hookmask |=3D (1 << hooknr);
+			continue;
+		}
+letscontinue:
+		e =3D (void *)e + e->next_offset;
+		pos++;
+	}
+	return 0;
+}
+
+// do the parsing of the table/chains/entries/matches/watchers/targets, =
heh
+static int translate_table(struct ebt_replace *repl,
+   struct ebt_table_info *newinfo)
+{
+	unsigned int i, j, k, udc_cnt;
+	int ret;
+	struct ebt_cl_stack *cl_s =3D NULL; // used in the checking for chain l=
oops
+
+	i =3D 0;
+	while (i < NF_BR_NUMHOOKS && !(repl->valid_hooks & (1 << i)))
+		i++;
+	if (i =3D=3D NF_BR_NUMHOOKS) {
+		BUGPRINT("No valid hooks specified\n");
+		return -EINVAL;
+	}
+	if (repl->hook_entry[i] !=3D (struct ebt_entries *)repl->entries) {
+		BUGPRINT("Chains don't start at beginning\n");
+		return -EINVAL;
+	}
+	// make sure chains are ordered after each other in same order
+	// as their corresponding hooks
+	for (j =3D i + 1; j < NF_BR_NUMHOOKS; j++) {
+		if (!(repl->valid_hooks & (1 << j)))
+			continue;
+		if ( repl->hook_entry[j] <=3D repl->hook_entry[i] ) {
+			BUGPRINT("Hook order must be followed\n");
+			return -EINVAL;
+		}
+		i =3D j;
+	}
+
+	for (i =3D 0; i < NF_BR_NUMHOOKS; i++)
+		newinfo->hook_entry[i] =3D NULL;
+
+	newinfo->entries_size =3D repl->entries_size;
+	newinfo->nentries =3D repl->nentries;
+
+	// do some early checkings and initialize some things
+	i =3D 0; // holds the expected nr. of entries for the chain
+	j =3D 0; // holds the up to now counted entries for the chain
+	k =3D 0; // holds the total nr. of entries, should equal
+	       // newinfo->nentries afterwards
+	udc_cnt =3D 0; // will hold the nr. of user defined chains (udc)
+	ret =3D EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
+	   ebt_check_entry_size_and_hooks, newinfo, repl->entries,
+	   repl->entries + repl->entries_size, repl->hook_entry, &i, &j, &k,
+	   &udc_cnt, repl->valid_hooks);
+
+	if (ret !=3D 0)
+		return ret;
+
+	if (i !=3D j) {
+		BUGPRINT("nentries does not equal the nr of entries in the "
+		         "(last) chain\n");
+		return -EINVAL;
+	}
+	if (k !=3D newinfo->nentries) {
+		BUGPRINT("Total nentries is wrong\n");
+		return -EINVAL;
+	}
+
+	// check if all valid hooks have a chain
+	for (i =3D 0; i < NF_BR_NUMHOOKS; i++) {
+		if (newinfo->hook_entry[i] =3D=3D NULL &&
+		   (repl->valid_hooks & (1 << i))) {
+			BUGPRINT("Valid hook without chain\n");
+			return -EINVAL;
+		}
+	}
+
+	// Get the location of the udc, put them in an array
+	// While we're at it, allocate the chainstack
+	if (udc_cnt) {
+		// this will get free'd in do_replace()/ebt_register_table()
+		// if an error occurs
+		newinfo->chainstack =3D (struct ebt_chainstack **)
+		   vmalloc(NR_CPUS * sizeof(struct ebt_chainstack));
+		if (!newinfo->chainstack)
+			return -ENOMEM;
+		for (i =3D 0; i < NR_CPUS; i++) {
+			newinfo->chainstack[i] =3D
+			   vmalloc(udc_cnt * sizeof(struct ebt_chainstack));
+			if (!newinfo->chainstack[i]) {
+				while (i)
+					vfree(newinfo->chainstack[--i]);
+				vfree(newinfo->chainstack);
+				newinfo->chainstack =3D NULL;
+				return -ENOMEM;
+			}
+		}
+
+		cl_s =3D (struct ebt_cl_stack *)
+		   vmalloc(udc_cnt * sizeof(struct ebt_cl_stack));
+		if (!cl_s)
+			return -ENOMEM;
+		i =3D 0; // the i'th udc
+		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
+		   ebt_get_udc_positions, newinfo, repl->hook_entry, &i,
+		   repl->valid_hooks, cl_s);
+		// sanity check
+		if (i !=3D udc_cnt) {
+			BUGPRINT("i !=3D udc_cnt\n");
+			vfree(cl_s);
+			return -EFAULT;
+		}
+	}
+
+	// Check for loops
+	for (i =3D 0; i < NF_BR_NUMHOOKS; i++)
+		if (repl->valid_hooks & (1 << i))
+			if (check_chainloops(newinfo->hook_entry[i],
+			   cl_s, udc_cnt, i, newinfo->entries)) {
+				if (cl_s)
+					vfree(cl_s);
+				return -EINVAL;
+			}
+
+	// we now know the following (along with E=3Dmc=B2):
+	// - the nr of entries in each chain is right
+	// - the size of the allocated space is right
+	// - all valid hooks have a corresponding chain
+	// - there are no loops
+	// - wrong data can still be on the level of a single entry
+	// - could be there are jumps to places that are not the
+	//   beginning of a chain. This can only occur in chains that
+	//   are not accessible from any base chains, so we don't care.
+
+	// used to know what we need to clean up if something goes wrong
+	i =3D 0;
+	ret =3D EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
+	   ebt_check_entry, newinfo, repl->name, &i, repl->valid_hooks,
+	   cl_s, udc_cnt);
+	if (ret !=3D 0) {
+		EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
+		   ebt_cleanup_entry, &i);
+	}
+	if (cl_s)
+		vfree(cl_s);
+	return ret;
+}
+
+// called under write_lock
+static void get_counters(struct ebt_counter *oldcounters,
+   struct ebt_counter *counters, unsigned int nentries)
+{
+	int i, cpu;
+	struct ebt_counter *counter_base;
+
+	// counters of cpu 0
+	memcpy(counters, oldcounters,
+	   sizeof(struct ebt_counter) * nentries);
+	// add other counters to those of cpu 0
+	for (cpu =3D 1; cpu < NR_CPUS; cpu++) {
+		counter_base =3D COUNTER_BASE(oldcounters, nentries, cpu);
+		for (i =3D 0; i < nentries; i++)
+			counters[i].pcnt +=3D counter_base[i].pcnt;
+	}
+}
+
+// replace the table
+static int do_replace(void *user, unsigned int len)
+{
+	int ret, i, countersize;
+	struct ebt_table_info *newinfo;
+	struct ebt_replace tmp;
+	struct ebt_table *t;
+	struct ebt_counter *counterstmp =3D NULL;
+	// used to be able to unlock earlier
+	struct ebt_table_info *table;
+
+	if (copy_from_user(&tmp, user, sizeof(tmp)) !=3D 0)
+		return -EFAULT;
+
+	if (len !=3D sizeof(tmp) + tmp.entries_size) {
+		BUGPRINT("Wrong len argument\n");
+		return -EINVAL;
+	}
+
+	if (tmp.entries_size =3D=3D 0) {
+		BUGPRINT("Entries_size never zero\n");
+		return -EINVAL;
+	}
+	countersize =3D COUNTER_OFFSET(tmp.nentries) * NR_CPUS;
+	newinfo =3D (struct ebt_table_info *)
+	   vmalloc(sizeof(struct ebt_table_info) + countersize);
+	if (!newinfo)
+		return -ENOMEM;
+
+	if (countersize)
+		memset(newinfo->counters, 0, countersize);
+
+	newinfo->entries =3D (char *)vmalloc(tmp.entries_size);
+	if (!newinfo->entries) {
+		ret =3D -ENOMEM;
+		goto free_newinfo;
+	}
+	if (copy_from_user(
+	   newinfo->entries, tmp.entries, tmp.entries_size) !=3D 0) {
+		BUGPRINT("Couldn't copy entries from userspace\n");
+		ret =3D -EFAULT;
+		goto free_entries;
+	}
+
+	// the user wants counters back
+	// the check on the size is done later, when we have the lock
+	if (tmp.num_counters) {
+		counterstmp =3D (struct ebt_counter *)
+		   vmalloc(tmp.num_counters * sizeof(struct ebt_counter));
+		if (!counterstmp) {
+			ret =3D -ENOMEM;
+			goto free_entries;
+		}
+	}
+	else
+		counterstmp =3D NULL;
+
+	// this can get initialized by translate_table()
+	newinfo->chainstack =3D NULL;
+	ret =3D translate_table(&tmp, newinfo);
+
+	if (ret !=3D 0)
+		goto free_counterstmp;
+
+	t =3D find_table_lock(tmp.name, &ret, &ebt_mutex);
+	if (!t)
+		goto free_iterate;
+
+	// the table doesn't like it
+	if (t->check && (ret =3D t->check(newinfo, tmp.valid_hooks)))
+		goto free_unlock;
+
+	if (tmp.num_counters && tmp.num_counters !=3D t->private->nentries) {
+		BUGPRINT("Wrong nr. of counters requested\n");
+		ret =3D -EINVAL;
+		goto free_unlock;
+	}
+
+	// we have the mutex lock, so no danger in reading this pointer
+	table =3D t->private;
+	// we need an atomic snapshot of the counters
+	write_lock_bh(&t->lock);
+	if (tmp.num_counters)
+		get_counters(t->private->counters, counterstmp,
+		   t->private->nentries);
+
+	t->private =3D newinfo;
+	write_unlock_bh(&t->lock);
+	up(&ebt_mutex);
+	// So, a user can change the chains while having messed up her counter
+	// allocation. Only reason why this is done is because this way the loc=
k
+	// is held only once, while this doesn't bring the kernel into a
+	// dangerous state.
+	if (tmp.num_counters &&
+	   copy_to_user(tmp.counters, counterstmp,
+	   tmp.num_counters * sizeof(struct ebt_counter))) {
+		BUGPRINT("Couldn't copy counters to userspace\n");
+		ret =3D -EFAULT;
+	}
+	else
+		ret =3D 0;
+
+	// decrease module count and free resources
+	EBT_ENTRY_ITERATE(table->entries, table->entries_size,
+	   ebt_cleanup_entry, NULL);
+
+	vfree(table->entries);
+	if (table->chainstack) {
+		for (i =3D 0; i < NR_CPUS; i++)
+			vfree(table->chainstack[i]);
+		vfree(table->chainstack);
+	}
+	vfree(table);
+
+	if (counterstmp)
+		vfree(counterstmp);
+	return ret;
+
+free_unlock:
+	up(&ebt_mutex);
+free_iterate:
+	EBT_ENTRY_ITERATE(newinfo->entries, newinfo->entries_size,
+	   ebt_cleanup_entry, NULL);
+free_counterstmp:
+	if (counterstmp)
+		vfree(counterstmp);
+	// can be initialized in translate_table()
+	if (newinfo->chainstack) {
+		for (i =3D 0; i < NR_CPUS; i++)
+			vfree(newinfo->chainstack[i]);
+		vfree(newinfo->chainstack);
+	}
+free_entries:
+	if (newinfo->entries)
+		vfree(newinfo->entries);
+free_newinfo:
+	if (newinfo)
+		vfree(newinfo);
+	return ret;
+}
+
+int ebt_register_target(struct ebt_target *target)
+{
+	int ret;
+
+	ret =3D down_interruptible(&ebt_mutex);
+	if (ret !=3D 0)
+		return ret;
+	if (!list_named_insert(&ebt_targets, target)) {
+		up(&ebt_mutex);
+		return -EEXIST;
+	}
+	up(&ebt_mutex);
+	MOD_INC_USE_COUNT;
+
+	return 0;
+}
+
+void ebt_unregister_target(struct ebt_target *target)
+{
+	down(&ebt_mutex);
+	LIST_DELETE(&ebt_targets, target);
+	up(&ebt_mutex);
+	MOD_DEC_USE_COUNT;
+}
+
+int ebt_register_match(struct ebt_match *match)
+{
+	int ret;
+
+	ret =3D down_interruptible(&ebt_mutex);
+	if (ret !=3D 0)
+		return ret;
+	if (!list_named_insert(&ebt_matches, match)) {
+		up(&ebt_mutex);
+		return -EEXIST;
+	}
+	up(&ebt_mutex);
+	MOD_INC_USE_COUNT;
+
+	return 0;
+}
+
+void ebt_unregister_match(struct ebt_match *match)
+{
+	down(&ebt_mutex);
+	LIST_DELETE(&ebt_matches, match);
+	up(&ebt_mutex);
+	MOD_DEC_USE_COUNT;
+}
+
+int ebt_register_watcher(struct ebt_watcher *watcher)
+{
+	int ret;
+
+	ret =3D down_interruptible(&ebt_mutex);
+	if (ret !=3D 0)
+		return ret;
+	if (!list_named_insert(&ebt_watchers, watcher)) {
+		up(&ebt_mutex);
+		return -EEXIST;
+	}
+	up(&ebt_mutex);
+	MOD_INC_USE_COUNT;
+
+	return 0;
+}
+
+void ebt_unregister_watcher(struct ebt_watcher *watcher)
+{
+	down(&ebt_mutex);
+	LIST_DELETE(&ebt_watchers, watcher);
+	up(&ebt_mutex);
+	MOD_DEC_USE_COUNT;
+}
+
+int ebt_register_table(struct ebt_table *table)
+{
+	struct ebt_table_info *newinfo;
+	int ret, i, countersize;
+
+	if (!table || !table->table ||!table->table->entries ||
+	    table->table->entries_size =3D=3D 0 ||
+	    table->table->counters || table->private) {
+		BUGPRINT("Bad table data for ebt_register_table!!!\n");
+		return -EINVAL;
+	}
+
+	countersize =3D COUNTER_OFFSET(table->table->nentries) * NR_CPUS;
+	newinfo =3D (struct ebt_table_info *)
+	   vmalloc(sizeof(struct ebt_table_info) + countersize);
+	ret =3D -ENOMEM;
+	if (!newinfo)
+		return -ENOMEM;
+
+	newinfo->entries =3D (char *)vmalloc(table->table->entries_size);
+	if (!(newinfo->entries))
+		goto free_newinfo;
+
+	memcpy(newinfo->entries, table->table->entries,
+	   table->table->entries_size);
+
+	if (countersize)
+		memset(newinfo->counters, 0, countersize);
+
+	// fill in newinfo and parse the entries
+	newinfo->chainstack =3D NULL;
+	ret =3D translate_table(table->table, newinfo);
+	if (ret !=3D 0) {
+		BUGPRINT("Translate_table failed\n");
+		goto free_chainstack;
+	}
+
+	if (table->check && table->check(newinfo, table->valid_hooks)) {
+		BUGPRINT("The table doesn't like its own initial data, lol\n");
+		return -EINVAL;
+	}
+
+	table->private =3D newinfo;
+	table->lock =3D RW_LOCK_UNLOCKED;
+	ret =3D down_interruptible(&ebt_mutex);
+	if (ret !=3D 0)
+		goto free_chainstack;
+
+	if (list_named_find(&ebt_tables, table->name)) {
+		ret =3D -EEXIST;
+		BUGPRINT("Table name already exists\n");
+		goto free_unlock;
+	}
+
+	list_prepend(&ebt_tables, table);
+	up(&ebt_mutex);
+	MOD_INC_USE_COUNT;
+	return 0;
+free_unlock:
+	up(&ebt_mutex);
+free_chainstack:
+	if (newinfo->chainstack) {
+		for (i =3D 0; i < NR_CPUS; i++)
+			vfree(newinfo->chainstack[i]);
+		vfree(newinfo->chainstack);
+	}
+	vfree(newinfo->entries);
+free_newinfo:
+	vfree(newinfo);
+	return ret;
+}
+
+void ebt_unregister_table(struct ebt_table *table)
+{
+	int i;
+
+	if (!table) {
+		BUGPRINT("Request to unregister NULL table!!!\n");
+		return;
+	}
+	down(&ebt_mutex);
+	LIST_DELETE(&ebt_tables, table);
+	up(&ebt_mutex);
+	EBT_ENTRY_ITERATE(table->private->entries,
+	   table->private->entries_size, ebt_cleanup_entry, NULL);
+	if (table->private->entries)
+		vfree(table->private->entries);
+	if (table->private->chainstack) {
+		for (i =3D 0; i < NR_CPUS; i++)
+			vfree(table->private->chainstack[i]);
+		vfree(table->private->chainstack);
+	}
+	vfree(table->private);
+	MOD_DEC_USE_COUNT;
+}
+
+// userspace just supplied us with counters
+static int update_counters(void *user, unsigned int len)
+{
+	int i, ret;
+	struct ebt_counter *tmp;
+	struct ebt_replace hlp;
+	struct ebt_table *t;
+
+	if (copy_from_user(&hlp, user, sizeof(hlp)))
+		return -EFAULT;
+
+	if (len !=3D sizeof(hlp) + hlp.num_counters * sizeof(struct ebt_counter=
))
+		return -EINVAL;
+	if (hlp.num_counters =3D=3D 0)
+		return -EINVAL;
+
+	if ( !(tmp =3D (struct ebt_counter *)
+	   vmalloc(hlp.num_counters * sizeof(struct ebt_counter))) ){
+		MEMPRINT("Update_counters && nomemory\n");
+		return -ENOMEM;
+	}
+
+	t =3D find_table_lock(hlp.name, &ret, &ebt_mutex);
+	if (!t)
+		goto free_tmp;
+
+	if (hlp.num_counters !=3D t->private->nentries) {
+		BUGPRINT("Wrong nr of counters\n");
+		ret =3D -EINVAL;
+		goto unlock_mutex;
+	}
+
+	if ( copy_from_user(tmp, hlp.counters,
+	   hlp.num_counters * sizeof(struct ebt_counter)) ) {
+		BUGPRINT("Updata_counters && !cfu\n");
+		ret =3D -EFAULT;
+		goto unlock_mutex;
+	}
+
+	// we want an atomic add of the counters
+	write_lock_bh(&t->lock);
+
+	// we add to the counters of the first cpu
+	for (i =3D 0; i < hlp.num_counters; i++)
+		t->private->counters[i].pcnt +=3D tmp[i].pcnt;
+
+	write_unlock_bh(&t->lock);
+	ret =3D 0;
+unlock_mutex:
+	up(&ebt_mutex);
+free_tmp:
+	vfree(tmp);
+	return ret;
+}
+
+static inline int ebt_make_matchname(struct ebt_entry_match *m,
+   char *base, char *ubase)
+{
+	char *hlp =3D ubase - base + (char *)m;
+	if (copy_to_user(hlp, m->u.match->name, EBT_FUNCTION_MAXNAMELEN))
+		return -EFAULT;
+	return 0;
+}
+
+static inline int ebt_make_watchername(struct ebt_entry_watcher *w,
+   char *base, char *ubase)
+{
+	char *hlp =3D ubase - base + (char *)w;
+	if (copy_to_user(hlp , w->u.watcher->name, EBT_FUNCTION_MAXNAMELEN))
+		return -EFAULT;
+	return 0;
+}
+
+static inline int ebt_make_names(struct ebt_entry *e, char *base, char=20
*ubase)
+{
+	int ret;
+	char *hlp;
+	struct ebt_entry_target *t;
+
+	if ((e->bitmask & EBT_ENTRY_OR_ENTRIES) =3D=3D 0)
+		return 0;
+
+	hlp =3D ubase - base + (char *)e + e->target_offset;
+	t =3D (struct ebt_entry_target *)(((char *)e) + e->target_offset);
+=09
+	ret =3D EBT_MATCH_ITERATE(e, ebt_make_matchname, base, ubase);
+	if (ret !=3D 0)
+		return ret;
+	ret =3D EBT_WATCHER_ITERATE(e, ebt_make_watchername, base, ubase);
+	if (ret !=3D 0)
+		return ret;
+	if (copy_to_user(hlp, t->u.target->name, EBT_FUNCTION_MAXNAMELEN))
+		return -EFAULT;
+	return 0;
+}
+
+// called with ebt_mutex down
+static int copy_everything_to_user(struct ebt_table *t, void *user,
+   int *len, int cmd)
+{
+	struct ebt_replace tmp;
+	struct ebt_counter *counterstmp, *oldcounters;
+	unsigned int entries_size, nentries;
+	char *entries;
+
+	if (cmd =3D=3D EBT_SO_GET_ENTRIES) {
+		entries_size =3D t->private->entries_size;
+		nentries =3D t->private->nentries;
+		entries =3D t->private->entries;
+		oldcounters =3D t->private->counters;
+	} else {
+		entries_size =3D t->table->entries_size;
+		nentries =3D t->table->nentries;
+		entries =3D t->table->entries;
+		oldcounters =3D t->table->counters;
+	}
+
+	if (copy_from_user(&tmp, user, sizeof(tmp))) {
+		BUGPRINT("Cfu didn't work\n");
+		return -EFAULT;
+	}
+
+	if (*len !=3D sizeof(struct ebt_replace) + entries_size +
+	   (tmp.num_counters? nentries * sizeof(struct ebt_counter): 0)) {
+		BUGPRINT("Wrong size\n");
+		return -EINVAL;
+	}
+
+	if (tmp.nentries !=3D nentries) {
+		BUGPRINT("Nentries wrong\n");
+		return -EINVAL;
+	}
+
+	if (tmp.entries_size !=3D entries_size) {
+		BUGPRINT("Wrong size\n");
+		return -EINVAL;
+	}
+
+	// userspace might not need the counters
+	if (tmp.num_counters) {
+		if (tmp.num_counters !=3D nentries) {
+			BUGPRINT("Num_counters wrong\n");
+			return -EINVAL;
+		}
+		counterstmp =3D (struct ebt_counter *)
+		   vmalloc(nentries * sizeof(struct ebt_counter));
+		if (!counterstmp) {
+			MEMPRINT("Couldn't copy counters, out of memory\n");
+			return -ENOMEM;
+		}
+		write_lock_bh(&t->lock);
+		get_counters(oldcounters, counterstmp, nentries);
+		write_unlock_bh(&t->lock);
+
+		if (copy_to_user(tmp.counters, counterstmp,
+		   nentries * sizeof(struct ebt_counter))) {
+			BUGPRINT("Couldn't copy counters to userspace\n");
+			vfree(counterstmp);
+			return -EFAULT;
+		}
+		vfree(counterstmp);
+	}
+
+	if (copy_to_user(tmp.entries, entries, entries_size)) {
+		BUGPRINT("Couldn't copy entries to userspace\n");
+		return -EFAULT;
+	}
+	// set the match/watcher/target names right
+	return EBT_ENTRY_ITERATE(entries, entries_size,
+	   ebt_make_names, entries, tmp.entries);
+}
+
+static int do_ebt_set_ctl(struct sock *sk,
+	int cmd, void *user, unsigned int len)
+{
+	int ret;
+
+	switch(cmd) {
+	case EBT_SO_SET_ENTRIES:
+		ret =3D do_replace(user, len);
+		break;
+	case EBT_SO_SET_COUNTERS:
+		ret =3D update_counters(user, len);
+		break;
+	default:
+		ret =3D -EINVAL;
+  }
+	return ret;
+}
+
+static int do_ebt_get_ctl(struct sock *sk, int cmd, void *user, int *len=
)
+{
+	int ret;
+	struct ebt_replace tmp;
+	struct ebt_table *t;
+
+	if (copy_from_user(&tmp, user, sizeof(tmp)))
+		return -EFAULT;
+
+	t =3D find_table_lock(tmp.name, &ret, &ebt_mutex);
+	if (!t)
+		return ret;
+
+	switch(cmd) {
+	case EBT_SO_GET_INFO:
+	case EBT_SO_GET_INIT_INFO:
+		if (*len !=3D sizeof(struct ebt_replace)){
+			ret =3D -EINVAL;
+			up(&ebt_mutex);
+			break;
+		}
+		if (cmd =3D=3D EBT_SO_GET_INFO) {
+			tmp.nentries =3D t->private->nentries;
+			tmp.entries_size =3D t->private->entries_size;
+			tmp.valid_hooks =3D t->valid_hooks;
+		} else {
+			tmp.nentries =3D t->table->nentries;
+			tmp.entries_size =3D t->table->entries_size;
+			tmp.valid_hooks =3D t->table->valid_hooks;
+		}
+		up(&ebt_mutex);
+		if (copy_to_user(user, &tmp, *len) !=3D 0){
+			BUGPRINT("c2u Didn't work\n");
+			ret =3D -EFAULT;
+			break;
+		}
+		ret =3D 0;
+		break;
+
+	case EBT_SO_GET_ENTRIES:
+	case EBT_SO_GET_INIT_ENTRIES:
+		ret =3D copy_everything_to_user(t, user, len, cmd);
+		up(&ebt_mutex);
+		break;
+
+	default:
+		up(&ebt_mutex);
+		ret =3D -EINVAL;
+	}
+
+	return ret;
+}
+
+static struct nf_sockopt_ops ebt_sockopts =3D
+{ { NULL, NULL }, PF_INET, EBT_BASE_CTL, EBT_SO_SET_MAX + 1, do_ebt_set_=
ctl,
+    EBT_BASE_CTL, EBT_SO_GET_MAX + 1, do_ebt_get_ctl, 0, NULL
+};
+
+static int __init init(void)
+{
+	int ret;
+
+	down(&ebt_mutex);
+	list_named_insert(&ebt_targets, &ebt_standard_target);
+	up(&ebt_mutex);
+	if ((ret =3D nf_register_sockopt(&ebt_sockopts)) < 0)
+		return ret;
+
+	printk("Ebtables v2.0 registered");
+	return 0;
+}
+
+static void __exit fini(void)
+{
+	nf_unregister_sockopt(&ebt_sockopts);
+	printk("Ebtables v2.0 unregistered");
+}
+
+EXPORT_SYMBOL(ebt_register_table);
+EXPORT_SYMBOL(ebt_unregister_table);
+EXPORT_SYMBOL(ebt_register_match);
+EXPORT_SYMBOL(ebt_unregister_match);
+EXPORT_SYMBOL(ebt_register_watcher);
+EXPORT_SYMBOL(ebt_unregister_watcher);
+EXPORT_SYMBOL(ebt_register_target);
+EXPORT_SYMBOL(ebt_unregister_target);
+EXPORT_SYMBOL(ebt_do_table);
+module_init(init);
+module_exit(fini);
+MODULE_LICENSE("GPL");
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebtables.h	Wed S=
ep 11=20
23:06:55 2002
@@ -0,0 +1,358 @@
+/*
+ *  ebtables
+ *
+ *	Authors:
+ *	Bart De Schuymer		<bart.de.schuymer@pandora.be>
+ *
+ *  ebtables.c,v 2.0, April, 2002
+ *
+ *  This code is stongly inspired on the iptables code which is
+ *  Copyright (C) 1999 Paul `Rusty' Russell & Michael J. Neuling
+ */
+
+#ifndef __LINUX_BRIDGE_EFF_H
+#define __LINUX_BRIDGE_EFF_H
+#include <linux/if.h>
+#include <linux/netfilter_bridge.h>
+#include <linux/if_ether.h>
+
+#define EBT_TABLE_MAXNAMELEN 32
+#define EBT_CHAIN_MAXNAMELEN EBT_TABLE_MAXNAMELEN
+#define EBT_FUNCTION_MAXNAMELEN EBT_TABLE_MAXNAMELEN
+
+// [gs]etsockopt numbers
+#define EBT_BASE_CTL            128
+
+#define EBT_SO_SET_ENTRIES      (EBT_BASE_CTL)
+#define EBT_SO_SET_COUNTERS     (EBT_SO_SET_ENTRIES+1)
+#define EBT_SO_SET_MAX          (EBT_SO_SET_COUNTERS+1)
+
+#define EBT_SO_GET_INFO         (EBT_BASE_CTL)
+#define EBT_SO_GET_ENTRIES      (EBT_SO_GET_INFO+1)
+#define EBT_SO_GET_INIT_INFO    (EBT_SO_GET_ENTRIES+1)
+#define EBT_SO_GET_INIT_ENTRIES (EBT_SO_GET_INIT_INFO+1)
+#define EBT_SO_GET_MAX          (EBT_SO_GET_INIT_ENTRIES+1)
+
+// verdicts >0 are "branches"
+#define EBT_ACCEPT   -1
+#define EBT_DROP     -2
+#define EBT_CONTINUE -3
+#define EBT_RETURN   -4
+#define NUM_STANDARD_TARGETS   4
+
+// return values for match() functions
+#define EBT_MATCH 0
+#define EBT_NOMATCH 1
+
+struct ebt_counter
+{
+	uint64_t pcnt;
+};
+
+struct ebt_entries {
+	// this field is always set to zero
+	// See EBT_ENTRY_OR_ENTRIES.
+	// Must be same size as ebt_entry.bitmask
+	unsigned int distinguisher;
+	// the chain name
+	char name[EBT_CHAIN_MAXNAMELEN];
+	// counter offset for this chain
+	unsigned int counter_offset;
+	// one standard (accept, drop, return) per hook
+	int policy;
+	// nr. of entries
+	unsigned int nentries;
+	// entry list
+	char data[0];
+};
+
+// used for the bitmask of struct ebt_entry
+
+// This is a hack to make a difference between an ebt_entry struct and a=
n
+// ebt_entries struct when traversing the entries from start to end.
+// Using this simplifies the code alot, while still being able to use
+// ebt_entries.
+// Contrary, iptables doesn't use something like ebt_entries and therefo=
re=20
uses
+// different techniques for naming the policy and such. So, iptables doe=
sn't
+// need a hack like this.
+#define EBT_ENTRY_OR_ENTRIES 0x01
+// these are the normal masks
+#define EBT_NOPROTO 0x02
+#define EBT_802_3 0x04
+#define EBT_SOURCEMAC 0x08
+#define EBT_DESTMAC 0x10
+#define EBT_F_MASK (EBT_NOPROTO | EBT_802_3 | EBT_SOURCEMAC | EBT_DESTMA=
C \
+   | EBT_ENTRY_OR_ENTRIES)
+
+#define EBT_IPROTO 0x01
+#define EBT_IIN 0x02
+#define EBT_IOUT 0x04
+#define EBT_ISOURCE 0x8
+#define EBT_IDEST 0x10
+#define EBT_ILOGICALIN 0x20
+#define EBT_ILOGICALOUT 0x40
+#define EBT_INV_MASK (EBT_IPROTO | EBT_IIN | EBT_IOUT | EBT_ILOGICALIN \
+   | EBT_ILOGICALOUT | EBT_ISOURCE | EBT_IDEST)
+
+struct ebt_entry_match
+{
+	union {
+		char name[EBT_FUNCTION_MAXNAMELEN];
+		struct ebt_match *match;
+	} u;
+	// size of data
+	unsigned int match_size;
+	unsigned char data[0];
+};
+
+struct ebt_entry_watcher
+{
+	union {
+		char name[EBT_FUNCTION_MAXNAMELEN];
+		struct ebt_watcher *watcher;
+	} u;
+	// size of data
+	unsigned int watcher_size;
+	unsigned char data[0];
+};
+
+struct ebt_entry_target
+{
+	union {
+		char name[EBT_FUNCTION_MAXNAMELEN];
+		struct ebt_target *target;
+	} u;
+	// size of data
+	unsigned int target_size;
+	unsigned char data[0];
+};
+
+#define EBT_STANDARD_TARGET "standard"
+struct ebt_standard_target
+{
+	struct ebt_entry_target target;
+	int verdict;
+};
+
+// one entry
+struct ebt_entry {
+	// this needs to be the first field
+	unsigned int bitmask;
+	unsigned int invflags;
+	uint16_t ethproto;
+	// the physical in-dev
+	char in[IFNAMSIZ];
+	// the logical in-dev
+	char logical_in[IFNAMSIZ];
+	// the physical out-dev
+	char out[IFNAMSIZ];
+	// the logical out-dev
+	char logical_out[IFNAMSIZ];
+	unsigned char sourcemac[ETH_ALEN];
+	unsigned char sourcemsk[ETH_ALEN];
+	unsigned char destmac[ETH_ALEN];
+	unsigned char destmsk[ETH_ALEN];
+	// sizeof ebt_entry + matches
+	unsigned int watchers_offset;
+	// sizeof ebt_entry + matches + watchers
+	unsigned int target_offset;
+	// sizeof ebt_entry + matches + watchers + target
+	unsigned int next_offset;
+	unsigned char elems[0];
+};
+
+struct ebt_replace
+{
+	char name[EBT_TABLE_MAXNAMELEN];
+	unsigned int valid_hooks;
+	// nr of rules in the table
+	unsigned int nentries;
+	// total size of the entries
+	unsigned int entries_size;
+	// start of the chains
+	struct ebt_entries *hook_entry[NF_BR_NUMHOOKS];
+	// nr of counters userspace expects back
+	unsigned int num_counters;
+	// where the kernel will put the old counters
+	struct ebt_counter *counters;
+	char *entries;
+};
+
+#ifdef __KERNEL__
+
+struct ebt_match
+{
+	struct list_head list;
+	const char name[EBT_FUNCTION_MAXNAMELEN];
+	// 0 =3D=3D it matches
+	int (*match)(const struct sk_buff *skb, const struct net_device *in,
+	   const struct net_device *out, const void *matchdata,
+	   unsigned int datalen);
+	// 0 =3D=3D let it in
+	int (*check)(const char *tablename, unsigned int hookmask,
+	   const struct ebt_entry *e, void *matchdata, unsigned int datalen);
+	void (*destroy)(void *matchdata, unsigned int datalen);
+	struct module *me;
+};
+
+struct ebt_watcher
+{
+	struct list_head list;
+	const char name[EBT_FUNCTION_MAXNAMELEN];
+	void (*watcher)(const struct sk_buff *skb, const struct net_device *in,
+	   const struct net_device *out, const void *watcherdata,
+	   unsigned int datalen);
+	// 0 =3D=3D let it in
+	int (*check)(const char *tablename, unsigned int hookmask,
+	   const struct ebt_entry *e, void *watcherdata, unsigned int datalen);
+	void (*destroy)(void *watcherdata, unsigned int datalen);
+	struct module *me;
+};
+
+struct ebt_target
+{
+	struct list_head list;
+	const char name[EBT_FUNCTION_MAXNAMELEN];
+	// returns one of the standard verdicts
+	int (*target)(struct sk_buff **pskb, unsigned int hooknr,
+	   const struct net_device *in, const struct net_device *out,
+	   const void *targetdata, unsigned int datalen);
+	// 0 =3D=3D let it in
+	int (*check)(const char *tablename, unsigned int hookmask,
+	   const struct ebt_entry *e, void *targetdata, unsigned int datalen);
+	void (*destroy)(void *targetdata, unsigned int datalen);
+	struct module *me;
+};
+
+// used for jumping from and into user defined chains (udc)
+struct ebt_chainstack
+{
+	struct ebt_entries *chaininfo; // pointer to chain data
+	struct ebt_entry *e; // pointer to entry data
+	unsigned int n; // n'th entry
+};
+
+struct ebt_table_info
+{
+	// total size of the entries
+	unsigned int entries_size;
+	unsigned int nentries;
+	// pointers to the start of the chains
+	struct ebt_entries *hook_entry[NF_BR_NUMHOOKS];
+	// room to maintain the stack used for jumping from and into udc
+	struct ebt_chainstack **chainstack;
+	char *entries;
+	struct ebt_counter counters[0] ____cacheline_aligned;
+};
+
+struct ebt_table
+{
+	struct list_head list;
+	char name[EBT_TABLE_MAXNAMELEN];
+	struct ebt_replace *table;
+	unsigned int valid_hooks;
+	rwlock_t lock;
+	// e.g. could be the table explicitly only allows certain
+	// matches, targets, ... 0 =3D=3D let it in
+	int (*check)(const struct ebt_table_info *info,
+	   unsigned int valid_hooks);
+	// the data used by the kernel
+	struct ebt_table_info *private;
+};
+
+extern int ebt_register_table(struct ebt_table *table);
+extern void ebt_unregister_table(struct ebt_table *table);
+extern int ebt_register_match(struct ebt_match *match);
+extern void ebt_unregister_match(struct ebt_match *match);
+extern int ebt_register_watcher(struct ebt_watcher *watcher);
+extern void ebt_unregister_watcher(struct ebt_watcher *watcher);
+extern int ebt_register_target(struct ebt_target *target);
+extern void ebt_unregister_target(struct ebt_target *target);
+extern unsigned int ebt_do_table(unsigned int hook, struct sk_buff **psk=
b,
+   const struct net_device *in, const struct net_device *out,
+   struct ebt_table *table);
+
+   // Used in the kernel match() functions
+#define FWINV(bool,invflg) ((bool) ^ !!(info->invflags & invflg))
+// True if the hook mask denotes that the rule is in a base chain,
+// used in the check() functions
+#define BASE_CHAIN (hookmask & (1 << NF_BR_NUMHOOKS))
+// Clear the bit in the hook mask that tells if the rule is on a base ch=
ain
+#define CLEAR_BASE_CHAIN_BIT (hookmask &=3D ~(1 << NF_BR_NUMHOOKS))
+// True if the target is not a standard target
+#define INVALID_TARGET (info->target < -NUM_STANDARD_TARGETS || info->ta=
rget=20
>=3D 0)
+
+#endif /* __KERNEL__ */
+
+// blatently stolen from ip_tables.h
+// fn returns 0 to continue iteration
+#define EBT_MATCH_ITERATE(e, fn, args...)                   \
+({                                                          \
+	unsigned int __i;                                   \
+	int __ret =3D 0;                                      \
+	struct ebt_entry_match *__match;                    \
+	                                                    \
+	for (__i =3D sizeof(struct ebt_entry);                \
+	     __i < (e)->watchers_offset;                    \
+	     __i +=3D __match->match_size +                   \
+	     sizeof(struct ebt_entry_match)) {              \
+		__match =3D (void *)(e) + __i;                \
+		                                            \
+		__ret =3D fn(__match , ## args);              \
+		if (__ret !=3D 0)                             \
+			break;                              \
+	}                                                   \
+	if (__ret =3D=3D 0) {                                   \
+		if (__i !=3D (e)->watchers_offset)            \
+			__ret =3D -EINVAL;                    \
+	}                                                   \
+	__ret;                                              \
+})
+
+#define EBT_WATCHER_ITERATE(e, fn, args...)                 \
+({                                                          \
+	unsigned int __i;                                   \
+	int __ret =3D 0;                                      \
+	struct ebt_entry_watcher *__watcher;                \
+	                                                    \
+	for (__i =3D e->watchers_offset;                      \
+	     __i < (e)->target_offset;                      \
+	     __i +=3D __watcher->watcher_size +               \
+	     sizeof(struct ebt_entry_watcher)) {            \
+		__watcher =3D (void *)(e) + __i;              \
+		                                            \
+		__ret =3D fn(__watcher , ## args);            \
+		if (__ret !=3D 0)                             \
+			break;                              \
+	}                                                   \
+	if (__ret =3D=3D 0) {                                   \
+		if (__i !=3D (e)->target_offset)              \
+			__ret =3D -EINVAL;                    \
+	}                                                   \
+	__ret;                                              \
+})
+
+#define EBT_ENTRY_ITERATE(entries, size, fn, args...)       \
+({                                                          \
+	unsigned int __i;                                   \
+	int __ret =3D 0;                                      \
+	struct ebt_entry *__entry;                          \
+	                                                    \
+	for (__i =3D 0; __i < (size);) {                      \
+		__entry =3D (void *)(entries) + __i;          \
+		__ret =3D fn(__entry , ## args);              \
+		if (__ret !=3D 0)                             \
+			break;                              \
+		if (__entry->bitmask !=3D 0)                  \
+			__i +=3D __entry->next_offset;        \
+		else                                        \
+			__i +=3D sizeof(struct ebt_entries);  \
+	}                                                   \
+	if (__ret =3D=3D 0) {                                   \
+		if (__i !=3D (size))                          \
+			__ret =3D -EINVAL;                    \
+	}                                                   \
+	__ret;                                              \
+})
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_arp.h	Wed Se=
p 11=20
23:06:55 2002
@@ -0,0 +1,26 @@
+#ifndef __LINUX_BRIDGE_EBT_ARP_H
+#define __LINUX_BRIDGE_EBT_ARP_H
+
+#define EBT_ARP_OPCODE 0x01
+#define EBT_ARP_HTYPE 0x02
+#define EBT_ARP_PTYPE 0x04
+#define EBT_ARP_SRC_IP 0x08
+#define EBT_ARP_DST_IP 0x10
+#define EBT_ARP_MASK (EBT_ARP_OPCODE | EBT_ARP_HTYPE | EBT_ARP_PTYPE | \
+   EBT_ARP_SRC_IP | EBT_ARP_DST_IP)
+#define EBT_ARP_MATCH "arp"
+
+struct ebt_arp_info
+{
+	uint16_t htype;
+	uint16_t ptype;
+	uint16_t opcode;
+	uint32_t saddr;
+	uint32_t smsk;
+	uint32_t daddr;
+	uint32_t dmsk;
+	uint8_t  bitmask;
+	uint8_t  invflags;
+};
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_ip.h	Wed Sep=
 11=20
23:06:55 2002
@@ -0,0 +1,24 @@
+#ifndef __LINUX_BRIDGE_EBT_IP_H
+#define __LINUX_BRIDGE_EBT_IP_H
+
+#define EBT_IP_SOURCE 0x01
+#define EBT_IP_DEST 0x02
+#define EBT_IP_TOS 0x04
+#define EBT_IP_PROTO 0x08
+#define EBT_IP_MASK (EBT_IP_SOURCE | EBT_IP_DEST | EBT_IP_TOS | EBT_IP_P=
ROTO)
+#define EBT_IP_MATCH "ip"
+
+// the same values are used for the invflags
+struct ebt_ip_info
+{
+	uint32_t saddr;
+	uint32_t daddr;
+	uint32_t smsk;
+	uint32_t dmsk;
+	uint8_t  tos;
+	uint8_t  protocol;
+	uint8_t  bitmask;
+	uint8_t  invflags;
+};
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_vlan.h	Wed S=
ep 11=20
23:06:55 2002
@@ -0,0 +1,20 @@
+#ifndef __LINUX_BRIDGE_EBT_VLAN_H
+#define __LINUX_BRIDGE_EBT_VLAN_H
+
+#define EBT_VLAN_ID	0x01
+#define EBT_VLAN_PRIO	0x02
+#define EBT_VLAN_ENCAP	0x04
+#define EBT_VLAN_MASK (EBT_VLAN_ID | EBT_VLAN_PRIO | EBT_VLAN_ENCAP)
+#define EBT_VLAN_MATCH "vlan"
+
+struct ebt_vlan_info {
+	uint16_t id;		/* VLAN ID {1-4095} */
+	uint8_t prio;		/* VLAN User Priority {0-7} */
+	uint16_t encap;		/* VLAN Encapsulated frame code {0-65535} */
+	uint8_t bitmask;		/* Args bitmask bit 1=3D1 - ID arg,
+				   bit 2=3D1 User-Priority arg, bit 3=3D1 encap*/
+	uint8_t invflags;		/* Inverse bitmask  bit 1=3D1 - inversed ID arg,=20
+				   bit 2=3D1 - inversed Pirority arg */
+};
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_log.h	Wed Se=
p 11=20
23:06:55 2002
@@ -0,0 +1,17 @@
+#ifndef __LINUX_BRIDGE_EBT_LOG_H
+#define __LINUX_BRIDGE_EBT_LOG_H
+
+#define EBT_LOG_IP 0x01 // if the frame is made by ip, log the ip inform=
ation
+#define EBT_LOG_ARP 0x02
+#define EBT_LOG_MASK (EBT_LOG_IP | EBT_LOG_ARP)
+#define EBT_LOG_PREFIX_SIZE 30
+#define EBT_LOG_WATCHER "log"
+
+struct ebt_log_info
+{
+	uint8_t loglevel;
+	uint8_t prefix[EBT_LOG_PREFIX_SIZE];
+	uint32_t bitmask;
+};
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_nat.h	Wed Se=
p 11=20
23:06:55 2002
@@ -0,0 +1,13 @@
+#ifndef __LINUX_BRIDGE_EBT_NAT_H
+#define __LINUX_BRIDGE_EBT_NAT_H
+
+struct ebt_nat_info
+{
+	unsigned char mac[ETH_ALEN];
+	// EBT_ACCEPT, EBT_DROP, EBT_CONTINUE or EBT_RETURN
+	int target;
+};
+#define EBT_SNAT_TARGET "snat"
+#define EBT_DNAT_TARGET "dnat"
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_redirect.h	W=
ed=20
Sep 11 23:06:55 2002
@@ -0,0 +1,11 @@
+#ifndef __LINUX_BRIDGE_EBT_REDIRECT_H
+#define __LINUX_BRIDGE_EBT_REDIRECT_H
+
+struct ebt_redirect_info
+{
+	// EBT_ACCEPT, EBT_DROP or EBT_CONTINUE or EBT_RETURN
+	int target;
+};
+#define EBT_REDIRECT_TARGET "redirect"
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_mark_m.h	Wed=
 Sep=20
11 23:06:55 2002
@@ -0,0 +1,15 @@
+#ifndef __LINUX_BRIDGE_EBT_MARK_M_H
+#define __LINUX_BRIDGE_EBT_MARK_M_H
+
+#define EBT_MARK_AND 0x01
+#define EBT_MARK_OR 0x02
+#define EBT_MARK_MASK (EBT_MARK_AND | EBT_MARK_OR)
+struct ebt_mark_m_info
+{
+	unsigned long mark, mask;
+	uint8_t invert;
+	uint8_t bitmask;
+};
+#define EBT_MARK_MATCH "mark_m"
+
+#endif
--- /dev/null	Thu Aug 24 11:00:32 2000
+++ linux-2.5.34-ebtables/include/linux/netfilter_bridge/ebt_mark_t.h	Wed=
 Sep=20
11 23:06:55 2002
@@ -0,0 +1,12 @@
+#ifndef __LINUX_BRIDGE_EBT_MARK_T_H
+#define __LINUX_BRIDGE_EBT_MARK_T_H
+
+struct ebt_mark_t_info
+{
+	unsigned long mark;
+	// EBT_ACCEPT, EBT_DROP or EBT_CONTINUE or EBT_RETURN
+	int target;
+};
+#define EBT_MARK_TARGET "mark"
+
+#endif
