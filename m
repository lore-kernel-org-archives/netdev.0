From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/3] bpf, maps: add release callback
Date: Wed, 15 Jun 2016 22:47:12 +0200
Message-ID: <214337ce2c843119386fdc194d4ba10c7093cac9.1466021686.git.daniel@iogearbox.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:42929 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751907AbcFOUr1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 15 Jun 2016 16:47:27 -0400
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
In-Reply-To: <cover.1466021686.git.daniel@iogearbox.net>
References: <cover.1466021686.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add a release callback for maps that is invoked when the last
reference to its struct file is gone and the struct file about
to be released by vfs. The handler will be used by fd array maps.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h  | 3 ++-
 kernel/bpf/syscall.c | 7 ++++++-
 2 files changed, 8 insertions(+), 2 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 1bcae82..29b5a1a 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -19,7 +19,8 @@ struct bpf_map;
 struct bpf_map_ops {
 	/* funcs callable from userspace (via syscall) */
 	struct bpf_map *(*map_alloc)(union bpf_attr *attr);
-	void (*map_free)(struct bpf_map *);
+	void (*map_release)(struct bpf_map *map, struct file *map_file);
+	void (*map_free)(struct bpf_map *map);
 	int (*map_get_next_key)(struct bpf_map *map, void *key, void *next_key);
 
 	/* funcs callable from userspace and from eBPF programs */
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 46ecce4..fc3adcd 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -124,7 +124,12 @@ void bpf_map_put_with_uref(struct bpf_map *map)
 
 static int bpf_map_release(struct inode *inode, struct file *filp)
 {
-	bpf_map_put_with_uref(filp->private_data);
+	struct bpf_map *map = filp->private_data;
+
+	if (map->ops->map_release)
+		map->ops->map_release(map, filp);
+
+	bpf_map_put_with_uref(map);
 	return 0;
 }
 
-- 
1.9.3
