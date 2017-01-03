From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Tue, 3 Jan 2017 18:59:24 +0100
Message-ID: <20170103175924.GC13946@wotan.suse.de>
References: <1482598381-16513-1-git-send-email-pali.rohar@gmail.com>
 <1482598381-16513-3-git-send-email-pali.rohar@gmail.com>
 <e728586e-80bf-c9e0-0063-71da4c4aba85@broadcom.com>
 <20161226163559.GB27087@amd>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Ming Lei <ming.lei@canonical.com>,
        "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Michal Kazior <michal.kazior@tieto.com>,
        Daniel Wagner <wagi@monom.org>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev
To: Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20161226163559.GB27087@amd>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Dec 26, 2016 at 05:35:59PM +0100, Pavel Machek wrote:
> 
> Right question is "should we solve it without user-space help"?
> 
> Answer is no, too. Way too complex. Yes, it would be nice if hardware
> was designed in such a way that getting calibration data from kernel
> is easy, and if you design hardware, please design it like that. But
> N900 is not designed like that and getting the calibration through
> userspace looks like only reasonable solution.

Arend seems to have a better alternative in mind possible for other
devices which *can* probably pull of doing this easily and nicely,
given the nasty history of the usermode helper crap we should not
in any way discourage such efforts.

Arend -- please look at the firmware cache, it not a hash but a hash
table for an O(1) lookups would be a welcomed change, then it could
be repurposed for what you describe, I think the only difference is
you'd perhaps want a custom driver hook to fetch the calibration data
so the driver does whatever it needs.

> Now... how exactly to do that is other question. (But this is looks
> very reasonable. Maybe I'd add request_firmware_with_flags(, ...int
> flags), but.. that's a tiny detail.). But userspace needs to be
> involved.

No, no, we keep adding yet-another-exported symbol for requesting firmware,
instead of just adding a set of parameters possible and easily extending
functionality. Please review the patches posted on my last set which adds
a flexible API with only 2 calls, sync and async, and lets us customize
our requests using a parameter:

https://git.kernel.org/cgit/linux/kernel/git/mcgrof/linux-next.git/log/?h=20161216-drvdata-v3-try3

This also documents the "usermode helper" properly and explains some of
the issues and limitations you will need to consider if you use it, its
one reason I'd highly encourage to consider an alternative as what Arend
is considering. *Iff* you insist on using the (now using the proper term,
as per the documentation update I am providing) "custom fallback mechanism"
I welcome such a change but I ask we *really* think this through well so
we avoid the stupid issues which have historically made the custom fallback
mechanism more of a nuisance for Linux distributions, users and developers.
To this end -- I ask you check out Daniel Wagner and Tom Gundersen's firmwared
work [0] which I referred you to in December. Although the drvdata API does
not yet use a custom fallback mechanism, after and its merged the goal here
would be to *only* support a clean custom fallback mechanism which aligns
itself *well* with firmwared or solutions like it. Your patch set then could
just become a patch set to add the custom fallback mechaism support to drvdata
API with the new options/prefernce you are looking for to be specified in
the new parameters, not a new exported symbol.

One of the cruxes we should consider addressing before the drvdata API gets a
custom fallback mechanism support added is that the usermode helper lock should
be replaced with a generic solution for the races it was intended to address:
use of the API on suspend/resume and implicitly later avoid a race on init. To
this end we should consider the same race for *other* real kernel "user mode
helpers", I've documented this on a wiki [1] which documents the *real*
kernel usermode helpers users, one of which was the kobject uevent which is
one of the fallback mechanisms.

I should also note that the idea of fallback mechanism using kobject uevents
should really suffice, in review with Johannes Berg at least, he seemed
convinced just letting either the upstream firmwared, a custom firmwared or
a custom userspace solution should be able to just monitor for uevents for
drvdata and do the right thing, this whole "custom fallback mechanism"
in retrospect seems not really needed as far as I can tell.

[0] https://github.com/teg/firmwared
[1] https://kernelnewbies.org/KernelProjects/usermode-helper-enhancements

  Luis
