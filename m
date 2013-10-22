From: Giuseppe CAVALLARO <peppe.cavallaro@st.com>
Subject: Re: [PATCH RFC 3/5] net:stmmac: ensure we reclaim all dirty descriptors.
Date: Tue, 22 Oct 2013 15:33:50 +0200
Message-ID: <52667EBE.8050104@st.com>
References: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>  <1381937052-8999-4-git-send-email-jimmy.perchet@parrot.com>  <5264EEE9.8070607@st.com> <526527DE.5060906@parrot.com>  <1382380327.3284.77.camel@edumazet-glaptop.roam.corp.google.com> <1382381375.3284.79.camel@edumazet-glaptop.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"; format=flowed
Content-Transfer-Encoding: 7bit
Cc: <netdev@vger.kernel.org>
To: Eric Dumazet <eric.dumazet@gmail.com>,
	Jimmy PERCHET <jimmy.perchet@parrot.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from eu1sys200aog123.obsmtp.com ([207.126.144.155]:52001 "EHLO
	eu1sys200aog123.obsmtp.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751185Ab3JVNdz (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Oct 2013 09:33:55 -0400
In-Reply-To: <1382381375.3284.79.camel@edumazet-glaptop.roam.corp.google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 10/21/2013 8:49 PM, Eric Dumazet wrote:
> On Mon, 2013-10-21 at 11:32 -0700, Eric Dumazet wrote:
>> On Mon, 2013-10-21 at 15:10 +0200, Jimmy PERCHET wrote:
>>> Hello Peppe,
>>>
>>
>>> I can reproduce this problem by issuing 9KiB jumbo frames on 10MBit/s link.
>>> If socket's wmemory size is about 500kiB (or less), the transfer stall.
>>> (I guess it is reproducible with 1500o frames by decreasing
>>> socket's wmemory to 90KB)
>>> Re-arming the timer fix this behaviour.
>>>
>>> Here my understanding of this issue :
>>> With 9KiB frames and 500kiB of wmemory, only 60 frames can be
>>> prepared in a row. It is below the tx coalescence threshold,
>>> so there will be no interrupt. When the tx coalescence timer
>>> expires (40ms after), only five descriptors have to be
>>> freed (9000*5 @ 10Mbit/s = 34ms), it is not enough to reach
>>> the socket's wake-up threshold. We get into a deadlock :
>>> *Socket is waiting for free buffers before performing new transfer.
>>> *Driver is waiting for new transfer before performing cleanup.
>>>
>>> Maybe, it is not a real life use-case, and is not worth
>>> a patch. What do you think ?
>>>
>>
>> I think there is probably a bug in the driver, a race of some sort,
>> and it would be better to find it and fix it ;)
>>
>
> coalesce params should not be hardcoded, but depend on link speed and
> mtu.
>
> On 10Mbits, and MTU=9000 there is really no point using coalescing !

so the final patch could be to tune/disable the tx coalesce according
to speed and mtu.

Indeed I had added something that can already  help on that.

We can tune the tx_coal_frames and decide to set the IC bit
(interrupt on completion bit) in the frame to be transmitted.
This can be done via ethtool.

This should reduce the mitigation so, for sure, you can tune all in case
of low speed or jumbo. IIRC, you could decide to disable mitigation
at all. To Jimmy, can you try this? In any case, let me know.

Peppe
