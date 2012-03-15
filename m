From: Will Drewry <wad@chromium.org>
Subject: [PATCH v15 09/13] signal, x86: add SIGSYS info and make it synchronous.
Date: Wed, 14 Mar 2012 22:12:01 -0500
Message-ID: <1331781125-15658-10-git-send-email-wad@chromium.org>
References: <1331781125-15658-1-git-send-email-wad@chromium.org>
Reply-To: kernel-hardening@lists.openwall.com
Cc: linux-arch@vger.kernel.org,
	linux-doc@vger.kernel.org,
	kernel-hardening@lists.openwall.com,
	netdev@vger.kernel.org,
	x86@kernel.org,
	arnd@arndb.de,
	davem@davemloft.net,
	hpa@zytor.com,
	mingo@redhat.com,
	oleg@redhat.com,
	peterz@infradead.org,
	rdunlap@xenotime.net,
	mcgrathr@chromium.org,
	tglx@linutronix.de,
	luto@mit.edu,
	eparis@redhat.com,
	serge.hallyn@canonical.com,
	djm@mindrot.org,
	scarybeasts@gmail.com,
	indan@nul.nu,
	pmoore@redhat.com,
	akpm@linux-foundation.org,
	corbet@lwn.net,
	eric.dumazet@gmail.com,
	markus@chromium.org,
	coreyb@linux.vnet.ibm.com,
	keescook@chromium.org,
	Will Drewry <wad@chromium.org>
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-1132-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1331781125-15658-1-git-send-email-wad@chromium.org>
List-Id: netdev.vger.kernel.org

This change enables SIGSYS, defines _sigfields._sigsys, and adds
x86 (compat) arch support.  _sigsys defines fields which allow
a signal handler to receive the triggering system call number,
the relevant AUDIT_ARCH_* value for that number, and the address
of the callsite.

SIGSYS is added to the SYNCHRONOUS_MASK because it is desirable for it
to have setup_frame() called for it. The goal is to ensure that
ucontext_t reflects the machine state from the time-of-syscall and not
from another signal handler.

The first consumer of SIGSYS would be seccomp filter.  In particular,
a filter program could specify a new return value, SECCOMP_RET_TRAP,
which would result in the system call being denied and the calling
thread signaled.  This also means that implementing arch-specific
support can be dependent upon HAVE_ARCH_SECCOMP_FILTER.

v14: - rebase/nochanges
v13: - rebase on to 88ebdda6159ffc15699f204c33feb3e431bf9bdc
v12: - reworded changelog (oleg@redhat.com)
v11: - fix dropped words in the change description
     - added fallback copy_siginfo support.
     - added __ARCH_SIGSYS define to allow stepped arch support.
v10: - first version based on suggestion

Acked-by: Serge Hallyn <serge.hallyn@canonical.com>
Suggested-by: H. Peter Anvin <hpa@zytor.com>
Signed-off-by: Will Drewry <wad@chromium.org>
---
 arch/x86/ia32/ia32_signal.c   |    4 ++++
 arch/x86/include/asm/ia32.h   |    6 ++++++
 include/asm-generic/siginfo.h |   22 ++++++++++++++++++++++
 kernel/signal.c               |    9 ++++++++-
 4 files changed, 40 insertions(+), 1 deletions(-)

diff --git a/arch/x86/ia32/ia32_signal.c b/arch/x86/ia32/ia32_signal.c
index 6557769..c81d2c7 100644
--- a/arch/x86/ia32/ia32_signal.c
+++ b/arch/x86/ia32/ia32_signal.c
@@ -73,6 +73,10 @@ int copy_siginfo_to_user32(compat_siginfo_t __user *to, siginfo_t *from)
 			switch (from->si_code >> 16) {
 			case __SI_FAULT >> 16:
 				break;
+			case __SI_SYS >> 16:
+				put_user_ex(from->si_syscall, &to->si_syscall);
+				put_user_ex(from->si_arch, &to->si_arch);
+				break;
 			case __SI_CHLD >> 16:
 				put_user_ex(from->si_utime, &to->si_utime);
 				put_user_ex(from->si_stime, &to->si_stime);
diff --git a/arch/x86/include/asm/ia32.h b/arch/x86/include/asm/ia32.h
index 1f7e625..541485f 100644
--- a/arch/x86/include/asm/ia32.h
+++ b/arch/x86/include/asm/ia32.h
@@ -126,6 +126,12 @@ typedef struct compat_siginfo {
 			int _band;	/* POLL_IN, POLL_OUT, POLL_MSG */
 			int _fd;
 		} _sigpoll;
+
+		struct {
+			unsigned int _call_addr; /* calling insn */
+			int _syscall;	/* triggering system call number */
+			unsigned int _arch;	/* AUDIT_ARCH_* of syscall */
+		} _sigsys;
 	} _sifields;
 } compat_siginfo_t;
 
