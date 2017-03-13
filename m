From: Akshay Bhat <akshay.bhat-jEh4hwF5bVhBDgjK7y7TUQ@public.gmane.org>
Subject: Re: [PATCH v2 2/2] can: spi: hi311x: Add Holt HI-311x CAN driver
Date: Mon, 13 Mar 2017 11:38:12 -0400
Message-ID: <b3ebb569-b50c-39ad-dec5-0059fbfba8fb@timesys.com>
References: <1484680922-25813-1-git-send-email-akshay.bhat@timesys.com>
 <1484680922-25813-2-git-send-email-akshay.bhat@timesys.com>
 <234d9e75-0083-b8b4-c781-add653fdb550@grandegger.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8bit
Cc: linux-can-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        devicetree-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
        Akshay Bhat <nodeax-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
To: Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>, mkl-bIcnvbaLZ9MEGnE8C9+IrQ@public.gmane.org
Return-path: <devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <234d9e75-0083-b8b4-c781-add653fdb550-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Sender: devicetree-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi Wolfgang,

On 03/09/2017 12:36 PM, Wolfgang Grandegger wrote:
> Hello,
> 
> doing a quick review... I realized a few issues...
> 
> Am 17.01.2017 um 20:22 schrieb Akshay Bhat:
>> +static u8 hi3110_read(struct spi_device *spi, u8 command)
>> +{
>> +    struct hi3110_priv *priv = spi_get_drvdata(spi);
>> +    u8 val = 0;
>> +
>> +    priv->spi_tx_buf[0] = command;
>> +    hi3110_spi_trans(spi, 2);
>> +    val = priv->spi_rx_buf[1];
>> +    dev_dbg(&spi->dev, "hi3110_read: %02X, %02X\n", command, val);
> 
> This produces a lot of output which is not useful for the normal user.
> 

Fixed in v3 patch.

>> +static void hi3110_write(struct spi_device *spi, u8 reg, u8 val)
>> +{
>> +    struct hi3110_priv *priv = spi_get_drvdata(spi);
>> +
>> +    priv->spi_tx_buf[0] = reg;
>> +    priv->spi_tx_buf[1] = val;
>> +    dev_dbg(&spi->dev, "hi3110_write: %02X, %02X\n", reg, val);
> 
> Ditto.
> 

Fixed in v3 patch.


>> +
>> +static void hi3110_hw_rx(struct spi_device *spi)
>> +{
>> +    struct hi3110_priv *priv = spi_get_drvdata(spi);
>> +    struct sk_buff *skb;
>> +    struct can_frame *frame;
>> +    u8 buf[HI3110_RX_BUF_LEN - 1];
>> +
>> +    skb = alloc_can_skb(priv->net, &frame);
>> +    if (!skb) {
>> +        dev_err(&spi->dev, "cannot allocate RX skb\n");
> 
> Please return silenty! Otherwise it will make the situation worse.
> 

Fixed in v3 patch.

>> +
>> +    /* Data length */
>> +    frame->can_dlc = get_can_dlc(buf[HI3110_FIFO_WOTIME_DLC_OFF] &
>> 0x0F);
>> +    memcpy(frame->data, buf + HI3110_FIFO_WOTIME_DAT_OFF,
>> frame->can_dlc);
> 
> No data bytes should not be copied for RTR messages.
> 

Fixed in v3 patch.

>> +
>> +    if (priv->tx_skb || priv->tx_len) {
>> +        dev_warn(&spi->dev, "hard_xmit called while tx busy\n");
> 
> s/warn/err/? This should never happen; IIUC.
> 

Fixed in v3 patch.

>> +        return NETDEV_TX_BUSY;
>> +    }
>> +
>> +    if (can_dropped_invalid_skb(net, skb))
>> +        return NETDEV_TX_OK;
>> +
>> +    netif_stop_queue(net);
> 
> The driver transfers the packets in sequence. Any chance to queue them?
> At least there is a TX FIFO for 8 messages. That's bad for RT but would
> increase the throughput.
> 

I initially did not use the TX FIFO for the reason you mentioned above.
Queuing should be possible but since it requires lot more additional
logic, I can work on it a later time.


>> +
>> +    if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
>> +        /* Put device into loopback mode */
>> +        hi3110_write(spi, HI3110_WRITE_CTRL0,
>> +                 HI3110_CTRL0_LOOPBACK_MODE);
>> +    } else if (priv->can.ctrlmode & CAN_CTRLMODE_LISTENONLY) {
>> +        /* Put device into listen-only mode */
>> +        hi3110_write(spi, HI3110_WRITE_CTRL0,
>> +                 HI3110_CTRL0_MONITOR_MODE);
>> +    } else {
>> +        /* Put device into normal mode */
>> +        hi3110_write(spi, HI3110_WRITE_CTRL0,
>> +                 HI3110_CTRL0_NORMAL_MODE);
> 
> "mode = x" and just one write is more compact.
> 

Fixed in v3 patch.

>> +
>> +        /* Wait for the device to enter normal mode */
>> +        mdelay(HI3110_OST_DELAY_MS);
>> +        reg = hi3110_read(spi, HI3110_READ_CTRL0);
>> +        if ((reg & HI3110_CTRL0_MODE_MASK) != HI3110_CTRL0_NORMAL_MODE)
>> +            return -EBUSY;
> 
> Is this not necesary for listen or loopbcak only mode?
> 

It is necessary, fixed in v3 patch.

>> +
>> +static void hi3110_error_skb(struct net_device *net, int can_id,
>> +                 int data1, int data2)
>> +{
>> +    struct sk_buff *skb;
>> +    struct can_frame *frame;
>> +
>> +    skb = alloc_can_err_skb(net, &frame);
>> +    if (skb) {
>> +        frame->can_id |= can_id;
>> +        frame->data[1] = data1;
>> +        frame->data[2] = data2;
>> +        netif_rx_ni(skb);
>> +    } else {
>> +        netdev_err(net, "cannot allocate error skb\n");
> 
> Please remove the error message. Not a good at low memory situations.
> 

Fixed in v3 patch.

>> +        /* Check for protocol errors */
>> +        if (eflag & HI3110_ERR_PROTOCOL_MASK) {
>> +            can_id |= CAN_ERR_PROT | CAN_ERR_BUSERROR;
>> +            priv->can.can_stats.bus_error++;
>> +            priv->net->stats.rx_errors++;
>> +            if (eflag & HI3110_ERR_BITERR)
>> +                data2 |= CAN_ERR_PROT_BIT;
>> +            else if (eflag & HI3110_ERR_FRMERR)
>> +                data2 |= CAN_ERR_PROT_FORM;
>> +            else if (eflag & HI3110_ERR_STUFERR)
>> +                data2 |= CAN_ERR_PROT_STUFF;
>> +            else
>> +                data2 |= CAN_ERR_PROT_UNSPEC;
> 
> And what about the ACK and CRC error defines at the beginning?
> It's also comon to use netdev_dbg() on error interrupts.
> 

Good catch, I missed it. Fixed in v3 patch.

>> +        }
> 
> Bus error reporting can flood the system with interrupts. Any chance to
> implement CAN_CTRLMODE_BERR_REPORTING. I think the bus error interrupt
> can be enabled/disabled.
> 

Thanks, was not aware of this feature. Added it in v3 patch.

>> +        /* Update can state statistics */
>> +        switch (priv->can.state) {
>> +        case CAN_STATE_ERROR_ACTIVE:
>> +            if (new_state >= CAN_STATE_ERROR_WARNING &&
>> +                new_state <= CAN_STATE_BUS_OFF)
>> +                priv->can.can_stats.error_warning++;
>> +        /* fallthrough */
>> +        case CAN_STATE_ERROR_WARNING:
>> +            if (new_state >= CAN_STATE_ERROR_PASSIVE &&
>> +                new_state <= CAN_STATE_BUS_OFF)
>> +                priv->can.can_stats.error_passive++;
>> +            break;
>> +        default:
>> +            break;
>> +        }
>> +        priv->can.state = new_state;
>> +
>> +        if (intf & HI3110_INT_BUSERR) {
>> +            /* Note: HI3110 Does report overflow errors */
>> +            hi3110_error_skb(net, can_id, data1, data2);
>> +        }
> 
> Usually the bus error counts are filled in the error message frame as
> well. It the counts are available, I would also be nice to have the
> "do_get_berr_counter" callback as well.
> 

Added it in v3 patch.

>> +static int hi3110_open(struct net_device *net)
>> +{
>> +    struct hi3110_priv *priv = netdev_priv(net);
>> +    struct spi_device *spi = priv->spi;
>> +    unsigned long flags = IRQF_ONESHOT | IRQF_TRIGGER_RISING;
>> +    int ret;
>> +
>> +    ret = open_candev(net);
>> +    if (ret) {
>> +        dev_err(&spi->dev, "unable to set initial baudrate!\n");
> 
> open_candev() does already print an error message.
>

Fixed in v3 patch.


> A few other things to check:
> 
> Run "cangen" and monitor the message with "candump -e any,0:0,#FFFFFFF".
> Then 1) disconnect the cable or 2) short-circuit CAN low and high at the
> connector. You should see error messages. After reconnection or removing
> the short-circuit (and bus-off recovery) the state should go back to
> "active".
>

With the above sequence, candump reports "ERRORFRAME" with
protocol-violation{{}{acknowledge-slot}}, bus-error. On re-connecting
the cable the can state goes back to ACTIVE and I see the messages that
were in the queue being sent.

> Run "canfdtest" to check for out-of-order messages. I do not expect
> problems with your driver, though.
>

Ran canfdtest for 100k loop (@1M can bit rate), did not see any issues.

Thanks for your valuable suggests and tests :)
Akshay.

--
To unsubscribe from this list: send the line "unsubscribe devicetree" in
the body of a message to majordomo-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
More majordomo info at  http://vger.kernel.org/majordomo-info.html
