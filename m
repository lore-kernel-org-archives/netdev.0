From: Alexander Aring <alex.aring@gmail.com>
Subject: Re: [Linux-zigbee-devel] [PATCH net-next v1 1/3] ieee802154: cc2520:
 adds driver for TI CC2520 radio
Date: Tue, 17 Jun 2014 11:51:14 +0200
Message-ID: <20140617095112.GA30654@omega>
References: <1929819035.7546.1402996542810.JavaMail.open-xchange@webmail.cdac.in>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: Varka Bhadram <varkabhadram@gmail.com>, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org,
	linux-zigbee-devel@lists.sourceforge.net, davem@davemloft.net
To: Varka Bhadram <varkab@cdac.in>
Return-path: <linux-kernel-owner@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <1929819035.7546.1402996542810.JavaMail.open-xchange@webmail.cdac.in>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi,

On Tue, Jun 17, 2014 at 02:45:42PM +0530, Varka Bhadram wrote:
> On 06/17/2014 02:11 PM, Alexander Aring wrote:
> 
> > 
> >     Hi Varka,
...
> > >         +
> > >         +/* Generic Functions */
> > >         +static int
> > >         +cc2520_cmd_strobe(struct cc2520_private *priv, u8 cmd)
> > >         +{
> > >         + int ret;
> > >         + u8 status = 0xff;
> > >         + struct spi_message msg;
> > >         + struct spi_transfer xfer = {
> > >         +  .len = 0,
> > >         +  .tx_buf = priv->buf,
> > >         +  .rx_buf = priv->buf,
> > >         + };
> > >         +
> > >         + spi_message_init(&msg);
> > >         + spi_message_add_tail(&xfer, &msg);
> > >         +
> > >         + mutex_lock(&priv->buffer_mutex);
> > >         + priv->buf[xfer.len++] = cmd;
> > >         + dev_vdbg(&priv->spi->dev,
> > >         +   "command strobe buf[0] = %02x\n",
> > >         +   priv->buf[0]);
> > >         +
> > >         + ret = spi_sync(priv->spi, &msg);
> > >         + if (!ret)
> > >         +  status = priv->buf[0];
> > >         + dev_vdbg(&priv->spi->dev,
> > >         +   "buf[0] = %02x\n", priv->buf[0]);
> > >         + mutex_unlock(&priv->buffer_mutex);
> > >         +
> > >         + return ret;
> > >         +}
> > > 
> > >     > 
> >     What's about to drop the lowlevel spi calls and use spi helper functions?
> > 
> > 
> Many of the people are suggesting to use spi_sync() functions instead of spi
> helper functions.
> 

The spi helper function do the same what do you there in several
functions in this driver. Look in 'drivers/spi/spi.c'. This would
decrease much the code count.

