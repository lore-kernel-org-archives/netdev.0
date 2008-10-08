From: Lennert Buytenhek <buytenh@wantstofly.org>
Subject: Re: [PATCHv3 5/5] [NET] dsa: add support for the Marvell 88E6060 switch chip
Date: Thu, 9 Oct 2008 00:07:10 +0200
Message-ID: <20081008220710.GF1111@xi.wantstofly.org>
References: <20081007234622.GF23200@xi.wantstofly.org> <Pine.LNX.4.64.0810071725300.4731@k.domain.actdsltmp> <20081008084903.GE23326@xi.wantstofly.org> <2acbd3e40810081320oe022835r7e6f53abc1147542@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Trent Piepho <tpiepho@freescale.com>, netdev@vger.kernel.org
To: Andy Fleming <afleming@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xi.wantstofly.org ([83.160.184.112]:46684 "EHLO
	xi.wantstofly.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbYJHWHO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 8 Oct 2008 18:07:14 -0400
Content-Disposition: inline
In-Reply-To: <2acbd3e40810081320oe022835r7e6f53abc1147542@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 08, 2008 at 03:20:18PM -0500, Andy Fleming wrote:

> >> > +#define REG_READ(addr, reg)                                        \
> >> > +   ({                                                      \
> >> > +           int __ret;                                      \
> >> > +                                                           \
> >> > +           __ret = reg_read(ds, addr, reg);                \
> >> > +           if (__ret < 0)                                  \
> >> > +                   return __ret;                           \
> >> > +           __ret;                                          \
> >> > +   })
> >>
> >> Macro with a hidden use of a local ('ds') and a hidden return?  The
> >> former is discouraged (but can sure save a lot of typing) but the
> >> latter seems like it's just begging to cause a missing unlock or
> >> free on an error path.
> >
> > Yeah, well, that was intentional (Nicolas Pitre suggested it, and I
> > figured it made sense to do it).  I think there are a couple more places
> > in the tree that do this, and it very much increases readability because
> > you no longer need to check the return value explicitly every single
> > time you do an MII access.
> 
> I agree with Trent, it only increases readability in the sense that
> you have to read less when scanning over the code.  To me, that is the
> least important sort of readability.  This sort of macro just creates
> hidden traps.  I know it's annoying to check that return value every
> time, but that's why we get paid the big bucks.  ;)

Well, I think I picked this up from reading kernel sources. :)
And some quick grepping shows that there's plenty of places that do
this (implicit argument and/or implicit return):

arch/powerpc/boot/libfdt/fdt_ro.c:
#define CHECK_HEADER(fdt) \
        { \
                int err; \
                if ((err = fdt_check_header(fdt)) != 0) \
                        return err; \
        }

drivers/net/e1000e/ethtool.c:
#define REG_PATTERN_TEST_ARRAY(reg, offset, mask, write)                       \
        do {                                                                   \
                if (reg_pattern_test(adapter, data, reg, offset, mask, write)) \
                        return 1;                                              \
        } while (0)

drivers/net/wireless/ath5k/eeprom.h:
define AR5K_ASSERT_ENTRY(_e, _s) do {          \
        if (_e >= _s)                           \
                return (false);                 \
} while (0)

I'd agree that there is some potential for lossage, but I wouldn't say
that the implicit return thing is all that bad.  I guess I just got
used to the construct.


> If, for some reason, the community feels this is the right way to go,
> at *least* rename the macro to make it clear that it returns on an
> error, and make ds an explicit parameter.

Explicit parameter, fine with me.

How about renaming REG_{READ,WRITE} to REG_{READ,WRITE}_RETURN_ON_ERR
or somesuch?
