From: Michael Stone <michael@laptop.org>
Subject: [PATCH 2/3] Security: Implement prctl(PR_SET_NETWORK,
	PR_NETWORK_OFF) semantics. (v3)
Date: Wed, 23 Dec 2009 20:45:13 -0500
Message-ID: <20091224014513.GA24178@heat>
References: <20091224014258.GA24115@heat>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Michael Stone <michael@laptop.org>, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-security-module@vger.kernel.org,
	Andi Kleen <andi@firstfloor.org>, David Lang <david@lang.hm>,
	Oliver Hartkopp <socketcan@hartkopp.net>,
	Alan Cox <alan@lxorguk.ukuu.org.uk>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	Valdis Kletnieks <Valdis.Kletnieks@vt.edu>,
	Bryan Donlan <bdonlan@gmail.com>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	"C. Scott Ananian" <cscott@cscott.net>,
	James Morris <jmorris@namei.org>,
	"Eric W. Biederman" <ebiederm@xmission.com>,
	Bernie Innocenti <bernie@codewiz.org>,
	Mark Seaborn <mrs@mythic-beasts.com>,
	Randy Dunlap <randy.dunlap@oracle.com>,
	=?iso-8859-1?Q?Am=E9rico?= Wang <xiyou.wangcong@gmail.com>
To: Alan Cox <alan@lxorguk.ukuu.org.uk>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1757589AbZLXBnR@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20091224014258.GA24115@heat>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Implement security_* hooks for socket_create, socket_bind, socket_connect,
socket_sendmsg, and ptrace_access_check which return -EPERM when called from a
process with networking restrictions. Exempt AF_UNIX sockets.

Signed-off-by: Michael Stone <michael@laptop.org>
---
  security/Kconfig         |   13 +++++
  security/Makefile        |    1 +
  security/prctl_network.c |  110 ++++++++++++++++++++++++++++++++++++++++++++++
  3 files changed, 124 insertions(+), 0 deletions(-)
  create mode 100644 security/prctl_network.c

diff --git a/security/Kconfig b/security/Kconfig
index 226b955..740a7fe 100644
--- a/security/Kconfig
+++ b/security/Kconfig
@@ -137,6 +137,19 @@ config LSM_MMAP_MIN_ADDR
  	  this low address space will need the permission specific to the
  	  systems running LSM.
  
+config SECURITY_PRCTL_NETWORK
+	tristate "prctl(PR_{GET,SET}_NETWORK) support"
+	depends on SECURITY_NETWORK
+	help
+    This enables processes to drop networking privileges via
+    prctl(PR_SET_NETWORK, PR_NETWORK_OFF), which is used by OLPC's isolation
+    shell, <http://wiki.laptop.org/go/Rainbow> to implement discretionary
+    network isolation.
+
+    See Documentation/prctl/network.txt for more information about this LSM.
+
+	  If you are unsure how to answer this question, answer N.
+
  source security/selinux/Kconfig
  source security/smack/Kconfig
  source security/tomoyo/Kconfig
diff --git a/security/Makefile b/security/Makefile
index da20a19..92ce65d 100644
--- a/security/Makefile
+++ b/security/Makefile
@@ -20,6 +20,7 @@ obj-$(CONFIG_SECURITY_SMACK)		+= smack/built-in.o
  obj-$(CONFIG_AUDIT)			+= lsm_audit.o
  obj-$(CONFIG_SECURITY_TOMOYO)		+= tomoyo/built-in.o
  obj-$(CONFIG_CGROUP_DEVICE)		+= device_cgroup.o
+obj-$(CONFIG_SECURITY_PRCTL_NETWORK)	+= prctl_network.o
  
  # Object integrity file lists
  subdir-$(CONFIG_IMA)			+= integrity/ima
diff --git a/security/prctl_network.c b/security/prctl_network.c
new file mode 100644
index 0000000..2da6051
--- /dev/null
+++ b/security/prctl_network.c
@@ -0,0 +1,110 @@
+/*
+ * prctl_network LSM.
+ *
+ * Copyright (C) 2008-2009 Michael Stone <michael@laptop.org>
+ * Based on sample code from security/root_plug.c, (C) 2002 Greg Kroah-Hartman.
+ *
+ * Implements the prctl(PR_SET_NETWORK, PR_NETWORK_OFF) syscall.
+ *
+ * See Documentation/prctl/network.txt for more information about this code.
+ *
+ * This program is free software; you can redistribute it and/or
+ * modify it under the terms of the GNU General Public License as
+ * published by the Free Software Foundation, version 2 of the
+ * License.
+ */
+
+#include <linux/init.h>
+#include <linux/kernel.h>
+#include <linux/errno.h>
+#include <linux/sched.h>
+#include <net/sock.h>
+#include <linux/socket.h>
+#include <linux/security.h>
+
+static inline int maybe_allow(void)
+{
+	if (current->network)
+		return -EPERM;
+	return 0;
+}
+
+static inline int prctl_network_socket_create_hook (int family, int type,
+						int protocol, int kern)
+{
+	if (family == AF_UNIX)
+		return 0;
+	return maybe_allow();
+}
+
+static inline int prctl_network_socket_bind_hook(struct socket * sock,
+					     struct sockaddr * address,
+					     int addrlen)
+{
+	if (address->sa_family == AF_UNIX)
+		return 0;
+	return maybe_allow();
+}
+
+static inline int prctl_network_socket_connect_hook(struct socket * sock,
+						struct sockaddr * address,
+						int addrlen)
+{
+	if (address->sa_family == AF_UNIX)
+		return 0;
+	return maybe_allow();
+}
+
+static inline int prctl_network_socket_sendmsg_hook(struct socket * sock,
+						struct msghdr * msg, int size)
+{
+	if (sock->sk->sk_family != PF_UNIX &&
+		current->network &&
+		(msg->msg_name != NULL || msg->msg_namelen != 0))
+		return -EPERM;
+	return 0;
+}
+
+static inline int prctl_network_ptrace_access_check_hook(struct task_struct *child, unsigned int mode)
+{
+	/* does current have networking restrictions not shared by child? */
+	if (current->network & ~child->network)
+		return -EPERM;
+	return 0;
+}
+
+/* static inline int prctl_network_ptrace_traceme(struct task_struct *parent) ? */
+
+static struct security_operations prctl_network_security_ops = {
+	.name                   = "prctl_net",
+	.socket_create		= prctl_network_socket_create_hook,
+	.socket_bind		= prctl_network_socket_bind_hook,
+	.socket_connect		= prctl_network_socket_connect_hook,
+	.socket_sendmsg		= prctl_network_socket_sendmsg_hook,
+	.ptrace_access_check	= prctl_network_ptrace_access_check_hook,
+};
+
+static int __init prctl_network_security_init (void)
+{
+	if (!security_module_enable(&prctl_network_security_ops)) {
+		printk (KERN_INFO
+			"Failure enabling prctl_network_lsm.\n");
+		return 0;
+	}
+
+	/* register ourselves with the security framework */
+	if (register_security (&prctl_network_security_ops)) {
+		printk (KERN_INFO
+			"Failure registering prctl_network_lsm with the kernel\n");
+		return 0;
+	}
+
+	printk (KERN_INFO "prctl_network_lsm initialized\n");
+
+	return 0;
+}
+
+security_initcall (prctl_network_security_init);
+
+MODULE_DESCRIPTION("prctl_network LSM; implementing prctl(PR_SET_NETWORK, PR_NETWORK_OFF).");
+MODULE_LICENSE("GPL");
-- 
1.6.6.rc1
