From: David Miller <davem@davemloft.net>
Subject: Re: [PATCH 06/11] netdev: bfin_mac: avoid tx skb overflows in the
 tx DMA ring
Date: Tue, 18 May 2010 12:29:53 -0700 (PDT)
Message-ID: <20100518.122953.236217958.davem@davemloft.net>
References: <1273400337-26501-6-git-send-email-vapier@gentoo.org>
	<20100510.044035.199023238.davem@davemloft.net>
	<AANLkTimWjjXKwi_YLFPxBrCBu1qkiuaUKyo1UW5373lH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: sonic.adi@gmail.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:48077
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1758024Ab0ERT3o convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 18 May 2010 15:29:44 -0400
In-Reply-To: <AANLkTimWjjXKwi_YLFPxBrCBu1qkiuaUKyo1UW5373lH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Sonic Zhang <sonic.adi@gmail.com>
Date: Tue, 18 May 2010 18:52:17 +0800

[ Please never drop the mailing list when you're trying to
  discuss something networking related with me, thanks.
  I've put the CC: back. ]

> On Mon, May 10, 2010 at 7:40 PM, David Miller <davem@davemloft.net> w=
rote:
>> From: Mike Frysinger <vapier@gentoo.org>
>> Date: Sun, =A09 May 2010 06:18:52 -0400
>>
>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>
>>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>>
>> This should never ever happen, it's a bug and you should print a war=
ning
>> message when and if it does actually occur.
>>
>> At any point where your ->next pointer hits tx_list_head, the queue
>> should have been stopped by your driver and therefore the networking
>> core will never pass another packet to you.
>=20
> To reduce the tx output overhead, the tx interrupt is not enabled and
> handled in this driver. So, the driver doesn't know when to restart
> the tx queue if the queue is stopped in ndo_start_xmit() at the point
> where next pointer hits tx_list_head.
>=20
> In this case, although TX buffer list full rarely happens, the check
> is still a safeguard.

You can't do that, if you don't use the TX interrupt then you can leave
SKBs stale in your TX ring for indefinite periods of time which is
illegal.

SKBs hold onto resources that can't be held indefinitely, such as TCP
socket references and netfilter conntrack state.  So if you leave a
packet in your TX ring for a long time, there might be a TCP socket
that now cannot be closed and freed up because of that.

You must therefore free them very as soon as possible after the
hardware is done with them.
