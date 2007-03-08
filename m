From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [RFC] display bound packet types
Date: Wed, 7 Mar 2007 16:42:59 -0800
Message-ID: <20070307164259.106c6c08@dxpl.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.osdl.org ([65.172.181.24]:42216 "EHLO smtp.osdl.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751983AbXCHAsc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 7 Mar 2007 19:48:32 -0500
Received: from shell0.pdx.osdl.net (fw.osdl.org [65.172.181.6])
	by smtp.osdl.org (8.12.8/8.12.8) with ESMTP id l280mVq8008525
	(version=TLSv1/SSLv3 cipher=EDH-RSA-DES-CBC3-SHA bits=168 verify=NO)
	for <netdev@vger.kernel.org>; Wed, 7 Mar 2007 16:48:31 -0800
Received: from dxpl.pdx.osdl.net (unknown-232.office.pdx.osdl.net [10.8.0.232])
	by shell0.pdx.osdl.net (8.13.1/8.11.6) with ESMTP id l280mV12014738
	for <netdev@vger.kernel.org>; Wed, 7 Mar 2007 16:48:31 -0800
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

While debugging I found it useful to see what packet types are in use.

This creates /proc/net/ptype with the format:

Type Device      Function
ALL  eth0     [ffffffff880b01b6] :af_packet:packet_rcv_spkt+0x0
0800          [ffffffff802330f8] ip_rcv+0x0
0011          [ffffffff881021ef] :llc:llc_rcv+0x0
0004          [ffffffff881021ef] :llc:llc_rcv+0x0
0806          [ffffffff8043de7f] arp_rcv+0x0
86dd          [ffffffff880c1b57] :ipv6:ipv6_rcv+0x0

Is it worth the space?

---
 net/core/dev.c |  131 +++++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 131 insertions(+)

--- netem-dev.orig/net/core/dev.c
+++ netem-dev/net/core/dev.c
@@ -2217,6 +2217,132 @@ static const struct file_operations soft
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
+		seq_printf(seq, " %-8s [%p]",
+			   pt->dev ? pt->dev->name : "",
+			   pt->func);
+#ifdef CONFIG_KALLSYMS
+		{
+			unsigned long offset = 0, symsize;
+			const char *symname;
+			char *modname;
+			char *delim = ":";
+			char namebuf[128];
+
+			symname = kallsyms_lookup((unsigned long)pt->func,
+						  &symsize, &offset,
+						  &modname, namebuf);
+
+			if (symname) {
+				if (!modname)
+					modname = delim = "";
+				seq_printf(seq, " %s%s%s%s+0x%lx",
+					   delim, modname, delim,
+					   symname, offset);
+			}
+		}
+#endif
+		seq_putc(seq, '\n');
+
+	}
+
+	return 0;
+}
+
+static struct seq_operations ptype_seq_ops = {
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
@@ -2231,6 +2357,9 @@ static int __init dev_proc_init(void)
 		goto out;
 	if (!proc_net_fops_create("softnet_stat", S_IRUGO, &softnet_seq_fops))
 		goto out_dev;
+	if (!proc_net_fops_create("ptype", S_IRUGO, &ptype_seq_fops))
+		goto out_dev2;
+
 	if (wireless_proc_init())
 		goto out_softnet;
 	rc = 0;
@@ -2238,6 +2367,8 @@ out:
 	return rc;
 out_softnet:
 	proc_net_remove("softnet_stat");
+out_dev2:
+	proc_net_remove("ptype");
 out_dev:
 	proc_net_remove("dev");
 	goto out;
