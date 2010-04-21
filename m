From: James Chapman <jchapman@katalix.com>
Subject: Re: [PATCH net-next-2.6 v4 10/14] l2tp: Convert rwlock to RCU
Date: Wed, 21 Apr 2010 14:53:58 +0100
Message-ID: <4BCF0376.9010504@katalix.com>
References: <20100402161822.11367.70454.stgit@bert.katalix.com>	 <20100402161916.11367.32252.stgit@bert.katalix.com> <1271782553.7895.62.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from katalix.com ([82.103.140.233]:46768 "EHLO mail.katalix.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754808Ab0DUNyE (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 21 Apr 2010 09:54:04 -0400
In-Reply-To: <1271782553.7895.62.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Hi James
> 
> I started a while ago patching l2tp but I wont be able to finish and
> test the thing...
> 
> There is a fundamental problem with this kind of construct :
> (this was wrong even better your RCU conversion)
> 
> rcu_read_lock_bh()
> hlist_for_each_entry_rcu(session, walk, session_list, global_hlist) {
> 	if (session->session_id == session_id) {
> 		rcu_read_unlock_bh();
> 		return session;
> 	}
> }
> rcu_read_unlock_bh();
> 
> 
> While the lookup _is_ protected, the result is not.
> 
> As soon as you call rcu_read_unlock_bh(); and before the "return
> session;", current thread could be preempted and an other thread frees
> session under first thread. Unexpected things can then happen.
> 
> Therefore, you need either to :
> 
> 1) Take a refcount on session (or tunnel) before the return
> 2) Or move the rcu_read_lock_bh()/rcu_read_unlock_bh() at callers.
> 3) Or all callers use a stronger lock. But then, why use RCU ;)
> 
> Here is a preliminary patch, obviously not finished, nor compiled, nor
> tested, to give possible ways to handle this problem.
> 
> (I added the ref parameter to make sure to change function signatures,
> maybe its not necessary and we should always take references)

Thanks Eric. I'll take a look at this.

-- 
James Chapman
Katalix Systems Ltd
http://www.katalix.com
Catalysts for your Embedded Linux software development

