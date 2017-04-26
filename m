From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: [PATCH net-next 5/6] bpf: add skeleton for procfs printing of bpf_progs
Date: Wed, 26 Apr 2017 20:24:18 +0200
Message-ID: <20170426182419.14574-6-hannes@stressinduktion.org>
References: <20170426182419.14574-1-hannes@stressinduktion.org>
Cc: ast@kernel.org, daniel@iogearbox.com, jbenc@redhat.com,
        aconole@bytheb.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from out4-smtp.messagingengine.com ([66.111.4.28]:48037 "EHLO
        out4-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S933328AbdDZSYz (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 14:24:55 -0400
In-Reply-To: <20170426182419.14574-1-hannes@stressinduktion.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Signed-off-by: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 kernel/bpf/core.c | 90 +++++++++++++++++++++++++++++++++++++++++++++++++++++++
 1 file changed, 90 insertions(+)

diff --git a/kernel/bpf/core.c b/kernel/bpf/core.c
index 048e2d79718a16..3ba175a24e971a 100644
--- a/kernel/bpf/core.c
+++ b/kernel/bpf/core.c
@@ -32,6 +32,9 @@
 #include <linux/kallsyms.h>
 #include <linux/rcupdate.h>
 
+#include <linux/proc_fs.h>
+#include <linux/seq_file.h>
+
 #include <asm/unaligned.h>
 
 /* Registers */
@@ -488,6 +491,93 @@ int bpf_get_kallsym(unsigned int symnum, unsigned long *value, char *type,
 	return ret;
 }
 
+/* ebpf procfs implementation */
+
+static struct proc_dir_entry *ebpf_proc_dir;
+
+static void *ebpf_proc_start(struct seq_file *s, loff_t *pos)
+	__acquires(RCU_BH)
+{
+	struct bpf_prog_aux *aux;
+	loff_t off = 0;
+
+	rcu_read_lock();
+
+	if (*pos == 0)
+		return SEQ_START_TOKEN;
+
+	list_for_each_entry_rcu(aux, &bpf_progs, bpf_progs_head)
+		if (++off == *pos)
+			return aux;
+
+	return NULL;
+}
+
+static void *ebpf_proc_next(struct seq_file *s, void *v, loff_t *pos)
+{
+	struct bpf_prog_aux *aux;
+
+	++*pos;
+
+	if (v == SEQ_START_TOKEN)
+		return list_first_or_null_rcu(&bpf_progs, struct bpf_prog_aux,
+					      bpf_progs_head);
+
+	aux = v;
+	return list_next_or_null_rcu(&bpf_progs,
+				     &aux->bpf_progs_head,
+				     struct bpf_prog_aux,
+				     bpf_progs_head);
+}
+
+static void ebpf_proc_stop(struct seq_file *s, void *v)
+	__releases(RCU_BH)
+{
+	rcu_read_unlock();
+}
+
+static int ebpf_proc_show(struct seq_file *s, void *v)
+{
+	if (v == SEQ_START_TOKEN) {
+		seq_printf(s, "# tag\n");
+		return 0;
+	}
+
+	return 0;
+}
+
+static const struct seq_operations ebpf_seq_ops = {
+	.start = ebpf_proc_start,
+	.next = ebpf_proc_next,
+	.stop = ebpf_proc_stop,
+	.show = ebpf_proc_show,
+};
+
+static int ebpf_proc_open(struct inode *inode, struct file *file)
+{
+	return seq_open(file, &ebpf_seq_ops);
+}
+
+static const struct file_operations ebpf_proc_operations = {
+	.open = ebpf_proc_open,
+	.read = seq_read,
+	.llseek = seq_lseek,
+	.release = seq_release,
+};
+
+static int __init ebpf_proc_init(void)
+{
+	ebpf_proc_dir = proc_mkdir("bpf", NULL);
+	if (!ebpf_proc_dir)
+		return 0;
+	proc_create("programs", 0400, ebpf_proc_dir, &ebpf_proc_operations);
+	return 0;
+}
+
+device_initcall(ebpf_proc_init);
+
+/* end of bpf proc inmplementation */
+
 struct bpf_binary_header *
 bpf_jit_binary_alloc(unsigned int proglen, u8 **image_ptr,
 		     unsigned int alignment,
-- 
2.9.3
