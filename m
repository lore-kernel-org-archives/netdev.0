From: Samir Bellabes <sbellabes@mandriva.com>
Subject: [PATCH] Network Events Connector
Date: Mon, 02 Oct 2006 08:11:06 +0200
Message-ID: <m23ba7gscl.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Return-path: <netdev-owner@vger.kernel.org>
Received: from 188.235.97-84.rev.gaoland.net ([84.97.235.188]:47590 "EHLO
	cerbere.dyndns.info") by vger.kernel.org with ESMTP id S932637AbWJBGMJ
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Oct 2006 02:12:09 -0400
To: netdev@vger.kernel.org
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


This patch adds a connector which reports networking's events to
userspace. It's sending events when a sock has its sk_state changed to :
  - LISTEN or CLOSE for DCCP and TCP
  - BIND or CLOSE for UDP.

With this notification, a userspace tool can ask the user if he want to
let the local firewall open for the corresponding sport or not, and if
so open the firewall for the application which get the corresponding sport.

For people behind a firewall (non-running in the user box) we can have a
authentification between the user box, which have set the port to state
TCP_LISTEN for example, and the firewall, in a such way that the
firewall's router will forward incoming packet for this port to the user
box.

It will avoid adding specific rules to the user's firewall-script, and
let the firewall be more interactive for users.

Signed-off-by: Samir Bellabes <sbellabes@mandriva.com>
---
 drivers/connector/Kconfig  |    8 ++
 drivers/connector/Makefile |    1 
 drivers/connector/cn_net.c |  161 ++++++++++++++++++++++++++++++++++++++++++++
 include/linux/cn_net.h     |   64 +++++++++++++++++
 include/linux/connector.h  |    4 +
 net/dccp/proto.c           |    6 +-
 net/ipv4/af_inet.c         |    6 ++
 net/ipv4/tcp.c             |    5 +
 net/ipv4/udp.c             |    2 +
 9 files changed, 254 insertions(+), 3 deletions(-)

diff --git a/drivers/connector/Kconfig b/drivers/connector/Kconfig
index e0bdc0d..bcb801f 100644
--- a/drivers/connector/Kconfig
+++ b/drivers/connector/Kconfig
@@ -18,4 +18,12 @@ config PROC_EVENTS
 	  Provide a connector that reports process events to userspace. Send
 	  events such as fork, exec, id change (uid, gid, suid, etc), and exit.
 
+config NET_EVENTS
+	boolean "Report network events to userspace"
+	depends on CONNECTOR=y
+	default y
+	---help---
+	  Provide a connector that reports networking's events to userspace.
+	  Send events such as DCCP/TCP listen/close and UDP bind/close.
+
 endmenu
diff --git a/drivers/connector/Makefile b/drivers/connector/Makefile
index 1f255e4..436bb5d 100644
--- a/drivers/connector/Makefile
+++ b/drivers/connector/Makefile
@@ -1,4 +1,5 @@
 obj-$(CONFIG_CONNECTOR)		+= cn.o
 obj-$(CONFIG_PROC_EVENTS)	+= cn_proc.o
+obj-$(CONFIG_NET_EVENTS)	+= cn_net.o
 
 cn-y				+= cn_queue.o connector.o
diff --git a/drivers/connector/cn_net.c b/drivers/connector/cn_net.c
new file mode 100644
index 0000000..affe30a
--- /dev/null
+++ b/drivers/connector/cn_net.c
@@ -0,0 +1,161 @@
+/* 
+ * drivers/connector/cn_net.c
+ *
+ * Network events connector
+ * Samir Bellabes <sbellabes@mandriva.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */ 
+
+#include <linux/kernel.h>
+#include <linux/module.h>
+#include <linux/skbuff.h>
+#include <linux/netlink.h>
+#include <linux/connector.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <linux/ipv6.h>
+#include <linux/in6.h>
+
+#include <linux/cn_net.h>
+
+MODULE_AUTHOR("Samir Bellabes <sbellabes@mandriva.com>");
+MODULE_DESCRIPTION("Net events module");
+MODULE_LICENSE("GPL");
+
+#define CN_NET_MSG_SIZE (sizeof(struct cn_msg) + sizeof(struct net_event))
+
+static atomic_t net_event_num_listeners = ATOMIC_INIT(0);
+static struct cb_id cn_net_event_id = { CN_IDX_NET, CN_VAL_NET };
+static char cn_net_event_name[] = "cn_net_event";
+
+/**
+ * cn_net_event
+ * @sk: sock which sk->sk_state change to the state identified by @event
+ * @event: type of event
+ */
+void cn_net_event(struct sock *sk, unsigned int event) {
+	struct net_event *ev;
+	struct cn_msg *m;
+	struct inet_sock *inet = inet_sk(sk);
+
+	__u8 buffer[CN_NET_MSG_SIZE];
+
+	if (atomic_read(&net_event_num_listeners) < 1)
+		goto out ;
+
+	m = (struct cn_msg *) buffer;
+	ev = (struct net_event *) m->data;
+
+	ev->event = event;
+	ktime_get_real_ts(&ev->timestamp);
+	ev->net_event_data.data.family = sk->sk_family;
+	ev->net_event_data.data.sport = ntohs(inet->sport);
+	switch (sk->sk_family) {
+	case AF_INET:
+		ev->net_event_data.data.saddr.ipv4 = inet->saddr;
+		break;
+	case AF_INET6:
+		memcpy(&(ev->net_event_data.data.saddr.ipv6),
+		       &(inet->pinet6->saddr), sizeof(struct in6_addr));
+		break;
+	default:
+		/* other protocol, sending nothing */
+		goto out;
+		break;
+	};
+	memcpy(&m->id, &cn_net_event_id, sizeof(m->id));
+	m->seq = 0;
+	m->ack = 0;
+	m->len = sizeof(struct net_event);
+
+	cn_netlink_send(m, CN_IDX_NET, gfp_any());
+
+out:
+	return;
+}
+EXPORT_SYMBOL(cn_net_event);
+
+/**
+ * Send an acknowledgement message to userspace
+ *
+ * Use 0 for success, EFOO otherwise.
+ * Note: this is the negative of conventional kernel error
+ * values because it's not being returned via syscall return
+ * mechanisms.
+ */
+static void cn_net_ack(int err, int rcvd_seq, int rcvd_ack)
+{
+	struct cn_msg *m;
+	struct net_event *ev;
+	__u8 buffer[CN_NET_MSG_SIZE];
+
+	if (atomic_read(&net_event_num_listeners) < 1)
+		return;
+
+	m = (struct cn_msg *) buffer;
+	ev = (struct net_event *) m->data;
+
+	ev->event = NET_EVENT_NONE;
+	ktime_get_real_ts(&ev->timestamp);
+	m->seq = rcvd_seq;
+	ev->net_event_data.ack.err = err;
+	memcpy(&m->id, &cn_net_event_id, sizeof(m->id));
+	m->ack = rcvd_ack + 1;
+	m->len = sizeof(struct net_event);
+	cn_netlink_send(m, CN_IDX_NET, gfp_any());
+}
+
+/* 
+ * cn_net_ctl
+ * @data: message sent from userpace via the connector
+ */
+void cn_net_ctl(void *data) {
+	struct cn_msg *m = data, *msg;
+	enum cn_net_status *status = NULL;
+	int err = 0;
+
+	msg = (struct cn_msg *)data;
+	
+	if (m->len != sizeof(*status))
+		return;
+
+	status = (enum cn_net_status *) m->data;
+	switch (*status) {
+	case CN_NET_LISTEN:
+		atomic_inc(&net_event_num_listeners);
+		break;
+	case CN_NET_IGNORE:
+		atomic_dec(&net_event_num_listeners);
+		break;
+	default:
+		err = EINVAL;
+		break;
+	}
+	cn_net_ack(err, m->seq, m->ack);
+	return;
+}
+
+static int __init init(void) {
+	int err;
+
+	err = cn_add_callback(&cn_net_event_id, cn_net_event_name,
+			      cn_net_ctl);
+	if (err) {
+		printk(KERN_WARNING "net_event module failed to load\n");
+		return err;
+	}
+	printk(KERN_INFO "network events module loaded\n");
+	return 0;
+}
+
+static void __exit fini(void) {
+	cn_del_callback(&cn_net_event_id);
+	printk(KERN_INFO "network events module unloaded\n");
+}
+
+module_init(init);
+module_exit(fini);
diff --git a/include/linux/cn_net.h b/include/linux/cn_net.h
new file mode 100644
index 0000000..9426538
--- /dev/null
+++ b/include/linux/cn_net.h
@@ -0,0 +1,64 @@
+/* 
+ * include/linux/cn_net.h
+ *
+ * Network events connector
+ * Samir Bellabes <sbellabes@mandriva.com>
+ *
+ *	This program is free software; you can redistribute it and/or
+ *	modify it under the terms of the GNU General Public License
+ *	as published by the Free Software Foundation; either version
+ *	2 of the License, or (at your option) any later version.
+ */ 
+
+#ifndef CN_NET_H
+#define CN_NET_H
+
+#include <linux/time.h>
+#include <linux/ipv6.h>
+
+/*
+ * Userspace sends this enum to register with the kernel that it is listening
+ * for events on the connector.
+ */
+enum cn_net_status {
+	CN_NET_LISTEN = 1,
+	CN_NET_IGNORE = 2
+};
+
+struct net_event {
+	enum event {
+		NET_EVENT_NONE		= 0x00000000,
+		NET_EVENT_TCP_LISTEN	= 0x00000001,
+		NET_EVENT_TCP_CLOSE	= 0x00000002,
+		NET_EVENT_UDP_BIND	= 0x00000004,
+		NET_EVENT_UDP_CLOSE	= 0x00000008,
+		NET_EVENT_DCCP_LISTEN	= 0x00000010,
+		NET_EVENT_DCCP_CLOSE	= 0x00000020,
+		NET_EVENT_MAX		= 0x80000000
+	} event;
+	struct timespec timestamp;
+	union {
+		struct {
+			__u32 err;
+		} ack;
+		
+		struct {
+			unsigned int family;
+			union {
+				struct in6_addr ipv6;
+				unsigned long ipv4;
+			} saddr;
+			unsigned int sport;
+		} data;
+	} net_event_data;
+};
+
+#ifdef __KERNEL__
+#ifdef CONFIG_NET_EVENTS
+void cn_net_event(struct sock *sk, unsigned int event);
+#else
+static inline void cn_net_event(struct sock *sk, unsigned int event)
+{}
+#endif /* CONFIG_NET_EVENTS */
+#endif /* __KERNEL__ */
+#endif /* CN_NET_H */
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 4c02119..f070bce 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -36,9 +36,11 @@ #define CN_IDX_CIFS			0x2
 #define CN_VAL_CIFS                     0x1
 #define CN_W1_IDX			0x3	/* w1 communication */
 #define CN_W1_VAL			0x1
+#define CN_IDX_NET			0x4
+#define CN_VAL_NET			0x1
 
 
-#define CN_NETLINK_USERS		4
+#define CN_NETLINK_USERS		5
 
 /*
  * Maximum connector's message size.
diff --git a/net/dccp/proto.c b/net/dccp/proto.c
index 72cbdcf..c5146b1 100644
--- a/net/dccp/proto.c
+++ b/net/dccp/proto.c
@@ -21,6 +21,7 @@ #include <linux/if_arp.h>
 #include <linux/init.h>
 #include <linux/random.h>
 #include <net/checksum.h>
+#include <linux/cn_net.h>
 
 #include <net/inet_sock.h>
 #include <net/sock.h>
@@ -794,6 +795,7 @@ int inet_dccp_listen(struct socket *sock
 	}
 	sk->sk_max_ack_backlog = backlog;
 	err = 0;
+	cn_net_event(sk, NET_EVENT_DCCP_LISTEN);
 
 out:
 	release_sock(sk);
@@ -906,8 +908,10 @@ #if 0
 #endif
 	}
 
-	if (sk->sk_state == DCCP_CLOSED)
+	if (sk->sk_state == DCCP_CLOSED) {
+		cn_net_event(sk, NET_EVENT_DCCP_CLOSE);
 		inet_csk_destroy_sock(sk);
+	}
 
 	/* Otherwise, socket is reprieved until protocol close. */
 
diff --git a/net/ipv4/af_inet.c b/net/ipv4/af_inet.c
index edcf093..a58996d 100644
--- a/net/ipv4/af_inet.c
+++ b/net/ipv4/af_inet.c
@@ -114,6 +114,7 @@ #include <net/xfrm.h>
 #ifdef CONFIG_IP_MROUTE
 #include <linux/mroute.h>
 #endif
+#include <linux/cn_net.h>
 
 DEFINE_SNMP_STAT(struct linux_mib, net_statistics) __read_mostly;
 
@@ -210,6 +211,7 @@ int inet_listen(struct socket *sock, int
 	}
 	sk->sk_max_ack_backlog = backlog;
 	err = 0;
+	cn_net_event(sk, NET_EVENT_TCP_LISTEN);
 
 out:
 	release_sock(sk);
@@ -468,6 +470,10 @@ int inet_bind(struct socket *sock, struc
 	inet->dport = 0;
 	sk_dst_reset(sk);
 	err = 0;
+	
+	if (sk->sk_protocol == IPPROTO_UDP)
+		cn_net_event(sk, NET_EVENT_UDP_BIND);
+
 out_release_sock:
 	release_sock(sk);
 out:
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index 66e9a72..345b376 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -258,6 +258,7 @@ #include <linux/random.h>
 #include <linux/bootmem.h>
 #include <linux/cache.h>
 #include <linux/err.h>
+#include <linux/cn_net.h>
 
 #include <net/icmp.h>
 #include <net/tcp.h>
@@ -1684,8 +1685,10 @@ adjudge_to_death:
 		}
 	}
 
-	if (sk->sk_state == TCP_CLOSE)
+	if (sk->sk_state == TCP_CLOSE) {
+		cn_net_event(sk, NET_EVENT_TCP_CLOSE);
 		inet_csk_destroy_sock(sk);
+	}
 	/* Otherwise, socket is reprieved until protocol close. */
 
 out:
diff --git a/net/ipv4/udp.c b/net/ipv4/udp.c
index 6d6142f..16bc4d7 100644
--- a/net/ipv4/udp.c
+++ b/net/ipv4/udp.c
@@ -108,6 +108,7 @@ #include <net/route.h>
 #include <net/inet_common.h>
 #include <net/checksum.h>
 #include <net/xfrm.h>
+#include <linux/cn_net.h>
 
 /*
  *	Snmp MIB for the UDP layer
@@ -912,6 +913,7 @@ int udp_disconnect(struct sock *sk, int 
 
 static void udp_close(struct sock *sk, long timeout)
 {
+	cn_net_event(sk, NET_EVENT_UDP_CLOSE);
 	sk_common_release(sk);
 }
 
