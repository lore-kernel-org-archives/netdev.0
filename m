From: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
Subject: Re: [PATCH 1/2] cs89x0_platform : Use ioread16/iowrite16 instead of inw/outw
Date: Thu, 3 May 2012 22:55:44 +0200
Message-ID: <CAGzjT4cUPuwHQ-46saDWdFjweekWrYt7TTJMsUORGXd8FdLpLQ@mail.gmail.com>
References: <1335779839-30420-1-git-send-email-jaccon.bastiaansen@gmail.com>
	<201204301419.27119.arnd@arndb.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: s.hauer@pengutronix.de, gfm@funxed.com, davem@davemloft.net,
	festevam@gmail.com, linux-arm-kernel@lists.infradead.org,
	kernel@pengutronix.de, netdev@vger.kernel.org
To: Arnd Bergmann <arnd@arndb.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:56866 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754494Ab2ECUzq convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 May 2012 16:55:46 -0400
Received: by yhmm54 with SMTP id m54so2218376yhm.19
        for <netdev@vger.kernel.org>; Thu, 03 May 2012 13:55:46 -0700 (PDT)
In-Reply-To: <201204301419.27119.arnd@arndb.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Arnd,

2012/4/30 Arnd Bergmann <arnd@arndb.de>:
> On Monday 30 April 2012, Jaccon Bastiaansen wrote:
>> The use of the inw/outw functions by the cs89x0 platform driver
>> results in NULL pointer references.
>>
>> Signed-off-by: Jaccon Bastiaansen <jaccon.bastiaansen@gmail.com>
>> ---
>> =A0drivers/net/ethernet/cirrus/cs89x0.c | =A0 12 ++++++++++++
>> =A01 files changed, 12 insertions(+), 0 deletions(-)
>
> It's actually broken on most platforms already, and the #ifdef is
> about to go away since IXP2xxx is getting removed in v3.5.
>
>> diff --git a/drivers/net/ethernet/cirrus/cs89x0.c b/drivers/net/ethe=
rnet/cirrus/cs89x0.c
>> index b9406cb..95737e9 100644
>> --- a/drivers/net/ethernet/cirrus/cs89x0.c
>> +++ b/drivers/net/ethernet/cirrus/cs89x0.c
>> @@ -369,6 +369,18 @@ writeword(unsigned long base_addr, int portno, =
u16 value)
>> =A0{
>> =A0 =A0 =A0 =A0 __raw_writel(value, base_addr + (portno << 1));
>> =A0}
>> +#elif defined(CONFIG_CS89x0_PLATFORM)
>> +static u16
>> +readword(unsigned long base_addr, int portno)
>> +{
>> + =A0 =A0 =A0 return ioread16(base_addr + portno);
>> +}
>> +
>> +static void
>> +writeword(unsigned long base_addr, int portno, u16 value)
>> +{
>> + =A0 =A0 =A0 iowrite16(value, base_addr + portno);
>> +}
>> =A0#else
>> =A0static u16
>> =A0readword(unsigned long base_addr, int portno)
>
> I think the best solution would be to always using ioread32/iowrite32
> in the #else path, and change the ISA code to do an ioport_map
> for the base address, passing around the virtual address as an __iome=
m
> pointer.
>
> =A0 =A0 =A0 =A0Arnd
> --

So if I understand you correctly you would like to have an
iopart_map() call in the cs89x0_probe() function and use the return
value of that iopart_map() call as ioaddr parameter of the
cs89x0_probe1() function. Is this correct? This would make the
cs89x0_probe() function similar to the cs89x0_platform_probe()
function where the return value of the ioremap() call is used as
ioaddr parameter of the cs89x0_probe1() function.

But why do you want to convert the current 16 bit accesses in the
#else path to 32 bit accesses? Why not using ioread16()/iowrite16()?


Regards,
  Jaccon
