From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next v2 5/8] ebpf: remove CONFIG_BPF_SYSCALL ifdefs in socket filter code
Date: Sun,  1 Mar 2015 12:31:45 +0100
Message-ID: <0cfa43b51eaacab86deeb8fda9bab342dfba4aaa.1425208502.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, netdev@vger.kernel.org,
	Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:52018 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751380AbbCALcO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Mar 2015 06:32:14 -0500
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
In-Reply-To: <cover.1425208501.git.daniel@iogearbox.net>
References: <cover.1425208501.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This gets rid of CONFIG_BPF_SYSCALL ifdefs in the socket filter code,
now that the BPF internal header can deal with it.

While going over it, I also changed eBPF related functions to a sk_filter
prefix to be more consistent with the rest of the file.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@plumgrid.com>
---
 net/core/filter.c | 36 ++++++++++++++----------------------
 1 file changed, 14 insertions(+), 22 deletions(-)

diff --git a/net/core/filter.c b/net/core/filter.c
index 6fe09e3..7417212 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1093,7 +1093,6 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 }
 EXPORT_SYMBOL_GPL(sk_attach_filter);
 
-#ifdef CONFIG_BPF_SYSCALL
 int sk_attach_bpf(u32 ufd, struct sock *sk)
 {
 	struct sk_filter *fp, *old_fp;
@@ -1107,7 +1106,6 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 		return PTR_ERR(prog);
 
 	if (prog->aux->prog_type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		/* valid fd, but invalid program type */
 		bpf_prog_put(prog);
 		return -EINVAL;
 	}
@@ -1117,8 +1115,8 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 		bpf_prog_put(prog);
 		return -ENOMEM;
 	}
-	fp->prog = prog;
 
+	fp->prog = prog;
 	atomic_set(&fp->refcnt, 0);
 
 	if (!sk_filter_charge(sk, fp)) {
@@ -1136,10 +1134,8 @@ int sk_attach_bpf(u32 ufd, struct sock *sk)
 	return 0;
 }
 
-/* allow socket filters to call
- * bpf_map_lookup_elem(), bpf_map_update_elem(), bpf_map_delete_elem()
- */
-static const struct bpf_func_proto *sock_filter_func_proto(enum bpf_func_id func_id)
+static const struct bpf_func_proto *
+sk_filter_func_proto(enum bpf_func_id func_id)
 {
 	switch (func_id) {
 	case BPF_FUNC_map_lookup_elem:
@@ -1153,34 +1149,30 @@ static const struct bpf_func_proto *sock_filter_func_proto(enum bpf_func_id func
 	}
 }
 
-static bool sock_filter_is_valid_access(int off, int size, enum bpf_access_type type)
+static bool sk_filter_is_valid_access(int off, int size,
+				      enum bpf_access_type type)
 {
 	/* skb fields cannot be accessed yet */
 	return false;
 }
 
-static const struct bpf_verifier_ops sock_filter_ops = {
-	.get_func_proto = sock_filter_func_proto,
-	.is_valid_access = sock_filter_is_valid_access,
+static const struct bpf_verifier_ops sk_filter_ops = {
+	.get_func_proto = sk_filter_func_proto,
+	.is_valid_access = sk_filter_is_valid_access,
 };
 
-static struct bpf_prog_type_list sock_filter_type __read_mostly = {
-	.ops = &sock_filter_ops,
+static struct bpf_prog_type_list sk_filter_type __read_mostly = {
+	.ops = &sk_filter_ops,
 	.type = BPF_PROG_TYPE_SOCKET_FILTER,
 };
 
-static int __init register_sock_filter_ops(void)
+static int __init register_sk_filter_ops(void)
 {
-	bpf_register_prog_type(&sock_filter_type);
+	bpf_register_prog_type(&sk_filter_type);
 	return 0;
 }
-late_initcall(register_sock_filter_ops);
-#else
-int sk_attach_bpf(u32 ufd, struct sock *sk)
-{
-	return -EOPNOTSUPP;
-}
-#endif
+late_initcall(register_sk_filter_ops);
+
 int sk_detach_filter(struct sock *sk)
 {
 	int ret = -ENOENT;
-- 
1.9.3
