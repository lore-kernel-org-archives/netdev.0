From: Varka Bhadram <varkabhadram@gmail.com>
Subject: Re: [PATCH net-next v5 1/3] ieee802154: cc2520: adds driver for TI
 CC2520 radio
Date: Thu, 19 Jun 2014 17:34:30 +0530
Message-ID: <53A2D1CE.6040402@gmail.com>
References: <1403167131-22092-1-git-send-email-varkab@cdac.in> <1403167131-22092-2-git-send-email-varkab@cdac.in> <20140619104440.GA17994@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, alex.bluesman.smirnov@gmail.com,
	dbaryshkov@gmail.com, linux-zigbee-devel@lists.sourceforge.net,
	linux-kernel@vger.kernel.org, davem@davemloft.net,
	sowjanyap@cdac.in, santoshk@cdac.in, venkatas@cdac.in
To: Alexander Aring <alex.aring@gmail.com>,
	Varka Bhadram <varkabhadram@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20140619104440.GA17994@omega>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi Alex,

Thanks for the comments

On 06/19/2014 04:14 PM, Alexander Aring wrote:
> Hi Varka,
>
> why do you add new features while you trying to get the first version
> mainline?

This h/w address filtering feature is required for me to get CC2520 Hardware ACK, which
enable TinyOS nodes to communicate with the linux node.

I want to get this feature also in mainline for the first version. So that it will be full fledged driver.

> On Thu, Jun 19, 2014 at 02:08:48PM +0530, Varka Bhadram wrote:
>> This patch adds the driver support for the cc2520 radio.
>>
>> Driver support:
>> 	- Tx and Rx of IEEE-802.15.4 packets.
>> 	- Energy Detection on channel.
>> 	- Setting the Channel for the radio. [b/w 11 - 26 channels]
>> 	- Start and Stop the radio
>> 	- h/w address filtering.
>>
[...]

