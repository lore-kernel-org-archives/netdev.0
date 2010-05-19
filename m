From: Sonic Zhang <sonic.adi@gmail.com>
Subject: Re: [PATCH 06/11] netdev: bfin_mac: avoid tx skb overflows in the tx
	DMA ring
Date: Wed, 19 May 2010 17:23:16 +0800
Message-ID: <AANLkTikKz6v09VTjtANmmcGHU1eKcVWjuDIO24KqkHWK@mail.gmail.com>
References: <1273400337-26501-6-git-send-email-vapier@gentoo.org>
	 <20100510.044035.199023238.davem@davemloft.net>
	 <AANLkTimWjjXKwi_YLFPxBrCBu1qkiuaUKyo1UW5373lH@mail.gmail.com>
	 <20100518.122953.236217958.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f194.google.com ([209.85.222.194]:42199 "EHLO
	mail-pz0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754123Ab0ESJXR convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 May 2010 05:23:17 -0400
Received: by pzk32 with SMTP id 32so2614067pzk.21
        for <netdev@vger.kernel.org>; Wed, 19 May 2010 02:23:16 -0700 (PDT)
In-Reply-To: <20100518.122953.236217958.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, May 19, 2010 at 3:29 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Sonic Zhang <sonic.adi@gmail.com>
> Date: Tue, 18 May 2010 18:52:17 +0800
>
> [ Please never drop the mailing list when you're trying to
> =A0discuss something networking related with me, thanks.
> =A0I've put the CC: back. ]
>
>> On Mon, May 10, 2010 at 7:40 PM, David Miller <davem@davemloft.net> =
wrote:
>>> From: Mike Frysinger <vapier@gentoo.org>
>>> Date: Sun, =A09 May 2010 06:18:52 -0400
>>>
>>>> From: Sonic Zhang <sonic.zhang@analog.com>
>>>>
>>>> Signed-off-by: Sonic Zhang <sonic.zhang@analog.com>
>>>> Signed-off-by: Mike Frysinger <vapier@gentoo.org>
>>>
>>> This should never ever happen, it's a bug and you should print a wa=
rning
>>> message when and if it does actually occur.
>>>
>>> At any point where your ->next pointer hits tx_list_head, the queue
>>> should have been stopped by your driver and therefore the networkin=
g
>>> core will never pass another packet to you.
>>
>> To reduce the tx output overhead, the tx interrupt is not enabled an=
d
>> handled in this driver. So, the driver doesn't know when to restart
>> the tx queue if the queue is stopped in ndo_start_xmit() at the poin=
t
>> where next pointer hits tx_list_head.
>>
>> In this case, although TX buffer list full rarely happens, the check
>> is still a safeguard.
>
> You can't do that, if you don't use the TX interrupt then you can lea=
ve
> SKBs stale in your TX ring for indefinite periods of time which is
> illegal.

No, this doesn't happen, because before ndo_start_xmit() returns, the
old TX buffers and skbs in the ring, which finished DMA operation, are
freed. The only difference is that the free operation of a skb is done
in next tx transfer.

Sonic

>
> SKBs hold onto resources that can't be held indefinitely, such as TCP
> socket references and netfilter conntrack state. =A0So if you leave a
> packet in your TX ring for a long time, there might be a TCP socket
> that now cannot be closed and freed up because of that.
>
> You must therefore free them very as soon as possible after the
> hardware is done with them.
>
