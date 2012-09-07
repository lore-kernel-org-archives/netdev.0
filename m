From: Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: Re: changing usbnet's API to better deal with cdc-ncm
Date: Fri, 7 Sep 2012 11:55:53 +0800
Message-ID: <CACVXFVM9OdUbmOFvf1KG4ePoz7wCxLRwCET3cgL=EynNBLx2AA@mail.gmail.com>
References: <2791550.LhGu6po6Xy@linux-lqwf.site>
	<87a9x33656.fsf@nemi.mork.no>
	<CACVXFVMYmTFLamWzTL2gTtu31eQg6bpLA4NapJehPoROF4t3dw@mail.gmail.com>
	<1676538.CEPj2RtrPe@linux-lqwf.site>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Bj=F8rn_Mork?= <bjorn-yOkvZcmFvRU@public.gmane.org>,
	alexey.orishko-0IS4wlFg1OjSUeElwK9/Pw@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-usb-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
To: Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org>
Return-path: <linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <1676538.CEPj2RtrPe-ugxBuEnWX9yG/4A2pS7c2Q@public.gmane.org>
Sender: linux-usb-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On Fri, Sep 7, 2012 at 1:56 AM, Oliver Neukum <oneukum-l3A5Bk7waGM@public.gmane.org> wrote:
> On Friday 07 September 2012 00:09:13 Ming Lei wrote:
>> On Thu, Sep 6, 2012 at 4:30 PM, Bj=F8rn Mork <bjorn-yOkvZcmFvRU@public.gmane.org> wrote:
>> > Ming Lei <tom.leiming-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org> writes:
>
>> >> Looks the introduced .tx_bundle is not necessary since .tx_fixup =
is OK.
>> >
>> > The minidriver does not have any information about tx in progress.=
  The
>>
>> Inside .tx_fixup, the low level driver will get the tx progress info=
rmation.
>
> That information changes after tx_fixup

You mean the low level drive can't see if the later transmission
for the aggregated frame is successful?  If so, there is no any complet=
e
notification to all low level drivers (with aggregation capability
or not) now, isn't there?

If no aggregated frame is ready for transmission, the information
can't be changed after current tx_fixup and before the next .tx_fixup.

>
>> > strategy above, which is what cdc_ncm uses today, is fine as long =
as you
>> > always want to wait as long as you always want to fill as many fra=
mes as
>> > possible in each packet.  But what if the queue is empty and the d=
evice
>>
>> For cdc_ncm, the wait time is controlled by cdc_ncm driver, see
>> cdc_ncm_tx_timeout_start().
>
> Well, that is the mistake. Using a timer is a bad idea.

Why is a bad idea?  Without a timer, how can usbnet or
low level driver aggregate the later coming transmit frames to
form a biger aggregated frame?

>
>> If we can abstract some common things about aggregation, it should b=
e
>> meaningful. As far as I know, most of aggregation protocol is very d=
ifferent,
>> so almost all aggregation work is only done by low level driver, suc=
h as
>> cdc_ncm.
>>
>> If we want to implement some aggregation framework, maybe below is
>> one solution, correct me if it is wrong.
>
> It isn't so much wrong as incomplete.
>
> It seems to me we can have
>
> - can queue, buffer not full -> do nothing more

As I said above, without a timeout timer, the queued skb
might not be sent out even some long time passed if no
frame comes later.

So could you add the wait for more mechanism to your patch
for further discussion?

> - can queue, buffer full -> transmit
> - cannot queue, buffer full -> transmit and then try again to queue

This might not happen, the buffer full should have been observed
in last xmit path.

>
> and an error case
>
> - cannot queue, buffer not full



Thanks,
--=20
Ming Lei
--
To unsubscribe from this list: send the line "unsubscribe linux-usb" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
