From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] drop_monitor: convert to modular building
Date: Wed, 16 May 2012 11:19:32 -0400
Message-ID: <20120516151932.GB30195@hmsreliant.think-freely.org>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
 <1337180505.2568.10.camel@bwh-desktop.uk.solarflarecom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, "David S. Miller" <davem@davemloft.net>
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:48735 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754118Ab2EPPTk (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 May 2012 11:19:40 -0400
Content-Disposition: inline
In-Reply-To: <1337180505.2568.10.camel@bwh-desktop.uk.solarflarecom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 16, 2012 at 04:01:45PM +0100, Ben Hutchings wrote:
> On Wed, 2012-05-16 at 10:27 -0400, Neil Horman wrote:
> > When I first wrote drop monitor I wrote it to just build monolithically.  There
> > is no reason it can't be built modularly as well, so lets give it that
> > flexibiity.
> 
> Yes, please.
> 
> [...]
> > --- a/net/core/drop_monitor.c
> > +++ b/net/core/drop_monitor.c
> > @@ -22,6 +22,7 @@
> >  #include <linux/timer.h>
> >  #include <linux/bitops.h>
> >  #include <linux/slab.h>
> > +#include <linux/module.h>
> >  #include <net/genetlink.h>
> >  #include <net/netevent.h>
> >  
> > @@ -223,9 +224,15 @@ static int set_all_monitor_traces(int state)
> >  
> >  	switch (state) {
> >  	case TRACE_ON:
> > +		if (!try_module_get(THIS_MODULE)) {
> > +			rc = -EINVAL;
> 
> Minor issue, but this isn't the right error code - there is nothing
> invalid about the request, it just came at the wrong time.  Perhaps
> ENODEV or ECANCELED?
> 
Yeah, ok, ENODEV seems reasonable.

> > +			break;
> > +		}
> > +
> >  		rc |= register_trace_kfree_skb(trace_kfree_skb_hit, NULL);
> >  		rc |= register_trace_napi_poll(trace_napi_poll_hit, NULL);
> >  		break;
> > +
> >  	case TRACE_OFF:
> >  		rc |= unregister_trace_kfree_skb(trace_kfree_skb_hit, NULL);
> >  		rc |= unregister_trace_napi_poll(trace_napi_poll_hit, NULL);
> > @@ -241,6 +248,9 @@ static int set_all_monitor_traces(int state)
> >  				kfree_rcu(new_stat, rcu);
> >  			}
> >  		}
> > +
> > +		module_put(THIS_MODULE);
> > +
> >  		break;
> >  	default:
> >  		rc = 1;
> > @@ -383,4 +393,38 @@ out:
> >  	return rc;
> >  }
> >  
> > -late_initcall(init_net_drop_monitor);
> > +static void exit_net_drop_monitor(void)
> > +{
> > +	struct per_cpu_dm_data *data;
> > +	int cpu;
> > +
> > +	if (unregister_netdevice_notifier(&dropmon_net_notifier))
> > +		printk(KERN_WARNING "Unable to unregiser dropmon notifer\n");
> 
> Currently this will only fail if you didn't actually register the
> notifier, which would be a bug.  If there is ever any other reason this
> could fail, continuing with the notifier still registered would be
> disastrous.  Therefore I think this should be:
> 
> 	rc = unregister_netdevice_notifier(&dropmon_net_notifier);
> 	BUG_ON(rc);
> 
Ok, seems reasonable.

> > +	/*
> > +	 * Because of the module_get/put we do in the trace state change path
> > +	 * we are guarnateed not to have any current users when we get here
> > +	 * all we need to do is make sure that we don't have any running timers
> > +	 * or pending schedule calls
> > +	 */
> 
> Surely you need to call set_all_monitor_traces(TRACE_OFF) first...
> 
Nope, If you'll note the code higher up in the patch, I use try_module_get and
module_put to prevent the module unload code from getting here while anyone is
actually using the protocol.  Once we are in the module remove routine here, we
are guaranateed that there are no users of this protocol, and that the
tracepoints are all unregistered.

> > +	for_each_present_cpu(cpu) {
> > +		data = &per_cpu(dm_cpu_data, cpu);
> > +		del_timer(&data->send_timer);
> > +		cancel_work_sync(&data->dm_alert_work);
> > +		/*
> > +		 * At this point, we should have exclusive access
> > +		 * to this struct and can free the skb inside it
> > +		 */
> > +		kfree_skb(data->skb);
> > +	}
> > +
> > +	if (genl_unregister_family(&net_drop_monitor_family))
> > +		printk(KERN_WARNING "Unable to unregister drop monitor socket family\n");
> 
> Same issue as with unregister_netdevice_notifier().
> 
ack, I'll update that to a BUG_ON
Neil
