From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH] dnet: Dave DNET ethernet controller driver
Date: Thu, 12 Mar 2009 13:49:33 -0400
Message-ID: <20090312174933.GC24995@hmsreliant.think-freely.org>
References: <49B82566.3070909@weinigel.se> <20090311171354.04c7a63d@nehalam> <49B8E6D4.2030702@weinigel.se> <20090312.055523.193191701.davem@davemloft.net> <49B91A7B.7050303@weinigel.se> <20090312151211.GB24995@hmsreliant.think-freely.org> <49B93777.7030202@weinigel.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	s.hauer@pengutronix.de, yanok@emcraft.com,
	linux-arm-kernel@lists.arm.linux.org.uk, netdev@vger.kernel.org,
	wd@denx.de, dzu@denx.de
To: Christer Weinigel <christer@weinigel.se>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:49612 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751927AbZCLRtx (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 12 Mar 2009 13:49:53 -0400
Content-Disposition: inline
In-Reply-To: <49B93777.7030202@weinigel.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Mar 12, 2009 at 05:25:27PM +0100, Christer Weinigel wrote:
> Neil Horman wrote:
>> What exactly is so difficult about cpio-ing up an initramfs to do this work with
>> sed and ifconfig? You make it sound like its an impossible barrier. Its really
>> quite simple
>
> In theory, nothing.  In practice, well, where do I find an example  
> initrd that I can build on that has a DHCP client that hands over the  
Well, for an example of an initrd, you can unpack just about any distribution
initramfs that you like.  If you want to use busybox, I'd personally recommend
either Debian (I think they use busybox normally), or you're welcome to get a
copy of the fedora kexec-tools package.  I put a script called mkdumprd that
generates initramfs files in there based on busybox for the purpose of capturing
core dumps.  As for the dhcp part of it, that depends on the dhcp client you
decide to use.  I use the udhcpc applet in busybox, the man page for which
describes how to extract the various options out of the dhcpoffer frame.  Its
pretty straightforward.  Other clients do it differently, but that one is both
small and easy to use.

> NFS root information from the DHCP response to a tool that mounts the  
> NFS root file system?  So far I haven't seen anything like that and the  
> infrastructure to build initrds (such as klibc) is still hard to find  
You don't need klibc, you can use regular glibc, and even build statically if
you like.  You'll have to use dig or host to do name lookups, but thats also
pretty easy to do.  This really is easier than you think it is :)

> and use.  Every time I've tried to build an initrd that can do DCHP+NFS  
> root it has turned out to be too much trouble and I've had to drop it as  
> deadlines come closer.
>

Seriously, most of what you need to do is embodied in my mkdumprd script.  Look
at that (or even just start with it an modify it), and you'll be 90% of the way
there.  After you get it working, you can strip out all the stuff you don't need
(which from mkdumprd will likely be substantial).

>> You've convinced yourself that theres no other way to do this.  What exactly is
>> your opposition to an initramfs? I just built busybox with ifconfig, sed and ash
>> in a static binary.  The whole thing comes out at 800kb, and is compressed to
>> 400kb.  You could probably save an extra hundred kb or so if you went with msh
>> instead or something.  Are you quite sure that your NV storage for your kernel
>> doesn't have an extra 400kb to spare for an initramfs?  I assume that it must,
>> since eventually you'll need an initramfs anyway to run the production variant
>> of the system your building (I imagine they won't all ship with an NFS server in
>> tow :) ).
>
> No, I'm quite aware that there are other ways of doing this, it's just  
> that all the other ways are _much_ more work for me.  The harsh reality  
Wheres all the extra work?  You've given a few examples here, and they're all
things that are easily overcome. 

> is that if I can get a board working using a hack in the driver in half  
> an hour, I'll do that rather than fussing around with an initrd.  
> Patching the driver is no big deal, it's quick and fairly painless for  
> me, it would just be nice if the kernel had a generic way of doing this  
> so that I don't have to.  The kernel requires no userspace, no C library  
> and all I have to be able to do is to compile the kernel itself.
>
Well, you've said it there yourself.  What you're proposing is a hack in the
driver.  This really isn't the place for hacks.  This is the place for doing
things in as consistent and maintainable a way as possible.  That way is using
an initramfs, which you will need at some point in time anyway, if you want any
userspace functionality.  So why not create one?  The small investment of your
time figuring out how to do it will pay off over and over again when you can
easily assign unit-specific data using well known and well documented tools to
do so.

> It's exactly the same reason why people are still using the in kernel  
> DHCP client and NFS root code instead of writing and initrd for it, it's  
>  much easier to use and why spend time on something that is much more  
> complicated for no gain since the in kernel code is sufficient?
>
You're last comment is in direct contradiction to what you are saying here.  As
you've discovered, the in kernel dhcp and nfs root client are useless unless
your ethernet interface has a mac on it, and if you don't have a mac stored in
eeprom that the driver can access, you can't assign one without introducing a
big hack, which no one here is going to support.  The solution is to do things
the right way.  Save some space in the kernel by turning the in-kernel dhcp
client and nfs root code off, and use that space to store an initrd that can do
everything you need to and more.

> I much prefer to spend time on working on the device drivers that I'm  
> paid to work on (and spend more time to try try to get those patches  
> into the kernel) than to spend time on rewriting everything for an  
> initrd.  And the final product usually won't even have ethernet, so from  
> a product perspective it would be wasted time.  Anyway, getting the  
> system to boot from NFS is usually the absolutely first thing I have to  
> do.  Making a product out of it comes months later, and only if we're  
> able to do a proof-of-concept demo on a couple of reference platforms at  
> an early stage.
>

Everyone has to invest some time on a tangent to their goal in order to reach
their goal.  This is simply a cost of doing business.  No one is going to accept
a hack to a driver just so that you don't have to learn how to do something a
bit differently.  And no amount of complaining about how difficult it is is
going to change that.  Its simply not true.  Theres a big document in the kernel
tree explaining how to create and use initramfs/initrd files.  I'll be happy to
help you figure out how to do it if you have questions.

> Regarding the flash space, if I have a 1.6MByte kernel image (the size  
> of a  compressed Linux 2.6.24 kernel for a Samsung S3C24A0 platform I'm  
> working on), those 400kBytes can make the difference between things  
> fitting into the 2MByte flash partition the bootloader has reserved for  
> the kernel or not.
>
It can, is that the the actual case?  How much space do you have if you turn off
the dhcp client and nfs root code in the kernel? Try hard, I bet you can make it
fit without much effort.

> So it mostly boils down to me being lazy and not wanting to spend a lot  
> of time on building new infrastructure.  I'd like something which is a  
> bit better than what we have now and can spend some time on it, but I  
> don't want to spend a lot of time on it since patching the driver works  
> just fine for my purposes.  Perfect is the enemy of good.
>
Well, that is your perogative.  I had to make those sorts of choices when I did
embedded too.  I tried to get upstream what was acceptible, and carried the rest
myself on occasion. But I promise you, this really isn't hard.  Spend some time,
and you'll find and onboard initramfs environment can make your life worlds
easier long term.
Neil

>   /Christer
>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>
