From: Dan Rosenberg <drosenberg@vsecurity.com>
Subject: [PATCH v4] kptr_restrict for hiding kernel pointers
Date: Sat, 18 Dec 2010 16:41:39 -0500
Message-ID: <1292708499.10804.89.camel@dan>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: jmorris@namei.org, eric.dumazet@gmail.com, tgraf@infradead.org,
	eugeneteo@kernel.org, kees.cook@canonical.com, mingo@elte.hu,
	davem@davemloft.net, a.p.zijlstra@chello.nl,
	akpm@linux-foundation.org, eparis@parisplace.org
To: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Add the %pK printk format specifier and
the /proc/sys/kernel/kptr_restrict sysctl.

The %pK format specifier is designed to hide exposed kernel pointers,
specifically via /proc interfaces.  Exposing these pointers provides an
easy target for kernel write vulnerabilities, since they reveal the
locations of writable structures containing easily triggerable function
pointers.  The behavior of %pK depends on the kptr_restrict sysctl.

If kptr_restrict is set to 0, no deviation from the standard %p behavior
occurs.  If kptr_restrict is set to 1, if the current user (intended to
be a reader via seq_printf(), etc.) does not have CAP_SYSLOG (which is
currently in the LSM tree), kernel pointers using %pK are printed as
0's.  If kptr_restrict is set to 2, kernel pointers using %pK are
printed as 0's regardless of privileges.  Replacing with 0's was chosen
over the default "(null)", which cannot be parsed by userland %p, which
expects "(nil)".


v4 incorporates Eric Paris' suggestion of using
has_capability_noaudit(), since failing this capability check is not a
policy violation but rather a code path choice and shouldn't generate
potentially excessive log noise.  Adjusted IRQ comment for clarity.

v3 adds the "2" setting, cleans up documentation, removes the CONFIG,
and incorporates changes and suggestions from Andrew Morton.

v2 improves checking for inappropriate context, on suggestion by Peter
Zijlstra.  Thanks to Thomas Graf for suggesting use of a centralized
format specifier.


Signed-off-by: Dan Rosenberg <drosenberg@vsecurity.com>
Cc: James Morris <jmorris@namei.org>
Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Thomas Graf <tgraf@infradead.org>
Cc: Eugene Teo <eugeneteo@kernel.org>
Cc: Kees Cook <kees.cook@canonical.com>
Cc: Ingo Molnar <mingo@elte.hu>
Cc: David S. Miller <davem@davemloft.net>
Cc: Peter Zijlstra <a.p.zijlstra@chello.nl>
Cc: Andrew Morton <akpm@linux-foundation.org>
Cc: Eric Paris <eparis@parisplace.org>
---

 Documentation/sysctl/kernel.txt |   14 ++++++++++++++
 include/linux/kernel.h          |    2 ++
 kernel/sysctl.c                 |    9 +++++++++
 lib/vsprintf.c                  |   24 ++++++++++++++++++++++++
 4 files changed, 49 insertions(+), 0 deletions(-)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 209e158..3cff47e 100644
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
+This toggle indicates whether restrictions are placed on
+exposing kernel addresses via /proc and other interfaces.  When
+kptr_restrict is set to (0), the default, there are no
+restrictions.  When kptr_restrict is set to (1), kernel pointers
+printed using the %pK format specifier will be replaced with 0's
+unless the user has CAP_SYSLOG.  When kptr_restrict is set to
+(2), kernel pointers printed using %pK will be replaced with 0's
+regardless of privileges.
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
index 5abfa15..236fa91 100644
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
+		.extra2		= &two,
+	},
+	{
 		.procname	= "ngroups_max",
 		.data		= &ngroups_max,
 		.maxlen		= sizeof (int),
diff --git a/lib/vsprintf.c b/lib/vsprintf.c
index c150d3d..313f767 100644
--- a/lib/vsprintf.c
+++ b/lib/vsprintf.c
@@ -936,6 +936,8 @@ char *uuid_string(char *buf, char *end, const u8 *addr,
 	return string(buf, end, uuid, spec);
 }
 
+int kptr_restrict;
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
@@ -1035,6 +1038,27 @@ char *pointer(const char *fmt, char *buf, char *end, void *ptr,
 		return buf + vsnprintf(buf, end - buf,
 				       ((struct va_format *)ptr)->fmt,
 				       *(((struct va_format *)ptr)->va));
+	case 'K':
+		/*
+		 * %pK cannot be used in IRQ context because its test
+		 * for CAP_SYSLOG would be meaningless.
+		 */
+		if (in_irq() || in_serving_softirq() || in_nmi())
+			WARN_ONCE(1, "%%pK used in interrupt context.\n");
+
+		if (!kptr_restrict)
+			break;		/* %pK does not obscure pointers */
+
+		if ((kptr_restrict != 2) &&
+		    has_capability_noaudit(current, CAP_SYSLOG))
+			break;		/* privileged apps expose pointers,
+					   unless kptr_restrict is 2 */
+
+		if (spec.field_width == -1) {
+			spec.field_width = 2 * sizeof(void *);
+			spec.flags |= ZEROPAD;
+		}
+		return number(buf, end, 0, spec);
 	}
 	spec.flags |= SMALL;
 	if (spec.field_width == -1) {


