From: Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>
Subject: Re: [PATCH 2/2] mrf24j40: Keep the interrupt
 line enabled
Date: Tue, 21 May 2013 14:22:55 -0400
Message-ID: <519BBB7F.5000900@signal11.us>
References: <1368112788-25701-1-git-send-email-david@hauweele.net>
	<1368112788-25701-2-git-send-email-david@hauweele.net>
	<5191B5C4.2020609@signal11.us>
	<CAO+c-UWi5UH-ZN5G0JiJCrCrScaYprKT7jLpFH0wEJecgoHgig@mail.gmail.com>
	<51995A78.20207@signal11.us>
	<CAO+c-UXymPjYysvh2kM36gcOsL3P51YWq+aYhEqX8oCySwBcaQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
In-Reply-To: <CAO+c-UXymPjYysvh2kM36gcOsL3P51YWq+aYhEqX8oCySwBcaQ-JsoAwUIsXosN+BqQ9rBEUg@public.gmane.org>
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

On 05/21/2013 12:17 PM, David Hauweele wrote:
> 2013/5/20 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>:
>> On 05/16/2013 05:34 PM, David Hauweele wrote:
>>> I have seen the interrupt line going low forever with heavy traffic.
>> I've been doing some testing today and I can reproduce your issue if I
>> ping -f both ways simultaneously (after about 3-4 minutes usually). I
>> think it has more to do with the tx/rx mutual exclusion that you
>> described in patch 1/1 than it does with the disable/enable IRQ. With
>> respect to enable/disable irq, I did some checking of other similar
>> drivers (non-ieee802154) and noticed that many of them use threaded
>> interrupts. I think this may be closer to the right way to do it.
> Indeed, threaded interrupts would be more appropriate.
> What about spi_async ? We could avoid using any working queue with this call.
> Although the driver would need a major rewrite and I've no clue about
> the benefits of doing so.
> I wonder how much additional latency is introduced by the working
> queue, I will try to measure this today.

Async would be really difficult since we need the values that are read
in order to know what to write in later calls (like where we need to set
one bit in a register). It's hard to imagine doing this without blocking
somewhere, and we might as well use the blocking mechanisms that the
kernel gives us.

>> Are you running a tickless kernel? What is your preemption model? What's
>> your hardware platform?
> This is a tickless kernel with CONFIG_PREEMPT on an RPi.

As another data point, can you try with voluntary preemption and see if
the behavior changes?

>>> The at86rf230 driver has two isr, one for edge-triggered and another
>>> for level-triggered interrupt. The latter uses
>>> disable_irq_nosync/enable_irq which makes sense for level-triggered
>>> interrupt. Otherwise the interrupt would be triggered again and again
>>> until the scheduled work read the status register.
>>>
>>> However I don't see the use of disable_irq/enable_irq with an
>>> edge-triggered interrupt. Perhaps I'm missing something. Though I
>>> don't see any harm using it anyway.
>> My understanding based on the datasheet is that the interrupt can be
>> asserted again as soon as INTSTAT is read (which is done in the
>> workqueue). I guess even if it happens while the workqueue is running,
>> it's ok.
> You're right, as soon as INTSTAT is read, the line should be driven
> high again to assert another interrupt.

This is where I think I've found another race condition. In doing some
testing with the mrf24j40 from PIC24 firmware last night, I think I've
discovered that it's possible for the interrupt line to _not_ get reset
(de-asserted). I think what may be causing it is if an interrupt occurs
at the same time as (or right shortly after) INTSTAT is read. It's easy
to imagine the interrupt line not being able to get all the way up
before coming back down. I have a support email into Microchip asking
specifically about this case.

In my firmware, I'm able to see a case where the INTSTAT register shows
non-zero (ie: an interrupt is pending), yet the interrupt flag is not
set. It seems like it takes about 30 minutes for this to happen. On
Linux, I think this is less likely, but still possible, since there is
more latency between the hardware interrupt and when INTSTAT is read.
The extra latency means there is more time for the second interrupt to
happen, causing INTSTAT to simply show both interrupts, and have less
likelihood of the second interrupt happening exactly as INTSTAT is read.

> So it shouldn't pose any problem if the interrupts are replayed by the
> kernel. What may happen however is
> an error in the spi transfer. This would result in the line staying
> low since the register hasn't really been read.
> This is what I observed at the hardware level.

To be clear, you've observed the line staying low, not an SPI transfer
error, right?

> If this is the case, then the problem should also occurs with and
> without disable/enable_irq. However this bug
> is a bit harder to reproduce as it may take several hours. The only
> solution I see would be to regularly poll the
> INTSTAT register for recovering. I know about other drivers which do
> this so I will look into this and work on a fix.

I'd like to avoid a straight-up poll if at all possible. Worst case, we
can poll for interrupt in the case of something happening which we don't
expect to ever happen, for example on something like the TX interrupt
never showing up. It's harder of course to know when to poll for a
system that's primarily a receiver.
 
I've done something like this in my firmware:

