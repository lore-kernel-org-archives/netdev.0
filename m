From: Arnaldo Carvalho de Melo <arnaldo.melo@gmail.com>
Subject: Re: Leaked net-device reference in eql.c
Date: Sat, 27 Aug 2005 06:37:17 -0300
Message-ID: <39e6f6c705082702372dbc902d@mail.gmail.com>
References: <430FAF0D.5050000@candelatech.com> <430FE01E.9020600@trash.net>
	 <43100709.1090800@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 8bit
Cc: Patrick McHardy <kaber@trash.net>,
        "netdev@oss.sgi.com" <netdev@oss.sgi.com>
Return-path: <netdev-bounce@oss.sgi.com>
To: Ben Greear <greearb@candelatech.com>
In-Reply-To: <43100709.1090800@candelatech.com>
Content-Disposition: inline
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

On 8/27/05, Ben Greear <greearb@candelatech.com> wrote:
> Patrick McHardy wrote:
> > Ben Greear wrote:
> >
> >> I think the eql_s_slave_cfg method in eql.c leaks
> >> the reference to slave_dev.  Am I missing something?
> >
> >
> > No, it should also put the device, as in eql_g_slave_cfg.
> 
> Ok, I'm making a patch...will add this to it.
> 
> How about this one.  It seems like it does a dev_put when it shouldn't
> (if some of the if's fail, the dev_get never happened):
> 
> net/sched/sch_generic.c
> 
> static void dev_watchdog(unsigned long arg)
> {
>         struct net_device *dev = (struct net_device *)arg;
> 
>         spin_lock(&dev->xmit_lock);
>         if (dev->qdisc != &noop_qdisc) {
>                 if (netif_device_present(dev) &&
>                     netif_running(dev) &&
>                     netif_carrier_ok(dev)) {
>                         if (netif_queue_stopped(dev) &&
>                             (jiffies - dev->trans_start) > dev->watchdog_timeo) {
>                                 printk(KERN_INFO "NETDEV WATCHDOG: %s: transmit timed out\n", dev->name);
>                                 dev->tx_timeout(dev);
>                         }
>                         if (!mod_timer(&dev->watchdog_timer, jiffies + dev->watchdog_timeo))
>                                 dev_hold(dev);
>                 }
>         }
>         spin_unlock(&dev->xmit_lock);
> 
>         dev_put(dev);
> }

Doesn't look like its a problem, its the classical case where when you
associate some data structure to a timer you grab a refcount, when the
timer expires you drop the refcount, and as the code above shows when
mod_timer is succesfully called it grabs a reference, so the reference
being dropped above is from the previous timer firing, now its just a matter
if looking for the first mod_timer, that must be at some other place in
sched_generic.c, lemme see...
