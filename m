From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Wed, 13 Jul 2016 06:20:31 -0400
Message-ID: <578615EF.9010305@redhat.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>		<CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>		<5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>		<57840214.8000904@redhat.com> <87eg6yav5e.fsf@purkki.adurom.net> <1468394693.25088.138.camel@coelho.fi>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: Luca Coelho <luca@coelho.fi>, Kalle Valo <kvalo@codeaurora.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468394693.25088.138.camel@coelho.fi>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/13/2016 03:24 AM, Luca Coelho wrote:
> On Wed, 2016-07-13 at 09:50 +0300, Kalle Valo wrote:
>> Prarit Bhargava <prarit@redhat.com> writes:
>>
>>>> We implement thermal zone because we do support it, but the
>>>> problem is
>>>> that we need the firmware to be loaded for that. So you can argue
>>>> that
>>>> we should register *later* when the firmware is loaded. But this
>>>> is
>>>> really not helping all that much because the firmware can also be
>>>> stopped at any time. So you'd want us to register / unregister
>>>> the
>>>> thermal zone anytime the firmware is loaded / unloaded?
>>>
>>> You might have to do that.  I think that if the firmware enables a
>>> feature then
>>> the act of loading the firmware should run the code that enables
>>> the feature.
>>> IMO of course.
>>
>> But I suspect that the iwlwifi firmware is loaded during interface up
>> (and unloaded during interface down) and in that case
>> register/unregister would be happening all the time. That doesn't
>> sound
>> like a good idea. I would rather try to fix the thermal interface to
>> handle the cases when the measurement is not available.
> 
> I totally agree with Emmanuel and Kalle.  We should not change this.
>  It is a design decision to return an error when the interface is down,
> this is very common with other subsystems as well.  

Please show me another subsystem or driver that does this.  I've looked around
the kernel but cannot find one that updates the firmware and implements new
features on the fly like this.  I have come across several drivers that allow
for an update, but they do not implement new features based on the firmware.

Additionally, what happens when someone back revs firmware versions (which
happens far more than you and I would expect)?  Does that mean I now go from a
functional system to a non-functional system wrt to userspace?

The userspace
> should be able to handle errors and report something like "unavailable"
> when this kind of error is returned.
> 

I myself have made the same arguments wrt to cpufreq code & bad userspace
choices.  I just went through this a few months back with what went from a
simple patch and turned out to be a hideous patch in cpufreq.  You cannot break
userspace like this.

See commit 51443fbf3d2c ("cpufreq: intel_pstate: Fix intel_pstate powersave
min_perf_pct value").  What should have been a trivial change resulted in a
massive change because of broken userspace.

> I'm not sure EIO is the best we can have, but for me that's exactly
> what it is.  The thermal zone *is* there, but cannot be accessed
> because the firmware is not available.  I'm okay to change it to EBUSY,
> if that would help userspace, but I think that's a bit misleading.  The
> device is not busy, on the contrary, it's not even running at all.
> 

I understand that, but by returning -EIO we end up with an error.

> Furthermore, I don't think this is "breaking userspace" in the sense of
> being a regression.  

I run (let's say 4.5 kernel).  sensors works.  I update to 4.7.  sensors doesn't
work.  How is that not a regression?  That's _exactly_ what it should be
reported as.

The userspace API has always been implemented with
> the possibility of returning errors.  It's not a good design if a
> single device returning an error causes all the other devices to also
> fail.
> 

If that were the case we would never have to worry about "breaking userspace"?
For any kernel change I could just say that the userspace design was bad and be
done with it.  Why fix anything then?

I don't see any harm in waiting to register the sysfs files for hwmon until the
firmware has been validated.  IIUC, the up/down'ing of the device doesn't happen
that often (during initial boot, and suspend/resume, switching wifi connections,
shutdown?).  This would make the iwlwifi community happy (IMO) and sensors would
still work.  At the same time I could write a patch for lm-sensors to fix this
issue if it comes up in future versions.  [Aside: I'm going to have the
reproducing system available today and will test this out.  It looks like just
moving some code around.]

The bottom line is that lm-sensors is currently broken with this change in
iwlwifi.  AFAICT, no other thermal device returns an error this way, and IMO
that means the iwlwifi driver is doing something new and unexpected wrt to
userspace.

P.


> --
> Cheers,
> Luca.
> 
