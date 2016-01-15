From: =?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@gmail.com>
Subject: Re: [PATCH] net/rfkill: Create "airplane mode" LED trigger
Date: Fri, 15 Jan 2016 10:04:25 -0500
Message-ID: <CA+A7VXWeUJHTnSiGGT2WZER=pAX7hhhhi2oQVeu4U8xSM5VZag@mail.gmail.com>
References: <1451142303-1872-1-git-send-email-jprvita@endlessm.com>
 <1451142303-1872-2-git-send-email-jprvita@endlessm.com> <6DC3AA8C-DDE9-44B8-91C5-94B1EB0DBE9A@holtmann.org>
 <1452076319.2541.3.camel@sipsolutions.net> <CA+A7VXW3Fsf2O_xnnZAWxieMMhSP2ngTbhtuJEB1JpMc6EFPxQ@mail.gmail.com>
 <1452200461.3141.19.camel@sipsolutions.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "David S. Miller" <davem@davemloft.net>,
	linux-wireless <linux-wireless@vger.kernel.org>,
	Marcel Holtmann <marcel@holtmann.org>,
	Network Development <netdev@vger.kernel.org>,
	=?UTF-8?Q?Jo=C3=A3o_Paulo_Rechi_Vita?= <jprvita@endlessm.com>,
	LKML <linux-kernel@vger.kernel.org>,
	Darren Hart <dvhart@infradead.org>,
	platform-driver-x86@vger.kernel.org
To: Johannes Berg <johannes@sipsolutions.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1452200461.3141.19.camel@sipsolutions.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello, Johannes.

On 7 January 2016 at 16:01, Johannes Berg <johannes@sipsolutions.net> w=
rote:
> On Thu, 2016-01-07 at 11:19 -0500, Jo=C3=A3o Paulo Rechi Vita wrote:
>
>> Trying to answer both Marcel's and your comments, I think we should
>> rather have a trigger which fires when the global state of
>> RFKILL_TYPE_ALL changes, instead of tied to the op
>> RFKILL_OP_CHANGE_ALL. Then we should also update the global states o=
n
>> every set block operation instead of only on RFKILL_OP_CHANGE_ALL.
>> This part does not look like policy to me (please correct me if I'm
>> wrong).
>
> Yeah, this seems fine. I'm not sure really quite what the difference
> between the state and OP_CHANGE_ALL would be, but using the state doe=
s
> seem reasonable to me. I also agree it's not really policy. In a sens=
e
> though, one might argue that it encourages the wrong policy.
>

There was a misunderstanding of these semantics on my side, despite
this being documented in Documentation/rfkill.txt. Now I've realized
the semantic difference between 1."having all the individual switches
of a certain type blocked at a certain moment" and 2."blocking all
switches of a certain type": on the 1st situation, each switch was
individually blocked in different moments, and by chance a certain
type had all its registered switches blocked, while on the 2nd, all
switches of a certain type were blocked altogether using
RFKILL_OP_CHANGE_ALL. Only on the 2nd situation we want to update the
default state for hotplugged devices, and that's why
rfkill_global_states[type] is not updated when individual switches are
driven, even if we read situation 1. Then there is actually no
difference between the state value and the operation, and there is
nothing to be fixed on an individual switch change. Sorry for the
confusion.

I'm going to add a note about this behavior to
include/uapi/linux/rfkill.h as well.

>> The platform driver can default this trigger and have the LED reflec=
t
>> the global state of RFKILL_TYPE_ALL. This indeed looks like policy,
>> but mostly because the physical LED label is an airplane icon, what
>> the LED will be representing is "all radios are off". If that is not
>> acceptable in the kernel, I can expose the LED to userspace instead
>> and different userspaces can decide when to trigger it (in which cas=
e
>> we don't need this patch at all). But considering this is a laptop
>> platform driver, the only way I can see this being used is having th=
e
>> LED lit when all the radios are off, and unlit otherwise (maybe I'm
>> being a bit short-visioned).
>
> As Marcel said, the question is whether or not a physical LED with an
> airplane icon really should be lit when all the radios are off, or
> should instead be lit when the system is in an "airplane safe" mode.
> Consider, for example, an Android phone: You can quite easily display
> both the WiFi connection icon and the airplane icon.
>

Yes. I think we're actually saying the same thing with different words =
here.

>> If I'm following this correctly, your suggestion is to have an
>> "airplane mode indicator" switch in the RFKill subsystem, which woul=
d
>> be driven by userspace and will be tied to a trigger that could be
>> used by platform drivers to drive physical airplane mode LEDs and
>> similar. That's an interesting idea and probably better than
>> expecting
>> userspaces to know about platform details like LED presence. If this
>> is feasible looks like a nice generic solution for this problem.
>
> Mostly correct, yes. I'd argue that it should come with the following
> semantics:
>  * default to the state of all as you described, so that without any
>    userspace you still get some kind of sane default behaviour

Agreed, and we would still be in an "airplane safe" mode, but maybe a
too conservative one.

>  * allow only a single userspace owner, and require that owner to
>    toggle it as required, to avoid multiple userspace applications
>    stepping on each others' toes. This could be implemented by making
>    this a new /dev/rfkill command, and requiring the fd to be held
>    open while controlling the airplane mode state.
>

And when the fd gets released we would fallback to default, right? So
that would avoid two userpace apps trying to control it at the same
time, but not one after the other (which is a good thing). As I
understand it also implies we would not expose this control point
through sysfs.

> This would be the most generic solution, starting with the default
> behaviour you implemented but allowing userspace to implement its own
> airplane mode semantics without having to know about the platform LED=
s
> etc.
>
> We could even do that in two stages, with your (updated) patch as the
> first stage.
>

Great, I already fixed the previous comments and started working on a
prototype of the second stage, but then a naming question came to my
mind. They way I'm designing it is to have only one trigger and change
its behavior when the "airplane mode indicator" is under userspace
control (basically changing when to call led_trigger_event() to fire
the trigger). In this case it probably makes sense to call the trigger
something like "rfkill-airplane_mode", as before, because it will fire
when we're in an "airplane safe" mode, controlled by userspace or with
a fallback default behavior.

Another option would be to have two separate triggers,
"rfkill-airplane_mode" controlled by userspace, and "rfkill-all"
implementing the default behavior, and change which trigger is set to
each LED *from the trigger implementation side* in rfkill. Unless I'm
missing something, I don't think this second approach is possible.

So the question is, if we go with the 1st approach, would it be fine
to call the trigger "rkill-airplane_mode", even for the first stage
when only the default behavior is implemented, or should I rename it
(which implies renaming an API to other drivers) during the 2nd stage
implementation? I think sticking with one name from the beginning is
better, but since it goes against previous feedback, I decided to ask
first.

> I would want to see some interest from userspace (e.g. Marcel for
> connman) though before implementing that.
>

I'll send patches for this soon.

Thanks for the feedback,
