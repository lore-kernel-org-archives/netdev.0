From: Samir Bellabes <sam@synack.fr>
Subject: [RFC] [PATCH] Network Events Connector
Date: Thu, 15 Mar 2007 02:05:53 +0100
Message-ID: <m2fy875n9q.fsf@cerbere.dyndns.info>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from 119.235.97-84.rev.gaoland.net ([84.97.235.119]:35996 "EHLO
	cerbere.dyndns.info" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S964934AbXCOBFz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Mar 2007 21:05:55 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,
here a updated patch for the network events connector.
review are welcome :)

Thanks.

[PATCH] Network Events Connector

This patch adds a connector which reports networking's events to
userspace.

It's sending events when a userspace application is using
syscalls so with LSM, we are catching this, at hooks : socket_listen,
socket_bind, socket_connect, socket_shutdown and sk_free_security.

Wanted events are dynamically manage from userspace, in a rbtree. A
daemon, cn_net_daemon, is listening for the connector in userspace.

daemon and doc are available here :
http://people.mandriva.com/~sbellabes/cn_net/

Signed-off-by: Samir Bellabes <sam@synack.fr>

------------------------------------------------------------------------------

 drivers/connector/Kconfig  |    8 
 drivers/connector/Makefile |    1 
 drivers/connector/cn_net.c |  618 +++++++++++++++++++++++++++++++++++++++++++++
 include/linux/cn_net.h     |  122 ++++++++
 include/linux/connector.h  |    5 
 5 files changed, 752 insertions(+), 2 deletions(-)

------------------------------------------------------------------------------

diff --git a/drivers/connector/Kconfig b/drivers/connector/Kconfig
index e0bdc0d..0b04952 100644
--- a/drivers/connector/Kconfig
+++ b/drivers/connector/Kconfig
@@ -18,4 +18,12 @@ config PROC_EVENTS
 	  Provide a connector that reports process events to userspace. Send
 	  events such as fork, exec, id change (uid, gid, suid, etc), and exit.
 
