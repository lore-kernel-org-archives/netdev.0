From: Wolfgang Zarre <info@essax.com>
Subject: Re: [PATCH net-next v2 2/4] can: cc770: add legacy ISA bus driver
 for the CC770 and AN82527
Date: Tue, 10 Jan 2012 13:30:02 +0100
Message-ID: <4F0C2F4A.20500@essax.com>
References: <AE90C24D6B3A694183C094C60CF0A2F6D8AF31@saturn3.aculab.com> <4F0B608D.6090309@essax.com> <4F0B7421.6050203@pengutronix.de> <4F0C0552.5080504@grandegger.com>
Reply-To: info@essax.com
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Marc Kleine-Budde <mkl@pengutronix.de>,
	David Laight <David.Laight@ACULAB.COM>,
	Oliver Hartkopp <socketcan@hartkopp.net>, henrik@proconx.com,
	netdev@vger.kernel.org, linux-can@vger.kernel.org,
	socketcan-users@lists.berlios.de, IreneV <boir1@yandex.ru>,
	Stanislav Yelenskiy <stanislavelensky@yahoo.com>, oe@port.de,
	henrik@focus-sw.com
To: Wolfgang Grandegger <wg@grandegger.com>
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <4F0C0552.5080504@grandegger.com>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello Wolfgang,

> On 01/10/2012 12:11 AM, Marc Kleine-Budde wrote:
>> On 01/09/2012 10:47 PM, Wolfgang Zarre wrote:
>> [...]
>>
>>>>> OK. My concern: Can we be sure that 16bit accesses are always
>>>> supported
>>>>> by the hardware? Does a spinlock_irqsave/spinlock_irqrestore around
>>>> the
>>>>> 8bit accesses already help?
>>>>
>>>> Hmmm... are there any register reads that need the
>>>> same 'double cycle' sequence ??
>>>> If so you need to stop reads being interleaved (with
>>>> themselves and writes) so requesting a 16bit access
>>>> doesn't help.
>>>>
>>>> Which means you need a spinlock...
>>>>
>>>>      David
>>>>
>>>>
>>>
>>> @David: Thank You very much for that hint. You are right and to
>>> implement correct we need a spinlock.
>>>
>>> @Wolfgang: I was thinking about Your question regarding 8/16 bit and
>>> in fact it wouldn't work at all on a clean 8 bit cards.
>>>
>>> Further it wouldn't work on 16 bit cards where the MSB is not equal
>>> to base port +1 and anyway, it's depending always on how the chip is
>>> interfaced to the ISA bus and in which mode the chip is configured.
>>>
>>>
>>> And therefore I was giving David's hint a try in using a spinlock in
>>> function cc770_isa_port_write_reg_indirect() and patched as follows:
>>>
>>> ---------------------------------------------------------------------
>>> diff --git a/drivers/net/can/cc770/cc770.c b/drivers/net/can/cc770/cc770.c
>>> index 2d12f89..dad6707 100644
>>> --- a/drivers/net/can/cc770/cc770.c
>>> +++ b/drivers/net/can/cc770/cc770.c
>>> @@ -460,15 +460,6 @@ static netdev_tx_t cc770_start_xmit(struct sk_buff
>>> *skb, struct net_device *dev)
>>>
>>>       stats->tx_bytes += dlc;
>>>
>>> -
>>> -    /*
>>> -     * HM: We had some cases of repeated IRQs so make sure the
>>> -     * INT is acknowledged I know it's already further up, but
>>> -     * doing again fixed the issue
>>> -     */
>>> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
>>> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>>> -
>>>       return NETDEV_TX_OK;
>>>   }
>>>
>>> @@ -689,12 +680,6 @@ static void cc770_tx_interrupt(struct net_device
>>> *dev, unsigned int o)
>>>       /* Nothing more to send, switch off interrupts */
>>>       cc770_write_reg(priv, msgobj[mo].ctrl0,
>>>               MSGVAL_RES | TXIE_RES | RXIE_RES | INTPND_RES);
>>> -    /*
>>> -     * We had some cases of repeated IRQ so make sure the
>>> -     * INT is acknowledged
>>> -     */
>>> -    cc770_write_reg(priv, msgobj[mo].ctrl0,
>>> -            MSGVAL_UNC | TXIE_UNC | RXIE_UNC | INTPND_RES);
>
> Please provide an extra patch for these unrelated changes. If we really
> want to remove it.
>

Sure, this I can do.

>>>       stats->tx_packets++;
>>>       can_get_echo_skb(dev, 0);
>>> diff --git a/drivers/net/can/cc770/cc770_isa.c
>>> b/drivers/net/can/cc770/cc770_isa.c
>>> index 4be5fe2..fe39eed 100644
>>> --- a/drivers/net/can/cc770/cc770_isa.c
>>> +++ b/drivers/net/can/cc770/cc770_isa.c
>>> @@ -110,6 +110,9 @@ MODULE_PARM_DESC(bcr, "Bus configuration register
>>> (default=0x40 [CBY])");
>>>   #define CC770_IOSIZE          0x20
>>>   #define CC770_IOSIZE_INDIRECT 0x02
>>>
>>> +/* Spinlock for cc770_isa_port_write_reg_indirect */
>>> +static DEFINE_SPINLOCK( outb_lock);
>>> +
>>
>> Do we need a global or a per device spin lock? If this should be a per
>> device one, please introduce a cc770_isa_priv and put the spinlock
>> there. Don't forget to initialize the spinlock.
>
> Yes, that's what I was thinking as well but in the ocan driver I find:
>
> /*
>   * we need a spinlock here, as the address register looks shared between
>   * two PC-ECAN devices. Moreover, we need to protect WRT interrupts
>   */
>
> Looks like wired hardware. Anyway, a global spinlock might be safer.
>

Hmmm, actually I thought to place the spinlock local because of having
the problem just with the interrupt and not with mutex.

But if global wouldn't it then better to make an array[MAX_DEV] for the
lock with initialisation in _init or _start?

But if PC-ECAN works with that configuration?

> Wolfgang.

Wolfgang
