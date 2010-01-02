From: Samir Bellabes <sam@synack.fr>
Subject: [RFC 6/9] snet: introduce snet_hooks.c and snet_hook.h
Date: Sat,  2 Jan 2010 14:04:13 +0100
Message-ID: <1262437456-24476-7-git-send-email-sam@synack.fr>
References: <1262437456-24476-1-git-send-email-sam@synack.fr>
Cc: Patrick McHardy <kaber@trash.net>, jamal <hadi@cyberus.ca>,
	Evgeniy Polyakov <zbr@ioremap.net>,
	Neil Horman <nhorman@tuxdriver.com>, netdev@vger.kernel.org,
	netfilter-devel@vger.kernel.org, Samir Bellabes <sam@synack.fr>
To: linux-security-module@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from bob75-7-88-160-5-175.fbx.proxad.net ([88.160.5.175]:38357 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752200Ab0ABNGp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 2 Jan 2010 08:06:45 -0500
In-Reply-To: <1262437456-24476-1-git-send-email-sam@synack.fr>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

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
 security/snet/include/snet_hooks.h |   28 ++
 security/snet/snet_hooks.c         |  686 ++++++++++++++++++++++++++++++++++++
 2 files changed, 714 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/include/snet_hooks.h
 create mode 100644 security/snet/snet_hooks.c

diff --git a/security/snet/include/snet_hooks.h b/security/snet/include/snet_hooks.h
new file mode 100644
index 0000000..fbda5ed
--- /dev/null
+++ b/security/snet/include/snet_hooks.h
@@ -0,0 +1,28 @@
+#ifndef _SNET_HOOKS_H
+#define _SNET_HOOKS_H
+
+extern atomic_t snet_num_listeners;
+extern unsigned int snet_verdict_policy;
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
+/* init function */
+int snet_hooks_init(void);
+/* exit function */
+int snet_hooks_exit(void);
+
+#endif /* _SNET_HOOK_H */
diff --git a/security/snet/snet_hooks.c b/security/snet/snet_hooks.c
new file mode 100644
index 0000000..9c249ab
--- /dev/null
+++ b/security/snet/snet_hooks.c
@@ -0,0 +1,686 @@
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
+
+#include "snet.h"
+#include "snet_hooks.h"
+#include "snet_verdict.h"
+#include "snet_netlink.h"
+#include "snet_event.h"
+
+#define SNET_DBG_V4()							\
+	snet_dbg("%u.%u.%u.%u:%u->%u.%u.%u.%u:%u\n",			\
+		 NIPQUAD(info.src.u3.ip), info.src.u.port,		\
+		 NIPQUAD(info.dst.u3.ip), info.dst.u.port)
+
+#define SNET_DBG_V6()							\
+	snet_dbg("%pI6:%u->%pI6:%u\n",					\
+		 &info.src.u3.ip, info.src.u.port,			\
+		 &info.dst.u3.ip, info.dst.u.port)
+
+#define SNET_CHECK_LISTENERS()						\
+do {									\
+	if (atomic_read(&snet_num_listeners) < 0) {			\
+		snet_dbg("number of listeners is negative\n");		\
+		verdict = SNET_VERDICT_GRANT;				\
+		goto out;						\
+	} else if (atomic_read(&snet_num_listeners) == 0) {		\
+		verdict = SNET_VERDICT_GRANT;				\
+		goto out;						\
+	}								\
+} while (0)
+
+#define SNET_DO_VERDICT(sys, family)					\
+do {									\
+	if (verdict_id == 0)						\
+		goto skip_send_wait;					\
+	/* sending networking informations to userspace */		\
+	snet_nl_send_event(verdict_id, sys, protocol,			\
+			   family, (void *)&info,			\
+			   sizeof(struct snet_sock_info));		\
+	/* waiting for userspace reply or timeout */			\
+	verdict = snet_verdict_wait(verdict_id);			\
+		/* removing verdict */					\
+	snet_verdict_remove(verdict_id);				\
+} while (0)
+
+#define SNET_CHECK_LISTENERS_NOVERDICT()				\
+do {									\
+	if (atomic_read(&snet_num_listeners) < 0) {			\
+		snet_dbg("number of listeners is negative\n");		\
+		goto out;						\
+	} else if (atomic_read(&snet_num_listeners) == 0) {		\
+		goto out;						\
+	}								\
+} while (0)
+
+#define SNET_DO_SEND_EVENT(sys, family)					\
+do {									\
+	/* sending networking informations to userspace */		\
+	snet_nl_send_event(0, sys, protocol,				\
+			   family, (void *)&info,			\
+			   sizeof(struct snet_sock_info));		\
+} while (0)
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
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+
+	/* if (kern) */
+	/*	;		/\* do something smart *\/ */
+
+	SNET_CHECK_LISTENERS();
+
+	if (snet_event_is_registered(SNET_SOCKET_CREATE, protocol)) {
+		struct snet_sock_info info;
+
+		/* inserting verdict PENDING */
+		verdict_id = snet_verdict_insert();
+
+		/* prepare networking informations for userspace */
+		info.type = type;
+
+		snet_dbg("family=%u type=%u protocol=%u kern=%u\n",
+			 family, type, protocol, kern);
+
+		SNET_DO_VERDICT(SNET_SOCKET_CREATE, family);
+
+	} else {
+		verdict = SNET_VERDICT_GRANT;
+	}
+
+	if (verdict == SNET_VERDICT_NONE)
+		verdict = snet_verdict_policy;
+
+skip_send_wait:
+out:
+	return verdict;
+}
+
+static int snet_socket_bind(struct socket *sock,
+			    struct sockaddr *address, int addrlen)
+{
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_BIND, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+		struct sockaddr_in *a = (struct sockaddr_in *) address;
+		struct sockaddr_in6 *a6 = (struct sockaddr_in6 *) address;
+
+		/* prepare networking informations for userspace */
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			info.src.u3.ip = a->sin_addr.s_addr;
+			info.dst.u3.ip = inet->inet_daddr;
+			info.src.u.port = ntohs(a->sin_port);
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			memcpy(&info.src.u3.ip6, (void *)&a6->sin6_addr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+			info.src.u.port = ntohs(a6->sin6_port);
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		SNET_DO_VERDICT(SNET_SOCKET_BIND, sock->sk->sk_family);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_CONNECT, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+		struct sockaddr_in *a = (struct sockaddr_in *) address;
+		struct sockaddr_in6 *a6 = (struct sockaddr_in6 *) address;
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING */
+			verdict_id = snet_verdict_insert();
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = a->sin_addr.s_addr;
+			info.dst.u.port = ntohs(a->sin_port);
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING */
+			verdict_id = snet_verdict_insert();
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&a6->sin6_addr,
+			       sizeof(info.dst.u3.ip6));
+			info.dst.u.port = ntohs(a6->sin6_port);
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		SNET_DO_VERDICT(SNET_SOCKET_CONNECT, sock->sk->sk_family);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_LISTEN, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		SNET_DO_VERDICT(SNET_SOCKET_LISTEN, sock->sk->sk_family);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_ACCEPT, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		SNET_DO_VERDICT(SNET_SOCKET_ACCEPT, sock->sk->sk_family);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	SNET_CHECK_LISTENERS_NOVERDICT();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_POST_ACCEPT, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(newsock->sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			goto out;
+			break;
+		}
+
+		SNET_DO_SEND_EVENT(SNET_SOCKET_POST_ACCEPT, sock->sk->sk_family);
+	}
+out:
+	return;
+}
+
+static int snet_socket_sendmsg(struct socket *sock,
+			       struct msghdr *msg, int size)
+{
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_SENDMSG, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING */
+			verdict_id = snet_verdict_insert();
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING */
+			verdict_id = snet_verdict_insert();
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		SNET_DO_VERDICT(SNET_SOCKET_SENDMSG, sock->sk->sk_family);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	u32 verdict_id = 0;
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_RECVMSG, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING  */
+			verdict_id = snet_verdict_insert();
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		SNET_DO_VERDICT(SNET_SOCKET_RECVMSG, sock->sk->sk_family);
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	/* u32 verdict_id = 0; */
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
+
+	SNET_CHECK_LISTENERS();
+
+	protocol = sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_SOCK_RCV_SKB, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sk->sk_family) {
+		case PF_INET:
+			/* inserting verdict PENDING  */
+			/* verdict_id = snet_verdict_insert(); */
+
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			/* inserting verdict PENDING  */
+			/* verdict_id = snet_verdict_insert(); */
+
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			verdict = SNET_VERDICT_NONE;
+			goto skip_send_wait;
+			break;
+		}
+
+		/* SNET_DOC_VERDICT(SNET_SOCKET_SOCK_RCV_SKB, sk->sk_family); */
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	SNET_CHECK_LISTENERS_NOVERDICT();
+
+	protocol = sock->sk->sk_protocol;
+
+	if (snet_event_is_registered(SNET_SOCKET_CLOSE, protocol)) {
+		struct snet_sock_info info;
+		struct inet_sock *inet = inet_sk(sock->sk);
+
+		/* prepare networking informations for userspace */
+		info.src.u.port = ntohs(inet->inet_sport);
+		info.dst.u.port = ntohs(inet->inet_dport);
+
+		switch (sock->sk->sk_family) {
+		case PF_INET:
+			info.src.u3.ip = inet->inet_saddr;
+			info.dst.u3.ip = inet->inet_daddr;
+
+			SNET_DBG_V4();
+			break;
+#if defined(CONFIG_IPV6) || defined(CONFIG_IPV6_MODULE)
+		case PF_INET6:
+			memcpy(&info.src.u3.ip6, (void *)&inet->pinet6->saddr,
+			       sizeof(info.src.u3.ip6));
+			memcpy(&info.dst.u3.ip6, (void *)&inet->pinet6->daddr,
+			       sizeof(info.dst.u3.ip6));
+
+			SNET_DBG_V6();
+			break;
+#endif
+		default:
+			goto out;
+			break;
+		}
+
+		SNET_DO_SEND_EVENT(SNET_SOCKET_CLOSE, sock->sk->sk_family);
+	}
+out:
+	return;
+}
+
+#undef SNET_DBG_V4
+#undef SNET_DBG_V6
+#undef SNET_CHECK_LISTENERS
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
+
+int snet_hooks_exit(void)
+{
+	return 0;
+}
-- 
1.6.3.3

