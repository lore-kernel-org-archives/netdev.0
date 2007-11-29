From: Samir Bellabes <sam@synack.fr>
Subject: Re: [PATCH net-2.6.25] Add packet filtering based on process'ssecurity context.
Date: Thu, 29 Nov 2007 05:57:37 +0100
Message-ID: <m2sl2p8x8e.fsf@synack.fr>
References: <200711212130.EJJ43745.LFOFHOSMJOtFVQ@I-love.SAKURA.ne.jp>
	<200711222235.GCA05378.HtMOJQVFSFOLFO@I-love.SAKURA.ne.jp>
	<Xine.LNX.4.64.0711231005270.4252@us.intercode.com.au>
	<200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-=-="
Cc: jmorris@namei.org, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, davem@davemloft.net,
	linux-security-module@vger.kernel.org, kaber@trash.net,
	netfilter-devel@lists.netfilter.org, sds@tycho.nsa.gov
To: Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp>
Return-path: <linux-security-module-owner@vger.kernel.org>
In-Reply-To: <200711241114.FCJ30702.JSMOFQtVHFFOOL@I-love.SAKURA.ne.jp>
	(Tetsuo Handa's message of "Sat, 24 Nov 2007 11:14:50 +0900")
Sender: linux-security-module-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

--=-=-=

Tetsuo Handa <penguin-kernel@I-love.SAKURA.ne.jp> writes:

> Hello.
>
> James Morris wrote:
>> From memory, one approach under discussion was to add netfilter hooks to 
>> the transport layer, which could be invoked correctly by each type of 
>> protocol when the target process is selected.
>> 
>> If this is done for netfilter, then an LSM hook is probably not needed at 
>> all, as security modules can utilize netfilter hooks directly.
>
> Patrick McHardy says (at http://marc.info/?l=linux-netdev&m=118495005800410&w=2 )
> "Even with socket filters netfilter doesn't know the final receipient
>  process, that is not known until it calls recvmsg and the data is read,
>  which is too late for netfilter."

Indeed, but there is another approach, using libnetfilter_queue.
I have the same goal as TOMOYO, let the user decided filtering, with
informations coming from LSM hook, which give more datas to the users,
specially with the relationship between the socket and the
user/process. 

My approach is to get the informations regarding the socket from
socket(), bind() and and accept() syscalls hooks.
Pushing this informations to userspace. Here the user can refuse or
accept the sycalls.
Then, for incoming data, we are using libnetfilter_queue from userspace.
And we can make a relation between the first delivered packet by
netfilter with our informations from the LSM hooks at socket(), bind() and
accept().

Let me get a example based on TCP/IP:
process X is executing this :
  - userspace  : socket()
  - kernel : sys_socket()
  - LSM : socket_create() -> pushing (process id, userid, protocol,
                             IP/ports) infos to userspace
  - userspace : bind()
  - kernel : sys_bind()
  - LSM : socket_bind() -> pushing (process id, userid, protocol,
                           IP/ports) infos to userspace
  - userspace : listen()
  - kernel : sys_listen() -> pushing (process id, userid, protocol,
                             IP/ports) infos to userspace

As now the application is listening on a port, we are waiting for the
TCP SYN packet coming from remote side.
When TCP SYN arrive, we can capture it with libnetfilter_queue.

Then we can make a relation between informations in the hearders from
the TCP SYN packet: (src/dst address IPs, dst/src/ ports, procotol) ie
the netfilter tuple, and our informations from the LSM hooks, ie we know
that process X did socket(), bind(), listen() on the same src address
IP, src port and protocol.

Then we can decide to drop or accept this packet, with
libnetfilter_queue.

this approach seems better because we already have *all* the tools from
the kernel side, except form the managing LSM interface with userspace,
but I already have some improvements on this (patch attached)

Please consider this approach as a better side because using netfilter
for filtering packets is the best solution, and that we can make a
relation between socket and packets with this idea, and this feature can
stay in userspace.

FYI, this project is named "network events connector", some people from
netfilter-devel list may already know it, because I made a talk about it
for the last netfilter workshop.

thank you.


--=-=-=
Content-Type: text/x-patch
Content-Disposition: inline; filename=cn_net.patch

diff --git a/drivers/connector/Kconfig b/drivers/connector/Kconfig
index 100bfd4..0d410f9 100644
--- a/drivers/connector/Kconfig
+++ b/drivers/connector/Kconfig
@@ -19,4 +19,12 @@ config PROC_EVENTS
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
 endif # CONNECTOR
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
index 0000000..4fde17f
--- /dev/null
+++ b/drivers/connector/cn_net.c
@@ -0,0 +1,1118 @@
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
+#include <linux/cn_net.h>
+#include <asm/unaligned.h>
+
+/* when waiting for a verdict, you get added to this */
+DECLARE_WAIT_QUEUE_HEAD(cn_net_wq);
+
+static atomic_t net_event_num_listeners = ATOMIC_INIT(0);
+static struct cb_id cn_net_event_id = { CN_IDX_NET, CN_VAL_NET };
+static char cn_net_event_name[] = "cn_net_event";
+static int secondary = 0;
+
+static struct rb_root event_tree = RB_ROOT;
+static rwlock_t event_lock = RW_LOCK_UNLOCKED;
+static struct rb_root verdict_tree = RB_ROOT;
+static rwlock_t verdict_lock = RW_LOCK_UNLOCKED;
+
+/* should we print out debug messages */
+static int debug = 0;
+static int delay = 5;
+
+module_param(debug, bool, 0600);
+MODULE_PARM_DESC(debug, "Debug enabled or not");
+module_param(delay, uint, 0600);
+MODULE_PARM_DESC(delay, "Set the default pending delay for events");
+
+#if defined(CONFIG_NET_EVENTS)
+#define MY_NAME THIS_MODULE->name
+#else
+#define MY_NAME "cn_net"
+#endif
+
+#define cn_net_dbg(fmt, arg...)					\
+	do {							\
+		if (debug)					\
+			printk(KERN_DEBUG "%s: %s: " fmt ,	\
+				MY_NAME , __FUNCTION__ , 	\
+				## arg);			\
+	} while (0)
+
+static const char *cn_net_syscall_name(const u8 syscall)
+{
+	static const char *syscall_name[] = {
+		[CN_NET_SOCKET_LISTEN]		= "LISTEN",
+		[CN_NET_SOCKET_BIND]		= "BIND",
+		[CN_NET_SOCKET_CONNECT]		= "CONNECT",
+		[CN_NET_SOCKET_SHUTDOWN]	= "SHUTDOWN",
+		[CN_NET_SK_FREE_SECURITY]	= "SK_FREE",
+		[CN_NET_SOCKET_ACCEPT]		= "ACCEPT",
+		[CN_NET_SOCKET_POST_ACCEPT]	= "POST_ACCEPT",
+	};
+	return syscall_name[syscall];
+};
+
+static const char *cn_net_msg_type_name(const u8 msg_type)
+{
+	static const char *msg_type_name[] = {
+		[CN_NET_NONE]		= "CN_NET_NONE",
+		[CN_NET_ACK]		= "CN_NET_ACK",
+		[CN_NET_DATA]		= "CN_NET_DATA",
+		[CN_NET_VERDICT]	= "CN_NET_VERDICT",
+		[CN_NET_CONFIG]		= "CN_NET_CONFIG",
+		[CN_NET_LISTEN]		= "CN_NET_LISTEN",
+		[CN_NET_IGNORE]		= "CN_NET_IGNORE",
+		[CN_NET_DUMP]		= "CN_NET_DUMP",
+	};
+	return msg_type_name[msg_type];
+};
+
+static const char *cn_net_config_name(const u8 config)
+{
+	static const char *config_name[] = {
+		[CN_NET_CONFIG_ADD]	= "CN_NET_CONFIG_ADD",
+		[CN_NET_CONFIG_DEL]	= "CN_NET_CONFIG_DEL",
+		[CN_NET_CONFIG_FLUSH]	= "CN_NET_CONFIG_FLUSH",
+	};
+	return config_name[config];
+}
+
+static const char *cn_net_verdict_name(const u8 verdict)
+{
+	static const char *verdict_name[] = {
+		[CN_NET_VERDICT_ACCEPT]		= "CN_NET_VERDICT_ACCEPT",
+		[CN_NET_VERDICT_DENY]		= "CN_NET_VERDICT_DENY",
+		[CN_NET_VERDICT_PENDING]	= "CN_NET_VERDICT_PENDING",
+		[CN_NET_VERDICT_POLICY]		= "CN_NET_VERDICT_POLICY",
+	};
+	return verdict_name[verdict];
+}
+
+/**
+ * is_same_event()
+ * check if two events are the same or not
+ */			 
+static unsigned int is_same_event(struct event one, struct event two)
+{
+	return ((one.syscall_num == two.syscall_num) &&
+		(one.protocol == two.protocol));
+}
+
+/**
+ * lookup_event()
+ * look for a match in the rbtree
+ * returns address of the wanted element if it is in the rbtree, or NULL
+ */
+static struct event_node *lookup_event(struct event ev)
+{
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
+ * check_wanted_event()
+ * we don't send unwanted informations to userspace, according to the
+ * dynamic configuration in the rbtree
+ */
+static int check_wanted_event(struct sock *sk, enum cn_net_socket syscall_num)
+{
+	int err = -EINVAL;
+	struct event ev;
+	
+	if (!sk)
+		return err;
+
+	ev.syscall_num = syscall_num;
+	ev.protocol = sk->sk_protocol;
+	       
+	/* check if the event is registered */
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
+static void dump_event(void)
+{
+	struct rb_node *p = NULL ;
+	struct event_node *tmp = NULL;
+	struct verdict_node *vtmp = NULL;
+
+	read_lock(&event_lock);
+	p = rb_first(&event_tree);
+	while (p) {
+		tmp = rb_entry(p, struct event_node, ev_node);
+		printk(KERN_INFO "%d:%s\n", tmp->ev.protocol,
+		       cn_net_syscall_name(tmp->ev.syscall_num));
+		p = rb_next(p);
+	}
+	read_unlock(&event_lock);
+
+	/* FIXME delete this code */
+	read_lock(&verdict_lock);
+	p = rb_first(&verdict_tree);
+	while (p) {
+		vtmp = rb_entry(p, struct verdict_node, v_node);
+		printk(KERN_INFO "0x%x:%s\n", vtmp->verdict.id,
+		       cn_net_verdict_name(vtmp->verdict.v));
+		p = rb_next(p);
+	}
+	read_unlock(&verdict_lock);
+}
+
+/**
+ * remove_all_events()
+ * delete all events registered in the rbtree
+ */
+static enum ack_err remove_all_events(void)
+{
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
+static struct event_node *alloc_event(void)
+{
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
+static enum ack_err insert_event(struct event ev)
+{
+	struct rb_node **rb_link, *rb_parent;
+	struct event_node *new_evn;
+	enum ack_err ret = CN_NET_ACK_SUCCES;
+
+	rb_link = &event_tree.rb_node;
+	rb_parent = NULL;
+
+	if ((new_evn = alloc_event()) != NULL) {
+		new_evn->ev.syscall_num = ev.syscall_num;
+		new_evn->ev.protocol = ev.protocol;
+	} else {
+		/* can't allocate memory, exiting */
+		ret = CN_NET_ACK_ENOMEM;
+		goto out;
+	}
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
+			write_unlock(&event_lock);
+			ret = CN_NET_ACK_EINCONFIG;
+			goto out_free;
+		}
+	}
+
+	/* no match: event is added to the tree */
+	rb_link_node(&new_evn->ev_node, rb_parent, rb_link);
+	rb_insert_color(&new_evn->ev_node, &event_tree);
+	write_unlock(&event_lock);
+	return ret;
+
+out_free:
+	kfree(new_evn);
+out:
+	return ret;
+}
+
+/**
+ * remove_event()  
+ * delete a entry from the rbtree
+ * we are checking if we are trying to delete a unregistered event
+ */
+static enum ack_err remove_event(struct event ev)
+{
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
+
+	write_unlock(&event_lock);
+	return ret;
+}
+
+/* routine for verdict_tree */
+
+/**
+ * __lookup_verdict()
+ * look for a match in the rbtree
+ * this function is not lock-safe, remember to lock verdict_lock when using
+ * returns address of the verdict_node if it is in the rbtree, or NULL
+ */
+static struct verdict_node *__lookup_verdict(__u32 id)
+{
+	struct rb_node *rb_node = verdict_tree.rb_node;
+
+	while (rb_node) {
+		struct verdict_node *cur = rb_entry(rb_node, struct verdict_node, v_node);
+		
+		if (cur->verdict.id == id) {
+			return cur;
+		}
+
+		if (id < cur->verdict.id)
+			rb_node = rb_node->rb_left;
+		else if (id > cur->verdict.id)
+			rb_node = rb_node->rb_right;
+	}
+
+	return NULL;
+}
+
+/** 
+ * apply_policy()
+ * when timer expires for a verdict, we apply the policy by default
+ */
+static void apply_policy(unsigned long arg)
+{
+	struct verdict_node *vnode;
+	__u32 id = (__u32) arg;
+
+	write_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode) {
+		vnode->verdict.v = DEFAULT_POLICY;
+		cn_net_dbg("apply_policy: id=0x%x verdict %d %s\n", /* FIXME debug to delete */
+			   vnode->verdict.id,
+			   (int)vnode->verdict.v,
+			   cn_net_verdict_name((int)vnode->verdict.v));
+	}
+	write_unlock(&verdict_lock);
+	wake_up(&cn_net_wq);
+}
+
+/** 
+ * alloc_verdict()
+ * alloc memory for a verdict_node, and return pointer to it
+ */
+static struct verdict_node *alloc_verdict(void)
+{
+	struct verdict_node *vnode = NULL;
+	vnode = kzalloc(sizeof(struct verdict_node), GFP_KERNEL);
+	return vnode;
+}
+
+/**
+ * insert_verdict()
+ * insert a verdict in the rbtree
+ * we are checking if we are trying to register a same verdict twice
+ * Returns 0 if insertion is ok, else -1
+ */
+static int insert_verdict(__u32 id)
+{
+	struct rb_node **rb_link, *rb_parent;
+	struct verdict_node *new_verdict;
+	enum ack_err ret = CN_NET_ACK_SUCCES;
+
+	rb_link = &verdict_tree.rb_node;
+	rb_parent = NULL;
+
+	if ((new_verdict = alloc_verdict()) != NULL) {
+		new_verdict->verdict.id = id;
+		new_verdict->verdict.v = CN_NET_VERDICT_PENDING;
+	} else {
+		/* can't allocate memory, exiting */
+		ret = CN_NET_ACK_ENOMEM;
+		goto out;
+	}
+
+	write_lock(&verdict_lock);
+
+	while(*rb_link) {
+		struct verdict_node *tmp;
+
+		rb_parent = *rb_link;
+		tmp = rb_entry(rb_parent, struct verdict_node, v_node);
+		
+		if (id < tmp->verdict.id)
+			rb_link = &rb_parent->rb_left;
+		else if (id > tmp->verdict.id)
+			rb_link = &rb_parent->rb_right;
+		else {
+			/* verdict is already registered */
+			write_unlock(&verdict_lock);
+			ret = CN_NET_ACK_EINCONFIG;
+			goto out_free;
+		}
+	}
+
+	/* setting timer to set defaut policy at expiration */
+	init_timer(&new_verdict->timer);
+	new_verdict->timer.expires = jiffies + delay*HZ;
+	new_verdict->timer.data = (unsigned long)id;
+	new_verdict->timer.function = apply_policy;	
+	/* no match: verdict is added to the tree */
+	rb_link_node(&new_verdict->v_node, rb_parent, rb_link);
+	rb_insert_color(&new_verdict->v_node, &verdict_tree);
+	write_unlock(&verdict_lock);
+	return 0;
+
+out_free:
+	kfree(new_verdict);
+out:
+	if (ret != CN_NET_ACK_SUCCES) /* error occured, inform userspace with CN_NET_ACK */
+		cn_net_ack(ret, id, 0, CN_NET_ACK);
+	return -1;
+}
+
+/* routine for verdict_tree */
+
+
+/**
+ * do_register()
+ * check if userpace protocol version is same as kernel protocol version
+ */
+static enum ack_err do_register(__u32 version)
+{
+	enum ack_err err = CN_NET_ACK_SUCCES;
+
+	cn_net_dbg("do_register: %d %d\n",
+		   version, CN_NET_VERSION);
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
+static enum ack_err do_config(struct config_msg *cfg)
+{
+	enum ack_err err = CN_NET_ACK_SUCCES;
+
+	cn_net_dbg("do_config: %s %s %d\n",
+		   cn_net_config_name(cfg->config_cmd),
+		   cn_net_syscall_name(cfg->ev.syscall_num),
+		   cfg->ev.protocol);
+
+	switch (cfg->config_cmd) {
+	case CN_NET_CONFIG_ADD:
+		err = insert_event(cfg->ev);
+		break;
+	case CN_NET_CONFIG_DEL:
+		err= remove_event(cfg->ev);
+		break;
+	case CN_NET_CONFIG_FLUSH:
+		err = remove_all_events();
+		break;
+	default:
+		err = CN_NET_ACK_EINTYPE;
+		break;
+	}
+	
+	return err;
+}
+
+/** 
+ * do_verdict()
+ * execute verdict for a CN_NET_DATA message
+ * return enum ack_err
+ */
+static enum ack_err do_verdict(struct verdict_msg *vdt)
+{
+	enum ack_err err = CN_NET_ACK_SUCCES;
+	struct verdict_node *vnode = NULL;
+
+	cn_net_dbg("do_verdict: 0x%x %d\n",
+		   vdt->id, vdt->v);
+
+	switch (vdt->v) {
+	case CN_NET_VERDICT_ACCEPT:
+	case CN_NET_VERDICT_DENY:
+	case CN_NET_VERDICT_POLICY:
+		write_lock(&verdict_lock);
+		vnode = __lookup_verdict(vdt->id);
+		if (vnode) {
+			vnode->verdict.v = vdt->v;
+			write_unlock(&verdict_lock);
+			wake_up(&cn_net_wq);
+		} else {
+			write_unlock(&verdict_lock);
+			err = CN_NET_ACK_EINCONFIG;
+		}
+		break;
+	default:
+		err = CN_NET_ACK_EINTYPE;
+		break;
+	}
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
+static void cn_net_ack(enum ack_err err, unsigned int rcvd_seq,
+		       unsigned int rcvd_ack, enum msg_type msg_type)
+{
+	struct cn_msg *m;
+	struct net_event *net_ev;
+	struct timespec ts;
+	__u8 buffer[CN_NET_MSG_SIZE];
+
+	cn_net_dbg("cn_net_ack: listen=%d\n",
+		   atomic_read(&net_event_num_listeners));
+	
+	/* no listener, no response, excepted for notifying that
+	   protocol version is not the same as in kernel */
+	if (atomic_read(&net_event_num_listeners) < 1 &&
+	    err != CN_NET_ACK_EBADPROTO) 
+		return;
+
+	m = (struct cn_msg *) buffer;
+	net_ev = (struct net_event *) m->data;
+
+	net_ev->msg_type = msg_type;
+/* 	ktime_get_real_ts(&net_ev->timestamp); */
+	ktime_get_real_ts(&ts);
+	put_unaligned(timespec_to_ns(&ts), (__u64 *)&net_ev->timestamp_ns);
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
+void cn_net_ctl(void *data)
+{
+	struct cn_msg *m = data;
+	struct net_event *net_ev = NULL;
+	enum msg_type msg_type;
+	enum ack_err err = CN_NET_ACK_SUCCES;
+
+	if (m->len != sizeof(struct net_event)) {
+		cn_net_dbg("cn_net_ctl : message with "
+			   "bad size, discard\n");
+		return;
+	}
+
+	net_ev = (struct net_event *) m->data;
+
+	if (net_ev->msg_type != CN_NET_LISTEN && 
+	    atomic_read(&net_event_num_listeners) < 1) {
+		cn_net_dbg("cn_net_ctl : register first\n");
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
+	case CN_NET_VERDICT:	/* userspace give verdict for the CN_NET_DATA msg*/
+		err = do_verdict(&(net_ev->net_event_data.verdict));
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
+	}
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
+static __u32 cn_net_send_event(struct sock *sk, struct sockaddr *address,
+					      enum cn_net_socket syscall_num)
+{
+	struct net_event *net_ev;
+	struct cn_msg *m;
+	struct inet_sock *inet = inet_sk(sk);
+	struct sockaddr_in *addr4 = NULL;
+	struct sockaddr_in6 *addr6 = NULL;
+	struct task_struct *me = current;
+	struct verdict_node *vnode = NULL;
+	struct timespec ts;
+	int insertion = -1;
+
+	__u8 buffer[CN_NET_MSG_SIZE];
+
+	cn_net_dbg("cn_net_ack: listen=%d\n",
+		   atomic_read(&net_event_num_listeners));
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
+/* 	ktime_get_real_ts(&net_ev->timestamp); */
+	ktime_get_real_ts(&ts);
+	put_unaligned(timespec_to_ns(&ts), (__u64 *)&net_ev->timestamp_ns);
+	net_ev->net_event_data.data.uid = me->uid;
+/* 	get_task_comm(net_ev->net_event_data.data.taskname, me); */
+	net_ev->net_event_data.data.pid = me->pid;
+	net_ev->net_event_data.data.ev.protocol = sk->sk_protocol;
+	net_ev->net_event_data.data.ev.syscall_num = syscall_num;
+	net_ev->net_event_data.data.family = sk->sk_family;
+	memcpy(&m->id, &cn_net_event_id, sizeof(m->id));
+	m->seq = get_random_int();
+	m->ack = 0;
+	m->len = sizeof(struct net_event);
+	
+	/* adding node entry to verdict_tree */
+	insertion = insert_verdict(m->seq);
+
+	if (insertion == 0) { /* sending CN_NET_DATA */
+		cn_netlink_send(m, CN_IDX_NET, gfp_any());
+		/* starting timer for default policy */
+		write_lock(&verdict_lock);
+		vnode = __lookup_verdict(m->seq);
+		if (vnode)
+			add_timer(&vnode->timer);
+		write_unlock(&verdict_lock);	
+	}
+out:
+	return m->seq;
+}
+
+static __u32 get_secure_verdict(__u32 id)
+{
+	struct verdict_node *vnode = NULL;
+	__u32 v;
+
+	read_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode)
+		v = vnode->verdict.v;
+	else
+		v = DEFAULT_POLICY;
+	read_unlock(&verdict_lock);
+	return v;
+}
+
+static int cn_net_socket_listen(struct socket *sock, int backlog)
+{
+	struct verdict_node *vnode = NULL;
+	enum verdict v;
+	__u32 id = 0;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	cn_net_dbg("cn_net_socket_listen\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_LISTEN) == 0)
+		id = cn_net_send_event(sock->sk, NULL, CN_NET_SOCKET_LISTEN);
+
+/* 	if (!vnode) { */
+/* 		cn_net_dbg("cn_net_socket_listen: apply default_policy vnode == NULL\n"); */
+/* 		v = DEFAULT_POLICY; */
+/* 	} else { */
+	add_wait_queue(&cn_net_wq, &myself);
+	for(;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if ((v = get_secure_verdict(id)) != CN_NET_VERDICT_PENDING)
+			break;
+		schedule();
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(&cn_net_wq, &myself);
+	/* remove verdict_node for rbtree */
+	write_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode) {
+		rb_erase(&vnode->v_node, &verdict_tree);
+		del_timer_sync(&vnode->timer);
+	}
+	write_unlock(&verdict_lock);
+	kfree(vnode);
+/* } */
+	cn_net_dbg("cn_net_socket_listen: verdict %d %s\n", (int) v,
+		   cn_net_verdict_name((int)v));
+	return v == CN_NET_VERDICT_POLICY ? DEFAULT_POLICY : (int)v;
+}
+
+static int cn_net_socket_bind(struct socket *sock,
+			      struct sockaddr *address, int addrlen)
+{
+	struct verdict_node *vnode = NULL;
+	enum verdict v;
+	__u32 id = 0;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	cn_net_dbg("cn_net_socket_bind\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_BIND) == 0)
+		id = cn_net_send_event(sock->sk, address, CN_NET_SOCKET_BIND);
+
+/* 	if (!vnode) { */
+/* 		cn_net_dbg("cn_net_socket_bind: apply default_policy vnode == NULL\n"); */
+/* 		v = DEFAULT_POLICY; */
+/* 	} else { */
+	add_wait_queue(&cn_net_wq, &myself);
+	for(;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if ((v = get_secure_verdict(id)) != CN_NET_VERDICT_PENDING)
+			break;
+		schedule();
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(&cn_net_wq, &myself);
+	/* remove verdict_node for rbtree */
+	write_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode) {
+		rb_erase(&vnode->v_node, &verdict_tree);
+		del_timer_sync(&vnode->timer);
+	}
+	write_unlock(&verdict_lock);
+	kfree(vnode);
+/* } */
+	cn_net_dbg("cn_net_socket_bind: verdict %d %s\n", (int) v,
+		   cn_net_verdict_name((int)v));
+	return v == CN_NET_VERDICT_POLICY ? DEFAULT_POLICY : (int)v;
+
+}
+
+static int cn_net_socket_connect(struct socket *sock,
+				 struct sockaddr *address, int addrlen)
+{
+	struct verdict_node *vnode = NULL;
+	enum verdict v;
+	__u32 id = 0;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	cn_net_dbg("cn_net_socket_connect\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_CONNECT) == 0)
+		id = cn_net_send_event(sock->sk, address, CN_NET_SOCKET_CONNECT);
+
+/* 	if (!vnode) { */
+/* 		cn_net_dbg("cn_net_socket_connect: apply default_policy vnode == NULL\n"); */
+/* 		v = DEFAULT_POLICY; */
+/* 	} else { */
+	add_wait_queue(&cn_net_wq, &myself);
+	for(;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if ((v = get_secure_verdict(id)) != CN_NET_VERDICT_PENDING)
+			break;
+		schedule();
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(&cn_net_wq, &myself);
+	/* remove verdict_node for rbtree */
+	write_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode) {
+		rb_erase(&vnode->v_node, &verdict_tree);
+		del_timer_sync(&vnode->timer);
+	}
+	write_unlock(&verdict_lock);
+	kfree(vnode);
+/* } */
+	cn_net_dbg("cn_net_socket_connect: verdict %d %s\n", (int) v,
+		   cn_net_verdict_name((int)v));
+	return v == CN_NET_VERDICT_POLICY ? DEFAULT_POLICY : (int)v;
+}
+
+static int cn_net_socket_shutdown(struct socket *sock, int how)
+{
+	struct verdict_node *vnode = NULL;
+	enum verdict v;
+	__u32 id = 0;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	cn_net_dbg("cn_net_socket_shutdown\n");
+	if (check_wanted_event(sock->sk, CN_NET_SOCKET_SHUTDOWN) == 0)
+		id = cn_net_send_event(sock->sk, NULL, CN_NET_SOCKET_SHUTDOWN);
+
+/* 	if (!vnode) { */
+/* 		cn_net_dbg("cn_net_socket_shutdown: apply default_policy vnode == NULL\n"); */
+/* 		v = DEFAULT_POLICY; */
+/* 	} else { */
+	add_wait_queue(&cn_net_wq, &myself);
+	for(;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if ((v = get_secure_verdict(id)) != CN_NET_VERDICT_PENDING)
+			break;
+		schedule();
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(&cn_net_wq, &myself);
+	/* remove verdict_node for rbtree */
+	write_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode) {
+		rb_erase(&vnode->v_node, &verdict_tree);
+		del_timer_sync(&vnode->timer);
+	}
+	write_unlock(&verdict_lock);
+	kfree(vnode);
+/* } */
+	cn_net_dbg("cn_net_socket_shutdown: verdict %d %s\n", (int) v,
+		   cn_net_verdict_name((int)v));
+	return v == CN_NET_VERDICT_POLICY ? DEFAULT_POLICY : (int)v;
+}
+
+static void cn_net_sk_free_security(struct sock *sk)
+{
+	struct verdict_node *vnode = NULL;
+	enum verdict v;
+	__u32 id = 0;
+
+	DECLARE_WAITQUEUE(myself, current);
+
+	cn_net_dbg("cn_net_sk_free_security\n");
+	if (check_wanted_event(sk, CN_NET_SK_FREE_SECURITY) == 0)
+		id = cn_net_send_event(sk, NULL, CN_NET_SK_FREE_SECURITY);
+
+/* 	if (!vnode) { */
+/* 		cn_net_dbg("cn_net_socket_free_security: apply default_policy vnode == NULL\n"); */
+/* 		v = DEFAULT_POLICY; */
+/* 	} else { */
+	add_wait_queue(&cn_net_wq, &myself);
+	for(;;) {
+		set_current_state(TASK_INTERRUPTIBLE);
+		if ((v = get_secure_verdict(id)) != CN_NET_VERDICT_PENDING)
+			break;
+		schedule();
+	}
+	set_current_state(TASK_RUNNING);
+	remove_wait_queue(&cn_net_wq, &myself);
+	/* remove verdict_node for rbtree */
+	write_lock(&verdict_lock);
+	vnode = __lookup_verdict(id);
+	if (vnode) {
+		rb_erase(&vnode->v_node, &verdict_tree);
+		del_timer_sync(&vnode->timer);
+	}
+	write_unlock(&verdict_lock);
+	kfree(vnode);
+/* } */
+	cn_net_dbg("cn_net_socket_free_security: verdict %d %s\n", (int) v,
+		   cn_net_verdict_name((int)v));
+	return;
+}
+
+static void cn_net_socket_post_accept(struct socket *sock, struct socket *newsock)
+{
+	struct inet_sock *inet;
+	struct inet_sock *newinet;
+
+	inet = inet_sk(sock->sk);
+	newinet = inet_sk(newsock->sk);
+
+	cn_net_dbg("cn_net_socket_post_accept\n");
+/* 	if (check_wanted_event(sk, CN_NET_SOCKET_ACCEPT) == 0) */
+/* 		cn_net_socket_accept(sk, NULL, CN_NET_SOCKET_ACCEPT); */
+	printk(KERN_INFO "post_accept: type: %d:%d sock=("NIPQUAD_FMT":%u -> "NIPQUAD_FMT":%u) "
+	       "newsock=("NIPQUAD_FMT":%u -> "NIPQUAD_FMT":%u)\n",
+	       sock->type, newsock->type,
+	       NIPQUAD(inet->saddr), ntohs(inet->sport),
+	       NIPQUAD(inet->daddr), ntohs(inet->dport),
+	       NIPQUAD(newinet->saddr), ntohs(newinet->sport),
+	       NIPQUAD(newinet->daddr), ntohs(newinet->dport));
+	
+	return;
+}
+
+static int cn_net_socket_accept(struct socket *sock, struct socket *newsock)
+{
+	struct inet_sock *inet;
+
+	inet = inet_sk(sock->sk);
+
+	cn_net_dbg("cn_net_socket_accept\n");
+/* 	if (check_wanted_event(sk, CN_NET_SOCKET_ACCEPT) == 0) */
+/* 		cn_net_socket_accept(sk, NULL, CN_NET_SOCKET_ACCEPT); */
+	printk(KERN_INFO "accept: %d: sock=("NIPQUAD_FMT":%u -> "NIPQUAD_FMT":%u)\n",
+	       sock->type,
+	       NIPQUAD(inet->saddr), ntohs(inet->sport),
+	       NIPQUAD(inet->daddr), ntohs(inet->dport));
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
+	.socket_accept		= cn_net_socket_accept,
+	.socket_post_accept	= cn_net_socket_post_accept,
+};
+
+static int __init init(void)
+{
+	int err = 0;
+
+	err = cn_add_callback(&cn_net_event_id, cn_net_event_name, &cn_net_ctl);
+	if (err) {
+		printk(KERN_WARNING "cn_net: failure add connector callback\n");
+		goto out_callback;
+	}
+
+	if (register_security(&cn_net_security_ops)) {
+		printk(KERN_INFO "cn_net: failure registering with kernel\n");
+		if (mod_reg_security(MY_NAME, &cn_net_security_ops)) {
+			printk(KERN_WARNING
+			       "cn_net: failure registering with "
+			       "primary security module\n");
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
+static void __exit fini(void)
+{
+	if (secondary) {
+		if (mod_unreg_security(MY_NAME, &cn_net_security_ops))
+			printk(KERN_INFO "cn_net: failure unregistering with "
+					 "primary security module\n");
+	} else {
+		if (unregister_security(&cn_net_security_ops))
+			printk(KERN_INFO "cn_net: failure unregistering with "
+					 "kernel\n");
+	}
+	
+	cn_del_callback(&cn_net_event_id);
+	
+	/* clean memory */
+	remove_all_events();
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
index 0000000..8c8ba56
--- /dev/null
+++ b/include/linux/cn_net.h
@@ -0,0 +1,146 @@
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
+#define CN_NET_VERSION	0x1
+#define DEFAULT_POLICY	CN_NET_VERDICT_ACCEPT
+
+#define CN_NET_MSG_SIZE (sizeof(struct cn_msg) + sizeof(struct net_event))
+
+/**
+ * identify which syscall has been called.
+ */
+enum cn_net_socket {
+	CN_NET_SOCKET_LISTEN = 0,
+	CN_NET_SOCKET_BIND,
+	CN_NET_SOCKET_CONNECT,
+	CN_NET_SOCKET_SHUTDOWN,
+	CN_NET_SK_FREE_SECURITY,
+	CN_NET_SOCKET_ACCEPT,
+	CN_NET_SOCKET_POST_ACCEPT,
+	CN_NET_SOCKET_MAX,
+};
+
+/**
+ * Protocol message type
+ */
+enum msg_type {
+	CN_NET_NONE = 0,
+	CN_NET_ACK,
+	CN_NET_DATA,
+	CN_NET_VERDICT,
+	CN_NET_CONFIG,
+	CN_NET_LISTEN,
+	CN_NET_IGNORE,
+	CN_NET_DUMP,
+};
+
+/**
+ * values for CN_NET_ACK messages
+ */
+enum ack_err {
+	CN_NET_ACK_SUCCES = 0,
+	CN_NET_ACK_ENOMEM,
+	CN_NET_ACK_EINCONFIG,
+	CN_NET_ACK_EINTYPE,
+	CN_NET_ACK_EBADPROTO,
+};
+
+/**
+ * values for CN_NET_VERDICT messages
+ */
+enum verdict {
+	CN_NET_VERDICT_ACCEPT = 0,
+	CN_NET_VERDICT_DENY,
+	CN_NET_VERDICT_PENDING,
+	CN_NET_VERDICT_POLICY,
+};
+
+/**
+ * values for CN_NET_CONFIG messages
+ */
+enum config_cmd {
+	CN_NET_CONFIG_ADD = 0,
+	CN_NET_CONFIG_DEL,
+	CN_NET_CONFIG_FLUSH,
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
+struct config_msg {
+	enum config_cmd config_cmd;
+	struct event ev; 
+};
+
+struct verdict_msg {
+	__u32 id;
+	enum verdict v;
+};
+
+struct verdict_node {
+	struct rb_node v_node;
+	struct timer_list timer;
+	struct verdict_msg verdict;
+};
+
+struct net_event {
+	enum msg_type msg_type;
+	__u64 __attribute__((aligned(8))) timestamp_ns;
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
+			pid_t pid;
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
+		struct config_msg config;
+		/* send verdict to kernel */
+		struct verdict_msg verdict;
+	} net_event_data;
+};
+
+static void cn_net_ack(enum ack_err err, unsigned int rcvd_seq,
+		       unsigned int rcvd_ack, enum msg_type msg_type);
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

--=-=-=--
