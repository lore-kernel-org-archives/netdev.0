From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: [PATCH net] net: usbnet: prevent buggy devices from killing us
Date: Fri, 25 Jan 2013 13:27:07 +0100
Message-ID: <87obgde9d0.fsf@nemi.mork.no>
References: <2556579.vjYlY1iKn5@linux-5eaq.site>
	<1794053.fjSaMDVud2@linux-5eaq.site> <87ham5g2gk.fsf@nemi.mork.no>
	<1659086.jLlTU1VIap@linux-5eaq.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1659086.jLlTU1VIap-7ztolUikljGernLeA6q8OA@public.gmane.org> (Oliver Neukum's message of
	"Fri, 25 Jan 2013 13:02:38 +0100")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
> On Friday 25 January 2013 08:13:15 Bj=C3=B8rn Mork wrote:
>> Oliver Neukum <oliver-GvhC2dPhHPQdnm+yROfE0A@public.gmane.org> writes:
>> > On Thursday 24 January 2013 20:16:56 Bj=C3=B8rn Mork wrote:
>> >> A device sending 0 length frames as fast as it can has been
>> >> observed killing the host system due to the resulting memory
>> >> pressure.
>> >>=20
>> >> Temporarily disable RX skb allocation and URB submission when
>> >> the current error ratio is high, preventing us from trying to
>> >> allocate an infinite number of skbs.  Reenable as soon as we
>> >> are finished processing the done queue, allowing the device
>> >> to continue working after short error bursts.
>> >>=20
>> >> Signed-off-by: Bj=C3=B8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org>
>> >> ---
>> >> So is this starting to look OK?
>> >
>> > It seems to me that we at least need to try some error recovery.
>>=20
>> Won't the disabling code in usbnet_bh do? RX will only stay disabled
>> until the done queue is handled.
>
> So will the burst of bogus packets stop by itself?

No, in the case I am looking at it won't.  So we end up switching this
off/on endlessly.

But I believe that is fine. There is no way we can *know* that the
errors won't stop unless we start receiving packets again.  Other
devices may have similar temporary bugs, making them start working agai=
n
after a while. If we permanently disable RX then we will just make any
such device fail for no good reason.

My only wish for this patch is that it makes usbnet survive the buggy
device without bringing the host down.  Not magically fix the device (o=
f
course impossible), or even hide the bug in any way.  A non-functional
device will still appear as a non-functional device. Manual user
intervention is required to make it work.  This might involve a firmwar=
e
upgrade for all we know...

>> > How about resetting the device when it is no longer used?
>>=20
>> Yes, that we should do. I guess usbnet_open is the place to reset th=
e
>> flag and counters? I'll send another version taking care of this and
>> Joes comment.
>
> I was thinking about resetting the device, not just counters.

What's the point? We only risk making the issue worse if some device ha=
s
a similar temporary bug, fixing itself a while after reset.  I think we
should leave any such actions to the user.

> But yes, open() needs to reset the counters, too.

OK, will add that.


Bj=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
