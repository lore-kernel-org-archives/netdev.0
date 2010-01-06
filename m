From: Samir Bellabes <sam@synack.fr>
Subject: Re: [RFC 4/9] snet: introduce snet_core.c and snet.h
Date: Wed, 06 Jan 2010 19:23:33 +0100
Message-ID: <m23a2jnlcq.fsf@ssh.synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
	<1262437456-24476-5-git-send-email-sam@synack.fr>
	<4B41FE9D.2070708@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-security-module@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <4B41FE9D.2070708@trash.net> (Patrick McHardy's message of "Mon,
	04 Jan 2010 15:43:41 +0100")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Patrick McHardy <kaber@trash.net> writes:

>> +#define SNET_PRINTK(enable, fmt, arg...)			\
>> +	do {							\
>> +		if (enable)					\
>> +			printk(KERN_INFO "%s: %s: " fmt ,	\
>> +				SNET_NAME , __func__ ,		\
>> +				## arg);			\
>> +	} while (0)
>
> How about using pr_debug()?

right. I moved the code to use pr_debug()
here is the patch

commit 2ca568b34357c8f744a75e3c8191054e23bf5ff2
Author: Samir Bellabes <sam@synack.fr>
Date:   Wed Jan 6 19:09:33 2010 +0100

    snet: use pr_debug() for debug logging
    
    Noticed by Patrick McHardy <kaber@trash.net>
    
    Signed-off-by: Samir Bellabes <sam@synack.fr>

diff --git a/security/snet/Kconfig b/security/snet/Kconfig
index 547a524..6dabd7d 100644
--- a/security/snet/Kconfig
+++ b/security/snet/Kconfig
@@ -9,14 +9,3 @@ config SECURITY_SNET
 	---help---
 	If this option is enabled, the kernel will include support for reporting
 	networking's syscalls to userspace and wait for a verdict
-
-config SECURITY_SNET_DEBUG
-       bool "snet debug messages"
-       depends on SECURITY_SNET
-       ---help---
-       Only use if you are hacking snet.
-
-       This toggles the debugging outputs, by setting the parameter snet_debug
-       to 0 or 1 at boot.
-
-       Just say N
diff --git a/security/snet/include/snet.h b/security/snet/include/snet.h
index b664a47..47da614 100644
--- a/security/snet/include/snet.h
+++ b/security/snet/include/snet.h
@@ -6,21 +6,6 @@
 #define SNET_VERSION	0x1
 #define SNET_NAME	"snet"
 
-#define SNET_PRINTK(enable, fmt, arg...)			\
-	do {							\
-		if (enable)					\
-			printk(KERN_INFO "%s: %s: " fmt ,	\
-				SNET_NAME , __func__ ,		\
-				## arg);			\
-	} while (0)
-
-#ifdef CONFIG_SECURITY_SNET_DEBUG
-extern unsigned int snet_debug;
-#define snet_dbg(fmt, arg...)	SNET_PRINTK(snet_debug, fmt, ##arg)
-#else
-#define snet_dbg(fmt, arg...)
-#endif
-
 struct snet_event {
 	enum snet_syscall syscall;
 	u8 protocol;
diff --git a/security/snet/snet_core.c b/security/snet/snet_core.c
index 1ef1313..35f0c71 100644
--- a/security/snet/snet_core.c
+++ b/security/snet/snet_core.c
@@ -25,27 +25,20 @@ unsigned int snet_verdict_policy = SNET_VERDICT_GRANT;	/* permissive by default
 module_param(snet_verdict_policy, uint, 0400);
 MODULE_PARM_DESC(snet_verdict_policy, "Set the default verdict");
 
-#ifdef CONFIG_SECURITY_SNET_DEBUG
-unsigned int snet_debug;
-EXPORT_SYMBOL_GPL(snet_debug);
-module_param(snet_debug, bool, 0644);
-MODULE_PARM_DESC(snet_debug, "Enable debug messages");
-#endif
-
 void snet_core_exit(void)
 {
 	snet_netlink_exit();
 	snet_event_exit();
 	snet_hooks_exit();
 	snet_verdict_exit();
-	snet_dbg("stopped\n");
+	pr_debug("stopped\n");
 }
 
 static __init int snet_init(void)
 {
 	int ret;
 
-	snet_dbg("initializing: event_hash_size=%u "
+	pr_debug("initializing: event_hash_size=%u "
 		 "verdict_hash_size=%u verdict_delay=%usecs "
 		 "default_policy=%s\n",
 		 snet_evh_size, snet_vdh_size, snet_verdict_delay,
@@ -63,7 +56,7 @@ static __init int snet_init(void)
 	if (ret < 0)
 		goto exit;
 
-	snet_dbg("started\n");
+	pr_debug("started\n");
 	return 0;
 exit:
 	snet_core_exit();
diff --git a/security/snet/snet_hooks.c b/security/snet/snet_hooks.c
index 7c0e990..3980350 100644
--- a/security/snet/snet_hooks.c
+++ b/security/snet/snet_hooks.c
@@ -38,19 +38,19 @@
 #include "snet_event.h"
 
 #define SNET_DBG_V4(info)						\
-	snet_dbg("%pI4:%u->%pI4:%u\n",					\
+	pr_debug("%pI4:%u->%pI4:%u\n",					\
 		 &info.src.u3.ip, info.src.u.port,			\
 		 &info.dst.u3.ip, info.dst.u.port)
 
 #define SNET_DBG_V6(info)						\
-	snet_dbg("%pI6:%u->%pI6:%u\n",					\
+	pr_debug("%pI6:%u->%pI6:%u\n",					\
 		 &info.src.u3.ip, info.src.u.port,			\
 		 &info.dst.u3.ip, info.dst.u.port)
 
 #define SNET_CHECK_LISTENERS()						\
 do {									\
 	if (atomic_read(&snet_num_listeners) < 0) {			\
-		snet_dbg("number of listeners is negative\n");		\
+		pr_debug("number of listeners is negative\n");		\
 		verdict = SNET_VERDICT_GRANT;				\
 		goto out;						\
 	} else if (atomic_read(&snet_num_listeners) == 0) {		\
@@ -74,7 +74,7 @@ do {									\
 #define SNET_CHECK_LISTENERS_NOVERDICT()				\
 do {									\
 	if (atomic_read(&snet_num_listeners) < 0) {			\
-		snet_dbg("number of listeners is negative\n");		\
+		pr_debug("number of listeners is negative\n");		\
 		goto out;						\
 	} else if (atomic_read(&snet_num_listeners) == 0) {		\
 		goto out;						\
@@ -116,7 +116,7 @@ static int snet_socket_create(int family, int type, int protocol, int kern)
 		info.family = family;
 		info.type = type;
 
-		snet_dbg("family=%u type=%u protocol=%u kern=%u\n",
+		pr_debug("family=%u type=%u protocol=%u kern=%u\n",
 			 family, type, protocol, kern);
 
 		SNET_DO_VERDICT(info);
diff --git a/security/snet/snet_netlink.c b/security/snet/snet_netlink.c
index 51a4fd7..0b2405b 100644
--- a/security/snet/snet_netlink.c
+++ b/security/snet/snet_netlink.c
@@ -33,7 +33,7 @@ int snet_nl_send_event(struct snet_info *info)
 	if (msg_head == NULL)
 		goto send_event_failure;
 
-	snet_dbg("verdict_id=0x%x syscall=%s protocol=%u "
+	pr_debug("verdict_id=0x%x syscall=%s protocol=%u "
 		 "family=%u uid=%u pid=%u\n",
 		 info->verdict_id, snet_syscall_name(info->syscall),
 		 info->protocol, info->family, current_uid(), current->pid);
@@ -230,7 +230,7 @@ static int snet_nl_register(struct sk_buff *skb, struct genl_info *info)
 				    set_resp_flag);
 
 	snet_nl_pid = info->snd_pid;
-	snet_dbg("pid=%u num_listeners=%d\n",
+	pr_debug("pid=%u num_listeners=%d\n",
 		 snet_nl_pid, atomic_read(&snet_num_listeners));
 	return ret;
 }
@@ -254,7 +254,7 @@ static int snet_nl_unregister(struct sk_buff *skb, struct genl_info *info)
 		atomic_dec(&snet_num_listeners);
 	ret = snet_nl_response_flag(info, &snet_genl_family,
 				    SNET_C_UNREGISTER, SNET_A_UNREGISTERED, 1);
-	snet_dbg("pid=%u num_listeners=%d\n",
+	pr_debug("pid=%u num_listeners=%d\n",
 		 snet_nl_pid, atomic_read(&snet_num_listeners));
 	return ret;
 }
@@ -286,7 +286,7 @@ static int snet_nl_insert(struct sk_buff *skb, struct genl_info *info)
 	syscall = nla_get_u8(info->attrs[SNET_A_SYSCALL]);
 	protocol = nla_get_u8(info->attrs[SNET_A_PROTOCOL]);
 	ret_event = snet_event_insert(syscall, protocol);
-	snet_dbg("syscall=%s protocol=%u insert=%s\n",
+	pr_debug("syscall=%s protocol=%u insert=%s\n",
 		 snet_syscall_name(syscall), protocol,
 		 (ret_event == 0) ? "success" : "failed");
 
@@ -326,7 +326,7 @@ static int snet_nl_remove(struct sk_buff *skb, struct genl_info *info)
 	syscall = nla_get_u8(info->attrs[SNET_A_SYSCALL]);
 	protocol = nla_get_u8(info->attrs[SNET_A_PROTOCOL]);
 	ret_event = snet_event_remove(syscall, protocol);
-	snet_dbg("syscall=%s protocol=%u remove=%s\n",
+	pr_debug("syscall=%s protocol=%u remove=%s\n",
 		 snet_syscall_name(syscall), protocol,
 		 (ret_event == 0) ? "success" : "failed");
 
