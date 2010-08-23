From: luciano.coelho@nokia.com
Subject: [PATCH] netfilter: xt_condition: add security capability support
Date: Mon, 23 Aug 2010 15:50:01 +0300
Message-ID: <1282567801-2673-1-git-send-email-luciano.coelho@nokia.com>
Cc: netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	Luciano Coelho <luciano.coelho@nokia.com>
To: kaber@trash.net
Return-path: <netfilter-devel-owner@vger.kernel.org>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Luciano Coelho <luciano.coelho@nokia.com>

Add a module parameter that allows the required security capability to
change the conditions from userspace to be specified.  By default the
module will require the CAP_NET_ADMIN capability.

Signed-off-by: Luciano Coelho <luciano.coelho@nokia.com>
---
 net/netfilter/xt_condition.c |   10 ++++++++++
 1 files changed, 10 insertions(+), 0 deletions(-)

diff --git a/net/netfilter/xt_condition.c b/net/netfilter/xt_condition.c
index 06205aa..fd279e5 100644
--- a/net/netfilter/xt_condition.c
+++ b/net/netfilter/xt_condition.c
@@ -29,11 +29,13 @@
 #include <linux/netfilter/xt_condition.h>
 #include <net/netns/generic.h>
 #include <asm/uaccess.h>
+#include <linux/capability.h>
 
 /* Defaults, these can be overridden on the module command-line. */
 static unsigned int condition_list_perms = S_IRUGO | S_IWUSR;
 static unsigned int condition_uid_perms = 0;
 static unsigned int condition_gid_perms = 0;
+static unsigned int condition_capabilities = CAP_NET_ADMIN;
 
 MODULE_AUTHOR("Stephane Ouellette <ouellettes@videotron.ca>");
 MODULE_AUTHOR("Massimiliano Hofer <max@nucleus.it>");
@@ -47,6 +49,8 @@ module_param(condition_uid_perms, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(condition_uid_perms, "default user owner of /proc/net/nf_condition/* files");
 module_param(condition_gid_perms, uint, S_IRUSR | S_IWUSR);
 MODULE_PARM_DESC(condition_gid_perms, "default group owner of /proc/net/nf_condition/* files");
+module_param(condition_capabilities, uint, CAP_NET_ADMIN);
+MODULE_PARM_DESC(condition_capabilities, "default capabilities required to change /proc/net/nf_condition/* files");
 MODULE_ALIAS("ipt_condition");
 MODULE_ALIAS("ip6t_condition");
 
@@ -88,6 +92,12 @@ static int condition_proc_write(struct file *file, const char __user *input,
 	char buf[sizeof("+037777777777")];
 	unsigned long long value;
 
+	if (!capable(condition_capabilities)) {
+		pr_debug("not enough capabilities (requires %0X)\n",
+			condition_capabilities);
+		return -EPERM;
+	}
+
 	if (length == 0)
 		return 0;
 
-- 
1.7.0.4

