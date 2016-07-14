From: Kalle Valo <kvalo@codeaurora.org>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless ucode is loaded
Date: Thu, 14 Jul 2016 11:01:40 +0300
Message-ID: <87oa60y7ff.fsf@kamboji.qca.qualcomm.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>
	<CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>
	<5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
	<57840214.8000904@redhat.com> <87eg6yav5e.fsf@purkki.adurom.net>
	<1468394693.25088.138.camel@coelho.fi> <578615EF.9010305@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Luca Coelho <luca@coelho.fi>,
	"Grumbach\, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Berg\, Johannes" <johannes.berg@intel.com>,
	"Ivgi\, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev\@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon\, Sara" <sara.sharon@intel.com>,
	"linux-wireless\@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Prarit Bhargava <prarit@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.codeaurora.org ([198.145.29.96]:52132 "EHLO
	smtp.codeaurora.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751109AbcGNIBr (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 14 Jul 2016 04:01:47 -0400
In-Reply-To: <578615EF.9010305@redhat.com> (Prarit Bhargava's message of "Wed,
	13 Jul 2016 06:20:31 -0400")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Prarit Bhargava <prarit@redhat.com> writes:

> On 07/13/2016 03:24 AM, Luca Coelho wrote:
>
>> I totally agree with Emmanuel and Kalle. We should not change this.
>> It is a design decision to return an error when the interface is
>> down, this is very common with other subsystems as well.
>
> Please show me another subsystem or driver that does this.  I've looked around
> the kernel but cannot find one that updates the firmware and implements new
> features on the fly like this.  I have come across several drivers that allow
> for an update, but they do not implement new features based on the
> firmware.
>
> Additionally, what happens when someone back revs firmware versions (which
> happens far more than you and I would expect)?  Does that mean I now go from a
> functional system to a non-functional system wrt to userspace?

I'm not following, what do you mean exactly? Why are you talking
updating the firmware?

So when we talk about "loading firmware" we mean that the driver pushes
the firmware image to to the chipset. And then the interface is down the
chipset is powered down and the RAM on it will be erased. That's the
general idea anyway, I haven't checked how iwlwifi exactly works in this
case but Luca or Emmanuel can correct me.

>> The userspace should be able to handle errors and report something
>> like "unavailable" when this kind of error is returned.
>
> I myself have made the same arguments wrt to cpufreq code & bad userspace
> choices.  I just went through this a few months back with what went from a
> simple patch and turned out to be a hideous patch in cpufreq.  You cannot break
> userspace like this.

Don't get me wrong, I'm a strong supporter of stable user space
interfaces and I always try to adher to that. But there's a limit for
everything. If I'm understanding correctly, what you mean is that the
kernel should never return an error because an application doesn't
handle errors gracefully. Sorry, but that doesn't make sense to me.

> See commit 51443fbf3d2c ("cpufreq: intel_pstate: Fix intel_pstate powersave
> min_perf_pct value").  What should have been a trivial change resulted in a
> massive change because of broken userspace.

In that cpufreq case I understand, it was about a combination of
configuration values which broke the user space. But here we are just
dealing with a simple error value, nothing fancy.

>> I'm not sure EIO is the best we can have, but for me that's exactly
>> what it is.  The thermal zone *is* there, but cannot be accessed
>> because the firmware is not available.  I'm okay to change it to EBUSY,
>> if that would help userspace, but I think that's a bit misleading.  The
>> device is not busy, on the contrary, it's not even running at all.
>> 
>
> I understand that, but by returning -EIO we end up with an error.
>
>> Furthermore, I don't think this is "breaking userspace" in the sense of
>> being a regression.  
>
> I run (let's say 4.5 kernel).  sensors works.  I update to 4.7.  sensors doesn't
> work.  How is that not a regression?  That's _exactly_ what it should be
> reported as.

Sure, it's a regression in a way. But that's how the user space app you
are using is implemented, the same problem would happen with any driver
returning errors.

>> The userspace API has always been implemented with
>> the possibility of returning errors.  It's not a good design if a
>> single device returning an error causes all the other devices to also
>> fail.
>> 
>
> If that were the case we would never have to worry about "breaking userspace"?
> For any kernel change I could just say that the userspace design was bad and be
> done with it.  Why fix anything then?

Because we are talking about a simple error value.

> I don't see any harm in waiting to register the sysfs files for hwmon until the
> firmware has been validated.

I'm against of that because it's bad software design. It's standard
practise in Linux that drivers register their capabilities during driver
probe time so that user space can query them whenever needed. I assume a
properly behaving user space app would want to know about all the
available sensors once the driver is initialised and your suggestion
would break that.

> IIUC, the up/down'ing of the device doesn't happen that often (during
> initial boot, and suspend/resume, switching wifi connections,
> shutdown?).

Basically it can happen anytime, this is fully controlled by user space.
There's no point of trying to make any assumptions as they won't hold
anyway.

> This would make the iwlwifi community happy (IMO) and
> sensors would still work. At the same time I could write a patch for
> lm-sensors to fix this issue if it comes up in future versions.
> [Aside: I'm going to have the reproducing system available today and
> will test this out. It looks like just moving some code around.]

Another option, but still a bad one I don't like, is that you change the
kernel interface to ignore all errors from drivers (like iwlwifi). This
way drivers don't need to make ugly workarounds.

> The bottom line is that lm-sensors is currently broken with this change in
> iwlwifi.  AFAICT, no other thermal device returns an error this way, and IMO
> that means the iwlwifi driver is doing something new and unexpected wrt to
> userspace.

I haven't checked but I suspect ath10k has a similar problem when
interface is down.

-- 
Kalle Valo
