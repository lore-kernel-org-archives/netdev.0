From: Anton Vorontsov <avorontsov@ru.mvista.com>
Subject: Re: [PATCH v2] netpoll: Introduce netpoll_carrier_timeout kernel
 option
Date: Wed, 8 Jul 2009 16:23:17 +0400
Message-ID: <20090708122317.GA7837@oksana.dev.rtsoft.ru>
References: <20090708010030.GA26331@oksana.dev.rtsoft.ru>
 <20090707180354.2f203648@nehalam>
 <20090708013011.GA30330@oksana.dev.rtsoft.ru>
 <20090708105902.GB6000@hmsreliant.think-freely.org>
Reply-To: avorontsov@ru.mvista.com
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Neil Horman <nhorman@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ru.mvista.com ([213.79.90.228]:46037 "EHLO
	buildserver.ru.mvista.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1755907AbZGHMXT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 08:23:19 -0400
Content-Disposition: inline
In-Reply-To: <20090708105902.GB6000@hmsreliant.think-freely.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2009 at 06:59:02AM -0400, Neil Horman wrote:
[...]
> > diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> > index d77fbd8..9347f4a 100644
> > --- a/Documentation/kernel-parameters.txt
> > +++ b/Documentation/kernel-parameters.txt
> > @@ -1531,6 +1531,11 @@ and is between 256 and 4096 characters. It is defined in the file
> >  			symbolic names: lapic and ioapic
> >  			Example: nmi_watchdog=2 or nmi_watchdog=panic,lapic
> >  
> > +	netpoll.carrier_timeout=
> > +			[NET] Specifies amount of time (in seconds) that
> > +			netpoll should wait for a carrier. By default netpoll
> > +			waits 4 seconds.
> > +
> I'm not sure the documentation still belongs in kernel-parameters.txt if you
> make this a module options, but thats just a nit.

There are other module options described in the
kernel-parameters.txt. Plus it's really a kernel parameter. ;-)

> >  
> > +#include <linux/moduleparam.h>
> >  #include <linux/netdevice.h>
> >  #include <linux/etherdevice.h>
> >  #include <linux/string.h>
> > @@ -50,6 +51,9 @@ static atomic_t trapped;
> >  static void zap_completion_queue(void);
> >  static void arp_reply(struct sk_buff *skb);
> >  
> > +static unsigned int carrier_timeout = 4;
> > +module_param(carrier_timeout, uint, 0644);
> > +
> >  static void queue_process(struct work_struct *work)
> >  {
> >  	struct netpoll_info *npinfo =
> > @@ -732,7 +736,7 @@ int netpoll_setup(struct netpoll *np)
> >  		}
> >  
> >  		atleast = jiffies + HZ/10;
> > -		atmost = jiffies + 4*HZ;
> > +		atmost = jiffies + carrier_timeout * HZ;
> >  		while (!netif_carrier_ok(ndev)) {
> >  			if (time_after(jiffies, atmost)) {
> >  				printk(KERN_NOTICE
> > -- 
> > 1.6.3.3
> > 
> I don't mind this functionality at all, but I'm looking at the code, and I have
> a hard time understanding why we bring up an interface here at all.  I get that
> we might want early netpoll access for netconsole or something like that, but
> looking at the console code I don't see where we buffer anything other than the
> standard dmesg log.  I don't see much reason why we can't just let normal early
> interface initalization from an initramfs bring up an interface like it normally
> does.

The earlier you bring the interface up, the earlier you'll able
to catch kernel oopses. netconsole is quite useful when
you don't have serial ports. The same applies for KGDBoE --
you might want to start debugging the kernel as soon as possible.

Sure, netconsole starts at module_init(), but looking at my dmesg,
netconsole initialization starts closer to the top of the log, so
it'll catch > 60% of oopses, i.e. all oopses in subsystems
that are below net/ in drivers/Makefile.

Thanks,

-- 
Anton Vorontsov
email: cbouatmailru@gmail.com
irc://irc.freenode.net/bd2
