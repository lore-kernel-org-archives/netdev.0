From: Taehun Kim <kth3321@gmail.com>
Subject: Re: [PATCH] w5300: add WIZnet W5300 Ethernet driver
Date: Mon, 3 Oct 2011 18:15:54 +0900
Message-ID: <CAOkfWjfujtrFLd8HFLVC_jAQ98o8BkZNg0zGSbceFoTt9Cw6fg@mail.gmail.com>
References: <1316261666-28555-1-git-send-email-kth3321@gmail.com>
	<CAOkfWjcHxh60D9KvxLfgL0tw9XdPyDN9xr7q+9V+nM6B6g8tDA@mail.gmail.com>
	<20110927174523.GA12600@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev <netdev@vger.kernel.org>, linux-kernel@vger.kernel.org
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vx0-f174.google.com ([209.85.220.174]:55363 "EHLO
	mail-vx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752639Ab1JCJPz convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Oct 2011 05:15:55 -0400
In-Reply-To: <20110927174523.GA12600@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2011/9/28 Francois Romieu <romieu@fr.zoreil.com>:

>> +/* Opening channels of W5300 */
>> +static int
>> +w5300_open(struct wiz_private *wp, u32 type)
>
> Name it w5300_channel_open or more adequately w5300_channel_0_open
> as it is hardwired to channel 0 ?

The W5300 Ethernet function is only available in channel 0. The other c=
hannels
(1~7) is used hardwired TCP/IP stack.
I was limited to the Ethernet function in this driver because hardwired=
 TCP/IP
stack to use the TCP/IP stack in linux kernel be modified.

>> + =C2=A0 =C2=A0 int s;
>> +
>> + =C2=A0 =C2=A0 isr =3D w5300_read(wp, IR);
>> +
>> + =C2=A0 =C2=A0 /* Completing all interrupts at a time. */
>> + =C2=A0 =C2=A0 while (isr) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 w5300_write(wp, IR, isr)=
;
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Finding the channel t=
o create the interrupt */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 s =3D find_first_bit(&is=
r, sizeof(u16));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 ssr =3D w5300_read(wp, S=
n_IR(s));
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* socket interrupt is c=
leared. */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 w5300_write(wp, Sn_IR(s)=
, ssr);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 DPRINTK("%s: ISR =3D %X,=
 SSR =3D %X, s =3D %X\n",
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 __func__, isr, ssr, s);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 if (likely(!s)) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 if (ssr & Sn_IR_RECV) {
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* De-activation of interrupt */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 w5300_interrupt_disable(wp, 0);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Receiving by polling method */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 napi_schedule(&wp->napi);
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=
=A0 }
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 /* Is there any interrup=
t to be processed? */
>> + =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 isr =3D w5300_read(wp, I=
R);
>> + =C2=A0 =C2=A0 }
>> +
>> + =C2=A0 =C2=A0 return IRQ_HANDLED;
>
> The hardware implementation is supposed to enforce that the 'while' i=
s
> always entered, right ?
>

If isr is 0, it is to ensure that the W5300 is received an interrupt re=
sponses.
You mean that there is a need to the loop exit routine. right?

Thank you for your detailed feedback.

I will rewrite the driver code by applied your feedback. When the work =
is
completed, I will suggest the rewritten driver code to this thread.

Thank you.

T.K.
