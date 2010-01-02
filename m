From: Samir Bellabes <sam@synack.fr>
Subject: [RFC 7/9] snet: introduce snet_netlink.c and snet_netlink.h
Date: Sat,  2 Jan 2010 14:04:14 +0100
Message-ID: <1262437456-24476-8-git-send-email-sam@synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netfilter-devel-owner@vger.kernel.org>
In-Reply-To: <1262437456-24476-1-git-send-email-sam@synack.fr>
Sender: netfilter-devel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

this patch adds the snet communication's subsystem.

snet_netlink is using genetlink for sending/receiving messages to/from userspace.
the genetlink operations permit to receive orders to manage the table of events
- events are values [syscall, protocol] - which is used to know which syscall
and protocol have to be protected. genl operations are also used to manage
communication of events to userspace, and to receive the related verdict.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/include/snet_netlink.h |  201 +++++++++++++
 security/snet/snet_netlink.c         |  541 ++++++++++++++++++++++++++++++++++
 2 files changed, 742 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/include/snet_netlink.h
 create mode 100644 security/snet/snet_netlink.c

diff --git a/security/snet/include/snet_netlink.h b/security/snet/include/snet_netlink.h
new file mode 100644
index 0000000..d739f66
--- /dev/null
+++ b/security/snet/include/snet_netlink.h
@@ -0,0 +1,201 @@
+#ifndef _SNET_NETLINK_H
+#define _SNET_NETLINK_H
+
+/*
+ * The following payloads are supported.
+ *
+ * o VERSION:
+ *   Sent by an application to verify the snet version.
+ *   When sent by an application, there is no payload.
+ *   When sent by the kernel, it's a response to an VERSION request.
+ *
+ *   Required attributes:
+ *
+ *     SNET_A_VERSION
+ *
+ * o REGISTER:
+ *   Sent by an application to notify listening for events.
+ *
+ * o UNREGISTER:
+ *   Sent by an application to notify unlistening for events.
+ *
+ * o INSERT:
+ *   Sent by an application to insert a new event.
+ *
+ *   Required attributes:
+ *
+ *     SNET_A_SYSCALL
+ *     SNET_A_PROTOCOL
+ *
+ * o REMOVE
+ *   Sent by an application to remove a event.
+ *
+ *   Required attributes:
+ *
+ *     SNET_A_SYSCALL
+ *     SNET_A_PROTOCOL
+ *
+ * o FLUSH
+ *   Sent by an application to flush the events' hashtable
+ *
+ * o LIST
+ *   Sent by an application to list all events on the hashtable.
+ *   When sent by an application there is no payload and the NLM_F_DUMP
+ *   flag should be set. The kernel should respond with a series of
+ *   the following messages.
+ *
+ * o VERDICT
+ *   kernel -> userspace
+ *   Sent by the kernel to notify for a syscall is pending for a
+ *   verdict or to notify for a network event.
+ *
+ *   Required attributes:
+ *
+ *     SNET_A_VERDICT_ID
+ *     SNET_A_SYSCALL
+ *     SNET_A_PROTOCOL
+ *     SNET_A_FAMILY
+ *     SNET_A_UID
+ *     SNET_A_PID
+ *
+ *   If using SNET_SOCKET_CREATE
+ *   the following attributes are required:
+ *
+ *     SNET_A_TYPE
+ *
+ *   If using SNET_SOCKET_LISTEN or SNET_SOCKET_BIND or SNET_SOCKET_ACCEPT
+ *   the following attributes are required:
+ *
+ *     SNET_A_SADDR or SNET_A_SADDR6 depending on sk->family
+ *     SNET_A_SPORT
+ *
+ *   If using SNET_SOCKET_CONNECT
+ *   the following attributes are required:
+ *
+ *     SNET_A_SADDR or SNET_A_SADDR6 depending on sk->family
+ *     SNET_A_DADDR or SNET_A_DADDR6 depending on sk->family
+ *     SNET_A_SPORT
+ *     SNET_A_DPORT
+ *
+ *   If using SNET_SOCKET_SENDMSG
+ *   the following attributes are required:
+ *
+ *     SNET_A_SADDR or SNET_A_SADDR6 depending on sk->family
+ *     SNET_A_DADDR or SNET_A_DADDR6 depending on sk->family
+ *     SNET_A_SPORT
+ *     SNET_A_DPORT
+ *     SNET_A_BUFFER_LEN (msg->msg_iov->iov_len)
+ *     SNET_A_BUFFER     (msg->msg_iov->iov_base)
+ *
+ *   If using SNET_SOCKET_RECVMSG
+ *   the following attributes are required:
+ *
+ *     SNET_A_SADDR or SNET_A_SADDR6 depending on sk->family
+ *     SNET_A_DADDR or SNET_A_DADDR6 depending on sk->family
+ *     SNET_A_SPORT
+ *     SNET_A_DPORT
+ *
+ *   If using SNET_SOCKET_SOCK_RCV_SKB
+ *   the following attributes are required:
+ *
+ *     SNET_A_SADDR or SNET_A_SADDR6 depending on sk->family
+ *     SNET_A_DADDR or SNET_A_DADDR6 depending on sk->family
+ *     SNET_A_SPORT
+ *     SNET_A_DPORT
+ *     SNET_A_BUFFER_LEN ()
+ *     SNET_A_BUFFER     ()
+ *
+ *   userspace -> kernel
+ *   Sent by a application to set the verdict for a pending event.
+ *
+ *   Required attributes:
+ *
+ *     SNET_A_VERDICT_ID
+ *     SNET_A_VERDICT
+ *
+ * o VERDICT_DELAY
+ *   Sent by an application to set the timeout value for verdicts.
+ *
+ *   Required attributes:
+ *
+ *     SNET_A_VERDICT_DELAY
+ *
+ */
+
+#include <linux/in6.h>
+#include "snet_hooks.h"
+
+extern unsigned int snet_verdict_delay;
+
+/* commands */
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
+	SNET_C_VERDICT_DELAY,
+	__SNET_C_MAX,
+};
+
+#define SNET_C_MAX (__SNET_C_MAX - 1)
+
+/* attributes */
+enum {
+	SNET_A_UNSPEC,
+	SNET_A_VERSION,		/* (NLA_U32) the snet protocol version	*/
+	SNET_A_SYSCALL,		/* (NLA_U8)  a syscall identifier	*/
+	SNET_A_PROTOCOL,	/* (NLA_U8)  a protocol identifier	*/
+	SNET_A_INSERTED,
+	SNET_A_REMOVED,
+	SNET_A_FLUSHED,
+	SNET_A_REGISTERED,
+	SNET_A_UNREGISTERED,
+	SNET_A_VERDICT_ID,
+	SNET_A_FAMILY,
+	SNET_A_UID,
+	SNET_A_PID,
+	SNET_A_VERDICT,
+	SNET_A_DATA_EXT,
+	SNET_A_VERDICT_DELAY,
+	SNET_A_VERDICT_DELAYED,
+	__SNET_A_MAX,
+};
+
+#define SNET_A_MAX (__SNET_A_MAX - 1)
+
+#define SNET_GENL_NAME		"SNET"
+#define SNET_GENL_VERSION	SNET_VERSION
+
+int snet_nl_send_event(const u32 verdict_id, const enum snet_syscall syscall,
+		       const u8 protocol, const u8 family, void *data,
+		       const unsigned int len);
+
+int snet_nl_list_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+			   u32 flags, u8 protocol, enum snet_syscall syscall);
+
+void snet_netlink_exit(void);
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
+struct snet_sock_info {
+	struct snet_sock_half src;
+	struct snet_sock_half dst;
+	int type;
+};
+
+#endif /* _SNET_NETLINK_H */
diff --git a/security/snet/snet_netlink.c b/security/snet/snet_netlink.c
new file mode 100644
index 0000000..cc21d6c
--- /dev/null
+++ b/security/snet/snet_netlink.c
@@ -0,0 +1,541 @@
+#include <linux/sched.h>
+#include <net/genetlink.h>
+#include <linux/in6.h>
+
+#include "snet.h"
+#include "snet_netlink.h"
+#include "snet_verdict.h"
+#include "snet_event.h"
+#include <snet_utils.h>
+
+atomic_t snet_nl_seq = ATOMIC_INIT(0);
+static uint32_t snet_nl_pid;
+static struct genl_family snet_genl_family;
+atomic_t snet_num_listeners = ATOMIC_INIT(0);
+
+/*
+ * snet genetlink
+ */
+int snet_nl_send_event(const u32 verdict_id, const enum snet_syscall syscall,
+		       const u8 protocol, const u8 family, void *data,
+		       const unsigned int len)
+{
+	struct sk_buff *skb_rsp;
+	void *msg_head;
+	int ret = -ENOMEM;
+
+	skb_rsp = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb_rsp == NULL)
+		return 0;
+
+	msg_head = genlmsg_put(skb_rsp, snet_nl_pid,
+			       atomic_inc_return(&snet_nl_seq),
+			       &snet_genl_family, 0, SNET_C_VERDICT);
+	if (msg_head == NULL)
+		goto send_event_failure;
+
+	snet_dbg("verdict_id=0x%x syscall=%s protocol=%u "
+		 "family=%u uid=%u pid=%u\n",
+		 verdict_id, snet_syscall_name(syscall),
+		 protocol, family, current_uid(), current->pid);
+
+	if (verdict_id) {
+		ret = nla_put_u32(skb_rsp, SNET_A_VERDICT_ID, verdict_id);
+		if (ret != 0)
+			goto send_event_failure;
+	}
+	ret = nla_put_u8(skb_rsp, SNET_A_SYSCALL, syscall);
+	if (ret != 0)
+		goto send_event_failure;
+	ret = nla_put_u8(skb_rsp, SNET_A_PROTOCOL, protocol);
+	if (ret != 0)
+		goto send_event_failure;
+	ret = nla_put_u8(skb_rsp, SNET_A_FAMILY, family);
+	if (ret != 0)
+		goto send_event_failure;
+	ret = nla_put_u32(skb_rsp, SNET_A_UID, current_uid());
+	if (ret != 0)
+		goto send_event_failure;
+	ret = nla_put_u32(skb_rsp, SNET_A_PID, current->pid);
+	if (ret != 0)
+		goto send_event_failure;
+	ret = nla_put(skb_rsp, SNET_A_DATA_EXT, len, data);
+	if (ret != 0)
+		goto send_event_failure;
+
+	ret = genlmsg_end(skb_rsp, msg_head);
+	if (ret < 0)
+		goto send_event_failure;
+
+	genlmsg_unicast(&init_net, skb_rsp, snet_nl_pid);
+	return 0;
+
+send_event_failure:
+	kfree_skb(skb_rsp);
+	return 0;
+}
+
+/*
+ * snet genetlink helper functions
+ */
+static int snet_nl_response_flag(struct genl_info *info,
+				 struct genl_family *family,
+				 u8 cmd, int attrtype, u8 set_resp_flag)
+{
+	int ret = -EINVAL;
+	struct sk_buff *skb_rsp = NULL;
+	void *msg_head;
+
+	skb_rsp = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb_rsp == NULL)
+		return -ENOMEM;
+	msg_head = genlmsg_put_reply(skb_rsp, info, family, 0, cmd);
+	if (msg_head == NULL)
+		goto response_failure;
+
+	/* we put flag only if it is asked */
+	if (set_resp_flag) {
+		ret = nla_put_flag(skb_rsp, attrtype);
+		if (ret != 0)
+			goto response_failure;
+	}
+
+	genlmsg_end(skb_rsp, msg_head);
+	ret = genlmsg_reply(skb_rsp, info);
+	if (ret != 0)
+		goto response_failure;
+	return 0;
+
+response_failure:
+	kfree_skb(skb_rsp);
+	return ret;
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
+static const struct nla_policy snet_genl_policy[SNET_A_MAX + 1]
+__read_mostly = {
+	[SNET_A_VERSION]		= { .type = NLA_U32 },
+	[SNET_A_SYSCALL]		= { .type = NLA_U8 },
+	[SNET_A_PROTOCOL]		= { .type = NLA_U8 },
+	[SNET_A_INSERTED]		= { .type = NLA_FLAG },
+	[SNET_A_REMOVED]		= { .type = NLA_FLAG },
+	[SNET_A_FLUSHED]		= { .type = NLA_FLAG },
+	[SNET_A_REGISTERED]		= { .type = NLA_FLAG },
+	[SNET_A_UNREGISTERED]		= { .type = NLA_FLAG },
+	[SNET_A_VERDICT_ID]		= { .type = NLA_U32 },
+	[SNET_A_FAMILY]			= { .type = NLA_U8 },
+	[SNET_A_UID]			= { .type = NLA_U32 },
+	[SNET_A_PID]			= { .type = NLA_U32 },
+	[SNET_A_VERDICT]		= { .type = NLA_U8 },
+	[SNET_A_DATA_EXT]		= { .type = NLA_BINARY,
+					    .len = sizeof(struct snet_sock_info) },
+	[SNET_A_VERDICT_DELAY]		= { .type = NLA_U32 },
+	[SNET_A_VERDICT_DELAYED]	= { .type = NLA_FLAG },
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
+	int ret = -ENOMEM;
+	struct sk_buff *skb_rsp = NULL;
+	void *msg_head;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners) <= 0)
+		return 0;
+
+	skb_rsp = genlmsg_new(NLMSG_GOODSIZE, GFP_KERNEL);
+	if (skb_rsp == NULL)
+		return -ENOMEM;
+	msg_head = genlmsg_put_reply(skb_rsp, info, &snet_genl_family,
+				     0, SNET_C_VERSION);
+	if (msg_head == NULL)
+		goto version_failure;
+
+	ret = nla_put_u32(skb_rsp, SNET_A_VERSION, SNET_VERSION);
+	if (ret != 0)
+		goto version_failure;
+
+	genlmsg_end(skb_rsp, msg_head);
+
+	ret = genlmsg_reply(skb_rsp, info);
+	if (ret != 0)
+		goto version_failure;
+	return 0;
+
+version_failure:
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
+	int ret = -EINVAL;
+	u32 version = 0;
+	u8 set_resp_flag = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (!info->attrs[SNET_A_VERSION])
+		return -EINVAL;
+	version = nla_get_u32(info->attrs[SNET_A_VERSION]);
+
+	if (version == SNET_VERSION) {	/* version is compliant */
+		atomic_inc(&snet_num_listeners);
+		set_resp_flag = 1;
+	}
+
+	ret = snet_nl_response_flag(info, &snet_genl_family,
+				    SNET_C_REGISTER, SNET_A_REGISTERED,
+				    set_resp_flag);
+
+	snet_nl_pid = info->snd_pid;
+	snet_dbg("pid=%u num_listeners=%d\n",
+		 snet_nl_pid, atomic_read(&snet_num_listeners));
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
+	int ret = -EINVAL;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners))
+		atomic_dec(&snet_num_listeners);
+	ret = snet_nl_response_flag(info, &snet_genl_family,
+				    SNET_C_UNREGISTER, SNET_A_UNREGISTERED, 1);
+	snet_dbg("pid=%u num_listeners=%d\n",
+		 snet_nl_pid, atomic_read(&snet_num_listeners));
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
+	int ret_event = -EINVAL, ret = -EINVAL;
+	enum snet_syscall syscall;
+	u8 protocol;
+	u8 set_resp_flag = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners) <= 0)
+		return 0;
+
+	if (!info->attrs[SNET_A_SYSCALL] || !info->attrs[SNET_A_PROTOCOL])
+		return -EINVAL;
+
+	syscall = nla_get_u8(info->attrs[SNET_A_SYSCALL]);
+	protocol = nla_get_u8(info->attrs[SNET_A_PROTOCOL]);
+	ret_event = snet_event_insert(syscall, protocol);
+	snet_dbg("syscall=%s protocol=%u insert=%s\n",
+		 snet_syscall_name(syscall), protocol,
+		 (ret_event == 0) ? "success" : "failed");
+
+	if (ret_event == 0)
+		set_resp_flag = 1;
+
+	ret = snet_nl_response_flag(info, &snet_genl_family,
+				    SNET_C_INSERT, SNET_A_INSERTED,
+				    set_resp_flag);
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
+	int ret_event = -EINVAL, ret = -EINVAL;
+	enum snet_syscall syscall;
+	u8 protocol;
+	u8 set_resp_flag = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners) <= 0)
+		return 0;
+
+	if (!info->attrs[SNET_A_SYSCALL] || !info->attrs[SNET_A_PROTOCOL])
+		return -EINVAL;
+
+	syscall = nla_get_u8(info->attrs[SNET_A_SYSCALL]);
+	protocol = nla_get_u8(info->attrs[SNET_A_PROTOCOL]);
+	ret_event = snet_event_remove(syscall, protocol);
+	snet_dbg("syscall=%s protocol=%u remove=%s\n",
+		 snet_syscall_name(syscall), protocol,
+		 (ret_event == 0) ? "success" : "failed");
+
+	if (ret_event == 0)
+		set_resp_flag = 1;
+
+	ret = snet_nl_response_flag(info, &snet_genl_family,
+				    SNET_C_REMOVE, SNET_A_REMOVED,
+				    set_resp_flag);
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
+	int ret = -EINVAL;
+	u8 set_resp_flag = 0;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners) <= 0)
+		return 0;
+
+	snet_event_flush();
+
+	set_resp_flag = 1;
+
+	ret = snet_nl_response_flag(info, &snet_genl_family,
+				    SNET_C_FLUSH, SNET_A_FLUSHED,
+				    set_resp_flag);
+	return ret;
+}
+
+int snet_nl_list_fill_info(struct sk_buff *skb, u32 pid, u32 seq,
+			   u32 flags, u8 protocol, enum snet_syscall syscall)
+{
+	void *hdr;
+	int ret = -1;
+
+	hdr = genlmsg_put(skb, pid, seq, &snet_genl_family, flags, SNET_C_LIST);
+	if (hdr == NULL)
+		return -1;
+
+	ret = nla_put_u8(skb, SNET_A_SYSCALL, syscall);
+	if (ret != 0)
+		goto list_failure;
+
+	ret = nla_put_u8(skb, SNET_A_PROTOCOL, protocol);
+	if (ret != 0)
+		goto list_failure;
+
+	return genlmsg_end(skb, hdr);
+
+list_failure:
+	genlmsg_cancel(skb, hdr);
+	return 0;
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
+static int snet_nl_verdict(struct sk_buff *skb,
+			   struct genl_info *info)
+{
+	u32 verdict_id;
+	enum snet_verdict verdict;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners) <= 0)
+		return 0;
+
+	if (!info->attrs[SNET_A_VERDICT_ID] || !info->attrs[SNET_A_VERDICT])
+		return -EINVAL;
+
+	verdict_id = nla_get_u32(info->attrs[SNET_A_VERDICT_ID]);
+	verdict = nla_get_u8(info->attrs[SNET_A_VERDICT]);
+	snet_verdict_set(verdict_id, verdict);
+	return 0;
+}
+
+/**
+ * snet_nl_verdict_delay - Handle a VERDICT_DELAY message
+ * @skb: the NETLINK buffer
+ * @info the Generic NETLINK info block
+ *
+ * Description:
+ * Provides userspace with a VERDICT_DELAY message, ie userspace application
+ * is able to set the value of the timeout for verdicts
+ * Returns zero on success, and negative values on error.
+ */
+static int snet_nl_verdict_delay(struct sk_buff *skb,
+				 struct genl_info *info)
+{
+	int ret = -EINVAL;
+
+	atomic_set(&snet_nl_seq, info->snd_seq);
+
+	if (atomic_read(&snet_num_listeners) <= 0)
+		return 0;
+
+	if (!info->attrs[SNET_A_VERDICT_DELAY])
+		return -EINVAL;
+
+	snet_verdict_delay = nla_get_u32(info->attrs[SNET_A_VERDICT_DELAY]);
+	/* FIXME: do something */
+	ret = snet_nl_response_flag(info, &snet_genl_family,
+				    SNET_C_VERDICT_DELAY, SNET_A_VERDICT_DELAYED,
+				    1);
+	return ret;
+}
+
+static struct genl_ops snet_genl_ops[] = {
+	{
+		.cmd		= SNET_C_VERSION,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_version,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_REGISTER,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_register,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_UNREGISTER,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_unregister,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_INSERT,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_insert,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_REMOVE,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_remove,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_FLUSH,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_flush,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_LIST,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= NULL,
+		.dumpit		= snet_nl_list,
+	},
+	{
+		.cmd		= SNET_C_VERDICT,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_verdict,
+		.dumpit		= NULL,
+	},
+	{
+		.cmd		= SNET_C_VERDICT_DELAY,
+		.flags		= GENL_ADMIN_PERM,
+		.policy		= snet_genl_policy,
+		.doit		= snet_nl_verdict_delay,
+		.dumpit		= NULL,
+	},
+};
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
-- 
1.6.3.3

