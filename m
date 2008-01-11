From: "Randy Macleod" <macleodr@nortel.com>
Subject: RFC: TIPC API, bind to two networks
Date: Fri, 11 Jan 2008 14:42:39 -0500
Message-ID: <4787C6AF.7000308@nortel.com>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="------------010907070504030207040400"
Cc: Chris Friesen <cfriesen@nortel.com>,
	tipc <tipc-discussion@lists.sourceforge.net>,
	Ravik Rao <ravik.rao@tcs.com>
To: netdev@vger.kernel.org
Return-path: <tipc-discussion-bounces@lists.sourceforge.net>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=tipc-discussion>
List-Post: <mailto:tipc-discussion@lists.sourceforge.net>
List-Help: <mailto:tipc-discussion-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/tipc-discussion>,
	<mailto:tipc-discussion-request@lists.sourceforge.net?subject=subscribe>
Sender: tipc-discussion-bounces@lists.sourceforge.net
Errors-To: tipc-discussion-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------010907070504030207040400
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit


I'd like some feedback on a change to TIPC that I plan
to submit to netdev/kernel.org. At this stage, I'm interested
in what people think about using the protocol parameter
of the socket interface to select a TIPC stack for the socket.
My co-worker, Chris Friesen, has suggested that it would
be more conventional to extend the TIPC sockaddr to
select the appropriate network in calls to sendto() or bind().
I prefer socket(,,protocol) approach.

Some background:

We use TIPC in an ATCA chassis (Advanced Telecommunications Computing
Architecture). An ATCA chassis may have two networks commonly called
base and data (outside of the ATCA world base is called control).

Users want to be able to create a TIPC socket that is
bound to one network OR the other. The intention is that these
networks should be isolated as much as possible.

The attached patch accomplishes this by using the protocol
parameter of the socket() syscall. A user can specify the TIPC stack
to which the socket should be attached as follows:
     int socket(int domain, int type, int protocol);
     fd = socket(AF_TIPC, SOCK_SEQPACKET, 1);
In the unpatched TIPC code the protocol was required to be zero.
This requires that the user know the network topology or that the
system designer provide an API (get_base_netid(), get_data_netid()).

The patch is for tipc-1.5.12 which you can get from tipc.sf.net.
We're way back on linux-2.6.14 - gotta love the embedded world!

In terms of implementation,
the basic idea of the patch is to introduce a layer in the
TIPC code around socket creation and tipc netlink messages.
This layer lets TIPC stack code register callback functions and
then dispatches socket() and netlink calls to the appropriate
TIPC stack.

For example usage, please see:
<http://sourceforge.net/mailarchive/message.php?msg_name=476839F3.8070203%40nortel.com>

One note for those who might not read the link above....
I create two modules: tipc.ko and tipcstack.ko
these are ~98% identical with certain bits of functionality,
like registering AF_TIPC, disabled. This means that we have
the same bits of code loaded twice but that's a feature not
a bug! It means that the control and data networks are even
more independent so you could update one but not the other
or you could use system tap on one but not the other.



diffstat:
    Makefile                |   15 +++-
    include/net/tipc/tipc.h |   11 ++-
    net/tipc/core.c         |  157
+++++++++++++++++++++++-------------------------
    net/tipc/core.h         |   25 +++++++
    net/tipc/handler.c      |   17 +++--
    net/tipc/netlink.c      |   21 +++++-
    net/tipc/socket.c       |   55 ++++++++++++----
    net/tipc/vtipc.c        |  154
+++++++++++++++++++++++++++++++++++++++++++++++
    net/tipc/vtipc.h        |   48 ++++++++++++++
    tools/tipc-config.c     |   29 ++++++--


Even though I *don't* want the attached patch to be integrated
into the kernel (yet), I'm still going to include:
Signed-off-by: Randy MacLeod (macleodr@nortel.com)
because it's taken such a long time to get Nortel to bless
official kernel participation!

// Randy



--------------010907070504030207040400
Content-Type: text/plain;
 name="tipc-1.5.12-vtipc-01.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="tipc-1.5.12-vtipc-01.patch"

diff -Naur tipc-1.5.12_orig/include/net/tipc/tipc.h tipc-1.5.12_gmt/include/net/tipc/tipc.h
--- tipc-1.5.12_orig/include/net/tipc/tipc.h	2005-12-15 00:48:48.000000000 +0530
+++ tipc-1.5.12_gmt/include/net/tipc/tipc.h	2007-12-17 21:41:19.000000000 +0530
@@ -71,7 +71,6 @@
 	__u32 lower;
 	__u32 upper;
 };
-
 static inline __u32 tipc_addr(unsigned int zone,
 			      unsigned int cluster,
 			      unsigned int node)
@@ -213,13 +212,21 @@
 /*
  * TIPC-specific socket option values
  */
-
 #define SOL_TIPC		50	/* TIPC socket option level */
