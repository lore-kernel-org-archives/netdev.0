From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: wl1251 & mac address & calibration data
Date: Thu, 15 Dec 2016 20:03:19 -0600
Message-ID: <CAB=NE6VHF+U7DzapENvLMKtN4Dgi9J0qMoeUJ8o4vSwc2-rRFQ@mail.gmail.com>
References: <201611111820.52072@pali> <201611241749.33681@pali>
 <20161124181138.4i6ehkpohjxfgpbn@earth> <201611241935.32796@pali>
 <87d1gtli57.fsf@purkki.adurom.net> <1481816017.2090.2.camel@Pali-Nokia-N900> <76365770-f5ba-9565-3fca-710518f64d81@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 8BIT
Cc: =?UTF-8?Q?Pali_Roh=C3=A1r?= <pali.rohar@gmail.com>,
        Kalle Valo <kvalo@codeaurora.org>,
        Sebastian Reichel <sre@kernel.org>,
        Pavel Machek <pavel@ucw.cz>,
        Michal Kazior <michal.kazior@tieto.com>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Tony Lindgren <tony@atomide.com>,
        linux-wireless <linux-wireless@vger.kernel.org>,
        Network Development <netdev@vger.kernel.org>,
        "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Takashi Iwai <tiwai@suse.de>,
        Josh Boyer <jwboyer@fedoraproject.org>,
        Dmitry Torokhov <dmitry.torokhov@gmail.com>
To: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Tom Gundersen <teg@jklm.no>, Daniel Wagner <wagi@monom.org>,
        Johannes Berg <johannes@sipsolutions.net>,
        Ming Lei <ming.lei@canonical.com>,
        Mimi Zohar <zohar@linux.vnet.ibm.com>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        =?UTF-8?B?UmFmYcWCIE1pxYJlY2tp?= <zajec5@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46628 "EHLO mail.kernel.org"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1758861AbcLPCDu (ORCPT <rfc822;netdev@vger.kernel.org>);
        Thu, 15 Dec 2016 21:03:50 -0500
In-Reply-To: <76365770-f5ba-9565-3fca-710518f64d81@broadcom.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 2:12 PM, Arend Van Spriel
<arend.vanspriel@broadcom.com> wrote:
> On 15-12-2016 16:33, Pali Rohár wrote:
>> On Thu Dec 15 09:18:44 2016 Kalle Valo <kvalo@codeaurora.org> wrote:
>>> (Adding Luis because he has been working on request_firmware() lately)
>>>
>>> Pali Rohár <pali.rohar@gmail.com> writes:
>>>
>>>>>> So no, there is no argument against... request_firmware() in
>>>>>> fallback mode with userspace helper is by design blocking and
>>>>>> waiting for userspace. But waiting for some change in DTS in
>>>>>> kernel is just nonsense.
>>>>>
>>>>> I would just mark the wlan device with status = "disabled" and
>>>>> enable it in the overlay together with adding the NVS & MAC info.
>>>>
>>>> So if you think that this solution make sense, we can wait what net
>>>> wireless maintainers say about it...
>>>>
>>>> For me it looks like that solution can be:
>>>>
>>>> extending request_firmware() to use only userspace helper
>>>
>>> I haven't followed the discussion very closely but this is my preference
>>> what drivers should do:
>>>
>>> 1) First the driver should do try to get the calibration data and mac
>>>        address from the device tree.
>>>
>>
>> Ok, but there is no (dynamic, device specific) data in DTS for N900. So 1) is noop.
>
> Uhm. What do you mean? You can propose a patch to the DT bindings [1] to
> get it in there and create your N900 DTB or am I missing something here.
> Are there hardware restrictions that do not allow you to boot with your
> own DTB.
>
>>> 2) If they are not in DT the driver should retrieve the calibration data
>>>        with request_firmware(). BUT with an option for user space to
>>>        implement that with a helper script so that the data can be created
>>>        dynamically, which I believe openwrt does with ath10k calibration
>>>        data right now.
>>
>> Currently there is flag for request_firmware() that it should fallback to user helper if direct VFS access not find needed firmware.
>>
>> But this flag is not suitable as /lib/firmware already provides default (not device specific) calibration data.
>>
>> So I would suggest to add another flag/function which will primary use user helper.
> I recall Luis saying that user-mode helper (fallback) should be
> discouraged, because there is no assurance that there is a user-mode
> helper so you might just be pissing in the wind.

