From: Jeff Garzik <jeff@garzik.org>
Subject: Re: [PATCH] firmware: convert acenic driver to request_firmware()
Date: Mon, 16 Jun 2008 18:11:24 -0400
Message-ID: <4856E50C.5050908@garzik.org>
References: <1213608300.26255.665.camel@pmac.infradead.org>	 <4856CE43.4020706@garzik.org> <1213652749.26255.842.camel@pmac.infradead.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Jes Sorensen <jes@trained-monkey.org>, netdev@vger.kernel.org,
	jaswinder@infradead.org
To: David Woodhouse <dwmw2@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from srv5.dvmed.net ([207.36.208.214]:46130 "EHLO mail.dvmed.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752380AbYFPWLa (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 16 Jun 2008 18:11:30 -0400
In-Reply-To: <1213652749.26255.842.camel@pmac.infradead.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

David Woodhouse wrote:
> On Mon, 2008-06-16 at 16:34 -0400, Jeff Garzik wrote:
>> Mostly ok...
>>
>> 1) firmware separation should be a separate patch from 
>> request_firmware() support addition
> 
> It's kind of hard to do that. Taking this patch as an example -- we've
> had to make minor changes to the firmware loading w.r.t. endianness,
> etc.
> 
> If we really wanted to do it in two steps of '1. add request_firmware()'
> followed by '2. remove old static firmware', then the whole process
> would just be a lot more cumbersome than we need.
> 
> In this case, the first patch would probably add a completely new
> version of ace_load_firmware() and ace_copy(), while the second patch
> would remove the old versions of each function. To make sense of and
> review that lot, you'd actually want to run 'combinediff' on them anyway
> so you end up with what I've posted here. Only then is it really obvious
> what's happening.
> 
> I do understand the desire to keep patches simple and do things in
> stages -- but in this case (and the other request_firmware() patches
> I've done), it seems like separating those two steps would actually be
> counter-productive.
> 
> AFAICT it doesn't make it any easier to test the new code path, either.
> It's still only really testable after you've applied both patches,
> surely?

An intermediate request_firmware() step is something that can go into an 
upstream kernel _immediately_, without even needing firmware/ install 
infrastructure.

That, in turn, enables the ability to test a driver with externally 
loaded firmwares, while still being able to fall back to a known 
working, guaranteed present built-in firmware.

IOW, the first step for each driver should be:

+	request_firmware()
+	if (success)
+		use externally-loaded firmware
+	else
		use built-in firmware

and that's it.  Nothing else [in the first patch].

Thus you minimize change -- both source code upheaval as well as 
operational behavior upheaval -- while adding the capability for people 
to immediately begin testing external firmware loading... in parallel 
with further firmware/ development you yourself are doing.

While I'm on the subject, I think the most user-friendly, 
developer-friendly, and time-friendly ordering is

0) prepare kernel-firmware package with extracted firmwares from kernel 
tree, and have it available in rawhide, cooker, opensuse-devel, etc.

1) what I said above: request_firmware() for every driver

At this point, users have udev-loadable firmware in hand and a driver 
capable of loading said firmware, and can immediately start operating in 
the desired environment.

2) start peeling built-in firmwares out of the C source



What I think you don't get is that moving the firmware out of the driver 
is the _easy_ part that comes _last_.

The core problem with request_firmware() loading external firmwares is 
usability:  the user damn well needs to have their firmware available, 
otherwise their hardware doesn't work.

That means the pressure is on you to have all the elements in place with 
all the major distros _before_ you do the easy part.

Otherwise the user experience is going to suck, the last thing we all 
want...




> 
>> 2) [minor] firmware Kconfig entries should default to 'Y' during 
>> transition, though it's ok to remove those after transition is over
> 
> I don't think it's good to have a 'default y' on options for which the
> help text says "Say 'N' and let udev load it as $DEITY intended".
> 
> As a compromise, perhaps we could do a 'CONFIG_INCLUDE_ALL_FIRMWARE' and
> make them all default to whatever that option is set to? I'm really
> unconvinced of the need for that, though -- running 'make
> firmware_install' is all that's necessary, and is the preferred option. 

I'm mainly thinking of user and developer experience here.

I just want to make it damn near impossible to accidentally create a 
non-working configuration, after your patches are applied.

This isn't like other driver Kconfig options, where the driver will 
continue to work even if you auto-set everything to 'N'.  If the user 
doesn't have multiple pieces of the puzzle _already in place_, it is all 
too easy to create a non-working driver.

The truth of the matter is, the user really does want to set that 
Kconfig option, during the initial time period after your patches are 
applied.

Once things settled down and infrastructure is in place, the 'default y' 
could go away.


>> 3) there are enough changes to warrant a requirement of a "driver still 
>> works" test before going in, IMO
> 
> Most definitely. As I said, I've been very careful to ensure that the
> converted firmware is correct, in conjunction with the driver changes
> (like the endianness considerations in this case). But that is no
> substitute for testing.

Cool :)

	Jeff



