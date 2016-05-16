From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH -next v2 3/4] net: w5100: increase TX timeout period
Date: Mon, 16 May 2016 22:53:41 +0900
Message-ID: <CAC5umygRFn0vV9pRds45w2eXGfjZAnUn9Jg1De7khmLt0s5jCA@mail.gmail.com>
References: <1463205350-7089-1-git-send-email-akinobu.mita@gmail.com>
 <1463205350-7089-4-git-send-email-akinobu.mita@gmail.com> <063D6719AE5E284EB5DD2968C1650D6D5F4BF7F1@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Mike Sinkovsky <msink@permonline.ru>,
	"David S . Miller" <davem@davemloft.net>
To: David Laight <David.Laight@aculab.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qg0-f67.google.com ([209.85.192.67]:34583 "EHLO
	mail-qg0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751738AbcEPNyC (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 May 2016 09:54:02 -0400
Received: by mail-qg0-f67.google.com with SMTP id e35so13659923qge.1
        for <netdev@vger.kernel.org>; Mon, 16 May 2016 06:54:01 -0700 (PDT)
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6D5F4BF7F1@AcuExch.aculab.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2016-05-16 18:33 GMT+09:00 David Laight <David.Laight@aculab.com>:
> From: netdev-owner@vger.kernel.org Akinobu Mita
>> Sent: 14 May 2016 06:56
>> This increases TX timeout period from one second to 5 seconds which is
>> the default value if the driver doesn't explicitly set
>> net_device->watchdog_timeo.
>>
>> The one second timeout is too short for W5100 with SPI interface mode
>> which doesn't support burst READ/WRITE processing in the SPI transfer.
>> If the packet is transmitted while RX packets are being received at a
>> very high rate, the TX transmittion work in the workqueue is delayed
>> and the watchdog timer is expired.
>
> ISTM that if RX traffic can cause a 1 second timeout to expire I can
> see no reason why it shouldn't also cause a 5 second timer to expire.
>
> I'm guessing that something needs to be done to cause the SPI
> block to discard receive frames (I guess the hardware will be discarding
> them as well) in order to allow frames to be transmitted.

You are right.  In SPI interface mode, the interrupt of W5100 is masked
as far as receiving packets in w5100_rx_work(). (Ideally, RECV interrupt
should only be masked as W5200 and W5500 have different interrupt mask
bits for RECV and SENDOK, but W5100 doesn't have)

So this problem should be fixed by limiting the maximum execution time
of w5100_rx_skb() in w5100_rx_work() by maximum loop count or querying
jiffies.  I'll try it out.

> Given the 'damp string' nature of SPI, you might even want to give
> transmits priority over receives.

How can we do this?