+
 #define TIPC_IMPORTANCE		127	/* Default: TIPC_LOW_IMPORTANCE */
 #define TIPC_SRC_DROPPABLE	128	/* Default: 0 (resend congested msg) */
 #define TIPC_DEST_DROPPABLE	129	/* Default: based on socket type */
 #define TIPC_CONN_TIMEOUT     	130	/* Default: 8000 (ms)  */
 
+#define TIPC_STACK_0     	0	/* Default TIPC stack */
+#define TIPC_STACK_1     	1	/* 1st TIPC stack */
+#define TIPC_STACK_2     	2	/* 2nd TIPC stack */
+#define TIPC_STACK_3     	3	/* 3rd TIPC stack */
+#define TIPC_STACK_4     	4	/* 4th TIPC stack */
+#define TIPC_STACK_5     	5	/* 5th TIPC stack */
+#define TIPC_STACK_6     	6	/* 6th TIPC stack */
+#define TIPC_STACK_7     	7	/* 7th TIPC stack */
 
 #ifdef __KERNEL__
 
diff -Naur tipc-1.5.12_orig/Makefile tipc-1.5.12_gmt/Makefile
--- tipc-1.5.12_orig/Makefile	2005-06-23 00:10:12.000000000 +0530
+++ tipc-1.5.12_gmt/Makefile	2007-12-18 01:41:20.000000000 +0530
@@ -3,8 +3,6 @@
 #
 
 SHELL = /bin/bash
-
-
  
 ifdef KERNELDIR
 	KINCLUDE = ${KERNELDIR}/include
@@ -22,8 +20,19 @@
 	   -DCONFIG_TIPC_DEBUG
 
 obj-m += tipc.o
+obj-m += tipcstack.o
+
+tipc-objs += net/tipc/addr.o  net/tipc/bcast.o  net/tipc/discover.o  \
+	net/tipc/cluster.o  net/tipc/dbg.o  net/tipc/link.o  \
+	net/tipc/config.o net/tipc/bearer.o  net/tipc/msg.o  \
+	net/tipc/name_distr.o  net/tipc/subscr.o  \
+	net/tipc/name_table.o net/tipc/net.o  net/tipc/node.o  \
+	net/tipc/node_subscr.o  net/tipc/port.o \
+	net/tipc/ref.o net/tipc/user_reg.o net/tipc/zone.o  \
+	net/tipc/core.o  net/tipc/handler.o  net/tipc/netlink.o \
+	net/tipc/socket.o net/tipc/eth_media.o net/tipc/vtipc.o
 
-tipc-objs +=  net/tipc/addr.o  net/tipc/bcast.o  net/tipc/discover.o  \
+tipcstack-objs +=  net/tipc/addr.o  net/tipc/bcast.o  net/tipc/discover.o  \
 	net/tipc/cluster.o  net/tipc/dbg.o  net/tipc/link.o  \
 	net/tipc/config.o net/tipc/bearer.o  net/tipc/msg.o  \
 	net/tipc/name_distr.o  net/tipc/subscr.o  \
diff -Naur tipc-1.5.12_orig/net/tipc/core.c tipc-1.5.12_gmt/net/tipc/core.c
--- tipc-1.5.12_orig/net/tipc/core.c	2006-06-23 01:38:04.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/core.c	2007-12-19 01:01:06.000000000 +0530
@@ -135,16 +135,20 @@
 #include "name_table.h"
 #include "subscr.h"
 #include "config.h"
-
+#include "vtipc.h"
+extern struct net_vtipc_proto vtipc_ops;
 int  eth_media_start(void);
 void eth_media_stop(void);
-int  handler_start(void);
-void handler_stop(void);
-int  socket_init(void);
-void socket_stop(void);
+int  handler_start(int role, int stack_id);
+void handler_stop(int role, int stack_id);
+int  socket_init(int role, int stack_id, struct net_vtipc_proto *vtipc_ops);
+void socket_stop(int role, int stack_id);
 int  netlink_start(void);
 void netlink_stop(void);
 
+int start_core_base(int role, int stack_id);
+int start_core_stack(int role, int stack_id);
+
 #define TIPC_MOD_VER "1.5.12"
 
 #ifndef CONFIG_TIPC_ZONES
@@ -179,6 +183,14 @@
 
 const char tipc_alphabet[] = 
 	"ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789_";
+// Module parameters 
+static int tipc_role;
+module_param(tipc_role, int, TIPC_ROLE_FULL);
+MODULE_PARM_DESC(tipc_role, "Role of tipc: 0 = full stack, 1 = core only, 2 = stack only");
+
+static int tipc_stack_id;
+module_param(tipc_stack_id, int, 0);
+MODULE_PARM_DESC(tipc_stack_id, "TIPC stack id: 0-7 permitted.");
 
 /* configurable TIPC parameters */
 
@@ -224,11 +236,53 @@
 	return res;
 }
 
