From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v3 1/5] seccomp: save the original filter
Date: Wed, 30 Sep 2015 12:13:36 -0600
Message-ID: <1443636820-17083-2-git-send-email-tycho.andersen@canonical.com>
References: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Cc: Will Drewry <wad@chromium.org>, Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>,
	Alexei Starovoitov <ast@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443636820-17083-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In order to implement checkpoint of seccomp filters, we need to keep track
of the original filter as the user gave it to us. Since we're doing this,
we need to also use bpf_prog_destroy to free the struct bpf_brogs so we
don't leak this memory.

Signed-off-by: Tycho Andersen <tycho.andersen@canonical.com>
CC: Kees Cook <keescook@chromium.org>
CC: Will Drewry <wad@chromium.org>
CC: Oleg Nesterov <oleg@redhat.com>
CC: Andy Lutomirski <luto@amacapital.net>
CC: Pavel Emelyanov <xemul@parallels.com>
CC: Serge E. Hallyn <serge.hallyn@ubuntu.com>
CC: Alexei Starovoitov <ast@kernel.org>
CC: Daniel Borkmann <daniel@iogearbox.net>
---
 include/linux/filter.h |  2 ++
 kernel/seccomp.c       | 24 ++++++++++++++++--------
 net/core/filter.c      |  4 ++--
 3 files changed, 20 insertions(+), 10 deletions(-)

diff --git a/include/linux/filter.h b/include/linux/filter.h
index fa2cab9..6c045ba 100644
--- a/include/linux/filter.h
+++ b/include/linux/filter.h
@@ -410,6 +410,8 @@ int bpf_prog_create(struct bpf_prog **pfp, struct sock_fprog_kern *fprog);
 int bpf_prog_create_from_user(struct bpf_prog **pfp, struct sock_fprog *fprog,
 			      bpf_aux_classic_check_t trans);
 void bpf_prog_destroy(struct bpf_prog *fp);
+int bpf_prog_store_orig_filter(struct bpf_prog *fp,
+			       const struct sock_fprog *fprog);
 
 int sk_attach_filter(struct sock_fprog *fprog, struct sock *sk);
 int sk_attach_bpf(u32 ufd, struct sock *sk);
diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 5bd4779..09f3769 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -337,6 +337,14 @@ static inline void seccomp_sync_threads(void)
 	}
 }
 
+static inline void seccomp_filter_free(struct seccomp_filter *filter)
+{
+	if (filter) {
+		bpf_prog_destroy(filter->prog);
+		kfree(filter);
+	}
+}
+
 /**
  * seccomp_prepare_filter: Prepares a seccomp filter for use.
  * @fprog: BPF program to install
@@ -376,6 +384,14 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 		return ERR_PTR(ret);
 	}
 
+	if (config_enabled(CONFIG_CHECKPOINT_RESTORE)) {
+		ret = bpf_prog_store_orig_filter(sfilter->prog, fprog);
+		if (ret < 0) {
+			seccomp_filter_free(sfilter);
+			return ERR_PTR(ret);
+		}
+	}
+
 	atomic_set(&sfilter->usage, 1);
 
 	return sfilter;
@@ -466,14 +482,6 @@ void get_seccomp_filter(struct task_struct *tsk)
 	atomic_inc(&orig->usage);
 }
 
-static inline void seccomp_filter_free(struct seccomp_filter *filter)
-{
-	if (filter) {
-		bpf_prog_free(filter->prog);
-		kfree(filter);
-	}
-}
-
 /* put_seccomp_filter - decrements the ref count of tsk->seccomp.filter */
 void put_seccomp_filter(struct task_struct *tsk)
 {
diff --git a/net/core/filter.c b/net/core/filter.c
index 13079f0..70995dd 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -832,8 +832,8 @@ static int bpf_check_classic(const struct sock_filter *filter,
 	return -EINVAL;
 }
 
-static int bpf_prog_store_orig_filter(struct bpf_prog *fp,
-				      const struct sock_fprog *fprog)
+int bpf_prog_store_orig_filter(struct bpf_prog *fp,
+			       const struct sock_fprog *fprog)
 {
 	unsigned int fsize = bpf_classic_proglen(fprog);
 	struct sock_fprog_kern *fkprog;
-- 
2.5.0
