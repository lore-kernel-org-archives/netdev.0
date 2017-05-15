From: "Luis R. Rodriguez" <mcgrof@kernel.org>
Subject: Re: [PATCH 2/6] wl1251: Use request_firmware_prefer_user() for
 loading NVS calibration data
Date: Tue, 16 May 2017 01:13:39 +0200
Message-ID: <20170515231339.GF17314@wotan.suse.de>
References: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: "Luis R. Rodriguez" <mcgrof@kernel.org>,
        Pavel Machek <pavel@ucw.cz>, Daniel Wagner <wagi@monom.org>,
        Tom Gundersen <teg@jklm.no>,
        Pali =?iso-8859-1?Q?Roh=E1r?= <pali.rohar@gmail.com>,
        Greg Kroah-Hartman <gregkh@linuxfoundation.org>,
        Kalle Valo <kvalo@codeaurora.org>,
        David Gnedt <david.gnedt@davizone.at>,
        Tony Lindgren <tony@atomide.com>,
        Sebastian Reichel <sre@kernel.org>,
        Ivaylo Dimitrov <ivo.g.dimitrov.75@gmail.com>,
        Aaro Koskinen <aaro.koskinen@iki.fi>,
        Takashi Iwai <tiwai@suse.de>,
        AKASHI Takahiro <takahiro.akashi@linaro.org>,
        David Woodhouse <dwmw2@infradead.org>,
        Bjorn Andersson <bjorn.andersson@linaro.org>,
        Grazvydas Ignotas <notasas@gmail.com>,
        linux-kernel@vger.kernel.org, linux-wireless@vger.kernel.org,
        netdev@vger.kernel.org,
        =?u
To: Arend Van Spriel <arend.vanspriel@broadcom.com>,
        Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <0fd90416-f33c-a6be-14fd-5e964583e9cb@broadcom.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, May 12, 2017 at 11:02:26PM +0200, Arend Van Spriel wrote:
> try again.. replacing email address from Michał
> On 12-5-2017 22:55, Arend Van Spriel wrote:
> > Let me explain the idea to refresh your memory (and mine). It started
> > when we were working on adding driver support for OpenWrt in brcmfmac.
> > The driver requests for firmware calibration data, but on routers it is
> > stored in flash. So after failing on the firmware request we now call a
> > platform specific API. That was my itch, but it was not bad enough to go
> > and scratch. Now for N900 case there is a similar scenario alhtough it
> > has additional requirement to go to user-space due to need to use a
> > proprietary library to obtain the NVS calibration data. My thought: Why
> > should firmware_class care?

Agreed.

> > So the idea is that firmware_class provides
> > a registry for modules that can produce a certain firmware "file". Those
> > modules can do whatever is needed. If they need to use umh so be it.
> > They would only register themselves with firmware_class on platforms
> > that need them. It would basically be replacing the fallback mechanism
> > and only be effective on certain platforms.

Sure, so it sounds like the work that Daniel Wagner and Tom Gundersen worked
[0] on which provides a firmwared with two modes: best-effort, and final-mode,
would address what you are looking for but without requiring any upstream
changes, *and* it also helps solve the rootfs race remote-proc folks had
concerns over.

The other added gain over this solution is if folks need their own proprietary
concoction they can just fork firmwared and have that do whatever it needs
for the specific device on the specific rootfs. That is, firmwared can be the
upstream solution if folks need it, but if folks need something custom they can
just mimic the implementation: best-effort, and and final-mode.

Yet another added gain over this solution we can do *not* support the
custom fallback mechanism as its not needed, the udev event should suffice
to let userspace do what it needs.

Lastly, if we did not want to deal with timeouts for the way the driver data
API implements it I think we might be able to do away with them for for async
requests if we assume there will be a daemon that spawns in final-mode eventually,
and since it *knows* when the rootfs is ready it should be able to do a final
lookup, if it returns -ENOENT; then indeed we know we can give up. Now, perhaps
how and if we want to deal with timeouts when using the driver data API for
the fallback mechanism is worth considering given it does not have a fallback
mechanism support yet. If we *add* them it would seem this would also put an
implicit race against userspace finishing initialization and running firmwared
in final-mode.

Johannes, do you recall the corner cases we spoke about regarding timeouts?
Does this match what we spoke about?

> > Let me know if this idea is still of interest and I will rebase what I
> > have for an RFC round.

Since no upstream delta is needed for firmwared I'd like to first encourage
evaluating the above. While distributions don't carry it yet that may be seen as
an issue but since what we are looking for are corner cases, only folks needing
to deploy a specific solution would need it or a custom proprietary solution.

[0] https://github.com/teg/firmwared.git

PS.

Note that firmware signing will require an additional file, the detached
signature. The driver data API does not currently support the fallback
mechanism so we would not have to worry about that yet but once we add
fallback support we'd need to consider this.

  Luis
