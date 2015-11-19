From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: add show_fdinfo handler for maps
Date: Thu, 19 Nov 2015 11:56:22 +0100
Message-ID: <b3f1dd7e21d72dc47beac222d655640ee584c5cd.1447930253.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:57595 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752892AbbKSK40 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Nov 2015 05:56:26 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a handler for show_fdinfo() to be used by the anon-inodes
backend for eBPF maps, and dump the map specification there. Not
only useful for admins, but also it provides a minimal way to
compare specs from ELF vs pinned object.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/syscall.c | 22 +++++++++++++++++++++-
 1 file changed, 21 insertions(+), 1 deletion(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 0d3313d..6d1407b 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -93,6 +93,23 @@ void bpf_map_put(struct bpf_map *map)
 	}
 }
 
+#ifdef CONFIG_PROC_FS
+static void bpf_map_show_fdinfo(struct seq_file *m, struct file *filp)
+{
+	const struct bpf_map *map = filp->private_data;
+
+	seq_printf(m,
+		   "map_type:\t%u\n"
+		   "key_size:\t%u\n"
+		   "value_size:\t%u\n"
+		   "max_entries:\t%u\n",
+		   map->map_type,
+		   map->key_size,
+		   map->value_size,
+		   map->max_entries);
+}
+#endif
+
 static int bpf_map_release(struct inode *inode, struct file *filp)
 {
 	struct bpf_map *map = filp->private_data;
@@ -108,7 +125,10 @@ static int bpf_map_release(struct inode *inode, struct file *filp)
 }
 
 static const struct file_operations bpf_map_fops = {
-	.release = bpf_map_release,
+#ifdef CONFIG_PROC_FS
+	.show_fdinfo	= bpf_map_show_fdinfo,
+#endif
+	.release	= bpf_map_release,
 };
 
 int bpf_map_new_fd(struct bpf_map *map)
-- 
1.9.3
