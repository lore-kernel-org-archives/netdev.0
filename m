From: Johannes Berg <johannes@sipsolutions.net>
Subject: Re: [PATCH] net/rfkill: Create "airplane mode" LED trigger
Date: Thu, 07 Jan 2016 22:01:01 +0100
Message-ID: <1452200461.3141.19.camel@sipsolutions.net>
References: <1451142303-1872-1-git-send-email-jprvita@endlessm.com>
	 <1451142303-1872-2-git-send-email-jprvita@endlessm.com>
	 <6DC3AA8C-DDE9-44B8-91C5-94B1EB0DBE9A@holtmann.org>
	 <1452076319.2541.3.camel@sipsolutions.net>
	 <CA+A7VXW3Fsf2O_xnnZAWxieMMhSP2ngTbhtuJEB1JpMc6EFPxQ@mail.gmail.com>
	 (sfid-20160107_172007_086281_804D2523)
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Network Development <netdev@vger.kernel.org>,
	=?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita
	<jprvita@endlessm.com>, LKML <linux-kernel@vger.kernel.org>,
	Darren Hart <dvhart@infradead.org>,
	platform-driver-x86@vger.kernel.org
To: =?ISO-8859-1?Q?Jo=E3o?= Paulo Rechi Vita <jprvita@gmail.com>
Return-path: <platform-driver-x86-owner@vger.kernel.org>
In-Reply-To: <CA+A7VXW3Fsf2O_xnnZAWxieMMhSP2ngTbhtuJEB1JpMc6EFPxQ@mail.gmail.com> (sfid-20160107_172007_086281_804D2523)
Sender: platform-driver-x86-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, 2016-01-07 at 11:19 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:

> Trying to answer both Marcel's and your comments, I think we should
> rather have a trigger which fires when the global state of
> RFKILL_TYPE_ALL changes, instead of tied to the op
> RFKILL_OP_CHANGE_ALL. Then we should also update the global states on
> every set block operation instead of only on RFKILL_OP_CHANGE_ALL.
> This part does not look like policy to me (please correct me if I'm
> wrong).

Yeah, this seems fine. I'm not sure really quite what the difference
between the state and OP_CHANGE_ALL would be, but using the state does
seem reasonable to me. I also agree it's not really policy. In a sense
though, one might argue that it encourages the wrong policy.

> The platform driver can default this trigger and have the LED reflect
> the global state of RFKILL_TYPE_ALL. This indeed looks like policy,
> but mostly because the physical LED label is an airplane icon, what
> the LED will be representing is "all radios are off". If that is not
> acceptable in the kernel, I can expose the LED to userspace instead
> and different userspaces can decide when to trigger it (in which case
> we don't need this patch at all). But considering this is a laptop
> platform driver, the only way I can see this being used is having the
> LED lit when all the radios are off, and unlit otherwise (maybe I'm
> being a bit short-visioned).

As Marcel said, the question is whether or not a physical LED with an
airplane icon really should be lit when all the radios are off, or
should instead be lit when the system is in an "airplane safe" mode.
Consider, for example, an Android phone: You can quite easily display
both the WiFi connection icon and the airplane icon.

> If I'm following this correctly, your suggestion is to have an
> "airplane mode indicator" switch in the RFKill subsystem, which would
> be driven by userspace and will be tied to a trigger that could be
> used by platform drivers to drive physical airplane mode LEDs and
> similar. That's an interesting idea and probably better than
> expecting
> userspaces to know about platform details like LED presence. If this
> is feasible looks like a nice generic solution for this problem.

Mostly correct, yes. I'd argue that it should come with the following
semantics:
=C2=A0* default to the state of all as you described, so that without a=
ny
=C2=A0 =C2=A0userspace you still get some kind of sane default behaviou=
r
=C2=A0* allow only a single userspace owner, and require that owner to
=C2=A0 =C2=A0toggle it as required, to avoid multiple userspace applica=
tions
=C2=A0 =C2=A0stepping on each others' toes. This could be implemented b=
y making
=C2=A0 =C2=A0this a new /dev/rfkill command, and requiring the fd to be=
 held
=C2=A0 =C2=A0open while controlling the airplane mode state.

This would be the most generic solution, starting with the default
behaviour you implemented but allowing userspace to implement its own
airplane mode semantics without having to know about the platform LEDs
etc.

We could even do that in two stages, with your (updated) patch as the
first stage.

I would want to see some interest from userspace (e.g. Marcel for
connman) though before implementing that.


johannes
