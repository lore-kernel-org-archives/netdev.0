From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Tue, 15 Feb 2005 03:29:18 +0100
Message-ID: <42115E7E.6050909@eurodev.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net> <420E77FA.6080007@eurodev.net> <20050215001334.GB27645@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------040206070606070909000306"
Cc: netdev@oss.sgi.com, davem@davemloft.net, jmorris@redhat.com,
        sds@epoch.ncsc.mil, serue@us.ibm.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050215001334.GB27645@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------040206070606070909000306
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Chris Wright wrote:

>>With your patch, a message from user space process that doesn't have the 
>>capabilites follows this path:
>>
>>sys_sendmsg() -> netlink_sendmsg() -> netlink_unicast() -> 
>>netlink_sendskb() = discarded here.
>>
>>Currently, it continues, for example in case of rtnetlink:
>>
>>... -> netlink_sendskb() -> sk_data_ready(sk, len) -> rtnetlink_rcv() -> 
>>rtnetlink_rcv_skb() -> rtnetlink_rcv_msg() = discarded here.
>>
>>Nowadays the message is enqueued but it's discarded later. So if I'm not 
>>missing anything, I don't see the point of adding a new function to 
>>check for capabilities/audit stuff just a bit before.
>>    
>>
>
>The purpose is to guarantee that the checks are done in the sender's
>context to avoid having to cache values such as capabilities, SELinux
>SID, audit loginuid.
>  
>

Thanks for the explanation. I don't still like so much the new 
netlink_kernel_create_check function. I think that we could get more 
variations of netlink_kernel_create in future just to add another 
feature/checking. So I prefer new function (netlink_kernel_set_check) 
that set check_sender if it's needed once the netlink socket is created. 
I've modified your patches to use this function.

Comments welcome.

--
Pablo

--------------040206070606070909000306
Content-Type: text/plain;
 name="01"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01"

===== include/linux/netlink.h 1.23 vs edited =====
--- 1.23/include/linux/netlink.h	2005-02-07 06:59:39 +01:00
+++ edited/include/linux/netlink.h	2005-02-15 02:35:36 +01:00
@@ -117,6 +117,7 @@
 
 
 extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
+extern inline void netlink_kernel_set_check(struct sock *sk, int (*check)(struct sk_buff *skb));
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 21:25:32 +01:00
+++ edited/net/netlink/af_netlink.c	2005-02-15 02:35:49 +01:00
@@ -71,6 +71,7 @@
 	struct netlink_callback	*cb;
 	spinlock_t		cb_lock;
 	void			(*data_ready)(struct sock *sk, int bytes);
+	int			(*check_sender)(struct sk_buff *skb);
 };
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
@@ -1063,6 +1064,12 @@
 	return sk;
 }
 
+inline void netlink_kernel_set_check(struct sock *sk, 
+				     int (*check)(struct sk_buff *skb))
+{
+	nlk_sk(sk)->check_sender = check;
+}
+
 void netlink_set_nonroot(int protocol, unsigned int flags)
 { 
 	if ((unsigned int)protocol < MAX_LINKS) 
@@ -1460,6 +1467,7 @@
 EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
+EXPORT_SYMBOL(netlink_kernel_set_check);
 EXPORT_SYMBOL(netlink_register_notifier);
 EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_set_nonroot);

--------------040206070606070909000306
Content-Type: text/plain;
 name="02"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="02"

===== kernel/audit.c 1.9 vs edited =====
--- 1.9/kernel/audit.c	2005-01-31 07:33:47 +01:00
+++ edited/kernel/audit.c	2005-02-15 02:17:22 +01:00
@@ -309,27 +309,36 @@
  * Check for appropriate CAP_AUDIT_ capabilities on incoming audit
  * control messages.
  */
