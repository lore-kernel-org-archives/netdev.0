From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 2/2] bpf: refactor bpf_prog_get and type check into helper
Date: Thu, 30 Jun 2016 17:24:44 +0200
Message-ID: <52f4727f0771d43bfde5b3588444fef4d40ca3fb.1467298256.git.daniel@iogearbox.net>
References: <cover.1467298256.git.daniel@iogearbox.net>
Cc: alexei.starovoitov@gmail.com, jannh@google.com,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:48320 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932448AbcF3PZG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 30 Jun 2016 11:25:06 -0400
In-Reply-To: <cover.1467298256.git.daniel@iogearbox.net>
In-Reply-To: <cover.1467298256.git.daniel@iogearbox.net>
References: <cover.1467298256.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Since bpf_prog_get() and program type check is used in a couple of places,
refactor this into a small helper function that we can make use of. Since
the non RO prog->aux part is not used in performance critical paths and a
program destruction via RCU is rather very unlikley when doing the put, we
shouldn't have an issue just doing the bpf_prog_get() + prog->type != type
check, but actually not taking the ref at all (due to being in fdget() /
fdput() section of the bpf fd) is even cleaner and makes the diff smaller
as well, so just go for that. Callsites are changed to make use of the new
helper where possible.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Acked-by: Alexei Starovoitov <ast@kernel.org>
---
 include/linux/bpf.h    |  7 +++++++
 kernel/bpf/syscall.c   | 27 +++++++++++++++++++--------
 net/core/filter.c      | 13 +------------
 net/kcm/kcmsock.c      |  8 +-------
 net/packet/af_packet.c |  6 +-----
 net/sched/act_bpf.c    |  7 +------
 net/sched/cls_bpf.c    |  7 +------
 7 files changed, 31 insertions(+), 44 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index 7495498..b3336b4 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -218,6 +218,7 @@ void bpf_register_prog_type(struct bpf_prog_type_list *tl);
 void bpf_register_map_type(struct bpf_map_type_list *tl);
 
 struct bpf_prog *bpf_prog_get(u32 ufd);
+struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type);
 struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog);
 void bpf_prog_put(struct bpf_prog *prog);
 
@@ -277,6 +278,12 @@ static inline struct bpf_prog *bpf_prog_get(u32 ufd)
 	return ERR_PTR(-EOPNOTSUPP);
 }
 
+static inline struct bpf_prog *bpf_prog_get_type(u32 ufd,
+						 enum bpf_prog_type type)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
 static inline void bpf_prog_put(struct bpf_prog *prog)
 {
 }
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index f6806a1..22863d9 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -657,7 +657,7 @@ int bpf_prog_new_fd(struct bpf_prog *prog)
 				O_RDWR | O_CLOEXEC);
 }
 
-static struct bpf_prog *__bpf_prog_get(struct fd f)
+static struct bpf_prog *____bpf_prog_get(struct fd f)
 {
 	if (!f.file)
 		return ERR_PTR(-EBADF);
@@ -678,24 +678,35 @@ struct bpf_prog *bpf_prog_inc(struct bpf_prog *prog)
 	return prog;
 }
 
-/* called by sockets/tracing/seccomp before attaching program to an event
- * pairs with bpf_prog_put()
- */
-struct bpf_prog *bpf_prog_get(u32 ufd)
+static struct bpf_prog *__bpf_prog_get(u32 ufd, enum bpf_prog_type *type)
 {
 	struct fd f = fdget(ufd);
 	struct bpf_prog *prog;
 
-	prog = __bpf_prog_get(f);
+	prog = ____bpf_prog_get(f);
 	if (IS_ERR(prog))
 		return prog;
+	if (type && prog->type != *type) {
+		prog = ERR_PTR(-EINVAL);
+		goto out;
+	}
 
 	prog = bpf_prog_inc(prog);
+out:
 	fdput(f);
-
 	return prog;
 }
-EXPORT_SYMBOL_GPL(bpf_prog_get);
+
+struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	return __bpf_prog_get(ufd, NULL);
+}
+
+struct bpf_prog *bpf_prog_get_type(u32 ufd, enum bpf_prog_type type)
+{
+	return __bpf_prog_get(ufd, &type);
+}
+EXPORT_SYMBOL_GPL(bpf_prog_get_type);
 
 /* last field in 'union bpf_attr' used by this command */
 #define	BPF_PROG_LOAD_LAST_FIELD kern_version
