From: Tejun Heo <tj@kernel.org>
Subject: Possible netlink autobind regression
Date: Wed, 16 Sep 2015 22:29:09 -0400
Message-ID: <20150917022909.GA22754@htj.duckdns.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: davem@davemloft.net, tom@herbertland.com, kafai@fb.com,
	kernel-team@fb.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org
To: herbert@gondor.apana.org.au
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello,

We're seeing processes piling up on audit_cmd_mutex and after some
digging it turns out sometimes audit_receive() ends up recursing into
itself causing an A-A deadlock on audit_cmd_mutex.  Here's the
backtrace.

 PID: 1939995  TASK: ffff88085bdde360  CPU: 27  COMMAND: "crond"
  #0 [ffff880369513ae0] __schedule at ffffffff818c49e2
  #1 [ffff880369513b30] schedule at ffffffff818c50e7
  #2 [ffff880369513b50] schedule_preempt_disabled at ffffffff818c52ce
  #3 [ffff880369513b60] __mutex_lock_slowpath at ffffffff818c6ad2
  #4 [ffff880369513bc0] mutex_lock at ffffffff818c6b5b
  #5 [ffff880369513be0] audit_receive at ffffffff810de5f1
  #6 [ffff880369513c10] netlink_unicast at ffffffff817c419b
  #7 [ffff880369513c60] netlink_ack at ffffffff817c4764
  #8 [ffff880369513ca0] audit_receive at ffffffff810de65a
  #9 [ffff880369513cd0] netlink_unicast at ffffffff817c419b
 #10 [ffff880369513d20] netlink_sendmsg at ffffffff817c450a
 #11 [ffff880369513da0] sock_sendmsg at ffffffff817792ba
 #12 [ffff880369513e30] SYSC_sendto at ffffffff81779ce0
 #13 [ffff880369513f70] sys_sendto at ffffffff8177a27e
 #14 [ffff880369513f80] system_call_fastpath at ffffffff818c8772
     RIP: 00007fbf652e6913  RSP: 00007ffca11d08d8  RFLAGS: 00010202
     RAX: ffffffffffffffda  RBX: ffffffff818c8772  RCX: 0000000000000000
     RDX: 0000000000000070  RSI: 00007ffca11d2c50  RDI: 0000000000000003
     RBP: 00007ffca11d2c50   R8: 00007ffca11d08f0   R9: 000000000000000c
     R10: 0000000000000000  R11: 0000000000000246  R12: ffffffff8177a27e
     R13: ffff880369513f78  R14: 0000000000000060  R15: 0000000000000070
     ORIG_RAX: 000000000000002c  CS: 0033  SS: 002b

The weird thing is that netlink_ack() ends up trying to send ack to
the kernel socket instead of the userland sender.  This seems only
possible if the issuing socket's portid is 0 for some reason.

c0bb07df7d98 ("netlink: Reset portid after netlink_insert failure")
made netlink_insert() reset nlk_sk(sk)->portid to zero if insertion
fails.  The description says that it prevents sockets which lost
autobinding from being stuck in limbo.  I could be mistaken but the
description doesn't seem to be enough - for unconnected sendmsg users,
it looks like the socket would just use the wrong port number likely
occupied by someone else from the second try which would hose ack
routing.

Anyways, after the patch, it seems something like the following could
happen.

  thread 1			thread 2
 -----------------------------------------------------------------------
  netlink_sendmsg()
  netlink_autobind()
  netlink_insert()
    nlk->portid = portid;
    __netlink_insert() fails

				 netlink_sendmsg()
				   nlk->portid is not zero,
				   skip autobinding
    nlk->portid = 0;
				 NETLINK_CB(skb).portid is set to zero
				 ...
				 netlink_ack(skb)
				   tries to send ack to kernel rx socket


If the above could happen, it would explain the deadlock.  The root
problem is that whether to autobind or not is determined by testing
whether nlk->portid is zero without synchronizing against autobind
path and the autobind path may temporarily set and then clear portid
thus tricking the unsynchronized test.  The issue can be fixed by only
setting portid after it's known that the port can be used.

That particular issue can be fixed by the following incorrect patch
which needs more work as it ends up temporarily hashing sockets with a
mismatching portid.

Does this make any sense or am I chasing wild geese?

Thanks.

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index 7f86d3b..6835426 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1037,11 +1037,12 @@ static struct sock *__netlink_lookup(struct netlink_table *table, u32 portid,
 				      netlink_rhashtable_params);
 }
 
-static int __netlink_insert(struct netlink_table *table, struct sock *sk)
+static int __netlink_insert(struct netlink_table *table, struct sock *sk,
+			    int portid)
 {
 	struct netlink_compare_arg arg;
 
-	netlink_compare_arg_init(&arg, sock_net(sk), nlk_sk(sk)->portid);
+	netlink_compare_arg_init(&arg, sock_net(sk), portid);
 	return rhashtable_lookup_insert_key(&table->hash, &arg,
 					    &nlk_sk(sk)->node,
 					    netlink_rhashtable_params);
@@ -1103,11 +1104,12 @@ static int netlink_insert(struct sock *sk, u32 portid)
 	    unlikely(atomic_read(&table->hash.nelems) >= UINT_MAX))
 		goto err;
 
-	nlk_sk(sk)->portid = portid;
 	sock_hold(sk);
 
-	err = __netlink_insert(table, sk);
-	if (err) {
+	err = __netlink_insert(table, sk, portid);
+	if (!err) {
+		nlk_sk(sk)->portid = portid;
+	} else {
 		/* In case the hashtable backend returns with -EBUSY
 		 * from here, it must not escape to the caller.
 		 */
@@ -1115,7 +1117,6 @@ static int netlink_insert(struct sock *sk, u32 portid)
 			err = -EOVERFLOW;
 		if (err == -EEXIST)
 			err = -EADDRINUSE;
-		nlk_sk(sk)->portid = 0;
 		sock_put(sk);
 	}
 

Thanks.

-- 
tejun
