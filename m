From: Chris Wright <chrisw@osdl.org>
Subject: Re: [PATCH] Add audit uid to netlink credentials
Date: Wed, 9 Feb 2005 17:11:15 -0800
Message-ID: <20050209171115.G24171@build.pdx.osdl.net>
References: <20050204165840.GA2320@IBM-BWN8ZTBWA01.austin.ibm.com> <1107958621.19262.524.camel@hades.cambridge.redhat.com> <1107960659.4837.9.camel@serge> <1107973381.17568.97.camel@moss-spartans.epoch.ncsc.mil> <20050209103747.Y24171@build.pdx.osdl.net> <1107974448.17568.108.camel@moss-spartans.epoch.ncsc.mil> <20050209153816.B24171@build.pdx.osdl.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Smalley <sds@epoch.ncsc.mil>, netdev@oss.sgi.com,
        Linux Audit Discussion <linux-audit@redhat.com>, davem@davemloft.net,
        kuznet@ms2.inr.ac.ru
To: Chris Wright <chrisw@osdl.org>
Content-Disposition: inline
In-Reply-To: <20050209153816.B24171@build.pdx.osdl.net>; from chrisw@osdl.org on Wed, Feb 09, 2005 at 03:38:16PM -0800
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

* Chris Wright (chrisw@osdl.org) wrote:
> Hmm, perhaps we could eliminate the whole asynchronous issue by allowing
> registration of a netlink link specific security handler.  Something like:
> 
> netlink_kernel_create_sec(unit, rx, sec_handler)
> 
> Then the check would be done before the packet was ever queued.  This
> would eliminate the if (NETLINK_CREDS(skb)->$cred == bad) on receipt
> side, and push it to sender side.  It would also be link specific so
> audit could do it's audit payload loginuid check here.  I think it would
> also eliminate SELinux's need to tag the packet for later checking on
> receipt.  Thoughts?

Here's an example of what I mean.  It's quite rough, doesn't yet eliminate
any of the code that it eventually could, and doesn't deal with broadcast.
I gave it a quick test with audit netlink, and it does what I expect.

thanks,
-chris
-- 
Linux Security Modules     http://lsm.immunix.org     http://lsm.bkbits.net

===== kernel/audit.c 1.9 vs edited =====
--- 1.9/kernel/audit.c	2005-01-30 22:33:47 -08:00
+++ edited/kernel/audit.c	2005-02-09 17:07:22 -08:00
@@ -333,6 +333,15 @@ static int audit_netlink_ok(kernel_cap_t
 	return err;
 }
 
+static int audit_check_sender(struct sk_buff *skb)
+{
+	struct nlmsghdr *nlh = (struct nlmsghdr *)skb->data;
+	u16		msg_type = nlh->nlmsg_type;
+
+	return audit_netlink_ok(NETLINK_CB(skb).eff_cap, msg_type);
+
+}
+
 static int audit_receive_msg(struct sk_buff *skb, struct nlmsghdr *nlh)
 {
 	u32			uid, pid, seq;
@@ -551,7 +560,7 @@ int __init audit_init(void)
 {
 	printk(KERN_INFO "audit: initializing netlink socket (%s)\n",
 	       audit_default ? "enabled" : "disabled");
-	audit_sock = netlink_kernel_create(NETLINK_AUDIT, audit_receive);
+	audit_sock = netlink_kernel_create_check(NETLINK_AUDIT, audit_receive, audit_check_sender);
 	if (!audit_sock)
 		audit_panic("cannot initialize netlink socket");
 
===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 12:25:32 -08:00
+++ edited/net/netlink/af_netlink.c	2005-02-09 16:39:15 -08:00
@@ -71,6 +71,7 @@ struct netlink_opt
 	struct netlink_callback	*cb;
 	spinlock_t		cb_lock;
 	void			(*data_ready)(struct sock *sk, int bytes);
+	int			(*send_check)(struct sk_buff *skb);
 };
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
@@ -639,6 +640,14 @@ int netlink_sendskb(struct sock *sk, str
 	int len = skb->len;
 
 	nlk = nlk_sk(sk);
+
+	if (nlk->send_check)
+		if (nlk->send_check(skb)) {
+			kfree_skb(skb);
+			sock_put(sk);
+			return -EPERM;
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
+		nlk_sk(sk)->send_check = check;
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
+++ edited/include/linux/netlink.h	2005-02-09 16:36:45 -08:00
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
