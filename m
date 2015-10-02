From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf, seccomp: prepare for upcoming criu support
Date: Fri,  2 Oct 2015 15:17:33 +0200
Message-ID: <65c43ff26bd4f37c268d2aad7b8d368edfd42200.1443789826.git.daniel@iogearbox.net>
Cc: netdev@vger.kernel.org, Daniel Borkmann <daniel@iogearbox.net>,
	Tycho Andersen <tycho.andersen@canonical.com>,
	Pavel Emelyanov <xemul@parallels.com>,
	Kees Cook <keescook@chromium.org>,
	Andy Lutomirski <luto@amacapital.net>,
	Alexei Starovoitov <ast@plumgrid.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:59280 "EHLO
	www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752035AbbJBNRo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 2 Oct 2015 09:17:44 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The current ongoing effort to dump existing cBPF seccomp filters back
to user space requires to hold the pre-transformed instructions like
we do in case of socket filters from sk_attach_filter() side, so they
can be reloaded in original form at a later point in time by utilities
such as criu.

To prepare for this, simply extend the bpf_prog_create_from_user()
API to hold a flag that tells whether we should store the original
or not. Also, fanout filters could make use of that in future for
things like diag. While fanout filters already use bpf_prog_destroy(),
move seccomp over to them as well to handle original programs when
present.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Cc: Tycho Andersen <tycho.andersen@canonical.com>
Cc: Pavel Emelyanov <xemul@parallels.com>
Cc: Kees Cook <keescook@chromium.org>
Cc: Andy Lutomirski <luto@amacapital.net>
Cc: Alexei Starovoitov <ast@plumgrid.com>
---
 This is in realtion to Tycho's latest patch set under [1]. The BPF
 handling is unfortunately not correct (triggering a crash on kernels
 that can set pages as ro).

 This patch here provides a minimal, simple interface from BPF API side
 as a possible step forward, so that the focus can then be on seccomp
 side wrt criu. F.e., dumping could happen similarly as in Pavel's
 sk_get_filter().

 I have tested/based this against net-next, but have no issues whether
 Kees wants to take it, or whether it should go through both trees to
 reduce merge issues as once the case with 0fc174dea545 ("ebpf: make
 internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs").

 Thanks!

 [1] http://thread.gmane.org/gmane.linux.network/380300

 include/linux/filter.h |  2 +-
 kernel/seccomp.c       |  4 ++--
 net/core/filter.c      | 16 +++++++++++-----
 net/packet/af_packet.c |  2 +-
 4 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index fa2cab9..1f0f7bf 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -408,7 +408,7 @@ typedef int (*bpf_aux_classic_check_t)(struct sock_filter *filter,
 
 int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
 int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
-			      bpf_aux_classic_check_t trans);
+			      bpf_aux_classic_check_t trans, bool save_orig);
 void bpf_prog_destroy(struct bpf_prog *fp);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 5bd4779..06858a7 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -370,7 +370,7 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 		return ERR_PTR(-ENOMEM);
 
 	ret = bpf_prog_create_from_user(&sfilter->prog, fprog,
-					seccomp_check_filter);
+					seccomp_check_filter, false);
 	if (ret < 0) {
 		kfree(sfilter);
 		return ERR_PTR(ret);
@@ -469,7 +469,7 @@ void get_seccomp_filter(struct task_struct *tsk)
 static inline void seccomp_filter_free(struct seccomp_filter *filter)
 {
 	if (filter) {
-		bpf_prog_free(filter->prog);
+		bpf_prog_destroy(filter->prog);
 		kfree(filter);
 	}
 }
diff --git a/net/core/filter.c b/net/core/filter.c
index 60e3fe7..9cf09ed 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1083,16 +1083,18 @@ EXPORT_SYMBOL_GPL(bpf_prog_create);
  *	@pfp: the unattached filter that is created
  *	@fprog: the filter program
  *	@trans: post-classic verifier transformation handler
+ *	@save_orig: save classic BPF program
  *
  * This function effectively does the same as bpf_prog_create(), only
  * that it builds up its insns buffer from user space provided buffer.
  * It also allows for passing a bpf_aux_classic_check_t handler.
  */
 int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
-			      bpf_aux_classic_check_t trans)
+			      bpf_aux_classic_check_t trans, bool save_orig)
 {
 	unsigned int fsize = bpf_classic_proglen(fprog);
 	struct bpf_prog *fp;
+	int err;
 
 	/* Make sure new filter is there and in the right amounts. */
 	if (fprog->filter == NULL)
@@ -1108,12 +1110,16 @@ int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 	}
 
 	fp->len = fprog->len;
-	/* Since unattached filters are not copied back to user
-	 * space through sk_get_filter(), we do not need to hold
-	 * a copy here, and can spare us the work.
-	 */
 	fp->orig_prog = NULL;
 
+	if (save_orig) {
+		err = bpf_prog_store_orig_filter(fp, fprog);
+		if (err) {
+			__bpf_prog_free(fp);
+			return -ENOMEM;
+		}
+	}
+
 	/* bpf_prepare_filter() already takes care of freeing
 	 * memory in case something goes wrong.
 	 */
diff --git a/net/packet/af_packet.c b/net/packet/af_packet.c
index aa4b15c..81c900f 100644
--- a/net/packet/af_packet.c
+++ b/net/packet/af_packet.c
@@ -1567,7 +1567,7 @@ static int fanout_set_data_cbpf(struct packet_sock *po, char __user *data,
 	if (copy_from_user(&fprog, data, len))
 		return -EFAULT;
 
-	ret = bpf_prog_create_from_user(&new, &fprog, NULL);
+	ret = bpf_prog_create_from_user(&new, &fprog, NULL, false);
 	if (ret)
 		return ret;
 
-- 
1.9.3
