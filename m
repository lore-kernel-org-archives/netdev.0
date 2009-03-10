From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Wed, 11 Mar 2009 00:54:44 +0300
Message-ID: <20090310215443.GA9660@ioremap.net>
References: <20090310151357.GA10658@ioremap.net> <Pine.LNX.4.64.0903102147480.21593@ask.diku.dk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>, hawk@comx.dk
To: Jesper Dangaard Brouer <hawk@diku.dk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from genesysrack.ru ([195.178.208.66]:49395 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754571AbZCJVyz (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 17:54:55 -0400
Content-Disposition: inline
In-Reply-To: <Pine.LNX.4.64.0903102147480.21593@ask.diku.dk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Tue, Mar 10, 2009 at 10:01:30PM +0100, Jesper Dangaard Brouer (hawk@diku.dk) wrote:
> >+static void __exit ipt_osf_fini(void)
> >+{
> >+	struct ipt_osf_finger *f;
> >+	int i;
> >+
> >+	cn_del_callback(&cn_osf_id);
> >+	xt_unregister_match(&ipt_osf_match);
> >+
> >+	rcu_read_lock();
> >+	for (i=0; i<ARRAY_SIZE(ipt_osf_fingers); ++i) {
> >+		struct ipt_osf_finger_storage *st = &ipt_osf_fingers[i];
> >+
> >+		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {
> 
> spin_lock(&st->finger_lock); //???
> >+			list_del_rcu(&f->finger_entry);
> spin_unlock(&st->finger_lock);
> 
> >+			call_rcu(&f->rcu_head, ipt_osf_finger_free_rcu);
> >+		}
> >+	}
> >+	rcu_read_unlock();
> 
> Should the list_del_rcu() not be protected by a spinlock?

Not required at this place - all users are already unregistered and
no code can access this list except module exit path.

> >+	rcu_barrier();
> 
> In some of my code I call synchronize_net(), is it enough to call 
> rcu_barrier()?

It is enough here, rcu_barrier() will wait until all scheduled
call_rcu() are completed, that's what we need. But in some cases we
should only wait for the whole grace period to elapse, then one has to use
synchronize_rcu() and friends. rcu_barrier() will wait for the callbacks
to be executed, while they are executed after grace period has elapsed,
so it implicitly includes synchronize_rcu(), but effectively they are
the same: both functions register rcu callback and wait for the
completion, rcu_barrier() is a bit more enhanced, since it has several
types.

> What is the difference between:
> 
>  synchronize_rcu()
>  synchronize_net()

Those are essentially the same - synchronize_net() has additional
might_sleep()  call. Both will wait until grace period elapced - i.e.
all currently RCU protected sections completed.

>  rcu_barrier()

It will wait until all scheduled rcu callbacks are executed.

So from the description they look different, but implementation
suggestes that effectively they are the same, except that there are a
bit different invocation types for the barrier.

-- 
	Evgeniy Polyakov
