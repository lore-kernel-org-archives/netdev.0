From: Tzungder Lin <tzungder@gmail.com>
Subject: Re: Probably a flaw in Linux rtl8139 driver FYI
Date: Sat, 18 Apr 2009 23:28:13 +0800
Message-ID: <528f811a0904180828i6b414a10p2dda1a7cbb79db87@mail.gmail.com>
References: <528f811a0904170008q34b5cde1l810fb22f78eefaf7@mail.gmail.com>
	 <528f811a0904170010w2b2c8b34j698b255331f78765@mail.gmail.com>
	 <528f811a0904180540t15489826n99cf8143fe105463@mail.gmail.com>
	 <49E9CF3C.2090308@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, davem@davemloft.net
To: Eric Dumazet <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rv-out-0506.google.com ([209.85.198.224]:52039 "EHLO
	rv-out-0506.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753408AbZDRP2O convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 18 Apr 2009 11:28:14 -0400
Received: by rv-out-0506.google.com with SMTP id b25so689521rvf.5
        for <netdev@vger.kernel.org>; Sat, 18 Apr 2009 08:28:13 -0700 (PDT)
In-Reply-To: <49E9CF3C.2090308@cosmosbay.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Dear Eric,

I agree with you at first.
But after I checked the driver code, I think tp->cur_rx has been set
to zero in rtl8139_init_ring() which has been executed before
rtl8139_hw_start().
So, it should be safe already.
Thanks for your advice still.
=46YR

Regards
  jonathan

On Sat, Apr 18, 2009 at 9:01 PM, Eric Dumazet <dada1@cosmosbay.com> wro=
te:
> Tzungder Lin a =E9crit :
>> Dear Sirs,
>>
>> Hello, I am jon from Taiwan.
>> First I want to thank you for your great contributions of open sourc=
e.
>> Thank you for your 8139 driver to make our world better.
>>
>> Here is what happens:
>> While I am debugging our Embedded Linux SoC I found a flaw in Linux
>> 8139 driver (8139too.c) ,probably.
>> If I attack (interval < 10ms) the driver with broadcast packets
>> (mac.destaddr =3D=3D ff:ff:ff:ff:ff:ff) when network interface up (i=
fconfig
>> eth0 up) at the first time, the kernel space memory will be corrupte=
d
>> (overwrited with packet content) start from 0xc03e8800.
>> Then kernel panics.
>>
>> Here is what I discovered:
>> While ifconfig eth0 up kernel calls open() of 8139 driver(8139too.c)=
=2E
>> In rtl8139_hw_start() of rtl8139_open(), 8139 driver enable RX befor=
e
>> setting up the DMA buffer
>> address.
>> Therefore in this interval where RX was enabled and DMA buffer addre=
ss
>> is not yet set up, any incoming broadcast packet would be send to a =
strange
>> physical address: 0x003e8800 which is the default value of DMA buffe=
r address.
>> Unfortunately, this address is in Linux kernel used by kmem_cache fu=
nctions.
>> So, kernel panics. I have tried to fix the driver by setting up DMA
>> buffer address
>> before RX enabled and everything is fine.
>>
>> I have checked 8139too.c in both 2.4.x kernel and 2.6.x kernel, they
>> both have the same initial flow.
>> Here is a simple patch to show you what I found.
>>
>> --- 8139too.c =A0 2007-12-13 15:54:26.000000000 +0800
>> +++ 8139too_patch.c =A0 =A0 2009-04-17 14:56:27.000000000 +0800
>> @@ -1382,6 +1382,10 @@
>> =A0 =A0 =A0 =A0RTL_W32_F (MAC0 + 0, cpu_to_le32 (*(u32 *) (dev->dev_=
addr + 0)));
>> =A0 =A0 =A0 =A0RTL_W32_F (MAC0 + 4, cpu_to_le32 (*(u32 *) (dev->dev_=
addr + 4)));
>>
>> + =A0 =A0 =A0 /* init Rx ring buffer DMA address */
>> + =A0 =A0 =A0 /* init before Rx enabled to avoid broadcast packet at=
tack in
>> this interval */
>> + =A0 =A0 =A0 RTL_W32_F (RxBuf, tp->rx_ring_dma);
>> +
>> =A0 =A0 =A0 =A0/* Must enable Tx/Rx before setting transfer threshol=
ds! */
>> =A0 =A0 =A0 =A0RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
>>
>> @@ -1405,8 +1409,6 @@
>> =A0 =A0 =A0 =A0/* Lock Config[01234] and BMCR register writes */
>> =A0 =A0 =A0 =A0RTL_W8 (Cfg9346, Cfg9346_Lock);
>>
>> - =A0 =A0 =A0 /* init Rx ring buffer DMA address */
>> - =A0 =A0 =A0 RTL_W32_F (RxBuf, tp->rx_ring_dma);
>>
>> =A0 =A0 =A0 =A0/* init Tx buffer DMA addresses */
>> =A0 =A0 =A0 =A0for (i =3D 0; i < NUM_TX_DESC; i++)
>>
>> Hope this can make the driver more robust.
>> FYR
>> Thanks a lot!
>>
>> Regards
>> =A0Jonathan Lin @Taiwan
>> =A02009.4.18
>
> Hello Jonathan
>
> This seems a nice catch !
>
> What about also initializing tp->cur_rx =3D 0 *before* enabling RX to=
o ?
>
> So after patch we should have :
>
> =A0 =A0 =A0 =A0tp->cur_rx =3D 0;
> =A0 =A0 =A0 =A0RTL_W32_F (RxBuf, tp->rx_ring_dma);
> =A0 =A0 =A0 =A0/* Must enable Tx/Rx before setting transfer threshold=
s! */
> =A0 =A0 =A0 =A0RTL_W8 (ChipCmd, CmdRxEnb | CmdTxEnb);
>
> Everything should be setup before enable RX interrupts coming...
>
>
>
