From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [RFC][PATCH 2/3] netlink check sender, audit
Date: Tue, 15 Feb 2005 03:36:50 +0100
Message-ID: <42116042.6030205@eurodev.net>
References: <20050212010109.V24171@build.pdx.osdl.net> <20050212010243.W24171@build.pdx.osdl.net> <20050212010504.X24171@build.pdx.osdl.net> <420E334B.8060805@eurodev.net> <420E77FA.6080007@eurodev.net> <20050215001334.GB27645@shell0.pdx.osdl.net> <42115E7E.6050909@eurodev.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------070102060609050907020807"
Cc: netdev@oss.sgi.com, davem@davemloft.net, jmorris@redhat.com,
        sds@epoch.ncsc.mil, serue@us.ibm.com
To: Chris Wright <chrisw@osdl.org>
In-Reply-To: <42115E7E.6050909@eurodev.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------070102060609050907020807
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit

Pablo Neira wrote:

> Chris Wright wrote:
>
>>> With your patch, a message from user space process that doesn't have 
>>> the capabilites follows this path:
>>>
>>> sys_sendmsg() -> netlink_sendmsg() -> netlink_unicast() -> 
>>> netlink_sendskb() = discarded here.
>>>
>>> Currently, it continues, for example in case of rtnetlink:
>>>
>>> ... -> netlink_sendskb() -> sk_data_ready(sk, len) -> 
>>> rtnetlink_rcv() -> rtnetlink_rcv_skb() -> rtnetlink_rcv_msg() = 
>>> discarded here.
>>>
>>> Nowadays the message is enqueued but it's discarded later. So if I'm 
>>> not missing anything, I don't see the point of adding a new function 
>>> to check for capabilities/audit stuff just a bit before.
>>>   
>>
>>
>> The purpose is to guarantee that the checks are done in the sender's
>> context to avoid having to cache values such as capabilities, SELinux
>> SID, audit loginuid.
>>  
>>
>
> Thanks for the explanation. I don't still like so much the new 
> netlink_kernel_create_check function. I think that we could get more 
> variations of netlink_kernel_create in future just to add another 
> feature/checking. So I prefer new function (netlink_kernel_set_check) 
> that set check_sender if it's needed once the netlink socket is 
> created. I've modified your patches to use this function.


Sorry, I'm stupid. Wrong patch.

--
Pablo

--------------070102060609050907020807
Content-Type: text/x-patch;
 name="netlink.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink.patch"

===== net/netlink/af_netlink.c 1.69 vs edited =====
--- 1.69/net/netlink/af_netlink.c	2005-01-21 21:25:32 +01:00
+++ edited/net/netlink/af_netlink.c	2005-02-15 03:34:53 +01:00
@@ -71,6 +71,7 @@
 	struct netlink_callback	*cb;
 	spinlock_t		cb_lock;
 	void			(*data_ready)(struct sock *sk, int bytes);
+	int			(*check_sender)(struct sk_buff *skb);
 };
 
 #define nlk_sk(__sk) ((struct netlink_opt *)(__sk)->sk_protinfo)
@@ -636,9 +637,15 @@
 int netlink_sendskb(struct sock *sk, struct sk_buff *skb, int protocol)
 {
 	struct netlink_opt *nlk;
-	int len = skb->len;
+	int err, len = skb->len;
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
@@ -1063,6 +1070,12 @@
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
@@ -1460,6 +1473,7 @@
 EXPORT_SYMBOL(netlink_broadcast);
 EXPORT_SYMBOL(netlink_dump_start);
 EXPORT_SYMBOL(netlink_kernel_create);
+EXPORT_SYMBOL(netlink_kernel_set_check);
 EXPORT_SYMBOL(netlink_register_notifier);
 EXPORT_SYMBOL(netlink_set_err);
 EXPORT_SYMBOL(netlink_set_nonroot);
===== include/linux/netlink.h 1.23 vs edited =====
--- 1.23/include/linux/netlink.h	2005-02-07 06:59:39 +01:00
+++ edited/include/linux/netlink.h	2005-02-15 02:53:35 +01:00
@@ -117,6 +117,7 @@
 
 
 extern struct sock *netlink_kernel_create(int unit, void (*input)(struct sock *sk, int len));
+extern inline void netlink_kernel_set_check(struct sock *sk, int (*check)(struct sk_buff *skb));
 extern void netlink_ack(struct sk_buff *in_skb, struct nlmsghdr *nlh, int err);
 extern int netlink_unicast(struct sock *ssk, struct sk_buff *skb, __u32 pid, int nonblock);
 extern int netlink_broadcast(struct sock *ssk, struct sk_buff *skb, __u32 pid,

--------------070102060609050907020807--
