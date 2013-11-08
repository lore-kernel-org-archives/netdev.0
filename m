From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v3] can: add Renesas R-Car CAN driver
Date: Sat, 09 Nov 2013 01:54:00 +0300
Message-ID: <527D6B88.3010409@cogentembedded.com>
References: <201311020240.13354.sergei.shtylyov@cogentembedded.com> <5276ADF6.9050309@pengutronix.de> <527C28DE.7070402@cogentembedded.com> <527CAC38.6040800@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, wg@grandegger.com,
	linux-can@vger.kernel.org, linux-sh@vger.kernel.org,
	vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>
Return-path: <linux-sh-owner@vger.kernel.org>
In-Reply-To: <527CAC38.6040800@pengutronix.de>
Sender: linux-sh-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 11/08/2013 12:17 PM, Marc Kleine-Budde wrote:

>>>> Index: linux-can-next/drivers/net/can/rcar_can.c
>>>> ===================================================================
>>>> --- /dev/null
>>>> +++ linux-can-next/drivers/net/can/rcar_can.c
>>>> @@ -0,0 +1,893 @@
[...]
>>>> +#define DRV_NAME    "rcar_can"
>>>> +
>>>> +/* Mailbox configuration:
>>>> + * mailbox 0 - not used
>>>> + * mailbox 1-31 - Rx
>>>> + * mailbox 32-63 - Tx
>>>> + * no FIFO mailboxes
>>>> + */
>>>> +#define N_MBX        64
>>>> +#define FIRST_TX_MB    32
>>>> +#define N_TX_MB        (N_MBX - FIRST_TX_MB)
>>>> +#define RX_MBX_MASK    0xFFFFFFFE

>>> Please use a common prefix for all defines.

>>     OK, done now. Could you however explain why the file-local #define's
>> should be prefixed? It's not quite obvious to me...

> It's about readability and maintainability. If you don't know the
> driver, but all driver local defines and functions have a common prefix,
> it's much easier to read if you are not the author of the driver IMHO.

    Well, actually I think the last changes somewhat impaired the readability. 
My idea was that you want to exclude name conflicts with #include'd headers 
this way...

