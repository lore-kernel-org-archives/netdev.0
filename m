From: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Subject: Re: [PATCH v5] can: add Renesas R-Car CAN driver
Date: Fri, 21 Feb 2014 02:48:21 +0300
Message-ID: <53069445.80408@cogentembedded.com>
References: <201312270037.15822.sergei.shtylyov@cogentembedded.com> <52DCE9E4.7010209@pengutronix.de> <52E3148E.2010608@cogentembedded.com> <52FCB6C5.6020001@pengutronix.de>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: linux-sh@vger.kernel.org, vksavl@gmail.com
To: Marc Kleine-Budde <mkl@pengutronix.de>, netdev@vger.kernel.org,
	wg@grandegger.com, linux-can@vger.kernel.org
Return-path: <linux-can-owner@vger.kernel.org>
In-Reply-To: <52FCB6C5.6020001@pengutronix.de>
Sender: linux-can-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hello.

On 02/13/2014 03:12 PM, Marc Kleine-Budde wrote:

>>>> Add support for the CAN controller found in Renesas R-Car SoCs.

>>>> Signed-off-by: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>

>>>> ---
>>>> The patch is against the 'linux-can-next.git' repo.

>> [...]
>>>> Index: linux-can-next/drivers/net/can/rcar_can.c
>>>> ===================================================================
>>>> --- /dev/null
>>>> +++ linux-can-next/drivers/net/can/rcar_can.c
>>>> @@ -0,0 +1,857 @@
>> [...]
>>>> +/* Mailbox registers structure */
>>>> +struct rcar_can_mbox_regs {
>>>> +    u32 id;        /* IDE and RTR bits, SID and EID */
>>>> +    u8 stub;    /* Not used */
>>>> +    u8 dlc;        /* Data Length Code - bits [0..3] */
>>>> +    u8 data[8];    /* Data Bytes */
>>>> +    u8 tsh;        /* Time Stamp Higher Byte */
>>>> +    u8 tsl;        /* Time Stamp Lower Byte */
>>>> +} __packed;

>>> If you have contact to the hardware designer please blame him for

>>     Unfortunately, we don't.

>>> placing the data register unaligned into the register space. :)

>>     It's not even the only one or worst example of questionable register
>> design in this module IMO.

    Moreover, there are certainly strange issues with the host bus.

>> [...]
>>>> +static void rcar_can_tx_done(struct net_device *ndev)
>>>> +{
>>>> +    struct rcar_can_priv *priv = netdev_priv(ndev);
>>>> +    struct net_device_stats *stats = &ndev->stats;
>>>> +    int i;
>>>> +
>>>> +    spin_lock(&priv->skb_lock);
>>>> +    for (i = 0; i < priv->frames_queued; i++)
>>>> +        can_get_echo_skb(ndev, i);
>>>> +    stats->tx_bytes += priv->bytes_queued;
>>>> +    stats->tx_packets += priv->frames_queued;
>>>> +    priv->bytes_queued = 0;
>>>> +    priv->frames_queued = 0;
>>>> +    spin_unlock(&priv->skb_lock);

>>> This looks broken. What happens if you send 2 CAN frames in a row, the
>>> first one is send, a TX complete interrupt is issued and you handle it
>>> here? You assume, that all CAN frames have been sent.

>>     TX interrupt will be issued only when TX FIFO gets empty (all 2 frames
>> have been transmitted in this case). Please see the comment to the
>> RCAR_CAN_MIER1_TXFIT bit.

> Does the hardware have a TX complete interrupt?

    Yes, there's a mode where TX interrupt signals send completion. I rewrote
the driver to make use of this mode now.

> If you only have TX FIFO
> empty, you have to limit the FIFO depth to 1.

    Not quite clear why...

[...]
>>>> +static void rcar_can_set_bittiming(struct net_device *dev)
>>>> +{
>>>> +    struct rcar_can_priv *priv = netdev_priv(dev);
>>>> +    struct can_bittiming *bt = &priv->can.bittiming;
>>>> +    u32 bcr;
>>>> +    u8 clkr;
>>>> +
>>>> +    /* Don't overwrite CLKR with 32-bit BCR access */
>>>> +    /* CLKR has 8-bit access */

>>> Can you explain the register layout here? Why do you access BCR with 32
>>> bits when the register is defined as 3x8 bit? Can't you make it a
>>> standard 32 bit register?

>> 1. According to documentation BCR is the 24-bit register.
>> Actually we can consider some 32-bit register that combines BCR and
>> CLKR but according to documentation there are two separate registers.
>> 2. BCR has 8- ,16-, and 32-bit access (according to documentation).
>> 3. This is the algorithm that the documentation suggests.
>> 4. We had a driver version with byte access but 32-bit access seems
>> shorter.

> Please use a normal read-modify-write 32 bit access.

    IMO, reading 32-bits is futile, as we're going to completely overwrite 
those 24 bits that constitute BCR. So I kept the 8-bit CLKR read but removed 
the CLKR write in the end. I've also added a comment clarifying why CLKR is 
positioned in the LSBs of 32-bit word (while it's address would assume MSBs).
The host bus is big-endian but byte-swaps at least 16- and 32-bit accesses, so 
that read[wl]()/write[wl]() work. 8-bit accesses are not byte swapped, despite 
what the figure in the manual shows.

> Marc

WBR, Sergei