void mrf24j40_isr(void)
{
        u8 intstat;
        int ret;

        /* Read the interrupt status */
        ret = read_short_reg(devrec, REG_INTSTAT, &intstat);
        if (ret)
                return;

        do {
                /* Check for TX complete */
                if (intstat & 0x1)
                        tx_complete = 1;

                /* Check for Rx */
                if (intstat & 0x8)
                        mrf24j40_handle_rx();

                /* Read the interrupt status */
                ret = read_short_reg(devrec, REG_INTSTAT, &intstat);
                if (ret)
                        return;

                if (intstat && !IFS1bits.INT1IF) {
                        /* Put a break here. This should never happen
but does */
                        Nop();
                        Nop();
                        Nop();
                }
        } while (intstat);
}

Basically there's an extra reading of the INTSTAT every time there's an
interrupt. One would think this would take care of the race condition,
unless there's another....

The breakpoint in the comment is shows the error I describe. The second
reading of INTSTAT shows an interrupt pending (in the case I observed,
0x8: RX), but INT1F (the interrupt flag for INT1, where I have the INT
line of the mrf24j40 connected) does not get set. In the Linux driver
(and in an ISR which doesn't do the extra check of INTSTAT, this causes
the INT line to be stuck low (asserted) with no ISR ever getting called.

We could try triggering on level (IRQF_TRIGGER_LOW) instead of edge. The
mrf24j40 datasheet specifically says it gives an edge trigger, but the
level sticks low until it INTSTAT is read, so we should be able to
detect it as a level trigger.

I'll do some testing on both of these cases.

Alan.

>> I think I had a flawed understanding of schedule_work() before, thinking
>> that it would not schedule a work_struct it if the work_struct was running.
>>
>>>  As you said the interrupt should
>>> be delayed until enable_irq() is called. In particular when
>>> CONFIG_HARDIRQS_SW_RESEND is set.
>> I think I agree with you. I'll send you a patch to try with threaded
>> interrupts to try.
>>
>> I'm trying to determine exactly what's the cause of the interrupt line
>> being stuck low.
>>
> I tried your patch for INIT_COMPLETION. It doesn't fix the problem but
> I agree with you for the race condition.
>
> David
>
>>> 2013/5/14 Alan Ott <alan-yzvJWuRpmD1zbRFIqnYvSA@public.gmane.org>:
>>>> On 5/9/13 11:19 AM, David Hauweele wrote:
>>>>> Disabling the interrupt line could miss an IRQ and leave the line into a
>>>>> low state hence locking the driver.
>>>>>
>>>> Have you observed this? My understanding is that the interrupt won't be lost
>>>> but instead delayed until enable_irq() is called.
>>>>
>>>> I got this pattern from the other 802.15.4 drivers. Perhaps my understanding
>>>> is wrong.
>>>>
>>>>
>>>>
>>>>> Signed-off-by: David Hauweele <david-1EggE+PRa6vk1uMJSBkQmQ@public.gmane.org>
>>>>> ---
>>>>>   drivers/net/ieee802154/mrf24j40.c |    7 +------
>>>>>   1 file changed, 1 insertion(+), 6 deletions(-)
>>>>>
>>>>> diff --git a/drivers/net/ieee802154/mrf24j40.c
>>>>> b/drivers/net/ieee802154/mrf24j40.c
>>>>> index 1e3ddf3..6ef32f7 100644
>>>>> --- a/drivers/net/ieee802154/mrf24j40.c
>>>>> +++ b/drivers/net/ieee802154/mrf24j40.c
>>>>> @@ -603,8 +603,6 @@ static irqreturn_t mrf24j40_isr(int irq, void *data)
>>>>>   {
>>>>>         struct mrf24j40 *devrec = data;
>>>>>
>>>>> -       disable_irq_nosync(irq);
>>>>> -
>>>>>         schedule_work(&devrec->irqwork);
>>>>>
>>>>>         return IRQ_HANDLED;
>>>>> @@ -619,7 +617,7 @@ static void mrf24j40_isrwork(struct work_struct *work)
>>>>>         /* Read the interrupt status */
>>>>>         ret = read_short_reg(devrec, REG_INTSTAT, &intstat);
>>>>>         if (ret)
>>>>> -               goto out;
>>>>> +               return;
>>>>>
>>>>>         /* Check for TX complete */
>>>>>         if (intstat & 0x1)
>>>>> @@ -628,9 +626,6 @@ static void mrf24j40_isrwork(struct work_struct *work)
>>>>>         /* Check for Rx */
>>>>>         if (intstat & 0x8)
>>>>>                 schedule_work(&devrec->rxwork);
>>>>> -
>>>>> -out:
>>>>> -       enable_irq(devrec->spi->irq);
>>>>>   }
>>>>>
>>>>>   static void mrf24j40_rxwork(struct work_struct *work)
>>>>>
>>


------------------------------------------------------------------------------
Try New Relic Now & We'll Send You this Cool Shirt
New Relic is the only SaaS-based application performance monitoring service 
that delivers powerful full stack analytics. Optimize and monitor your
browser, app, & servers with just a few lines of code. Try New Relic
and get this awesome Nerd Life shirt! http://p.sf.net/sfu/newrelic_d2d_may
