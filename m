From: Michael Tokarev <mjt@tls.msk.ru>
Subject: Re: [Security, resend] Instant crash with rtl8169 and large packets
Date: Mon, 08 Jun 2009 20:26:46 +0400
Message-ID: <4A2D3BC6.3040904@msgid.tls.msk.ru>
References: <4A2D1147.8020101@msgid.tls.msk.ru> <4A2D1FE4.5030100@gmail.com> <4A2D25F6.9080300@msgid.tls.msk.ru> <4A2D2906.6090002@gmail.com> <4A2D301D.9040301@msgid.tls.msk.ru> <4A2D3568.6010901@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1;
	format=flowed
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Linux-kernel <linux-kernel@vger.kernel.org>,
	netdev <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from isrv.corpit.ru ([81.13.33.159]:38957 "EHLO isrv.corpit.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756111AbZFHQ0u (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 8 Jun 2009 12:26:50 -0400
In-Reply-To: <4A2D3568.6010901@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Eric Dumazet wrote:
> Michael Tokarev a =E9crit :
>> Eric Dumazet wrote:
>>> Michael Tokarev a =E9crit :
>> []
>>>>>> The situation is very simple: with an RTL8169 (probably
>>>>>> onboard) GigE card which, by default, is configured to
>>>>>> have MTU (maximal transmission unit) to be 1500 bytes,
>>>>>> it's *trivial* to instantly crash the machine by sending
>>>>>> it a *single* packet of size >1500 bytes (provided the
>>>>>> network switch can handle jumbo frames).
>> []
>>> OK, 2nd try then :)
>>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>>> index e94316b..9080b08 100644
>>> --- a/drivers/net/r8169.c
>>> +++ b/drivers/net/r8169.c
>>> @@ -3495,7 +3495,8 @@ static int rtl8169_rx_interrupt(struct
>>> net_device *dev,
>>>               * frames. They are seen as a symptom of over-mtu
>>>               * sized frames.
>>>               */
>>> -            if (unlikely(rtl8169_fragmented_frame(status))) {
>>> +            if (unlikely(rtl8169_fragmented_frame(status) ||
>>> +                     (unsigned int)pkt_size > tp->rx_buf_sz)) {
>>>                  dev->stats.rx_dropped++;
>>>                  dev->stats.rx_length_errors++;
>>>                  rtl8169_mark_to_asic(desc, tp->rx_buf_sz);
>> This one behaves much better.  There's no instant crash anymore, and=
 the
>> 'dropped' and 'frame' stats in ifconfig gets incremented with each p=
ing.
>>
>> It fails down the line however.  I wasn't able to reply to this emai=
l after
>> doing the ping test with the above change (no more large packets wer=
e
>> sent).
>> With OOPSes like this one:
>>
>>  general protection fault: 0000 [#1] SMP
[]
>>   [<ffffffff803dbc7f>] ? skb_release_data+0xaf/0xe0
>>   [<ffffffff803db911>] ? __kfree_skb+0x11/0xa0
>>   [<ffffffff80418a88>] ? tcp_recvmsg+0x6d8/0x950
[]
>> Looks like some memory corruption.  And most probably it is in
>> that error path in r8169 driver - it is the only new codepath
>> which were executed here.  The problem is quite repeatable -
>> after sending a single large ping system starts behaving like
>> the above at random.
[]
> Hmm... this code path is not new, I believe your adapter is buggy, be=
cause it
> is overwriting part of memory it should not touch at all.
>=20
> When this driver queues a skb in rx queue, it tells NIC the max size =
of the skb,
> and apparently NIC happily delivers packets with larger sizes, so pro=
bably DMA
> wrote data past end of skb data.

That's a very likely situation.

> Try to change=20
>=20
> static void rtl_set_rx_max_size(void __iomem *ioaddr)
>     RTL_W16(RxMaxSize, 16383);=20
>=20
> to ->
>=20
>     RTL_W16(RxMaxSize, RX_BUF_SIZE);
>=20
> (But it will probably break jumbo frames rx as well)

(RX_BUF_SIZE is defined as 1536).
Aha, so it should set some flags instead (as were tested in your
first try), for packets larger than that.  Makes sense.

But if we told the NIC that we can receive 16K buffers, and it
delivered 3K packet to us, we've got some memory corruption...
I.e., the problem is that we told the driver that we can handle
16k buffers but actually we had only 1500, no?

Lemme check this all...

Setting RxMaxSize to RX_BUF_SIZE indeed solved the problem, --
I don't see random corruptions like the last one above.

But after setting RxMaxSize to 2500, I can trigger your 2nd
check/patch condition (for pkt_size > tp->rx_buf_sz) for
packets <2500 in size, and your *first* check/patch condition
(RxRES | RxRWT | RxRUNT | RxCRC | RxFOVF) for packets >2500
in size.

So to me (who has no knowledge about hardware at all), it looks
like the card behaves quite correctly.

Also note that I've seen this behavior on several different
machines.  Here @home where I'm doing this all testing I've
Asus M3A78-EM motherboard (AMD780), and the second one is
Gigabyte GA-MA74GM-S2H (AMD740) - both behaves very similarly.
Both are AMD7xx, but I've seen the same problem on Intel-based
machines too.

I'll try out some more tests later today.  (And there's another
issue with these NICs -- the famous, quite frequent under load
"NETDEV WATCHDOG: eth0 (r8169): transmit timed out" errors, which
are quite annoying... Also shown by both the above-mentioned mobos
and by other machines).

Thanks!

/mjt
