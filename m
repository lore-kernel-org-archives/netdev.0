From: Paul Bolle <pebolle@tiscali.nl>
Subject: Re: [PATCH 08/12] fsl/fman: Add Frame Manager support
Date: Thu, 11 Jun 2015 11:37:49 +0200
Message-ID: <1434015469.2271.83.camel@x220>
References: <1433949712-5648-1-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-2-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-3-git-send-email-madalin.bucur@freescale.com>
	 <1433949712-5648-4-git-send-email-madalin.bucur@freescale.com>
	 <1434012956.2271.58.camel@x220>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	linuxppc-dev@lists.ozlabs.org, scottwood@freescale.com,
	Igal Liberman <Igal.Liberman@freescale.com>
To: madalin.bucur@freescale.com
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1434012956.2271.58.camel@x220>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

So I couldn't help having yet another look at the code, just to drive
home my point.

On Thu, 2015-06-11 at 10:55 +0200, Paul Bolle wrote:
> > +void *fm_drv_init(void)
> 
> static.
> 
> > +{
> > +	memset(&fm_drvs, 0, sizeof(fm_drvs));

fm_drvs is an external variable. It is guaranteed to be zero, isn't it?

> > +	mutex_init(&fm_drv_mutex);
> > +
> > +	/* Register to the DTB for basic FM API */
> > +	platform_driver_register(&fm_driver);
> > +
> > +	return &fm_drvs;

You're returning a pointer to external variable. How's that useful?

And note this is the last time we'll ever see fm_drvs. So I think that
all this variable does for the code is getting initialized to zero,
twice.

> > +}
> > +
> > +int fm_drv_free(void *p_fm_drv)
> 
> static.
> 
> > +{
> > +	platform_driver_unregister(&fm_driver);
> > +	mutex_destroy(&fm_drv_mutex);
> > +
> > +	return 0;

This function has one caller, which doesn't check the return value. So
this should be a function returning void. Of course, a wrapper of two
lines called only once means you should actually not put this into a
separate function.

> > +}

> > +static void *p_fm_drv;
> 
> > +static int __init __cold fm_load(void)
> > +{
> > +	p_fm_drv = fm_drv_init();
> > +	if (!p_fm_drv) {

fm_drv_init() returns a pointer to an external variable. So how can this
happen?

> > +		pr_err("Failed to init FM wrapper!\n");
> > +		return -ENODEV;
> > +	}
> > +
> > +	pr_info("Freescale FM module\n");
> > +	return 0;
> > +}

This is all rather basic. It must be, otherwise I wouldn't spot it.

So I keep spotting these basic oddities, with every cup of coffee I
treat myself to while reading through this, wherever I look. By now I'm
sure there's no need for the netdev people to look at this, not yet. 


Paul Bolle
