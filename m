From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 5/6] bpf: allow for mount options to specify permissions
Date: Sat, 26 Nov 2016 01:28:08 +0100
Message-ID: <fc8b72b6e6604e070240b049e4dea00f3776858a.1480119396.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42856 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751917AbcKZA2o (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 19:28:44 -0500
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
In-Reply-To: <cover.1480119395.git.daniel@iogearbox.net>
References: <cover.1480119395.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since we recently converted the BPF filesystem over to use mount_nodev(),
we now have the possibility to also hold mount options in sb's s_fs_info.
This work implements mount options support for specifying permissions on
the sb's inode, which will be used by tc when it manually needs to mount
the fs.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/inode.c | 54 +++++++++++++++++++++++++++++++++++++++++++++++++++++-
 1 file changed, 53 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 2565809..0b030c9 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -18,6 +18,7 @@
 #include <linux/namei.h>
 #include <linux/fs.h>
 #include <linux/kdev_t.h>
+#include <linux/parser.h>
 #include <linux/filter.h>
 #include <linux/bpf.h>
 
@@ -364,15 +365,66 @@ static void bpf_evict_inode(struct inode *inode)
 static const struct super_operations bpf_super_ops = {
 	.statfs		= simple_statfs,
 	.drop_inode	= generic_delete_inode,
+	.show_options	= generic_show_options,
 	.evict_inode	= bpf_evict_inode,
 };
 
+enum {
+	OPT_MODE,
+	OPT_ERR,
+};
+
+static const match_table_t bpf_mount_tokens = {
+	{ OPT_MODE, "mode=%o" },
+	{ OPT_ERR, NULL },
+};
+
+struct bpf_mount_opts {
+	umode_t mode;
+};
+
+static int bpf_parse_options(char *data, struct bpf_mount_opts *opts)
+{
+	substring_t args[MAX_OPT_ARGS];
+	int option, token;
+	char *ptr;
+
+	opts->mode = S_IRWXUGO;
+
+	while ((ptr = strsep(&data, ",")) != NULL) {
+		if (!*ptr)
+			continue;
+
+		token = match_token(ptr, bpf_mount_tokens, args);
+		switch (token) {
+		case OPT_MODE:
+			if (match_octal(&args[0], &option))
+				return -EINVAL;
+			opts->mode = option & S_IALLUGO;
+			break;
+		/* We might like to report bad mount options here, but
+		 * traditionally we've ignored all mount options, so we'd
+		 * better continue to ignore non-existing options for bpf.
+		 */
+		}
+	}
+
+	return 0;
+}
+
 static int bpf_fill_super(struct super_block *sb, void *data, int silent)
 {
 	static struct tree_descr bpf_rfiles[] = { { "" } };
+	struct bpf_mount_opts opts;
 	struct inode *inode;
 	int ret;
 
+	save_mount_options(sb, data);
+
+	ret = bpf_parse_options(data, &opts);
+	if (ret)
+		return ret;
+
 	ret = simple_fill_super(sb, BPF_FS_MAGIC, bpf_rfiles);
 	if (ret)
 		return ret;
@@ -382,7 +434,7 @@ static int bpf_fill_super(struct super_block *sb, void *data, int silent)
 	inode = sb->s_root->d_inode;
 	inode->i_op = &bpf_dir_iops;
 	inode->i_mode &= ~S_IALLUGO;
-	inode->i_mode |= S_ISVTX | S_IRWXUGO;
+	inode->i_mode |= S_ISVTX | opts.mode;
 
 	return 0;
 }
-- 
1.9.3
