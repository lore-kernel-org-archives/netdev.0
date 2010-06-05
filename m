From: =?UTF-8?B?VGltbyBUZXLDpHM=?= <timo.teras@iki.fi>
Subject: Re: [PATCH] Re: still having r8169 woes with XID 18000000
Date: Sat, 05 Jun 2010 12:21:58 +0300
Message-ID: <4C0A1736.9030209@iki.fi>
References: <4C08ED47.1030800@iki.fi>	 <20100604123641.ED8154CD45@orbit.nwl.cc> <4C08F953.1050800@iki.fi>	 <20100604134351.7981F4CD45@orbit.nwl.cc> <4C09387F.1050403@iki.fi>	 <4C09611B.2090805@iki.fi>  <4C09FF4B.4050601@iki.fi> <1275729201.5238.2.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Phil Sutter <phil@nwl.cc>,
	=?UTF-8?B?ZnJhbsOnb2lzIHJvbWlldQ==?= <romieu@fr.zoreil.com>,
	netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ew0-f223.google.com ([209.85.219.223]:52091 "EHLO
	mail-ew0-f223.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932627Ab0FEJV6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 5 Jun 2010 05:21:58 -0400
Received: by ewy23 with SMTP id 23so509794ewy.1
        for <netdev@vger.kernel.org>; Sat, 05 Jun 2010 02:21:57 -0700 (PDT)
In-Reply-To: <1275729201.5238.2.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 06/05/2010 12:13 PM, Eric Dumazet wrote:
> Le samedi 05 juin 2010 =C3=A0 10:39 +0300, Timo Ter=C3=A4s a =C3=A9cr=
it :
>> Ok, I compared Realtek's and the in-tree driver. The only essential
>> difference is that Realtek driver uses udelay(100) in mdio_write()'s
>> busy polling loop where as the in-tree uses udelay(25). And that see=
ms
>> to be the magic difference! Using udelay(100) fixes this!
>>
>> I'm guessing that the phy needs slight delay between consecutive
>> mdio_write's even if it has advertised that the write has been
>> completed. And yes, just adding a small delay in the end of mdio_wri=
te
>> does seem to work too.
>>
>> Francois, you think the below patch is ok? Should I send it as prope=
rly
>> formatted commit?
>>
>> diff --git a/drivers/net/r8169.c b/drivers/net/r8169.c
>> index 217e709..6db62bf 100644
>> --- a/drivers/net/r8169.c
>> +++ b/drivers/net/r8169.c
>> @@ -559,6 +559,7 @@ static void mdio_write(void __iomem *ioaddr,
>>  			break;
>>  		udelay(25);
>>  	}
>> +	udelay(25);
>>  }
>>
>>  static int mdio_read(void __iomem *ioaddr, int reg_addr)
>> --
>=20
> Sure this deserves an official patch with all prereqs, but please add=
 a
> comment in mdio_write() why this extra udelay(25) is needed, especial=
ly
> since you say of udelay(100) 'fixes the bug'.

Uh, yes. The intention was to get feedback if this is the proper place
for the delay. I first thought that maybe we could just add the delay t=
o
the phy config function writing the values in tight loop... but as it
appears even some other mdio_writes seem to fail, this seems to be the
logical and correct place.

Alternatively, I was thinking if someone had specs to check if they say
anything about delay needed between mdio writes.

Reason why adding new delay in the end of the function is better is
because using udelay(100) in the loop means that anything between
0..100us has elapsed after the "write complete" is acked; if very
unlucky the "write complete" happens just after our udelay has ended an=
d
there would be no delay between next mdio write.

Adding the additional udelay(25) in the end guarantees small delay
between "write complete" ack and the next write. And yes, it needs a
comment.

I'll send a new patch shortly.
