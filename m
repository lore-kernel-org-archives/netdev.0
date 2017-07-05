From: David Howells <dhowells@redhat.com>
Subject: [PATCH 06/14] bpf: Implement show_options
Date: Wed, 05 Jul 2017 16:24:49 +0100
Message-ID: <149926828898.20611.6599036959362646109.stgit@warthog.procyon.org.uk>
References: <149926824154.20611.6104595541055328700.stgit@warthog.procyon.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Alexei Starovoitov <ast@kernel.org>,
        linux-kernel@vger.kernel.org, dhowells@redhat.com,
        linux-fsdevel@vger.kernel.org
To: viro@zeniv.linux.org.uk
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <149926824154.20611.6104595541055328700.stgit@warthog.procyon.org.uk>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement the show_options superblock op for bpf as part of a bid to get
rid of s_options and generic_show_options() to make it easier to implement
a context-based mount where the mount options can be passed individually
over a file descriptor.

Signed-off-by: David Howells <dhowells@redhat.com>
cc: Alexei Starovoitov <ast@kernel.org>
cc: Daniel Borkmann <daniel@iogearbox.net>
cc: netdev@vger.kernel.org
---

 kernel/bpf/inode.c |   16 +++++++++++++---
 1 file changed, 13 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 9bbd33497d3d..e833ed914358 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -377,10 +377,22 @@ static void bpf_evict_inode(struct inode *inode)
 		bpf_any_put(inode->i_private, type);
 }
 
+/*
+ * Display the mount options in /proc/mounts.
+ */
+static int bpf_show_options(struct seq_file *m, struct dentry *root)
+{
+	umode_t mode = d_inode(root)->i_mode & S_IALLUGO & ~S_ISVTX;
+
+	if (mode != S_IRWXUGO)
+		seq_printf(m, ",mode=%o", mode);
+	return 0;
+}
+
 static const struct super_operations bpf_super_ops = {
 	.statfs		= simple_statfs,
 	.drop_inode	= generic_delete_inode,
-	.show_options	= generic_show_options,
+	.show_options	= bpf_show_options,
 	.evict_inode	= bpf_evict_inode,
 };
 
@@ -434,8 +446,6 @@ static int bpf_fill_super(struct super_block *sb, void *data, int silent)
 	struct inode *inode;
 	int ret;
 
-	save_mount_options(sb, data);
-
 	ret = bpf_parse_options(data, &opts);
 	if (ret)
 		return ret;
