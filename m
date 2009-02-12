From: Evgeniy Polyakov <zbr@ioremap.net>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 12 Feb 2009 20:51:30 +0300
Message-ID: <20090212175130.GA16318@ioremap.net>
References: <20090212171245.GA15025@ioremap.net> <20090212174253.GF6759@linux.vnet.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cet.com.ru ([195.178.208.66]:47816 "EHLO tservice.net.ru"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1759467AbZBLRvc (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 12:51:32 -0500
Content-Disposition: inline
In-Reply-To: <20090212174253.GF6759@linux.vnet.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi.

On Thu, Feb 12, 2009 at 09:42:53AM -0800, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > Passive OS fingerprint homepage (archives, examples):
> > http://www.ioremap.net/projects/osf
> 
> I advocate using this to get more accurate censuses of machines
> accessing given web servers, given the tendency of browsers to lie
> about themselves in order to avoid being shut out of certain web sites.
> 
> One question about the module-unload sequence below.
> 
> Given a reasonable answer to that question, I am OK with this from
> an RCU viewpoint.

Thanks a lot Paul, but are they actually questions? You answered all of them :)

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
> 
> For the above to be safe:
> 
> o	Any remaining RCU callbacks cannot reference the list
> 	(and your callbacks do in fact meet this constraint).

They do not access that list.

> o	Any timers have to have fired or been cancelled (but you
> 	don't seem to have any timers, so not a problem).

No timers, tasklets, work queues or whatever else postponing the work.

> o	All pathways to the data structure have to have been
> 	shut down.  This is the tough one -- or is it simply
> 	a requirement that the guy removing the module has shut
> 	down all requests?

They can be accessed via connector configuration, but it is stopped
above (and it waits for currently active users to run away);
and netfilter path, which should be prevented after match was also
unregistered above.

-- 
	Evgeniy Polyakov
