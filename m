From: Ben Greear <greearb@candelatech.com>
Subject: Re: Leaked net-device reference in eql.c
Date: Fri, 26 Aug 2005 23:24:09 -0700
Message-ID: <43100709.1090800@candelatech.com>
References: <430FAF0D.5050000@candelatech.com> <430FE01E.9020600@trash.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: "'netdev@oss.sgi.com'" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Patrick McHardy <kaber@trash.net>
In-Reply-To: <430FE01E.9020600@trash.net>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Patrick McHardy wrote:
> Ben Greear wrote:
> 
>> I think the eql_s_slave_cfg method in eql.c leaks
>> the reference to slave_dev.  Am I missing something?
> 
> 
> No, it should also put the device, as in eql_g_slave_cfg.

Ok, I'm making a patch...will add this to it.

How about this one.  It seems like it does a dev_put when it shouldn't
(if some of the if's fail, the dev_get never happened):

net/sched/sch_generic.c

static void dev_watchdog(unsigned long arg)
{
	struct net_device *dev = (struct net_device *)arg;

	spin_lock(&dev->xmit_lock);
	if (dev->qdisc != &noop_qdisc) {
		if (netif_device_present(dev) &&
		    netif_running(dev) &&
		    netif_carrier_ok(dev)) {
			if (netif_queue_stopped(dev) &&
			    (jiffies - dev->trans_start) > dev->watchdog_timeo) {
				printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n", dev->name);
				dev->tx_timeout(dev);
			}
			if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
				dev_hold(dev);
		}
	}
	spin_unlock(&dev->xmit_lock);

	dev_put(dev);
}



-- 
Ben Greear <greearb@candelatech.com>
Candela Technologies Inc  http://www.candelatech.com
