From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: Spurious timeouts in mvmdio
Date: Wed, 04 Dec 2013 00:17:56 +0100
Message-ID: <529E66A4.4050000@gmail.com>
References: <529CA42A.3040504@freebox.fr> <20131203122346.GD29282@titan.lakedaemon.net> <20131203124033.GT16735@n2100.arm.linux.org.uk> <abe249f5cba5c267e2c536bd62c57908@doppler.thel33t.co.uk> <529E5F03.8040607@gmail.com> <8d65780eb7bfe49bb0734a09f05f70a6@doppler.thel33t.co.uk>
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
	Nicolas Schichan <nschichan@freebox.fr>,
	Jason Cooper <jason@lakedaemon.net>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	Florian Fainelli <florian@openwrt.org>,
	"David S. Miller" <davem@davemloft.net>,
	linux-arm-kernel@lists.infradead.org
To: Leigh Brown <leigh@solinno.co.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f180.google.com ([209.85.215.180]:43916 "EHLO
	mail-ea0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753816Ab3LCXSB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Dec 2013 18:18:01 -0500
In-Reply-To: <8d65780eb7bfe49bb0734a09f05f70a6@doppler.thel33t.co.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/04/2013 12:20 AM, Leigh Brown wrote:
> On 2013-12-03 22:45, Sebastian Hesselbarth wrote:
>> On 12/03/2013 09:57 PM, Leigh Brown wrote:
> [...]
>>> Nicolas' patch should fix the issue, but I prefer the following as it is
>>> more
>>> correct, as it only adjusts the timeout when calling
>>> wait_event_timeout().  As
>>> I said above,I believe the polling code is correct.
>>>
>>> diff --git a/drivers/net/ethernet/marvell/mvmdio.c
>>> b/drivers/net/ethernet/marvell/mvmdio.c
>>> index 7354960..b187c08 100644
>>> --- a/drivers/net/ethernet/marvell/mvmdio.c
>>> +++ b/drivers/net/ethernet/marvell/mvmdio.c
>>> @@ -92,6 +92,14 @@ static int orion_mdio_wait_ready(struct mii_bus *bus)
>>>               if (time_is_before_jiffies(end))
>>>                   ++timedout;
>>>               } else {
>>> +            /*
>>> +             * wait_event_timeout does not guarantee a delay of at
>>> +             * least one whole jiffie, so timeout must be no less
>>> +             * than two.
>>> +             */
>>> +            if (timeout < 2)
>>> +                timeout = 2;
>>
>> If you always want to wait at least two jiffies, why not just increase
>> TIMEOUT makro to 20ms instead of messing here with it again?
>> As said on IRC log above, originally timeout was 100ms.
>
> You could do that, but would you not feel bad leaving a latent bug in
> the code?
> I know it's unlikely that someone would set HZ to 50, but if they did,
> the same
> bug would appear again.

If you want to ensure timeout > 2, why not then just use:

- 	unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
+ 	unsigned long timeout = 1 + usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