+
+/**
+ * start_core_base - TIPC Base module function
+ */
+int start_core_base(int role, int stack_id)
+{
+	int res = 0;
+        vtipc_ops.tipc_own_addr_p = &tipc_own_addr;
+        vtipc_ops.stack_number = stack_id;
+
+	info("Loading TIPC core module.\n");
+	if (role != TIPC_ROLE_STACK)
+		res = netlink_start();
+	if (res != 0 || 
+	    (res = socket_init(role, stack_id, &vtipc_ops))) {
+		stop_core(role, stack_id);
+	}
+	return res;
+}
+
+/**
+ * start_core_stack - TIPC stack module function
+ */
+int start_core_stack(int role, int stack_id)
+{
+	int res;
+	if (role == TIPC_ROLE_CORE)
+		return 0;
+
+	info("Loading TIPC stack %d.\n", stack_id);
+	if ((res = handler_start(role, stack_id)) ||
+           (res = ref_table_init(tipc_max_ports + tipc_max_subscriptions,
+                                 tipc_random)) ||
+           (res = reg_start()) ||
+           (res = nametbl_init()) ||
+           (res = k_signal((Handler)subscr_start, 0)) ||
+           (res = k_signal((Handler)cfg_init, 0))) {
+		stop_core(role, stack_id);
+	}
+	return res;
+}
+
 /**
  * stop_core - switch TIPC from SINGLE NODE to NOT RUNNING mode
  */
 
-void stop_core(void)
+void stop_core(int role, int stack_id)
 {
 	if (tipc_mode != TIPC_NODE_MODE)
 		return;
@@ -236,20 +290,20 @@
 	tipc_mode = TIPC_NOT_RUNNING;
 
 	netlink_stop();
-	handler_stop();
+	handler_stop(role, stack_id);
 	cfg_stop();
 	subscr_stop();
 	reg_stop();
 	nametbl_stop();
 	ref_table_stop();
-	socket_stop();
+	socket_stop(role, stack_id);
 }
 
 /**
  * start_core - switch TIPC from NOT RUNNING to SINGLE NODE mode
  */
 
