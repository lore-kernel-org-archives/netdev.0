From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Tue, 15 Feb 2005 23:19:41 +0100
Message-ID: <4212757D.5070401@eurodev.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net> <420E77FA.6080007@eurodev.net> <20050215001334.GB27645@shell0.pdx.osdl.net> <42115E7E.6050909@eurodev.net> <20050215034708.GG27645@shell0.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------080905080305000803030409"
Cc: netdev@oss.sgi.com, davem@davemloft.net, jmorris@redhat.com,
        sds@epoch.ncsc.mil, serue@us.ibm.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <20050215034708.GG27645@shell0.pdx.osdl.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------080905080305000803030409
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Chris Wright wrote:

>Great, thanks.  This is technically racy.  It's possible (albeit small
>window) that something could be delivered before this is set.
>

Yes, hard trigger but that can happen and doesn't tell too much in 
favour of me.

>Using a callback struct during registration would fix this.
>  
>

I agree, maybe something like the example patch attached. Hope that helps.

--
Pablo

--------------080905080305000803030409
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 21:25:32 +01:00
+++ edited/net/netlink/af_netlink.c	2005-02-15 23:10:47 +01:00
@@ -71,6 +71,7 @@
 	struct netlink_callback	*cb;
 	spinlock_t		cb_lock;
 	void			(*data_ready)(struct sock *sk, int bytes);
+	int			(*check_sender)(struct sk_buff *skb);
 };
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
@@ -636,9 +637,16 @@
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
 {
 	struct netlink_opt *nlk;
-	int len = skb->len;
+	int err, len = skb->len;
+	
+ 	nlk = nlk_sk(sk);
+
+	if (nlk->check_sender)
+		if ((err = nlk->check_sender(skb))) {
+			netlink_detachskb(sk, skb);
+			return err;
+		}
 
-	nlk = nlk_sk(sk);
 #ifdef NL_EMULATE_DEV
 	if (nlk->handler) {
 		skb_orphan(skb);
@@ -1033,7 +1041,7 @@
  */
 
 struct sock *
-netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len))
+netlink_kernel_create(int unit, struct netlink_ops *nlops)
 {
 	struct socket *sock;
 	struct sock *sk;
@@ -1053,8 +1061,12 @@
 	}
 	sk = sock->sk;
 	sk->sk_data_ready = netlink_data_ready;
-	if (input)
-		nlk_sk(sk)->data_ready = input;
+	if (nlops != NULL) {
+		if (nlops->input)
+			nlk_sk(sk)->data_ready = nlops->input;
+		if (nlops->check_sender)
+			nlk_sk(sk)->check_sender = nlops->check_sender;
+	}
 
 	if (netlink_insert(sk, 0)) {
 		sock_release(sock);
===== include/linux/netlink.h 1.23 vs edited =====
--- 1.23/include/linux/netlink.h	2005-02-07 06:59:39 +01:00
+++ edited/include/linux/netlink.h	2005-02-15 22:53:01 +01:00
@@ -115,8 +115,13 @@
 #define NETLINK_CB(skb)		(*(struct netlink_skb_parms*)&((skb)->cb))
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
+struct netlink_ops
+{
+	void    (*input)(struct sock *sk, int len);
+	int     (*check_sender)(struct sk_buff *skb);
+};
 
-extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
+extern struct sock *netlink_kernel_create(int unit, struct netlink_ops *nlops);
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
===== net/core/rtnetlink.c 1.33 vs edited =====
--- 1.33/net/core/rtnetlink.c	2005-01-10 22:42:22 +01:00
+++ edited/net/core/rtnetlink.c	2005-02-15 23:08:05 +01:00
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
 
@@ -681,6 +696,10 @@
 void __init rtnetlink_init(void)
 {
 	int i;
+	struct netlink_ops rtnl_ops = {
+		.input 		= rtnetlink_rcv,
+		.check_sender	= rtnetlink_check_sender
+	};
 
 	rtattr_max = 0;
 	for (i = 0; i < ARRAY_SIZE(rta_max); i++)
@@ -690,7 +709,7 @@
 	if (!rta_buf)
 		panic("rtnetlink_init: cannot allocate rta_buf\n");
 
-	rtnl = netlink_kernel_create(NETLINK_ROUTE, rtnetlink_rcv);
+	rtnl = netlink_kernel_create(NETLINK_ROUTE, &rtnl_ops);
 	if (rtnl == NULL)
 		panic("rtnetlink_init: cannot initialize rtnetlink\n");
 	netlink_set_nonroot(NETLINK_ROUTE, NL_NONROOT_RECV);

--------------080905080305000803030409--
