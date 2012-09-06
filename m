From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 7 Sep 2012 00:09:13 +0800
Message-ID: <CACVXFVMYmTFLamWzTL2gTtu31eQg6bpLA4NapJehPoROF4t3dw@mail.gmail.com>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	<CACVXFVMXz1mqANBYR56KZsh3RgN5M_og_OggDEHT02w0Pe-UiA@mail.gmail.com>
	<87a9x33656.fsf@nemi.mork.no>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>, alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org,
	netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <87a9x33656.fsf-lbf33ChDnrE/G1V5fR+Y7Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Thu, Sep 6, 2012 at 4:30 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
> Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>> On Thu, Sep 6, 2012 at 4:12 AM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrot=
e:
>>> Hi,
>>>
>>> looking at cdc-ncm it seeems to me that cdc-ncm is forced to play
>>> very dirty games because usbnet doesn't have a notion about aggrega=
ting
>>> packets for a single transfer.
>>
>> The Ethernet API we are using does not support transmitting multiple=
 Ethernet
>> frames in a single call, so the aggregation things should be done in=
side low
>> level driver, in fact it is just what some wlan(802.11n) drivers hav=
e
>> been doing.
>>
>> IMO, the current .tx_fixup is intelligent enough to handle aggregati=
on:
>>
>>       - return a skb_out for sending if low level drivers think it i=
s
>> ready to send
>>         the aggregated frames
>>      -  return NULL if  the low level drivers think they need to wai=
t
>> for more frames
>>
>> Of course, the low level drivers need to start a timer to trigger se=
nding
>> remainder frames in case of timeout and no further frames come from
>> upper protocol stack.
>>
>> Looks the introduced .tx_bundle is not necessary since .tx_fixup is =
OK.
>
> The minidriver does not have any information about tx in progress.  T=
he

Inside .tx_fixup, the low level driver will get the tx progress informa=
tion.

> strategy above, which is what cdc_ncm uses today, is fine as long as =
you
> always want to wait as long as you always want to fill as many frames=
 as
> possible in each packet.  But what if the queue is empty and the devi=
ce

=46or cdc_ncm, the wait time is controlled by cdc_ncm driver, see
cdc_ncm_tx_timeout_start().

> is just sitting there doing nothing while you are waiting for more
> frames?  Then you are just adding unnecessary latency.

As said above, cdc_ncm can control the latency by itself.

>
> There are also several usbnet minidrivers for protocols with frame
> aggregation support.  Most of them do not currently implement tx
> aggregation, possibly due to the complexity.  This makes a common
> aggregation framework interesting in any case.  Reimplementing simila=
r
> loginc in multiple minidrivers is meaningless.

If we can abstract some common things about aggregation, it should be
meaningful. As far as I know, most of aggregation protocol is very diff=
erent,
so almost all aggregation work is only done by low level driver, such a=
s
cdc_ncm.

If we want to implement some aggregation framework, maybe below is
one solution, correct me if it is wrong.

usbnet_start_xmit():

	to_send =3D info->tx_bundle(in_skb, &out_skb)
	if (!to_send) {
		usbnet_tx_timeout_start(usbnet);
		goto not_drop;
	}
	skb =3D info->tx_fixup(dev, out_skb, GFP_ATOMIC);=09
	...

Looks the above is no much advantage than doing bundling in .tx_fixup
just like cdc_ncm.

>
> I believe Oliver is adding very useful functionality to usbnet here.
> Functionality which at least cdc_ncm and possibly other existing
> minidrivers can take advantage of immediately.  There also seems to b=
e a

Sorry, I don't know other minidrivers, and is there some common
things in building aggregation with cdc_ncm?

Considered that the patch doesn't implement wait_for_more, suggest
Oliver to post a new one with basic wait_for_more support for further
discussion.

Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
