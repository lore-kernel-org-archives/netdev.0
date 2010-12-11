From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v2] kptr_restrict for hiding kernel pointers from
 unprivileged users
Date: Fri, 10 Dec 2010 19:05:24 -0500
Message-ID: <1292025924.2965.20.camel@Dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: linux-security-module@vger.kernel.org, netdev@vger.kernel.org,
	jmorris@namei.org, eugeneteo@kernel.org, kees.cook@canonical.com,
	mingo@elte.hu, davem@davemloft.net
To: linux-kernel@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The below patch adds the %pK format specifier, the
CONFIG_SECURITY_KPTR_RESTRICT configuration option, and the
kptr_restrict sysctl.

The %pK format specifier is designed to hide exposed kernel pointers
from unprivileged users, specifically via /proc interfaces.  Its
behavior depends on the kptr_restrict sysctl, whose default value
depends on CONFIG_SECURITY_KPTR_RESTRICT.  If kptr_restrict is set to 0,
no deviation from the standard %p behavior occurs.  If kptr_restrict is
set to 1, if the current user (intended to be a reader via seq_printf(),
etc.) does not have CAP_SYSLOG (which is currently in the LSM tree),
kernel pointers using %pK are printed as 0's.  This was chosen over the
default "(null)", which cannot be parsed by userland %p, which expects
"(nil)".

v2 improves checking for inappropriate context, on suggestion by Peter
Zijlstra.  Thanks to Thomas Graf for suggesting use of a centralized
format specifier.

Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
CC: James Morris <jmorris@namei.org>
CC: Eugene Teo <eugeneteo@kernel.org>
CC: Kees Cook <kees.cook@canonical.com>
CC: Ingo Molnar <mingo@elte.hu>
CC: David S. Miller <davem@davemloft.net>
CC: linux-security-module@vger.kernel.org
CC: netdev@vger.kernel.org
---
 Documentation/sysctl/kernel.txt |   14 ++++++++++++++
 include/linux/kernel.h          |    2 ++
 kernel/sysctl.c                 |    9 +++++++++
 lib/vsprintf.c                  |   18 ++++++++++++++++++
 security/Kconfig                |   12 ++++++++++++
 5 files changed, 55 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 209e158..e5373f3 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -34,6 +34,7 @@ show up in /proc/sys/kernel:
 - hotplug
 - java-appletviewer           [ binfmt_java, obsolete ]
 - java-interpreter            [ binfmt_java, obsolete ]
+- kptr_restrict
 - kstack_depth_to_print       [ X86 only ]
 - l2cr                        [ PPC only ]
 - modprobe                    ==> Documentation/debugging-modules.txt
@@ -261,6 +262,19 @@ This flag controls the L2 cache of G3 processor boards. If
 
 ==============================================================
 
+kptr_restrict:
+
+This toggle indicates whether unprivileged users are prevented from reading
+kernel addresses via /proc and other interfaces.  When kptr_restrict is set
+to (0), there are no restrictions.  When kptr_restrict is set to (1), kernel
+pointers printed using the %pK format specifier will be replaced with 0's
+unless the user has CAP_SYSLOG.
+
+The kernel config option CONFIG_SECURITY_KPTR_RESTRICT sets the default
+value of kptr_restrict.
+
+==============================================================
+
 kstack_depth_to_print: (X86 only)
 
 Controls the number of words to print when dumping the raw
diff --git a/include/linux/kernel.h b/include/linux/kernel.h
index b6de9a6..b4f4863 100644
--- a/include/linux/kernel.h
+++ b/include/linux/kernel.h
@@ -201,6 +201,8 @@ extern int sscanf(const char *, const char *, ...)
 extern int vsscanf(const char *, const char *, va_list)
 	__attribute__ ((format (scanf, 2, 0)));
 
+extern int kptr_restrict;	/* for sysctl */
+
 extern int get_option(char **str, int *pint);
 extern char *get_options(const char *str, int nints, int *ints);
 extern unsigned long long memparse(const char *ptr, char **retptr);
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 5abfa15..de46e47 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -713,6 +713,15 @@ static struct ctl_table kern_table[] = {
 	},
 #endif
 	{
+		.procname	= "kptr_restrict",
+		.data		= &kptr_restrict,
+		.maxlen		= sizeof(int),
+		.mode		= 0644,
+		.proc_handler	= proc_dointvec_minmax,
+		.extra1		= &zero,
+		.extra2		= &one,
+	},
+	{
 		.procname	= "ngroups_max",
 		.data		= &ngroups_max,
 		.maxlen		= sizeof (int),
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index c150d3d..ceb1a3b 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -936,6 +936,8 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
 	return string(buf, end, uuid, spec);
 }
 
+int kptr_restrict = CONFIG_SECURITY_KPTR_RESTRICT;
+
 /*
  * Show a '%p' thing.  A kernel extension is that the '%p' is followed
  * by an extra set of alphanumeric characters that are extended format
@@ -979,6 +981,7 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
  *       Implements a "recursive vsnprintf".
  *       Do not use this feature without some mechanism to verify the
  *       correctness of the format string and va_list arguments.
+ * - 'K' For a kernel pointer that should be hidden from unprivileged users
  *
  * Note: The difference between 'S' and 'F' is that on ia64 and ppc64
  * function pointers are really function descriptors, which contain a
@@ -1035,6 +1038,21 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return buf + vsnprintf(buf, end - buf,
 				       ((struct va_format *)ptr)->fmt,
 				       *(((struct va_format *)ptr)->va));
+	case 'K':
+		if (kptr_restrict) {
+			if (in_irq() || in_serving_softirq() || in_nmi())
+				WARN(1, "%%pK used in interrupt context.\n");
+
+			else if (capable(CAP_SYSLOG))
+				break;
+
+			if (spec.field_width == -1) {
+				spec.field_width = 2 * sizeof(void *);
+				spec.flags |= ZEROPAD;
+			}
+			return number(buf, end, 0, spec);
+		}
+		break;
 	}
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {
diff --git a/security/Kconfig b/security/Kconfig
index e80da95..944fc73 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -51,6 +51,18 @@ config SECURITY_DMESG_RESTRICT
 
 	  If you are unsure how to answer this question, answer N.
 
+config SECURITY_KPTR_RESTRICT
+	bool "Hide kernel pointers from unprivileged users"
+	default n
+	help
+	  This enforces restrictions on unprivileged users reading kernel
+	  addresses via various interfaces, e.g. /proc.
+
+	  If this option is not selected, no restrictions will be enforced
+	  unless the kptr_restrict sysctl is explicitly set to (1).
+
+	  If you are unsure how to answer this question, answer N.
+
 config SECURITY
 	bool "Enable different security models"
 	depends on SYSFS


