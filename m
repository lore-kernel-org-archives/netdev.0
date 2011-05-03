From: Samir Bellabes <sam@synack.fr>
Subject: [RFC v3 05/10] snet: introduce snet_hooks
Date: Tue,  3 May 2011 16:24:18 +0200
Message-ID: <1304432663-1575-6-git-send-email-sam@synack.fr>
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
 security/snet/snet_hooks.c |  722 ++++++++++++++++++++++++++++++++++++++++++++
 security/snet/snet_hooks.h |   10 +
 2 files changed, 732 insertions(+), 0 deletions(-)
 create mode 100644 security/snet/snet_hooks.c
 create mode 100644 security/snet/snet_hooks.h

diff --git a/security/snet/snet_hooks.c b/security/snet/snet_hooks.c
new file mode 100644
index 0000000..84ea5fc
--- /dev/null
+++ b/security/snet/snet_hooks.c
@@ -0,0 +1,722 @@
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
+static int snet_do_verdict(enum snet_verdict *verdict, struct snet_info *info)
+{
+	if (info->verdict_id == 0)
+		return -1;
+	/* sending networking informations to userspace */
+	if (snet_nl_send_event(info) == 0)
+		/* waiting for userspace reply or timeout */
+		*verdict = snet_verdict_wait(info->verdict_id);
+	/* removing verdict */
+	snet_verdict_remove(info->verdict_id);
+	return 0;
+}
+
+static void snet_do_send_event(struct snet_info *info)
+{
+	snet_nl_send_event(info);
+	return;
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
+
+	} else {
+		verdict = SNET_VERDICT_GRANT;
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
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
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
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
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
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
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
+		snet_do_send_event(&info);
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
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
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
+	enum snet_verdict verdict = SNET_VERDICT_NONE;
+	u8 protocol = 0;
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
+		snet_do_send_event(&info);
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
