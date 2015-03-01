From: Alexei Starovoitov <ast@plumgrid.com>
Subject: [PATCH v5 tip 1/7] bpf: make internal bpf API independent of CONFIG_BPF_SYSCALL ifdefs
Date: Sun,  1 Mar 2015 15:27:39 -0800
Message-ID: <1425252465-27527-2-git-send-email-ast@plumgrid.com>
References: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
Cc: Steven Rostedt <rostedt@goodmis.org>,
	Namhyung Kim <namhyung@kernel.org>,
	Arnaldo Carvalho de Melo <acme@infradead.org>,
	Jiri Olsa <jolsa@redhat.com>,
	Masami Hiramatsu <masami.hiramatsu.pt@hitachi.com>,
	"David S. Miller" <davem@davemloft.net>,
	Daniel Borkmann <daniel@iogearbox.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	linux-api@vger.kernel.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Ingo Molnar <mingo@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1425252465-27527-1-git-send-email-ast@plumgrid.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Daniel Borkmann <daniel@iogearbox.net>

Socket filter code and other subsystems with upcoming eBPF support should
not need to deal with the fact that we have CONFIG_BPF_SYSCALL defined or
not.

Having the bpf syscall as a config option is a nice thing and I'd expect
it to stay that way for expert users (I presume one day the default setting
of it might change, though), but code making use of it should not care if
it's actually enabled or not.

Instead, hide this via header files and let the rest deal with it.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
Signed-off-by: Alexei Starovoitov <ast@plumgrid.com>
---
 include/linux/bpf.h |   20 ++++++++++++++++----
 1 file changed, 16 insertions(+), 4 deletions(-)

diff --git a/include/linux/bpf.h b/include/linux/bpf.h
index bbfceb756452..c2e21113ecc0 100644
--- a/include/linux/bpf.h
+++ b/include/linux/bpf.h
@@ -113,8 +113,6 @@ struct bpf_prog_type_list {
 	enum bpf_prog_type type;
 };
 
-void bpf_register_prog_type(struct bpf_prog_type_list *tl);
-
 struct bpf_prog;
 
 struct bpf_prog_aux {
@@ -129,11 +127,25 @@ struct bpf_prog_aux {
 };
 
 #ifdef CONFIG_BPF_SYSCALL
+void bpf_register_prog_type(struct bpf_prog_type_list *tl);
+
 void bpf_prog_put(struct bpf_prog *prog);
+struct bpf_prog *bpf_prog_get(u32 ufd);
 #else
-static inline void bpf_prog_put(struct bpf_prog *prog) {}
+static inline void bpf_register_prog_type(struct bpf_prog_type_list *tl)
+{
+}
+
+static inline struct bpf_prog *bpf_prog_get(u32 ufd)
+{
+	return ERR_PTR(-EOPNOTSUPP);
+}
+
+static inline void bpf_prog_put(struct bpf_prog *prog)
+{
+}
 #endif
-struct bpf_prog *bpf_prog_get(u32 ufd);
+
 /* verify correctness of eBPF program */
 int bpf_check(struct bpf_prog *fp, union bpf_attr *attr);
 
-- 
1.7.9.5