There's tons of issues with the current status quo of the so called
"firmware usermode helper". To start off with its a complete misnomer,
the kernel's usermode helper infrastructure is implemented in
lib/kmod.c and it provides an API to help call out to userspace some
helper for you. That's the real kernel usermode helper. In so far as
the firmware_class.c driver is concerned -- it only makes use of the
kernel user mode helper as an option if you have
CONFIG_UEVENT_HELPER_PATH set to help address kobject uevents. Most
distributions do not use this, and back in the day systemd udev, and
prior to that hotplug used to process firmware kobject uevents.
systemd udev is long gone. Gone. This kobject uevents really are a
"fallback mechanism" for firmware only -- if cached firmware, built-in
firmware, or direct filesystem lookup fails. These each are their own
beast. Finally kobject uevents are only one of the fallback
mechanisms, "custom fallback mechanisms" are the other option and its
what you and others seem to describe to want for these sorts of custom
things.

There are issues with the existing request_firmware() API in that
everyone and their mother keeps extending it with stupid small API
extensions to do yet-another-tweak, and then having to go and change
tons of drivers. Or a new API call added for just one custom knob.
Naturally this is all plain dumb, so yet-another-API call or new
argument is not going to help us. We don't have "flags" persi in this
API, that was one issue with the design of the API, but there are much
more. The entire change in mechanism of "firmware fallback mechanism"
depending on which kernel config options you have is another. Its a
big web of gum put together. All this needs to end.

I've recently proposed a new patch to first help with understanding
each of the individual items I've listed above with as much new
information as is possible. I myself need to re-read it to just keep
tabs on what the hell is going on at times. After this I have a new
API proposal which I've been working on for a long time now which adds
an extensible API with only 2 calls: sync, async, and lets us modify
attributes through a parameters struct. This is what we should use in
the future for further extensions.

For the new API a solution for "fallback mechanisms" should be clean
though and I am looking to stay as far as possible from the existing
mess. A solution to help both the old API and new API is possible for
the "fallback mechanism" though -- but for that I can only refer you
at this point to some of Daniel Wagner and Tom Gunderson's firmwared
deamon prospect. It should help pave the way for a clean solution and
help address other stupid issues.

I'll note -- the "custom fallback mechanism", part of the old API is
just a terrible idea for many reasons. I've documented issues in my
documentation revamp, I suggest to read that, refer to this thread:

https://lkml.kernel.org/r/20161213030828.17820-4-mcgrof@kernel.org

> The idea was to have a
> dedicated API call that explicitly does the request towards user-space.

In so far as this driver example that was mentioned in this thread my
recommendation is to use the default existing MAC address /
calibration data on /lib/firmware/ and then use another request to
help override for the custom thing. The only issue of course is that
the timeout for the custom thing is 60 seconds, but if your platforms
are controlled -- just reduce this to 1 second or so given that udev
is long gone and it would seem you'd only use a custom fw request to
depend on. You could also wrap this thing into a kconfig option for
now, and have the filename specified, if empty then no custom request
is sent. If set then you have it request it.

Please note the other patches in my series for the custom fallback
though. We have only 2 users upstream -- and from recent discussions
it would seem it might be possible to address what you need with
firmwared in a clean way without this custom old fallback crap thing.
Johannes at least has a similar requirement and is convinced a
"custom" thing can be done without even adding an extra custom kobject
uevent attribute as from what I recall he hinted, drivers have no
business to be involved in this. If you do end up using the custom
fallback mechanism be sure to add super crystal clear documentation
for it (see my other patches for the declarer for this documentation).
Since we have only 2 drivers using this custom thing its hard to get
folks to commit to writing the docs, write it now and be sure you
think of the future as well.

Oh also the "custom firmware fallback" was also broken on recent
kernels for many kernel revisions, it just did not work until recently
a fix which went in, so your users wills need this fix cherry picked.
Hey I tell you, the custom fw thing was a terrible incarnation. Only 2
drivers use it. There are good reasons to not like it (be sure to read
the suspend issue I documented).

> By the way, are we talking here about wl1251 device or driver as you
> also mentioned wl12xx? I did not read the entire thread.

  Luis
