From: Pablo Neira <pablo@eurodev.net>
Subject: Re: [PATCH] Improve behaviour of Netlink Sockets
Date: Mon, 30 Aug 2004 02:37:45 +0200
Sender: linux-net-owner@vger.kernel.org
Message-ID: <413276D9.9080303@eurodev.net>
References: <412DF807.2040703@eurodev.net>	<20040826141407.38b56729.davem@redhat.com>	<412EB40A.6010100@eurodev.net>	<20040826214710.5e322f1a.davem@redhat.com>	<412F1269.8090303@eurodev.net> <20040827172736.543dbd54.davem@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------050608010505050300050900"
Return-path: <linux-net-owner@vger.kernel.org>
To: "David S. Miller" <davem@redhat.com>, netdev@oss.sgi.com,
	linux-net@vger.kernel.org
In-Reply-To: <20040827172736.543dbd54.davem@redhat.com>
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------050608010505050300050900
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit

Hi Davem,

David S. Miller wrote:

>Is a 2.4.x version possible?
>  
>
Attached the 2.4.x version. It just spawns one kernel thread called 
netlink, is it ok?

regards,
Pablo

--------------050608010505050300050900
Content-Type: text/x-patch;
 name="netlink-tqueue.patch"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="netlink-tqueue.patch"

--- a/net/netlink/af_netlink.c	2004-08-28 05:35:35.000000000 +0200
+++ b/net/netlink/af_netlink.c	2004-08-29 16:00:46.000000000 +0200
@@ -42,6 +42,7 @@
 #include <linux/notifier.h>
 #include <net/sock.h>
 #include <net/scm.h>
+#include <linux/tqueue.h>
 
 #define Nprintk(a...)
 
@@ -63,6 +64,15 @@
 	void			(*data_ready)(struct sock *sk, int bytes);
 };
 
+struct netlink_work
+{
+	struct sock 		*sk;
+	int 			len;
+	struct tq_struct	work;
+};
+
+static DECLARE_TASK_QUEUE(tq_netlink);
+static DECLARE_WAIT_QUEUE_HEAD(netlink_thread_wait);
 static struct sock *nl_table[MAX_LINKS];
 static DECLARE_WAIT_QUEUE_HEAD(nl_table_wait);
 static unsigned nl_nonroot[MAX_LINKS];
@@ -81,6 +91,15 @@
 
 static struct notifier_block *netlink_chain;
 
+void netlink_tq_handler(void *data)
+{
+	struct netlink_work *work = data;
+	
+	work->sk->data_ready(work->sk, work->len);
+	sock_put(work->sk);
+	kfree(work);
+}
+
 static void netlink_sock_destruct(struct sock *sk)
 {
 	skb_queue_purge(&sk->receive_queue);
@@ -437,6 +456,8 @@
 
 	if (atomic_read(&sk->rmem_alloc) > sk->rcvbuf ||
 	    test_bit(0, &sk->protinfo.af_netlink->state)) {
+		struct task_struct *client;
+		
 		if (!timeo) {
 			if (ssk->protinfo.af_netlink->pid == 0)
 				netlink_overrun(sk);
@@ -445,6 +466,19 @@
 			return -EAGAIN;
 		}
 
+		if (!sk->protinfo.af_netlink->pid) {
+			/* Kernel is sending information to user space
+			 * and socket buffer is full: Wake up user */
+			
+			client = find_task_by_pid(sk->protinfo.af_netlink->pid);
+			if (!client) {
+				sock_put(sk);
+				kfree_skb(skb);
+				return -EAGAIN;
+			}
+			wake_up_process(client);
+		}
+
 		__set_current_state(TASK_INTERRUPTIBLE);
 		add_wait_queue(&sk->protinfo.af_netlink->wait, &wait);
 
@@ -467,8 +501,26 @@
 	skb_orphan(skb);
 	skb_set_owner_r(skb, sk);
 	skb_queue_tail(&sk->receive_queue, skb);
-	sk->data_ready(sk, len);
-	sock_put(sk);
+
+	if (!sk->protinfo.af_netlink->pid) {
+		struct netlink_work *nlwork = 
+			kmalloc(sizeof(struct netlink_work), GFP_KERNEL);
+		
+		if  (!nlwork) {
+			sock_put(sk);
+			return -EAGAIN;
+		}
+		
+		INIT_TQUEUE(&nlwork->work, netlink_tq_handler, nlwork);
+		nlwork->sk = sk;
+		nlwork->len = len;
+		queue_task(&nlwork->work, &tq_netlink);
+		wake_up(&netlink_thread_wait);
+	} else {
+		sk->data_ready(sk, len);
+		sock_put(sk);
+	}
+	
 	return len;
 
 no_dst:
@@ -490,7 +542,22 @@
                 skb_orphan(skb);
 		skb_set_owner_r(skb, sk);
 		skb_queue_tail(&sk->receive_queue, skb);
-		sk->data_ready(sk, skb->len);
+
+		if (!sk->protinfo.af_netlink->pid) {
+			struct netlink_work *nlwork = 
+				kmalloc(sizeof(struct netlink_work), GFP_KERNEL);
+		
+			if  (!nlwork) 
+				return -EAGAIN;
+		
+			INIT_TQUEUE(&nlwork->work, netlink_tq_handler, nlwork);
+			nlwork->sk = sk;
+			nlwork->len = skb->len;
+			queue_task(&nlwork->work, &tq_netlink);
+			wake_up(&netlink_thread_wait);
+		} else 
+			sk->data_ready(sk, skb->len);
+
 		return 0;
 	}
 	return -1;
@@ -534,11 +601,12 @@
 			netlink_overrun(sk);
 			/* Clone failed. Notify ALL listeners. */
 			failure = 1;
+			sock_put(sk);
 		} else if (netlink_broadcast_deliver(sk, skb2)) {
 			netlink_overrun(sk);
+			sock_put(sk);
 		} else
 			skb2 = NULL;
-		sock_put(sk);
 	}
 
 	netlink_unlock_table();
@@ -868,6 +936,26 @@
 	netlink_unicast(in_skb->sk, skb, NETLINK_CB(in_skb).pid, MSG_DONTWAIT);
 }
 
+int netlink_thread(void *unused)
+{
+	struct task_struct *tsk = current;
+	DECLARE_WAITQUEUE(wait, tsk);
+
+	daemonize();
+	strcpy(tsk->comm, "netlink");
+	sigfillset(&tsk->blocked);
+	mb();
+
+	for (;;) {
+		run_task_queue(&tq_netlink);
+		
+		__set_current_state(TASK_INTERRUPTIBLE);
+		add_wait_queue(&netlink_thread_wait, &wait);
+		schedule();
+		__set_current_state(TASK_RUNNING);
+		remove_wait_queue(&netlink_thread_wait, &wait);
+	}
+}
 
 #ifdef NL_EMULATE_DEV
 
@@ -1027,6 +1115,8 @@
 #ifdef CONFIG_PROC_FS
 	create_proc_read_entry("net/netlink", 0, 0, netlink_read_proc, NULL);
 #endif
+	kernel_thread(netlink_thread, NULL, CLONE_FS | CLONE_FILES | CLONE_SIGNAL);
+	
 	return 0;
 }
 

--------------050608010505050300050900--
