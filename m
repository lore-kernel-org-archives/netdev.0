From: Li Yang <leoli@freescale.com>
Subject: Re: [PATCH] ucc_geth: Move freeing of TX packets to NAPI context.
Date: Mon, 30 Mar 2009 18:24:07 +0800
Message-ID: <2a27d3730903300324n5da94ed0g80283038849b224b@mail.gmail.com>
References: <1237987849.2194.9.camel@gentoo-jocke.transmode.se>
	 <20090325142540.GA20944@oksana.dev.rtsoft.ru>
	 <OF3C4E8131.4223FD1A-ONC1257584.0061D2E6-C1257584.0062233E@transmode.se>
	 <2a27d3730903300134q673de9cbg6c92e981efc12695@mail.gmail.com>
	 <OF6D5FFE1D.1843C7FE-ONC1257589.00328D91-C1257589.00336B8B@transmode.se>
	 <2a27d3730903300236j79cc3035raef2bf5e895fe429@mail.gmail.com>
	 <OF42785A57.F2F3AFE4-ONC1257589.0035B462-C1257589.003712D0@transmode.se>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: avorontsov@ru.mvista.com,
	linuxppc-dev Development <linuxppc-dev@ozlabs.org>,
	Netdev <netdev@vger.kernel.org>
To: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wf-out-1314.google.com ([209.85.200.174]:3956 "EHLO
	wf-out-1314.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756481AbZC3KYJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 30 Mar 2009 06:24:09 -0400
Received: by wf-out-1314.google.com with SMTP id 29so2511016wff.4
        for <netdev@vger.kernel.org>; Mon, 30 Mar 2009 03:24:07 -0700 (PDT)
In-Reply-To: <OF42785A57.F2F3AFE4-ONC1257589.0035B462-C1257589.003712D0@transmode.se>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Mar 30, 2009 at 6:01 PM, Joakim Tjernlund
<Joakim.Tjernlund@transmode.se> wrote:
> pku.leo@gmail.com wrote on 30/03/2009 11:36:36:
>>
>> On Mon, Mar 30, 2009 at 5:21 PM, Joakim Tjernlund
>> <Joakim.Tjernlund@transmode.se> wrote:
>> > pku.leo@gmail.com wrote on 30/03/2009 10:34:47:
>> >>
>> >> On Thu, Mar 26, 2009 at 1:51 AM, Joakim Tjernlund
>> >> <Joakim.Tjernlund@transmode.se> wrote:
>> >> > Anton Vorontsov <avorontsov@ru.mvista.com> wrote on 25/03/2009
>> > 15:25:40:
>> >> >> On Wed, Mar 25, 2009 at 02:30:49PM +0100, Joakim Tjernlund wro=
te:
>> >> >> > >>From 1c2f23b1f37f4818c0fd0217b93eb38ab6564840 Mon Sep 17
> 00:00:00
>> >> > 2001
>> >> >> > From: Joakim Tjernlund <Joakim.Tjernlund@transmode.se>
>> >> >> > Date: Tue, 24 Mar 2009 10:19:27 +0100
>> >> >> > Subject: [PATCH] ucc_geth: Move freeing of TX packets to NAP=
I
>> > context.
>> >> >> > =C2=A0Also increase NAPI weight somewhat.
>> >> >> > =C2=A0This will make the system alot more responsive while
>> >> >> > =C2=A0ping flooding the ucc_geth ethernet interaface.
>> >> >>
>> >> >> Some time ago I've tried a similar thing for this driver, but
> during
>> >> >> tcp (or udp I don't quite remember) netperf tests I was gettin=
g tx
>> >> >> watchdog timeouts after ~2-5 minutes of work. I was testing wi=
th a
>> >> >> gigabit and 100 Mbit link, with 100 Mbit link the issue was no=
t
>> >> >> reproducible.
>> >> >>
>> >> >> Though, I recalling I was doing a bit more than your patch: I =
was
>> >> >> also clearing the TX events in the ucce register before callin=
g
>> >> >> ucc_geth_tx, that way I was trying to avoid stale interrupts. =
That
>> >> >> helped to increase an overall performance (not only
> responsiveness),
>> >> >> but as I said my approach didn't pass the tests.
>> >> >>
>> >> >> I don't really think that your patch may cause this, but can y=
ou
>> >> >> try netperf w/ this patch applied anyway? And see if it really
>> >> >> doesn't cause any issues under stress?
>> >> >
>> >> > Does the line(in ucc_geth_tx()) look OK to you:
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0if ((bd =3D=3D ugeth->txBd[txQ]) && =
(netif_queue_stopped(dev) =3D=3D
>> > 0))
>> >> > =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =C2=A0 =
=C2=A0 =C2=A0 =C2=A0break;
>> >> >
>> >> > Sure does look fishy to me.
>> >>
>> >> There are two cases when txBd=3DConfBd: the BD ring is full or em=
pty.
>> >> The condition used here ensures that it is the empty case. =C2=A0=
Because
> in
>> >> hard_start_xmit, the queue will be stopped when the BD ring is fu=
ll.
>> >> Maybe some comment is needed here.
>> >
>> > But how do you know that the queue hasn't been stopped by someone =
else
>> > than
>> > the driver?
>> > If it is stopped by higher layers, the if stmt will fail.
>>
>> It looks like from existing code that only the driver can legally st=
op
>> the queue. =C2=A0I'm not 100% sure though. =C2=A0Correct me if I'm w=
rong.
>
> I don't know. But the question you should ask is: Does the networking
> code promise this now and for the future?

Right.  But it's beyond my knowledge to answer this question.  If not,
adding a device specific flag is not very costing.

Hi Dave,

Can we assume that the netif_stop_queue() and netif_wake_queue() are
only used by the netdev driver?  And the queue state will not be
changed by other part of the networking subsystem?

- Leo
