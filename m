From: Felipe Contreras <felipe.contreras-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: [PATCH v2] mac80211: add assoc beacon timeout logic
Date: Mon, 11 Nov 2013 10:23:05 -0600
Message-ID: <CAMP44s2cVVe4-yW214B9hJu7n6M1onZpZaPCj5N0Fi1JWDKKsw@mail.gmail.com>
References: <1384119945-31213-1-git-send-email-felipe.contreras@gmail.com>
	<1384160932.14334.6.camel@jlt4.sipsolutions.net>
	<CAMP44s3TFSgWuR8gVoFBznNP+t9mz+to===9i1PAnra4ogKu9w@mail.gmail.com>
	<1384184624.14334.31.camel@jlt4.sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: linux-wireless Mailing List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	netdev <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	"John W. Linville" <linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org>,
	"David S. Miller" <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1384184624.14334.31.camel-8Nb76shvtaUJvtFkdXX2HixXY32XiHfO@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Mon, Nov 11, 2013 at 9:43 AM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Mon, 2013-11-11 at 04:59 -0600, Felipe Contreras wrote:
>
>> Well the AP is sending beacons, but they seem to be corrupted,
>> although the corruption often seems to happen in a place that is not
>> so important.
>
> Indeed - the beacon you sent to me in private is damaged somewhere
> towards the end of the frame. Are we actually receiving it but ignoring
> it because it doesn't have the data we need?

The driver is not receiving it at all. I already debugged this:

http://article.gmane.org/gmane.linux.kernel.wireless.general/115429

However, I noticed that once in a very long time, sometimes it does
receive the corrupted frame and the association continues, and the
driver code detects it's a corrupted beacon frame.

> The firmware still
> shouldn't be filtering anything since it doesn't really look at the
> beacon information (or maybe it filters based on the DS IE? I'm not
> entirely sure)

That's what I thought, but I don't see it at all (only in monitor
mode, and in ad-hoc).

>> However, if I apply this patch, I don't notice any issue, it
>> associates and works fine. Maybe there's some subtle issues with
>> features I don't personally use, or perhaps there's the occasional
>> disconnection (although that could be due to something else), but
>> that's light years away from not associating at all.
>>
>> I'd say between a) some features not working and b) nothing working at
>> all, a) is preferred.
>>
>> If you think it's better that nothing works at all, then wouldn't it
>> make sense to time out and return an error? Currently we just keep
>> trying to associate *forever*.
>
> That's wpa_supplicant/userspace behaviour. The kernel will just drop the
> connection.

Nope, it keeps trying forever.

Oct 13 14:33:15 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
Oct 13 14:33:15 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
Oct 13 14:33:15 nysa kernel: wlan0: authenticated
Oct 13 14:33:15 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
Oct 13 14:33:18 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
Oct 13 14:33:18 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
Oct 13 14:33:18 nysa kernel: wlan0: authenticated
Oct 13 14:33:18 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
Oct 13 14:33:22 nysa kernel: wlan0: authenticate with e0:1d:3b:46:82:a0
Oct 13 14:33:22 nysa kernel: wlan0: send auth to e0:1d:3b:46:82:a0 (try 1/3)
Oct 13 14:33:22 nysa kernel: wlan0: authenticated
Oct 13 14:33:22 nysa kernel: wlan0: waiting for beacon from e0:1d:3b:46:82:a0
...

>> > If the AP is sending beacons but the device isn't receiving them, then
>> > it's a driver bug and mac80211 shouldn't work around it.
>>
>> I agree, but I can't seem to convince Intel guys of that. The firmware
>> is dropping the corrupt beacon frames (although not always), so
>> there's nothing the driver can do afterwards.
>
> You realize I work for the same team in Intel as well? :)

Now I do.

>> But even if there were not beacons at all (corrupt or otherwise), I
>> still think waiting *forever* in a loop is not ideal, a) is preferred;
>> not having all the features, but still somehow work (from my point of
>> view it's more than somewhat).
>
> This isn't really true like I said above - the kernel can only drop the
> association, if userspace *insists* then it will try again and again.

But it's not doing this:

  ieee80211_destroy_assoc_data(sdata, false);
  cfg80211_assoc_timeout(sdata->dev, bss);

Which is what causes the association to stop for me.

So where exactly in the code is the association being "dropped"?

> I'd much rather try to get to the bottom of this. Maybe the firmware is
> dropping the beacon because the DS IE is broken? Or are we receiving it
> but ignoring it because it's broken?

It's not the latter.

I would rather fix the problem at the two levels, so even if the
firmware passes the corrupt frames correctly, the driver would still
somewhat work when there's no beacon frames at all.

> Unfortunately, there's only so much we can do to work around broken APs.

Indeed, but 'so much' for this AP is really nothing, while with my
patch it's quite a lot.

-- 
Felipe Contreras
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