-int start_core(void)
+int start_core(int role, int stack_id)
 {
 	int res;
 
@@ -259,16 +313,10 @@
 	get_random_bytes(&tipc_random, sizeof(tipc_random));
 	tipc_mode = TIPC_NODE_MODE;
 
-	if ((res = handler_start()) || 
-	    (res = ref_table_init(tipc_max_ports + tipc_max_subscriptions,
-				  tipc_random)) ||
-	    (res = reg_start()) ||
-	    (res = nametbl_init()) ||
-            (res = k_signal((Handler)subscr_start, 0)) ||
-	    (res = k_signal((Handler)cfg_init, 0)) || 
-	    (res = netlink_start()) ||
-	    (res = socket_init())) {
-		stop_core();
+	if ((res = start_core_base(role, stack_id)) ||
+	    (res = start_core_stack(role, stack_id))) {
+		info("Loading failed.\n");
+		stop_core(role, stack_id);
 	}
 	return res;
 }
@@ -293,7 +341,16 @@
 	tipc_max_slaves = delimit(CONFIG_TIPC_SLAVE_NODES, 0, 2047);
 	tipc_net_id = 4711;
 
-	if ((res = start_core()))
+        info("The TIPC role is %d\n", tipc_role);
+        info("The TIPC stack id is %d\n", tipc_stack_id);
+        if (tipc_stack_id >= MAX_TIPC_STACKS) {
+                info("Tipc stack id %d invalid (0 - %d stacks allowed).\n",
+		     tipc_stack_id, MAX_TIPC_STACKS-1);
+                res = -EFAULT;
+                return res;
+        }
+
+	if ((res = start_core(tipc_role, tipc_stack_id)))
 		err("Unable to start in single node mode\n");
 	else	
 		info("Started in single node mode\n");
@@ -303,7 +360,7 @@
 static void __exit tipc_exit(void)
 {
 	stop_net();
-	stop_core();
+	stop_core(tipc_role, tipc_stack_id);
 	info("Deactivated\n");
 	log_stop();
 }
@@ -314,61 +371,3 @@
 MODULE_DESCRIPTION("TIPC: Transparent Inter Process Communication");
 MODULE_LICENSE("Dual BSD/GPL");
 MODULE_VERSION(TIPC_MOD_VER);
-
-/* Native TIPC API for kernel-space applications (see tipc.h) */
-
-EXPORT_SYMBOL(tipc_attach);
-EXPORT_SYMBOL(tipc_detach);
-EXPORT_SYMBOL(tipc_get_addr);
-EXPORT_SYMBOL(tipc_get_mode);
-EXPORT_SYMBOL(tipc_createport);
-EXPORT_SYMBOL(tipc_deleteport);
-EXPORT_SYMBOL(tipc_ownidentity);
-EXPORT_SYMBOL(tipc_portimportance);
-EXPORT_SYMBOL(tipc_set_portimportance);
-EXPORT_SYMBOL(tipc_portunreliable);
-EXPORT_SYMBOL(tipc_set_portunreliable);
-EXPORT_SYMBOL(tipc_portunreturnable);
-EXPORT_SYMBOL(tipc_set_portunreturnable);
-EXPORT_SYMBOL(tipc_publish);
-EXPORT_SYMBOL(tipc_withdraw);
-EXPORT_SYMBOL(tipc_connect2port);
-EXPORT_SYMBOL(tipc_disconnect);
-EXPORT_SYMBOL(tipc_shutdown);
-EXPORT_SYMBOL(tipc_isconnected);
-EXPORT_SYMBOL(tipc_peer);
-EXPORT_SYMBOL(tipc_ref_valid);
-EXPORT_SYMBOL(tipc_send);
-EXPORT_SYMBOL(tipc_send_buf);
-EXPORT_SYMBOL(tipc_send2name);
-EXPORT_SYMBOL(tipc_forward2name);
-EXPORT_SYMBOL(tipc_send_buf2name);
-EXPORT_SYMBOL(tipc_forward_buf2name);
-EXPORT_SYMBOL(tipc_send2port);
-EXPORT_SYMBOL(tipc_forward2port);
-EXPORT_SYMBOL(tipc_send_buf2port);
-EXPORT_SYMBOL(tipc_forward_buf2port);
-EXPORT_SYMBOL(tipc_multicast);
-/* EXPORT_SYMBOL(tipc_multicast_buf); not available yet */
-EXPORT_SYMBOL(tipc_ispublished);
-EXPORT_SYMBOL(tipc_available_nodes);
-
-/* TIPC API for external bearers (see tipc_bearer.h) */
-
-EXPORT_SYMBOL(tipc_block_bearer);
-EXPORT_SYMBOL(tipc_continue); 
-EXPORT_SYMBOL(tipc_disable_bearer);
-EXPORT_SYMBOL(tipc_enable_bearer);
-EXPORT_SYMBOL(tipc_recv_msg);
-EXPORT_SYMBOL(tipc_register_media); 
-
-/* TIPC API for external APIs (see tipc_port.h) */
-
-EXPORT_SYMBOL(tipc_createport_raw);
-EXPORT_SYMBOL(tipc_set_msg_option);
-EXPORT_SYMBOL(tipc_reject_msg);
-EXPORT_SYMBOL(tipc_send_buf_fast);
-EXPORT_SYMBOL(tipc_acknowledge);
-EXPORT_SYMBOL(tipc_get_port);
-EXPORT_SYMBOL(tipc_get_handle);
-
diff -Naur tipc-1.5.12_orig/net/tipc/core.h tipc-1.5.12_gmt/net/tipc/core.h
--- tipc-1.5.12_orig/net/tipc/core.h	2006-06-29 19:27:00.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/core.h	2007-12-19 01:16:04.000000000 +0530
@@ -66,6 +66,16 @@
 
 #define assert(i)  BUG_ON(!(i))
 
+/*
+ * The role specifies if the loaded module is tipc core,
+ * stack or both.
+ */
+#define TIPC_ROLE_FULL  0
+#define TIPC_ROLE_CORE  1
+#define TIPC_ROLE_STACK 2
+
+#define MAX_TIPC_STACKS 8
+
 struct tipc_msg;
 extern struct print_buf *CONS, *LOG;
 extern struct print_buf *TEE(struct print_buf *, struct print_buf *);
@@ -174,12 +184,23 @@
 extern atomic_t tipc_user_count;
 
 
+struct net_vtipc_proto {
+	int    stack_number;
+	u32  *tipc_own_addr_p;
+	int    (*registration)(struct socket *sock, int protocol);
+	struct sk_buff *(*netlink_registration)(__u32 orig_node, __u16 cmd,
+						const void *req_tlv_area,
+						int req_tlv_space,
+						int headroom);
+	struct module   *owner;
+};
+
 /*
  * Routines available to privileged subsystems
  */
 
-extern int  start_core(void);
-extern void stop_core(void);
+extern int  start_core(int role, int stack_id);
+extern void stop_core(int role, int stack_id);
 extern int  start_net(void);
 extern void stop_net(void);
 
diff -Naur tipc-1.5.12_orig/net/tipc/handler.c tipc-1.5.12_gmt/net/tipc/handler.c
--- tipc-1.5.12_orig/net/tipc/handler.c	2005-11-17 03:02:00.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/handler.c	2007-12-19 01:46:46.000000000 +0530
@@ -144,11 +144,18 @@
 	spin_unlock_bh(&qitem_lock);
 }
 
-int handler_start(void)
+int handler_start(int role, int stack_id)
 {
-	tipc_queue_item_cache = 
-		kmem_cache_create("tipc_queue_items", sizeof(struct queue_item),
-				  0, SLAB_HWCACHE_ALIGN, NULL, NULL);
+	#define tipc_qi_length 20
+	static char tipc_queue_items[tipc_qi_length] = {0};
+	/*The stack_id should be 2 digits*/
+	if (stack_id > 99) {
+		err("stack id out of range 0 - 99.\n");
+		return -ENOMEM;
+	}
+	snprintf(tipc_queue_items, tipc_qi_length, "tipc_queue_items_%02d", stack_id);
+        tipc_queue_item_cache = kmem_cache_create(tipc_queue_items, 
+		sizeof(struct queue_item), 0, SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!tipc_queue_item_cache)
 		return -ENOMEM;
 
@@ -158,7 +165,7 @@
 	return 0;
 }
 
