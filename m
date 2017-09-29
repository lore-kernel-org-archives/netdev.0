From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [PATCH 1/2] capability: introduce sysctl for controlled user-ns capability whitelist
Date: Fri, 29 Sep 2017 16:10:05 -0700
Message-ID: <20170929231005.29755-1-mahesh@bandewar.net>
Cc: Netdev <netdev@vger.kernel.org>,
        Kernel-hardening <kernel-hardening@lists.openwall.com>,
        Linux API <linux-api@vger.kernel.org>,
        Kees Cook <keescook@chromium.org>,
        Serge Hallyn <serge@hallyn.com>,
        "Eric W . Biederman" <ebiederm@xmission.com>,
        Eric Dumazet <edumazet@google.com>,
        David Miller <davem@davemloft.net>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>
To: LKML <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Mahesh Bandewar <maheshb@google.com>

Add a sysctl variable kernel.controlled_userns_caps_whitelist. This
takes input as capability mask expressed as two comma separated hex
u32 words. The mask, however, is stored in kernel as kernel_cap_t type.

Any capabilities that are not part of this mask will be controlled and
will not be allowed to processes in controlled user-ns.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
 Documentation/sysctl/kernel.txt | 21 ++++++++++++++++++
 include/linux/capability.h      |  3 +++
 kernel/capability.c             | 47 +++++++++++++++++++++++++++++++++++++++++
 kernel/sysctl.c                 |  5 +++++
 4 files changed, 76 insertions(+)

diff --git a/Documentation/sysctl/kernel.txt b/Documentation/sysctl/kernel.txt
index 694968c7523c..a1d39dbae847 100644
--- a/Documentation/sysctl/kernel.txt
+++ b/Documentation/sysctl/kernel.txt
@@ -25,6 +25,7 @@ show up in /proc/sys/kernel:
 - bootloader_version	     [ X86 only ]
 - callhome		     [ S390 only ]
 - cap_last_cap
+- controlled_userns_caps_whitelist
 - core_pattern
 - core_pipe_limit
 - core_uses_pid
@@ -187,6 +188,26 @@ CAP_LAST_CAP from the kernel.
 
 ==============================================================
 
+controlled_userns_caps_whitelist
+
+Capability mask that is whitelisted for "controlled" user namespaces.
+Any capability that is missing from this mask will not be allowed to
+any process that is attached to a controlled-userns. e.g. if CAP_NET_RAW
+is not part of this mask, then processes running inside any controlled
+userns's will not be allowed to perform action that needs CAP_NET_RAW
+capability. However, processes that are attached to a parent user-ns
+hierarchy that is *not* controlled and has CAP_NET_RAW can continue
+performing those actions. User-namespaces are marked "controlled" at
+the time of their creation based on the capabilities of the creator.
+A process that does not have CAP_SYS_ADMIN will create user-namespaces
+that are controlled.
+
+The value is expressed as two comma separated hex words (u32). This
+sysctl is avaialble in init-ns and users with CAP_SYS_ADMIN in init-ns
+are allowed to make changes.
+
+==============================================================
+
 core_pattern:
 
 core_pattern is used to specify a core dumpfile pattern name.
diff --git a/include/linux/capability.h b/include/linux/capability.h
index b52e278e4744..6c0b9677c03f 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -13,6 +13,7 @@
 #define _LINUX_CAPABILITY_H
 
 #include <uapi/linux/capability.h>
+#include <linux/sysctl.h>
 
 
 #define _KERNEL_CAPABILITY_VERSION _LINUX_CAPABILITY_VERSION_3
@@ -247,6 +248,8 @@ extern bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns);
 
 /* audit system wants to get cap info from files as well */
 extern int get_vfs_caps_from_disk(const struct dentry *dentry, struct cpu_vfs_cap_data *cpu_caps);
+int proc_douserns_caps_whitelist(struct ctl_table *table, int write,
+				 void __user *buff, size_t *lenp, loff_t *ppos);
 
 extern int cap_convert_nscap(struct dentry *dentry, void **ivalue, size_t size);
 
diff --git a/kernel/capability.c b/kernel/capability.c
index f97fe77ceb88..62dbe3350c1b 100644
--- a/kernel/capability.c
+++ b/kernel/capability.c
@@ -28,6 +28,8 @@ EXPORT_SYMBOL(__cap_empty_set);
 
 int file_caps_enabled = 1;
 
+kernel_cap_t controlled_userns_caps_whitelist = CAP_FULL_SET;
+
 static int __init file_caps_disable(char *str)
 {
 	file_caps_enabled = 0;
@@ -506,3 +508,48 @@ bool ptracer_capable(struct task_struct *tsk, struct user_namespace *ns)
 	rcu_read_unlock();
 	return (ret == 0);
 }
+
+/* Controlled-userns capabilities routines */
+#ifdef CONFIG_SYSCTL
+int proc_douserns_caps_whitelist(struct ctl_table *table, int write,
+				 void __user *buff, size_t *lenp, loff_t *ppos)
+{
+	DECLARE_BITMAP(caps_bitmap, CAP_LAST_CAP);
+	struct ctl_table caps_table;
+	char tbuf[NAME_MAX];
+	int ret;
+
+	ret = bitmap_from_u32array(caps_bitmap, CAP_LAST_CAP,
+				   controlled_userns_caps_whitelist.cap,
+				   _KERNEL_CAPABILITY_U32S);
+	if (ret != CAP_LAST_CAP)
+		return -1;
+
+	scnprintf(tbuf, NAME_MAX, "%*pb", CAP_LAST_CAP, caps_bitmap);
+
+	caps_table.data = tbuf;
+	caps_table.maxlen = NAME_MAX;
+	caps_table.mode = table->mode;
+	ret = proc_dostring(&caps_table, write, buff, lenp, ppos);
+	if (ret)
+		return ret;
+	if (write) {
+		kernel_cap_t tmp;
+
+		if (!capable(CAP_SYS_ADMIN))
+			return -EPERM;
+
+		ret = bitmap_parse_user(buff, *lenp, caps_bitmap, CAP_LAST_CAP);
+		if (ret)
+			return ret;
+
+		ret = bitmap_to_u32array(tmp.cap, _KERNEL_CAPABILITY_U32S,
+					 caps_bitmap, CAP_LAST_CAP);
+		if (ret != CAP_LAST_CAP)
+			return -1;
+
+		controlled_userns_caps_whitelist = tmp;
+	}
+	return 0;
+}
+#endif /* CONFIG_SYSCTL */
diff --git a/kernel/sysctl.c b/kernel/sysctl.c
index 6648fbbb8157..9903cf0de287 100644
--- a/kernel/sysctl.c
+++ b/kernel/sysctl.c
@@ -1229,6 +1229,11 @@ static struct ctl_table kern_table[] = {
 		.extra2		= &one,
 	},
 #endif
+	{
+		.procname	= "controlled_userns_caps_whitelist",
+		.mode		= 0644,
+		.proc_handler	= proc_douserns_caps_whitelist,
+	},
 	{ }
 };
 
-- 
2.14.2.822.g60be5d43e6-goog