-static int audit_netlink_ok(kernel_cap_t eff_cap, u16 msg_type)
+static int audit_check_sender(struct sk_buff *skb)
 {
-	int err = 0;
+	struct nlmsghdr *nlh;
+	u16 msg_type;
+	int err = -EINVAL;
 
+	if (skb->len < NLMSG_LENGTH(0))
+		goto out;
+
+	nlh = (struct nlmsghdr *)skb->data;
+	msg_type = nlh->nlmsg_type;
+
+	err = 0;
 	switch (msg_type) {
 	case AUDIT_GET:
 	case AUDIT_LIST:
 	case AUDIT_SET:
 	case AUDIT_ADD:
 	case AUDIT_DEL:
-		if (!cap_raised(eff_cap, CAP_AUDIT_CONTROL))
+		if (!capable(CAP_AUDIT_CONTROL))
 			err = -EPERM;
 		break;
 	case AUDIT_USER:
-		if (!cap_raised(eff_cap, CAP_AUDIT_WRITE))
+		if (!capable(CAP_AUDIT_WRITE))
 			err = -EPERM;
 		break;
 	default:  /* bad msg */
 		err = -EINVAL;
 	}
-
+out:
 	return err;
 }
 
@@ -338,14 +347,10 @@
 	u32			uid, pid, seq;
 	void			*data;
 	struct audit_status	*status_get, status_set;
-	int			err;
+	int			err = 0;
 	struct audit_buffer	*ab;
 	u16			msg_type = nlh->nlmsg_type;
 
-	err = audit_netlink_ok(NETLINK_CB(skb).eff_cap, msg_type);
-	if (err)
-		return err;
-
 	pid  = NETLINK_CREDS(skb)->pid;
 	uid  = NETLINK_CREDS(skb)->uid;
 	seq  = nlh->nlmsg_seq;
@@ -554,6 +559,8 @@
 	audit_sock = netlink_kernel_create(NETLINK_AUDIT, audit_receive);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
+	
+	netlink_kernel_set_check(audit_sock, audit_check_sender);
 
 	audit_initialized = 1;
 	audit_enabled = audit_default;

--------------040206070606070909000306
Content-Type: text/plain;
 name="03"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="03"

===== net/core/rtnetlink.c 1.33 vs edited =====
--- 1.33/net/core/rtnetlink.c	2005-01-10 22:42:22 +01:00
+++ edited/net/core/rtnetlink.c	2005-02-15 02:28:37 +01:00
@@ -462,8 +462,32 @@
 static struct rtattr **rta_buf;
 static int rtattr_max;
 
-/* Process one rtnetlink message. */
+static int rtnetlink_check_sender(struct sk_buff *skb)
+{
+	struct nlmsghdr *nlh;
+	int kind;
+	int type;
+
+	if (skb->len < NLMSG_LENGTH(0))
+		return -EINVAL;
+
+	nlh = (struct nlmsghdr *)skb->data;
+	type = nlh->nlmsg_type;
+
+	/* Unknown message: reply with EINVAL */
+	if (type > RTM_MAX)
+		return -EINVAL;
+
+	type -= RTM_BASE;
+	kind = type&3;
 
+	if (kind != 2 && !capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	return 0;
+}
+
+/* Process one rtnetlink message. */
 static __inline__ int
 rtnetlink_rcv_msg(struct sk_buff *skb, struct nlmsghdr *nlh, int *errp)
 {
@@ -485,10 +509,6 @@
 	if (type < RTM_BASE)
 		return 0;
 
-	/* Unknown message: reply with EINVAL */
-	if (type > RTM_MAX)
-		goto err_inval;
-
 	type -= RTM_BASE;
 
 	/* All the messages must have at least 1 byte length */
@@ -509,11 +529,6 @@
 	sz_idx = type>>2;
 	kind = type&3;
 
-	if (kind != 2 && security_netlink_recv(skb)) {
-		*errp = -EPERM;
-		return -1;
-	}
-
 	if (kind == 2 && nlh->nlmsg_flags&NLM_F_DUMP) {
 		u32 rlen;
 
@@ -693,6 +708,7 @@
 	rtnl = netlink_kernel_create(NETLINK_ROUTE, rtnetlink_rcv);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
+	netlink_kernel_set_check(rtnl, rtnetlink_check_sender);
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);
 	register_netdevice_notifier(&rtnetlink_dev_notifier);
 	rtnetlink_links[PF_UNSPEC] = link_rtnetlink_table;

--------------040206070606070909000306--
