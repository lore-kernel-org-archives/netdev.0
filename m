From: y@vger.kernel.org
Subject: [RFC v4 06/11] snet: introduce snet_netlink
Date: Thu,  5 May 2011 15:59:16 +0200
Message-ID: <1697.3327765756$1304604499@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Samir Bellabes <sam@synack.fr>

this patch adds the snet communication's subsystem.

snet_netlink is using genetlink for sending/receiving messages to/from userspace.
the genetlink operations permit to receive orders to manage the list of events
- events are values [syscall, protocol] - which is used to know which syscall
and protocol have to be protected. genl operations are also used to manage
communication of events to userspace, and to receive the related verdict

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_netlink.c        |  442 +++++++++++++++++++++++++++++++++++
 security/snet/snet_netlink.h        |   17 ++
 security/snet/snet_netlink_helper.c |  220 +++++++++++++++++
 security/snet/snet_netlink_helper.h |    7 +
 4 files changed, 686 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_netlink.c
 create mode 100644 security/snet/snet_netlink.h
 create mode 100644 security/snet/snet_netlink_helper.c
 create mode 100644 security/snet/snet_netlink_helper.h

diff --git a/security/snet/snet_netlink.c b/security/snet/snet_netlink.c
new file mode 100644
index 0000000..0d6cd8b
--- /dev/null
+++ b/security/snet/snet_netlink.c
@@ -0,0 +1,442 @@
+#include <linux/sched.h>
+#include <net/genetlink.h>
+#include <linux/in6.h>
+#include <linux/snet.h>
+#include "snet_netlink.h"
+#include "snet_netlink_helper.h"
+#include "snet_verdict.h"
+#include "snet_event.h"
+#include "snet_utils.h"
+
+atomic_t snet_nl_seq = ATOMIC_INIT(0);
+uint32_t snet_nl_pid;
+static struct genl_family snet_genl_family;
+
+/*
+ * snet genetlink
+ */
+int snet_nl_send_event(struct snet_info *info)
+{
+	struct sk_buff *skb_rsp;
+	void *msg_head;
+	int ret = 0, sbs = -1;
+	size_t size = 0;
+
+	sbs = snet_nl_size_by_syscall(info);
+	if (sbs < 0)
+		return -EINVAL;
+
+	size =  sbs +
+		2 * nla_total_size(sizeof(u8)) +
+		1 * nla_total_size(sizeof(u16)) +
+		(info->verdict_id ? 3 : 2) * nla_total_size(sizeof(u32));
+
+	skb_rsp = genlmsg_new(size, GFP_KERNEL);
+	if (skb_rsp == NULL)
+		return -ENOMEM;
+
+	msg_head = genlmsg_put(skb_rsp, snet_nl_pid,
+			       atomic_inc_return(&snet_nl_seq),
+			       &snet_genl_family, 0, SNET_C_VERDICT);
+	if (msg_head == NULL)
+		goto nla_put_failure;
+
+	pr_debug("verdict_id=0x%x syscall=%s protocol=%u "
+		 "family=%u uid=%u pid=%u\n",
+		 info->verdict_id, snet_syscall_name(info->syscall),
+		 info->protocol, info->family, current_uid(), current->pid);
+
+	if (info->verdict_id)
+		NLA_PUT_U32(skb_rsp, SNET_A_VERDICT_ID, info->verdict_id);
+	NLA_PUT_U16(skb_rsp, SNET_A_SYSCALL, info->syscall);
+	NLA_PUT_U8(skb_rsp, SNET_A_PROTOCOL, info->protocol);
+	NLA_PUT_U8(skb_rsp, SNET_A_FAMILY, info->family);
+	NLA_PUT_U32(skb_rsp, SNET_A_UID, current_uid());
+	NLA_PUT_U32(skb_rsp, SNET_A_PID, current->pid);
+
+	ret = snet_nl_fill_by_syscall(skb_rsp, info);
+	if (ret != 0)
+		goto nla_put_failure;
+
+	ret = genlmsg_end(skb_rsp, msg_head);
+	if (ret < 0)
+		goto nla_put_failure;
+
+	return genlmsg_unicast(&init_net, skb_rsp, snet_nl_pid);
+
+nla_put_failure:
+	kfree_skb(skb_rsp);
+	return -ECONNABORTED;
+}
+
+/*
+ * snet genetlink functions
+ */
+
+static struct genl_family snet_genl_family = {
+	.id		= GENL_ID_GENERATE,
+	.hdrsize	= 0,
+	.name		= SNET_GENL_NAME,
+	.version	= SNET_GENL_VERSION,
+	.maxattr	= SNET_A_MAX,
+};
+
+static const struct nla_policy snet_genl_policy[SNET_A_MAX + 1] = {
+	[SNET_A_VERSION]		= { .type = NLA_U32 },
+	[SNET_A_VERDICT_ID]		= { .type = NLA_U32 },
+	[SNET_A_FAMILY]			= { .type = NLA_U8 },
+	[SNET_A_SYSCALL]		= { .type = NLA_U16 },
+	[SNET_A_PROTOCOL]		= { .type = NLA_U8 },
+	[SNET_A_UID]			= { .type = NLA_U32 },
+	[SNET_A_PID]			= { .type = NLA_U32 },
+	[SNET_A_TYPE]			= { .type = NLA_U32 },
+	[SNET_A_IPV4SADDR]		= { .type = NLA_BINARY,
+					    .len = sizeof(struct in_addr) },
+	[SNET_A_IPV6SADDR]		= { .type = NLA_BINARY,
+					    .len = sizeof(struct in6_addr) },
+	[SNET_A_IPV4DADDR]		= { .type = NLA_BINARY,
+					    .len = sizeof(struct in_addr) },
+	[SNET_A_IPV6DADDR]		= { .type = NLA_BINARY,
+					    .len = sizeof(struct in6_addr) },
+	[SNET_A_SPORT]			= { .type = NLA_U16 },
+	[SNET_A_DPORT]			= { .type = NLA_U16 },
+	[SNET_A_VERDICT]		= { .type = NLA_U8 },
+	[SNET_A_VERDICT_DELAY]		= { .type = NLA_U32 },
+	[SNET_A_TICKET_DELAY]		= { .type = NLA_U32 },
+	[SNET_A_TICKET_MODE]		= { .type = NLA_U8 },
+};
+
+/**
+ * snet_nl_version - Handle a VERSION message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Process a user generated VERSION message and respond accordingly.
+ * Returns zero on success, negative values on failure.
+ */
+static int snet_nl_version(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	struct sk_buff *skb_rsp = NULL;
+	void *msg_head;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	skb_rsp = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb_rsp == NULL)
+		return -ENOMEM;
+	msg_head = genlmsg_put_reply(skb_rsp, info, &snet_genl_family,
+				     0, SNET_C_VERSION);
+	if (msg_head == NULL)
+		goto nla_put_failure;
+
+	NLA_PUT_U32(skb_rsp, SNET_A_VERSION, SNET_VERSION);
+
+	ret = genlmsg_end(skb_rsp, msg_head);
+	if (ret < 0)
+		goto nla_put_failure;
+
+	ret = genlmsg_reply(skb_rsp, info);
+	if (ret != 0)
+		goto nla_put_failure;
+	return 0;
+
+nla_put_failure:
+	kfree_skb(skb_rsp);
+	return ret;
+}
+
+/**
+ * snet_nl_register - Handle a REGISTER message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Notify the kernel that an application is listening for events.
+ * Returns zero on success, negative values on failure.
+ */
+static int snet_nl_register(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	u32 version = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (!info->attrs[SNET_A_VERSION]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	version = nla_get_u32(info->attrs[SNET_A_VERSION]);
+
+	if (version != SNET_VERSION) {
+		ret = -EPERM;
+		goto out;
+	}
+
+	if (snet_nl_pid > 0) {
+		ret = -ECONNREFUSED;
+		goto out;
+	}
+	snet_nl_pid = info->snd_pid;
+	pr_debug("pid=%u\n", snet_nl_pid);
+out:
+	return ret;
+}
+
+/**
+ * snet_nl_unregister - Handle a UNREGISTER message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Notify the kernel that the application is no more listening for events.
+ * Returns zero on success, negative values on failure.
+ */
+static int snet_nl_unregister(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (snet_nl_pid == 0) {
+		ret = -ENOTCONN;
+		goto out;
+	}
+
+	snet_nl_pid = 0;
+	pr_debug("pid=%u\n", snet_nl_pid);
+out:
+	return ret;
+}
+
+/**
+ * snet_nl_insert - Handle a INSERT message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Insert a new event to the events' hashtable. Returns zero on success,
+ * negative values on failure.
+ */
+static int snet_nl_insert(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	enum snet_syscall syscall;
+	u8 protocol;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (!info->attrs[SNET_A_SYSCALL] || !info->attrs[SNET_A_PROTOCOL]) {
+		ret =  -EINVAL;
+		goto out;
+	}
+	syscall = nla_get_u16(info->attrs[SNET_A_SYSCALL]);
+	protocol = nla_get_u8(info->attrs[SNET_A_PROTOCOL]);
+	ret = snet_event_insert(syscall, protocol);
+	pr_debug("syscall=%s protocol=%u insert=%s\n",
+		 snet_syscall_name(syscall), protocol,
+		 (ret == 0) ? "success" : "failed");
+out:
+	return ret;
+}
+
+/**
+ * snet_nl_remove - Handle a REMOVE message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Remove a event from the events' hastable. Returns zero on success,
+ * negative values on failure.
+ */
+static int snet_nl_remove(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	enum snet_syscall syscall;
+	u8 protocol;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (!info->attrs[SNET_A_SYSCALL] || !info->attrs[SNET_A_PROTOCOL]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	syscall = nla_get_u16(info->attrs[SNET_A_SYSCALL]);
+	protocol = nla_get_u8(info->attrs[SNET_A_PROTOCOL]);
+	ret = snet_event_remove(syscall, protocol);
+	pr_debug("syscall=%s protocol=%u remove=%s\n",
+		 snet_syscall_name(syscall), protocol,
+		 (ret == 0) ? "success" : "failed");
+out:
+	return ret;
+}
+
+/**
+ * snet_nl_flush - Handle a FLUSH message
+ * @skb: the NETLINK buffer
+ * @info: the Generic NETLINK info block
+ *
+ * Description:
+ * Remove all events from the hashtable. Returns zero on success,
+ * negative values on failure.
+ */
+static int snet_nl_flush(struct sk_buff *skb, struct genl_info *info)
+{
+	atomic_set(&snet_nl_seq, info->snd_seq);
+	snet_event_flush();
+	return 0;
+}
+
+int snet_nl_list_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+			   u32 flags, u8 protocol, enum snet_syscall syscall)
+{
+	void *hdr;
+
+	hdr = genlmsg_put(skb, pid, seq, &snet_genl_family, flags, SNET_C_LIST);
+	if (hdr == NULL)
+		return -1;
+
+	NLA_PUT_U16(skb, SNET_A_SYSCALL, syscall);
+	NLA_PUT_U8(skb, SNET_A_PROTOCOL, protocol);
+
+	return genlmsg_end(skb, hdr);
+
+nla_put_failure:
+	genlmsg_cancel(skb, hdr);
+	return -EMSGSIZE;
+}
+/**
+ * snet_nl_list - Handle a LIST message
+ * @skb: the NETLINK buffer
+ * @cb:
+ *
+ * Description:
+ * Process a user LIST message and respond. Returns zero on success,
+ * and negative values on error.
+ */
+static int snet_nl_list(struct sk_buff *skb, struct netlink_callback *cb)
+{
+	unsigned int len = 0;
+
+	atomic_set(&snet_nl_seq, cb->nlh->nlmsg_seq);
+	len = snet_event_fill_info(skb, cb);
+	return len;
+}
+
+/**
+ * snet_nl_verdict - Handle a VERDICT message
+ * @skb: the NETLINK buffer
+ * @info the Generic NETLINK info block
+ *
+ * Description:
+ * Provides userspace with a VERDICT message, ie we are sending informations
+ * with this command. Userspace is sending the appropriate verdict for the
+ * event. Returns zero on success,and negative values on error.
+ */
+static int snet_nl_verdict(struct sk_buff *skb, struct genl_info *info)
+{
+	int ret = 0;
+	u32 verdict_id;
+	enum snet_verdict verdict;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (snet_nl_pid == 0) {
+		ret = -ENOTCONN;
+		goto out;
+	}
+
+	if (!info->attrs[SNET_A_VERDICT_ID] || !info->attrs[SNET_A_VERDICT]) {
+		ret = -EINVAL;
+		goto out;
+	}
+	verdict_id = nla_get_u32(info->attrs[SNET_A_VERDICT_ID]);
+	verdict = nla_get_u8(info->attrs[SNET_A_VERDICT]);
+	ret = snet_verdict_set(verdict_id, verdict);
+out:
+	return ret;
+}
+
+static int snet_nl_config(struct sk_buff *skb,
+			  struct genl_info *info)
+{
+	int ret = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (info->attrs[SNET_A_VERDICT_DELAY]) {
+		unsigned int new = nla_get_u32(info->attrs[SNET_A_VERDICT_DELAY]);
+		if (new == 0) {
+			ret = -EINVAL;
+			goto out;
+		}
+		snet_verdict_delay = new;
+		pr_debug("snet_nl_config: verdict_delay=%u\n", snet_verdict_delay);
+	}
+	if (info->attrs[SNET_A_TICKET_DELAY]) {
+		unsigned int new = nla_get_u32(info->attrs[SNET_A_TICKET_DELAY]);
+		if (new == 0) {
+			ret = -EINVAL;
+			goto out;
+		}
+		snet_ticket_delay = new;
+		pr_debug("snet_nl_config: ticket_delay=%u\n", snet_ticket_delay);
+	}
+	if (info->attrs[SNET_A_TICKET_MODE]) {
+		unsigned int new = nla_get_u32(info->attrs[SNET_A_TICKET_MODE]);
+		if (new >= SNET_TICKET_INVALID) {
+			ret = -EINVAL;
+			goto out;
+		}
+		snet_ticket_mode = new;
+		pr_debug("snet_nl_config: ticket_mode=%u\n", snet_ticket_mode);
+	}
+out:
+	return ret;
+}
+
+#define SNET_GENL_OPS(_cmd, _flags, _policy, _op, _opname)	\
+	{							\
+		.cmd	= _cmd,					\
+		.flags	= _flags,				\
+		.policy	= _policy,				\
+		._op	= snet_nl_##_opname,			\
+	}
+
+static struct genl_ops snet_genl_ops[] = {
+	SNET_GENL_OPS(SNET_C_VERSION, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, version),
+	SNET_GENL_OPS(SNET_C_REGISTER, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, register),
+	SNET_GENL_OPS(SNET_C_UNREGISTER, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, unregister),
+	SNET_GENL_OPS(SNET_C_INSERT, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, insert),
+	SNET_GENL_OPS(SNET_C_REMOVE, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, remove),
+	SNET_GENL_OPS(SNET_C_FLUSH, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, flush),
+	SNET_GENL_OPS(SNET_C_LIST, GENL_ADMIN_PERM, snet_genl_policy,
+		      dumpit, list),
+	SNET_GENL_OPS(SNET_C_VERDICT, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, verdict),
+	SNET_GENL_OPS(SNET_C_CONFIG, GENL_ADMIN_PERM, snet_genl_policy,
+		      doit, config),
+};
+
+#undef SNET_GENL_OPS
+
+static __init int snet_netlink_init(void)
+{
+	return genl_register_family_with_ops(&snet_genl_family,
+					     snet_genl_ops,
+					     ARRAY_SIZE(snet_genl_ops));
+}
+
+void snet_netlink_exit(void)
+{
+	genl_unregister_family(&snet_genl_family);
+}
+
+__initcall(snet_netlink_init);
diff --git a/security/snet/snet_netlink.h b/security/snet/snet_netlink.h
new file mode 100644
index 0000000..5e80d7b
--- /dev/null
+++ b/security/snet/snet_netlink.h
@@ -0,0 +1,17 @@
+#ifndef _SNET_NETLINK_H
+#define _SNET_NETLINK_H
+
+#include <linux/in6.h>
+
+extern unsigned int snet_verdict_delay;
+extern unsigned int snet_ticket_delay;
+extern unsigned int snet_ticket_mode;
+
+int snet_nl_send_event(struct snet_info *info);
+
+int snet_nl_list_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+			   u32 flags, u8 protocol, enum snet_syscall syscall);
+
+void snet_netlink_exit(void);
+
+#endif /* _SNET_NETLINK_H */
diff --git a/security/snet/snet_netlink_helper.c b/security/snet/snet_netlink_helper.c
new file mode 100644
index 0000000..d7d743c
--- /dev/null
+++ b/security/snet/snet_netlink_helper.c
@@ -0,0 +1,220 @@
+#include <net/netlink.h>
+#include <net/genetlink.h>
+#include <linux/in6.h>
+#include <linux/snet.h>
+
+static int fill_src(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+	switch (info->family) {
+	case PF_INET:
+		ret = nla_put(skb_rsp, SNET_A_IPV4SADDR,
+			      sizeof(struct in_addr), &(info->src.u3.ip));
+		if (ret != 0)
+			goto out;
+		break;
+	case PF_INET6:
+		ret = nla_put(skb_rsp, SNET_A_IPV6SADDR,
+			      sizeof(struct in6_addr), &(info->src.u3.ip6));
+		if (ret != 0)
+			goto out;
+		break;
+	default:
+		break;
+	}
+	ret = nla_put_u16(skb_rsp, SNET_A_SPORT, info->src.u.port);
+out:
+	return ret;
+
+}
+
+static int fill_dst(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+	switch (info->family) {
+	case PF_INET:
+		ret = nla_put(skb_rsp, SNET_A_IPV4DADDR,
+			      sizeof(struct in_addr), &(info->dst.u3.ip));
+		if (ret != 0)
+			goto out;
+		break;
+	case PF_INET6:
+		ret = nla_put(skb_rsp, SNET_A_IPV6DADDR,
+			      sizeof(struct in6_addr), &(info->dst.u3.ip6));
+		if (ret != 0)
+			goto out;
+		break;
+	default:
+		break;
+	}
+	ret = nla_put_u16(skb_rsp, SNET_A_DPORT, info->dst.u.port);
+out:
+	return ret;
+}
+
+static int snet_fill_create(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+	ret = nla_put_u8(skb_rsp, SNET_A_TYPE, info->type);
+	return ret;
+}
+
+static int snet_fill_bind(struct sk_buff *skb_rsp,  struct snet_info *info)
+{
+	return fill_src(skb_rsp, info);
+}
+
+static int snet_fill_connect(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+
+	ret = fill_src(skb_rsp, info);
+	if (ret != 0)
+		goto out;
+	ret = fill_dst(skb_rsp, info);
+out:
+	return ret;
+}
+
+static int snet_fill_listen(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	return fill_src(skb_rsp, info);
+}
+
+static int snet_fill_accept(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	return fill_src(skb_rsp, info);
+}
+
+static int snet_fill_post_accept(struct sk_buff *skb_rsp,
+				 struct snet_info *info)
+{
+	int ret;
+
+	ret = fill_src(skb_rsp, info);
+	if (ret != 0)
+		goto out;
+	ret = fill_dst(skb_rsp, info);
+out:
+	return ret;
+}
+
+static int snet_fill_sendmsg(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+
+	ret = fill_src(skb_rsp, info);
+	if (ret != 0)
+		goto out;
+	ret = fill_dst(skb_rsp, info);
+out:
+	return ret;
+}
+
+static int snet_fill_recvmsg(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+
+	ret = fill_src(skb_rsp, info);
+	if (ret != 0)
+		goto out;
+	ret = fill_dst(skb_rsp, info);
+out:
+	return ret;
+}
+
+static int snet_fill_sock_rcv_skb(struct sk_buff *skb_rsp,
+				  struct snet_info *info)
+{
+	int ret;
+
+	ret = fill_src(skb_rsp, info);
+	if (ret != 0)
+		goto out;
+	ret = fill_dst(skb_rsp, info);
+out:
+	return ret;
+}
+
+static int snet_fill_close(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	int ret;
+
+	ret = fill_src(skb_rsp, info);
+	if (ret != 0)
+		goto out;
+	ret = fill_dst(skb_rsp, info);
+out:
+	return ret;
+}
+
+int snet_nl_fill_by_syscall(struct sk_buff *skb_rsp, struct snet_info *info)
+{
+	static int (*snet_df[])(struct sk_buff *, struct snet_info *) = {
+		[SNET_SOCKET_CREATE]		= &snet_fill_create,
+		[SNET_SOCKET_BIND]		= &snet_fill_bind,
+		[SNET_SOCKET_CONNECT]		= &snet_fill_connect,
+		[SNET_SOCKET_LISTEN]		= &snet_fill_listen,
+		[SNET_SOCKET_ACCEPT]		= &snet_fill_accept,
+		[SNET_SOCKET_POST_ACCEPT]	= &snet_fill_post_accept,
+		[SNET_SOCKET_SENDMSG]		= &snet_fill_sendmsg,
+		[SNET_SOCKET_RECVMSG]		= &snet_fill_recvmsg,
+		[SNET_SOCKET_SOCK_RCV_SKB]	= &snet_fill_sock_rcv_skb,
+		[SNET_SOCKET_CLOSE]		= &snet_fill_close,
+	};
+
+	if (info->syscall >= SNET_NR_SOCKET_TYPES)
+		return -EINVAL;
+	else
+		return snet_df[info->syscall](skb_rsp, info);
+}
+
+int snet_nl_size_by_syscall(struct snet_info *info)
+{
+	unsigned int size_addr4_port = nla_total_size(sizeof(struct in_addr)) +
+				       nla_total_size(sizeof(u16));
+	unsigned int size_addr6_port = nla_total_size(sizeof(struct in6_addr)) +
+				       nla_total_size(sizeof(u16));
+
+	unsigned int sbs4[] = {
+		[SNET_SOCKET_CREATE]		= nla_total_size(sizeof(u8)),
+		[SNET_SOCKET_BIND]		= size_addr4_port,
+		[SNET_SOCKET_CONNECT]		= 2 * size_addr4_port,
+		[SNET_SOCKET_LISTEN]		= size_addr4_port,
+		[SNET_SOCKET_ACCEPT]		= size_addr4_port,
+		[SNET_SOCKET_POST_ACCEPT]	= 2 * size_addr4_port,
+		[SNET_SOCKET_SENDMSG]		= 2 * size_addr4_port,
+		[SNET_SOCKET_RECVMSG]		= 2 * size_addr4_port,
+		[SNET_SOCKET_SOCK_RCV_SKB]	= 2 * size_addr4_port,
+		[SNET_SOCKET_CLOSE]		= 2 * size_addr4_port,
+	};
+
+	unsigned int sbs6[] = {
+		[SNET_SOCKET_CREATE]		= nla_total_size(sizeof(u8)),
+		[SNET_SOCKET_BIND]		= size_addr6_port,
+		[SNET_SOCKET_CONNECT]		= 2 * size_addr6_port,
+		[SNET_SOCKET_LISTEN]		= size_addr6_port,
+		[SNET_SOCKET_ACCEPT]		= size_addr6_port,
+		[SNET_SOCKET_POST_ACCEPT]	= 2 * size_addr6_port,
+		[SNET_SOCKET_SENDMSG]		= 2 * size_addr6_port,
+		[SNET_SOCKET_RECVMSG]		= 2 * size_addr6_port,
+		[SNET_SOCKET_SOCK_RCV_SKB]	= 2 * size_addr6_port,
+		[SNET_SOCKET_CLOSE]		= 2 * size_addr6_port,
+	};
+
+	if (info->syscall >= SNET_NR_SOCKET_TYPES)
+		return -EINVAL;
+	else {
+		switch (info->family) {
+		case AF_INET:
+			return sbs4[info->syscall];
+			break;
+		case AF_INET6:
+			return sbs6[info->syscall];
+			break;
+		default:
+			return -EINVAL;
+			break;
+		}
+	}
+}
diff --git a/security/snet/snet_netlink_helper.h b/security/snet/snet_netlink_helper.h
new file mode 100644
index 0000000..d12e563
--- /dev/null
+++ b/security/snet/snet_netlink_helper.h
@@ -0,0 +1,7 @@
+#ifndef _SNET_NETLINK_HELPER_H
+#define _SNET_NETLINK_HELPER_H
+
+int snet_nl_fill_by_syscall(struct sk_buff *skb_rsp, struct snet_info *info);
+int snet_nl_size_by_syscall(struct snet_info *info);
+
+#endif /* SNET_NETLINK_HELPER_H */
-- 
1.7.4.1

