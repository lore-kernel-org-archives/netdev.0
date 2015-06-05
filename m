From: Andy Gospodarek <gospo@cumulusnetworks.com>
Subject: Re: [PATCH net-next] net: change fib behavior based on interface
 link status
Date: Fri, 5 Jun 2015 15:05:46 -0400
Message-ID: <20150605190543.GO588@gospo.home.greyhouse.net>
References: <1433300839-18511-1-git-send-email-gospo@cumulusnetworks.com>
 <556F4685.5010505@gmail.com>
 <20150603200232.GL588@gospo.home.greyhouse.net>
 <556F6B24.3040704@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, davem@davemloft.net,
	ddutt@cumulusnetworks.com
To: Alexander Duyck <alexander.duyck@gmail.com>, sfeldma@gmail.com,
	shemminger@vyatta.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f42.google.com ([209.85.192.42]:33805 "EHLO
	mail-qg0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751433AbbFETFu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Jun 2015 15:05:50 -0400
Received: by qgf75 with SMTP id 75so31102141qgf.1
        for <netdev@vger.kernel.org>; Fri, 05 Jun 2015 12:05:50 -0700 (PDT)
Content-Disposition: inline
In-Reply-To: <556F6B24.3040704@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jun 03, 2015 at 02:01:24PM -0700, Alexander Duyck wrote:
> On 06/03/2015 01:02 PM, Andy Gospodarek wrote:
[...]
> >
> >>>@@ -621,7 +623,7 @@ static int fib_check_nh(struct fib_config *cfg, struct fib_info *fi,
> >>>  			/* It is not necessary, but requires a bit of thinking */
> >>>  			if (fl4.flowi4_scope < RT_SCOPE_LINK)
> >>>  				fl4.flowi4_scope = RT_SCOPE_LINK;
> >>>-			err = fib_lookup(net, &fl4, &res);
> >>>+			err = fib_lookup_flags(net, &fl4, &res, FIB_LOOKUP_ALLOWDEAD);
> >>>  			if (err) {
> >>>  				rcu_read_unlock();
> >>>  				return err;
> 
> I just noticed this piece.  You replace fib_lookup with fib_lookup_flags.  I
> don't think the two are equivalent since what you modified was __fib_lookup.
> Also there are two implementations of fib_lookup, one for the multiple
> tables and one for the single table implementation.  You need to make sure
> both work the same after your patch.
> 
> It might also be worthwhile to make it so that the lookup flag opts into
> dropping the down link instead of opting into it.  One way to approach this
> would be to make both fib_lookup and __fib_lookup accept a flags value.
> Then you could OR in the FIB_LOOKUP_NOREF in fib_lookup, and assign the
> value directly to the arg.flags in __fib_lookup, and strip the
> FIB_LOOKUP_DROPDEAD (yes I am flipping the logic here so I renamed it) in
> fib_table_lookup if the sysctl indicates the option is disabled.  In fact
> you could probably convert the bit stripping in fib_table_lookup to a
> static_key based flag similar to rps_needed.
> 
> You might also want to split this into two patches.  One for
> setting/clearing the LINKDOWN bit, and one for all of the fib_lookup
> changes.

So I think I've addressed most of your concerns (as well as Scott's
concern about a per-device configuration), and have it ready to go.  I've
also cleaned up other items that had odd/confusing logic so they will
hopefully be easier to maintain.

The switchdev bits are not done, but that should be terrible -- despite
the fact that right now no NH flag changes made inside the kernel are
communicated to offload devices.

[...]
> >That would be fine, but then a new way needs to be devised to report
> >this back to userspace to anyone who performs a dump of the fib table
> >knows that routes are dead.  One such option would be to have a check
> >in fib_dump_info() for link status and add the RTNH_F_DEAD flag (or
> >another flag if it is deemed that this is necessary and not too
> >disruptive to userspace on the way up.
> 
> I'd leave this up to Stephen.  Actually implementing that bit should be
> straight forward since it is just a shift, AND, OR to get the DEAD bit to
> mirror the LINKDOWN bit.

I've still not heard anything from Stephen and I'd be curious if he
wants to weigh in on this....

My preference for user output is for the normal output to users who have
not set any of these sysctl bits to see this output with iproute2 when
p8p1 is linkdown:

# ip route show
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 linkdown 
90.0.0.0/24 
	nexthop via 80.0.0.2  dev p8p1 weight 1 linkdown
	nexthop via 70.0.0.2  dev p7p1 weight 1

This would simply indicate state, it does not take an action based on
that flag.  If the sysctl is set we would see the following:

# ip route show
70.0.0.0/24 dev p7p1  proto kernel  scope link  src 70.0.0.1 
80.0.0.0/24 dev p8p1  proto kernel  scope link  src 80.0.0.1 dead linkdown 
90.0.0.0/24 
	nexthop via 80.0.0.2  dev p8p1 weight 1 dead linkdown
	nexthop via 70.0.0.2  dev p7p1 weight 1

This allows someone who is only querying via netlink to know that the
route would not be used by the kernel due to the link being down (bits
for DEAD & LINKDOWN set).  This is separate from the nexthop not being
used as the interface is administratively down (bits for DEAD set).

FWIW, the kernel will not set these bits at the same time.  There really
is not a need since we are keying off the sysctl and LINKDOWN and the
logic is much cleaner and easier to understand that way.  This would be
similar to the way dev_get_flags adds bits to GETLINK callers without
having the kernel store all of those values.
