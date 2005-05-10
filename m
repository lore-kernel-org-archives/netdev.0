From: Ken-ichirou MATSUZAWA <chamas@h4.dion.ne.jp>
Subject: assertion (!atomic_read(&sk->sk_rmem_alloc)) failed at
 net/netlink/af_netlink.c (122)
Date: Tue, 10 May 2005 21:43:32 +0900 (JST)
Message-ID: <20050510.214332.-1300551106.chamas@h4.dion.ne.jp>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
 boundary="--Next_Part(Tue_May_10_21_43_32_2005_990)--"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

----Next_Part(Tue_May_10_21_43_32_2005_990)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit

 Hello.

Everytime on shutting down, the subject message is logged.  
It seems that the reason is do_one_broadcast may preempt
netlink_recvmsg. Added patch to 2.6.12-rc4 seems resolving this
problem.

But I'm not a kernel hacker. I don't understand design, detail and
the intenstion of struct netlink_broadcast_data, so that I hope
someone to do more tidy work. In addition, please check 2.4 kernel
and pfkey_broadcast_one too.

Thanks.


----Next_Part(Tue_May_10_21_43_32_2005_990)--
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Content-Disposition: inline; filename="af_netlink.diff"

--- net/netlink/af_netlink.c.orig	2005-05-10 21:03:11.000000000 +0900
+++ net/netlink/af_netlink.c	2005-05-10 21:10:39.000000000 +0900
@@ -721,7 +721,7 @@
 	int congested;
 	int delivered;
 	int allocation;
-	struct sk_buff *skb, *skb2;
+	struct sk_buff *skb;
 };
 
 static inline int do_one_broadcast(struct sock *sk,
@@ -729,6 +729,7 @@
 {
 	struct netlink_sock *nlk = nlk_sk(sk);
 	int val;
+	struct sk_buff *skb;
 
 	if (p->exclude_sk == sk)
 		goto out;
@@ -741,25 +742,21 @@
 		goto out;
 	}
 
-	sock_hold(sk);
-	if (p->skb2 == NULL) {
-		if (atomic_read(&p->skb->users) != 1) {
-			p->skb2 = skb_clone(p->skb, p->allocation);
-		} else {
-			p->skb2 = p->skb;
-			atomic_inc(&p->skb->users);
-		}
-	}
-	if (p->skb2 == NULL) {
+	skb = skb_clone(p->skb, p->allocation);
+	if (skb == NULL) {
 		netlink_overrun(sk);
 		/* Clone failed. Notify ALL listeners. */
 		p->failure = 1;
-	} else if ((val = netlink_broadcast_deliver(sk, p->skb2)) < 0) {
+		goto out;
+	}
+
+	sock_hold(sk);
+	if ((val = netlink_broadcast_deliver(sk, skb)) < 0) {
 		netlink_overrun(sk);
+		kfree_skb(skb);
 	} else {
 		p->congested |= val;
 		p->delivered = 1;
-		p->skb2 = NULL;
 	}
 	sock_put(sk);
 
@@ -784,7 +781,6 @@
 	info.delivered = 0;
 	info.allocation = allocation;
 	info.skb = skb;
-	info.skb2 = NULL;
 
 	/* While we sleep in clone, do not allow to change socket list */
 
@@ -795,8 +791,6 @@
 
 	netlink_unlock_table();
 
-	if (info.skb2)
-		kfree_skb(info.skb2);
 	kfree_skb(skb);
 
 	if (info.delivered) {

----Next_Part(Tue_May_10_21_43_32_2005_990)----
