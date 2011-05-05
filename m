From: y@vger.kernel.org
Subject: [RFC v4 05/11] snet: introduce snet_hooks
Date: Thu,  5 May 2011 15:59:15 +0200
Message-ID: <40889.4938686446$1304604500@news.gmane.org>
References: <1304603961-2517-1-git-send-email-y>
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, jamal <hadi@cyberus.ca>,
	Patrick McHardy <kaber@trash.net>,
	Grzegorz Nosek <root@localdomain.pl>,
	Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 236.121.91-79.rev.gaoland.net ([79.91.121.236]:43803 "EHLO
	mx.synack.fr" rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1754685Ab1EEOHA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 5 May 2011 10:07:00 -0400
In-Reply-To: <1304603961-2517-1-git-send-email-y>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Samir Bellabes <sam@synack.fr>

This patch adds the snet LSM's subsystem

snet_hooks provides the security hook's functions and the security_operations
structure. Currently hook functions are only related to network stack.

For each hook function, there is a generic mecanism:
 0. check if the event [syscall, protocol] is registered
 1. prepare informations for userspace
 2. send informations to userspace (snet_netlink)
 3. wait for verdict from userspace (snet_verdict)
 4. apply verdict for the syscall

steps 3 and 4 are only valid for LSM hooks which are returning a value (a way to
'filter' the syscall). For hooks returning 'void', steps 3 and 4 don't exist,
but snet sends security informations to userspace (step 2) to update the global
security policy.

Signed-off-by: Samir Bellabes <sam@synack.fr>
---
 security/snet/snet_hooks.c |  764 ++++++++++++++++++++++++++++++++++++++++++++
 security/snet/snet_hooks.h |   10 +
 2 files changed, 774 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_hooks.c
 create mode 100644 security/snet/snet_hooks.h

diff --git a/security/snet/snet_hooks.c b/security/snet/snet_hooks.c
new file mode 100644
index 0000000..1d2f9b1
--- /dev/null
+++ b/security/snet/snet_hooks.c
@@ -0,0 +1,764 @@
+/*
+ * snet_hook.c
+ *
+ * here are interesting informations which can be picked up from hooks.
+ *
+ *
+ * SOCKET_CREATE:
+ *	family, type, protocol
+ * SOCKET_BIND:
+ *	family, protocol, saddr, sport
+ * SOCKET_CONNECT:
+ *	family, protocol, saddr, sport, daddr, dport
+ * SOCKET_LISTEN:
+ *	family, protocol, saddr, sport
+ * SOCKET_ACCEPT:
+ *	family, protocol, saddr, sport
+ *
+ * SOCKET_SENDMSG:
+ * SOCKET_RECVMSG:
+ * SOCKET_SOCK_RCV_SKB:
+ *
+ *
+ */
+
+#include <linux/skbuff.h>
+#include <linux/security.h>
+#include <linux/net.h>
+#include <net/sock.h>
+#include <linux/in.h>
+#include <linux/in6.h>
+#include <net/inet_sock.h>
+#include <linux/ipv6.h>
+#include <linux/snet.h>
+#include <linux/uio.h>
+#include "snet_hooks.h"
+#include "snet_verdict.h"
+#include "snet_netlink.h"
+#include "snet_event.h"
+#include "snet_ticket.h"
+#include "snet_stats.h"
+
+static inline void  snet_pr_tuple(struct snet_info *info)
+{
+	switch (info->family) {
+	case AF_INET:
+		pr_debug("%pI4:%u->%pI4:%u\n",
+			 &info->src.u3.ip, info->src.u.port,
+			 &info->dst.u3.ip, info->dst.u.port);
+		break;
+	case AF_INET6:
+		pr_debug("%pI6:%u->%pI6:%u\n",
+			 &info->src.u3.ip6, info->src.u.port,
+			 &info->dst.u3.ip6, info->dst.u.port);
+		break;
+	default:
+		break;
+	}
+	return;
+}
+
+static inline int snet_check_listeners(enum snet_verdict *verdict)
+{
+	if (snet_nl_pid == 0 || snet_nl_pid == current->pid ) {
+		if (verdict != NULL)
+			*verdict = SNET_VERDICT_GRANT;
+		return -1;
+	}
+	return 0;
+}
+
+static void snet_do_verdict(enum snet_verdict *verdict, struct snet_info *info)
+{
+	if (info->verdict_id == 0)
+		return;
+	/* sending networking informations to userspace */
+	if (snet_nl_send_event(info) == 0)
+		/* waiting for userspace reply or timeout */
+		*verdict = snet_verdict_wait(info->verdict_id);
+	/* removing verdict */
+	snet_verdict_remove(info->verdict_id);
+	return;
+}
+
+static int snet_do_send_event(struct snet_info *info)
+{
+	return snet_nl_send_event(info);
+}
+
+/*
+ * security operations helper functions
+ */
+
+/*
+ * security operations functions members
+ */
+
+static int snet_socket_create(int family, int type, int protocol, int kern)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+
+	/* if (kern) */
+	/*	;		/\* do something smart *\/ */
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_CREATE);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	if (snet_event_is_registered(SNET_SOCKET_CREATE, protocol)) {
+		struct snet_info info;
+
+		/* inserting verdict PENDING */
+		info.verdict_id = snet_verdict_insert();
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_CREATE;
+		info.protocol = protocol;
+		info.family = family;
+		info.type = type;
+
+		pr_debug("family=%u type=%u protocol=%u kern=%u\n",
+			 family, type, protocol, kern);
+
+		snet_do_verdict(&verdict, &info);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_CREATE);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_CREATE);
+	}
+
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+
+out:
+	return verdict;
+}
+
+static int snet_socket_bind(struct socket *sock,
+			    struct sockaddr *address, int addrlen)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_BIND);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_BIND, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+		struct sockaddr_in *a = (struct sockaddr_in *) address;
+		struct sockaddr_in6 *a6 = (struct sockaddr_in6 *) address;
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_BIND;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = a->sin_addr.s_addr;
+			info.dst.u3.ip = inet->inet_daddr;
+			info.src.u.port = ntohs(a->sin_port);
+			/* check tickets */
+			verdict = snet_ticket_check(&info) ;
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&a6->sin6_addr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			info.src.u.port = ntohs(a6->sin6_port);
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		snet_do_verdict(&verdict, &info);
+		/* create ticket */
+		snet_ticket_create(&info, verdict);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_BIND);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_BIND);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static int snet_socket_connect(struct socket *sock,
+			       struct sockaddr *address, int addrlen)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_CONNECT);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_CONNECT, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+		struct sockaddr_in *a = (struct sockaddr_in *) address;
+		struct sockaddr_in6 *a6 = (struct sockaddr_in6 *) address;
+
+		/* prepare networking informations for userspace */
+		memset(&info, 0, sizeof(struct  snet_info));
+		info.syscall = SNET_SOCKET_CONNECT;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.src.u.port = ntohs(inet->inet_sport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = a->sin_addr.s_addr;
+			info.dst.u.port = ntohs(a->sin_port);
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&a6->sin6_addr,
+			       sizeof(info.dst.u3.ip6));
+			info.dst.u.port = ntohs(a6->sin6_port);
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		snet_do_verdict(&verdict, &info);
+		/* create ticket */
+		snet_ticket_create(&info, verdict);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_CONNECT);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_CONNECT);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static int snet_socket_listen(struct socket *sock, int backlog)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_LISTEN);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_LISTEN, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		memset(&info, 0, sizeof(struct  snet_info));
+		info.syscall = SNET_SOCKET_LISTEN;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		snet_do_verdict(&verdict, &info);
+		/* create ticket */
+		snet_ticket_create(&info, verdict);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_LISTEN);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_LISTEN);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static int snet_socket_accept(struct socket *sock, struct socket *newsock)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_ACCEPT);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_ACCEPT, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_ACCEPT;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		snet_do_verdict(&verdict, &info);
+		/* create ticket */
+		snet_ticket_create(&info, verdict);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_ACCEPT);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_ACCEPT);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static void snet_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_POST_ACCEPT);
+
+	if (snet_check_listeners(NULL)  < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_POST_ACCEPT, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(newsock->sk);
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_POST_ACCEPT;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.verdict_id = 0;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			break;
+#endif
+		default:
+			goto out;
+			break;
+		}
+		snet_pr_tuple(&info);
+		if (snet_do_send_event(&info) < 0)
+			SNET_STATS_INC(SNET_STATS_REG_ERROR,
+				       SNET_SOCKET_POST_ACCEPT);
+		else
+			SNET_STATS_INC(SNET_STATS_REG_GRANT,
+				       SNET_SOCKET_POST_ACCEPT);
+	}
+out:
+	return;
+}
+
+static int snet_socket_sendmsg(struct socket *sock,
+			       struct msghdr *msg, int size)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_SENDMSG);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_SENDMSG, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_SENDMSG;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		snet_do_verdict(&verdict, &info);
+		/* create ticket */
+		snet_ticket_create(&info, verdict);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_SENDMSG);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_SENDMSG);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static int snet_socket_recvmsg(struct socket *sock,
+			       struct msghdr *msg, int size, int flags)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_RECVMSG);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_RECVMSG, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_RECVMSG;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			/* check tickets */
+			verdict = snet_ticket_check(&info);
+			if (verdict != SNET_VERDICT_NONE)
+				goto out;
+			/* inserting verdict PENDING */
+			info.verdict_id = snet_verdict_insert();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		snet_do_verdict(&verdict, &info);
+		/* create ticket */
+		snet_ticket_create(&info, verdict);
+		snet_stats_inc_reg(verdict, SNET_SOCKET_RECVMSG);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_RECVMSG);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static int snet_socket_sock_rcv_skb(struct sock *sk, struct sk_buff *skb)
+{
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_SOCK_RCV_SKB);
+
+	if (snet_check_listeners(&verdict) < 0)
+		goto out;
+
+	protocol = sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_SOCK_RCV_SKB, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sk);
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_SOCK_RCV_SKB;
+		info.protocol = protocol;
+		info.family = sk->sk_family;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING  */
+			/* info.verdict_id = snet_verdict_insert(); */
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING  */
+			/* info.verdict_id = snet_verdict_insert(); */
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+		snet_pr_tuple(&info);
+		/* SNET_DOC_VERDICT(info); */
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+		SNET_STATS_INC(SNET_STATS_UNREG, SNET_SOCKET_SOCK_RCV_SKB);
+	}
+
+skip_send_wait:
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+out:
+	return verdict;
+}
+
+static void snet_socket_close(struct socket *sock)
+{
+	u8 protocol = 0;
+
+	if (sock == NULL || sock->sk == NULL) {
+		goto out;
+	}
+
+	SNET_STATS_INC(SNET_STATS_EXEC, SNET_SOCKET_CLOSE);
+
+	if (snet_check_listeners(NULL)  < 0)
+		goto out;
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_CLOSE, protocol)) {
+		struct snet_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.syscall = SNET_SOCKET_CLOSE;
+		info.protocol = protocol;
+		info.family = sock->sk->sk_family;
+		info.verdict_id = 0;
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			break;
+#endif
+		default:
+			goto out;
+			break;
+		}
+		snet_pr_tuple(&info);
+		if (snet_do_send_event(&info) < 0)
+			SNET_STATS_INC(SNET_STATS_REG_ERROR, SNET_SOCKET_CLOSE);
+		else
+			SNET_STATS_INC(SNET_STATS_REG_GRANT, SNET_SOCKET_CLOSE);
+	}
+out:
+	return;
+}
+
+static struct security_operations snet_security_ops = {
+	.name			= "snet",
+
+	.socket_create		= snet_socket_create,
+	.socket_bind		= snet_socket_bind,
+	.socket_connect		= snet_socket_connect,
+	.socket_listen		= snet_socket_listen,
+	.socket_accept		= snet_socket_accept,
+	.socket_post_accept	= snet_socket_post_accept,
+	.socket_sendmsg		= snet_socket_sendmsg,
+	.socket_recvmsg		= snet_socket_recvmsg,
+	.socket_sock_rcv_skb	= snet_socket_sock_rcv_skb,
+	.socket_close		= snet_socket_close,
+
+	.cred_prepare		= snet_prepare_creds,
+	.cred_free		= snet_cred_free,
+};
+
+int snet_hooks_init(void)
+{
+	if (!security_module_enable(&snet_security_ops))
+		return 0;
+
+	if (register_security(&snet_security_ops))
+		panic("snet: failed to register security_ops\n");
+
+	return 0;
+}
diff --git a/security/snet/snet_hooks.h b/security/snet/snet_hooks.h
new file mode 100644
index 0000000..05fe5e8
--- /dev/null
+++ b/security/snet/snet_hooks.h
@@ -0,0 +1,10 @@
+#ifndef _SNET_HOOKS_H
+#define _SNET_HOOKS_H
+
+extern uint32_t snet_nl_pid;
+extern unsigned int snet_verdict_policy;
+
+/* init function */
+int snet_hooks_init(void);
+
+#endif /* _SNET_HOOK_H */
-- 
1.7.4.1