diff --git a/include/asm-generic/siginfo.h b/include/asm-generic/siginfo.h
index 0dd4e87..31306f5 100644
--- a/include/asm-generic/siginfo.h
+++ b/include/asm-generic/siginfo.h
@@ -90,9 +90,18 @@ typedef struct siginfo {
 			__ARCH_SI_BAND_T _band;	/* POLL_IN, POLL_OUT, POLL_MSG */
 			int _fd;
 		} _sigpoll;
+
+		/* SIGSYS */
+		struct {
+			void __user *_call_addr; /* calling insn */
+			int _syscall;	/* triggering system call number */
+			unsigned int _arch;	/* AUDIT_ARCH_* of syscall */
+		} _sigsys;
 	} _sifields;
 } siginfo_t;
 
+/* If the arch shares siginfo, then it has SIGSYS. */
+#define __ARCH_SIGSYS
 #endif
 
 /*
@@ -116,6 +125,11 @@ typedef struct siginfo {
 #define si_addr_lsb	_sifields._sigfault._addr_lsb
 #define si_band		_sifields._sigpoll._band
 #define si_fd		_sifields._sigpoll._fd
+#ifdef __ARCH_SIGSYS
+#define si_call_addr	_sifields._sigsys._call_addr
+#define si_syscall	_sifields._sigsys._syscall
+#define si_arch		_sifields._sigsys._arch
+#endif
 
 #ifdef __KERNEL__
 #define __SI_MASK	0xffff0000u
@@ -126,6 +140,7 @@ typedef struct siginfo {
 #define __SI_CHLD	(4 << 16)
 #define __SI_RT		(5 << 16)
 #define __SI_MESGQ	(6 << 16)
+#define __SI_SYS	(7 << 16)
 #define __SI_CODE(T,N)	((T) | ((N) & 0xffff))
 #else
 #define __SI_KILL	0
@@ -135,6 +150,7 @@ typedef struct siginfo {
 #define __SI_CHLD	0
 #define __SI_RT		0
 #define __SI_MESGQ	0
+#define __SI_SYS	0
 #define __SI_CODE(T,N)	(N)
 #endif
 
@@ -232,6 +248,12 @@ typedef struct siginfo {
 #define NSIGPOLL	6
 
 /*
+ * SIGSYS si_codes
+ */
+#define SYS_SECCOMP		(__SI_SYS|1)	/* seccomp triggered */
+#define NSIGSYS	1
+
+/*
  * sigevent definitions
  * 
  * It seems likely that SIGEV_THREAD will have to be handled from 
diff --git a/kernel/signal.c b/kernel/signal.c
index c73c428..15a9e9b 100644
--- a/kernel/signal.c
+++ b/kernel/signal.c
@@ -160,7 +160,7 @@ void recalc_sigpending(void)
 
 #define SYNCHRONOUS_MASK \
 	(sigmask(SIGSEGV) | sigmask(SIGBUS) | sigmask(SIGILL) | \
-	 sigmask(SIGTRAP) | sigmask(SIGFPE))
+	 sigmask(SIGTRAP) | sigmask(SIGFPE) | sigmask(SIGSYS))
 
 int next_signal(struct sigpending *pending, sigset_t *mask)
 {
@@ -2686,6 +2686,13 @@ int copy_siginfo_to_user(siginfo_t __user *to, siginfo_t *from)
 		err |= __put_user(from->si_uid, &to->si_uid);
 		err |= __put_user(from->si_ptr, &to->si_ptr);
 		break;
+#ifdef __ARCH_SIGSYS
+	case __SI_SYS:
+		err |= __put_user(from->si_call_addr, &to->si_call_addr);
+		err |= __put_user(from->si_syscall, &to->si_syscall);
+		err |= __put_user(from->si_arch, &to->si_arch);
+		break;
+#endif
 	default: /* this is just in case for now ... */
 		err |= __put_user(from->si_pid, &to->si_pid);
 		err |= __put_user(from->si_uid, &to->si_uid);
-- 
1.7.5.4
