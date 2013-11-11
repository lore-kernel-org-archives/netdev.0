From: Felipe Contreras <felipe.contreras@gmail.com>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 10:53:59 -0600
Message-ID: <CAMP44s3nkj2wZYCPve7EhyeD7sEFmpUN=-h015dOP68PcNSTug@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
	<CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	<1384184624.14334.31.camel@jlt4.sipsolutions.net>
	<CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
	<1384188067.14334.45.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f178.google.com ([209.85.217.178]:33052 "EHLO
	mail-lb0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754234Ab3KKQyA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 11 Nov 2013 11:54:00 -0500
In-Reply-To: <1384188067.14334.45.camel@jlt4.sipsolutions.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Nov 11, 2013 at 10:41 AM, Johannes Berg
<johannes@sipsolutions.net> wrote:
> On Mon, 2013-11-11 at 10:23 -0600, Felipe Contreras wrote:

>> However, I noticed that once in a very long time, sometimes it does
>> receive the corrupted frame and the association continues, and the
>> driver code detects it's a corrupted beacon frame.
>
> So how does it treat the corruption?

wlan0: associating with AP with corrupt beacon

>> > The firmware still
>> > shouldn't be filtering anything since it doesn't really look at the
>> > beacon information (or maybe it filters based on the DS IE? I'm not
>> > entirely sure)
>>
>> That's what I thought, but I don't see it at all (only in monitor
>> mode, and in ad-hoc).
>
> Yes, that part is odd - that's really the root cause.
>
> I didn't quickly find in the threads what device and firmware you were
> using, mind identifying it (again)?

Intel Corporation Centrino Advanced-N 6235 (rev 24)
iwlwifi 0000:02:00.0: loaded firmware version 18.168.6.1 op_mode iwldvm

>> Nope, it keeps trying forever.
>>
>> Oct 13 14:33:15 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
>> Oct 13 14:33:15 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
>> Oct 13 14:33:15 nysa kernel: wlan0: authenticated
>> Oct 13 14:33:15 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
>> Oct 13 14:33:18 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
>> Oct 13 14:33:18 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
>> Oct 13 14:33:18 nysa kernel: wlan0: authenticated
>> Oct 13 14:33:18 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
>> Oct 13 14:33:22 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
>> Oct 13 14:33:22 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
>> Oct 13 14:33:22 nysa kernel: wlan0: authenticated
>> Oct 13 14:33:22 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
>> ...
>
> I see the same behaviour - but it's the supplicant's doing, it is indeed
> getting the event that the AP connection failed (timed out):
>
> wlan0: Event ASSOC_TIMED_OUT (15) received

Not in my setup.

>> > This isn't really true like I said above - the kernel can only drop the
>> > association, if userspace *insists* then it will try again and again.
>>
>> But it's not doing this:
>>
>>   ieee80211_destroy_assoc_data(sdata, false);
>>   cfg80211_assoc_timeout(sdata->dev, bss);
>>
>> Which is what causes the association to stop for me.
>>
>> So where exactly in the code is the association being "dropped"?
>
> This does get called in my setup.

Yes, because your setup is receiving beacons.

Check the code:

if ((ifmgd->assoc_data->need_beacon && !ifmgd->have_beacon) ||
   ieee80211_do_assoc(sdata)) {
struct cfg80211_bss *bss = ifmgd->assoc_data->bss;

ieee80211_destroy_assoc_data(sdata, false);
cfg80211_assoc_timeout(sdata->dev, bss);
}

If there's no beacon, cfg80211_assoc_timeout() is not called.

I'm sure if you don't call ieee80211_rx_mgmt_beacon() at all you will
see the same behavior I see.

>> I would rather fix the problem at the two levels, so even if the
>> firmware passes the corrupt frames correctly, the driver would still
>> somewhat work when there's no beacon frames at all.
>
> Like I said before - trying to work with an AP without beacons at all is
> really bad, we shouldn't be doing it.

Why not? For all intents and purposes my system is not receiving any
beacons, and I don't see any problems.

What would you prefer? That nothing works at all?

> We might not properly react to
> radar events, and other things, for example.

So? I don't know what that means, but it can't be worst than not being
able to connect to the Internet whatsoever at all.

Cheers.

-- 
Felipe Contreras
