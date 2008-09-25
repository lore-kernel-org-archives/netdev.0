From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: [PATCH 1/1] Use RCU for the UDP hash lock
Date: Thu, 25 Sep 2008 08:29:36 -0700
Message-ID: <20080925152936.GF6725@linux.vnet.ibm.com>
References: <20080924172827.GA1573@minyard.local> <20080924124006.6bb41b49@extreme> <48DAA71C.5030000@acm.org>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	Linux Kernel <linux-kernel@vger.kernel.org>,
	netdev@vger.kernel.org
To: Corey Minyard <minyard@acm.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754392AbYIYPaK@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <48DAA71C.5030000@acm.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Sep 24, 2008 at 03:46:20PM -0500, Corey Minyard wrote:
> Stephen Hemminger wrote:
>>   
>>>   static inline void udp_lib_unhash(struct sock *sk)
>>>  {
>>> -	write_lock_bh(&udp_hash_lock);
>>> -	if (sk_del_node_init(sk)) {
>>> +	spin_lock_bh(&udp_hash_wlock);
>>> +	if (sk_del_node_rcu(sk)) {
>>>  		inet_sk(sk)->num = 0;
>>>  		sock_prot_inuse_add(sock_net(sk), sk->sk_prot, -1);
>>>  	}
>>> -	write_unlock_bh(&udp_hash_lock);
>>> +	spin_unlock_bh(&udp_hash_wlock);
>>> +	synchronize_sched();
>>>     
>>
>> Could this be synchronize_rcu? You are using rcu_read_lock() protected 
>> sections.
>>   
> I meant to comment on that.  I wasn't sure which to use, so I chose the 
> more conservative approach.  synchronize_rcu() might be appropriate.

You do indeed need to match the update-side and read-side primitives:

	Update-side				Read-side

	synchronize_rcu()			rcu_read_lock()
	call_rcu()				rcu_read_unlock()

	call_rcu_bh()				rcu_read_lock_bh()
						rcu_read_unlock_bh()

	synchronize_sched()			preempt_disable()
						preempt_enable()
						[and anything else
						 that disables either
						 preemption or irqs]

	synchronize_srcu()			srcu_read_lock()
						srcu_read_unlock()


Mixing RCU or RCU-SCHED with RCU-BH will fail in Classic RCU systems,
while mixing RCU or RCU-BH with RCU-SCHED will fail in preemptable RCU
systems.  Mixing SRCU with any of the other flavors of RCU will fail
on any system.

So please match them up correctly!

							Thanx, Paul
