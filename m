From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, inode: allow for rename and link ops
Date: Thu, 10 Dec 2015 22:33:49 +0100
Message-ID: <023d613fa37780f354c130c7920a43da2090e58e.1449782627.git.daniel@iogearbox.net>
Cc: ast@kernel.org, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:37841 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbbLJVeB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Dec 2015 16:34:01 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add support for renaming and hard links to the fs. Most of this can be
implemented by using simple library operations under the same constraints
that we don't use a reserved name like elsewhere. Linking can be useful
to share/manage things like maps across subsystem users. It works within
the file system boundary, but is not allowed for directories.

Symbolic links are explicitly not implemented here, as it can be better
done already by doing bind mounts inside bpf fs to set up shared directories
f.e. useful when using volumes in docker containers that map a private
working directory into /sys/fs/bpf/ which contains itself a bind mounted
path from the host's /sys/fs/bpf/ mount that is shared among multiple
containers. For single maps instead of whole directory, hard links can
be easily used to do the same.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/inode.c | 20 ++++++++++++++++++++
 1 file changed, 20 insertions(+)

diff --git a/kernel/bpf/inode.c b/kernel/bpf/inode.c
index 5a8a797..f2ece3c 100644
--- a/kernel/bpf/inode.c
+++ b/kernel/bpf/inode.c
@@ -187,11 +187,31 @@ static int bpf_mkobj(struct inode *dir, struct dentry *dentry, umode_t mode,
 	}
 }
 
+static int bpf_link(struct dentry *old_dentry, struct inode *dir,
+		    struct dentry *new_dentry)
+{
+	if (bpf_dname_reserved(new_dentry))
+		return -EPERM;
+
+	return simple_link(old_dentry, dir, new_dentry);
+}
+
+static int bpf_rename(struct inode *old_dir, struct dentry *old_dentry,
+		      struct inode *new_dir, struct dentry *new_dentry)
+{
+	if (bpf_dname_reserved(new_dentry))
+		return -EPERM;
+
+	return simple_rename(old_dir, old_dentry, new_dir, new_dentry);
+}
+
 static const struct inode_operations bpf_dir_iops = {
 	.lookup		= simple_lookup,
 	.mknod		= bpf_mkobj,
 	.mkdir		= bpf_mkdir,
 	.rmdir		= simple_rmdir,
+	.rename		= bpf_rename,
+	.link		= bpf_link,
 	.unlink		= simple_unlink,
 };
 
-- 
1.9.3
