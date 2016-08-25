From: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>
Subject: [RFC v2 07/10] landlock: Add errno check
Date: Thu, 25 Aug 2016 12:32:42 +0200
Message-ID: <1472121165-29071-8-git-send-email-mic@digikod.net>
References: <1472121165-29071-1-git-send-email-mic@digikod.net>
Reply-To: kernel-hardening@lists.openwall.com
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8bit
Cc: =?UTF-8?q?Micka=C3=ABl=20Sala=C3=BCn?= <mic@digikod.net>,
        Alexei Starovoitov <ast@kernel.org>,
        Andy Lutomirski <luto@amacapital.net>, Arnd Bergmann <arnd@arndb.de>,
        Casey Schaufler <casey@schaufler-ca.com>,
        Daniel Borkmann <daniel@iogearbox.net>,
        Daniel Mack <daniel@zonque.org>, David Drysdale <drysdale@google.com>,
        "David S . Miller" <davem@davemloft.net>,
        Elena Reshetova <elena.reshetova@intel.com>,
        James Morris <james.l.morris@oracle.com>,
        Kees Cook <keescook@chromium.org>, Paul Moore <pmoore@redhat.com>,
        Sargun Dhillon <sargun@sargun.me>,
        "Serge E . Hallyn" <serge@hallyn.com>, Will Drewry <wad@chromium.org>,
        kernel-hardening@lists.openwall.com, linux-api@vger.kernel.org,
        linux-security-module@vger.kernel.org, netdev@vger.kernel.org
To: linux-kernel@vger.kernel.org
Return-path: <kernel-hardening-return-4458-glkh-kernel-hardening=m.gmane.org@lists.openwall.com>
List-Post: <mailto:kernel-hardening@lists.openwall.com>
List-Help: <mailto:kernel-hardening-help@lists.openwall.com>
List-Unsubscribe: <mailto:kernel-hardening-unsubscribe@lists.openwall.com>
List-Subscribe: <mailto:kernel-hardening-subscribe@lists.openwall.com>
In-Reply-To: <1472121165-29071-1-git-send-email-mic@digikod.net>
List-Id: netdev.vger.kernel.org

Add a max errno value.

This is not strictly needed but should improve reliability.

Signed-off-by: Mickaël Salaün <mic@digikod.net>
Cc: Arnd Bergmann <arnd@arndb.de>
Cc: Serge E. Hallyn <serge@hallyn.com>
Cc: James Morris <james.l.morris@oracle.com>
Cc: Kees Cook <keescook@chromium.org>
---
 include/uapi/asm-generic/errno-base.h | 1 +
 security/landlock/lsm.c               | 6 +++---
 2 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/uapi/asm-generic/errno-base.h b/include/uapi/asm-generic/errno-base.h
index 65115978510f..43407a403e72 100644
--- a/include/uapi/asm-generic/errno-base.h
+++ b/include/uapi/asm-generic/errno-base.h
@@ -35,5 +35,6 @@
 #define	EPIPE		32	/* Broken pipe */
 #define	EDOM		33	/* Math argument out of domain of func */
 #define	ERANGE		34	/* Math result not representable */
+#define	_ERRNO_LAST	ERANGE
 
 #endif
diff --git a/security/landlock/lsm.c b/security/landlock/lsm.c
index aa9d4a64826e..322309068066 100644
--- a/security/landlock/lsm.c
+++ b/security/landlock/lsm.c
@@ -11,7 +11,6 @@
 #include <asm/current.h>
 #include <linux/bpf.h> /* enum bpf_reg_type, struct landlock_data */
 #include <linux/cred.h>
-#include <linux/err.h> /* MAX_ERRNO */
 #include <linux/filter.h> /* struct bpf_prog, BPF_PROG_RUN() */
 #include <linux/kernel.h> /* FIELD_SIZEOF() */
 #include <linux/lsm_hooks.h>
@@ -104,8 +103,9 @@ static int landlock_run_prog(__u64 args[6])
 				}
 			}
 			if (!ret) {
-				if (cur_ret > MAX_ERRNO)
-					ret = MAX_ERRNO;
+				/* check errno to not mess with kernel code */
+				if (cur_ret > _ERRNO_LAST)
+					ret = EPERM;
 				else
 					ret = cur_ret;
 			}
-- 
2.8.1
