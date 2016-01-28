From: Linus Torvalds <torvalds-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>
Subject: Re: WARNING at net/mac80211/rate.c:513 ieee80211_get_tx_rates [mac80211]
Date: Thu, 28 Jan 2016 13:44:06 -0800
Message-ID: <CA+55aFx73nv9ny-fu5BR6v8wL=f2oFomwrZoLRw=x2kNP76cYA@mail.gmail.com>
References: <CA+55aFxe22iWok6UojY=hCoG2k1wNpJ9CfQ0b+STSxq67tb86Q@mail.gmail.com>
	<1453983185.2217.12.camel@sipsolutions.net>
	<CA+55aFya9K4JboNY8kB9cg6zt9otguhdzfHm3jvLmWedxQTSWg@mail.gmail.com>
	<1454013625.2332.9.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: David Miller <davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org>,
	Linux Wireless List <linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
	Network Development <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: Johannes Berg <johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>,
	Larry Finger <Larry.Finger-tQ5ms3gMjBLk1uMJSBkQmQ@public.gmane.org>,
	Chaoming Li <chaoming_li-kXabqFNEczNtrwSWzY7KCg@public.gmane.org>,
	Kalle Valo <kvalo-sgV2jX0FEOL9JmXXK+q4OQ@public.gmane.org>
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1454013625.2332.9.camel-cdvu00un1VgdHxzADdlk8Q@public.gmane.org>
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Adding the RTL people to the cc, and leaving the whole thing quoted at
the bottom..

I will try Johannes' suggestion on that machine to see if it makes a
difference, but somebody who knows the rtlwifi rate control code
should take a double- or triple-look at this.

Please? Some googling shows that this is not a new issue. Or at least
I seem to find reports that look very much like this from over a year
ago.

                 Linus

On Thu, Jan 28, 2016 at 12:40 PM, Johannes Berg
<johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org> wrote:
> On Thu, 2016-01-28 at 11:01 -0800, Linus Torvalds wrote:
>>
>> I used to have the basic original UniFi UAP. I've replaced them with
>> the newer "AC Lite" version:
>>
>>     https://www.ubnt.com/unifi/unifi-ap-ac-lite/
>>
>> so it's a fairly big jump from a 2.4GHz-only network to a dual-band
>> one.
>>
>> The old 2.4GHz-only AP's showed the problem with minstrel-ht
>> incorrectly starting off at the highest rate (on a totally different
>> machine). So the Unifi AP's have shown problems in the kernel
>> wireless before, but so far it's always been the fault of the kernel
>> wireless, not the AP.
>
> Yeah; I wasn't trying to blame it on this change, I was just trying to
> understand the change in the environment. Seems likely that it's simply
> the switch to 5 GHz, which is strange, I'd have thought that even that
> rtlwifi driver would've been tested with that :)
>
>> > Could you print out the entire table there when the warning
>> > happens?
>>
>> This is the best I can come up with: printing out the index, and the
>> rate and bitrate tables:
>>
>>   rates[i].idx (9) >= sband->n_bitrates (8)
>>   Rates:
>>       0: idx 9 count 1 flags a0
>>       1: idx 8 count 1 flags a0
>>       2: idx 7 count 2 flags a0
>>       3: idx 6 count 3 flags a0
>
> Yeah, perfect. See, this is already evidently not making any sense:
>
> flags a0 is
> IEEE80211_TX_RC_40_MHZ_WIDTH | IEEE80211_TX_RC_SHORT_GI
>
> both of those options *require* IEEE80211_TX_RC_MCS or
> IEEE80211_TX_RC_VHT_MCS as well, so the flags really should be a8 or
> 1a0.
>
>>   Bitrates:
>>       0: flags 00000002 bitrate 60 (hw: 0004 0000)
>>       1: flags 00000000 bitrate 90 (hw: 0005 0000)
>>       2: flags 00000002 bitrate 120 (hw: 0006 0000)
>>       3: flags 00000000 bitrate 180 (hw: 0007 0000)
>>       4: flags 00000002 bitrate 240 (hw: 0008 0000)
>>       5: flags 00000000 bitrate 360 (hw: 0009 0000)
>>       6: flags 00000000 bitrate 480 (hw: 000a 0000)
>>       7: flags 00000000 bitrate 540 (hw: 000b 0000)
>>
>> So it's the very first rate that has index 9, but the bitrate table
>> only goes from 0-7.
>>
>> So I suspect that once the first index has been marked invalid, it
>> now will never even look at the later indices, so it has no transmit
>> rates at all.  Or something.
>
> Indeed.
>
>> That bitrate table does seem to match:
>>
>>    static struct ieee80211_rate rtl_ratetable_5g[] = {
>>
>> in drivers/net/wireless/realtek/rtlwifi/base.c
>>
>
> Yeah, it would, but it's irrelevant since the rate table isn't actually
> used with MCS rates.
>
> I'm not familiar with this code at all, but looking at it suggests that
> perhaps the switch to 5 GHz wasn't at fault, but instead the switch to
> VHT (802.11ac) - that's more plausible too, not testing with VHT seems
> like something that could have happened for this driver.
>
> And as I figured, the code in _rtl_rc_rate_set_series() is obviously
> not handling VHT correctly: it has
>
>                 if (sgi_20 || sgi_40 || sgi_80)
>                         rate->flags |= IEEE80211_TX_RC_SHORT_GI;
>                 if (sta && sta->ht_cap.ht_supported &&
>                     ((wireless_mode == WIRELESS_MODE_N_5G) ||
>                      (wireless_mode == WIRELESS_MODE_N_24G)))
>                         rate->flags |= IEEE80211_TX_RC_MCS;
>
> but can never set IEEE80211_TX_RC_VHT_MCS. Seems like there should be
> something like
>
>                 if (sta && sta->ht_cap.vht_supported &&
>                     (wireless_mode == WIRELESS_MODE_AC_5G ||
>                      wireless_mode == WIRELESS_MODE_AC_24G ||
>                      wireless_mode == WIRELESS_MODE_AC_ONLY))
>                         rate->flags |= IEEE80211_TX_RC_VHT_MCS;
>
> just after/before the above block.
>
> But I'm not familiar with this code at all, so that may not really be
> the right fix or even work.
>
> johannes
--
To unsubscribe from this list: send the line "unsubscribe linux-wireless" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
