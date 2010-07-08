From: David Miller <davem@davemloft.net>
Subject: Re: linux-next: build warning after merge of the net tree
Date: Wed, 07 Jul 2010 18:18:47 -0700 (PDT)
Message-ID: <20100707.181847.62350965.davem@davemloft.net>
References: <20100706142542.d723903f.sfr@canb.auug.org.au>
	<20100707.174522.148565561.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-next@vger.kernel.org,
	linux-kernel@vger.kernel.org, joe@perches.com, gregkh@suse.de
To: sfr@canb.auug.org.au
Return-path: <linux-next-owner@vger.kernel.org>
In-Reply-To: <20100707.174522.148565561.davem@davemloft.net>
Sender: linux-next-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: David Miller <davem@davemloft.net>
Date: Wed, 07 Jul 2010 17:45:22 -0700 (PDT)

> From: Stephen Rothwell <sfr@canb.auug.org.au>
> Date: Tue, 6 Jul 2010 14:25:42 +1000
> 
>> After merging the net tree, today's linux-next build (powerpc
>> ppc64_defconfig) produced these warnings:
>> 
>> drivers/scsi/sym53c8xx_2/sym_hipd.c: In function 'sym_print_msg':
>> drivers/scsi/sym53c8xx_2/sym_hipd.c:78: warning: zero-length gnu_printf format string
> 
> Thanks Stephen I'll look into this.

Yeah this is a bit ugly.

It used to be that the dev_*() format string was CPP pasted to whatever
format string the user gave.  So if the user gave an empty string it
still looked like a non-empty printf string.

But that no longer happens because we hide the implementation, and thus
the top-level printf format string, in the external functions.

It seems the construction:

/*
 * Stupid hackaround for existing uses of non-printk uses dev_info
 *
 * Note that the definition of dev_info below is actually _dev_info
 * and a macro is used to avoid redefining dev_info
 */

#define dev_info(dev, fmt, arg...) _dev_info(dev, fmt, ##arg)

added to linux/device.h was meant to handle these cases, but as we see
it doesn't.

It looks like there are just a hand-ful of cases, so maybe we can tweak
them by hand.  For example, in the sym53c8xx_2 driver bits we can replace
the NULL labels passed to sym_print_msg() with a real string and therefore
remove the "" case.

Joe, any better ideas?
