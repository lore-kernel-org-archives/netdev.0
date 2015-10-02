From: Tycho Andersen <tycho.andersen@canonical.com>
Subject: [PATCH v5 3/3] kcmp: add KCMP_SECCOMP_FD
Date: Fri,  2 Oct 2015 10:27:23 -0600
Message-ID: <1443803243-25912-4-git-send-email-tycho.andersen@canonical.com>
References: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Cc: Alexei Starovoitov <ast@kernel.org>,
	Will Drewry <wad@chromium.org>,
	Oleg Nesterov <oleg@redhat.com>,
	Andy Lutomirski <luto@amacapital.net>,
	Pavel Emelyanov <xemul@parallels.com>,
	"Serge E. Hallyn" <serge.hallyn@ubuntu.com>,
	Daniel Borkmann <daniel@iogearbox.net>,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-api@vger.kernel.org,
	Tycho Andersen <tycho.andersen@canonical.com>
To: Kees Cook <keescook@chromium.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1443803243-25912-1-git-send-email-tycho.andersen@canonical.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This command allows for comparing the filters pointed to by two seccomp
fds. This is useful e.g. to find out if a seccomp filter is inherited,
since struct seccomp_filter are unique across tasks and are the
private_data seccomp fds.

v2: switch to KCMP_SECCOMP_FD instead of KCMP_FILE_PRIVATE_DATA

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
 include/uapi/linux/kcmp.h |  1 +
 kernel/kcmp.c             | 27 +++++++++++++++++++++++++++
 2 files changed, 28 insertions(+)

diff --git a/include/uapi/linux/kcmp.h b/include/uapi/linux/kcmp.h
index 84df14b..cd7870b 100644
--- a/include/uapi/linux/kcmp.h
+++ b/include/uapi/linux/kcmp.h
@@ -10,6 +10,7 @@ enum kcmp_type {
 	KCMP_SIGHAND,
 	KCMP_IO,
 	KCMP_SYSVSEM,
+	KCMP_SECCOMP_FD,
 
 	KCMP_TYPES,
 };
diff --git a/kernel/kcmp.c b/kernel/kcmp.c
index 0aa69ea..d53db53 100644
--- a/kernel/kcmp.c
+++ b/kernel/kcmp.c
@@ -11,6 +11,7 @@
 #include <linux/bug.h>
 #include <linux/err.h>
 #include <linux/kcmp.h>
+#include <linux/seccomp.h>
 
 #include <asm/unistd.h>
 
@@ -165,6 +166,32 @@ SYSCALL_DEFINE5(kcmp, pid_t, pid1, pid_t, pid2, int, type,
 		ret = -EOPNOTSUPP;
 #endif
 		break;
+	case KCMP_SECCOMP_FD: {
+		struct file *filp1, *filp2;
+
+		filp1 = get_file_raw_ptr(task1, idx1);
+		filp2 = get_file_raw_ptr(task2, idx2);
+
+		if (filp1 && filp2) {
+			struct seccomp_filter *filter1, *filter2;
+
+			filter1 = seccomp_filter_from_file(filp1);
+			if (IS_ERR(filter1)) {
+				ret = PTR_ERR(filter1);
+				break;
+			}
+
+			filter2 = seccomp_filter_from_file(filp2);
+			if (IS_ERR(filter2)) {
+				ret = PTR_ERR(filter2);
+				break;
+			}
+
+			ret = kcmp_ptr(filter1, filter2, KCMP_SECCOMP_FD);
+		} else
+			ret = -EBADF;
+		break;
+	}
 	default:
 		ret = -EINVAL;
 		break;
-- 
2.5.0
