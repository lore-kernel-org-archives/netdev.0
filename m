From: "Luis R. Rodriguez" <mcgrof@do-not-panic.com>
Subject: Re: [cfg80211 / iwlwifi] setting wireless regulatory domain doesn't
 work.
Date: Wed, 18 Dec 2013 11:27:11 -0800
Message-ID: <20131218192711.GC5705@cerro.do-not-panic.com>
References: <CAB=NE6V-RSnqbAC-0tfYK=WGJLp1aPC2UpFDurs49h+wXr9UfQ@mail.gmail.com>
 <1818324675.20131211175350@eikelenboom.it>
 <CAB=NE6Wf=T0bGLSYPDyb=-fMAVnGcbGkeaBiNrzwV-Lpxr6VZg@mail.gmail.com>
 <1342235583.20131211182804@eikelenboom.it>
 <CAB=NE6UfumA2xez1DvtDSBDZ72WF_tOozFo_8LRnMryYiSqD-A@mail.gmail.com>
 <871324710.20131211191104@eikelenboom.it>
 <CAB=NE6XRnE0j9NMW0K1vKzEO9v70arSH4YXZjudqa0ZxiLB4AA@mail.gmail.com>
 <1937118387.20131216122200@eikelenboom.it>
 <52AEE60B.6030509@broadcom.com>
 <19210260274.20131216135644@eikelenboom.it>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arend van Spriel <arend@broadcom.com>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	"Berg, Johannes" <johannes.berg@intel.com>,
	"Grumbach, Emmanuel" <emmanuel.grumbach@intel.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"ilw@linux.intel.com" <ilw@linux.intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linux-wireless@vger.kernel.org" <linux-wireless@vger.kernel.org>,
	"John W. Linville" <linville@tuxdriver.com>,
	Avinash Patil <avinashapatil@gmail.com>
To: Sander Eikelenboom <linux@eikelenboom.it>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <19210260274.20131216135644@eikelenboom.it>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 16, 2013 at 01:56:44PM +0100, Sander Eikelenboom wrote:
> 
> Let's start from scratch then ...
> 
> 
> a) Isn't the point of the whole regulatory domain system that i can
>    select (and restrict) the channels/frequencies my devices transmits
>    on, so i can abide the law ?

The point is to support all forms of vendor desired architecture.
Letting userspace help regulatory with its own picked ISO3166-alpha2
is one feature and we support allowing userspace to distinguish the
input source if its from userspace -- today we support a source from
userspace to come from the user or a cellular base station. What is 
done for each of these will depend on the vendor and their own
preference, and the specific device's own architecture By default
Linux will trust the user, but if the driver wants, it will only use
the user input to enhance regulatory, never to allow more. The matrix
of possibilities varies depending on the architecture of the driver and
firmware.

So its best then to describe the issue specifically keeping in mind what
device driver and firmware you are using, rather than assuming general
things for the different scenerios.

> b) If so, does it set a regulatory domain from firmware  ?

It depends on the device. In your case the driver reads channels that are
allowed from EEPROM, then uses that information to set the channel data
structures before wiphy registration to cfg80211. cfg80211 then will use
this as the 'base set' of channels that are allowed, no further input
can enable new channels unless regulatory_hint() is used by the driver.
In your case you cannot do anything other than 'restrict' the device
further and I don't think you want to do that -- given that the vendor
already assumed testing / compliance with what it hand and they are OK
with that!

> c) If so, should it let me *restrict* the available channels even more
>    by setting the regulatory domain to the region in which de device is
>    currently being used ?

Yeap.

