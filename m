From: Joe Perches <joe@perches.com>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Wed, 07 Jul 2010 21:13:42 -0700
Message-ID: <1278562423.1712.43.camel@Joe-Laptop>
References: <20100706142542.d723903f.sfr@canb.auug.org.au>
	 <20100707.174522.148565561.davem@davemloft.net>
	 <20100707.181847.62350965.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: sfr@canb.auug.org.au, netdev@vger.kernel.org,
	linux-next@vger.kernel.org, linux-kernel@vger.kernel.org,
	gregkh@suse.de
To: David Miller <davem@davemloft.net>
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100707.181847.62350965.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, 2010-07-07 at 18:18 -0700, David Miller wrote:
> From: David Miller <davem@davemloft.net>
> Date: Wed, 07 Jul 2010 17:45:22 -0700 (PDT)
> > From: Stephen Rothwell <sfr@canb.auug.org.au>
> > Date: Tue, 6 Jul 2010 14:25:42 +1000
> >> After merging the net tree, today's linux-next build (powerpc
> >> ppc64_defconfig) produced these warnings:
> >> drivers/scsi/sym53c8xx_2/sym_hipd.c: In function 'sym_print_msg':
> >> drivers/scsi/sym53c8xx_2/sym_hipd.c:78: warning: zero-length gnu_printf format string
> > Thanks Stephen I'll look into this.
> Yeah this is a bit ugly.
> 
> It used to be that the dev_*() format string was CPP pasted to whatever
> format string the user gave.  So if the user gave an empty string it
> still looked like a non-empty printf string.
> 
> But that no longer happens because we hide the implementation, and thus
> the top-level printf format string, in the external functions.
> 
> It seems the construction:
> 
> /*
>  * Stupid hackaround for existing uses of non-printk uses dev_info
>  *
>  * Note that the definition of dev_info below is actually _dev_info
>  * and a macro is used to avoid redefining dev_info
>  */
> 
> #define dev_info(dev, fmt, arg...) _dev_info(dev, fmt, ##arg)
> 
> added to linux/device.h was meant to handle these cases, but as we see
> it doesn't.

Nope, the _dev_info/dev_info is meant to handle the
current uses of dev_info as a variable like this one:

$ grep dev_info drivers/net/pcmcia/pcnet_cs.c
static dev_info_t dev_info = "pcnet_cs";
    ret = request_irq(dev->irq, ei_irq_wrapper, IRQF_SHARED, dev_info, dev);

Without the _dev_info and dev_info as a macro,
the function is redefined as a variable.

> It looks like there are just a hand-ful of cases, so maybe we can tweak
> them by hand.  For example, in the sym53c8xx_2 driver bits we can replace
> the NULL labels passed to sym_print_msg() with a real string and therefore
> remove the "" case.
> 
> Joe, any better ideas?

You're right there are just a few cases where dev_info
is uses as a preface for a hex_dump style display.

Maybe it'd be OK to simply add a trailing space to the
preface and remove any leading spaces from the subsequent
initial printks.

dev_info(dev, " ");
