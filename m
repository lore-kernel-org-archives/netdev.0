From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v3 03/10] snet: introduce snet_core
Date: Tue,  3 May 2011 16:24:16 +0200
Message-ID: <1304432663-1575-4-git-send-email-sam@synack.fr>
References: <1304432663-1575-1-git-send-email-sam@synack.fr>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1304432663-1575-1-git-send-email-sam@synack.fr>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch introduce snet_core.c, which provides functions to start and stop
snet's subsystems, and include/linux/snet.h, which provides interface with
userspace.

subsytems are:
    - snet_hooks    : LSM hooks
    - snet_netlink  : kernel-user communication (genetlink)
    - snet_event    : manages the list of protected syscalls
    - snet_verdict  : provides a waitqueue for syscalls and manage verdicts
		      from userspace
    - snet_ticket   : provides a granted-access ticket mecanism

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 include/linux/snet.h      |  117 +++++++++++++++++++++++++++++++++++++++++++++
 security/snet/snet_core.c |   82 +++++++++++++++++++++++++++++++
 2 files changed, 199 insertions(+), 0 deletions(-)
 create mode 100644 include/linux/snet.h
 create mode 100644 security/snet/snet_core.c

diff --git a/include/linux/snet.h b/include/linux/snet.h
new file mode 100644
index 0000000..580b6b6
--- /dev/null
+++ b/include/linux/snet.h
@@ -0,0 +1,117 @@
+#ifndef _LINUX_SNET_H
+#define _LINUX_SNET_H
+
+#include <linux/in6.h>
+
+#define SNET_VERSION	0x1
+#define SNET_NAME	"snet"
+
+enum snet_syscall {
+	SNET_SOCKET_CREATE = 0,
+	SNET_SOCKET_BIND,
+	SNET_SOCKET_CONNECT,
+	SNET_SOCKET_LISTEN,
+	SNET_SOCKET_ACCEPT,
+	SNET_SOCKET_POST_ACCEPT,
+	SNET_SOCKET_SENDMSG,
+	SNET_SOCKET_RECVMSG,
+	SNET_SOCKET_SOCK_RCV_SKB,
+	SNET_SOCKET_CLOSE,
+	SNET_SOCKET_INVALID,
+};
+
+#define SNET_NR_SOCKET_TYPES SNET_SOCKET_INVALID
+
+struct snet_event {
+	enum snet_syscall syscall;
+	u8 protocol;
+};
+
+enum snet_verdict {
+	SNET_VERDICT_GRANT = 0,	/* grant the syscall */
+	SNET_VERDICT_DENY,	/* deny the syscall */
+	SNET_VERDICT_PENDING,	/* waiting for a decision */
+	SNET_VERDICT_NONE,	/* no decision can be set */
+	SNET_VERDICT_INVALID,
+};
+
+#define SNET_NR_VERDICT_TYPES SNET_VERDICT_INVALID
+
+enum snet_ticket_mode {
+	SNET_TICKET_OFF = 0,
+	SNET_TICKET_FIX,
+	SNET_TICKET_EXTEND,
+	SNET_TICKET_INVALID,
+};
+
+/* genetlink commands */
+enum {
+	SNET_C_UNSPEC,
+	SNET_C_VERSION,
+	SNET_C_REGISTER,
+	SNET_C_UNREGISTER,
+	SNET_C_INSERT,
+	SNET_C_REMOVE,
+	SNET_C_FLUSH,
+	SNET_C_LIST,
+	SNET_C_VERDICT,
+	SNET_C_CONFIG,
+	__SNET_C_MAX,
+};
+
+#define SNET_C_MAX (__SNET_C_MAX - 1)
+
+/* genetlink attributes */
+enum {
+	SNET_A_UNSPEC,
+	SNET_A_VERSION,		/* (NLA_U32) the snet protocol version	*/
+	SNET_A_VERDICT_ID,
+	SNET_A_FAMILY,
+	SNET_A_SYSCALL,		/* (NLA_U8)  a syscall identifier	*/
+	SNET_A_PROTOCOL,	/* (NLA_U8)  a protocol identifier	*/
+	SNET_A_UID,
+	SNET_A_PID,
+	SNET_A_TYPE,
+	SNET_A_IPV4SADDR,
+	SNET_A_IPV6SADDR,
+	SNET_A_IPV4DADDR,
+	SNET_A_IPV6DADDR,
+	SNET_A_SPORT,
+	SNET_A_DPORT,
+	SNET_A_VERDICT,
+	SNET_A_VERDICT_DELAY,
+	SNET_A_TICKET_DELAY,
+	SNET_A_TICKET_MODE,
+	__SNET_A_MAX,
+};
+
+#define SNET_A_MAX (__SNET_A_MAX - 1)
+
+#define SNET_GENL_NAME		"SNET"
+#define SNET_GENL_VERSION	SNET_VERSION
+
+struct snet_sock_half {
+	struct {
+		union {
+			__be32 ip;
+			struct in6_addr ip6;
+		};
+	} u3;
+	struct {
+		__be16 port;
+	} u;
+};
+
+struct snet_info {
+	u32 verdict_id;
+
+	enum snet_syscall syscall;
+	u8 protocol;
+	u8 family;
+
+	int type;
+	struct snet_sock_half src;
+	struct snet_sock_half dst;
+};
+
+#endif /* _LINUX_SNET_H */
diff --git a/security/snet/snet_core.c b/security/snet/snet_core.c
new file mode 100644
index 0000000..949ecaa
--- /dev/null
+++ b/security/snet/snet_core.c
@@ -0,0 +1,82 @@
+#include <linux/module.h>
+#include <linux/kernel.h>
+#include <net/genetlink.h>
+#include <linux/snet.h>
+#include "snet_hooks.h"
+#include "snet_event.h"
+#include "snet_verdict.h"
+#include "snet_ticket.h"
+#include "snet_utils.h"
+
+unsigned int snet_evh_size = 16;
+module_param(snet_evh_size, uint, 0400);
+MODULE_PARM_DESC(snet_evh_size, "Set the size of the event hash table");
+
+unsigned int snet_vdh_size = 16;
+module_param(snet_vdh_size, uint, 0400);
+MODULE_PARM_DESC(snet_vdh_size, "Set the size of the verdict hash table");
+
+unsigned int snet_verdict_delay = 5;
+module_param(snet_verdict_delay, uint, 0600);
+MODULE_PARM_DESC(snet_verdict_delay, "Set the timeout for verdicts in secs");
+
+unsigned int snet_verdict_policy = SNET_VERDICT_GRANT;	/* permissive by default */
+module_param(snet_verdict_policy, uint, 0400);
+MODULE_PARM_DESC(snet_verdict_policy, "Set the default verdict");
+
+unsigned int snet_ticket_delay = 15;
+module_param(snet_ticket_delay, uint, 0600);
+MODULE_PARM_DESC(snet_ticket_delay, "Set the timeout for tickets in secs");
+
+unsigned int snet_ticket_mode = SNET_TICKET_FIX;
+module_param(snet_ticket_mode, uint, 0600);
+MODULE_PARM_DESC(snet_ticket_mode, "Set the mode for tickets");
+
+static __init int snet_init(void)
+{
+	int ret;
+
+	pr_debug("initializing: event_hash_size=%u "
+		 "verdict_hash_size=%u verdict_delay=%usecs "
+		 "default_policy=%s\n",
+		 snet_evh_size, snet_vdh_size, snet_verdict_delay,
+		 snet_verdict_name(snet_verdict_policy));
+
+	if (snet_verdict_policy >= SNET_VERDICT_INVALID) {
+		printk(KERN_ERR "snet: bad snet_verdict_policy\n");
+		ret = -EINVAL;
+		goto event_failed;
+	}
+
+	ret = snet_event_init();
+	if (ret < 0)
+		goto event_failed;
+
+	ret = snet_verdict_init();
+	if (ret < 0)
+		goto verdict_failed;
+
+	ret = snet_ticket_init();
+	if (ret < 0)
+		goto ticket_failed;
+
+	/* snet_hooks_init() returns 0 or execute panic() */
+	snet_hooks_init();
+
+	pr_debug("started\n");
+	return 0;
+
+ticket_failed:
+	snet_verdict_exit();
+verdict_failed:
+	snet_event_exit();
+event_failed:
+	pr_debug("stopped\n");
+	return ret;
+}
+
+security_initcall(snet_init);
+
+MODULE_DESCRIPTION("snet - Security for NETwork syscalls");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Samir Bellabes <sam@synack.fr>");
-- 
1.7.4.1
