From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: b44: Reset due to FIFO overflow.
Date: Tue, 29 Jun 2010 07:17:58 +0200
Message-ID: <1277788678.4235.1285.camel@edumazet-laptop>
References: <AANLkTinwnTw3Yqy3POghliZDRmRYUfJL6Gy67GNNLiYv@mail.gmail.com>
	 <1277716394.4235.235.camel@edumazet-laptop>
	 <5E7CE189-1002-4723-ACB2-D537B71BA5F3@earthlink.net>
	 <1277719251.4235.306.camel@edumazet-laptop>
	 <AANLkTimK4mGdsSq206aqfusXPvnQczbYDlOWSYXAbOQJ@mail.gmail.com>
	 <1277723370.4235.388.camel@edumazet-laptop>
	 <ED315045-4A5D-4ECA-99C8-06B4714D8FA0@earthlink.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: James Courtier-Dutton <james.dutton@gmail.com>,
	netdev@vger.kernel.org
To: Mitchell Erblich <erblichs@earthlink.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:60075 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751069Ab0F2FSE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Jun 2010 01:18:04 -0400
Received: by wyb38 with SMTP id 38so2383715wyb.19
        for <netdev@vger.kernel.org>; Mon, 28 Jun 2010 22:18:02 -0700 (PDT)
In-Reply-To: <ED315045-4A5D-4ECA-99C8-06B4714D8FA0@earthlink.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le lundi 28 juin 2010 =C3=A0 14:21 -0700, Mitchell Erblich a =C3=A9crit=
 :
> On Jun 28, 2010, at 4:09 AM, Eric Dumazet wrote:
>=20
> > Le lundi 28 juin 2010 =C3=A0 11:17 +0100, James Courtier-Dutton a =C3=
=A9crit :
> >> On 28 June 2010 11:00, Eric Dumazet <eric.dumazet@gmail.com> wrote=
:
> >>>=20
> >>> Problem is we receive a spike of RX network frames (possibly UDP =
or some
> >>> other RX only trafic), and chip raises an RX fifo overflow _error=
_
> >>> indication.
> >>>=20
>=20
> IMO, spikes are a normal behaviour.

Yes, this is why I said NIC is buggy, if it requires a reset (lasting a
_very_ long time) on a normal condition.

>=20
> >>=20
> >> The cause of the RX overflow is in my case is TCP.
> >> It is reproducible in mythtv.
> >> While watching LiveTV, press "s" for the program guide.
> >> The program guide is implemented into mythtv by a SQL query that
> >> results in a large response.
> >> The kernel is probably not servicing the RX FIFO quickly enough du=
e to
> >> it being busy doing something else. In this case, probably a video
> >> mode switch.
> >>=20
> >=20
> > Thats strange, b44 has a big RX ring... and tcp sender should wait =
for
> > ACK...
> >=20
>=20
> Slow start, etc SHOULD/CAN  double the number of in-flight segments i=
n each
> next round-trip, placing them back to back.
>=20

rx ring buffer is about 200 frames on b44. One single tcp flow should
fit.

Limit is 511. James, did you try to increase rx ring ?

ethtool -G eth0 rx 511

> IMO,  a stress test, would be a large number/wirespeed set of pings?
>=20

Better is to use frames that are going to slow down receiver.
Say multicast trafic with 100 receivers on same multicast group.
Send 1000 consecutive frames, last ones will trigger RX overflow,
because softirq handler cannot be fast enough.

Ping is answered by kernel, its pretty fast.

> >>> Some hardware are buggy enough that such error indication is fata=
l and
> >>> _require_ hardware reset. Thats life. I suspect b44 driver doing =
a full
> >>> reset is not a random guess from driver author, but to avoid a co=
mplete
> >>> NIC lockup.
> >>>=20
> >>=20
> >> Interesting, which hardware, apart from the b44, is it that "requi=
res"
> >> a hardware reset after a RX FIFO overflow.
> >=20
> > Just take a look at some net drivers and you'll see some of them ha=
ve
> > this requirement.
> >=20
> > rtl8169_rx_interrupt()
> > ...
> > 	if (status & RxFOVF) {
> > 		rtl8169_schedule_work(dev, rtl8169_reset_task);
> > 		dev->stats.rx_fifo_errors++;
> > 	}
> >=20
> >=20
> >=20
> >=20
>=20
>=20
> If they can reset in say X frame loss units, then why not reset if
> X is an acceptable number?
>=20

Because a reset is an exception. While card is reset, we lose many tx
and rx frames and this should be the very last thing to consider.

Why not a complete reboot of the host while we are at it ?

> And a hammer may fix the dent, while I may be more
> interested in preventing the dent in the first place.

So ? Please submit an alternative firmware for this NIC, or provide
another NIC on thousand of machines that are stuck with it.