+config NET_EVENTS
+	boolean "Report network events to userspace"
+	depends on CONNECTOR=y && SECURITY_NETWORK
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
index 0000000..a15f67b
--- /dev/null
+++ b/drivers/connector/cn_net.c
@@ -0,0 +1,618 @@
+/* 
+ * drivers/connector/cn_net.c
+ *
+ * Network events connector
+ * Samir Bellabes <sam@synack.fr>
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
+#include <linux/security.h>
+#include <linux/netlink.h>
+#include <linux/connector.h>
+#include <linux/net.h>
+#include <net/sock.h>
+#include <net/inet_sock.h>
+#include <linux/in.h>
+#include <linux/ipv6.h>
+#include <linux/in6.h>
+#include <linux/rbtree.h>
+#include <linux/list.h>
+#include <linux/spinlock.h>
+#include <linux/random.h>
+
+#include <linux/cn_net.h>
+
+static atomic_t net_event_num_listeners = ATOMIC_INIT(0);
+static struct cb_id cn_net_event_id = { CN_IDX_NET, CN_VAL_NET };
+static char cn_net_event_name[] = "cn_net_event";
+static int secondary = 0;
+
+struct rb_root event_tree = RB_ROOT;
+static rwlock_t event_lock = RW_LOCK_UNLOCKED;
+
+#if defined(CONFIG_NET_EVENTS)
+#define MY_NAME THIS_MODULE->name
+#else
+#define MY_NAME "cn_net"
+#endif
+
+#if 0
+#define DEBUGP printk
+#else
+#define DEBUGP(format, args...)
+#endif
+
+/**
+ * is_same_event()
+ * check if two events are the same or not
+ */			 
+static unsigned int is_same_event(struct event one, struct event two) {
+	return ((one.syscall_num == two.syscall_num) &&
+		(one.protocol == two.protocol));
+}
+
+/**
+ * lookup_event()
+ * look for a match in the rbtree
+ * returns address of the wanted element if it is in the rbtree, or NULL
+ */
+static struct event_node *lookup_event(struct event ev) {
+	struct rb_node *rb_node = event_tree.rb_node;
+
+	read_lock(&event_lock);
+
+	while (rb_node) {
+		struct event_node *cur = rb_entry(rb_node, struct event_node, ev_node);
+		
+		if (is_same_event(cur->ev, ev)) {
+			read_unlock(&event_lock);
+			return cur;
+		}
+
+		if (ev.syscall_num < cur->ev.syscall_num)
+			rb_node = rb_node->rb_left;
+		else if (ev.syscall_num > cur->ev.syscall_num)
+			rb_node = rb_node->rb_right;
+		else if (ev.protocol < cur->ev.protocol)
+			rb_node = rb_node->rb_left;
+		else if (ev.protocol > cur->ev.protocol)
+			rb_node = rb_node->rb_right;
+	}
+
+	read_unlock(&event_lock);
+	return NULL;
+}
+
+/** 
+ * check_wanted_data()
+ * we don't send unwanted informations to userspace, according to the
+ * dynamic configuration in the rbtree
+ */
+static int check_wanted_event(struct sock *sk, enum cn_net_socket syscall_num) {
+	int err = -EINVAL;
+	struct event ev;
+	
+	if (!sk)
+		return err;
+
+	ev.syscall_num = syscall_num;
+	ev.protocol = sk->sk_protocol;
+	       
+	/* check if the event is already registered */
+	if (lookup_event(ev))
+		err = 0;
+
+	return err;
+}
+
+/**
+ * dump_event()
+ * dump the entire rbtree in log
+ */
+static void dump_event(void) {
+	struct rb_node *p = NULL ;
+	struct event_node *tmp = NULL;
+
+	read_lock(&event_lock);
+	p = rb_first(&event_tree);
+	while (p) {
+		tmp = rb_entry(p, struct event_node, ev_node);
+		printk(KERN_INFO "%d:%s\n",
+		       tmp->ev.protocol, syscall_name[tmp->ev.syscall_num]);
+		p = rb_next(p);
+	};
+	read_unlock(&event_lock);
+}
+
+/**
+ * remove_all_event()
+ * delete all events registered in the rbtree
+ */
+static enum ack_err remove_all_event(void) {
+	struct rb_node *p = NULL;
+	struct event_node *cur = NULL;
+
+	write_lock(&event_lock);	
+	while ((p = rb_first(&event_tree)) != NULL) {
+		cur = rb_entry(p, struct event_node, ev_node);
+		rb_erase(p, &event_tree);
+		kfree(cur);
+	}
+	write_unlock(&event_lock);
+
+	/* rbtree is now empty */
+	return CN_NET_ACK_SUCCES;
+}
+
+/** 
+ * alloc_event()
+ * alloc memory for a event_node, and return pointer to it
+ */
+static struct event_node *alloc_event(void) {
+	struct event_node *evn = NULL;
+	evn = kzalloc(sizeof(struct event_node), GFP_KERNEL);
+	return evn;
+}
+
+/**
+ * insert_event()
+ * insert a event in the rbtree
+ * we are checking if we are trying to register a same event twice
+ */
+static enum ack_err insert_event(struct event ev) {
+	struct rb_node **rb_link, *rb_parent;
+	struct event_node *new_evn;
+	enum ack_err ret = CN_NET_ACK_SUCCES;
+
+	rb_link = &event_tree.rb_node;
+	rb_parent = NULL;
+
+	write_lock(&event_lock);
+
+	while(*rb_link) {
+		struct event_node *tmp;
+
+		rb_parent = *rb_link;
+		tmp = rb_entry(rb_parent, struct event_node, ev_node);
+		
+		if (ev.syscall_num < tmp->ev.syscall_num)
+			rb_link = &rb_parent->rb_left;
+		else if (ev.syscall_num > tmp->ev.syscall_num)
+			rb_link = &rb_parent->rb_right;
+		else if (ev.protocol < tmp->ev.protocol)
+			rb_link = &rb_parent->rb_left;
+		else if (ev.protocol > tmp->ev.protocol)
+			rb_link = &rb_parent->rb_right;
+		else {
+			/* event is already registered */
+			ret = CN_NET_ACK_EINCONFIG;
+			goto out;
+		}
+	}
+
+	/* no match: event is added to the tree */
+	if ((new_evn = alloc_event()) != NULL) {
+		new_evn->ev.syscall_num = ev.syscall_num;
+		new_evn->ev.protocol = ev.protocol;
+	} else {
+		/* can't allocate memory, exiting */
+		ret = CN_NET_ACK_ENOMEM;
+		goto out;
+	}
+
+	rb_link_node(&new_evn->ev_node, rb_parent, rb_link);
+	rb_insert_color(&new_evn->ev_node, &event_tree);
+
+out:
+	write_unlock(&event_lock);
+	return ret;
+}
+
+/**
+ * remove_event()  
+ * delete a entry from the rbtree
+ * we are checking if we are trying to delete a unregistered event
+ */
+static enum ack_err remove_event(struct event ev) {
+	struct event_node *cur = NULL;
+	enum ack_err ret = CN_NET_ACK_EINCONFIG;
+	struct rb_node *rb_node = event_tree.rb_node;
+
+	write_lock(&event_lock);
+
+	while (rb_node) {
+		cur = rb_entry(rb_node, struct event_node, ev_node);
+		
+		if (is_same_event(cur->ev, ev))
+			break;
+
+		if (ev.syscall_num < cur->ev.syscall_num)
+			rb_node = rb_node->rb_left;
+		else if (ev.syscall_num > cur->ev.syscall_num)
+			rb_node = rb_node->rb_right;
+		else if (ev.protocol < cur->ev.protocol)
+			rb_node = rb_node->rb_left;
+		else if (ev.protocol > cur->ev.protocol)
+			rb_node = rb_node->rb_right;
+	}
+
+	if (rb_node) {
+		rb_erase(&cur->ev_node, &event_tree);
+		kfree(cur);
+		ret = CN_NET_ACK_SUCCES;
+	}
+	write_unlock(&event_lock);
+
+	return ret;
+}
+
+/**
+ * do_register()
+ * check if userpace protocol version is same as kernel protocol version
+ */
+static enum ack_err do_register(__u32 version) {
+	enum ack_err err = CN_NET_ACK_SUCCES;
+
+	DEBUGP(KERN_INFO "do_register: %d %d\n",
+	       version, CN_NET_VERSION);
+
+	if (version == CN_NET_VERSION)
+		atomic_inc(&net_event_num_listeners);
+	else
+		err = CN_NET_ACK_EBADPROTO;
+	return err;
+}
+
+/** 
+ * do_config()
+ * execute config asked by userspace
+ * return enum ack_err
+ */
+static enum ack_err do_config(struct msg_config *cfg) {
+	enum ack_err err = CN_NET_ACK_SUCCES;
+
+	DEBUGP(KERN_INFO "do_config: %s %s %d\n",
+	       config_name[cfg->config_cmd],
+	       syscall_name[cfg->ev.syscall_num],
+	       cfg->ev.protocol);
+
+	switch (cfg->config_cmd) {
+	case CN_NET_CONFIG_ADD:
+		err = insert_event(cfg->ev);
+		break;
+	case CN_NET_CONFIG_DEL:
+		err= remove_event(cfg->ev);
+		break;
+	case CN_NET_CONFIG_FLUSH:
+		err = remove_all_event();
+		break;
+	default:
+		err = CN_NET_ACK_EINTYPE;
+		break;
+	};
+	
+	return err;
+}
+
+/**
+ * cn_net_ack
+ * Send an acknowledgement message to userspace
+ *
+ * Use 0 for SUCCESS, EFOO otherwise. (see enum ack_err)
+ */
+static void cn_net_ack(enum ack_err err, unsigned int rcvd_seq, unsigned int rcvd_ack, enum msg_type msg_type)
+{
+	struct cn_msg *m;
+	struct net_event *net_ev;
+	__u8 buffer[CN_NET_MSG_SIZE];
+
+	DEBUGP(KERN_INFO "cn_net_ack: listen=%d\n", atomic_read(&net_event_num_listeners));
+	
+	if (atomic_read(&net_event_num_listeners) < 1 && err != CN_NET_ACK_EBADPROTO)
+		return;
+
+	m = (struct cn_msg *) buffer;
+	net_ev = (struct net_event *) m->data;
+
+	net_ev->msg_type = msg_type;
+	ktime_get_real_ts(&net_ev->timestamp);
+	net_ev->net_event_data.ack = err;
+	memcpy(&m->id, &cn_net_event_id, sizeof(m->id));
+	m->seq = rcvd_seq;
+	m->ack = rcvd_ack + 1;
+	m->len = sizeof(struct net_event);
+	cn_netlink_send(m, CN_IDX_NET, gfp_any());
+}
+
+/**
+ * cn_net_ctl
+ * connector callback
+ * @data: message receive from userspace via the connector
+ */
+void cn_net_ctl(void *data) {
+	struct cn_msg *m = data;
+	struct net_event *net_ev = NULL;
+	enum msg_type msg_type;
+	enum ack_err err = CN_NET_ACK_SUCCES;
+
+	if (m->len != sizeof(struct net_event)) {
+		printk(KERN_WARNING "cn_net_ctl : message with bad size, discard\n");
+		return;
+	}
+
+	net_ev = (struct net_event *) m->data;
+
+	if (net_ev->msg_type != CN_NET_LISTEN && 
+	    atomic_read(&net_event_num_listeners) < 1) {
+		printk(KERN_WARNING "cn_net_ctl : register first\n");
+		return;
+	}
+	msg_type = CN_NET_ACK;	/* default response message type */
+
+	switch (net_ev->msg_type) {
+	case CN_NET_NONE:	/* want to play ping pong ? */
+		msg_type = net_ev->msg_type;
+		break;
+	case CN_NET_ACK:	/* userspace is ack'ing - check that */
+		/* FIXME: we don't send an ACK to an ACK */
+		/* we just check which message is ack */
+		goto out;
+		break;
+	case CN_NET_DATA:	/* CN_NET_DATA can't be used by userspace */
+		err = CN_NET_ACK_EINTYPE;
+		break;
+	case CN_NET_CONFIG:	/* configuring kernel's behaviour */
+		err = do_config(&(net_ev->net_event_data.config));
+		break;
+	case CN_NET_LISTEN:	/* userspace is registering */
+		err = do_register(net_ev->net_event_data.version);
+		break;
+	case CN_NET_IGNORE:     /* userspace is unregistering */
+		atomic_dec(&net_event_num_listeners);
+		break;
+	case CN_NET_DUMP:     /* dumping the rbtree -- debug purpose */
+		dump_event();
+		break;
+	default:
+		err = CN_NET_ACK_EINTYPE;
+		break;
+	};
+	cn_net_ack(err, m->seq, m->ack, msg_type);
+out:
+	return;
+}
+
+/**
+ * cn_net_send_event
+ * send data to userspace
+ * @sock: sock which sock->sk->sk_state change to the state identified by @event
+ */
+static void cn_net_send_event(struct sock *sk, struct sockaddr *address,
+			      enum cn_net_socket syscall_num) {
+			 
+	struct net_event *net_ev;
+	struct cn_msg *m;
+	struct inet_sock *inet = inet_sk(sk);
+	struct sockaddr_in *addr4 = NULL;
+	struct sockaddr_in6 *addr6 = NULL;
+	struct task_struct *me = current;
+
+	__u8 buffer[CN_NET_MSG_SIZE];
+
+	DEBUGP(KERN_INFO "cn_net_ack: listen=%d\n", atomic_read(&net_event_num_listeners));
+
+	if (atomic_read(&net_event_num_listeners) < 1)
+		goto out;
+	
+	m = (struct cn_msg *) buffer;
+	net_ev = (struct net_event *) m->data;
+	
+	switch (syscall_num) {
+	case CN_NET_SOCKET_LISTEN:
+	case CN_NET_SOCKET_SHUTDOWN:
+	case CN_NET_SK_FREE_SECURITY:
+		switch (sk->sk_family) {
+		case AF_INET:
+			net_ev->net_event_data.data.saddr.ipv4 = inet->saddr;
+			net_ev->net_event_data.data.daddr.ipv4 = inet->daddr;
+			break;
+		case AF_INET6:
+			memcpy(&(net_ev->net_event_data.data.saddr.ipv6),
+			       &(inet->pinet6->saddr), sizeof(struct in6_addr));
+			memcpy(&(net_ev->net_event_data.data.daddr.ipv6),
+			       &(inet->pinet6->daddr), sizeof(struct in6_addr));
+			break;
+		default:
+			/* other protocol, sending nothing */
+			goto out;
+			break;
+		};
+		net_ev->net_event_data.data.sport = ntohs(inet->sport);
+		net_ev->net_event_data.data.dport = ntohs(inet->dport);
+		break;
+	case CN_NET_SOCKET_BIND:
+		switch (sk->sk_family) {
+		case AF_INET:
+			addr4 = (struct sockaddr_in *) address;
+			net_ev->net_event_data.data.saddr.ipv4 = addr4->sin_addr.s_addr;
+			net_ev->net_event_data.data.daddr.ipv4 = inet->daddr;
+			net_ev->net_event_data.data.sport = ntohs(addr4->sin_port);
+			net_ev->net_event_data.data.dport = ntohs(inet->dport);
+			break;
+		case AF_INET6:
+			addr6 = (struct sockaddr_in6 *) address;
+			memcpy(&(net_ev->net_event_data.data.saddr.ipv6),
+			       &(addr6->sin6_addr), sizeof(struct in6_addr));
+			memcpy(&(net_ev->net_event_data.data.daddr.ipv6),
+			       &(inet->pinet6->daddr), sizeof(struct in6_addr));
+			net_ev->net_event_data.data.sport = ntohs(addr6->sin6_port);
+			net_ev->net_event_data.data.dport = ntohs(inet->dport);
+			break;
+		default:
+			/* other protocol, sending nothing */
+			goto out;
+			break;
+		};
+		break;
+	case CN_NET_SOCKET_CONNECT:
+		switch (sk->sk_family) {
+		case AF_INET:
+			addr4 = (struct sockaddr_in *) address;
+			net_ev->net_event_data.data.saddr.ipv4 = inet->saddr;
+			net_ev->net_event_data.data.daddr.ipv4 = addr4->sin_addr.s_addr;
+			net_ev->net_event_data.data.sport = ntohs(inet->sport);
+			net_ev->net_event_data.data.dport = ntohs(addr4->sin_port);
+			break;
+		case AF_INET6:
+			addr6 = (struct sockaddr_in6 *) address;
+			memcpy(&(net_ev->net_event_data.data.saddr.ipv6),
+			       &(inet->pinet6->saddr), sizeof(struct in6_addr));
+			memcpy(&(net_ev->net_event_data.data.daddr.ipv6),
+			       &(addr6->sin6_addr), sizeof(struct in6_addr));
+			net_ev->net_event_data.data.sport = ntohs(inet->sport);
+			net_ev->net_event_data.data.dport = ntohs(addr6->sin6_port);
+			break;
+		default:
+			/* other protocol, sending nothing */
+			goto out;
+			break;
+		};
+		break;
+	default:
+		/* Bad syscall_num */
+		break;
+	};
+	net_ev->msg_type = CN_NET_DATA;
+	ktime_get_real_ts(&net_ev->timestamp);
+	net_ev->net_event_data.data.uid = me->uid;
+	get_task_comm(net_ev->net_event_data.data.taskname, me);
+	net_ev->net_event_data.data.ev.protocol = sk->sk_protocol;
+	net_ev->net_event_data.data.ev.syscall_num = syscall_num;
+	net_ev->net_event_data.data.family = sk->sk_family;
+	memcpy(&m->id, &cn_net_event_id, sizeof(m->id));
+	m->seq = get_random_int();
+	m->ack = 0;
+	m->len = sizeof(struct net_event);
+	
+	cn_netlink_send(m, CN_IDX_NET, gfp_any());
+out:
+	return;
+}
+
+static int cn_net_socket_listen(struct socket *sock, int backlog) {
+
+	DEBUGP(KERN_INFO "cn_net_socket_listen\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_LISTEN) == NULL)
+		cn_net_send_event(sock->sk, NULL, CN_NET_SOCKET_LISTEN);
+
+	return 0;
+}
+
+static int cn_net_socket_bind(struct socket *sock,
+			      struct sockaddr *address, int addrlen) {
+
+	DEBUGP(KERN_INFO "cn_net_socket_bind\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_BIND) == NULL)
+		cn_net_send_event(sock->sk, address, CN_NET_SOCKET_BIND);
+
+	return 0;
+}
+
+static int cn_net_socket_connect(struct socket *sock, struct sockaddr *address, int addrlen) {
+	
+	DEBUGP(KERN_INFO "cn_net_socket_connect\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_CONNECT) == NULL)
+		cn_net_send_event(sock->sk, address, CN_NET_SOCKET_CONNECT);
+
+	return 0;
+}
+
+static int cn_net_socket_shutdown(struct socket *sock, int how) {
+
+	DEBUGP(KERN_INFO "cn_net_socket_shutdown\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_SHUTDOWN) == NULL)
+		cn_net_send_event(sock->sk, NULL, CN_NET_SOCKET_SHUTDOWN);
+
+	return 0;
+}
+
+static int cn_net_sk_free_security(struct sock *sk) {
+	
+	DEBUGP(KERN_INFO "cn_net_sk_free_security\n");
+	if (check_wanted_event(sk, CN_NET_SK_FREE_SECURITY) == NULL)
+		cn_net_send_event(sk, NULL, CN_NET_SK_FREE_SECURITY);
+
+	return 0;
+}
+
+static struct security_operations cn_net_security_ops = {
+	.socket_listen		= cn_net_socket_listen,
+	.socket_bind		= cn_net_socket_bind,
+	.socket_connect		= cn_net_socket_connect,
+	.socket_shutdown	= cn_net_socket_shutdown,
+	.sk_free_security	= cn_net_sk_free_security,
+};
+
+static int __init init(void) {
+	int err = 0;
+
+	err = cn_add_callback(&cn_net_event_id, cn_net_event_name, &cn_net_ctl);
+	if (err) {
+		printk(KERN_WARNING "cn_net: Failure add connector callback\n");
+		goto out_callback;
+	}
+
+	if (register_security(&cn_net_security_ops)) {
+		printk(KERN_INFO "cn_net: Failure registering with kernel\n");
+		if (mod_reg_security(MY_NAME, &cn_net_security_ops)) {
+			printk(KERN_WARNING
+			       "cn_net: Failure registering with primary security"
+			       " module\n");
+			err = -EINVAL;
+			goto out_security;
+		}
+		secondary = 1;
+	}
+
+	printk(KERN_INFO "cn_net: network events module loaded\n");
+	return 0;
+
+out_security:
+	cn_del_callback(&cn_net_event_id);
+
+out_callback:
+	return err;
+}
+
+static void __exit fini(void) {
+	if (secondary) {
+		if (mod_unreg_security(MY_NAME, &cn_net_security_ops))
+			printk(KERN_INFO "cn_net: Failure unregistering with"
+			       " primary security module\n");
+	} else {
+		if (unregister_security(&cn_net_security_ops))
+			printk(KERN_INFO "cn_net: Failure unregistering with "
+			       "kernel\n");
+	}
+	
+	cn_del_callback(&cn_net_event_id);
+	
+	/* clean memory */
+	remove_all_event();
+
+	printk(KERN_INFO "cn_net: network events module unloaded\n");
+}
+
+module_init(init);
+module_exit(fini);
+
+MODULE_DESCRIPTION("Network events module");
+MODULE_LICENSE("GPL");
+MODULE_AUTHOR("Samir Bellabes <sam@synack.fr>");
diff --git a/include/linux/cn_net.h b/include/linux/cn_net.h
new file mode 100644
index 0000000..0d86715
--- /dev/null
+++ b/include/linux/cn_net.h
@@ -0,0 +1,122 @@
+/* 
+ * include/linux/cn_net.h
+ *
+ * Network events connector
+ * Samir Bellabes <sam@synack.fr>
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
+#define CN_NET_VERSION 0x1
+
+#define CN_NET_MSG_SIZE (sizeof(struct cn_msg) + sizeof(struct net_event))
+
+char *syscall_name[] = { "LISTEN", "BIND", "CONNECT", "SHUTDOWN", "SK_FREE" };
+char *msg_type_name[] = { "CN_NET_NONE", "CN_NET_ACK", "CN_NET_DATA",
+			  "CN_NET_CONFIG", "CN_NET_LISTEN", "CN_NET_IGNORE",
+			  "CN_NET_DUMP" };
+char *config_name[] = {"CN_NET_CONFIG_ADD", "CN_NET_CONFIG_DEL", "CN_NET_CONFIG_FLUSH" };
+
+/**
+ * identify which syscall has been called.
+ */
+enum cn_net_socket {
+	CN_NET_SOCKET_LISTEN	= 0,
+	CN_NET_SOCKET_BIND	= 1,
+	CN_NET_SOCKET_CONNECT	= 2,
+	CN_NET_SOCKET_SHUTDOWN	= 3,
+	CN_NET_SK_FREE_SECURITY = 4,
+	CN_NET_SOCKET_MAX	= 5,
+};
+
+/**
+ * Protocol message type
+ */
+enum msg_type {
+	CN_NET_NONE     = 0,
+	CN_NET_ACK      = 1,    
+	CN_NET_DATA     = 2,
+	CN_NET_CONFIG   = 3,
+	CN_NET_LISTEN   = 4,
+	CN_NET_IGNORE   = 5,
+	CN_NET_DUMP	= 6,
+};
+
+/**
+ * values for CN_NET_ACK messages
+ */
+enum ack_err {
+	CN_NET_ACK_SUCCES	= 0,
+	CN_NET_ACK_ENOMEM	= 1,
+	CN_NET_ACK_EINCONFIG	= 2,
+	CN_NET_ACK_EINTYPE	= 3,
+	CN_NET_ACK_EBADPROTO	= 4,
+};
+
+/**
+ * values for CN_NET_CONFIG messages
+ */
+enum config_cmd {
+	CN_NET_CONFIG_ADD	= 0,
+	CN_NET_CONFIG_DEL	= 1,
+	CN_NET_CONFIG_FLUSH	= 2,
+};
+
+struct event {
+	enum cn_net_socket syscall_num;
+	__u8 protocol;
+};
+
+struct event_node {
+	struct rb_node ev_node;
+	struct event ev;
+};
+
+struct msg_config {
+	enum config_cmd config_cmd;
+	struct event ev; 
+};
+
+struct net_event {
+	enum msg_type msg_type;
+	struct timespec timestamp;
+	union {
+		/* protocol version number */
+		__u32 version;
+
+		/* generic ack for both userspace and kernel */
+		enum ack_err ack;
+
+		/* send data to userspace */
+		struct {
+			struct event ev;
+			uid_t uid;
+			unsigned char taskname[TASK_COMM_LEN];
+			unsigned int family;
+			union {
+				struct in6_addr ipv6;
+				__u32 ipv4;
+			} saddr;
+			union {
+				struct in6_addr ipv6;
+				__u32 ipv4;
+			} daddr;
+			unsigned int sport;
+			unsigned int dport;
+		} data;
+
+		/* send config to kernel */
+		struct msg_config config;
+	} net_event_data;
+};
+
+#endif /* CN_NET_H */
diff --git a/include/linux/connector.h b/include/linux/connector.h
index 10eb56b..3042360 100644
--- a/include/linux/connector.h
+++ b/include/linux/connector.h
@@ -36,9 +36,10 @@ #define CN_IDX_CIFS			0x2
 #define CN_VAL_CIFS                     0x1
 #define CN_W1_IDX			0x3	/* w1 communication */
 #define CN_W1_VAL			0x1
+#define CN_IDX_NET			0x4
+#define CN_VAL_NET			0x1
 
-
-#define CN_NETLINK_USERS		4
+#define CN_NETLINK_USERS		5
 
 /*
  * Maximum connector's message size.
