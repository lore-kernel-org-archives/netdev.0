From: Paul Stewart <pstew@chromium.org>
Subject: Re: [RFC] Keep track of interrupt URB status and resubmit in bh if necessary
Date: Fri, 4 Mar 2011 10:01:38 -0800
Message-ID: <AANLkTin--1dD0u7hnW8kWMNStmQiG1pBjKz26FG18WLg@mail.gmail.com>
References: <20110303055828.073E520218@glenhelen.mtv.corp.google.com>
	<4D70C699.8000606@Ericsson.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Brownell <david-b@pacbell.net>
To: Indrek Peri <Indrek.Peri@ericsson.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([74.125.121.67]:61199 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756244Ab1CDSBm convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 4 Mar 2011 13:01:42 -0500
Received: from wpaz29.hot.corp.google.com (wpaz29.hot.corp.google.com [172.24.198.93])
	by smtp-out.google.com with ESMTP id p24I1evC020895
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 10:01:40 -0800
Received: from iwn33 (iwn33.prod.google.com [10.241.68.97])
	by wpaz29.hot.corp.google.com with ESMTP id p24I0p4P009010
	(version=TLSv1/SSLv3 cipher=RC4-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Fri, 4 Mar 2011 10:01:39 -0800
Received: by iwn33 with SMTP id 33so3303223iwn.27
        for <netdev@vger.kernel.org>; Fri, 04 Mar 2011 10:01:38 -0800 (PST)
In-Reply-To: <4D70C699.8000606@Ericsson.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Thanks for helping clear this up a bit.  I'm still a little foggy on
the details, especially when it comes to selective suspend (although I
currently don't work with a system that is actively using it, so I
might not see these issues).

On Fri, Mar 4, 2011 at 3:01 AM, Indrek Peri <Indrek.Peri@ericsson.com> =
wrote:
>
> To my understanding usbnet has design questions, like EVENT_DEV_ASLEE=
P,
> device states and events. In struct "flags" member holds an event to
> execute deferred work. Actually, in usbnet_bh, EVENT_DEV_ASLEEP is
> really needed in if-statement. Without that, in selective suspend
> case driver crashes.
>
> Another problem was that "suspend" removed interrupt URB. I tought in
> the same way as Paul, I added insertion of interrupt URB. Paul added
> it in usbnet_bh and I in "resume". I do not see a problem to add
> interrupt URB in "resume". My patch had a typo, in "resume" we
> should use GFP_ATOMIC in usb_submit_urb. Now is the question is
> this good design? My interpretation of David is that driver needs
> "resume driver" transition where RX and INT URBs are activated.

My interpretation of his statement "shouldn't this be just another
part of the "resume driver" action, like refilling the RX urb queue?"
was implicitly asking "shouldn't you move this to usbnet_bh, which is
where the RX urb queue is refilled?"  This is why I moved things
there.  Hopefully David can shed some light on it (now that I think
I've typed in his email address correctly. :-)

Now, I am also seeing what appear to be RX stalls with some
probability after suspend/resume, so it seems even with the current bh
there is still work to be done...

> I guess that usbnet needs a redesign and rewriting.
> usbnet is used by many USB-Ethernet devices that actually do not
> use selective suspend.
>
> BR, Indrek
>
>
>
> On 03/03/2011 06:45 AM, Paul Stewart wrote:
>> It appears that a patch from Indrek Peri similar to the one below
>> without resolution. =A0I'm new to this problem (suspend-resume causi=
ng
>> interrupt URBs to stop delivering) and am curious about what the cor=
rect
>> solution would should like. =A0Before becoming aware of this thread,=
 I
>> just added a "usb_submit_urb" of "dev->interrupt" into "usbnet_resum=
e()"
>> and that worked to solve the issue I was having. =A0Apparently this =
isn't
>> the correct solution though, from David's response to Indrek. =A0So,=
 I'm
>> curious about what the right code should be.
>>
>> I'll note is that submitting the interrupt URB seems fairly benign. =
=A0If
>> we are in a situation where we should not have sent an URB (e.g, the
>> netif wasn't running) intr_complete correctly handles this case and =
does
>> not re-submit the URB, so at most we get one "rogue" interrupt URB a=
fter
>> resume-from-suspend. =A0The only nasty thing is that this URB should
>> probably not be submitted from interrupt, which the resume function
>> almost certainly is. =A0I'm guessing this is part of why David NAKed
>> Indrek's patch. =A0Am I correct?
>>
>> Does something like the patch below seem like a resonable solution?
>>
>> Cc: David Brownell <dbrownell@users.sourceforge.org>
>> Cc: Indrek Peri <Indrek.Peri@Ericsson.com>
>> Signed-off-by: Paul Stewart <pstew@google.com>
>> ---
>> =A0drivers/net/usb/usbnet.c =A0 | =A0 21 +++++++++++++++++++--
>> =A0include/linux/usb/usbnet.h | =A0 =A01 +
>> =A02 files changed, 20 insertions(+), 2 deletions(-)
>>
>> diff --git a/drivers/net/usb/usbnet.c b/drivers/net/usb/usbnet.c
>> index 02d25c7..bc6a8e0 100644
>> --- a/drivers/net/usb/usbnet.c
>> +++ b/drivers/net/usb/usbnet.c
>> @@ -471,6 +471,8 @@ static void intr_complete (struct urb *urb)
>> =A0 =A0 =A0 struct usbnet =A0 *dev =3D urb->context;
>> =A0 =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 status =3D urb->status;
>>
>> + =A0 =A0 dev->interrupt_urb_running =3D 0;
>> +
>> =A0 =A0 =A0 switch (status) {
>> =A0 =A0 =A0 /* success */
>> =A0 =A0 =A0 case 0:
>> @@ -497,7 +499,9 @@ static void intr_complete (struct urb *urb)
>>
>> =A0 =A0 =A0 memset(urb->transfer_buffer, 0, urb->transfer_buffer_len=
gth);
>> =A0 =A0 =A0 status =3D usb_submit_urb (urb, GFP_ATOMIC);
>> - =A0 =A0 if (status !=3D 0 && netif_msg_timer (dev))
>> + =A0 =A0 if (status =3D=3D 0)
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev->interrupt_urb_running =3D 1;
>> + =A0 =A0 else if (netif_msg_timer (dev))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 deverr(dev, "intr resubmit --> %d", stat=
us);
>> =A0}
>>
>> @@ -580,6 +584,7 @@ static int usbnet_stop (struct net_device *net)
>> =A0 =A0 =A0 remove_wait_queue (&unlink_wakeup, &wait);
>>
>> =A0 =A0 =A0 usb_kill_urb(dev->interrupt);
>> + =A0 =A0 dev->interrupt_urb_running =3D 0;
>>
>> =A0 =A0 =A0 /* deferred work (task, timer, softirq) must also stop.
>> =A0 =A0 =A0 =A0* can't flush_scheduled_work() until we drop rtnl (la=
ter),
>> @@ -640,7 +645,8 @@ static int usbnet_open (struct net_device *net)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (netif_msg_ifup (dev)=
)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 deverr (=
dev, "intr submit %d", retval);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto done;
>> - =A0 =A0 =A0 =A0 =A0 =A0 }
>> + =A0 =A0 =A0 =A0 =A0 =A0 } else
>> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->interrupt_urb_running=
 =3D 1;
>> =A0 =A0 =A0 }
>>
>> =A0 =A0 =A0 netif_start_queue (net);
>> @@ -1065,6 +1071,17 @@ static void usbnet_bh (unsigned long param)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (dev->txq.qlen < TX_QLEN (dev))
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue (dev->n=
et);
>> =A0 =A0 =A0 }
>> +
>> + =A0 =A0 // Do we need to re-enable interrupt URBs?
>> + =A0 =A0 if (netif_running (dev->net) &&
>> + =A0 =A0 =A0 =A0 netif_device_present (dev->net) &&
>> + =A0 =A0 =A0 =A0 dev->interrupt_urb_running =3D=3D 0) {
>> + =A0 =A0 =A0 =A0 =A0 =A0 usb_submit_urb (dev->interrupt, GFP_KERNEL=
);
>> +
>> + =A0 =A0 =A0 =A0 =A0 =A0 /* Unconditionally mark as running so we d=
on't retry */
>> + =A0 =A0 =A0 =A0 =A0 =A0 dev->interrupt_urb_running =3D 1;
>> + =A0 =A0 }
>> +
>> =A0}
>>
>>
>> diff --git a/include/linux/usb/usbnet.h b/include/linux/usb/usbnet.h
>> index ba09fe8..1b8ed8a 100644
>> --- a/include/linux/usb/usbnet.h
>> +++ b/include/linux/usb/usbnet.h
>> @@ -49,6 +49,7 @@ struct usbnet {
>> =A0 =A0 =A0 u32 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 hard_mtu; =A0=
 =A0 =A0 /* count any extra framing */
>> =A0 =A0 =A0 size_t =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rx_urb_size; =A0=
 =A0/* size for rx urbs */
>> =A0 =A0 =A0 struct mii_if_info =A0 =A0 =A0mii;
>> + =A0 =A0 int =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 interrupt_urb_=
running;
>>
>> =A0 =A0 =A0 /* various kinds of pending driver work */
>> =A0 =A0 =A0 struct sk_buff_head =A0 =A0 rxq;
>
>
