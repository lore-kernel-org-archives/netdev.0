From: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Subject: [PATCH v5 net-next 05/29] bpf: enable bpf syscall on x64 and i386
Date: Sun, 24 Aug 2014 13:21:06 -0700
Message-ID: <1408911690-7598-6-git-send-email-ast@plumgrid.com>
References: <1408911690-7598-1-git-send-email-ast@plumgrid.com>
Cc: Ingo Molnar <mingo-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Andy Lutomirski <luto-kltTT9wpgjJwATOyAt5JVQ@public.gmane.org>,
	Steven Rostedt <rostedt-nx8X9YLhiw1AfugRpC6u6w@public.gmane.org>,
	Daniel Borkmann <dborkman-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org>,
	Chema Gonzalez <chema-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Eric Dumazet <edumazet-hpIqsD4AKlfQT0dZR+AlfA@public.gmane.org>,
	Peter Zijlstra <a.p.zijlstra-/NLkJaSkS4VmR6Xm/wNWPw@public.gmane.org>,
	Brendan Gregg <brendan.d.gregg-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>,
	Namhyung Kim <namhyung-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
	"H. Peter Anvin" <hpa-YMNOUZJC4hwAvxtiuMwx3w@public.gmane.org>,
	Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
	Kees Cook <keescook-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>, linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: "David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1408911690-7598-1-git-send-email-ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

done as separate commit to ease conflict resolution

Signed-off-by: Alexei Starovoitov <ast-uqk4Ao+rVK5Wk0Htik3J/w@public.gmane.org>
---
 arch/x86/syscalls/syscall_32.tbl  |    1 +
 arch/x86/syscalls/syscall_64.tbl  |    1 +
 include/linux/syscalls.h          |    3 ++-
 include/uapi/asm-generic/unistd.h |    4 +++-
 kernel/sys_ni.c                   |    3 +++
 5 files changed, 10 insertions(+), 2 deletions(-)

diff --git a/arch/x86/syscalls/syscall_32.tbl b/arch/x86/syscalls/syscall_32.tbl
index 028b78168d85..9fe1b5d002f0 100644
--- a/arch/x86/syscalls/syscall_32.tbl
+++ b/arch/x86/syscalls/syscall_32.tbl
@@ -363,3 +363,4 @@
 354	i386	seccomp			sys_seccomp
 355	i386	getrandom		sys_getrandom
 356	i386	memfd_create		sys_memfd_create
+357	i386	bpf			sys_bpf
diff --git a/arch/x86/syscalls/syscall_64.tbl b/arch/x86/syscalls/syscall_64.tbl
index 35dd922727b9..281150b539a2 100644
--- a/arch/x86/syscalls/syscall_64.tbl
+++ b/arch/x86/syscalls/syscall_64.tbl
@@ -327,6 +327,7 @@
 318	common	getrandom		sys_getrandom
 319	common	memfd_create		sys_memfd_create
 320	common	kexec_file_load		sys_kexec_file_load
+321	common	bpf			sys_bpf
 
 #
 # x32-specific system call numbers start at 512 to avoid cache impact
diff --git a/include/linux/syscalls.h b/include/linux/syscalls.h
index 0f86d85a9ce4..61bc112b9fa5 100644
--- a/include/linux/syscalls.h
+++ b/include/linux/syscalls.h
@@ -875,5 +875,6 @@ asmlinkage long sys_seccomp(unsigned int op, unsigned int flags,
 			    const char __user *uargs);
 asmlinkage long sys_getrandom(char __user *buf, size_t count,
 			      unsigned int flags);
-
+asmlinkage long sys_bpf(int cmd, unsigned long arg2, unsigned long arg3,
+			unsigned long arg4, unsigned long arg5);
 #endif
diff --git a/include/uapi/asm-generic/unistd.h b/include/uapi/asm-generic/unistd.h
index 11d11bc5c78f..22749c134117 100644
--- a/include/uapi/asm-generic/unistd.h
+++ b/include/uapi/asm-generic/unistd.h
@@ -705,9 +705,11 @@ __SYSCALL(__NR_seccomp, sys_seccomp)
 __SYSCALL(__NR_getrandom, sys_getrandom)
 #define __NR_memfd_create 279
 __SYSCALL(__NR_memfd_create, sys_memfd_create)
+#define __NR_bpf 280
+__SYSCALL(__NR_bpf, sys_bpf)
 
 #undef __NR_syscalls
-#define __NR_syscalls 280
+#define __NR_syscalls 281
 
 /*
  * All syscalls below here should go away really,
diff --git a/kernel/sys_ni.c b/kernel/sys_ni.c
index 391d4ddb6f4b..b4b5083f5f5e 100644
--- a/kernel/sys_ni.c
+++ b/kernel/sys_ni.c
@@ -218,3 +218,6 @@ cond_syscall(sys_kcmp);
 
 /* operate on Secure Computing state */
 cond_syscall(sys_seccomp);
+
+/* access BPF programs and maps */
+cond_syscall(sys_bpf);
-- 
1.7.9.5