>> +static int
>> +cc2520_read_rxfifo(struct cc2520_private *priv, u8 *data, u8 len, u8 *lqi)
>> +{
>> +	int status;
>> +	struct spi_message msg;
>> +
>> +	struct spi_transfer xfer_head = {
>> +		.len = 0,
>> +		.tx_buf = priv->buf,
>> +		.rx_buf = priv->buf,
>> +	};
>> +	struct spi_transfer xfer_buf = {
>> +		.len = len,
>> +		.rx_buf = data,
>> +	};
>> +
>> +	spi_message_init(&msg);
>> +	spi_message_add_tail(&xfer_head, &msg);
>> +	spi_message_add_tail(&xfer_buf, &msg);
>> +
>> +	mutex_lock(&priv->buffer_mutex);
>> +	priv->buf[xfer_head.len++] = CC2520_CMD_RXBUF;
>> +
>> +	dev_vdbg(&priv->spi->dev, "read rxfifo buf[0] = %02x\n", priv->buf[0]);
>> +	dev_vdbg(&priv->spi->dev, "buf[1] = %02x\n", priv->buf[1]);
>> +
>> +	status = spi_sync(priv->spi, &msg);
>> +	dev_vdbg(&priv->spi->dev, "status = %d\n", status);
>> +	if (msg.status)
>> +		status = msg.status;
>> +	dev_vdbg(&priv->spi->dev, "status = %d\n", status);
>> +	dev_vdbg(&priv->spi->dev,
>> +		 "return status buf[0] = %02x\n", priv->buf[0]);
>> +	dev_vdbg(&priv->spi->dev, "length buf[1] = %02x\n", priv->buf[1]);
>> +
>> +	*lqi = data[priv->buf[1] - 1] & 0x7f;
> This is a little bit critical... but I know others driver doesn't check
> also on this.

I will check how other drivers using lqi field , which is actually passing to higher layers.

> After the cc2520_read_rxfifo you check if (len < 2 ...) but here you
> already use the len. Maybe but the length constraints check in this function.
>
>> +
>> +	mutex_unlock(&priv->buffer_mutex);
>> +
>> +	return status;

[...]

>> +static int cc2520_rx(struct cc2520_private *priv)
>> +{
>> +	u8 len = 0, lqi = 0, bytes = 1;
>> +	struct sk_buff *skb;
>> +
>> +	cc2520_read_rxfifo(priv, &len, bytes, &lqi);
> Okay, you get here the length for your pdu. But then you can check
> afterwards on:
>
> if (len < 2) instead of doing this in the second rxfifo call. And please
> do a:
>
> if (len < 2 || len > IEEE802154_MTU)

I will make this change in v6

> The reason is, I don't know if your chip does filter something like
> that. The at86rf230 don't filter pdu above the MTU size and we have no
> generic mac802154 layer function right now to check on this. I like to
> improve that in the near future...
>
> When you do this check you can save the kfree_skb in this branch.
>
>> +
>> +	skb = alloc_skb(len, GFP_KERNEL);
>> +	if (!skb)
>> +		return -ENOMEM;
>> +
>> +	cc2520_read_rxfifo(priv, skb_put(skb, len), len, &lqi);
>> +	if (len < 2) {
>> +		kfree_skb(skb);
>> +		return -EINVAL;
>> +	}
>> +
>> +	skb_trim(skb, skb->len - 2);
>> +
>> +	ieee802154_rx_irqsafe(priv->dev, skb, lqi);
>> +
>> +	dev_vdbg(&priv->spi->dev, "RXFIFO: %x %x\n", len, lqi);
>> +
>> +	return 0;
>> +}
>> +
>> +static int
>> +cc2520_ed(struct ieee802154_dev *dev, u8 *level)
>> +{
>> +	struct cc2520_private *priv = dev->priv;
>> +	u8 status = 0xff;
>> +	u8 rssi;
>> +	int ret;
>> +
>> +	ret = cc2520_read_register(priv , CC2520_RSSISTAT, &status);
>> +	if (ret)
>> +		return ret;
>> +
>> +	if (status != RSSI_VALID) {
>> +		ret = -EINVAL;
>> +		return ret;
> return -EINVAL;

Ok. I will do it in v6

>> +	}
>> +
>> +	ret = cc2520_read_register(priv , CC2520_RSSI, &rssi);
>> +	if (ret)
>> +		return ret;
>> +
>> +	/* level = RSSI(rssi) - OFFSET [dBm] : offset is 76dBm*/
>> +	*level = rssi - RSSI_OFFSET;
>> +
>> +	return ret;
>> +}
>> +
[...]
>> +static int
>> +cc2520_filter(struct ieee802154_dev *dev,
>> +	      struct ieee802154_hw_addr_filt *filt, unsigned long changed)
>> +{
>> +	struct cc2520_private *priv = dev->priv;
>> +
>> +	if (changed & IEEE802515_AFILT_PANID_CHANGED) {
>> +		u8 panid[2];
>> +		panid[0] = filt->pan_id & 0xff;
>> +		panid[1] = filt->pan_id >> 8;
> const u16 panid = le16_to_cpu(filt->pan_id);

Ok.

>> +		cc2520_write_ram(priv, CC2520RAM_PANID, sizeof(panid), panid);
>> +	}
>> +
>> +	if (changed & IEEE802515_AFILT_IEEEADDR_CHANGED)
>> +		cc2520_write_ram(priv, CC2520RAM_IEEEADDR,
>> +				sizeof(filt->ieee_addr), (u8 *)&filt->ieee_addr);
>> +
>> +	return 0;
>> +
>> +}
> What's about to handle IEEE802515_AFILT_PANC_CHANGED and
> IEEE802515_AFILT_SADDR_CHANGED? These are fully ignored, your chip
> should have such functions.

CC2520 supports IEEE802515_AFILT_SADDR_CHANGED functionality , but i didn't find any info about
Pan co-coordinator changed register details. If that is possible i will do it in v6

> If you don't support them you need to return -EOPNOTSUPP; but this would
> be weird because you have a IEEE 802.15.4 complaint chip. :-)
>
Ok.


-Varka Bhadram
