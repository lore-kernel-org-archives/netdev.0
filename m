From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH v2] netpoll: Introduce netpoll_carrier_timeout kernel
	option
Date: Wed, 8 Jul 2009 06:59:02 -0400
Message-ID: <20090708105902.GB6000@hmsreliant.think-freely.org>
References: <20090708010030.GA26331@oksana.dev.rtsoft.ru> <20090707180354.2f203648@nehalam> <20090708013011.GA30330@oksana.dev.rtsoft.ru>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Stephen Hemminger <shemminger@vyatta.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Anton Vorontsov <avorontsov@ru.mvista.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:46146 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751443AbZGHK7P (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Jul 2009 06:59:15 -0400
Content-Disposition: inline
In-Reply-To: <20090708013011.GA30330@oksana.dev.rtsoft.ru>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Jul 08, 2009 at 05:30:11AM +0400, Anton Vorontsov wrote:
> Some PHYs require longer timeouts for carrier detection, and
> auto-negotiation process may take indefinite amount of time.
> 
> It may be inconvenient to force longer timeouts for sane PHYs,
> so let's introduce a kernel command line option.
> 
> Since we're using module_param(), the option also can be
> changed in runtime.
> 
> Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> ---
> 
> On Tue, Jul 07, 2009 at 06:03:54PM -0700, Stephen Hemminger wrote:
> > On Wed, 8 Jul 2009 05:00:30 +0400
> > Anton Vorontsov <avorontsov@ru.mvista.com> wrote:
> > 
> > > Some PHYs require longer timeouts for carrier detection, and
> > > auto-negotiation process may take indefinite amount of time.
> > > 
> > > It may be inconvenient to force longer timeouts for sane PHYs,
> > > so let's introduce a kernel command line option.
> > > 
> > > Signed-off-by: Anton Vorontsov <avorontsov@ru.mvista.com>
> > > ---
> > >  Documentation/kernel-parameters.txt |    5 +++++
> > >  net/core/netpoll.c                  |   11 ++++++++++-
> > >  2 files changed, 15 insertions(+), 1 deletions(-)
> > 
> > A sysctl (or module option) is a less awkward interface for something
> > like this.
> 
> Right you are, and it's less code. Wasn't sure if it makes sense
> to use module_param() for non-modular code, but afterall it makes
> sense indeed, since with it we can change the timeout in runtime.
> 
> > Kernel command line parameters are ugly step children
> > loved only by embedded developers.
> 
> So true! ;-)
> 
> How about this patch?
> 
> Thanks,
> 
>  Documentation/kernel-parameters.txt |    5 +++++
>  net/core/netpoll.c                  |    6 +++++-
>  2 files changed, 10 insertions(+), 1 deletions(-)
> 
> diff --git a/Documentation/kernel-parameters.txt b/Documentation/kernel-parameters.txt
> index d77fbd8..9347f4a 100644
> --- a/Documentation/kernel-parameters.txt
> +++ b/Documentation/kernel-parameters.txt
> @@ -1531,6 +1531,11 @@ and is between 256 and 4096 characters. It is defined in the file
>  			symbolic names: lapic and ioapic
>  			Example: nmi_watchdog=2 or nmi_watchdog=panic,lapic
>  
> +	netpoll.carrier_timeout=
> +			[NET] Specifies amount of time (in seconds) that
> +			netpoll should wait for a carrier. By default netpoll
> +			waits 4 seconds.
> +
I'm not sure the documentation still belongs in kernel-parameters.txt if you
make this a module options, but thats just a nit.



>  
> +#include <linux/moduleparam.h>
>  #include <linux/netdevice.h>
>  #include <linux/etherdevice.h>
>  #include <linux/string.h>
> @@ -50,6 +51,9 @@ static atomic_t trapped;
>  static void zap_completion_queue(void);
>  static void arp_reply(struct sk_buff *skb);
>  
> +static unsigned int carrier_timeout = 4;
> +module_param(carrier_timeout, uint, 0644);
> +
>  static void queue_process(struct work_struct *work)
>  {
>  	struct netpoll_info *npinfo =
> @@ -732,7 +736,7 @@ int netpoll_setup(struct netpoll *np)
>  		}
>  
>  		atleast = jiffies + HZ/10;
> -		atmost = jiffies + 4*HZ;
> +		atmost = jiffies + carrier_timeout * HZ;
>  		while (!netif_carrier_ok(ndev)) {
>  			if (time_after(jiffies, atmost)) {
>  				printk(KERN_NOTICE
> -- 
> 1.6.3.3
> 
I don't mind this functionality at all, but I'm looking at the code, and I have
a hard time understanding why we bring up an interface here at all.  I get that
we might want early netpoll access for netconsole or something like that, but
looking at the console code I don't see where we buffer anything other than the
standard dmesg log.  I don't see much reason why we can't just let normal early
interface initalization from an initramfs bring up an interface like it normally
does.

Neil

> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> 