> > 
> >         > > 
> > >         +
> > >         +static int
> > >         +cc2520_get_status(struct cc2520_private *priv, u8 *status)
> > >         +{
> > >         + int ret;
> > >         + struct spi_message msg;
> > >         + struct spi_transfer xfer = {
> > >         +  .len = 0,
> > >         +  .tx_buf = priv->buf,
> > >         +  .rx_buf = priv->buf,
> > >         + };
> > >         +
> > >         + spi_message_init(&msg);
> > >         + spi_message_add_tail(&xfer, &msg);
> > >         +
> > >         + mutex_lock(&priv->buffer_mutex);
> > >         + priv->buf[xfer.len++] = CC2520_CMD_SNOP;
> > >         + dev_vdbg(&priv->spi->dev,
> > >         +   "get status command buf[0] = %02x\n", priv->buf[0]);
> > >         +
> > >         + ret = spi_sync(priv->spi, &msg);
> > >         + if (!ret)
> > >         +  *status = priv->buf[0];
> > >         + dev_vdbg(&priv->spi->dev,
> > >         +   "buf[0] = %02x\n", priv->buf[0]);
> > >         + mutex_unlock(&priv->buffer_mutex);
> > >         +
> > >         + return ret;
> > >         +}
> > >         +
> > >         +static int
> > >         +cc2520_write_register(struct cc2520_private *priv, u8 reg, u8
> > > value)
> > >         +{
> > >         + int status;
> > >         + struct spi_message msg;
> > >         + struct spi_transfer xfer = {
> > >         +  .len = 0,
> > >         +  .tx_buf = priv->buf,
> > >         +  .rx_buf = priv->buf,
> > >         + };
> > >         +
> > >         + spi_message_init(&msg);
> > >         + spi_message_add_tail(&xfer, &msg);
> > >         +
> > >         + mutex_lock(&priv->buffer_mutex);
> > >         +
> > >         + if (reg <= CC2520_FREG_MASK) {
> > >         +  priv->buf[xfer.len++] = CC2520_CMD_REGISTER_WRITE | reg;
> > >         +  priv->buf[xfer.len++] = value;
> > >         + } else {
> > >         +  priv->buf[xfer.len++] = CC2520_CMD_MEMORY_WRITE;
> > >         +  priv->buf[xfer.len++] = reg;
> > >         +  priv->buf[xfer.len++] = value;
> > >         + }
> > >         + status = spi_sync(priv->spi, &msg);
> > >         + if (msg.status)
> > >         +  status = msg.status;
> > >         +
> > >         + mutex_unlock(&priv->buffer_mutex);
> > >         +
> > >         + return status;
> > >         +}
> > >         +
> > >         +static int
> > >         +cc2520_read_register(struct cc2520_private *priv, u8 reg, u8 *data)
> > >         +{
> > >         + int status;
> > >         + struct spi_message msg;
> > >         + struct spi_transfer xfer1 = {
> > >         +  .len = 0,
> > >         +  .tx_buf = priv->buf,
> > >         +  .rx_buf = priv->buf,
> > >         + };
> > >         +
> > >         + struct spi_transfer xfer2 = {
> > >         +  .len = 1,
> > >         +  .rx_buf = data,
> > >         + };
> > >         +
> > >         + spi_message_init(&msg);
> > >         + spi_message_add_tail(&xfer1, &msg);
> > >         + spi_message_add_tail(&xfer2, &msg);
> > >         +
> > >         + mutex_lock(&priv->buffer_mutex);
> > >         + priv->buf[xfer1.len++] = CC2520_CMD_MEMORY_READ;
> > >         + priv->buf[xfer1.len++] = reg;
> > >         +
> > >         + status = spi_sync(priv->spi, &msg);
> > >         + dev_dbg(&priv->spi->dev,
> > >         +  "spi status = %d\n", status);
> > >         + if (msg.status)
> > >         +  status = msg.status;
> > >         +
> > >         + mutex_unlock(&priv->buffer_mutex);
> > >         +
> > >         + return status;
> > >         +}
> > >         +
> > >         +static int
> > >         +cc2520_write_txfifo(struct cc2520_private *priv, u8 *data, u8 len)
> > >         +{
> > >         + int status;
> > >         +
> > >         + /*
> > >         +  *length byte must include FCS even
> > >         +  *if it is calculated in the hardware
> > >         +  */
> > >         + int len_byte = len + 2;
> > >         +
> > >         + struct spi_message msg;
> > >         +
> > >         + struct spi_transfer xfer_head = {
> > >         +  .len = 0,
> > >         +  .tx_buf = priv->buf,
> > >         +  .rx_buf = priv->buf,
> > >         + };
> > >         + struct spi_transfer xfer_len = {
> > >         +  .len = 1,
> > >         +  .tx_buf = &len_byte,
> > >         + };
> > >         + struct spi_transfer xfer_buf = {
> > >         +  .len = len,
> > >         +  .tx_buf = data,
> > >         + };
> > >         +
> > >         + spi_message_init(&msg);
> > >         + spi_message_add_tail(&xfer_head, &msg);
> > >         + spi_message_add_tail(&xfer_len, &msg);
> > >         + spi_message_add_tail(&xfer_buf, &msg);
> > >         +
> > >         + mutex_lock(&priv->buffer_mutex);
> > >         + priv->buf[xfer_head.len++] = CC2520_CMD_TXBUF;
> > >         + dev_vdbg(&priv->spi->dev,
> > >         +   "TX_FIFO cmd buf[0] = %02x\n", priv->buf[0]);
> > >         +
> > >         + status = spi_sync(priv->spi, &msg);
> > >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > >         + if (msg.status)
> > >         +  status = msg.status;
> > >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > >         + dev_vdbg(&priv->spi->dev, "buf[0] = %02x\n", priv->buf[0]);
> > >         + mutex_unlock(&priv->buffer_mutex);
> > >         +
> > >         + return status;
> > >         +}
> > >         +
> > >         +static int
> > >         +cc2520_read_rxfifo(struct cc2520_private *priv, u8 *data, u8 *len,
> > > u8 *lqi)
> > > 
> > >     > 
> >     why is len a pointer here? It's never changed in this function I would
> >     prefer const u8 len.
> > 
> Good catch. Its my mistake. Previously i updated the len pointer and i used in
> cc2520_rx().
> Thanx
> 
> > 
> > 
> > 
> >         > > 
> > >         +{
> > >         + int status;
> > >         + struct spi_message msg;
> > >         +
> > >         + struct spi_transfer xfer_head = {
> > >         +  .len = 0,
> > >         +  .tx_buf = priv->buf,
> > >         +  .rx_buf = priv->buf,
> > >         + };
> > >         + struct spi_transfer xfer_buf = {
> > >         +  .len = *len,
> > >         +  .rx_buf = data,
> > >         + };
> > >         +
> > >         + spi_message_init(&msg);
> > >         + spi_message_add_tail(&xfer_head, &msg);
> > >         + spi_message_add_tail(&xfer_buf, &msg);
> > >         +
> > >         + mutex_lock(&priv->buffer_mutex);
> > >         + priv->buf[xfer_head.len++] = CC2520_CMD_RXBUF;
> > >         +
> > >         + dev_vdbg(&priv->spi->dev, "read rxfifo buf[0] = %02x\n",
> > > priv->buf[0]);
> > >         + dev_vdbg(&priv->spi->dev, "buf[1] = %02x\n", priv->buf[1]);
> > >         +
> > >         + status = spi_sync(priv->spi, &msg);
> > >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > >         + if (msg.status)
> > >         +  status = msg.status;
> > >         + dev_vdbg(&priv->spi->dev, "status = %d\n", status);
> > >         + dev_vdbg(&priv->spi->dev,
> > >         +   "return status buf[0] = %02x\n", priv->buf[0]);
> > >         + dev_vdbg(&priv->spi->dev, "length buf[1] = %02x\n", priv->buf[1]);
> > >         +
> > >         + *lqi = data[priv->buf[1] - 1] & 0x7f;
> > >         +
> > >         + mutex_unlock(&priv->buffer_mutex);
> > >         +
> > >         + return status;
> > >         +}
> > >         +
> > >         +static int cc2520_start(struct ieee802154_dev *dev)
> > >         +{
> > >         + return cc2520_cmd_strobe(dev->priv, CC2520_CMD_SRXON);
> > >         +}
> > >         +
> > >         +static void cc2520_stop(struct ieee802154_dev *dev)
> > >         +{
> > >         + cc2520_cmd_strobe(dev->priv, CC2520_CMD_SRFOFF);
> > >         +}
> > >         +
> > >         +static int
> > >         +cc2520_tx(struct ieee802154_dev *dev, struct sk_buff *skb)
> > >         +{
> > >         + struct cc2520_private *priv = dev->priv;
> > >         + unsigned long flags;
> > >         + int rc;
> > >         + u8 status = 0;
> > >         +
> > >         + rc = cc2520_cmd_strobe(priv, CC2520_CMD_SFLUSHTX);
> > >         + if (rc)
> > >         +  goto err_tx;
> > >         +
> > >         + rc = cc2520_write_txfifo(priv, skb->data, skb->len);
> > >         + if (rc)
> > >         +  goto err_tx;
> > >         +
> > >         + rc = cc2520_get_status(priv, &status);
> > >         + if (rc)
> > >         +  goto err_tx;
> > >         +
> > >         + if (status & CC2520_STATUS_TX_UNDERFLOW) {
> > >         +  dev_err(&priv->spi->dev, "cc2520 tx underflow exception\n");
> > >         +  goto err_tx;
> > >         + }
> > >         +
> > >         + spin_lock_irqsave(&priv->lock, flags);
> > >         + BUG_ON(priv->is_tx);
> > >         + priv->is_tx = 1;
> > >         + spin_unlock_irqrestore(&priv->lock, flags);
> > >         +
> > >         + rc = cc2520_cmd_strobe(priv, CC2520_CMD_STXONCCA);
> > >         + if (rc)
> > >         +  goto err;
> > >         +
> > >         + rc = wait_for_completion_interruptible(&priv->tx_complete);
> > >         + if (rc < 0)
> > >         +  goto err;
> > > 
> > >     > 
> >     mhhh, I never see a reinit_completion and ask myself how the driver can
> >     ever work?
> > 
> >     We should also use a wait_for_completion_timeout here, then you need to
> >     handle the error handling with if (!rc).
> > 
> I initialized the work completion in the cc2520_probe():
>                           init_completion(&priv->tx_complete);
> 

Ah, we only need a reinit_completion after a complete_all. Ok, sorry :-)

