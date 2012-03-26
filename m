From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: RCU lock bug in 3.0.21 (bisected to: 682cb56a, fix NULL
 dereferences in check_peer_redir)
Date: Tue, 27 Mar 2012 01:39:08 +0200
Message-ID: <1332805148.3547.14.camel@edumazet-glaptop>
References: <4F70E308.7070908@candelatech.com>
	 <20120326.174945.1186427809261872546.davem@davemloft.net>
	 <4F70E560.3020102@candelatech.com>  <4F70F688.6050108@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	gregkh@linuxfoundation.org,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
To: Ben Greear <greearb@candelatech.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f46.google.com ([74.125.83.46]:40665 "EHLO
	mail-ee0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755320Ab2CZXjO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 26 Mar 2012 19:39:14 -0400
Received: by eekc41 with SMTP id c41so1700040eek.19
        for <netdev@vger.kernel.org>; Mon, 26 Mar 2012 16:39:13 -0700 (PDT)
In-Reply-To: <4F70F688.6050108@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2012-03-26 at 16:06 -0700, Ben Greear wrote:
> On 03/26/2012 02:53 PM, Ben Greear wrote:
> > On 03/26/2012 02:49 PM, David Miller wrote:
> >>
> >> Looks like all of those strange undiagnosable reported Dave Jones
> >> has been feeding us. Something in one part of the kernel leaves
> >> a lock held, and this shows up as a warning elsewhere.
> >
> > Every (initial) bug printout fingers ipv6 and the 'ip' tool on my system.
> 
> I added a patch to convert rcu_read_lock/unlock to macros so
> that I could automatically grab the call site (_THIS_IP_)
> and pass it into the lockdep framework instead of the (useless)
> _THIS_IP_ in the old rcu_read_lock method which at best seems to
> only indicate which module the issue relates to...

Hi Ben

Is this problem also appears with current tree ?
(This could be a problem with the backport, as it was full of
dependencies)

Also, if you use a patch to better track rcu_read_lock()/unlock(), you
could add new macros as well to track that a particular unlock() matches
one given lock(). (maybe returning the rcu_preempt_depth at
rcu_read_lock() time , but maybe a more absolute ref would be better)

So we could have a warning if an unlock() doesnt match the lock()

inet6_dump_fib () was already a suspect but we could not find why.

diff --git a/net/ipv6/ip6_fib.c b/net/ipv6/ip6_fib.c
index 5b27fbc..d1719e3 100644
--- a/net/ipv6/ip6_fib.c
+++ b/net/ipv6/ip6_fib.c
@@ -362,6 +362,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	struct hlist_node *node;
 	struct hlist_head *head;
 	int res = 0;
+	int depth;
 
 	s_h = cb->args[0];
 	s_e = cb->args[1];
@@ -390,7 +391,7 @@ static int inet6_dump_fib(struct sk_buff *skb, struct netlink_callback *cb)
 	arg.net = net;
 	w->args = &arg;
 
-	rcu_read_lock();
+	depth = rcu_read_lock_return();
 	for (h = s_h; h < FIB6_TABLE_HASHSZ; h++, s_e = 0) {
 		e = 0;
 		head = &net->ipv6.fib_table_hash[h];
@@ -405,7 +406,7 @@ next:
 		}
 	}
 out:
-	rcu_read_unlock();
+	rcu_read_unlock_check(depth);
 	cb->args[1] = e;
 	cb->args[0] = h;
 
