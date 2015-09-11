From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2 1/5] ebpf: add a seccomp program type
Date: Thu, 10 Sep 2015 18:20:58 -0600
Message-ID: <1441930862-14347-2-git-send-email-tycho.andersen@canonical.com>
References: <1441930862-14347-1-git-send-email-tycho.andersen@canonical.com>
Cc: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>,
	"Serge E. Hallyn" <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>,
	Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>,
	linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
To: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>,
	Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1441930862-14347-1-git-send-email-tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

seccomp uses eBPF as its underlying storage and execution format, and eBPF
has features that seccomp would like to make use of in the future. This
patch adds a formal seccomp type to the eBPF verifier.

The current implementation of the seccomp eBPF type is very limited, and
doesn't support some interesting features (notably, maps) of eBPF. However,
the primary motivation for this patchset is to enable checkpoint/restore
for seccomp filters later in the series, to this limited feature set is ok
for now.

v2: * don't allow seccomp eBPF programs to call any functions
    * get rid of superfluous seccomp_convert_ctx_access

Signed-off-by: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
CC: Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Will Drewry <wad-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
CC: Oleg Nesterov <oleg-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>
CC: Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>
CC: Pavel Emelyanov <xemul-bzQdu9zFT3WakBO8gow8eQ@public.gmane.org>
CC: Serge E. Hallyn <serge.hallyn-GeWIH/nMZzLQT0dZR+AlfA@public.gmane.org>
CC: Alexei Starovoitov <ast-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>
CC: Daniel Borkmann <daniel-FeC+5ew28dpmcu3hnIyYJQ@public.gmane.org>
---
 include/uapi/linux/bpf.h |  1 +
 net/core/filter.c        | 31 +++++++++++++++++++++++++++++++
 2 files changed, 32 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 92a48e2..631cdee 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -123,6 +123,7 @@ enum bpf_prog_type {
 	BPF_PROG_TYPE_KPROBE,
 	BPF_PROG_TYPE_SCHED_CLS,
 	BPF_PROG_TYPE_SCHED_ACT,
+	BPF_PROG_TYPE_SECCOMP,
 };
 
 #define BPF_PSEUDO_MAP_FD	1
diff --git a/net/core/filter.c b/net/core/filter.c
index 13079f0..faaae67 100644
--- a/net/core/filter.c
+++ b/net/core/filter.c
@@ -1612,6 +1612,15 @@ tc_cls_act_func_proto(enum bpf_func_id func_id)
 	}
 }
 
+static const struct bpf_func_proto *
+seccomp_func_proto(enum bpf_func_id func_id)
+{
+	/* At some point in the future seccomp filters may grow support for
+	 * eBPF functions. For now, these are disabled.
+	 */
+	return NULL;
+}
+
 static bool __is_valid_access(int off, int size, enum bpf_access_type type)
 {
 	/* check bounds */
@@ -1662,6 +1671,17 @@ static bool tc_cls_act_is_valid_access(int off, int size,
 	return __is_valid_access(off, size, type);
 }
 
+static bool seccomp_is_valid_access(int off, int size,
+				    enum bpf_access_type type)
+{
+	if (type == BPF_WRITE)
+		return false;
+
+	if (off < 0 || off >= sizeof(struct seccomp_data) || off & 3)
+		return false;
+
+	return true;
+}
 static u32 bpf_net_convert_ctx_access(enum bpf_access_type type, int dst_reg,
 				      int src_reg, int ctx_off,
 				      struct bpf_insn *insn_buf)
@@ -1795,6 +1815,11 @@ static const struct bpf_verifier_ops tc_cls_act_ops = {
 	.convert_ctx_access = bpf_net_convert_ctx_access,
 };
 
+static const struct bpf_verifier_ops seccomp_ops = {
+	.get_func_proto = seccomp_func_proto,
+	.is_valid_access = seccomp_is_valid_access,
+};
+
 static struct bpf_prog_type_list sk_filter_type __read_mostly = {
 	.ops = &sk_filter_ops,
 	.type = BPF_PROG_TYPE_SOCKET_FILTER,
@@ -1810,11 +1835,17 @@ static struct bpf_prog_type_list sched_act_type __read_mostly = {
 	.type = BPF_PROG_TYPE_SCHED_ACT,
 };
 
+static struct bpf_prog_type_list seccomp_type __read_mostly = {
+	.ops = &seccomp_ops,
+	.type = BPF_PROG_TYPE_SECCOMP,
+};
+
 static int __init register_sk_filter_ops(void)
 {
 	bpf_register_prog_type(&sk_filter_type);
 	bpf_register_prog_type(&sched_cls_type);
 	bpf_register_prog_type(&sched_act_type);
+	bpf_register_prog_type(&seccomp_type);
 
 	return 0;
 }
-- 
2.1.4
