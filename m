From: Cyrill Gorcunov <gorcunov-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: Mark IPW2100 as BROKEN: Fatal interrupt. Scheduling firmware
	restart.
Date: Mon, 22 Sep 2008 00:05:18 +0400
Message-ID: <20080921200518.GK7736@localhost>
References: <20080921172316.GA6306@2ka.mipt.ru> <20080921110422.1d010b96@infradead.org> <20080921182835.GA11473@2ka.mipt.ru> <20080921113513.16677c4e@infradead.org> <20080921190050.GA20484@2ka.mipt.ru> <1222024444.3023.53.camel@johannes.berg> <20080921193809.GA8735@2ka.mipt.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Arjan van de Ven <arjan-wEGCiKHe2LqWVfeAwA7xHQ@public.gmane.org>,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	ipw2100-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org,
	linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, yi.zhu-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org,
	reinette.chatre-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org, jgarzik-e+AXbWqSrlAAvxtiuMwx3w@public.gmane.org,
	linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org, davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
To: Evgeniy Polyakov <johnpol-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Content-Disposition: inline
In-Reply-To: <20080921193809.GA8735-9fLWQ3dKdXwox3rIn2DAYQ@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

[Evgeniy Polyakov - Sun, Sep 21, 2008 at 11:38:09PM +0400]
| Hi.
| 
| On Sun, Sep 21, 2008 at 09:14:04PM +0200, Johannes Berg (johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org) wrote:
| > > Do you want me to implement ipw2100 driver as a big work structure
| > > which will run ipw2100_init()/wait/ipw2100_exit() in a loop?
| > > And that will be the fix suggested by Intel? That would explain a lot.
| > 
| > I think what Arjan is saying is that it would be better to put pressure
| > on the responsible folks (I don't think Arjan is anywhere near them at
| 
| Both maintainers were added to the copy list.
| 
| > all) if you'd put in a WARN_ON() for this error and that would make the
| > top entry on kerneloops.org all the time... And additionally put in a
| > workaround for yourself for now.
| 
| As I pointed, I can rewrite the whole driver's initialization process,
| so that it looked like init/wait/exit loop, which can be processed at
| the module load and when fatal interrupt fires. Do this a fix? This is
| not even a remotely workaround. We can just add
| rmmod/modprobe/ifdown/ifup to the crontab job. Another users reported in
| bugzilla that they needed to reboot a machine to make card working
| again. I'm not sure that user tried to do a rmmod/modprobe though.
| 
| > And can we keep the flames off this list please? That comment from Wei
| > Weng was absolutely uncalled for, and inciting a flamewar (as you have
| > already blogged) was not really productive either.
| 
| If we will keep silence, no one will notice that problem exists.
| 
| I do hope this will result in a progress. Arjan, do you aggree to add
| this patch to the current tree?
| 
| diff --git a/drivers/net/wireless/ipw2100.c b/drivers/net/wireless/ipw2100.c
| index 19a401c..9a7b64c 100644
| --- a/drivers/net/wireless/ipw2100.c
| +++ b/drivers/net/wireless/ipw2100.c
| @@ -206,6 +206,8 @@ MODULE_PARM_DESC(disable, "manually disable the radio (default 0 [radio on])");
|  
|  static u32 ipw2100_debug_level = IPW_DL_NONE;
|  
| +static int ipw2100_max_fatal_ints = 10;
| +
|  #ifdef CONFIG_IPW2100_DEBUG
|  #define IPW_DEBUG(level, message...) \
|  do { \
| @@ -3174,6 +3176,10 @@ static void ipw2100_irq_tasklet(struct ipw2100_priv *priv)
|  	if (inta & IPW2100_INTA_FATAL_ERROR) {
|  		printk(KERN_WARNING DRV_NAME
|  		       ": Fatal interrupt. Scheduling firmware restart.\n");
| +		WARN_ON(1);
| +
| +		BUG_ON(ipw2100_max_fatal_ints-- <= 0);
| +
|  		priv->inta_other++;
|  		write_register(dev, IPW_REG_INTA, IPW2100_INTA_FATAL_ERROR);
|  
| 
| 
| -- 
| 	Evgeniy Polyakov
| 

Since it's that serious maybe we should change

		IPW_DEBUG_INFO("%s: Fatal error value: 0x%08X\n",
			       priv->net_dev->name, priv->fatal_error);

to printk(KERN_WARN)? And here is why - as I see now we can't say what
exactly is wrong - Evgeniy said he has a suspicious about firmware so
this WARNS will be collected by Arjan thru kerneloops and we could not
ask users to change debug level and repost problem - oops will have it
by default - and if it really firmware problem - firmware engineers could
find this _additional_ info usefull and resolve it (probably).

		- Cyrill -
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
