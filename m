From: Russell King <rmk+lkml@arm.linux.org.uk>
Subject: Re: [RFC] Suspicious bug in module refcounting
Date: Wed, 4 Feb 2009 10:59:36 +0000
Message-ID: <20090204105936.GA20410@flint.arm.linux.org.uk>
References: <20090203134721.GA11069@pingi.kke.suse.de> <200902041418.09630.rusty@rustcorp.com.au> <20090204101130.GB19498@flint.arm.linux.org.uk> <200902042125.48723.rusty@rustcorp.com.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Karsten Keil <kkeil@suse.de>, linux-kernel@vger.kernel.org,
	Michal Hocko <mhocko@suse.cz>,
	richard kennedy <richard@rsk.demon.co.uk>,
	Dan Williams <dan.j.williams@intel.com>,
	Dmitry Torokhov <dmitry.torokhov@gmail.com>,
	dwmw2@infradead.org, Scott Wood <scottwood@freescale.com>,
	netdev@vger.kernel.org, Al Viro <viro@zeniv.linux.org.uk>
To: Rusty Russell <rusty@rustcorp.com.au>, alex@shark-linux.de
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755526AbZBDLAi@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <200902042125.48723.rusty@rustcorp.com.au>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Adding Alexander Schulz who can comment on the correctness of your patch
for Shark.

On Wed, Feb 04, 2009 at 09:25:47PM +1030, Rusty Russell wrote:
> On Wednesday 04 February 2009 20:41:30 Russell King wrote:
> > On Wed, Feb 04, 2009 at 02:18:08PM +1030, Rusty Russell wrote:
> > >   gameport.c, serio.c and input.c increment their own refcount, but to get
> > > into those init functions someone must be holding a refcount already (ie. a
> > > module depends on this module).  Ditto cyber2000fb.c, and MTD.
> > 
> > Err, wrong.  cyber2000fb.c does it in its module initialization function
> > to prevent the module (when built for Shark) from being unloaded.  It
> > does this because it's from the days of 2.2 kernels and no one bothered
> > writing the module unload support for Shark.  I'm certainly not in a
> > position to do that.
> 
> Thanks, here's the patch then:
> 
> Subject: cyber2000fb.c: use proper method for stopping unload if CONFIG_ARCH_SHARK
> 
> Russell explains the __module_get():
> > cyber2000fb.c does it in its module initialization function
> > to prevent the module (when built for Shark) from being unloaded.  It
> > does this because it's from the days of 2.2 kernels and no one bothered
> > writing the module unload support for Shark.
> 
> Since 2.4, the correct answer has been to not define an unload fn.
> 
> Cc: Russell King <rmk+lkml@arm.linux.org.uk>
> Signed-off-by: Rusty Russell <rusty@rustcorp.com.au>
> 
> diff --git a/drivers/video/cyber2000fb.c b/drivers/video/cyber2000fb.c
> --- a/drivers/video/cyber2000fb.c
> +++ b/drivers/video/cyber2000fb.c
> @@ -1736,10 +1736,8 @@ static int __init cyber2000fb_init(void)
>  
>  #ifdef CONFIG_ARCH_SHARK
>  	err = cyberpro_vl_probe();
> -	if (!err) {
> +	if (!err)
>  		ret = 0;
> -		__module_get(THIS_MODULE);
> -	}
>  #endif
>  #ifdef CONFIG_PCI
>  	err = pci_register_driver(&cyberpro_driver);
> @@ -1749,14 +1747,15 @@ static int __init cyber2000fb_init(void)
>  
>  	return ret ? err : 0;
>  }
> +module_init(cyber2000fb_init);
>  
> +#ifndef CONFIG_ARCH_SHARK
>  static void __exit cyberpro_exit(void)
>  {
>  	pci_unregister_driver(&cyberpro_driver);
>  }
> -
> -module_init(cyber2000fb_init);
>  module_exit(cyberpro_exit);
> +#endif
>  
>  MODULE_AUTHOR("Russell King");
>  MODULE_DESCRIPTION("CyberPro 2000, 2010 and 5000 framebuffer driver");

-- 
Russell King
 Linux kernel    2.6 ARM Linux   - http://www.arm.linux.org.uk/
 maintainer of:
