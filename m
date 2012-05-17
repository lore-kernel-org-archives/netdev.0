From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH v2] drop_monitor: convert to modular building
Date: Thu, 17 May 2012 19:14:05 +0100
Message-ID: <1337278445.2496.17.camel@bwh-desktop.uk.solarflarecom.com>
References: <1337178426-2470-1-git-send-email-nhorman@tuxdriver.com>
	 <1337276940-5025-1-git-send-email-nhorman@tuxdriver.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>, "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:10731 "EHLO
	ocex02.SolarFlarecom.com" rhost-flags-OK-OK-OK-FAIL)
	by vger.kernel.org with ESMTP id S1754980Ab2EQSOK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 17 May 2012 14:14:10 -0400
In-Reply-To: <1337276940-5025-1-git-send-email-nhorman@tuxdriver.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, 2012-05-17 at 13:49 -0400, Neil Horman wrote:
> When I first wrote drop monitor I wrote it to just build monolithically.  There
> is no reason it can't be built modularly as well, so lets give it that
> flexibiity.
> 
> I've tested this by building it as both a module and monolithically, and it
> seems to work quite well
> 
> Change notes:
> 
> v2)
> * fixed for_each_present_cpu loops to be more correct as per Eric D.
> * Converted exit path failures to BUG_ON as per Ben H.

Sorry I didn't pick up on this the first time:

[...]
> -late_initcall(init_net_drop_monitor);
> +static void exit_net_drop_monitor(void)
> +{
> +	struct per_cpu_dm_data *data;
> +	int cpu;
> +
> +	BUG_ON(unregister_netdevice_notifier(&dropmon_net_notifier));
> +
> +	/*
> +	 * Because of the module_get/put we do in the trace state change path
> +	 * we are guarnateed not to have any current users when we get here
> +	 * all we need to do is make sure that we don't have any running timers
> +	 * or pending schedule calls
> +	 */
> +
> +	for_each_possible_cpu(cpu) {
> +		data = &per_cpu(dm_cpu_data, cpu);
> +		del_timer(&data->send_timer);

Doesn't this need to be del_timer_sync()?

Ben.

> +		cancel_work_sync(&data->dm_alert_work);
> +		/*
> +		 * At this point, we should have exclusive access
> +		 * to this struct and can free the skb inside it
> +		 */
> +		kfree_skb(data->skb);
> +	}
> +
> +	BUG_ON(genl_unregister_family(&net_drop_monitor_family));
> +}
> +
> +module_init(init_net_drop_monitor);
> +module_exit(exit_net_drop_monitor);
> +
> +MODULE_LICENSE("GPL v2");
> +MODULE_AUTHOR("Neil Horman <nhorman@tuxdriver.com>");

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
