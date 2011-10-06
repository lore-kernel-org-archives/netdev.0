From: Andre Naujoks <nautsch@gmail.com>
Subject: Re: [PATCH net] mscan: zero accidentally copied register content
Date: Thu, 6 Oct 2011 17:03:19 +0200
Message-ID: <CAOCMmufQ77Vz4XTSTZTVSMiOA4QtWkZEvWHjGXip5-JK20E=QA@mail.gmail.com>
References: <4E8C78E8.3010605@hartkopp.net>
	<20111005155127.GB13794@pengutronix.de>
	<4E8C8175.2040202@hartkopp.net>
	<4E8D528D.8020607@hartkopp.net>
	<4E8D7065.8040905@grandegger.com>
	<4E8DBC34.80607@hartkopp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Wolfgang Grandegger <wg@grandegger.com>,
	Wolfram Sang <w.sang@pengutronix.de>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Oliver Hartkopp <socketcan@hartkopp.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:39306 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751009Ab1JFPDU convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 6 Oct 2011 11:03:20 -0400
Received: by qadb15 with SMTP id b15so2029337qad.19
        for <netdev@vger.kernel.org>; Thu, 06 Oct 2011 08:03:19 -0700 (PDT)
In-Reply-To: <4E8DBC34.80607@hartkopp.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/10/6 Oliver Hartkopp <socketcan@hartkopp.net>:
> On 10/06/11 11:09, Wolfgang Grandegger wrote:
>
>> On 10/06/2011 09:02 AM, Oliver Hartkopp wrote:
>>>
>>> I think if one would like to rework the 16bit register access (whic=
h is used
>>> in the rx path /and/ in the tx path also) this should go via net-ne=
xt after
>>> some discussion and testing.
>>
>> Why do you want to change 16-bit accesses in general? They are faste=
r
>> than two 8 bit accesses.
>>
>>> IMHO this fix is small and clear and especially not risky. I wonder=
 if
>>> reworking the 16 bit register access is worth the effort?
>>
>> I would prefer:
>>
>> =A0 =A0 =A0 if (!(frame->can_id & CAN_RTR_FLAG)) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __iomem *data =3D &regs->rx.dsr1_0;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 u16 *payload =3D (u16 *)frame->data;
>>
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < frame->can_dlc / 2; i+=
+) {
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 *payload++ =3D in_be16(d=
ata);
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 data +=3D 2 + _MSCAN_RES=
ERVED_DSR_SIZE;
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* copy remaining byte */
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (frame->can_dlc & 1)
>> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->data[frame->can_d=
lc - 1] =3D in_8(data);
>> =A0 =A0 =A0 }
>
>
> Besides the fact that Andre is going to test this idea from Wolfgang =
now, are
> you really sure that it must be
>
> =A0 =A0 =A0 =A0in_8(data)
>
> and not
>
> =A0 =A0 =A0 =A0in_8(data+1)
>
> ???
>
> And that data definitely points to the right place?
>
> I would prefer to be really cautious with these big endian 16 bit reg=
isters!
>
> Therefore my fix with
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* zero accidentally copied register co=
ntent at odd DLCs */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (frame->can_dlc & 1)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->data[frame->can_=
dlc] =3D 0;
>
> only repairing the result looks much more defensive to me.

=46irst things first: Both ways seem to work correctly. At least on the
MPC5200 I have here.

But I am with Oliver on this one. The solution looks much simpler and
endianess errors are not possible. If the few CPU cycles are worth it
on the other hand, then Wolfgangs version is probably preferable. I
don't have access to this kind of hardware on a little endian machine
to test it, though.

Greetings
  Andre

>
> Regards,
> Oliver
>