> d) If so, why am i not  able to do so with my intel driver for a long time
>   (for over a month now).
> # iw reg get
> country 00:
>         (2402 - 2472 @ 40), (6, 20)
>         (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN
>         (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN
>         (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN
>         (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN
>         (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN
> # iw reg set US
> # iw reg get
> country 00:
>         (2402 - 2472 @ 40), (6, 20)
>         (2457 - 2482 @ 40), (6, 20), PASSIVE-SCAN
>         (2474 - 2494 @ 20), (6, 20), NO-OFDM, PASSIVE-SCAN
>         (5170 - 5250 @ 160), (6, 20), PASSIVE-SCAN
>         (5250 - 5330 @ 160), (6, 20), DFS, PASSIVE-SCAN
>         (5490 - 5730 @ 160), (6, 20), DFS, PASSIVE-SCAN

You originally seemed to believe that using this will let you use channels
that the EEPROM and firmware does not allow, this is not the case. The
expectation that this will help you *restrict* the device is correct
thoug and the fact that its not going through is an issue and I'm happy
to review that case and fix it, as that should work. My initial review
from your kernel log though was that CRDA was not installed or if it was
installed it was not sending the information to the kernel, which could
have been an issue with the signature of the reguatory database -- the
kernel log you showed so far reflects no updates being sent by CRDA.

You have two options to help troubleshoot this, which I had indicated
before. One is to use CONFIG_CFG80211_INTERNAL_REGDB and throw the
regulatory database file into the kernel upon build on
net/wireless/db.txt. The other is to troubleshoot the regulatory
domain not getting to the kernel via udev and CRDA.

> Dmesg only spits out:
> [  383.849977] cfg80211: Pending regulatory request, waiting for it to be processed...

This indicates to us that there is an original regulatory request
that was issued and has not been processed by userspace. There is a
timeout for this, 3.14 seconds, and if 3.14 seconds go by without
this being processed we clear it and new regulatory requests should
be allowed after that.

> e) So why doesn't this whole regulatory mumbojumbo and the Linux
>    implementation in particular let me abide the law ?!? Wasn't that it's
>   *sole* point of existence ?

You are abiding by the law. The issue you are describing seems to be an
issue likely fixed in older kernels, the timeout on pending requests was
fixed long ago so I'd like to get more information on the kernel version
you are using to see if I can see what's going on.

> f) Why doesn't seem anyone to be seriously looking at it (for over a
>    month now, while everyone from wireless/80211 to intel driver
>    maintainers were CC'ed) ?

No one except myself is looking into this, and I have been busy as
I quit my job and have been traveling and juggling other things.
You were also confusing things, despite my clarifications on things,
and the issue you repoted is not something I was able to reproduce.

> g) Saying it has got to do with reg db's not being found or all kinds
> of other arguments while the report clearly stated the way it can be
> circumvented by 2 simple patches that don't seem to involve any
> changes to how it finds the reg db (apart from that i tested that a
> few times on request and indicated it didn't matter) in current 3.13
> code (and 3.12 and perhaps even earlier) (case 1) or
> with current wireless-next pulled (which has quite some changes to
> reg.c but none fixes this) onto 3.13 (case 2) Neither of these
> patches might be correct codewise, but at least it let's me set the
> regulatory domain, and the current state the code is in is neither
> correct.

You are just jumbling things around for your own purpose. Stop that.
The issue is either a timeout is not being cleared and/or CRDA is
not getting the request to the kernel. Let's focus on that.

> h) Added Linus to the CC, you never know if that automagically kicks
> things in gear ... (hopefully not in reverse :-p)

That won't help cure anything.

> Case 1 - patch that makes it possible to set the regulatory domain
> without silently ignoring it - applies to 3.13-rc4
> 
> diff --git a/net/wireless/reg.c b/net/wireless/reg.c
> 
> index 7da67fd..e8ab82e 100644
> --- a/net/wireless/reg.c
> +++ b/net/wireless/reg.c
> @@ -1579,7 +1579,7 @@ static void reg_process_pending_hints(void)
>         /* When last_request->processed becomes true this will be rescheduled */
>         if (lr && !lr->processed) {
>                 REG_DBG_PRINT("Pending regulatory request, waiting for it to be processed...\n");
> -               return;
> +               /* return; */
>         }
> 
>         spin_lock(&reg_requests_lock);
> 

Again that patch is not correct and breaks things given that we have a
timeout that will clear that. The real issue is your original request
was not processed and we want it processed. Otherwise after 3.14 seconds
from the original request you should be able to issue new requests.

> Case 2 - RFC patch by Avinash Patil that makes it possible to set the
> regulatory domain without silently ignoring it - applies to 3.13-rc4 +
> wireless-next pulled onto it

That patch was incorrect as I noted earlier.

What we need to do is get down to the exact case you have to reproduce
and fix. The issue you reported should already be addressed as I noted
and if its not I wonder if your kernel is old or its a corner case we
had not looked into before.

  Luis
