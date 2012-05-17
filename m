From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] drop_monitor: convert to modular building
Date: Thu, 17 May 2012 15:33:00 -0400
Message-ID: <20120517193300.GA19321@hmsreliant.think-freely.org>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
 <1337276940-5025-1-git-send-email-nhorman@tuxdriver.com>
 <1337278445.2496.17.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:38800 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759674Ab2EQTdI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 15:33:08 -0400
Content-Disposition: inline
In-Reply-To: <1337278445.2496.17.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 17, 2012 at 07:14:05PM +0100, Ben Hutchings wrote:
> On Thu, 2012-05-17 at 13:49 -0400, Neil Horman wrote:
> > When I first wrote drop monitor I wrote it to just build monolithically.  There
> > is no reason it can't be built modularly as well, so lets give it that
> > flexibiity.
> > 
> > I've tested this by building it as both a module and monolithically, and it
> > seems to work quite well
> > 
> > Change notes:
> > 
> > v2)
> > * fixed for_each_present_cpu loops to be more correct as per Eric D.
> > * Converted exit path failures to BUG_ON as per Ben H.
> 
> Sorry I didn't pick up on this the first time:
> 
> [...]
> > -late_initcall(init_net_drop_monitor);
> > +static void exit_net_drop_monitor(void)
> > +{
> > +	struct per_cpu_dm_data *data;
> > +	int cpu;
> > +
> > +	BUG_ON(unregister_netdevice_notifier(&dropmon_net_notifier));
> > +
> > +	/*
> > +	 * Because of the module_get/put we do in the trace state change path
> > +	 * we are guarnateed not to have any current users when we get here
> > +	 * all we need to do is make sure that we don't have any running timers
> > +	 * or pending schedule calls
> > +	 */
> > +
> > +	for_each_possible_cpu(cpu) {
> > +		data = &per_cpu(dm_cpu_data, cpu);
> > +		del_timer(&data->send_timer);
> 
> Doesn't this need to be del_timer_sync()?
> 
Yeah, good catch.  I was thinking it didn't need to be as the timer doesn't
re-arm itself and the cancel_work_sync would undo anything that a running timer
did, but thinking about it, its possible that a timer could fire on cpu A, and
cpu B could execute and complete the cancel_work_sync prior to cpu A scheduling
it, so there is a race window there.  I'll fix that up.
Neil
 
