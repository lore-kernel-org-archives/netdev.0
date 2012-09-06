From: =?utf-8?Q?Bj=C3=B8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Thu, 06 Sep 2012 10:30:29 +0200
Message-ID: <87a9x33656.fsf@nemi.mork.no>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	<CACVXFVMXz1mqANBYR56KZsh3RgN5M_og_OggDEHT02w0Pe-UiA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <CACVXFVMXz1mqANBYR56KZsh3RgN5M_og_OggDEHT02w0Pe-UiA-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
	(Ming Lei's message of "Thu, 6 Sep 2012 11:23:51 +0800")
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
> On Thu, Sep 6, 2012 at 4:12 AM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote=
:
>> Hi,
>>
>> looking at cdc-ncm it seeems to me that cdc-ncm is forced to play
>> very dirty games because usbnet doesn't have a notion about aggregat=
ing
>> packets for a single transfer.
>
> The Ethernet API we are using does not support transmitting multiple =
Ethernet
> frames in a single call, so the aggregation things should be done ins=
ide low
> level driver, in fact it is just what some wlan(802.11n) drivers have
> been doing.
>
> IMO, the current .tx_fixup is intelligent enough to handle aggregatio=
n:
>
>       - return a skb_out for sending if low level drivers think it is
> ready to send
>         the aggregated frames
>      -  return NULL if  the low level drivers think they need to wait
> for more frames
>
> Of course, the low level drivers need to start a timer to trigger sen=
ding
> remainder frames in case of timeout and no further frames come from
> upper protocol stack.
>
> Looks the introduced .tx_bundle is not necessary since .tx_fixup is O=
K.

The minidriver does not have any information about tx in progress.  The
strategy above, which is what cdc_ncm uses today, is fine as long as yo=
u
always want to wait as long as you always want to fill as many frames a=
s
possible in each packet.  But what if the queue is empty and the device
is just sitting there doing nothing while you are waiting for more
frames?  Then you are just adding unnecessary latency.

There are also several usbnet minidrivers for protocols with frame
aggregation support.  Most of them do not currently implement tx
aggregation, possibly due to the complexity.  This makes a common
aggregation framework interesting in any case.  Reimplementing similar
loginc in multiple minidrivers is meaningless.

I believe Oliver is adding very useful functionality to usbnet here.
=46unctionality which at least cdc_ncm and possibly other existing
minidrivers can take advantage of immediately.  There also seems to be =
a
trend towards more complex aggregating protocols as the devices get
smarter and speeds go up.


BJ=C3=B8rn
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
