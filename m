From: Chris Wright <chrisw@osdl.org>
Subject: [RFC][PATCH 1/3] netlink check sender
Date: Sat, 12 Feb 2005 01:02:43 -0800
Message-ID: <20050212010243.W24171@build.pdx.osdl.net>
References: <20050212010109.V24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, jmorris@redhat.com, sds@epoch.ncsc.mil,
        serue@us.ibm.com
To: netdev@oss.sgi.com
Content-Disposition: inline
In-Reply-To: <20050212010109.V24171@build.pdx.osdl.net>; from chrisw@osdl.org on Sat, Feb 12, 2005 at 01:01:09AM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Add check_sender callback to struct netlink_opt.
* Add netlink_kernel_create_check() to register that callback, and turn
  netlink_kernel_create() into a simple wrapper around that.
* Invoke callback when set to verify sender in sender's context.

===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 12:25:32 -08:00
+++ edited/net/netlink/af_netlink.c	2005-02-11 18:05:59 -08:00
@@ -71,6 +71,7 @@ struct netlink_opt
 	struct netlink_callback	*cb;
 	spinlock_t		cb_lock;
 	void			(*data_ready)(struct sock *sk, int bytes);
+	int			(*check_sender)(struct sk_buff *skb);
 };
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
@@ -636,9 +637,17 @@ int netlink_attachskb(struct sock *sk, s
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
 {
 	struct netlink_opt *nlk;
-	int len = skb->len;
-
+	int err, len = skb->len;
+	
 	nlk = nlk_sk(sk);
+
+	printk("%s: %s(%d) send_check %p\n", __FUNCTION__, current->comm, current->pid, nlk->check_sender);
+	if (nlk->check_sender)
+		if ((err = nlk->check_sender(skb))) {
+			netlink_detachskb(sk, skb);
+			return err;
+		}
+
 #ifdef NL_EMULATE_DEV
 	if (nlk->handler) {
 		skb_orphan(skb);
@@ -1033,7 +1042,8 @@ static void netlink_data_ready(struct so
  */
 
 struct sock *
-netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len))
+netlink_kernel_create_check(int unit, void (*input)(struct sock *sk, int len),
+			    int (*check)(struct sk_buff *skb))
 {
 	struct socket *sock;
 	struct sock *sk;
@@ -1053,8 +1063,10 @@ netlink_kernel_create(int unit, void (*i
 	}
 	sk = sock->sk;
 	sk->sk_data_ready = netlink_data_ready;
-	if (input)
+	if (input) {
 		nlk_sk(sk)->data_ready = input;
+		nlk_sk(sk)->check_sender = check;
+	}
 
 	if (netlink_insert(sk, 0)) {
 		sock_release(sock);
@@ -1459,7 +1471,7 @@ MODULE_ALIAS_NETPROTO(PF_NETLINK);
 EXPORT_SYMBOL(netlink_ack);
 EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);
-EXPORT_SYMBOL(netlink_kernel_create);
+EXPORT_SYMBOL(netlink_kernel_create_check);
 EXPORT_SYMBOL(netlink_register_notifier);
 EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_set_nonroot);
===== include/linux/netlink.h 1.23 vs edited =====
--- 1.23/include/linux/netlink.h	2005-02-06 21:59:39 -08:00
+++ edited/include/linux/netlink.h	2005-02-11 14:56:23 -08:00
@@ -116,7 +116,11 @@ struct netlink_skb_parms
 #define NETLINK_CREDS(skb)	(&NETLINK_CB((skb)).creds)
 
 
-extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
+extern struct sock *netlink_kernel_create_check(int unit, void (*input)(struct sock *sk, int len), int (*check)(struct sk_buff *skb));
+static inline struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len)) 
+{
+	return netlink_kernel_create_check(unit, input, NULL);
+}
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,
