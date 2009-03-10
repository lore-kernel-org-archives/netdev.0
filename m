From: Jesper Dangaard Brouer <hawk@diku.dk>
Subject: Re: Passive OS fingerprint xtables match.
Date: Tue, 10 Mar 2009 22:01:30 +0100 (CET)
Message-ID: <Pine.LNX.4.64.0903102147480.21593@ask.diku.dk>
References: <20090310151357.GA10658@ioremap.net>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; CHARSET=US-ASCII; format=flowed
Cc: Patrick McHardy <kaber@trash.net>, netdev <netdev@vger.kernel.org>,
	David Miller <davem@davemloft.net>,
	"Paul E. McKenney" <paulmck@linux.vnet.ibm.com>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>,
	Jan Engelhardt <jengelh@medozas.de>, hawk@comx.dk
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mgw2.diku.dk ([130.225.96.92]:43899 "EHLO mgw2.diku.dk"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753335AbZCJVBg (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Mar 2009 17:01:36 -0400
In-Reply-To: <20090310151357.GA10658@ioremap.net>
Content-ID: <Pine.LNX.4.64.0903102147482.21593@ask.diku.dk>
Content-Disposition: INLINE
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 10 Mar 2009, Evgeniy Polyakov wrote:

> +struct ipt_osf_finger {
> +	struct rcu_head			rcu_head;
> +	struct list_head		finger_entry;
> +	struct ipt_osf_user_finger	finger;
> +};

> +struct ipt_osf_finger_storage
> +{
> +	struct list_head		finger_list;
> +	spinlock_t			finger_lock;
> +};
> +
> +/*
> + * Indexed by dont-fragment bit.
> + * It is the only constant value in the fingerprint.
> + */
> +struct ipt_osf_finger_storage ipt_osf_fingers[2];
> +
> +static DEFINE_PER_CPU(struct ipt_osf_message, ipt_osf_mbuf);

> +static void __exit ipt_osf_fini(void)
> +{
> +	struct ipt_osf_finger *f;
> +	int i;
> +
> +	cn_del_callback(&cn_osf_id);
> +	xt_unregister_match(&ipt_osf_match);
> +
> +	rcu_read_lock();
> +	for (i=0; i<ARRAY_SIZE(ipt_osf_fingers); ++i) {
> +		struct ipt_osf_finger_storage *st = &ipt_osf_fingers[i];
> +
> +		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {

spin_lock(&st->finger_lock); //???
> +			list_del_rcu(&f->finger_entry);
spin_unlock(&st->finger_lock);

> +			call_rcu(&f->rcu_head, ipt_osf_finger_free_rcu);
> +		}
> +	}
> +	rcu_read_unlock();

Should the list_del_rcu() not be protected by a spinlock?


> +	rcu_barrier();

In some of my code I call synchronize_net(), is it enough to call 
rcu_barrier()?

What is the difference between:

  synchronize_rcu()
  synchronize_net()
  rcu_barrier()

Hilsen
   Jesper Brouer

--
-------------------------------------------------------------------
MSc. Master of Computer Science
Dept. of Computer Science, University of Copenhagen
Author of http://www.adsl-optimizer.dk
-------------------------------------------------------------------
