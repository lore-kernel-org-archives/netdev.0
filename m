From: Paul Stewart <pstew-F7+t8E8rja9g9hUCZPvPmw@public.gmane.org>
Subject: Re: [PATCHv4] usbnet: Resubmit interrupt URB once if halted
Date: Thu, 21 Apr 2011 07:44:04 -0700
Message-ID: <BANLkTikK66s2fWY7LToRmgH_iGfhkFV01A@mail.gmail.com>
References: <BANLkTi=N3T-V8VNOcbKu6COKvbEHqMoAog@mail.gmail.com>
	<Pine.LNX.4.44L0.1104210937360.1939-100000@iolanthe.rowland.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org, greg-U8xfFu+wG4EAvxtiuMwx3w@public.gmane.org
To: Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <Pine.LNX.4.44L0.1104210937360.1939-100000-IYeN2dnnYyZXsRXLowluHWD2FQJk+8+b@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Apr 21, 2011 at 6:43 AM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLpVzexx5G7lz@public.gmane.org>=
 wrote:
> On Wed, 20 Apr 2011, Paul Stewart wrote:
>
>> On Wed, Apr 20, 2011 at 2:08 PM, Alan Stern <stern-nwvwT67g6+6dFdvTe/nMLrNAH6kLmebB@public.gmane.org=
du> wrote:
>> > On Tue, 19 Apr 2011, Paul Stewart wrote:
>> >
>> >> Set a flag if the interrupt URB completes with ENOENT as this
>> >> occurs legitimately during system suspend. =EF=BF=BDWhen the usbn=
et_bh
>> >> is called after resume, test this flag and try once to resubmit
>> >> the interrupt URB.
>> >
>> > No doubt there's a good reason for doing things this way, but it i=
sn't
>> > clear. =EF=BF=BDWhy wait until usbnet_bh() is called after resume?=
 =EF=BF=BDWhy not
>> > resubmit the interrupt URB _during_ usbnet_resume()?
>>
>> Actually, I was doing this in the bh because of feedback I had gaine=
d
>> early in this process about not doing submit_urb in the resume().
>
> Do you have a URL for that feedback? =C2=A0In general, there's no rea=
son not
> to resubmit URBs during a resume callback; lots of drivers do it. =C2=
=A0But
> usbnet may have some special requirements of its own that I'm not awa=
re
> of.
>
>> =C2=A0If
>> that issue doesn't exist, that makes my work a lot easier. =C2=A0In =
testing
>> I found that just setting this to happen in the bh might be problema=
tic
>> due to firing too early, so this is good news.
>>
>> >=EF=BF=BDThis would seem
>> > to be the logical approach, seeing as how usbnet_suspend() kills t=
he
>> > interrupt URB.
>>
>> Aha! =C2=A0But you'll see from the current version of my patch that =
we don't
>> actually ever kill the interrupt URB. =C2=A0It gets killed all on it=
s own (by the
>> hcd?) and handed back to us in intr_complete(). =C2=A0This last bit =
about the
>> complete function being called was lost on me for a while which is w=
hy
>> in a previous iteration of the patch I was trying to kill the urb in=
 suspend().
>
> Why not kill the interrupt URB while suspending? =C2=A0It's the prope=
r thing
> to do. =C2=A0Otherwise you run the risk that an event might happen at=
 just
> the wrong time, causing the interrupt URB to complete normally, but
> _after_ the driver has finished suspending. =C2=A0There's a good chan=
ce the
> driver would not process the event correctly.

I don't mind killing the URB. I'd want to set the halt flag as well
(more on why have a flag in response to your other email).  You're
right that there may be a race between an interrupt URB arriving and
the onset of suspend, but I really can't imagine why I can't solve
that by setting the flag if a submit_urb() fails in intr_complete().

>
> Alan Stern
>
>
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