diff --git a/net/core/filter.c b/net/core/filter.c
index 76f9a49..76fee35 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1301,21 +1301,10 @@ int sk_reuseport_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 
 static struct bpf_prog *__get_bpf(u32 ufd, struct sock *sk)
 {
-	struct bpf_prog *prog;
-
 	if (sock_flag(sk, SOCK_FILTER_LOCKED))
 		return ERR_PTR(-EPERM);
 
-	prog = bpf_prog_get(ufd);
-	if (IS_ERR(prog))
-		return prog;
-
-	if (prog->type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		bpf_prog_put(prog);
-		return ERR_PTR(-EINVAL);
-	}
-
-	return prog;
+	return bpf_prog_get_type(ufd, BPF_PROG_TYPE_SOCKET_FILTER);
 }
 
 int sk_attach_bpf(u32 ufd, struct sock *sk)
diff --git a/net/kcm/kcmsock.c b/net/kcm/kcmsock.c
index 0b68ba7..cb39e05 100644
--- a/net/kcm/kcmsock.c
+++ b/net/kcm/kcmsock.c
@@ -1765,18 +1765,12 @@ static int kcm_attach_ioctl(struct socket *sock, struct kcm_attach *info)
 	if (!csock)
 		return -ENOENT;
 
-	prog = bpf_prog_get(info->bpf_fd);
+	prog = bpf_prog_get_type(info->bpf_fd, BPF_PROG_TYPE_SOCKET_FILTER);
 	if (IS_ERR(prog)) {
 		err = PTR_ERR(prog);
 		goto out;
 	}
 
-	if (prog->type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		bpf_prog_put(prog);
-		err = -EINVAL;
-		goto out;
-	}
-
 	err = kcm_attach(sock, csock, prog);
 	if (err) {
 		bpf_prog_put(prog);
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index d1f3b9e..48b5895 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1588,13 +1588,9 @@ static int fanout_set_data_ebpf(struct packet_sock *po, char __user *data,
 	if (copy_from_user(&fd, data, len))
 		return -EFAULT;
 
-	new = bpf_prog_get(fd);
+	new = bpf_prog_get_type(fd, BPF_PROG_TYPE_SOCKET_FILTER);
 	if (IS_ERR(new))
 		return PTR_ERR(new);
-	if (new->type != BPF_PROG_TYPE_SOCKET_FILTER) {
-		bpf_prog_put(new);
-		return -EINVAL;
-	}
 
 	__fanout_set_data_bpf(po->fanout, new);
 	return 0;
diff --git a/net/sched/act_bpf.c b/net/sched/act_bpf.c
index f7b6cf4..ef74bff 100644
--- a/net/sched/act_bpf.c
+++ b/net/sched/act_bpf.c
@@ -223,15 +223,10 @@ static int tcf_bpf_init_from_efd(struct nlattr **tb, struct tcf_bpf_cfg *cfg)
 
 	bpf_fd = nla_get_u32(tb[TCA_ACT_BPF_FD]);
 
-	fp = bpf_prog_get(bpf_fd);
+	fp = bpf_prog_get_type(bpf_fd, BPF_PROG_TYPE_SCHED_ACT);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
-	if (fp->type != BPF_PROG_TYPE_SCHED_ACT) {
-		bpf_prog_put(fp);
-		return -EINVAL;
-	}
-
 	if (tb[TCA_ACT_BPF_NAME]) {
 		name = kmemdup(nla_data(tb[TCA_ACT_BPF_NAME]),
 			       nla_len(tb[TCA_ACT_BPF_NAME]),
diff --git a/net/sched/cls_bpf.c b/net/sched/cls_bpf.c
index 7b342c7..c3002c2 100644
--- a/net/sched/cls_bpf.c
+++ b/net/sched/cls_bpf.c
@@ -272,15 +272,10 @@ static int cls_bpf_prog_from_efd(struct nlattr **tb, struct cls_bpf_prog *prog,
 
 	bpf_fd = nla_get_u32(tb[TCA_BPF_FD]);
 
-	fp = bpf_prog_get(bpf_fd);
+	fp = bpf_prog_get_type(bpf_fd, BPF_PROG_TYPE_SCHED_CLS);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
-	if (fp->type != BPF_PROG_TYPE_SCHED_CLS) {
-		bpf_prog_put(fp);
-		return -EINVAL;
-	}
-
 	if (tb[TCA_BPF_NAME]) {
 		name = kmemdup(nla_data(tb[TCA_BPF_NAME]),
 			       nla_len(tb[TCA_BPF_NAME]),
-- 
1.9.3
