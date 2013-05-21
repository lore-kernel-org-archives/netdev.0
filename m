From: David Hauweele <david@hauweele.net>
Subject: Re: [Linux-zigbee-devel] [PATCH 2/2] mrf24j40: Keep the interrupt
 line enabled
Date: Tue, 21 May 2013 18:17:34 +0200
Message-ID: <CAO+c-UXymPjYysvh2kM36gcOsL3P51YWq+aYhEqX8oCySwBcaQ@mail.gmail.com>
References: <1368112788-25701-1-git-send-email-david@hauweele.net>
	<1368112788-25701-2-git-send-email-david@hauweele.net>
	<5191B5C4.2020609@signal11.us>
	<CAO+c-UWi5UH-ZN5G0JiJCrCrScaYprKT7jLpFH0wEJecgoHgig@mail.gmail.com>
	<51995A78.20207@signal11.us>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: Alexander Smirnov <alex.bluesman.smirnov@gmail.com>,
	Dmitry Eremin-Solenikov <dbaryshkov@gmail.com>,
	linux-zigbee-devel@lists.sourceforge.net, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
To: Alan Ott <alan@signal11.us>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <51995A78.20207@signal11.us>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2013/5/20 Alan Ott <alan@signal11.us>:
> On 05/16/2013 05:34 PM, David Hauweele wrote:
>> I have seen the interrupt line going low forever with heavy traffic.
>
> Hi David,
>
> I've been doing some testing today and I can reproduce your issue if I
> ping -f both ways simultaneously (after about 3-4 minutes usually). I
> think it has more to do with the tx/rx mutual exclusion that you
> described in patch 1/1 than it does with the disable/enable IRQ. With
> respect to enable/disable irq, I did some checking of other similar
> drivers (non-ieee802154) and noticed that many of them use threaded
> interrupts. I think this may be closer to the right way to do it.

Hi Alan,

Indeed, threaded interrupts would be more appropriate.
What about spi_async ? We could avoid using any working queue with this call.
Although the driver would need a major rewrite and I've no clue about
the benefits of doing so.
I wonder how much additional latency is introduced by the working
queue, I will try to measure this today.

>
> Are you running a tickless kernel? What is your preemption model? What's
> your hardware platform?

This is a tickless kernel with CONFIG_PREEMPT on an RPi.

>
>> The at86rf230 driver has two isr, one for edge-triggered and another
>> for level-triggered interrupt. The latter uses
>> disable_irq_nosync/enable_irq which makes sense for level-triggered
>> interrupt. Otherwise the interrupt would be triggered again and again
>> until the scheduled work read the status register.
>>
>> However I don't see the use of disable_irq/enable_irq with an
>> edge-triggered interrupt. Perhaps I'm missing something. Though I
>> don't see any harm using it anyway.
>
> My understanding based on the datasheet is that the interrupt can be
> asserted again as soon as INTSTAT is read (which is done in the
> workqueue). I guess even if it happens while the workqueue is running,
> it's ok.

You're right, as soon as INTSTAT is read, the line should be driven
high again to assert another interrupt.
So it shouldn't pose any problem if the interrupts are replayed by the
kernel. What may happen however is
an error in the spi transfer. This would result in the line staying
low since the register hasn't really been read.
This is what I observed at the hardware level.

If this is the case, then the problem should also occurs with and
without disable/enable_irq. However this bug
is a bit harder to reproduce as it may take several hours. The only
solution I see would be to regularly poll the
INTSTAT register for recovering. I know about other drivers which do
this so I will look into this and work on a fix.

>
> I think I had a flawed understanding of schedule_work() before, thinking
> that it would not schedule a work_struct it if the work_struct was running.
>
>>  As you said the interrupt should
>> be delayed until enable_irq() is called. In particular when
>> CONFIG_HARDIRQS_SW_RESEND is set.
>
> I think I agree with you. I'll send you a patch to try with threaded
> interrupts to try.
>
> I'm trying to determine exactly what's the cause of the interrupt line
> being stuck low.
>

I tried your patch for INIT_COMPLETION. It doesn't fix the problem but
I agree with you for the race condition.

David

>>
>> 2013/5/14 Alan Ott <alan@signal11.us>:
>>> On 5/9/13 11:19 AM, David Hauweele wrote:
>>>> Disabling the interrupt line could miss an IRQ and leave the line into a
>>>> low state hence locking the driver.
>>>>
>>> Have you observed this? My understanding is that the interrupt won't be lost
>>> but instead delayed until enable_irq() is called.
>>>
>>> I got this pattern from the other 802.15.4 drivers. Perhaps my understanding
>>> is wrong.
>>>
>>>
>>>
>>>> Signed-off-by: David Hauweele <david@hauweele.net>
>>>> ---
>>>>   drivers/net/ieee802154/mrf24j40.c |    7 +------
>>>>   1 file changed, 1 insertion(+), 6 deletions(-)
>>>>
>>>> diff --git a/drivers/net/ieee802154/mrf24j40.c
>>>> b/drivers/net/ieee802154/mrf24j40.c
>>>> index 1e3ddf3..6ef32f7 100644
>>>> --- a/drivers/net/ieee802154/mrf24j40.c
>>>> +++ b/drivers/net/ieee802154/mrf24j40.c
>>>> @@ -603,8 +603,6 @@ static irqreturn_t mrf24j40_isr(int irq, void *data)
>>>>   {
>>>>         struct mrf24j40 *devrec = data;
>>>>
>>>> -       disable_irq_nosync(irq);
>>>> -
>>>>         schedule_work(&devrec->irqwork);
>>>>
>>>>         return IRQ_HANDLED;
>>>> @@ -619,7 +617,7 @@ static void mrf24j40_isrwork(struct work_struct *work)
>>>>         /* Read the interrupt status */
>>>>         ret = read_short_reg(devrec, REG_INTSTAT, &intstat);
>>>>         if (ret)
>>>> -               goto out;
>>>> +               return;
>>>>
>>>>         /* Check for TX complete */
>>>>         if (intstat & 0x1)
>>>> @@ -628,9 +626,6 @@ static void mrf24j40_isrwork(struct work_struct *work)
>>>>         /* Check for Rx */
>>>>         if (intstat & 0x8)
>>>>                 schedule_work(&devrec->rxwork);
>>>> -
>>>> -out:
>>>> -       enable_irq(devrec->spi->irq);
>>>>   }
>>>>
>>>>   static void mrf24j40_rxwork(struct work_struct *work)
>>>>
>
>
