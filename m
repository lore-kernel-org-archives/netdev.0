From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: RCU problems in fib_table_insert
Date: Sun, 21 Mar 2010 14:37:03 -0700
Message-ID: <20100321213703.GD2517@linux.vnet.ibm.com>
References: <20100321202525.GA966@basil.fritz.box>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: robert.olsson@its.uu.se, netdev@vger.kernel.org
To: Andi Kleen <andi@firstfloor.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e8.ny.us.ibm.com ([32.97.182.138]:39408 "EHLO e8.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752324Ab0CUVhM (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 21 Mar 2010 17:37:12 -0400
Received: from d01relay06.pok.ibm.com (d01relay06.pok.ibm.com [9.56.227.116])
	by e8.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o2LLSaRC029645
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:28:36 -0400
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay06.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o2LLb6Zm1847486
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:37:06 -0400
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o2LLb5gX014936
	for <netdev@vger.kernel.org>; Sun, 21 Mar 2010 17:37:06 -0400
Content-Disposition: inline
In-Reply-To: <20100321202525.GA966@basil.fritz.box>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 21, 2010 at 09:25:25PM +0100, Andi Kleen wrote:
> Hi,
> 
> I got the following warning at boot with a 2.6.34-rc2ish git kernel
> with RCU debugging and preemption enabled.
> 
> It seems the problem is that not all callers of fib_find_node
> call it with rcu_read_lock() to stabilize access to the fib. 
> 
> I tried to fix it, but especially for fib_table_insert() that's rather 
> tricky: it does a lot of memory allocations and also route flushing and 
> other blocking operations while assuming the original fa is RCU stable.
> 
> I first tried to move some allocations to the beginning and keep
> preemption disabled in the rest, but it's difficult with all of them.
> No patch because of that.
> 
> Does the fa need an additional reference count for this problem?
> Or perhaps some optimistic locking?
> 
> -Andi
> 
> 
> ==================================================
> [ INFO: suspicious rcu_dereference_check() usage. ]
> ---------------------------------------------------
> /home/lsrc/git/linux-2.6/net/ipv4/fib_trie.c:964 invoked rcu_dereference_check() without protection!
> 
> other info that might help us debug this:
> 
> 
> rcu_scheduler_active = 1, debug_locks = 0
> 2 locks held by ip/4521:
>  #0:  (rtnl_mutex){+.+.+.}, at: [<ffffffff816466af>] rtnetlink_rcv+0x1f/0x40
>  #1:  ((inetaddr_chain).rwsem){.+.+.+}, at: [<ffffffff8107cde7>] __blocking_notifier_call_chain+0x47/0x90

Looks to me like a false positive: If I rememeber correctly, it is OK
to invoke the fib-trie functions either inside an RCU read-side critical
section or with RTNL held.  However, I must defer to the networking guys.
For one thing, things might have changed since I last looked at this code.

But if I am correct, the following patch should work.  If I am wrong,
this patch will instead incorrectly enforce my misconceptions.  ;-)

							Thanx, Paul

------------------------------------------------------------------------

net: suppress lockdep-RCU false positive in FIB trie.

Allow fib_find_node() to be called either under rcu_read_lock()
protection or with RTNL held.

Signed-off-by: Paul E. McKenney <paulmck@linux.vnet.ibm.com>
---

 fib_trie.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/net/ipv4/fib_trie.c b/net/ipv4/fib_trie.c
index af5d897..01ef8ba 100644
--- a/net/ipv4/fib_trie.c
+++ b/net/ipv4/fib_trie.c
@@ -961,7 +961,9 @@ fib_find_node(struct trie *t, u32 key)
 	struct node *n;
 
 	pos = 0;
-	n = rcu_dereference(t->trie);
+	n = rcu_dereference_check(t->trie,
+				  rcu_read_lock_held() ||
+				  lockdep_rtnl_is_held());
 
 	while (n != NULL &&  NODE_TYPE(n) == T_TNODE) {
 		tn = (struct tnode *) n;
