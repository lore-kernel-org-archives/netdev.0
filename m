From: Tycho Andersen <tycho.andersen-Z7WLFzj8eWMS+FvcfC7Uqw@public.gmane.org>
Subject: [PATCH v2 3/5] ebpf: add a way to dump an eBPF program
Date: Thu, 10 Sep 2015 18:21:00 -0600
Message-ID: <1441930862-14347-4-git-send-email-tycho.andersen@canonical.com>
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

This commit adds a way to dump eBPF programs. The initial implementation
doesn't support maps, and therefore only allows dumping seccomp ebpf
programs which themselves don't currently support maps.

v2: don't export a prog_id for the filter

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
 include/uapi/linux/bpf.h | 14 ++++++++++++++
 kernel/bpf/syscall.c     | 41 +++++++++++++++++++++++++++++++++++++++++
 2 files changed, 55 insertions(+)

diff --git a/include/uapi/linux/bpf.h b/include/uapi/linux/bpf.h
index 631cdee..e037a76 100644
--- a/include/uapi/linux/bpf.h
+++ b/include/uapi/linux/bpf.h
@@ -107,6 +107,13 @@ enum bpf_cmd {
 	 * returns fd or negative error
 	 */
 	BPF_PROG_LOAD,
+
+	/* dump an existing bpf
+	 * err = bpf(BPF_PROG_DUMP, union bpf_attr *attr, u32 size)
+	 * Using attr->prog_fd, attr->dump_insn_cnt, attr->dump_insns
+	 * returns zero or negative error
+	 */
+	BPF_PROG_DUMP,
 };
 
 enum bpf_map_type {
@@ -161,6 +168,13 @@ union bpf_attr {
 		__aligned_u64	log_buf;	/* user supplied buffer */
 		__u32		kern_version;	/* checked when prog_type=kprobe */
 	};
+
+	struct { /* anonymous struct used by BPF_PROG_DUMP command */
+		__u32		prog_fd;
+		__u32		dump_insn_cnt;
+		__aligned_u64	dump_insns;	/* user supplied buffer */
+		__u8		gpl_compatible;
+	};
 } __attribute__((aligned(8)));
 
 /* integer value in 'imm' field of BPF_CALL instruction selects which helper
diff --git a/kernel/bpf/syscall.c b/kernel/bpf/syscall.c
index dc9b464..58ae9f4 100644
--- a/kernel/bpf/syscall.c
+++ b/kernel/bpf/syscall.c
@@ -586,6 +586,44 @@ free_prog:
 	return err;
 }
 
+static int bpf_prog_dump(union bpf_attr *attr, union bpf_attr __user *uattr)
+{
+	int ufd = attr->prog_fd;
+	struct fd f = fdget(ufd);
+	struct bpf_prog *prog;
+	int ret = -EINVAL;
+
+	prog = get_prog(f);
+	if (IS_ERR(prog))
+		return PTR_ERR(prog);
+
+	/* For now, let's refuse to dump anything that isn't a seccomp program.
+	 * Other program types have support for maps, which our current dump
+	 * code doesn't support.
+	 */
+	if (prog->type != BPF_PROG_TYPE_SECCOMP)
+		goto out;
+
+	ret = -EFAULT;
+	if (put_user(prog->len, &uattr->dump_insn_cnt))
+		goto out;
+
+	if (put_user((u8) prog->gpl_compatible, &uattr->gpl_compatible))
+		goto out;
+
+	if (attr->dump_insns) {
+		u32 len = prog->len * sizeof(struct bpf_insn);
+
+		if (copy_to_user(u64_to_ptr(attr->dump_insns),
+				 prog->insns, len) != 0)
+			goto out;
+	}
+
+	ret = 0;
+out:
+	return ret;
+}
+
 SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, size)
 {
 	union bpf_attr attr = {};
@@ -650,6 +688,9 @@ SYSCALL_DEFINE3(bpf, int, cmd, union bpf_attr __user *, uattr, unsigned int, siz
 	case BPF_PROG_LOAD:
 		err = bpf_prog_load(&attr);
 		break;
+	case BPF_PROG_DUMP:
+		err = bpf_prog_dump(&attr, uattr);
+		break;
 	default:
 		err = -EINVAL;
 		break;
-- 
2.1.4
