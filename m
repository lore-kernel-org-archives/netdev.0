From: Nuno Martins <nuno.martins@caixamagica.pt>
Subject: [RFC PATCH 2/2] PID-based packet filtering support
Date: Wed,  4 Apr 2012 10:16:17 +0100
Message-ID: <19b9f7a0f38c1bab367da6f6cf622c8c2b3a4920.1333466900.git.nuno.martins@caixamagica.pt>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
Cc: Alfredo Matos <alfredo.matos@caixamagica.pt>,
	Paulo Trezentos <paulo.trezentos@caixamagica.pt>
To: netdev <netdev@vger.kernel.org>, nuno.martins@caixamagica.pt
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f46.google.com ([209.85.214.46]:35689 "EHLO
	mail-bk0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755176Ab2DDJQh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Apr 2012 05:16:37 -0400
Received: by mail-bk0-f46.google.com with SMTP id ik5so59839bkc.19
        for <netdev@vger.kernel.org>; Wed, 04 Apr 2012 02:16:36 -0700 (PDT)
In-Reply-To: <cover.1333466900.git.nuno.martins@caixamagica.pt>
In-Reply-To: <cover.1333466900.git.nuno.martins@caixamagica.pt>
References: <cover.1333466900.git.nuno.martins@caixamagica.pt>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch introduces the pidmonitor module through three main components:

* a custom BFP filter function that acts on PID information

* dynamic KProbes handlers (kretprobe handlers) that intercept system calls (connect, bind, etc.) to determine the connections established by a specific process (pid).

* a repository (RB Tree) for maintaining the packet information to PID
mapping, to allow runtime use of the BPF filter.

Currently, the PID monitor is only available for TCP and UDP on IPv4. IPv6 support is under development.

Signed-off-by: Nuno Martins <nuno.martins@caixamagica.pt>
---
 include/linux/filter.h            |    1 +
 net/Kconfig                       |    7 +
 net/Makefile                      |    1 +
 net/core/filter.c                 |    5 +
 net/core/filter_function.c        |    9 +-
 net/pidmonitor/Makefile           |    3 +
 net/pidmonitor/db_monitor.c       |  389 ++++++++++++++++++++++++++++++
 net/pidmonitor/db_monitor.h       |   51 ++++
 net/pidmonitor/filter.c           |  476 +++++++++++++++++++++++++++++++++++++
 net/pidmonitor/filter.h           |   31 +++
 net/pidmonitor/pidmonitor.c       |  102 ++++++++
 net/pidmonitor/pidmonitor.h       |   63 +++++
 net/pidmonitor/proc_monitor.c     |  116 +++++++++
 net/pidmonitor/proc_monitor.h     |   23 ++
 net/pidmonitor/syscalls_monitor.c |  423 ++++++++++++++++++++++++++++++++
 net/pidmonitor/syscalls_monitor.h |   31 +++
 net/pidmonitor/task_monitor.c     |   77 ++++++
 net/pidmonitor/task_monitor.h     |   23 ++
 18 files changed, 1824 insertions(+), 7 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index 8d2d9c2..f50dc35 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -204,6 +204,7 @@ enum {
 	BPF_S_LDX_IMM,
 	BPF_S_MISC_TAX,
 	BPF_S_MISC_TXA,
+	BPF_S_MISC_PROC,
 	BPF_S_ALU_DIV_K,
 	BPF_S_LD_MEM,
 	BPF_S_LDX_MEM,
diff --git a/net/Kconfig b/net/Kconfig
index 6bbce29..9c74a0f 100644
--- a/net/Kconfig
+++ b/net/Kconfig
@@ -268,6 +268,13 @@ config FILTER_FUNCTION
 	  Dynamicaly define what sniffer function would be used to filter
 	  packets
 
+config MONITOR_PID
+	tristate "network monitoring by process id"
+	depends on MODULES && KPROBES && FILTER_FUNCTION
+	default m
+	---help---
+	  Monitor network defining a pid to sniff the packets
+
 menu "Network testing"
 
 config NET_PKTGEN
diff --git a/net/Makefile b/net/Makefile
index ad432fa..b5e35ab 100644
--- a/net/Makefile
+++ b/net/Makefile
@@ -70,3 +70,4 @@ obj-$(CONFIG_CEPH_LIB)		+= ceph/
 obj-$(CONFIG_BATMAN_ADV)	+= batman-adv/
 obj-$(CONFIG_NFC)		+= nfc/
 obj-$(CONFIG_OPENVSWITCH)	+= openvswitch/
+obj-$(CONFIG_MONITOR_PID)	+= pidmonitor/
diff --git a/net/core/filter.c b/net/core/filter.c
index 0aa1ac6..51b41a0 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -277,6 +277,10 @@ load_b:
 		case BPF_S_MISC_TXA:
 			A = X;
 			continue;
+		case BPF_S_MISC_PROC:
+			if ((fentry+1)->code == BPF_S_JMP_JEQ_K)
+				fentry += 1;
+			continue;
 		case BPF_S_RET_K:
 			return K;
 		case BPF_S_RET_A:
@@ -472,6 +476,7 @@ int sk_chk_filter(struct sock_filter *filter, unsigned int flen)
 		[BPF_LDX|BPF_IMM]        = BPF_S_LDX_IMM,
 		[BPF_MISC|BPF_TAX]       = BPF_S_MISC_TAX,
 		[BPF_MISC|BPF_TXA]       = BPF_S_MISC_TXA,
+		[BPF_MISC|BPF_PROC]	 = BPF_S_MISC_PROC,
 		[BPF_RET|BPF_K]          = BPF_S_RET_K,
 		[BPF_RET|BPF_A]          = BPF_S_RET_A,
 		[BPF_ALU|BPF_DIV|BPF_K]  = BPF_S_ALU_DIV_K,
diff --git a/net/core/filter_function.c b/net/core/filter_function.c
index c9b62e3..ee5f5be 100644
--- a/net/core/filter_function.c
+++ b/net/core/filter_function.c
@@ -32,9 +32,7 @@
 #include <linux/filter.h>
 #include <net/sock.h>
 
-LIST_HEAD(filter_list);
-/*EXPORT_SYMBOL(sniff_list);*/
-
+static LIST_HEAD(filter_list);
 static DEFINE_MUTEX(filter_list_mutex);
 
 int register_filter_function(struct filter_function *ff)
@@ -84,10 +82,7 @@ int attach_filter_function(struct filter_function_struct *ffs, struct sock *sk)
 	struct filter_function *ff = NULL;
 	struct sk_filter *old_fp;
 
-	if (strcmp(ffs->name, "sk_run_filter") == 0) {
-		/*if (init_process_filter_function != NULL)
-			init_process_filter_function(ffs);*/
-	} else
+	if (strcmp(ffs->name, "sk_run_filter") != 0)
 		ff = find_filter_function_by_name(ffs->name);
 
 	if (ff != NULL) {
diff --git a/net/pidmonitor/Makefile b/net/pidmonitor/Makefile
new file mode 100644
index 0000000..3fa01dd
--- /dev/null
+++ b/net/pidmonitor/Makefile
@@ -0,0 +1,3 @@
+obj-$(CONFIG_MONITOR_PID) += pidnetmonitor.o
+
+pidnetmonitor-objs := syscalls_monitor.o task_monitor.o filter.o proc_monitor.o db_monitor.o pidmonitor.o
diff --git a/net/pidmonitor/db_monitor.c b/net/pidmonitor/db_monitor.c
new file mode 100644
index 0000000..45dfb6d
--- /dev/null
+++ b/net/pidmonitor/db_monitor.c
@@ -0,0 +1,389 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/rbtree.h>
+#include <linux/types.h>
+
+#include <linux/in.h>
+
+#include "pidmonitor.h"
+#include "db_monitor.h"
+
+static struct rb_root db;
+
+/*
+ * returns NULL if there isn't that port int the tree
+ */
+static int is_equal_packet_info(struct packetInfo *pi,
+		struct portInfo *info)
+{
+
+	struct local_addresses_list *tmp = NULL;
+	struct local_addresses_list *address = NULL;
+	struct list_head *pos = NULL;
+
+	switch (pi->protocol) {
+	case IPPROTO_TCP:
+		if (info->tcp)
+			tmp = info->tcp;
+		break;
+	case IPPROTO_UDP:
+		if (info->udp)
+			tmp = info->udp;
+		break;
+	default:
+		return 0;
+	}
+
+	if (!tmp)
+		return 0;
+
+	list_for_each(pos, &(tmp->list)) {
+		address = list_entry(pos, struct local_addresses_list, list);
+		if (pi->address == address->address && pi->pid == address->pid)
+			return 1;
+	}
+
+	return 0;
+}
+
+static struct portInfo *__monitor_search(struct rb_root *root, struct packetInfo *pi)
+{
+	struct rb_node *node = root->rb_node;
+	struct portInfo *data = NULL;
+
+	while (node) {
+		data = container_of(node, struct portInfo, node);
+
+		if (pi->port < data->port)
+			node = node->rb_left;
+		else
+			if (pi->port > data->port)
+				node = node->rb_right;
+			else
+				if (pi->port == data->port) {
+					if (is_equal_packet_info(pi, data) != 0)
+						return data;
+					else
+						return NULL;
+				} else
+					return NULL;
+	}
+	return NULL;
+}
+
+struct portInfo *monitor_search(struct packetInfo *pi)
+{
+	return __monitor_search(&db, pi);
+}
+
+static int add_address(struct packetInfo *lpi, struct local_addresses_list *tmp,
+		int *list_counter, int pid)
+{
+	struct local_addresses_list *address = NULL;
+	struct list_head *pos = NULL;
+	struct local_addresses_list *node = NULL;
+
+	list_for_each(pos, &(tmp->list)) {
+		address = list_entry(pos, struct local_addresses_list, list);
+		if (lpi->address == address->address) {
+			address->counter++;
+			address->pid = pid;
+			return 1;
+		}
+	}
+
+	node = kmalloc(sizeof(*node), GFP_KERNEL);
+
+	if (!node)
+		return -1;
+
+	node->address = lpi->address;
+	node->counter = 1;
+
+	list_add(&(node->list), &(tmp->list));
+	(*list_counter)++;
+	node->pid = pid;
+
+	return 1;
+}
+
+static int insert_address(struct packetInfo *lpi, struct portInfo *port_info)
+{
+
+	switch (lpi->protocol) {
+	case IPPROTO_TCP:
+		if (!(port_info->tcp)) {
+			port_info->tcp = kmalloc(sizeof(struct local_addresses_list), GFP_KERNEL);
+
+			if (!port_info->tcp)
+				return -1;
+
+			INIT_LIST_HEAD(&((port_info->tcp)->list));
+			port_info->tcp->counter = 0;
+		}
+
+		if (lpi->address == 0) {
+			struct local_addresses_list *address = NULL;
+			struct list_head *pos = NULL;
+
+			list_for_each(pos, &(local_list->list)) {
+				struct packetInfo pi;
+				address = list_entry(pos, struct local_addresses_list, list);
+				pi.address = address->address;
+				add_address(&pi, port_info->tcp, &(port_info->tcp_list_counter), lpi->pid);
+			}
+		} else {
+			add_address(lpi, port_info->tcp, &(port_info->tcp_list_counter),lpi->pid);
+		}
+
+		break;
+	case IPPROTO_UDP:
+		if (!(port_info->udp)) {
+			port_info->udp = kmalloc(sizeof(struct local_addresses_list), GFP_KERNEL);
+			if (!port_info->udp)
+				return -1;
+			INIT_LIST_HEAD(&((port_info->udp)->list));
+			port_info->udp->counter = 0;
+		}
+		if (lpi->address == 0) {
+			struct local_addresses_list *address = NULL;
+			struct list_head *pos = NULL;
+
+			list_for_each(pos, &(local_list->list)) {
+				struct packetInfo pi;
+				address = list_entry(pos, struct local_addresses_list, list);
+				pi.address = address->address;
+				add_address(&pi, port_info->udp, &(port_info->udp_list_counter), lpi->pid);
+			}
+		} else {
+			add_address(lpi, port_info->udp, &(port_info->udp_list_counter), lpi->pid);
+		}
+		break;
+	default:
+		return -1;
+	}
+
+	return 0;
+}
+
+static struct portInfo *create_packet_info(struct packetInfo *lpi)
+{
+	struct portInfo *pi = NULL;
+	pi = kmalloc(sizeof(*pi), GFP_KERNEL);
+
+	if (!pi)
+		return NULL;
+
+	pi->port = lpi->port;
+	pi->tcp = NULL;
+	pi->tcp_list_counter = 0;
+	pi->udp = NULL;
+	pi->udp_list_counter = 0;
+
+	insert_address(lpi, pi);
+
+	return pi;
+}
+
+static int __monitor_insert(struct rb_root *root, struct packetInfo *lpi)
+{
+	struct rb_node **new = &(root->rb_node), *parent = NULL;
+	struct portInfo *port = NULL;
+
+	while (*new) {
+		struct portInfo *this = container_of(*new, struct portInfo, node);
+
+		parent = *new;
+		if (lpi->port < this->port) {
+			new = &((*new)->rb_left);
+		} else
+			if (lpi->port > this->port) {
+				new = &((*new)->rb_right);
+			} else {
+				insert_address(lpi, this);
+				return 1;
+			}
+	}
+	port = create_packet_info(lpi);
+	if (!port)
+		return -1;
+
+	rb_link_node(&port->node, parent, new);
+	rb_insert_color(&port->node, root);
+
+	return 1;
+}
+
+int monitor_insert(struct packetInfo *lpi)
+{
+	return __monitor_insert(&db, lpi);
+}
+
+int decrement_address(struct packetInfo *lpi,
+		struct local_addresses_list *protocol, int *list_counter)
+{
+	struct local_addresses_list *address = NULL;
+	struct list_head *pos = NULL, *q = NULL;
+
+	list_for_each_safe(pos, q, &(protocol->list)) {
+		address = list_entry(pos, struct local_addresses_list, list);
+		if (lpi->address == address->address) {
+			(address->counter)--;
+			if (address->counter <= 0) {
+				list_del(pos);
+				kfree(address);
+				(*(list_counter))--;
+			}
+			return 1;
+		}
+	}
+	return 0;
+}
+
+static void remove_address_from_node(struct portInfo *pi, struct packetInfo *lpi)
+{
+
+	switch (lpi->protocol) {
+	case IPPROTO_TCP:
+		if (lpi->address) {
+			decrement_address(lpi, pi->tcp, &(pi->tcp_list_counter));
+		} else {
+			struct local_addresses_list *address = NULL;
+			struct list_head *pos = NULL;
+
+			list_for_each(pos, &(local_list->list)) {
+				struct packetInfo aux;
+				address = list_entry(pos, struct local_addresses_list, list);
+				aux.address = address->address;
+				decrement_address(&aux, pi->tcp, &(pi->tcp_list_counter));
+			}
+		}
+		if (pi->tcp_list_counter == 0) {
+			kfree(pi->tcp);
+			pi->tcp = NULL;
+		}
+		break;
+
+	case IPPROTO_UDP:
+		if (lpi->address) {
+			decrement_address(lpi, pi->udp, &(pi->udp_list_counter));
+		} else {
+			struct local_addresses_list *address = NULL;
+			struct list_head *pos = NULL;
+
+			list_for_each(pos, &(local_list->list)) {
+				struct packetInfo aux;
+				address = list_entry(pos, struct local_addresses_list, list);
+				aux.address = address->address;
+				decrement_address(&aux, pi->udp, &(pi->udp_list_counter));
+			}
+
+		}
+		if (pi->udp_list_counter == 0) {
+			kfree(pi->udp);
+			pi->udp = NULL;
+		}
+		break;
+	default:
+		return;
+	}
+}
+
+static void __monitor_erase(struct rb_root *root, struct packetInfo *pi)
+{
+	struct portInfo *data = __monitor_search(root, pi);
+
+	if (data) {
+		remove_address_from_node(data, pi);
+
+		if ((!data->tcp) && !(data->udp)) {
+			rb_erase(&data->node, root);
+			kfree(data);
+		}
+	}
+}
+
+void monitor_erase(struct packetInfo *pi)
+{
+	__monitor_erase(&db, pi);
+}
+
+static void clear_node_info(struct portInfo *pi)
+{
+	struct local_addresses_list *tmp = NULL;
+	struct list_head *pos = NULL, *q = NULL;
+
+	if (pi->tcp_list_counter > 0 && pi->tcp != NULL) {
+		struct local_addresses_list *aux = pi->tcp;
+		list_for_each_safe(pos, q, &(aux->list)) {
+			tmp = list_entry(pos, struct local_addresses_list, list);
+			list_del(pos);
+			kfree(tmp);
+		}
+		pi->tcp_list_counter = 0;
+		kfree(pi->tcp);
+	}
+
+	if (pi->udp_list_counter > 0 && pi->udp != NULL) {
+		struct local_addresses_list *aux = pi->udp;
+		list_for_each_safe(pos, q, &(aux->list))
+		{
+			tmp = list_entry(pos, struct local_addresses_list, list);
+			list_del(pos);
+			kfree(tmp);
+		}
+		pi->udp_list_counter = 0;
+		kfree(pi->udp);
+	}
+}
+
+void clear_all_info(struct rb_root *root)
+{
+	struct rb_node *node = NULL, *next_node = NULL;
+	struct portInfo *p = NULL;
+
+	node = rb_first(root);
+	while (node) {
+		next_node = rb_next(node);
+		p = rb_entry(node, struct portInfo, node);
+		clear_node_info(p);
+
+		rb_erase(node, root);
+		kfree(p);
+		p = NULL;
+		node = next_node;
+	}
+}
+
+void init_db_monitor(void)
+{
+}
+
+void exit_db_monitor(void)
+{
+	clear_all_info(&db);
+}
diff --git a/net/pidmonitor/db_monitor.h b/net/pidmonitor/db_monitor.h
new file mode 100644
index 0000000..ddc18d7
--- /dev/null
+++ b/net/pidmonitor/db_monitor.h
@@ -0,0 +1,51 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef PORTSDB_H_
+#define PORTSDB_H_
+
+#include <linux/types.h>
+#include <linux/list.h>
+#include <linux/rbtree.h>
+
+#include "pidmonitor.h"
+
+struct portInfo {
+	struct rb_node node;
+	u16 port;
+	struct local_addresses_list *udp;
+	struct local_addresses_list *tcp;
+	int tcp_list_counter;
+	int udp_list_counter;
+};
+
+extern struct portInfo *monitor_search(struct packetInfo *pi);
+extern int monitor_insert(struct packetInfo *lpi);
+extern void monitor_erase(struct packetInfo *pi);
+void clear_all_info(struct rb_root *root);
+
+extern void init_db_monitor(void);
+extern void exit_db_monitor(void);
+
+#endif /* PORTSDB_H_ */
diff --git a/net/pidmonitor/filter.c b/net/pidmonitor/filter.c
new file mode 100644
index 0000000..121c36a
--- /dev/null
+++ b/net/pidmonitor/filter.c
@@ -0,0 +1,476 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+/*
+ * Linux Socket Filter - Kernel level socket filtering
+ *
+ * Author:
+ *     Jay Schulist <jschlst@samba.org>
+ *
+ * Based on the design of:
+ *     - The Berkeley Packet Filter
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License
+ * as published by the Free Software Foundation; either version
+ * 2 of the License, or (at your option) any later version.
+ *
+ * Andi Kleen - Fix a few bad bugs and races.
+ * Kris Katterjohn - Added many additional checks in sk_chk_filter()
+ */
+
+#include <linux/module.h>
+#include <linux/types.h>
+#include <linux/mm.h>
+#include <linux/fcntl.h>
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/inet.h>
+#include <linux/netdevice.h>
+#include <linux/if_packet.h>
+#include <linux/gfp.h>
+#include <net/ip.h>
+#include <net/protocol.h>
+#include <net/netlink.h>
+#include <linux/skbuff.h>
+#include <net/sock.h>
+#include <linux/errno.h>
+#include <linux/timer.h>
+#include <asm/uaccess.h>
+#include <asm/unaligned.h>
+#include <linux/filter.h>
+#include <linux/reciprocal_div.h>
+#include <linux/ratelimit.h>
+
+#include <linux/debugfs.h>
+#include <linux/module.h>
+#include <linux/socket.h>
+
+#include <linux/skbuff.h>
+#include <linux/filter.h>
+#include <asm/unaligned.h>
+
+#include "pidmonitor.h"
+#include "db_monitor.h"
+
+#define		BPF_PROC	0xf0
+
+/* No hurry in this branch */
+static void *__load_pointer(const struct sk_buff *skb, int k, unsigned int size)
+{
+	u8 *ptr = NULL;
+
+	if (k >= SKF_NET_OFF)
+		ptr = skb_network_header(skb) + k - SKF_NET_OFF;
+	else if (k >= SKF_LL_OFF)
+		ptr = skb_mac_header(skb) + k - SKF_LL_OFF;
+
+	if (ptr >= skb->head && ptr + size <= skb_tail_pointer(skb))
+		return ptr;
+	return NULL;
+}
+
+static inline void *load_pointer(const struct sk_buff *skb, int k,
+				 unsigned int size, void *buffer)
+{
+	if (k >= 0)
+		return skb_header_pointer(skb, k, size, buffer);
+	return __load_pointer(skb, k, size);
+}
+
+int dynamic_filter(const struct sk_buff *skb, const int pid);
+
+unsigned int process_packets(const struct sk_buff *skb,
+			   const struct sock_filter *fentry)
+{
+	void *ptr;
+	u32 A = 0;			/* Accumulator */
+	u32 X = 0;			/* Index Register */
+	u32 mem[BPF_MEMWORDS];		/* Scratch Memory Store */
+	u32 tmp;
+	int k;
+	/*
+	 * Process array of filter instructions.
+	 */
+	for (;; fentry++) {
+#if defined(CONFIG_X86_32)
+#define	K (fentry->k)
+#else
+		const u32 K = fentry->k;
+#endif
+
+		switch (fentry->code) {
+		case BPF_S_ALU_ADD_X:
+			A += X;
+			continue;
+		case BPF_S_ALU_ADD_K:
+			A += K;
+			continue;
+		case BPF_S_ALU_SUB_X:
+			A -= X;
+			continue;
+		case BPF_S_ALU_SUB_K:
+			A -= K;
+			continue;
+		case BPF_S_ALU_MUL_X:
+			A *= X;
+			continue;
+		case BPF_S_ALU_MUL_K:
+			A *= K;
+			continue;
+		case BPF_S_ALU_DIV_X:
+			if (X == 0)
+				return 0;
+			A /= X;
+			continue;
+		case BPF_S_ALU_DIV_K:
+			A = reciprocal_divide(A, K);
+			continue;
+		case BPF_S_ALU_AND_X:
+			A &= X;
+			continue;
+		case BPF_S_ALU_AND_K:
+			A &= K;
+			continue;
+		case BPF_S_ALU_OR_X:
+			A |= X;
+			continue;
+		case BPF_S_ALU_OR_K:
+			A |= K;
+			continue;
+		case BPF_S_ALU_LSH_X:
+			A <<= X;
+			continue;
+		case BPF_S_ALU_LSH_K:
+			A <<= K;
+			continue;
+		case BPF_S_ALU_RSH_X:
+			A >>= X;
+			continue;
+		case BPF_S_ALU_RSH_K:
+			A >>= K;
+			continue;
+		case BPF_S_ALU_NEG:
+			A = -A;
+			continue;
+		case BPF_S_JMP_JA:
+			fentry += K;
+			continue;
+		case BPF_S_JMP_JGT_K:
+			fentry += (A > K) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JGE_K:
+			fentry += (A >= K) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JEQ_K:
+			fentry += (A == K) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JSET_K:
+			fentry += (A & K) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JGT_X:
+			fentry += (A > X) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JGE_X:
+			fentry += (A >= X) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JEQ_X:
+			fentry += (A == X) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_JMP_JSET_X:
+			fentry += (A & X) ? fentry->jt : fentry->jf;
+			continue;
+		case BPF_S_LD_W_ABS:
+			k = K;
+load_w:
+			ptr = load_pointer(skb, k, 4, &tmp);
+			if (ptr != NULL) {
+				A = get_unaligned_be32(ptr);
+				continue;
+			}
+			return 0;
+		case BPF_S_LD_H_ABS:
+			k = K;
+load_h:
+			ptr = load_pointer(skb, k, 2, &tmp);
+			if (ptr != NULL) {
+				A = get_unaligned_be16(ptr);
+				continue;
+			}
+			return 0;
+		case BPF_S_LD_B_ABS:
+			k = K;
+load_b:
+			ptr = load_pointer(skb, k, 1, &tmp);
+			if (ptr != NULL) {
+				A = *(u8 *)ptr;
+				continue;
+			}
+			return 0;
+		case BPF_S_LD_W_LEN:
+			A = skb->len;
+			continue;
+		case BPF_S_LDX_W_LEN:
+			X = skb->len;
+			continue;
+		case BPF_S_LD_W_IND:
+			k = X + K;
+			goto load_w;
+		case BPF_S_LD_H_IND:
+			k = X + K;
+			goto load_h;
+		case BPF_S_LD_B_IND:
+			k = X + K;
+			goto load_b;
+		case BPF_S_LDX_B_MSH:
+			ptr = load_pointer(skb, K, 1, &tmp);
+			if (ptr != NULL) {
+				X = (*(u8 *)ptr & 0xf) << 2;
+				continue;
+			}
+			return 0;
+		case BPF_S_LD_IMM:
+			A = K;
+			continue;
+		case BPF_S_LDX_IMM:
+			X = K;
+			continue;
+		case BPF_S_LD_MEM:
+			A = mem[K];
+			continue;
+		case BPF_S_LDX_MEM:
+			X = mem[K];
+			continue;
+		case BPF_S_MISC_TAX:
+			X = A;
+			continue;
+		case BPF_S_MISC_TXA:
+			A = X;
+			continue;
+		case BPF_S_MISC_PROC:
+			A = dynamic_filter(skb, ((fentry+1)->k)) ? ((fentry+1)->k) : 0;
+			continue;
+		case BPF_S_RET_K:
+			return K;
+		case BPF_S_RET_A:
+			return A;
+		case BPF_S_ST:
+			mem[K] = A;
+			continue;
+		case BPF_S_STX:
+			mem[K] = X;
+			continue;
+		case BPF_S_ANC_PROTOCOL:
+			A = ntohs(skb->protocol);
+			continue;
+		case BPF_S_ANC_PKTTYPE:
+			A = skb->pkt_type;
+			continue;
+		case BPF_S_ANC_IFINDEX:
+			if (!skb->dev)
+				return 0;
+			A = skb->dev->ifindex;
+			continue;
+		case BPF_S_ANC_MARK:
+			A = skb->mark;
+			continue;
+		case BPF_S_ANC_QUEUE:
+			A = skb->queue_mapping;
+			continue;
+		case BPF_S_ANC_HATYPE:
+			if (!skb->dev)
+				return 0;
+			A = skb->dev->type;
+			continue;
+		case BPF_S_ANC_RXHASH:
+			A = skb->rxhash;
+			continue;
+		case BPF_S_ANC_CPU:
+			A = raw_smp_processor_id();
+			continue;
+		case BPF_S_ANC_NLATTR: {
+			struct nlattr *nla;
+
+			if (skb_is_nonlinear(skb))
+				return 0;
+			if (A > skb->len - sizeof(struct nlattr))
+				return 0;
+
+			nla = nla_find((struct nlattr *)&skb->data[A],
+				       skb->len - A, X);
+			if (nla)
+				A = (void *)nla - (void *)skb->data;
+			else
+				A = 0;
+			continue;
+		}
+		case BPF_S_ANC_NLATTR_NEST: {
+			struct nlattr *nla;
+
+			if (skb_is_nonlinear(skb))
+				return 0;
+			if (A > skb->len - sizeof(struct nlattr))
+				return 0;
+
+			nla = (struct nlattr *)&skb->data[A];
+			if (nla->nla_len > A - skb->len)
+				return 0;
+
+			nla = nla_find_nested(nla, X);
+			if (nla)
+				A = (void *)nla - (void *)skb->data;
+			else
+				A = 0;
+			continue;
+		}
+		default:
+			WARN_RATELIMIT(1, "Unknown code:%u jt:%u tf:%u k:%u\n",
+				       fentry->code, fentry->jt,
+				       fentry->jf, fentry->k);
+			return 0;
+		}
+	}
+
+	return 0;
+}
+
+
+unsigned int process_filter_function(const struct sk_buff *skb,
+		const struct sock_filter *filter, const int pid);
+
+extern int init_process_filter_function_fn(struct filter_function_struct *ffs);
+
+static struct filter_function ff = {
+	.name = "process_packet_filter",
+	.init_func = &init_process_filter_function_fn,
+	.func = &process_packets
+};
+
+/*
+ * @pi must be allocated previously
+ * @skb is the buffer passed to the filter
+ */
+static inline int getPacketInfo(const struct sk_buff *skb,
+	struct packetInfo *src_pi, struct packetInfo *dst_pi)
+{
+	u32 tmp;
+	void *ptr;
+	u32 X;
+
+	ptr = skb_header_pointer(skb, 23, 1, &tmp);
+	if (ptr != NULL) {
+		src_pi->protocol = *(u8 *)ptr;
+		dst_pi->protocol = *(u8 *)ptr;
+	} else
+		goto out;
+
+	ptr = skb_header_pointer(skb, 26, 4, &tmp);
+	if (ptr != NULL)
+		src_pi->address = get_unaligned_be32(ptr);
+	else
+		goto out;
+
+	ptr = skb_header_pointer(skb, 30, 4, &tmp);
+	if (ptr != NULL)
+		dst_pi->address = get_unaligned_be32(ptr);
+	else
+		goto out;
+
+	ptr = skb_header_pointer(skb, 14, 1, &tmp);
+	if (ptr != NULL) {
+		X = (*(u8 *)ptr & 0xf) << 2;
+		X += 14;
+		ptr = skb_header_pointer(skb, X, 2, &tmp);
+		if (ptr != NULL)
+			src_pi->port = get_unaligned_be16(ptr);
+		else
+			goto out;
+
+		X += 2;
+		ptr = skb_header_pointer(skb, X, 2, &tmp);
+		if (ptr != NULL)
+			dst_pi->port = get_unaligned_be16(ptr);
+		else
+			goto out;
+	} else
+		goto out;
+
+	return 0;
+
+out:
+	return -1;
+}
+
+int packet_belongs(struct packetInfo *src_pi, struct packetInfo *dst_pi)
+{
+	if ((src_pi->protocol == IPPROTO_TCP || src_pi->protocol == IPPROTO_UDP)) {
+		if (monitor_search(src_pi)) {
+			return src_pi->pid;
+		}
+
+		if (monitor_search(dst_pi)) {
+			return dst_pi->pid;
+		}
+	}
+
+	return 0;
+}
+
+int dynamic_filter(const struct sk_buff *skb, const int pid)
+{
+	void *ptr;
+	u32 A;
+	u32 tmp;
+	int err = -ENODATA;
+
+	ptr = skb_header_pointer(skb, 12, 2, &tmp);
+	if (ptr != NULL) {
+		A = get_unaligned_be16(ptr);
+		if (A == 0x800) {
+			struct packetInfo dst_pi;
+			struct packetInfo src_pi;
+			dst_pi.pid = pid;
+			src_pi.pid = pid;
+			if (!getPacketInfo(skb, &src_pi, &dst_pi))
+				return packet_belongs(&src_pi, &dst_pi);
+		}
+	}
+	return err;
+}
+
+unsigned int process_filter_function(const struct sk_buff *skb,
+					const struct sock_filter *filter, const int pid)
+{
+	return dynamic_filter(skb, pid);
+}
+
+int init_filter(void)
+{
+	register_filter_function(&ff);
+	return 0;
+}
+void exit_filter(void)
+{
+	unregister_filter_function(&ff);
+}
diff --git a/net/pidmonitor/filter.h b/net/pidmonitor/filter.h
new file mode 100644
index 0000000..9405aea
--- /dev/null
+++ b/net/pidmonitor/filter.h
@@ -0,0 +1,31 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef FILTER_H_
+#define FILTER_H_
+
+extern int init_filter(void);
+extern void exit_filter(void);
+
+#endif /* FILTER_H_ */
diff --git a/net/pidmonitor/pidmonitor.c b/net/pidmonitor/pidmonitor.c
new file mode 100644
index 0000000..6acfcfc
--- /dev/null
+++ b/net/pidmonitor/pidmonitor.c
@@ -0,0 +1,102 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+#include <linux/module.h>
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/slab.h>
+#include <linux/netdevice.h>
+#include <net/net_namespace.h>
+#include <linux/inetdevice.h>
+
+#include "pidmonitor.h"
+#include "filter.h"
+#include "syscalls_monitor.h"
+#include "db_monitor.h"
+
+struct local_addresses_list *local_list;
+
+struct local_addresses_list *list_all_devices_address(void)
+{
+	struct net_device *dev;
+	struct net *net = &init_net;
+	struct local_addresses_list *list = NULL;
+	struct local_addresses_list *tmp = NULL;
+
+	list = kmalloc(sizeof(*list), GFP_KERNEL);
+	INIT_LIST_HEAD(&(list->list));
+
+	for_each_netdev(net, dev) {
+		if (dev->ip_ptr) {
+			struct in_device *in4 = dev->ip_ptr;
+			struct in_ifaddr *addr;
+			for (addr = in4->ifa_list; addr; addr = addr->ifa_next) {
+				tmp = kmalloc(sizeof(*tmp), GFP_KERNEL);
+				tmp->address = ntohl(addr->ifa_address);
+				list_add(&(tmp->list), &(list->list));
+			}
+		}
+	}
+	return list;
+}
+
+int remove_local_addresses_list(struct local_addresses_list *list)
+{
+	struct local_addresses_list *tmp;
+	struct list_head *pos = NULL, *q = NULL;
+
+	list_for_each_safe(pos, q, &(list->list)) {
+		tmp = list_entry(pos, struct local_addresses_list, list);
+		list_del(pos);
+		kfree(tmp);
+	}
+
+	return 0;
+}
+
+static int __init monitor_init(void)
+{
+	init_syscalls_monitor();
+	init_db_monitor();
+	init_filter();
+
+	local_list = list_all_devices_address();
+	return 0;
+}
+
+static void __exit monitor_exit(void)
+{
+	int ret = -1;
+
+	exit_db_monitor();
+	exit_filter();
+	exit_syscalls_monitor();
+
+	ret = remove_local_addresses_list(local_list);
+	if (ret == 0)
+		kfree(local_list);
+}
+
+module_init(monitor_init);
+module_exit(monitor_exit);
+MODULE_LICENSE("GPL");
diff --git a/net/pidmonitor/pidmonitor.h b/net/pidmonitor/pidmonitor.h
new file mode 100644
index 0000000..69d4306
--- /dev/null
+++ b/net/pidmonitor/pidmonitor.h
@@ -0,0 +1,63 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+#ifndef PCAP_MONITORING_H_
+#define PCAP_MONITORING_H_
+
+#include <linux/types.h>
+#include <linux/fs.h>
+#include <net/net_namespace.h>
+#include <linux/list.h>
+
+struct packetInfo {
+	u8 protocol;
+	u16 port;
+	u32 address;
+	int pid;
+};
+
+#define NIPQUAD(addr) \
+	((unsigned char *)&addr)[3], \
+	((unsigned char *)&addr)[2], \
+	((unsigned char *)&addr)[1], \
+	((unsigned char *)&addr)[0]
+
+struct local_addresses_list {
+	struct list_head list;
+	u32 address;
+	unsigned int pid;
+	int counter;
+};
+
+extern struct local_addresses_list *local_list;
+extern struct socket *sockfd_lookup(int fd, int *err);
+int get_local_packet_info_from_fd(unsigned int fd, struct packetInfo *ret);
+int get_local_packet_info_from_file(struct file *f, struct packetInfo *ret);
+struct local_addresses_list *list_all_devices_address(void);
+int remove_local_addresses_list(struct local_addresses_list *list);
+extern struct net inet;
+
+int init_process_filter_function_fn(struct filter_function_struct *ffs);
+void init_repo_task(int pidnr);
+
+#endif /* PCAP_MONITORING_H_ */
diff --git a/net/pidmonitor/proc_monitor.c b/net/pidmonitor/proc_monitor.c
new file mode 100644
index 0000000..5b41db3
--- /dev/null
+++ b/net/pidmonitor/proc_monitor.c
@@ -0,0 +1,116 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+#include <linux/kernel.h>
+#include <linux/list.h>
+#include <linux/stat.h>
+#include <linux/file.h>
+#include <linux/fs.h>
+#include <linux/path.h>
+#include <linux/dcache.h>
+#include <linux/socket.h>
+#include <linux/skbuff.h>
+#include <linux/tcp.h>
+#include <net/inet_sock.h>
+#include <linux/types.h>
+#include <linux/netdevice.h>
+#include <net/net_namespace.h>
+#include <linux/inetdevice.h>
+
+
+#include "pidmonitor.h"
+
+static void get_inet_sock_param(struct inet_sock *inetsock, struct packetInfo *ret)
+{
+	ret->port = inetsock->inet_num;
+	ret->protocol = ((struct sock *)inetsock)->sk_protocol;
+
+	if (ret->port == ntohs(inetsock->inet_sport)) {
+		if (!inetsock->inet_rcv_saddr)
+			ret->address = inetsock->inet_saddr;
+		else
+			ret->address = inetsock->inet_rcv_saddr;
+
+	} else
+		ret->address = inetsock->inet_daddr;
+
+	ret->address = ntohl(ret->address);
+}
+
+
+int get_local_packet_info_from_fd(unsigned int fd, struct packetInfo *ret)
+{
+	struct file *f = fget(fd);
+
+	if (f != NULL) {
+		fput(f);
+		return get_local_packet_info_from_file(f, ret);
+	}
+	return -3;
+}
+
+int get_local_packet_info_from_file(struct file *f, struct packetInfo *ret)
+{
+	struct socket *socket = NULL;
+	short type;
+	unsigned short family;
+	int err = 0;
+
+	if (f != NULL) {
+		struct dentry *dentry;
+		struct inode *d_inode;
+		dentry = f->f_dentry;
+		if (dentry != NULL) {
+			d_inode = dentry->d_inode;
+			if (S_ISSOCK(d_inode->i_mode)) {
+				socket = f->private_data;
+				if (socket == NULL) {
+					err = -5;
+					goto out;
+				}
+				type = socket->type;
+				if (socket->sk == NULL) {
+					err = -6;
+					goto out;
+				}
+				family = socket->sk->__sk_common.skc_family;
+				if (family != AF_INET) {
+					err = -4;
+					goto out;
+				} else {
+					get_inet_sock_param((struct inet_sock *)(socket->sk), ret);
+					err = 0;
+				}
+			} else {
+				err = -1;
+			}
+		} else {
+			err = -2;
+		}
+	} else {
+		err = -3;
+	}
+out:
+	return err;
+
+}
diff --git a/net/pidmonitor/proc_monitor.h b/net/pidmonitor/proc_monitor.h
new file mode 100644
index 0000000..c9ba064
--- /dev/null
+++ b/net/pidmonitor/proc_monitor.h
@@ -0,0 +1,23 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
diff --git a/net/pidmonitor/syscalls_monitor.c b/net/pidmonitor/syscalls_monitor.c
new file mode 100644
index 0000000..69016d5
--- /dev/null
+++ b/net/pidmonitor/syscalls_monitor.c
@@ -0,0 +1,423 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+#include <linux/ptrace.h>
+
+#include <linux/module.h>
+#include <linux/kprobes.h>
+
+#include <net/sock.h>
+#include <linux/string.h>
+#include <net/inet_sock.h>
+#include <linux/types.h>
+#include <linux/slab.h>
+#include <linux/types.h>
+#include <linux/list.h>
+
+#include <linux/pid.h>
+#include <asm-generic/errno.h>
+
+#include "pidmonitor.h"
+#include "db_monitor.h"
+
+u64 pid = -1, ppid = -1, tgid = -1;
+
+void set_process_identifiers(u64 lpid)
+{
+	pid = lpid;
+}
+
+int init_process_filter_function_fn(struct filter_function_struct *ffs)
+{
+	set_process_identifiers(ffs->pid);
+	init_repo_task(ffs->pid);
+	return 0;
+}
+int kprobes_index;
+
+#define TO_MONITOR(t) { \
+	if (pid == t->pid) \
+		goto monitor; \
+	else { \
+		my_data->fd = -1; \
+		return 0; \
+	}\
+} while(0);
+
+#define NR_PROBES 7
+
+struct kretprobe *kretprobes;
+
+struct cell {
+	int fd;
+};
+
+struct closeInfo {
+	int fd;
+	struct packetInfo pi;
+};
+
+struct connect_extern_info {
+	struct packetInfo external;
+	int fd;
+};
+
+static int sendto_entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	struct task_struct *task = ri->task;
+
+#ifdef CONFIG_X86_32
+	int fd = regs->ax;
+#else
+	int fd = regs->di;
+#endif
+	struct cell *my_data = (struct cell *)ri->data;
+	TO_MONITOR(task)
+
+monitor :
+	my_data->fd = fd;
+	return 0;
+}
+static int sendto_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+
+	int retval = regs_return_value(regs);
+	struct cell *my_data = (struct cell *)ri->data;
+	struct packetInfo pi;
+	int fd = my_data->fd;
+
+	if (my_data->fd == -1) {
+		return 0;
+	}
+
+
+	if (retval >= 0 || retval == -EAGAIN || retval == -EINPROGRESS || retval == -EALREADY) {
+		pi.pid = ri->task->pid;
+		if (!get_local_packet_info_from_fd(fd, &pi))
+			monitor_insert(&pi);
+	}
+	return 0;
+}
+
+static int recvfrom_entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	struct task_struct *task = ri->task;
+	struct cell *my_data = (struct cell *)ri->data;
+#ifdef CONFIG_X86_32
+	int fd = regs->ax;
+#else
+	int fd = regs->di;
+#endif
+	TO_MONITOR(task)
+
+monitor :
+	my_data->fd = fd;
+	return 0;
+}
+static int recvfrom_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	int retval = regs_return_value(regs);
+	struct cell *my_data = (struct cell *)ri->data;
+	struct packetInfo pi;
+	int fd = my_data->fd;
+	int err = 0;
+
+	if (my_data->fd == -1) {
+		return 0;
+	}
+
+	if (retval >= 0 || retval == -EAGAIN || retval == -EINPROGRESS) {
+		pi.pid = ri->task->pid;
+		get_local_packet_info_from_fd(fd, &pi);
+		if (err == 0)
+			monitor_insert(&pi);
+	}
+
+	return 0;
+}
+
+static int accept_entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	struct task_struct *task = ri->task;
+	struct cell *my_data = (struct cell *)ri->data;
+
+	TO_MONITOR(task)
+
+monitor :
+	my_data->fd = 0;
+	return 0;
+}
+static int accept_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	int retval = regs_return_value(regs);
+	struct cell *my_data = (struct cell *)ri->data;
+	struct packetInfo pi;
+
+	if (my_data->fd == -1) {
+		return 0;
+	}
+
+	if (retval > 0) {
+		pi.pid = ri->task->pid;
+		if (!get_local_packet_info_from_fd(retval, &pi))
+			monitor_insert(&pi);
+	}
+
+	return 0;
+}
+
+static int close_entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	struct task_struct *task = ri->task;
+	struct closeInfo *my_data = (struct closeInfo *)ri->data;
+
+#ifdef CONFIG_X86_32
+	struct file *filp = (struct file *)regs->bx;
+#else
+	struct file *filp = (struct file *)regs->si;
+#endif
+
+	int err = -1;
+	TO_MONITOR(task)
+
+monitor :
+
+	err = get_local_packet_info_from_file(filp, &(my_data->pi));
+	if (err >= 0) {
+		my_data->fd = -2;
+	} else {
+		my_data->fd = -1;
+	}
+
+	return 0;
+}
+
+static int close_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	int retval = regs_return_value(regs);
+	struct closeInfo *cI = (struct closeInfo *)ri->data;
+
+	if (cI->fd == -1) {
+		return 0;
+	}
+	if (retval == 0)
+		monitor_erase(&(cI->pi));
+	return 0;
+}
+
+static int bind_entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	struct task_struct *task = ri->task;
+#ifdef CONFIG_X86_32
+	int fd = regs->ax;
+#else
+	int fd = regs->di;
+#endif
+	struct cell *my_data = (struct cell *)ri->data;
+	TO_MONITOR(task)
+
+monitor :
+	my_data->fd = fd;
+	return 0;
+}
+
+static int bind_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	int retval = regs_return_value(regs);
+	struct cell *my_data = (struct cell *)ri->data;
+	struct packetInfo pi;
+	int fd = my_data->fd;
+
+	if (my_data->fd == -1) {
+		return 0;
+	}
+
+	pi.pid = ri->task->pid;
+	if (retval == 0 && !get_local_packet_info_from_fd(fd, &pi))
+		monitor_insert(&pi);
+
+	return 0;
+}
+
+static int connect_entry_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	struct task_struct *task = ri->task;
+	struct connect_extern_info *my_data = (struct connect_extern_info *)ri->data;
+#ifdef CONFIG_X86_32
+	int fd = regs->ax;
+	struct sockaddr_in *in = (struct sockaddr_in *)regs->dx;
+#else
+	int fd = regs->di;
+	struct sockaddr_in *in = (struct sockaddr_in *)regs->si;
+#endif
+	TO_MONITOR(task)
+
+monitor :
+	my_data->fd = fd;
+
+	if (!get_local_packet_info_from_fd(fd, &(my_data->external))){
+		my_data->external.address = ntohl(in->sin_addr.s_addr);
+		my_data->external.port = ntohs(in->sin_port);
+		(my_data->external).pid = task->pid;
+		monitor_insert(&(my_data->external));
+	} else {
+		my_data->fd = -1;
+	}
+
+	return 0;
+}
+
+static int connect_ret_handler(struct kretprobe_instance *ri, struct pt_regs *regs)
+{
+	int retval = regs_return_value(regs);
+	struct connect_extern_info *my_data = (struct connect_extern_info *)ri->data;
+	int fd = my_data->fd;
+	struct packetInfo pi;
+
+	if (fd == -1) {
+		return 0;
+	}
+
+	if (retval == 0 || retval == -EINPROGRESS || retval == -EALREADY || retval == -EISCONN || retval == -EAGAIN) {
+		monitor_erase(&(my_data->external));
+		pi.pid = ri->task->pid;
+		if (!get_local_packet_info_from_fd(fd, &pi))
+			monitor_insert(&pi);
+	}
+
+	return 0;
+}
+
+static int instantiationKRETProbe(struct kretprobe *kret,
+				const char *function_name,
+				kretprobe_handler_t func_handler,
+				kretprobe_handler_t func_entry_handler,
+				ssize_t data_size)
+{
+	int ret = -1;
+
+	struct kprobe kp = {
+		.symbol_name = function_name,
+	};
+
+	kret->kp = kp;
+	kret->handler = func_handler;
+	kret->entry_handler = func_entry_handler;
+	kret->data_size	= data_size;
+	kret->maxactive = 8;
+
+	ret = register_kretprobe(kret);
+	if (ret < 0) {
+		return -1;
+	}
+
+	return ret;
+}
+
+/*
+ * function called on module init to initialize kretprobes common to tcp and udp
+ */
+
+static int init_kretprobes_syscalls(void)
+{
+	int ret = 0;
+
+	kretprobes = kmalloc(sizeof(*kretprobes)*NR_PROBES, GFP_KERNEL);
+
+	if (!kretprobes) {
+		return -1;
+	}
+
+	ret = instantiationKRETProbe((kretprobes+kprobes_index),
+			"sys_bind", bind_ret_handler, bind_entry_handler,
+			(ssize_t)sizeof(struct cell));
+	kprobes_index += 1;
+	if (ret < 0)
+		return -1;
+
+	ret = instantiationKRETProbe((kretprobes+kprobes_index),
+			"sys_connect", connect_ret_handler,
+			connect_entry_handler,
+			(ssize_t)sizeof(struct connect_extern_info));
+	kprobes_index += 1;
+	if (ret < 0)
+		return -1;
+
+	ret = instantiationKRETProbe((kretprobes+kprobes_index),
+			"sock_close", close_ret_handler, close_entry_handler,
+			(ssize_t)sizeof(struct packetInfo));
+	kprobes_index += 1;
+	if (ret < 0)
+		return -1;
+
+	ret = instantiationKRETProbe((kretprobes+kprobes_index),
+			"sys_accept4", accept_ret_handler, accept_entry_handler,
+			(ssize_t)sizeof(struct cell));
+	kprobes_index += 1;
+		if (ret < 0)
+			return -1;
+
+	ret = instantiationKRETProbe((kretprobes+kprobes_index),
+			"sys_sendto", sendto_ret_handler, sendto_entry_handler,
+			(ssize_t)sizeof(struct cell));
+	kprobes_index += 1;
+	if (ret < 0)
+		return -1;
+
+	ret = instantiationKRETProbe((kretprobes+kprobes_index),
+			"sys_recvfrom", recvfrom_ret_handler,
+			recvfrom_entry_handler, (ssize_t)sizeof(struct cell));
+	kprobes_index += 1;
+	if (ret < 0)
+		return -1;
+
+	return kprobes_index;
+}
+
+static void removeKprobe(int index)
+{
+	if ((kretprobes+index) != NULL) {
+		unregister_kretprobe((kretprobes+index));
+	}
+}
+
+static void destroy_kretprobes_syscalls(void)
+{
+	int i = -1;
+
+	for (i = 0; i < kprobes_index ; i++)
+		removeKprobe(i);
+
+	if (kretprobes)
+		kfree(kretprobes);
+}
+
+int init_syscalls_monitor(void)
+{
+	return init_kretprobes_syscalls();
+}
+
+void exit_syscalls_monitor(void)
+{
+	destroy_kretprobes_syscalls();
+}
diff --git a/net/pidmonitor/syscalls_monitor.h b/net/pidmonitor/syscalls_monitor.h
new file mode 100644
index 0000000..1d1a2f6
--- /dev/null
+++ b/net/pidmonitor/syscalls_monitor.h
@@ -0,0 +1,31 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#ifndef SYSCALLS_MONITOR_H_
+#define SYSCALLS_MONITOR_H_
+
+extern int init_syscalls_monitor(void);
+extern void exit_syscalls_monitor(void);
+
+#endif /* SYSCALLS_MONITOR_H_ */
diff --git a/net/pidmonitor/task_monitor.c b/net/pidmonitor/task_monitor.c
new file mode 100644
index 0000000..4b9932c
--- /dev/null
+++ b/net/pidmonitor/task_monitor.c
@@ -0,0 +1,77 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
+
+#include <linux/sched.h>
+#include <linux/socket.h>
+#include <linux/in.h>
+#include <linux/byteorder/generic.h>
+#include <linux/uaccess.h>
+#include <linux/filter.h>
+#include <linux/fdtable.h>
+#include <linux/fs.h>
+#include <linux/file.h>
+
+#include "pidmonitor.h"
+#include "db_monitor.h"
+
+static void read_from_fdtable(struct task_struct *task)
+{
+	int fd;
+	int max_fds;
+	struct file *file;
+
+	max_fds = task->files->fdt->max_fds;
+	for (fd = 0; fd < max_fds ; fd++) {
+		file = fcheck_files(task->files, fd);
+		if (file) {
+			struct packetInfo p;
+			p.pid = task->pid;
+			if (!get_local_packet_info_from_file(file, &p)) {
+				monitor_insert(&p);
+			}
+		}
+	}
+}
+
+static void init_tree(struct task_struct *task)
+{
+
+	if (task == NULL)
+		return;
+
+	rcu_read_lock();
+	read_from_fdtable(task);
+	rcu_read_unlock();
+}
+
+void init_repo_task(int pidnr)
+{
+	struct task_struct *task = NULL;
+	struct pid *pid = find_get_pid(pidnr);
+	rcu_read_lock();
+	task = pid_task(pid, PIDTYPE_PID);
+	put_pid(pid);
+	rcu_read_unlock();
+	init_tree(task);
+}
diff --git a/net/pidmonitor/task_monitor.h b/net/pidmonitor/task_monitor.h
new file mode 100644
index 0000000..c9ba064
--- /dev/null
+++ b/net/pidmonitor/task_monitor.h
@@ -0,0 +1,23 @@
+/*
+ * Packet Filtering System based on BPF / LSF
+ *
+ * Author: Nuno Martins <nuno.martins@caixamagica.pt>
+ *
+ * (c) Copyright Caixa Magica Software, LDA., 2012
+ * (c) Copyright Universidade Nova de Lisboa, 2010-2011
+ *
+ * This program is free software;  you can redistribute it and/or modify
+ * it under the terms of the GNU General Public License as published by
+ * the Free Software Foundation; either version 2 of the License, or
+ * (at your option) any later version.
+ *
+ * This program is distributed in the hope that it will be useful,
+ * but WITHOUT ANY WARRANTY;  without even the implied warranty of
+ * MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See
+ * the GNU General Public License for more details.
+ *
+ * You should have received a copy of the GNU General Public License
+ * along with this program;  if not, write to the Free Software
+ * Foundation, Inc., 59 Temple Place, Suite 330, Boston, MA 02111-1307 USA
+ *
+ */
-- 
1.7.10.rc3.11.gd8282
