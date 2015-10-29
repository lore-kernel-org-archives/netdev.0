From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 1/5] bpf: abstract anon_inode_getfd invocations
Date: Thu, 29 Oct 2015 14:58:06 +0100
Message-ID: <7e428ccb5196367a6d3d73068587f8527923f61c.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, hannes@stressinduktion.org, tgraf@suug.ch,
	viro@ZenIV.linux.org.uk, ebiederm@xmission.com,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
In-Reply-To: <cover.1446126105.git.daniel@iogearbox.net>
References: <cover.1446126105.git.daniel@iogearbox.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Since we're going to use anon_inode_getfd() invocations in more than just
the current places, make a helper function for both, so that we only need
to pass a map/prog pointer to the helper itself in order to get a fd. The
new helpers are called bpf_map_new_fd() and bpf_prog_new_fd().

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 kernel/bpf/syscall.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index 687dd6c..2b89ef0 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -111,6 +111,12 @@ static const struct file_operations bpf_map_fops = {
 	.release = bpf_map_release,
 };
 
+static int bpf_map_new_fd(struct bpf_map *map)
+{
+	return anon_inode_getfd("bpf-map", &bpf_map_fops, map,
+				O_RDWR | O_CLOEXEC);
+}
+
 /* helper macro to check that unused fields 'union bpf_attr' are zero */
 #define CHECK_ATTR(CMD) \
 	memchr_inv((void *) &attr->CMD##_LAST_FIELD + \
@@ -141,8 +147,7 @@ static int map_create(union bpf_attr *attr)
 	if (err)
 		goto free_map;
 
-	err = anon_inode_getfd("bpf-map", &bpf_map_fops, map, O_RDWR | O_CLOEXEC);
-
+	err = bpf_map_new_fd(map);
 	if (err < 0)
 		/* failed to allocate fd */
 		goto free_map;
@@ -538,6 +543,12 @@ static const struct file_operations bpf_prog_fops = {
         .release = bpf_prog_release,
 };
 
+static int bpf_prog_new_fd(struct bpf_prog *prog)
+{
+	return anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog,
+				O_RDWR | O_CLOEXEC);
+}
+
 static struct bpf_prog *get_prog(struct fd f)
 {
 	struct bpf_prog *prog;
@@ -647,7 +658,7 @@ static int bpf_prog_load(union bpf_attr *attr)
 	if (err < 0)
 		goto free_used_maps;
 
-	err = anon_inode_getfd("bpf-prog", &bpf_prog_fops, prog, O_RDWR | O_CLOEXEC);
+	err = bpf_prog_new_fd(prog);
 	if (err < 0)
 		/* failed to allocate fd */
 		goto free_used_maps;
-- 
1.9.3
