From: David Stevens <dlstevens-r/Jw6+rmf7HQT0dZR+AlfA@public.gmane.org>
Subject: Re: igmp: Allow mininum interval specification for igmp timers.
Date: Mon, 27 Sep 2010 12:55:29 -0700
Message-ID: <OFC4EC0538.26831D99-ON882577AB.006B8055-882577AB.006D75FF@us.ibm.com>
References: <alpine.DEB.2.00.1009221354410.32661@router.home>	<20100923.213823.137834706.davem@davemloft.net>
	<OF4BA8F9C2.467056E9-ON882577AB.005F4832-882577AB.00612DD6@us.ibm.com> <20100927.105444.214208865.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="US-ASCII"
Cc: cl-vYTEC60ixJUAvxtiuMwx3w@public.gmane.org, linux-rdma-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	netdev-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, rda-x0S3BwdUo6DQT0dZR+AlfA@public.gmane.org
To: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Return-path: <linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <20100927.105444.214208865.davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
Sender: linux-rdma-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org> wrote on 09/27/2010 10:54:44 AM:

> This patch on the other hand is attacking a different problem,
> namely avoiding the worst cases caused by the randomization we
> do for the timer.
> 
> With bad luck this thing times out way too fast because the total of
> all of the randomized intervals can end up being very small, and I
> think we should fix that independently of the other issues hit by the
> IB folks.

        I think I'm caught up on the discussion now. For IGMPv3, we
would send all the reports always in < 2 secs, and the average would
be < 1 sec, so I'm not sure any sort of tweaks we do to enforce a
minimum randomized interval are compatible with IGMPv3 and still
solve IB's problem.
        As I said before, I think per protocol, back-to-back is both
allowed and not a problem, even if both subsequent randomized reports
come out to 0 time. But if we wanted to enforce a minimum interval
of, say, X, then I think the better way to do that is to set the
timer to X + rand(Interval-X) and not a table of fixed intervals
as in the original patch. For v2, X=1 or 2 sec and Interval=10
might work well, but for v3, the entire interval is 1 sec and I
think I saw that the set-up time for the fabric may be on the
order of 1 sec.
        I also don't think that we want those kinds of delays on
Ethernet. A program may join and send lots of traffic in 1 sec,
and if the immediate join is lost, one of the quickly-following
<1 sec duplicate reports will make it recover and work. Delaying
the minimum would guarantee it wouldn't work until that minimum
and drop all that traffic if the immediate report is lost, then.
        Really, of course, I think the solution belongs in IB, but
if we did anything in IGMP, I'd prefer it were a per-interface
tunable that defaults as in the RFC. Since you can change the
interval and # of reports through a querier now, exporting the
default values of (10,2) for v2 and (1,2) for v3 to instead be
per-interface tunables and then bumped as needed for IB would
allow tweaking without running a querier. But a querier that's
using default values would also override that and cause the
problem all over again. Queuing in the driver until the MAC
address is usable solves it generally.

        Also, MLD and IPv6 will have all these same issues, and
working multicasting is even more important there.

                                                                +-DLS


--
To unsubscribe from this list: send the line "unsubscribe linux-rdma" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
