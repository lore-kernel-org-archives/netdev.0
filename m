From: Xiaotian Feng <xtfeng@gmail.com>
Subject: Re: possible circular locking dependency in ISDN PPP
Date: Thu, 22 Oct 2009 10:27:25 +0800
Message-ID: <7b6bb4a50910211927k7371aeax1973b295c6f729c@mail.gmail.com>
References: <4ADB93C4.4090607@imap.cc>
	 <7b6bb4a50910182227y1281b40bj3fcc082d32cf4496@mail.gmail.com>
	 <4ADF35CA.5020207@imap.cc>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: LKML <linux-kernel@vger.kernel.org>,
	isdn4linux <isdn4linux@listserv.isdn4linux.de>,
	Netdev <netdev@vger.kernel.org>,
	Karsten Keil <isdn@linux-pingi.de>
To: Tilman Schmidt <tilman@imap.cc>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1753537AbZJVC1W@vger.kernel.org>
In-Reply-To: <4ADF35CA.5020207@imap.cc>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Thu, Oct 22, 2009 at 12:24 AM, Tilman Schmidt <tilman@imap.cc> wrote=
:
> Thanks for your analysis. The patch you propose does indeed prevent t=
he
> "circular locking dependency" message, with no noticeable ill effect.
>
> I cannot say why xmit_lock was taken around isdn_net_lp_busy() in the
> first place. The ISDN4Linux people would be the ones to comment on th=
at.
> If none of them objects, I propose you add a Signed-off-by line to yo=
ur
> patch and submit it to Karsten Keil, the ISDN maintainer, for inclusi=
on.
> You can also add a "Tested-by: Tilman Schmidt <tilman@imap.cc>" line.
>

Sure, I'll prepare a patch and send to Karsten later, Thanks.

> Thanks,
> Tilman
>
> Am 19.10.2009 07:27 schrieb Xiaotian Feng:
>> So there's a circular locking dependency.. Looking into isdn_net_get=
_locked_lp()
> [...]
>> Why do we need to hold xmit_lock while using
>> isdn_net_lp_busy(nd->queue) ? Can following patch fix this bug?
>>
>> ---
>> diff --git a/drivers/isdn/i4l/isdn_net.h b/drivers/isdn/i4l/isdn_net=
=2Eh
>> index 74032d0..7511f08 100644
>> --- a/drivers/isdn/i4l/isdn_net.h
>> +++ b/drivers/isdn/i4l/isdn_net.h
>> @@ -83,19 +83,19 @@ static __inline__ isdn_net_local *
>> isdn_net_get_locked_lp(isdn_net_dev *nd)
>>
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock_irqsave(&nd->queue_lock, flags=
);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 lp =3D nd->queue; =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 /* get lp on top of queue */
>> - =C2=A0 =C2=A0 =C2=A0 spin_lock(&nd->queue->xmit_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 while (isdn_net_lp_busy(nd->queue)) {
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock(&nd->=
queue->xmit_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 nd->queue =3D=
 nd->queue->next;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (nd->queu=
e =3D=3D lp) { /* not found -- should never happen */
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 lp =3D NULL;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0 goto errout;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> - =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_lock(&nd->qu=
eue->xmit_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 lp =3D nd->queue;
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 nd->queue =3D nd->queue->next;
>> + =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&nd->queue_lock, flags=
);
>> + =C2=A0 =C2=A0 =C2=A0 spin_lock(&lp->xmit_lock);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 local_bh_disable();
>> + =C2=A0 =C2=A0 =C2=A0 return lp;
>> =C2=A0errout:
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 spin_unlock_irqrestore(&nd->queue_lock, =
flags);
>> =C2=A0 =C2=A0 =C2=A0 =C2=A0 return lp;
>>
>
> --
> Tilman Schmidt =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0=
 =C2=A0 =C2=A0E-Mail: tilman@imap.cc
> Bonn, Germany
> Diese Nachricht besteht zu 100% aus wiederverwerteten Bits.
> Unge=C3=B6ffnet mindestens haltbar bis: (siehe R=C3=BCckseite)
>
>