> It will wait until the SFD interrupt to raise and get the completion signal from
> sfd_isr() by:
>                           complete(&priv->tx_complete)
> 
> wait_for_completion_interruptible() API will put the thread in interruptible
> state.
> 

Yes, you are right but there is also a
wait_for_completion_interruptible_timeout. I mean for the case if you
waiting forever and no irq hits.

> > 
> > 
> > 
...
> > >         +
> > >         + mutex_init(&priv->buffer_mutex);
> > >         + INIT_WORK(&priv->fifop_irqwork, cc2520_fifop_irqwork);
> > >         + spin_lock_init(&priv->lock);
> > >         + init_completion(&priv->tx_complete);
> > >         +
> > >         + /* Request all the gpio's */
> > >         + if (!gpio_is_valid(pdata->fifo)) {
> > >         +  dev_err(&spi->dev, "fifo gpio is not valid\n");
> > >         +  ret = -EINVAL;
> > >         +  goto err_hw_init;
> > >         + } else {
> > >         +  ret = devm_gpio_request_one(&spi->dev, pdata->fifo,
> > >         +         GPIOF_IN, "fifo");
> > >         +  if (ret)
> > >         +   goto err_hw_init;
> > >         + }
> > > 
> > >     > 
> >     you can drop the else branch here...
> > 
> 
> gpio_is_valid() will only check whether the GPIO PIN number is within the range
> of GPIO numbers or not.
> devm_gpio_request_one() request for the GPIO number. If other driver try to
> requst for the same number
> GPIO/Pinctrl subsytems through an error saying that 'The GPIO number is already
> used by someone else'
> 
> 

I meant something like this:

if (!gpio_is_valid(pdata->fifo)) {
	dev_err(&spi->dev, "fifo gpio is not valid\n");
	ret = -EINVAL;
	goto err_hw_init;
}

ret = devm_gpio_request_one(&spi->dev, pdata->fifo,
			    GPIOF_IN, "fifo");
if (ret)
	goto err_hw_init;

...

- Alex
