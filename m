From: Sebastian Hesselbarth <sebastian.hesselbarth@gmail.com>
Subject: Re: Spurious timeouts in mvmdio
Date: Wed, 04 Dec 2013 00:45:58 +0100
Message-ID: <529E6D36.40606@gmail.com>
References: <529CA42A.3040504@freebox.fr>
 <20131203122346.GD29282@titan.lakedaemon.net>
 <20131203124033.GT16735@n2100.arm.linux.org.uk>
 <abe249f5cba5c267e2c536bd62c57908@doppler.thel33t.co.uk>
 <529E5F03.8040607@gmail.com>
 <8d65780eb7bfe49bb0734a09f05f70a6@doppler.thel33t.co.uk>
 <529E66A4.4050000@gmail.com>
 <ae69666fd3b61411d7bbd9ac993cec13@doppler.thel33t.co.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"; Format="flowed"
Content-Transfer-Encoding: 7bit
Cc: Russell King - ARM Linux <linux@arm.linux.org.uk>,
 Jason Cooper <jason@lakedaemon.net>, Nicolas Schichan <nschichan@freebox.fr>,
 netdev@vger.kernel.org, LKML <linux-kernel@vger.kernel.org>,
 "David S. Miller" <davem@davemloft.net>,
 Florian Fainelli <florian@openwrt.org>, linux-arm-kernel@lists.infradead.org
To: Leigh Brown <leigh@solinno.co.uk>
Return-path: <linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org>
In-Reply-To: <ae69666fd3b61411d7bbd9ac993cec13@doppler.thel33t.co.uk>
List-Unsubscribe: <http://lists.infradead.org/mailman/options/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=unsubscribe>
List-Archive: <http://lists.infradead.org/pipermail/linux-arm-kernel/>
List-Post: <mailto:linux-arm-kernel@lists.infradead.org>
List-Help: <mailto:linux-arm-kernel-request@lists.infradead.org?subject=help>
List-Subscribe: <http://lists.infradead.org/mailman/listinfo/linux-arm-kernel>,
 <mailto:linux-arm-kernel-request@lists.infradead.org?subject=subscribe>
Sender: "linux-arm-kernel" <linux-arm-kernel-bounces@lists.infradead.org>
Errors-To: linux-arm-kernel-bounces+linux-arm-kernel=m.gmane.org@lists.infradead.org
List-Id: netdev.vger.kernel.org

On 12/04/2013 12:38 AM, Leigh Brown wrote:
> On 2013-12-03 23:17, Sebastian Hesselbarth wrote:
>> On 12/04/2013 12:20 AM, Leigh Brown wrote:
>>> On 2013-12-03 22:45, Sebastian Hesselbarth wrote:
>>>> On 12/03/2013 09:57 PM, Leigh Brown wrote:
>>> [...]
>>>>> Nicolas' patch should fix the issue, but I prefer the following as
>>>>> it is
>>>>> more
>>>>> correct, as it only adjusts the timeout when calling
>>>>> wait_event_timeout().  As
>>>>> I said above,I believe the polling code is correct.
>>>>>
>>>>> diff --git a/drivers/net/ethernet/marvell/mvmdio.c
>>>>> b/drivers/net/ethernet/marvell/mvmdio.c
>>>>> index 7354960..b187c08 100644
>>>>> --- a/drivers/net/ethernet/marvell/mvmdio.c
>>>>> +++ b/drivers/net/ethernet/marvell/mvmdio.c
>>>>> @@ -92,6 +92,14 @@ static int orion_mdio_wait_ready(struct mii_bus
>>>>> *bus)
>>>>>               if (time_is_before_jiffies(end))
>>>>>                   ++timedout;
>>>>>               } else {
>>>>> +            /*
>>>>> +             * wait_event_timeout does not guarantee a delay of at
>>>>> +             * least one whole jiffie, so timeout must be no less
>>>>> +             * than two.
>>>>> +             */
>>>>> +            if (timeout < 2)
>>>>> +                timeout = 2;
>>>>
>>>> If you always want to wait at least two jiffies, why not just increase
>>>> TIMEOUT makro to 20ms instead of messing here with it again?
>>>> As said on IRC log above, originally timeout was 100ms.
>>>
>>> You could do that, but would you not feel bad leaving a latent bug in
>>> the code?
>>> I know it's unlikely that someone would set HZ to 50, but if they did,
>>> the same
>>> bug would appear again.
>>
>> If you want to ensure timeout > 2, why not then just use:
>>
>> -     unsigned long timeout = usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
>> +     unsigned long timeout = 1 + usecs_to_jiffies(MVMDIO_SMI_TIMEOUT);
>
> This will make it correct when using interrupts but it will make the
> loop wait one
> jiffie longer than it should when polling.

Leigh,

it is not about "waiting longer than it should" but increasing the
_timeout_ to more than one jiffy. If you poll and everything is fine
with mdio, you exit way before timeout. If mdio hangs, it does not
really matter if you timeout after 10, 20, or even 100ms.

Anyway, I am fine with every patch that increases timeout to more than
one jiffy. Also, Russell just sent a patch to separate irq/polling
completely. Maybe give it a try.

Sebastian
