From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v2 2/5] seccomp: make underlying bpf ref counted as well
Date: Thu, 10 Sep 2015 18:20:59 -0600
Message-ID: <1441930862-14347-3-git-send-email-tycho.andersen@canonical.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
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
In-Reply-To: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

In the next patch, we're going to add a way to access the underlying
filters via bpf fds. This means that we need to ref-count both the
struct seccomp_filter objects and the struct bpf_prog objects separately,
in case a process dies but a filter is still referred to by another
process.

Additionally, we mark classic converted seccomp filters as seccomp eBPF
programs, since they are a subset of what is supported in seccomp eBPF.

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
 kernel/seccomp.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/kernel/seccomp.c b/kernel/seccomp.c
index 245df6b..afaeddf 100644
--- a/kernel/seccomp.c
+++ b/kernel/seccomp.c
@@ -378,6 +378,8 @@ static struct seccomp_filter *seccomp_prepare_filter(struct sock_fprog *fprog)
 	}
 
 	atomic_set(&sfilter->usage, 1);
+	atomic_set(&sfilter->prog->aux->refcnt, 1);
+	sfilter->prog->type = BPF_PROG_TYPE_SECCOMP;
 
 	return sfilter;
 }
@@ -470,7 +472,7 @@ void get_seccomp_filter(struct task_struct *tsk)
 static inline void seccomp_filter_free(struct seccomp_filter *filter)
 {
 	if (filter) {
-		bpf_prog_free(filter->prog);
+		bpf_prog_put(filter->prog);
 		kfree(filter);
 	}
 }
-- 
2.1.4
