From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [patch 3/4] net: show bound packet types
Date: Mon, 12 Mar 2007 14:08:20 -0700
Message-ID: <20070312210907.760118389@linux-foundation.org>
References: <20070312210817.485320783@linux-foundation.org>
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42391 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752955AbXCLVJd (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Mar 2007 17:09:33 -0400
Content-Disposition: inline; filename=ptype-proc.patch
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Show what protocols are bound to what packet types in /proc/net/ptype
Uses kallsyms to decode function pointers if possible.
Example:
	Type Device      Function
	ALL  eth1     packet_rcv_spkt+0x0
	0800          ip_rcv+0x0
	0806          arp_rcv+0x0
	86dd          :ipv6:ipv6_rcv+0x0

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
---
 net/core/dev.c |  134 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 134 insertions(+)

--- net-2.6.22.orig/net/core/dev.c	2007-03-12 12:29:39.000000000 -0700
+++ net-2.6.22/net/core/dev.c	2007-03-12 12:29:45.000000000 -0700
@@ -2217,6 +2217,135 @@
 	.release = seq_release,
 };
 
+static void *ptype_get_idx(loff_t pos)
+{
+	struct packet_type *pt = NULL;
+	loff_t i = 0;
+	int t;
+
+	list_for_each_entry_rcu(pt, &ptype_all, list) {
+		if (i == pos)
+			return pt;
+		++i;
+	}
+
+	for (t = 0; t < 16; t++) {
+		list_for_each_entry_rcu(pt, &ptype_base[t], list) {
+			if (i == pos)
+				return pt;
+			++i;
+		}
+	}
+	return NULL;
+}
+
+static void *ptype_seq_start(struct seq_file *seq, loff_t *pos)
+{
+	rcu_read_lock();
+	return *pos ? ptype_get_idx(*pos - 1) : SEQ_START_TOKEN;
+}
+
+static void *ptype_seq_next(struct seq_file *seq, void *v, loff_t *pos)
+{
+	struct packet_type *pt;
+	struct list_head *nxt;
+	int hash;
+
+	++*pos;
+	if (v == SEQ_START_TOKEN)
+		return ptype_get_idx(0);
+
+	pt = v;
+	nxt = pt->list.next;
+	if (pt->type == htons(ETH_P_ALL)) {
+		if (nxt != &ptype_all)
+			goto found;
+		hash = 0;
+		nxt = ptype_base[0].next;
+	} else
+		hash = ntohs(pt->type) & 15;
+
+	while (nxt == &ptype_base[hash]) {
+		if (++hash >= 16)
+			return NULL;
+		nxt = ptype_base[hash].next;
+	}
+found:
+	return list_entry(nxt, struct packet_type, list);
+}
+
+static void ptype_seq_stop(struct seq_file *seq, void *v)
+{
+	rcu_read_unlock();
+}
+
+static void ptype_seq_decode(struct seq_file *seq, void *sym)
+{
+#ifdef CONFIG_KALLSYMS
+	unsigned long offset = 0, symsize;
+	const char *symname;
+	char *modname;
+	char namebuf[128];
+
+	symname = kallsyms_lookup((unsigned long)sym, &symsize, &offset,
+				  &modname, namebuf);
+
+	if (symname) {
+		char *delim = ":";
+
+		if (!modname)
+			modname = delim = "";
+		seq_printf(seq, "%s%s%s%s+0x%lx", delim, modname, delim,
+			   symname, offset);
+		return;
+	}
+#endif
+
+	seq_printf(seq, "[%p]", sym);
+}
+
+static int ptype_seq_show(struct seq_file *seq, void *v)
+{
+	struct packet_type *pt = v;
+
+	if (v == SEQ_START_TOKEN)
+		seq_puts(seq, "Type Device      Function\n");
+	else {
+		if (pt->type == htons(ETH_P_ALL))
+			seq_puts(seq, "ALL ");
+		else
+			seq_printf(seq, "%04x", ntohs(pt->type));
+
+		seq_printf(seq, " %-8s ",
+			   pt->dev ? pt->dev->name : "");
+		ptype_seq_decode(seq,  pt->func);
+		seq_putc(seq, '\n');
+	}
+
+	return 0;
+}
+
+static const struct seq_operations ptype_seq_ops = {
+	.start = ptype_seq_start,
+	.next  = ptype_seq_next,
+	.stop  = ptype_seq_stop,
+	.show  = ptype_seq_show,
+};
+
+static int ptype_seq_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ptype_seq_ops);
+}
+
+static const struct file_operations ptype_seq_fops = {
+	.owner	 = THIS_MODULE,
+	.open    = ptype_seq_open,
+	.read    = seq_read,
+	.llseek  = seq_lseek,
+	.release = seq_release,
+};
+
+
 #ifdef CONFIG_WIRELESS_EXT
 extern int wireless_proc_init(void);
 #else
@@ -2231,6 +2360,9 @@
 		goto out;
 	if (!proc_net_fops_create("softnet_stat", S_IRUGO, &softnet_seq_fops))
 		goto out_dev;
+	if (!proc_net_fops_create("ptype", S_IRUGO, &ptype_seq_fops))
+		goto out_dev2;
+
 	if (wireless_proc_init())
 		goto out_softnet;
 	rc = 0;
@@ -2238,6 +2370,8 @@
 	return rc;
 out_softnet:
 	proc_net_remove("softnet_stat");
+out_dev2:
+	proc_net_remove("ptype");
 out_dev:
 	proc_net_remove("dev");
 	goto out;

--
Stephen Hemminger <shemminger@linux-foundation.org>

