From: Pavel Emelyanov <xemul@openvz.org>
Subject: [PATCH 1/6][NET-2.6.24] Introduce the seq_open_private()
Date: Tue, 09 Oct 2007 19:52:58 +0400
Message-ID: <470BA3DA.6050905@openvz.org>
References: <470BA351.3070208@openvz.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Linux Netdev List <netdev@vger.kernel.org>, devel@openvz.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from sacred.ru ([62.205.161.221]:43171 "EHLO sacred.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752122AbXJIPz2 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 9 Oct 2007 11:55:28 -0400
In-Reply-To: <470BA351.3070208@openvz.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This function allocates the zeroed chunk of memory and
call seq_open(). The __seq_open_private() helper returns
the allocated memory to make it possible for the caller
to initialize it.

Signed-off-by: Pavel Emelyanov <xemul@openvz.org>

---

diff --git a/fs/seq_file.c b/fs/seq_file.c
index bbb19be..ca71c11 100644
--- a/fs/seq_file.c
+++ b/fs/seq_file.c
@@ -429,6 +429,39 @@ int seq_release_private(struct inode *in
 }
 EXPORT_SYMBOL(seq_release_private);
 
+void *__seq_open_private(struct file *f, const struct seq_operations *ops,
+		int psize)
+{
+	int rc;
+	void *private;
+	struct seq_file *seq;
+
+	private = kzalloc(psize, GFP_KERNEL);
+	if (private == NULL)
+		goto out;
+
+	rc = seq_open(f, ops);
+	if (rc < 0)
+		goto out_free;
+
+	seq = f->private_data;
+	seq->private = private;
+	return private;
+
+out_free:
+	kfree(private);
+out:
+	return NULL;
+}
+EXPORT_SYMBOL(__seq_open_private);
+
+int seq_open_private(struct file *filp, const struct seq_operations *ops,
+		int psize)
+{
+	return __seq_open_private(filp, ops, psize) ? 0 : -ENOMEM;
+}
+EXPORT_SYMBOL(seq_open_private);
+
 int seq_putc(struct seq_file *m, char c)
 {
 	if (m->count < m->size) {
diff --git a/include/linux/seq_file.h b/include/linux/seq_file.h
index 83783ab..8bf1e05 100644
--- a/include/linux/seq_file.h
+++ b/include/linux/seq_file.h
@@ -46,6 +46,8 @@ int seq_path(struct seq_file *, struct v
 
 int single_open(struct file *, int (*)(struct seq_file *, void *), void *);
 int single_release(struct inode *, struct file *);
+void *__seq_open_private(struct file *, const struct seq_operations *, int);
+int seq_open_private(struct file *, const struct seq_operations *, int);
 int seq_release_private(struct inode *, struct file *);
 
 #define SEQ_START_TOKEN ((void *)1)