>> [...]
>>>> +static netdev_tx_t rcar_can_start_xmit(struct sk_buff *skb,
>>>> +                       struct net_device *ndev)
>>>> +{
>>>> +    struct rcar_can_priv *priv = netdev_priv(ndev);
>>>> +    struct can_frame *cf = (struct can_frame *)skb->data;
>>>> +    u32 data, mier1, mbxno, i;
>>>> +    unsigned long flags;
>>>> +    u8 mctl = 0;
>>>> +
>>>> +    if (can_dropped_invalid_skb(ndev, skb))
>>>> +        return NETDEV_TX_OK;
>>>> +
>>>> +    spin_lock_irqsave(&priv->mier_lock, flags);
>>>> +    mier1 = readl(&priv->regs->mier1);
>>>> +    if (mier1) {
>>>> +        i = __builtin_clz(mier1);
>>>> +        mbxno = i ? N_MBX - i : FIRST_TX_MB;
>>>> +    } else {
>>>> +        mbxno = FIRST_TX_MB;
>>>> +    }

>>> Can you explain how the hardware arbitration works, and you do you
>>> guarantee the CAN frames are send by the hardware in the same order you
>>> put them into the hardware.

>>     Tx mailbox with the smallest mailbox number has the highest priority.
>> The other possible Tx mailbox selection rule (not used by the driver
>> now) is ID priority transmit mode (as defined in the ISO 11898-1 specs).
>> The algorithm used guarantees the mailboxes are filled sequentially.

    Well, not quite, unfortunately -- it wraps at the last mailbox...

> I see. You are using mier1 to track the used mailboxes....correct?

    Yes, the mailbox interrupts in MIER1 are enabled only for used mailboxes.

>> +	if (unlikely(mier1 == 0xffffffff))
>> +		netif_stop_queue(ndev);

> Then you have a race condition in your tx-complete handler
> rcar_can_tx_done(), as you call netif_wake_queue() unconditionally. If

    Yes, I'm seeing it now...

> mier1 == 0xffffffff you must wait until _all_ mailboxes are transmitted

    That 0xffffffff criterion seems wrong for me now, I changed the algorithm 
and moved the criterion but didn't update it. The correct one seems to be:

	if (unlikely(mier1 & 0x80000000))
		netif_stop_queue(ndev);

> until you are allowed to reenable the mailboxes. Have a look at the
> at91_can driver, it's using a similar scheme. The lowest mailbox is
> transmitted first, but there are three additional bits that indicate the
> priority.

    You mean 4 bits? Priorities are from 0 to 15...

>> I've used 'canfdtest' as suggested by Wolfgang Grandegger to verify, see
>> the log below:

>> root@am335x-evm:~# ./canfdtest -v -g can0
>> interface = can0, family = 29, type = 3, proto = 1
>> ...............................................................................C
>>
>> Test messages sent and received: 483203
>> Exiting...
>> root@am335x-evm:~#

    As you can see, 'canfdtest' didn't detect any race, maybe you could 
recommend a test which would help to detect it?

>> [...]
>>>> +static int rcar_can_rx_poll(struct napi_struct *napi, int quota)
>>>> +{
>>>> +    struct rcar_can_priv *priv = container_of(napi,
>>>> +                          struct rcar_can_priv, napi);
>>>> +    int num_pkts = 0;
>>>> +
>>>> +    /* Find mailbox */
>>>> +    while (num_pkts < quota) {
>>>> +        u8 mctl, mbx;
>>>> +
>>>> +        mbx = readb(&priv->regs->mssr);

>>> How does the RX work? Is it a hardware FIFO?

>>     In short, the MSSR register provides the smallest Rx mailbox number
>> that is looked up in the Rx search mode. We read MSSR until no search
>> results can be obtained, so it is some sort of FIFO.

> This looks racy....

    Could you please elaborate?

>>     And there is separate FIFO operation mode: some mailboxes can be
>> configured as FIFO and serviced by special registers but this operation
>> mode is not supported by the driver.

> if you hardware supports a real FIFO then I strongly suggest to make use
> of it.

    Well, Tx/Rx FIFOs are only 4 frames deep (although I haven't seen more 
than 2 Rx mailboxes ready in a row, there are 32 Tx mailboxes); also FIFO mode 
is less documented than mailbox mode (hence some nasty surprises are 
possible). We still can use mailboxes when in FIFO mode, it's just 8 of them 
are reserved for Tx/Rx FIFOs.

>> [...]
>>>> +static int rcar_can_probe(struct platform_device *pdev)
>>>> +{
[...]
>>>> +    ndev->netdev_ops = &rcar_can_netdev_ops;
>>>> +    ndev->irq = irq;
>>>> +    ndev->flags |= IFF_ECHO;
>>>> +    priv->ndev = ndev;
>>>> +    priv->regs = addr;
>>>> +    priv->clock_select = pdata->clock_select;
>>>> +    priv->can.clock.freq = clk_get_rate(priv->clk);
>>>> +    priv->can.bittiming_const = &rcar_can_bittiming_const;
>>>> +    priv->can.do_set_bittiming = rcar_can_set_bittiming;

>>> Please call this function directly during the open() function.

>>     OK, done, and the method installation was removed. However, I'm not
>> sure why you requested this as many drivers are still using the method.

> The callback was there from the beginning, but then we figured out that
> we don't need it in the driver, but no one has cleaned up the drivers
> yet. So don't use it in new drivers. I know it's not documented anywhere :(

    You should have clarified that in your first review -- that would have 
prevented me from going the wrong way...

> regards,
> Marc

WBR, Sergei

