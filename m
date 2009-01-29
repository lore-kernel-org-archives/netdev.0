From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 29 Jan 2009 18:03:43 +0300
Message-ID: <20090129150343.GB28669@ioremap.net>
References: <20090127225545.GA16143@ioremap.net> <20090129033613.GB6462@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from matrixpower.ru ([195.178.208.66]:34123 "EHLO tservice.net.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754726AbZA2PEH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 29 Jan 2009 10:04:07 -0500
Content-Disposition: inline
In-Reply-To: <20090129033613.GB6462@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Paul.

On Wed, Jan 28, 2009 at 07:36:13PM -0800, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > Passive OS fingerprint homepage (archives, examples):
> > http://www.ioremap.net/projects/osf
> 
> Cool stuff!!!

Thank you :)

> However, I believe you need an rcu_barrier() in the module-exit function
> as noted below.

> > +static void __devexit ipt_osf_fini(void)
> > +{
> > +	struct ipt_osf_finger *f;
> > +	int i;
> > +
> > +	cn_del_callback(&cn_osf_id);
> > +	xt_unregister_match(&ipt_osf_match);
> > +
> > +	rcu_read_lock();
> > +	for (i=0; i<ARRAY_SIZE(ipt_osf_fingers); ++i) {
> > +		struct ipt_osf_finger_storage *st = &ipt_osf_fingers[i];
> > +
> > +		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {
> > +			list_del_rcu(&f->finger_entry);
> > +			call_rcu(&f->rcu_head, ipt_osf_finger_free_rcu);
> > +		}
> > +	}
> > +	rcu_read_unlock();
> 
> Don't we need an rcu_barrier() here so that the preceding RCU callbacks
> are guaranteed to complete before the module text/data/bss vanish?
> 
> Whatever does the rmmod is responsible for making sure that there are no
> additional callers into the various entry points once the rmmod starts,
> I take it?  I don't see anything here that prevents something like that
> from happening (though I easily could be missing something).

All objects freed there were dynamically allocated, so we just
kfree()'ing some data not accessing static data potentially destroyed by
the rmmod and not accessing statically created, so there should be no
problems as far as I can see.

-- 
	Evgeniy Polyakov
