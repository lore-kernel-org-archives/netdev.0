From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next 1/4] net: filter: add a callback to allow classic post-verifier transformations
Date: Wed,  6 May 2015 16:12:27 +0200
Message-ID: <437e17ab5c2cc818d937432cc0397030ee64f916.1430908145.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Cc: ast@plumgrid.com, keescook@chromium.org, nschichan@freebox.fr,
	netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59826 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752604AbbEFOMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 6 May 2015 10:12:38 -0400
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
In-Reply-To: <cover.1430908145.git.daniel@iogearbox.net>
References: <cover.1430908145.git.daniel@iogearbox.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Nicolas Schichan <nschichan@freebox.fr>

This is in preparation for use by the seccomp code, the rationale is
not to duplicate additional code within the seccomp layer, but instead,
have it abstracted and hidden within the classic BPF API.

As an interim step, this now also makes bpf_prepare_filter() visible
(not as exported symbol though), so that seccomp can reuse that code
path instead of reimplementing it.

Joint work with Daniel Borkmann.

Signed-off-by: Nicolas Schichan <nschichan@freebox.fr>
Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
Cc: Kees Cook <keescook@chromium.org>
---
 include/linux/filter.h |  6 ++++++
 net/core/filter.c      | 18 +++++++++++++++---
 2 files changed, 21 insertions(+), 3 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index fa11b3a..9199624 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -384,7 +384,13 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
 int sk_detach_filter(struct sock *sk);
 
+typedef int (*bpf_aux_classic_check_t)(struct sock_filter *filter,
+				       unsigned int flen);
+
 int bpf_check_classic(const struct sock_filter *filter, unsigned int flen);
+struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
+				    bpf_aux_classic_check_t trans);
+
 int sk_get_filter(struct sock *sk, struct sock_filter __user *filter,
 		  unsigned int len);
 
diff --git a/net/core/filter.c b/net/core/filter.c
index bf831a8..e670494 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -988,7 +988,8 @@ out_err:
 	return ERR_PTR(err);
 }
 
-static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp)
+struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp,
+				    bpf_aux_classic_check_t trans)
 {
 	int err;
 
@@ -1001,6 +1002,17 @@ static struct bpf_prog *bpf_prepare_filter(struct bpf_prog *fp)
 		return ERR_PTR(err);
 	}
 
+	/* There might be additional checks and transformations
+	 * needed on classic filters, f.e. in case of seccomp.
+	 */
+	if (trans) {
+		err = trans(fp->insns, fp->len);
+		if (err) {
+			__bpf_prog_release(fp);
+			return ERR_PTR(err);
+		}
+	}
+
 	/* Probe if we can JIT compile the filter and if so, do
 	 * the compilation of the filter.
 	 */
@@ -1050,7 +1062,7 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog)
 	/* bpf_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
-	fp = bpf_prepare_filter(fp);
+	fp = bpf_prepare_filter(fp, NULL);
 	if (IS_ERR(fp))
 		return PTR_ERR(fp);
 
@@ -1135,7 +1147,7 @@ int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk)
 	/* bpf_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
-	prog = bpf_prepare_filter(prog);
+	prog = bpf_prepare_filter(prog, NULL);
 	if (IS_ERR(prog))
 		return PTR_ERR(prog);
 
-- 
1.9.3
