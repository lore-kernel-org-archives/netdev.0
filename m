From: Karsten Keil <kkeil@suse.de>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Fri, 6 Feb 2009 23:41:00 +0100
Message-ID: <20090206224059.GA9080@pingi.kke.suse.de>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, Michal Hocko <mhocko@suse.cz>,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	Russell King <rmk+kernel@arm.linux.org.uk>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>,
	gregkh@suse.de
To: Rusty Russell <rusty@rustcorp.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ns2.suse.de ([195.135.220.15]:33333 "EHLO mx2.suse.de"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751986AbZBFWlG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Fri, 6 Feb 2009 17:41:06 -0500
Content-Disposition: inline
In-Reply-To: <200902041418.09630.rusty@rustcorp.com.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Rusty,

On Wed, Feb 04, 2009 at 02:18:08PM +1030, Rusty Russell wrote:
> On Wednesday 04 February 2009 00:17:21 Karsten Keil wrote:
> > The refcount is a per CPU atomic variable, module_refcount() simple add
> > in a fully unprotected loop (not disabled irqs, not protected against
> > scheduling) all per cpu values.
> 
> Hi Karsten,
> 
>    Yes, the BUG_ON() is overly aggressive.  And I really hate __module_get,
> and it looks like most of the callers are completely bogus.  The watchdog
> drivers use it to nail themselves in place in their open routines: this is
> OK, if a bit weird.
> 

...
> 
> Meanwhile, I'll remove the BUG_ON for 2.6.29.
> 
> Thanks,
> Rusty.

Seems that this was not picked up yet for 2.6.29, but I think it really should
go in random triggering BUG() is not very nice, maybe it should also added to
the stable trees.

Can you please submit it again ?

> 
> module: remove over-zealous check in __module_get()
> 
> module_refcount() isn't reliable outside stop_machine(), as demonstrated
> by Karsten Keil <kkeil@suse.de>, networking can trigger it under load
> (an inc on one cpu and dec on another while module_refcount() is tallying
>  can give false results, for example).
> 
> Almost noone should be using __module_get, but that's another issue.
> 
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> diff --git a/include/linux/module.h b/include/linux/module.h
> --- a/include/linux/module.h
> +++ b/include/linux/module.h
> @@ -407,7 +407,6 @@ static inline void __module_get(struct m
>  static inline void __module_get(struct module *module)
>  {
>  	if (module) {
> -		BUG_ON(module_refcount(module) == 0);
>  		local_inc(__module_ref_addr(module, get_cpu()));
>  		put_cpu();
>  	}
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at  http://www.tux.org/lkml/

-- 
Karsten Keil
SuSE Labs
ISDN and VOIP development
SUSE LINUX Products GmbH, Maxfeldstr.5 90409 Nuernberg, GF: Markus Rex, HRB 16746 (AG Nuernberg)
