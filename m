From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't work.
Date: Wed, 11 Dec 2013 18:14:16 +0100
Message-ID: <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com>
References: <1507831110.20131018194349@eikelenboom.it> <792757788.20131023142849@eikelenboom.it>
 <1819533168.20131211161710@eikelenboom.it> <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <1818324675.20131211175350@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1818324675.20131211175350@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Dec 11, 2013 at 5:53 PM, Sander Eikelenboom
<linux@eikelenboom.it> wrote:
>
> Wednesday, December 11, 2013, 4:38:13 PM, you wrote:
>
>> On Wed, Dec 11, 2013 at 4:17 PM, Sander Eikelenboom
>> <linux@eikelenboom.it> wrote:
>>> Since i haven't got a response to this yet and after having the troubled machine back:
>>> The problem is still present in linux 3.13-rc3
>
>> Keep in mind regulatory hints for Intel or Atheros cards do nothing
>> other than help compliance further given that the cards already have
>> their own regulatory data, the user input / hint is only going to
>> reduce the card's channels further.
>
> So in essence what you are saying is that the firmware/eeprom already dictates the limited channels available based on .. errr .. yeah based on what ...

Whatever the device was programmed with but in practice my
understanding is Intel only sells hardware for a few regions so they
have only a few custom world regulatory domains, so that is used upon
initialization. Having the capability to actually work properly on a
different set of regions with optimal power and performance without
violating regulatory is a challenge and this is why cards are either
region specific or built / optimized for a few regions or a general
world roaming card. Channels is just one thing to consider, there are
tons of other things to consider and this will be very card and
hardware specific.

> And setting the regulatory domain yourself only limits this list of limited channels available only further ?

Yeap, that's the case for Intel Atheros, and I think nowadays new
broadcom upstream drivers too. Users should not have to be involved on
setting the regulatory domain, everything should just work
automatically.

> I now spotted this from the dmesg:
> [    4.818467] cfg80211: Ignoring regulatory request set by core since the driver uses its own custom regulatory domain

Yeap, that's by design, if a card sets a flag that its has a custom
world regulatory domain the first hint from CRDA / internel regdb that
updates the world regulatory domain will bet set on cfg80211 but for
the wiphy data structure for the drivers that have the custom flag set
we'll skip using the regulatory domain for that card as it has its own
custom regulatory domain.

> Joy o joy who ever came up with that great idea ..

Understand the architecture before making conclusions.

> Would be nice it that error came up again when you would try to set the domain, instead of silently ignoring it.

That is not an error message, its a head up and that would only apply
for the first update of the world regulatory domain. The regulatory
domain settings that a user would do next would be applied but like I
said you'd be restricting the device further.

> So now the only thing left is to try to find out if some one has hacked these bloody cards, what a mess.

Feel free to hack the living hell out of things, go wild.

> Do other cards like broadcom or whatever have the same issue ?

This is a non-issue in so far as hardware is concerned, this is a
regulatory thing, if you're unhappy you can lobby for ability to use
the spectrum as you wish all over the world. That won't go well, but
what may work well is if you can sign off on your responsibility for
causing issues. This is important -- consider weather radar channels
which are used on 5 GHz and are used to help with airplanes, you can't
just take any hardware and go crazy anywhere. There are reasons for
this. Upstream ships compliant solutions, what you do in your basement
is up to you.

>>  That said the fact that you are
>> not seeing a regulatory domain being set is an issue provided you have
>> CRDA installed or use CONFIG_CFG80211_INTERNAL_REGDB. Keep in mind
>> that the latest version of wireless-regdb had a signature issue
>> reported by users and not sure if that is cleared yet, so that would
>> also prevent the wireless-regdb being read even if CRDA was present.
>> To rule that out try putting the db.txt into net/wireless/db.txt and
>> compile with CONFIG_CFG80211_INTERNAL_REGDB for now.
>
> I did have CRDA installed (debian).
> And also compiled the db.txt in.

Can you verify that CRDA gets called? You should see something like this:

[   71.133856] cfg80211: Calling CRDA to update world regulatory domain
[   71.139098] cfg80211: World regulatory domain updated:
[   71.139102] cfg80211:  DFS Master region: unset
[   71.139104] cfg80211:   (start_freq - end_freq @ bandwidth),
(max_antenna_gain, max_eirp)
[   71.139106] cfg80211:   (2402000 KHz - 2472000 KHz @ 40000 KHz),
(N/A, 2000 mBm)
[   71.139108] cfg80211:   (2457000 KHz - 2482000 KHz @ 40000 KHz),
(N/A, 2000 mBm)
[   71.139110] cfg80211:   (2474000 KHz - 2494000 KHz @ 20000 KHz),
(N/A, 2000 mBm)
[   71.139112] cfg80211:   (5170000 KHz - 5250000 KHz @ 80000 KHz),
(N/A, 2000 mBm)
[   71.139114] cfg80211:   (5735000 KHz - 5835000 KHz @ 80000 KHz),
(N/A, 2000 mBm)
[   71.139115] cfg80211:   (57240000 KHz - 63720000 KHz @ 2160000
KHz), (N/A, 0 mBm)


>> Then send the dmesg output, no need for all that fluffy intel debug
>> log as its not useful in this case.
>
> Compiled with db.txt in:
>
> ~# iw reg set US
> ~# iw reg get
> country 00:
>         (2402 - 2472 @ 40), (6, 20)
>         (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN, NO-IBSS
>         (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN, NO-IBSS
>         (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN, NO-IBSS
>         (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN, NO-IBSS
>         (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN, NO-IBSS

This can be from the static world regulatory domain in the kernel, it
doesn't mean it came from CRDA.

> [    3.862108] cfg80211: Calling CRDA to update world regulatory domain

<-- snip -->

> [    4.818467] cfg80211: Ignoring regulatory request set by core since the driver uses its own custom regulatory domain

<-- snip -->

> [   20.502235] cfg80211: Pending regulatory request, waiting for it to be processed...

<-- snip -->

> [  126.454516] cfg80211: Pending regulatory request, waiting for it to be processed...

It doesn't seem like you are getting your original requests getting
processed, so I don't think CRDA is passing it. Can you verify running
from CRDA code:

./regdbdump /usr/lib/crda/regulatory.bin

  Luis
