From: "Paul E. McKenney" <paulmck@linux.vnet.ibm.com>
Subject: Re: Passive OS fingerprint xtables match.
Date: Thu, 12 Feb 2009 12:41:15 -0800
Message-ID: <20090212204115.GL6759@linux.vnet.ibm.com>
References: <20090212171245.GA15025@ioremap.net> <20090212174253.GF6759@linux.vnet.ibm.com> <20090212175130.GA16318@ioremap.net>
Reply-To: paulmck@linux.vnet.ibm.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	David Miller <davem@davemloft.net>,
	Netfilter Development Mailinglist
	<netfilter-devel@vger.kernel.org>
To: Evgeniy Polyakov <zbr@ioremap.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e7.ny.us.ibm.com ([32.97.182.137]:54710 "EHLO e7.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757913AbZBLUlR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 12 Feb 2009 15:41:17 -0500
Content-Disposition: inline
In-Reply-To: <20090212175130.GA16318@ioremap.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Feb 12, 2009 at 08:51:30PM +0300, Evgeniy Polyakov wrote:
> Hi.
> 
> On Thu, Feb 12, 2009 at 09:42:53AM -0800, Paul E. McKenney (paulmck@linux.vnet.ibm.com) wrote:
> > > Passive OS fingerprint homepage (archives, examples):
> > > http://www.ioremap.net/projects/osf
> > 
> > I advocate using this to get more accurate censuses of machines
> > accessing given web servers, given the tendency of browsers to lie
> > about themselves in order to avoid being shut out of certain web sites.
> > 
> > One question about the module-unload sequence below.
> > 
> > Given a reasonable answer to that question, I am OK with this from
> > an RCU viewpoint.
> 
> Thanks a lot Paul, but are they actually questions? You answered all of them :)

The last one was.  Your answer was that you prevented any concurrent
access, but I frankly don't understand the netfilter/connector code
well enough to do more than simply believe you.

							Thanx, Paul

> > > +static void __devexit ipt_osf_fini(void)
> > > +{
> > > +	struct ipt_osf_finger *f;
> > > +	int i;
> > > +
> > > +	cn_del_callback(&cn_osf_id);
> > > +	xt_unregister_match(&ipt_osf_match);
> > > +
> > > +	rcu_read_lock();
> > > +	for (i=0; i<ARRAY_SIZE(ipt_osf_fingers); ++i) {
> > > +		struct ipt_osf_finger_storage *st = &ipt_osf_fingers[i];
> > > +
> > > +		list_for_each_entry_rcu(f, &st->finger_list, finger_entry) {
> > > +			list_del_rcu(&f->finger_entry);
> > 
> > For the above to be safe:
> > 
> > o	Any remaining RCU callbacks cannot reference the list
> > 	(and your callbacks do in fact meet this constraint).
> 
> They do not access that list.
> 
> > o	Any timers have to have fired or been cancelled (but you
> > 	don't seem to have any timers, so not a problem).
> 
> No timers, tasklets, work queues or whatever else postponing the work.
> 
> > o	All pathways to the data structure have to have been
> > 	shut down.  This is the tough one -- or is it simply
> > 	a requirement that the guy removing the module has shut
> > 	down all requests?
> 
> They can be accessed via connector configuration, but it is stopped
> above (and it waits for currently active users to run away);
> and netfilter path, which should be prevented after match was also
> unregistered above.
> 
> -- 
> 	Evgeniy Polyakov
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
