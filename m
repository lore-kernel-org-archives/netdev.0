From: Prarit Bhargava <prarit@redhat.com>
Subject: Re: [PATCH RESEND] iwlwifi, Do not implement thermal zone unless
 ucode is loaded
Date: Mon, 11 Jul 2016 16:31:16 -0400
Message-ID: <57840214.8000904@redhat.com>
References: <1468250301-10357-1-git-send-email-prarit@redhat.com>	 <CANUX_P0AFoM5VEDWDjtvOhNbExu4T1bLWU+uS-EYqoGtu5h2bw@mail.gmail.com>	 <5783E33E.7090205@redhat.com> <1468261650.20877.14.camel@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	linuxwifi <linuxwifi@intel.com>,
	"Coelho, Luciano" <luciano.coelho@intel.com>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"kvalo@codeaurora.org" <kvalo@codeaurora.org>,
	"Ivgi, Chaya Rachel" <chaya.rachel.ivgi@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Sharon, Sara" <sara.sharon@intel.com>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>
To: "Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1468261650.20877.14.camel@intel.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org



On 07/11/2016 02:27 PM, Grumbach, Emmanuel wrote:
> On Mon, 2016-07-11 at 14:19 -0400, Prarit Bhargava wrote:
>>
>> On 07/11/2016 02:00 PM, Emmanuel Grumbach wrote:
>>> On Mon, Jul 11, 2016 at 6:18 PM, Prarit Bhargava <prarit@redhat.com
>>>> wrote:
>>>>
>>>> Didn't get any feedback or review comments on this patch. 
>>>>  Resending ...
>>>>
>>>> P.
>>>
>>> This change is obviously completely broken. It simply disables the
>>> registration to thermal zone core.
>>
>> No it is not broken, and yes, that is exactly what should happen IMO.
>>
>> The problem is that the iwlwifi driver implements the thermal zone
>> even when the
>> device doesn't support it.
> 
> We implement thermal zone because we do support it, but the problem is
> that we need the firmware to be loaded for that. So you can argue that
> we should register *later* when the firmware is loaded. But this is
> really not helping all that much because the firmware can also be
> stopped at any time. So you'd want us to register / unregister the
> thermal zone anytime the firmware is loaded / unloaded?

You might have to do that.  I think that if the firmware enables a feature then
the act of loading the firmware should run the code that enables the feature.
IMO of course.

> I guess that works, but it seems wrong to me. Usually, registration
> should happen only upon INIT, and yes, at that time the firmware is not
> ready to provide the information yet.
> Maybe returning -EBUSY would help lm-sensors not to get confused?

I'll give that a shot, but I expect that won't work either as an error message
will still be displayed.

> 
>>
>> As can be seen in the current code base, iwl_mvm_tzone_get_temp()
>> will return
>> -EIO 100% of the time when the firmware doesn't support reading the
>> temperature[1].  In this case a read of sysfs will result in a return
>> of -EIO,
>> and this breaks existing userspace programs such as lm-sensors (which
>> by all
>> accounts is bad to do).
> 
> Right, but I don't understand why the userspace is broken because of
> that? 

Before the iwlwifi change, sensors successfully returned.  Now, because of the
error, it doesn't.

Unless we register / unregister anytime the firmware is loaded, I
> don't see any proper way to fix this. And yes, I'd expect the userspace
> to handle gracefully failures in its requests.

I agree with you in principle *and there's a great many things I wish userspace
would do gracefully* but updating the kernel shouldn't result in userspace
programs failing.

> 
>>
>> Note that in my patch I have removed the -EIO return in favor of not
>> registering
>> the non-existent thermal zone.  I'm not removing any functionality by
>> changing
>> this, nor am I adding functionality.  In both cases the thermal zone
>> is not
>> functional, and with my patch userspace continues to work.
> 
> You are removing the thermal zone functionality since even when the
> firmware will be loaded (which typically happens fairly quickly),
> thermal zone won't work.

Then I agree with your suggestion above that you need to enable the thermal zone
on a successful load of the firmware.  [Aside: I wonder what other drivers do in
this situation?  While this does seem like an odd case, I can't believe that the
iwlwifi driver is the only driver to enable features based on firmware.]

P.