-void handler_stop(void)
+void handler_stop(int role, int stack_id)
 {
 	struct list_head *l, *n;
 	struct queue_item *item; 
diff -Naur tipc-1.5.12_orig/net/tipc/netlink.c tipc-1.5.12_gmt/net/tipc/netlink.c
--- tipc-1.5.12_orig/net/tipc/netlink.c	2005-11-10 22:13:24.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/netlink.c	2007-12-19 01:02:27.000000000 +0530
@@ -60,6 +60,7 @@
 #include "core.h"
 #include "config.h"
 
+extern struct net_vtipc_proto *tipc_families[MAX_TIPC_STACKS];
 #ifdef ENABLE_NETLINK_GENERIC
 /*
  * NETLINK_GENERIC
@@ -158,13 +159,29 @@
 
 	if ((req_nlh->nlmsg_type & 0xC000) && (!capable(CAP_NET_ADMIN)))
 		rep_buf = cfg_reply_error_string(TIPC_CFG_NOT_NET_ADMIN);
-	else
+/*
+ * RKR: TODO : req_nlh->nlmsg_flags > 0
+ * Not Sure if we really need to handle stack zero as a special case?
+ * Even if we are running in the original tipc mode, we could introduce
+ * the additional registration and callback layer that we use for vtipc stacks.
+ * Need to modify this.
+ */
+	if (req_nlh->nlmsg_flags > 0) {
+		if (tipc_families[req_nlh->nlmsg_flags]) {
+       		 rep_buf = (*(tipc_families[req_nlh->nlmsg_flags]->netlink_registration))
+				((*tipc_families[req_nlh->nlmsg_flags]->tipc_own_addr_p),
+				 req_nlh->nlmsg_type, NLMSG_DATA(req_nlh),
+				 NLMSG_PAYLOAD(req_nlh, 0), hdr_space);
+		} else {
+			rep_buf = cfg_reply_error_string(TIPC_CFG_INVALID_VALUE);
+		}
+	} else {
 		rep_buf = cfg_do_cmd(tipc_own_addr, 
 				     req_nlh->nlmsg_type, 
 				     NLMSG_DATA(req_nlh), 
 				     NLMSG_PAYLOAD(req_nlh, 0), 
 				     hdr_space);
-
+	}
 	if (rep_buf) {
 		skb_push(rep_buf, hdr_space);
 		rep_nlh = (struct nlmsghdr *)rep_buf->data;
diff -Naur tipc-1.5.12_orig/net/tipc/socket.c tipc-1.5.12_gmt/net/tipc/socket.c
--- tipc-1.5.12_orig/net/tipc/socket.c	2006-06-12 20:05:28.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/socket.c	2007-12-19 01:50:51.000000000 +0530
@@ -181,13 +181,21 @@
 #include <asm/atomic.h>
 #include <linux/fcntl.h>
 #include <linux/version.h>
-
+#include <linux/module.h>
+#include <config.h>
+#include <vtipc.h>
 
 #define SS_LISTENING	-1	/* socket is listening */
 #define SS_READY	-2	/* socket is connectionless */
 
 #define OVERLOAD_LIMIT_BASE    5000
+int tipc_create(struct socket *sock, int protocol);
 
+struct net_vtipc_proto vtipc_ops = {
+       .owner          = THIS_MODULE,
+       .registration   = tipc_create,
+       .netlink_registration   = cfg_do_cmd
+};
 struct tipc_sock {
 	struct sock sk;
 	struct tipc_port *p;
@@ -300,10 +308,14 @@
 	struct tipc_port *port;
 	struct sock *sk;
         u32 ref;
-
-	if (unlikely(protocol != 0))
+        if ((protocol < 0) || (protocol >= MAX_TIPC_STACKS)) {
+		warn("Invalid protocol number : %d, permitted range 0 - %d.\n", protocol, MAX_TIPC_STACKS);
 		return -EPROTONOSUPPORT;
-
+        }
+	if (protocol > 0) {
+            	int vres = handle_protocol(sock, protocol);	
+	        return vres;
+	} 
 	ref = tipc_createport_raw(0, &dispatch, &wakeupdispatch, TIPC_LOW_IMPORTANCE);
 	if (unlikely(!ref))
 		return -ENOMEM;
@@ -1830,7 +1842,7 @@
 
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,12)
 static struct proto tipc_proto = {
-	.name		= "TIPC",
+	.name		= "TIPC_XX",
 	.owner		= THIS_MODULE,
 	.obj_size	= sizeof(struct tipc_sock)
 };
@@ -1841,18 +1853,28 @@
  * 
  * Returns 0 on success, errno otherwise
  */
-int socket_init(void)
+int socket_init(int role, int stack_id, struct net_vtipc_proto *vtipc_ops)
 {
+	#define tipc_sock_length 13 
 	int res;
+        static char tipc_sock_str[tipc_sock_length] = {0};
+
+	if (stack_id > MAX_TIPC_STACKS) {
+                err("Instance out of range.\n");
+                return -ENOMEM;
+        }
 
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,12)
+	snprintf(tipc_proto.name, sizeof(tipc_proto.name), "TIPC_%02d",
+		stack_id);
         res = proto_register(&tipc_proto, 1);
 	if (res) {
 		err("Unable to register TIPC protocol type\n");
 		goto out;
 	}
 #else
-	tipc_cache = kmem_cache_create("tipc_sock", sizeof(struct tipc_sock),
+        snprintf(tipc_sock_str, tipc_sock_length, "tipc_sock_%2d", stack_id);
+	tipc_cache = kmem_cache_create(tipc_sock_str, sizeof(struct tipc_sock),
 				       0, SLAB_HWCACHE_ALIGN, NULL, NULL);
 	if (!tipc_cache) {
 		err("Unable to create TIPC socket cache\n");
@@ -1861,6 +1883,11 @@
 	}
 #endif
 
+	if (role == TIPC_ROLE_STACK) {
+		res = register_with_tipc(role, stack_id, vtipc_ops);
+		return res;
+	}
+
 	res = sock_register(&tipc_family_ops);
 	if (res) {
 		err("Unable to register TIPC socket type\n");
@@ -1880,17 +1907,19 @@
 /**
  * sock_stop - stop TIPC socket interface
  */
-void socket_stop(void)
+void socket_stop(int role, int stack_id)
 {
-	if (!sockets_enabled)
-		return;
-
-	sockets_enabled = 0;
-	sock_unregister(tipc_family_ops.family);
 #if LINUX_VERSION_CODE >= KERNEL_VERSION(2,6,12)
 	proto_unregister(&tipc_proto);
 #else
 	kmem_cache_destroy(tipc_cache);
 #endif
+	deregister_with_tipc(role, stack_id);
+	if (!sockets_enabled)
+		return;
+
+	sockets_enabled = 0;
+	if (role != TIPC_ROLE_STACK)
+		sock_unregister(tipc_family_ops.family);
 }
 
diff -Naur tipc-1.5.12_orig/net/tipc/vtipc.c tipc-1.5.12_gmt/net/tipc/vtipc.c
--- tipc-1.5.12_orig/net/tipc/vtipc.c	1970-01-01 05:30:00.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/vtipc.c	2007-12-19 02:23:26.000000000 +0530
@@ -0,0 +1,154 @@
+/* --------------------------------------------------------------------------------
+ *
+ * vtipc.c
+ *
+ * Short description: TIPC virtualization routines.
+ *                    This files is only compiled when building tipc base.
+ *                    These routines allow a tipc stack to register with tipc base.
+ * --------------------------------------------------------------------------------
+ *
+ * Copyright (c) 2007, Nortel Canada
+ * All rights reserved.
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * Redistributions of source code must retain the above copyright notice, this
+ * list of conditions and the following disclaimer.
+ * Redistributions in binary form must reproduce the above copyright notice,
+ * this list of conditions and the following disclaimer in the documentation
+ * and/or other materials provided with the distribution.
+ * Neither the names of the copyright holders nor the names of its
+ * contributors may be used to endorse or promote products derived from this
+ * software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ *
+ * ------------------------------------------------------------------------
+ *
+ *  Created : 2007-12-14
+ *  Authors : Randy MacLeod
+ *            P Ravi Rao
+ *
+ * ------------------------------------------------------------------------
+ *
+ */
+
+#include "core.h"
+#include <tipc_port.h>
+#include <tipc_config.h>
+
+struct net_vtipc_proto *tipc_families[MAX_TIPC_STACKS] = {NULL};
+static spinlock_t tipc_family_lock = SPIN_LOCK_UNLOCKED;
+
+int handle_protocol(struct socket *sock, int protocol)
+{
+	if (!tipc_families[protocol]) {
+		return -1;
+	}
+        (*(tipc_families[protocol]->registration))(sock, 0);
+	return 0;
+}
+
+int register_with_tipc(int role, int stack_id, struct net_vtipc_proto *vtipc_ops)
+{
+	int res = -EEXIST;
+
+	spin_lock(&tipc_family_lock);
+	if (!tipc_families[stack_id]) {
+		tipc_families[stack_id] = vtipc_ops;
+		res = 0;
+	}
+	spin_unlock(&tipc_family_lock);
+
+	if (res == 0) {
+		info("TIPC: Registered stack %d.\n", stack_id);
+	} else {
+		info("TIPC: Registration of stack %d failed - already loaded.\n",
+		     stack_id);
+	}
+
+	return res;
+}
+
+void deregister_with_tipc(int role, int stack_id)
+{
+	if (role == TIPC_ROLE_STACK) {
+		info("TIPC: Deregistered stack %d.\n", stack_id);
+		spin_lock(&tipc_family_lock);
+		tipc_families[stack_id] = 0;
+		spin_unlock(&tipc_family_lock);
+	}
+}
+
+EXPORT_SYMBOL(register_with_tipc);
+EXPORT_SYMBOL(deregister_with_tipc);
+EXPORT_SYMBOL(handle_protocol);
+EXPORT_SYMBOL(tipc_families);
+
+
+/* Native TIPC API for kernel-space applications (see tipc.h) */
+
+EXPORT_SYMBOL(tipc_attach);
+EXPORT_SYMBOL(tipc_detach);
+EXPORT_SYMBOL(tipc_get_addr);
+EXPORT_SYMBOL(tipc_get_mode);
+EXPORT_SYMBOL(tipc_createport);
+EXPORT_SYMBOL(tipc_deleteport);
+EXPORT_SYMBOL(tipc_ownidentity);
+EXPORT_SYMBOL(tipc_portimportance);
+EXPORT_SYMBOL(tipc_set_portimportance);
+EXPORT_SYMBOL(tipc_portunreliable);
+EXPORT_SYMBOL(tipc_set_portunreliable);
+EXPORT_SYMBOL(tipc_portunreturnable);
+EXPORT_SYMBOL(tipc_set_portunreturnable);
+EXPORT_SYMBOL(tipc_publish);
+EXPORT_SYMBOL(tipc_withdraw);
+EXPORT_SYMBOL(tipc_connect2port);
+EXPORT_SYMBOL(tipc_disconnect);
+EXPORT_SYMBOL(tipc_shutdown);
+EXPORT_SYMBOL(tipc_isconnected);
+EXPORT_SYMBOL(tipc_peer);
+EXPORT_SYMBOL(tipc_ref_valid);
+EXPORT_SYMBOL(tipc_send);
+EXPORT_SYMBOL(tipc_send_buf);
+EXPORT_SYMBOL(tipc_send2name);
+EXPORT_SYMBOL(tipc_forward2name);
+EXPORT_SYMBOL(tipc_send_buf2name);
+EXPORT_SYMBOL(tipc_forward_buf2name);
+EXPORT_SYMBOL(tipc_send2port);
+EXPORT_SYMBOL(tipc_forward2port);
+EXPORT_SYMBOL(tipc_send_buf2port);
+EXPORT_SYMBOL(tipc_forward_buf2port);
+EXPORT_SYMBOL(tipc_multicast);
+/* EXPORT_SYMBOL(tipc_multicast_buf); not available yet */
+EXPORT_SYMBOL(tipc_ispublished);
+EXPORT_SYMBOL(tipc_available_nodes);
+
+/* TIPC API for external bearers (see tipc_bearer.h) */
+
+EXPORT_SYMBOL(tipc_block_bearer);
+EXPORT_SYMBOL(tipc_continue); 
+EXPORT_SYMBOL(tipc_disable_bearer);
+EXPORT_SYMBOL(tipc_enable_bearer);
+EXPORT_SYMBOL(tipc_recv_msg);
+EXPORT_SYMBOL(tipc_register_media); 
+
+/* TIPC API for external APIs (see tipc_port.h) */
+
+EXPORT_SYMBOL(tipc_createport_raw);
+EXPORT_SYMBOL(tipc_set_msg_option);
+EXPORT_SYMBOL(tipc_reject_msg);
+EXPORT_SYMBOL(tipc_send_buf_fast);
+EXPORT_SYMBOL(tipc_acknowledge);
+EXPORT_SYMBOL(tipc_get_port);
+EXPORT_SYMBOL(tipc_get_handle);
diff -Naur tipc-1.5.12_orig/net/tipc/vtipc.h tipc-1.5.12_gmt/net/tipc/vtipc.h
--- tipc-1.5.12_orig/net/tipc/vtipc.h	1970-01-01 05:30:00.000000000 +0530
+++ tipc-1.5.12_gmt/net/tipc/vtipc.h	2007-12-19 02:08:57.000000000 +0530
@@ -0,0 +1,48 @@
+/* --------------------------------------------------------------------
+ *
+ * vtipc.h
+ *
+ * Short description: TIPC virtualization routines.
+ * ------------------------------------------------------------------------
+ *
+ * Copyright (c) 2007, Nortel Canada
+ * All rights reserved.
+ * Redistribution and use in source and binary forms, with or without
+ * modification, are permitted provided that the following conditions are met:
+ *
+ * Redistributions of source code must retain the above copyright notice, this
+ * list of conditions and the following disclaimer.
+ * Redistributions in binary form must reproduce the above copyright notice,
+ * this list of conditions and the following disclaimer in the documentation
+ * and/or other materials provided with the distribution.
+ * Neither the names of the copyright holders nor the names of its
+ * contributors may be used to endorse or promote products derived from this
+ * software without specific prior written permission.
+ *
+ * THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
+ * AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
+ * IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE
+ * ARE DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT OWNER OR CONTRIBUTORS BE
+ * LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR
+ * CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF
+ * SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS
+ * INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN
+ * CONTRACT, STRICT LIABILITY, OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE)
+ * ARISING IN ANY WAY OUT OF THE USE OF THIS SOFTWARE, EVEN IF ADVISED OF THE
+ * POSSIBILITY OF SUCH DAMAGE.
+ *
+ * ------------------------------------------------------------------------
+ *
+ *  Created : 2007-12-14
+ *  Authors : Randy MacLeod
+ *            P Ravi Rao
+ *
+ * ------------------------------------------------------------------------
+ *
+ */
+#ifndef _LINUX_VTIPC_H
+#define _LINUX_VTIPC_H
+void deregister_with_tipc(int role, int stack_id);
+int handle_protocol(struct socket *sock, int protocol);
+int register_with_tipc(int role, int stack_id, struct net_vtipc_proto *vtipc_ops);
+#endif/* _LINUX_VTIPC_H */
diff -Naur tipc-1.5.12_orig/tools/tipc-config.c tipc-1.5.12_gmt/tools/tipc-config.c
--- tipc-1.5.12_orig/tools/tipc-config.c	2006-06-12 20:37:06.000000000 +0530
+++ tipc-1.5.12_gmt/tools/tipc-config.c	2007-12-18 20:06:09.000000000 +0530
@@ -84,6 +84,7 @@
 /* local variables */
 
 static int verbose = 0;
+static int stack_id = 0;
 static int interactive = 0;
 static __u32 dest = 0;
 static __u32 tlv_area[MAX_TLVS_SPACE / sizeof(__u32)];
@@ -134,13 +135,13 @@
 	return val;
 }
 
-static __u32 own_node(void)
+static __u32 own_node(int stack_id)
 {
 	struct sockaddr_tipc addr;
 	socklen_t sz = sizeof(addr);
 	int sd;
 
-	sd = socket(AF_TIPC, SOCK_RDM, 0);
+	sd = socket(AF_TIPC, SOCK_RDM, stack_id);
 	if (sd < 0)
 		err(1, "TIPC module not installed\n");
 	if (getsockname(sd, (struct sockaddr *)&addr, &sz) < 0)
@@ -164,7 +165,7 @@
 {
 	static char addr_area[30];
 
-	if (dest == own_node())
+	if (dest == own_node(stack_id))
 		return "";
 	sprintf(addr_area, " for node %s", addr2str(dest));
 	return addr_area;
@@ -367,7 +368,7 @@
 
 	req.n.nlmsg_len = NLMSG_LENGTH(req_tlv_space);
 	req.n.nlmsg_type = cmd;
-	req.n.nlmsg_flags = 0;
+	req.n.nlmsg_flags = stack_id;
 	req.n.nlmsg_seq = 0;
 	req.n.nlmsg_pid = getpid();
 	if (req_tlv_space)
@@ -486,7 +487,7 @@
 {
 	int rep_len;
 
-	if (dest == own_node())
+	if (dest == own_node(stack_id))
 		rep_len = do_command_netlink(cmd, req_tlv, req_tlv_space, 
 					     rep_tlv, rep_tlv_space);
 	else
@@ -791,6 +792,17 @@
 	cprintf("Link %s statistics reset\n", link_name);
 }
 
+static void set_stack_id(char *args)
+{
+	if (!*args) {
+		stack_id = 0;	
+		printf("No stack id is provided so resetting to default value of 0");
+	} else {
+		stack_id = atoi(args);	
+		dest = own_node(stack_id);
+		printf("The stack id is %d\n", stack_id);
+	}
+}
 static void show_name_table(char *args)
 {
 	int tlv_space;
@@ -1436,6 +1448,7 @@
 "        where <depth> = types|names|ports|all\n"
 #if 1
 "  -p                                         Get port info\n"
+"  -s     =<stack_id>                  	      Configure a virtulal tipc stack based on stack number\n"
 #else
 "  -p    [=all|bound|connected|<port>]        Get port info\n"
 "  -ps    =<port>                             Get port statistics\n"
@@ -1518,6 +1531,7 @@
 	{"max_nodes",    2, 0, OPT_BASE + 30},
 	{"max_slaves",   2, 0, OPT_BASE + 31},
 	{"log",          2, 0, OPT_BASE + 32},
+	{"s",            1, 0, OPT_BASE + 33},
 	{0, 0, 0, 0}
 };
 
@@ -1555,6 +1569,7 @@
 	set_max_nodes,
 	set_max_slaves,
 	set_log_size,
+	set_stack_id,
 	NULL
 };
 
@@ -1572,8 +1587,8 @@
 
 	if (argc == 1)
 		err(1, usage);
-
-	dest = own_node();
+	stack_id = 0;
+	dest = own_node(stack_id);
 
 	cno = 0;
 	while ((c = getopt_long_only(argc, argv, "", options, NULL)) != EOF) {



--------------010907070504030207040400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

-------------------------------------------------------------------------
Check out the new SourceForge.net Marketplace.
It's the best place to buy or sell services for
just about anything Open Source.
http://ad.doubleclick.net/clk;164216239;13503038;w?http://sf.net/marketplace
--------------010907070504030207040400
Content-Type: text/plain; charset="us-ascii"
MIME-Version: 1.0
Content-Transfer-Encoding: 7bit
Content-Disposition: inline

_______________________________________________
tipc-discussion mailing list
tipc-discussion@lists.sourceforge.net
https://lists.sourceforge.net/lists/listinfo/tipc-discussion

--------------010907070504030207040400--
