From: Jean Delvare <khali@linux-fr.org>
Subject: Re: SFC driver implements its own I2C support
Date: Thu, 15 May 2008 11:24:16 +0200
Message-ID: <20080515112416.55ffd328@hyperion.delvare>
References: <20080513103325.1ab317cf@hyperion.delvare>
	<20080514215818.GH28241@solarflare.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@redhat.com>, netdev@vger.kernel.org,
	Linux I2C <i2c@lm-sensors.org>,
	linux-net-drivers@solarflare.com
To: Ben Hutchings <bhutchings@solarflare.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from zone0.gcu-squad.org ([212.85.147.21]:32604 "EHLO
	services.gcu-squad.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751951AbYEOJY2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2008 05:24:28 -0400
In-Reply-To: <20080514215818.GH28241@solarflare.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi Ben,

On Wed, 14 May 2008 22:58:20 +0100, Ben Hutchings wrote:
> Jean Delvare wrote:
> > Hi Ben, hi Jeff,
> 
> Please use the address linux-net-drivers@solarflare.com, as listed in
> MAINTAINERS, which goes to everyone working on the sfc driver here.

OK, will do.

> > My attention was brought to the drivers/net/sfc/i2c-direct.c file which
> > appeared recently in the Linux kernel. Apparently this is a custom
> > implementation of I2C support, including software bit-banging. All this
> > is already available in the Linux kernel in:
> >   drivers/i2c/i2c-core.c
> >   drivers/i2c/algos/i2c-algo-bit.c
> > So it really doesn't make sense to duplicate the code in the sfc
> > network driver.
> >
> > Can you please get rid of this custom I2C implementation and use the
> > standard one?
> 
> We intend to do so, but may not be able to do it before 2.6.26.

OK, thanks. I understand that it's a bit late for 2.6.26, but you
should work on it now so that it's ready for the 2.6.27 merge window.

> > It should be really easy, all you have to do is include
> > <linux/i2c.h> and <linux/i2c-algo-bit.h>, pack your SDA and SCL get/set
> > functions in a struct i2c_algo_bit_data, and call i2c_bit_add_bus() on
> > it. See drivers/video/intelfb/intelfb_i2c.c (or any framebuffer driver
> > with I2C/DDC support) for an example.
> 
> I have made a start on this, and it looked like it would be a bit more
> difficult than that.  But then perhaps I was doing more work than I
> really needed to.

If you come to the conclusion that either i2c-core or i2c-algo-bit
misses something for you to be able (and happy) to use the standard i2c
subsystem, please let me know. I'd rather add the missing pieces there
for everybody to benefit than add yet another reimplementation of i2c.
There are way too many already :(

If you need help with the conversion, just ask me or on the i2c list.

> Also, see comments from the original author of our I2C code in
> <http://thread.gmane.org/gmane.linux.kernel.commits.head/145999/focus=92866>.

Quoting this post:

> Last time I checked (i.e. when I originally wrote this bit of the code), 
> the kernel's own i2c layer didn't provide any clean way for kernel code 
> (rather than user code) to access i2c devices.

I am not sure what Michael was referring to exactly, but access to i2c
devices from the kernel has been supported pretty much forever. Maybe
he really meant access to hardware monitoring devices? For these indeed
there is a standard user-space interface (through sysfs) but no
standard in-kernel access; mainly because there has never been a clear
need for one. Again, if you need something, please discuss it on the
relevant mailing lists and we'll find a way for you to use the standard
subsystems rather than reimplementing them for your own use.

> > Using the standard I2C implementation will give you access to all the
> > i2c debugging tools, user-space access to the I2C bus if needed, and
> > compatibility with all the Linux i2c device drivers, including hardware
> > monitoring and GPIO drivers which apparently the SFC hardware uses.
> 
> Right.  But the most immediate requirement is that we be able to
> configure I2C devices from the sfc driver.  Most of our reference
> designs require that as part of their initialisation.

The changes that went into the i2c subsystem since kernel 2.6.22 should
make it possible and relatively easy. You can instantiate the I2C
devices you know are present on each adapter, and access them directly
for specific configuration as needed. For hardware monitoring devices,
you will have to add support for explicit device creation (aka
new-style i2c driver), only a couple of hardware monitoring drivers have
been converted at the moment (in particular the lm87 driver has not.)
Again I can help with that if needed.

Thanks,
-- 
Jean Delvare
