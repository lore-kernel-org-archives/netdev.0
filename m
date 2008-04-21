From: Frans Pop <elendil@planet.nl>
Subject: Re: [git patches] ISDN cleanups (modularization prep) (was: ISDN testing)
Date: Mon, 21 Apr 2008 22:21:23 +0200
Message-ID: <200804212221.24586.elendil@planet.nl>
References: <20080420223959.GA17998@havoc.gtf.org> <200804210205.38891.elendil@planet.nl> <480BF15D.2090100@garzik.org> <200804211536.57655.elendil@planet.nl> <200804211536.57655.elendil@planet.nl> <480CE960.4050000@garzik.org>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	isdn4linux@listserv.isdn4linux.de
To: Jeff Garzik <jeff@garzik.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753224AbYDUUVl@vger.kernel.org>
In-reply-To: <480CE960.4050000@garzik.org>
Content-Disposition: inline
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

(Let's change the subject back to what it was :-)

Jeff Garzik wrote:
> Frans Pop wrote:
>> But when I tried to modprobe hisax, I got:
>> # modprobe hisax
>> FATAL: Module hisax not found.
>> 
>> Cause seems to be:
>> # depmod -a
>> WARNING: Module
>> /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisaxdiva.ko ignored,
>> due to loop WARNING: Module
>> /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/libhisax.ko ignored,
>> due to loop WARNING: Loop
>> detected: /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisax.ko
>> needs libhisax.ko which needs hisax.ko again!
>> WARNING: Module
>> /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/hisax.ko ignored, due
>> to loop
> 
> Yeah, that's what my patchset does -- splits the "hisax" driver into
> multiple smaller drivers.  Thus, "modprobe hisax" produces the results
> that you are seeing.

Hmmm. Isn't that going to break things for existing users?

For example, I currently have this in /etc/modprobe.d/hisax to get the two 
cards to work correctly:
options hisax type=9,11 protocol=2,2 irq=10 io=0x398

This effectively translates to:
- ITK card:  type=9  protocol=2 irq=10 io=0x398
- Diva card: type=11 protocol=2

To what would I have to change this?

I suspect there will at least have to be a major update in Documentation to 
tell people how options should now be set.

> You'll need to determine which newly-created kernel module applies to
> your hardware.  Let me know if you need help with that.  The new drivers
> should be in /lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax/
> provided that you enabled them in the kernel configuration.

I think that I have the correct config (unset options omitted):
CONFIG_ISDN=m
CONFIG_ISDN_I4L=m
# ISDN feature submodules
# ISDN4Linux hardware drivers
# Passive cards
CONFIG_ISDN_DRV_HISAX=m
# D-channel protocol features
CONFIG_HISAX_EURO=y
CONFIG_HISAX_MAX_CARDS=8
# HiSax supported cards
CONFIG_HISAX_16_3=y
CONFIG_HISAX_IX1MICROR2=y
CONFIG_HISAX_DIEHLDIVA=m

Note that HISAX_16_3 and HISAX_IX1MICROR2 are y/n config options; making 
those modular is not allowed.

This results in the following modules under drivers/isdn:
/lib/modules/2.6.25-isdn/kernel/drivers/isdn/hisax:
hisaxdiva.ko  hisax.ko  libhisax.ko
/lib/modules/2.6.25-isdn/kernel/drivers/isdn/i4l:
isdn.ko

So AFAICT, I should still be loading hisax for the ITK card.

Also, I doubt that depmod is supposed to fail like the way I saw. Seems to 
me that the "loop" errors during depmod are the cause of the modules not 
being loadable.
Note that 'modprobe hisaxdiva' fails with the exact same message as for 
hisax and that depmod even explicitly says that the modules are "ignored"!

Cheers,
FJP
