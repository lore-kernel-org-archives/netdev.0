From: christian pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
Subject: Re: [PATCH net-next-2.6 v2] can: mcp251x: Move to threaded interrupts
	instead of workqueues.
Date: Mon, 1 Feb 2010 08:10:55 +0100
Message-ID: <cabda6421001312310o60843addq8d27e9be019e9efd@mail.gmail.com>
References: <cabda6421001310939g4acd22d2ua8dab4de3322f90e@mail.gmail.com>
	<1264959793-1797-1-git-send-email-chripell@fsfe.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
To: socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Wolfgang Grandegger <wg-5Yr1BZd7O62+XT7JhA+gdA@public.gmane.org>
Return-path: <socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
In-Reply-To: <1264959793-1797-1-git-send-email-chripell-VaTbYqLCNhc@public.gmane.org>
List-Unsubscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=unsubscribe>
List-Archive: <https://lists.berlios.de/pipermail/socketcan-core>
List-Post: <mailto:socketcan-core-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org>
List-Help: <mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=help>
List-Subscribe: <https://lists.berlios.de/mailman/listinfo/socketcan-core>,
	<mailto:socketcan-core-request-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org?subject=subscribe>
Sender: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
Errors-To: socketcan-core-bounces-0fE9KPoRgkgATYTw5x5z8w@public.gmane.org
List-Id: netdev.vger.kernel.org

Please wait a moment for this patch because I had some reports of
possible problems.


On Sun, Jan 31, 2010 at 6:43 PM, Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org> wr=
ote:
> This patch addresses concerns about efficiency of handling incoming
> packets. Handling of interrupts is done in a threaded interrupt handler
> which has a smaller latency than workqueues. This change needed a rework
> of the locking scheme that was much simplified. Some other (more or less
> longstanding) bugs are fixed: utilization of just half of the RX
> buffers, useless wait for interrupt on open, more reliable reset
> sequence. The MERR interrupt is not used anymore: it overloads the CPU
> in bus-off state without any additional information.
>
> Signed-off-by: Christian Pellegrin <chripell-VaTbYqLCNhc@public.gmane.org>
> ---
> =A0drivers/net/can/mcp251x.c | =A0415 ++++++++++++++++++++++-------------=
----------
> =A01 files changed, 202 insertions(+), 213 deletions(-)
>
> diff --git a/drivers/net/can/mcp251x.c b/drivers/net/can/mcp251x.c
> index bbe186b..884d309 100644
> --- a/drivers/net/can/mcp251x.c
> +++ b/drivers/net/can/mcp251x.c
> @@ -180,6 +180,14 @@
> =A0#define RXBEID0_OFF 4
> =A0#define RXBDLC_OFF =A05
> =A0#define RXBDAT_OFF =A06
> +#define RXFSIDH(n) ((n) * 4)
> +#define RXFSIDL(n) ((n) * 4 + 1)
> +#define RXFEID8(n) ((n) * 4 + 2)
> +#define RXFEID0(n) ((n) * 4 + 3)
> +#define RXMSIDH(n) ((n) * 4 + 0x20)
> +#define RXMSIDL(n) ((n) * 4 + 0x21)
> +#define RXMEID8(n) ((n) * 4 + 0x22)
> +#define RXMEID0(n) ((n) * 4 + 0x23)
>
> =A0#define GET_BYTE(val, byte) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0(((val) >> ((byte) * 8)) & 0xff)
> @@ -219,7 +227,8 @@ struct mcp251x_priv {
> =A0 =A0 =A0 =A0struct net_device *net;
> =A0 =A0 =A0 =A0struct spi_device *spi;
>
> - =A0 =A0 =A0 struct mutex spi_lock; /* SPI buffer lock */
> + =A0 =A0 =A0 struct mutex mcp_lock; /* SPI device lock */
> +
> =A0 =A0 =A0 =A0u8 *spi_tx_buf;
> =A0 =A0 =A0 =A0u8 *spi_rx_buf;
> =A0 =A0 =A0 =A0dma_addr_t spi_tx_dma;
> @@ -227,11 +236,11 @@ struct mcp251x_priv {
>
> =A0 =A0 =A0 =A0struct sk_buff *tx_skb;
> =A0 =A0 =A0 =A0int tx_len;
> +
> =A0 =A0 =A0 =A0struct workqueue_struct *wq;
> =A0 =A0 =A0 =A0struct work_struct tx_work;
> - =A0 =A0 =A0 struct work_struct irq_work;
> - =A0 =A0 =A0 struct completion awake;
> - =A0 =A0 =A0 int wake;
> + =A0 =A0 =A0 struct work_struct restart_work;
> +
> =A0 =A0 =A0 =A0int force_quit;
> =A0 =A0 =A0 =A0int after_suspend;
> =A0#define AFTER_SUSPEND_UP 1
> @@ -245,7 +254,8 @@ static void mcp251x_clean(struct net_device *net)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D netdev_priv(net);
>
> - =A0 =A0 =A0 net->stats.tx_errors++;
> + =A0 =A0 =A0 if (priv->tx_skb || priv->tx_len)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 net->stats.tx_errors++;
> =A0 =A0 =A0 =A0if (priv->tx_skb)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_kfree_skb(priv->tx_skb);
> =A0 =A0 =A0 =A0if (priv->tx_len)
> @@ -300,16 +310,12 @@ static u8 mcp251x_read_reg(struct spi_device *spi, =
uint8_t reg)
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
> =A0 =A0 =A0 =A0u8 val =3D 0;
>
> - =A0 =A0 =A0 mutex_lock(&priv->spi_lock);
> -
> =A0 =A0 =A0 =A0priv->spi_tx_buf[0] =3D INSTRUCTION_READ;
> =A0 =A0 =A0 =A0priv->spi_tx_buf[1] =3D reg;
>
> =A0 =A0 =A0 =A0mcp251x_spi_trans(spi, 3);
> =A0 =A0 =A0 =A0val =3D priv->spi_rx_buf[2];
>
> - =A0 =A0 =A0 mutex_unlock(&priv->spi_lock);
> -
> =A0 =A0 =A0 =A0return val;
> =A0}
>
> @@ -317,15 +323,11 @@ static void mcp251x_write_reg(struct spi_device *sp=
i, u8 reg, uint8_t val)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
>
> - =A0 =A0 =A0 mutex_lock(&priv->spi_lock);
> -
> =A0 =A0 =A0 =A0priv->spi_tx_buf[0] =3D INSTRUCTION_WRITE;
> =A0 =A0 =A0 =A0priv->spi_tx_buf[1] =3D reg;
> =A0 =A0 =A0 =A0priv->spi_tx_buf[2] =3D val;
>
> =A0 =A0 =A0 =A0mcp251x_spi_trans(spi, 3);
> -
> - =A0 =A0 =A0 mutex_unlock(&priv->spi_lock);
> =A0}
>
> =A0static void mcp251x_write_bits(struct spi_device *spi, u8 reg,
> @@ -333,16 +335,12 @@ static void mcp251x_write_bits(struct spi_device *s=
pi, u8 reg,
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
>
> - =A0 =A0 =A0 mutex_lock(&priv->spi_lock);
> -
> =A0 =A0 =A0 =A0priv->spi_tx_buf[0] =3D INSTRUCTION_BIT_MODIFY;
> =A0 =A0 =A0 =A0priv->spi_tx_buf[1] =3D reg;
> =A0 =A0 =A0 =A0priv->spi_tx_buf[2] =3D mask;
> =A0 =A0 =A0 =A0priv->spi_tx_buf[3] =3D val;
>
> =A0 =A0 =A0 =A0mcp251x_spi_trans(spi, 4);
> -
> - =A0 =A0 =A0 mutex_unlock(&priv->spi_lock);
> =A0}
>
> =A0static void mcp251x_hw_tx_frame(struct spi_device *spi, u8 *buf,
> @@ -358,10 +356,8 @@ static void mcp251x_hw_tx_frame(struct spi_device *s=
pi, u8 *buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_write_reg(spi, TXB=
CTRL(tx_buf_idx) + i,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0buf[i]);
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&priv->spi_lock);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(priv->spi_tx_buf, buf, TXBDAT_OFF +=
 len);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_spi_trans(spi, TXBDAT_OFF + len);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&priv->spi_lock);
> =A0 =A0 =A0 =A0}
> =A0}
>
> @@ -408,13 +404,9 @@ static void mcp251x_hw_rx_frame(struct spi_device *s=
pi, u8 *buf,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0for (; i < (RXBDAT_OFF + len); i++)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0buf[i] =3D mcp251x_read_re=
g(spi, RXBCTRL(buf_idx) + i);
> =A0 =A0 =A0 =A0} else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_lock(&priv->spi_lock);
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->spi_tx_buf[RXBCTRL_OFF] =3D INSTRUCT=
ION_READ_RXB(buf_idx);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_spi_trans(spi, SPI_TRANSFER_BUF_LE=
N);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0memcpy(buf, priv->spi_rx_buf, SPI_TRANSFER=
_BUF_LEN);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mutex_unlock(&priv->spi_lock);
> =A0 =A0 =A0 =A0}
> =A0}
>
> @@ -467,21 +459,6 @@ static void mcp251x_hw_sleep(struct spi_device *spi)
> =A0 =A0 =A0 =A0mcp251x_write_reg(spi, CANCTRL, CANCTRL_REQOP_SLEEP);
> =A0}
>
> -static void mcp251x_hw_wakeup(struct spi_device *spi)
> -{
> - =A0 =A0 =A0 struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
> -
> - =A0 =A0 =A0 priv->wake =3D 1;
> -
> - =A0 =A0 =A0 /* Can only wake up by generating a wake-up interrupt. */
> - =A0 =A0 =A0 mcp251x_write_bits(spi, CANINTE, CANINTE_WAKIE, CANINTE_WAK=
IE);
> - =A0 =A0 =A0 mcp251x_write_bits(spi, CANINTF, CANINTF_WAKIF, CANINTF_WAK=
IF);
> -
> - =A0 =A0 =A0 /* Wait until the device is awake */
> - =A0 =A0 =A0 if (!wait_for_completion_timeout(&priv->awake, HZ))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "MCP251x didn't wake-up\=
n");
> -}
> -
> =A0static netdev_tx_t mcp251x_hard_start_xmit(struct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 struct net_device *net)
> =A0{
> @@ -490,7 +467,6 @@ static netdev_tx_t mcp251x_hard_start_xmit(struct sk_=
buff *skb,
>
> =A0 =A0 =A0 =A0if (priv->tx_skb || priv->tx_len) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_warn(&spi->dev, "hard_xmit called whil=
e tx busy\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_stop_queue(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return NETDEV_TX_BUSY;
> =A0 =A0 =A0 =A0}
>
> @@ -511,12 +487,13 @@ static int mcp251x_do_set_mode(struct net_device *n=
et, enum can_mode mode)
>
> =A0 =A0 =A0 =A0switch (mode) {
> =A0 =A0 =A0 =A0case CAN_MODE_START:
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_clean(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* We have to delay work since SPI I/O may=
 sleep */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->restart_tx =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (priv->can.restart_ms =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->after_suspend =3D AF=
TER_SUSPEND_RESTART;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv->irq_work);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv->restart_work);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0default:
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EOPNOTSUPP;
> @@ -525,7 +502,7 @@ static int mcp251x_do_set_mode(struct net_device *net=
, enum can_mode mode)
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void mcp251x_set_normal_mode(struct spi_device *spi)
> +static int mcp251x_set_normal_mode(struct spi_device *spi)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
> =A0 =A0 =A0 =A0unsigned long timeout;
> @@ -533,8 +510,7 @@ static void mcp251x_set_normal_mode(struct spi_device=
 *spi)
> =A0 =A0 =A0 =A0/* Enable interrupts */
> =A0 =A0 =A0 =A0mcp251x_write_reg(spi, CANINTE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0CANINTE_ERRIE | CANINT=
E_TX2IE | CANINTE_TX1IE |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CANINTE_TX0IE | CANINTE=
_RX1IE | CANINTE_RX0IE |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CANINTF_MERRF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 CANINTE_TX0IE | CANINTE=
_RX1IE | CANINTE_RX0IE);
>
> =A0 =A0 =A0 =A0if (priv->can.ctrlmode & CAN_CTRLMODE_LOOPBACK) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Put device into loopback mode */
> @@ -555,11 +531,12 @@ static void mcp251x_set_normal_mode(struct spi_devi=
ce *spi)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (time_after(jiffies, ti=
meout)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&s=
pi->dev, "MCP251x didn't"
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0" enter in normal mode\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBU=
SY;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0priv->can.state =3D CAN_STATE_ERROR_ACTIVE;
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0static int mcp251x_do_set_bittiming(struct net_device *net)
> @@ -590,33 +567,39 @@ static int mcp251x_setup(struct net_device *net, st=
ruct mcp251x_priv *priv,
> =A0{
> =A0 =A0 =A0 =A0mcp251x_do_set_bittiming(net);
>
> - =A0 =A0 =A0 /* Enable RX0->RX1 buffer roll over and disable filters */
> - =A0 =A0 =A0 mcp251x_write_bits(spi, RXBCTRL(0),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RXBCTRL_BUKT | RXBCT=
RL_RXM0 | RXBCTRL_RXM1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RXBCTRL_BUKT | RXBCT=
RL_RXM0 | RXBCTRL_RXM1);
> - =A0 =A0 =A0 mcp251x_write_bits(spi, RXBCTRL(1),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RXBCTRL_RXM0 | RXBCT=
RL_RXM1,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RXBCTRL_RXM0 | RXBCT=
RL_RXM1);
> + =A0 =A0 =A0 mcp251x_write_reg(spi, RXBCTRL(0),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RXBCTRL_BUKT | RXBCTRL_=
RXM0 | RXBCTRL_RXM1);
> + =A0 =A0 =A0 mcp251x_write_reg(spi, RXBCTRL(1),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RXBCTRL_RXM0 | RXBCTRL_=
RXM1);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static void mcp251x_hw_reset(struct spi_device *spi)
> +static int mcp251x_hw_reset(struct spi_device *spi)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
> =A0 =A0 =A0 =A0int ret;
> -
> - =A0 =A0 =A0 mutex_lock(&priv->spi_lock);
> + =A0 =A0 =A0 unsigned long timeout;
>
> =A0 =A0 =A0 =A0priv->spi_tx_buf[0] =3D INSTRUCTION_RESET;
> -
> =A0 =A0 =A0 =A0ret =3D spi_write(spi, priv->spi_tx_buf, 1);
> -
> - =A0 =A0 =A0 mutex_unlock(&priv->spi_lock);
> -
> - =A0 =A0 =A0 if (ret)
> + =A0 =A0 =A0 if (ret) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_err(&spi->dev, "reset failed: ret =3D =
%d\n", ret);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EIO;
> + =A0 =A0 =A0 }
> +
> =A0 =A0 =A0 =A0/* Wait for reset to finish */
> + =A0 =A0 =A0 timeout =3D jiffies + HZ;
> =A0 =A0 =A0 =A0mdelay(10);
> + =A0 =A0 =A0 while ((mcp251x_read_reg(spi, CANSTAT) & CANCTRL_REQOP_MASK)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0!=3D CANCTRL_REQOP_CONF) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (time_after(jiffies, timeout)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "MCP251x=
 didn't"
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 " enter in =
conf mode after reset\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EBUSY;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 return 0;
> =A0}
>
> =A0static int mcp251x_hw_probe(struct spi_device *spi)
> @@ -640,63 +623,17 @@ static int mcp251x_hw_probe(struct spi_device *spi)
> =A0 =A0 =A0 =A0return (st1 =3D=3D 0x80 && st2 =3D=3D 0x07) ? 1 : 0;
> =A0}
>
> -static irqreturn_t mcp251x_can_isr(int irq, void *dev_id)
> -{
> - =A0 =A0 =A0 struct net_device *net =3D (struct net_device *)dev_id;
> - =A0 =A0 =A0 struct mcp251x_priv *priv =3D netdev_priv(net);
> -
> - =A0 =A0 =A0 /* Schedule bottom half */
> - =A0 =A0 =A0 if (!work_pending(&priv->irq_work))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv->irq_work);
> -
> - =A0 =A0 =A0 return IRQ_HANDLED;
> -}
> -
> -static int mcp251x_open(struct net_device *net)
> +static void mcp251x_open_clean(struct net_device *net)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D netdev_priv(net);
> =A0 =A0 =A0 =A0struct spi_device *spi =3D priv->spi;
> =A0 =A0 =A0 =A0struct mcp251x_platform_data *pdata =3D spi->dev.platform_=
data;
> - =A0 =A0 =A0 int ret;
> -
> - =A0 =A0 =A0 ret =3D open_candev(net);
> - =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "unable to set initial b=
audrate!\n");
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> - =A0 =A0 =A0 }
>
> + =A0 =A0 =A0 free_irq(spi->irq, priv);
> + =A0 =A0 =A0 mcp251x_hw_sleep(spi);
> =A0 =A0 =A0 =A0if (pdata->transceiver_enable)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->transceiver_enable(1);
> -
> - =A0 =A0 =A0 priv->force_quit =3D 0;
> - =A0 =A0 =A0 priv->tx_skb =3D NULL;
> - =A0 =A0 =A0 priv->tx_len =3D 0;
> -
> - =A0 =A0 =A0 ret =3D request_irq(spi->irq, mcp251x_can_isr,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IRQF_TRIGGER_FALLING, D=
EVICE_NAME, net);
> - =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "failed to acquire irq %=
d\n", spi->irq);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pdata->transceiver_enable)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->transceiver_enable(0=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 close_candev(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> - =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 mcp251x_hw_wakeup(spi);
> - =A0 =A0 =A0 mcp251x_hw_reset(spi);
> - =A0 =A0 =A0 ret =3D mcp251x_setup(net, priv, spi);
> - =A0 =A0 =A0 if (ret) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 free_irq(spi->irq, net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_sleep(spi);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pdata->transceiver_enable)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->transceiver_enable(0=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 close_candev(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 mcp251x_set_normal_mode(spi);
> - =A0 =A0 =A0 netif_wake_queue(net);
> -
> - =A0 =A0 =A0 return 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->transceiver_enable(0);
> + =A0 =A0 =A0 close_candev(net);
> =A0}
>
> =A0static int mcp251x_stop(struct net_device *net)
> @@ -707,17 +644,19 @@ static int mcp251x_stop(struct net_device *net)
>
> =A0 =A0 =A0 =A0close_candev(net);
>
> + =A0 =A0 =A0 priv->force_quit =3D 1;
> + =A0 =A0 =A0 free_irq(spi->irq, priv);
> + =A0 =A0 =A0 destroy_workqueue(priv->wq);
> + =A0 =A0 =A0 priv->wq =3D NULL;
> +
> + =A0 =A0 =A0 mutex_lock(&priv->mcp_lock);
> +
> =A0 =A0 =A0 =A0/* Disable and clear pending interrupts */
> =A0 =A0 =A0 =A0mcp251x_write_reg(spi, CANINTE, 0x00);
> =A0 =A0 =A0 =A0mcp251x_write_reg(spi, CANINTF, 0x00);
>
> - =A0 =A0 =A0 priv->force_quit =3D 1;
> - =A0 =A0 =A0 free_irq(spi->irq, net);
> - =A0 =A0 =A0 flush_workqueue(priv->wq);
> -
> =A0 =A0 =A0 =A0mcp251x_write_reg(spi, TXBCTRL(0), 0);
> - =A0 =A0 =A0 if (priv->tx_skb || priv->tx_len)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_clean(net);
> + =A0 =A0 =A0 mcp251x_clean(net);
>
> =A0 =A0 =A0 =A0mcp251x_hw_sleep(spi);
>
> @@ -726,9 +665,27 @@ static int mcp251x_stop(struct net_device *net)
>
> =A0 =A0 =A0 =A0priv->can.state =3D CAN_STATE_STOPPED;
>
> + =A0 =A0 =A0 mutex_unlock(&priv->mcp_lock);
> +
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> +static void mcp251x_error_skb(struct net_device *net, int can_id, int da=
ta1)
> +{
> + =A0 =A0 =A0 struct sk_buff *skb;
> + =A0 =A0 =A0 struct can_frame *frame;
> +
> + =A0 =A0 =A0 skb =3D alloc_can_err_skb(net, &frame);
> + =A0 =A0 =A0 if (skb) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->can_id =3D can_id;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->data[1] =3D data1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(skb);
> + =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&net->dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "cannot allocate error skb\=
n");
> + =A0 =A0 =A0 }
> +}
> +
> =A0static void mcp251x_tx_work_handler(struct work_struct *ws)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D container_of(ws, struct mcp2=
51x_priv,
> @@ -737,33 +694,32 @@ static void mcp251x_tx_work_handler(struct work_str=
uct *ws)
> =A0 =A0 =A0 =A0struct net_device *net =3D priv->net;
> =A0 =A0 =A0 =A0struct can_frame *frame;
>
> + =A0 =A0 =A0 mutex_lock(&priv->mcp_lock);
> =A0 =A0 =A0 =A0if (priv->tx_skb) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D (struct can_frame *)priv->tx_skb-=
>data;
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (priv->can.state =3D=3D CAN_STATE_BUS_O=
FF) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_clean(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame =3D (struct can_frame=
 *)priv->tx_skb->data;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (frame->can_dlc > CAN_FR=
AME_MAX_DATA_LEN)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->can_=
dlc =3D CAN_FRAME_MAX_DATA_LEN;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_tx(spi, frame, 0=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tx_len =3D 1 + frame-=
>can_dlc;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 can_put_echo_skb(priv->tx_s=
kb, net, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tx_skb =3D NULL;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (frame->can_dlc > CAN_FRAME_MAX_DATA_LEN)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->can_dlc =3D CAN_FRAM=
E_MAX_DATA_LEN;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_tx(spi, frame, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tx_len =3D 1 + frame->can_dlc;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 can_put_echo_skb(priv->tx_skb, net, 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->tx_skb =3D NULL;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 mutex_unlock(&priv->mcp_lock);
> =A0}
>
> -static void mcp251x_irq_work_handler(struct work_struct *ws)
> +static void mcp251x_restart_work_handler(struct work_struct *ws)
> =A0{
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D container_of(ws, struct mcp2=
51x_priv,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0irq_work);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0restart_work);
> =A0 =A0 =A0 =A0struct spi_device *spi =3D priv->spi;
> =A0 =A0 =A0 =A0struct net_device *net =3D priv->net;
> - =A0 =A0 =A0 u8 txbnctrl;
> - =A0 =A0 =A0 u8 intf;
> - =A0 =A0 =A0 enum can_state new_state;
>
> + =A0 =A0 =A0 mutex_lock(&priv->mcp_lock);
> =A0 =A0 =A0 =A0if (priv->after_suspend) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mdelay(10);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_hw_reset(spi);
> @@ -772,45 +728,54 @@ static void mcp251x_irq_work_handler(struct work_st=
ruct *ws)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_set_normal_mode(sp=
i);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (priv->after_suspend & AFTER_SUS=
PEND_UP) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_device_attach(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Clean since we lost tx b=
uffer */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->tx_skb || priv->t=
x_len) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_cle=
an(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_=
queue(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_clean(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_set_normal_mode(sp=
i);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_hw_sleep(spi);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->after_suspend =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->force_quit =3D 0;
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (priv->can.restart_ms =3D=3D 0 && priv->can.state =3D=3D=
 CAN_STATE_BUS_OFF)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 if (priv->restart_tx) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->restart_tx =3D 0;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_reg(spi, TXBCTRL(0), 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_clean(net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_error_skb(net, CAN_ERR_RESTARTED, 0=
);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 mutex_unlock(&priv->mcp_lock);
> +}
>
> - =A0 =A0 =A0 while (!priv->force_quit && !freezing(current)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 eflag =3D mcp251x_read_reg(spi, EFLG);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 int can_id =3D 0, data1 =3D 0;
> +static irqreturn_t mcp251x_can_ist(int irq, void *dev_id)
> +{
> + =A0 =A0 =A0 struct mcp251x_priv *priv =3D dev_id;
> + =A0 =A0 =A0 struct spi_device *spi =3D priv->spi;
> + =A0 =A0 =A0 struct net_device *net =3D priv->net;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_reg(spi, EFLG, 0x00);
> + =A0 =A0 =A0 mutex_lock(&priv->mcp_lock);
> + =A0 =A0 =A0 while (!priv->force_quit) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enum can_state new_state;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 intf =3D mcp251x_read_reg(spi, CANINTF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 u8 eflag;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 int can_id =3D 0, data1 =3D 0;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->restart_tx) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->restart_tx =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_reg(spi, TXBC=
TRL(0), 0);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->tx_skb || priv->t=
x_len)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_cle=
an(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_queue(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 can_id |=3D CAN_ERR_RESTART=
ED;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_RX0IF) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_rx(spi, 0);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Free one buffer ASAP */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_bits(spi, CAN=
INTF, intf & CANINTF_RX0IF,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A00x00);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->wake) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Wait whilst the device w=
akes up */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdelay(10);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->wake =3D 0;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_RX1IF)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_rx(spi, 1);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 intf =3D mcp251x_read_reg(spi, CANINTF);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_write_bits(spi, CANINTF, intf, 0x0=
0);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 eflag =3D mcp251x_read_reg(spi, EFLG);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_write_reg(spi, EFLG, 0x00);
> +
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Update can state */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (eflag & EFLG_TXBO) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0new_state =3D CAN_STATE_BU=
S_OFF;
> @@ -851,59 +816,31 @@ static void mcp251x_irq_work_handler(struct work_st=
ruct *ws)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->can.state =3D new_state;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if ((intf & CANINTF_ERRIF) || (can_id & CAN=
_ERR_RESTARTED)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct sk_buff *skb;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct can_frame *frame;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Create error frame */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 skb =3D alloc_can_err_skb(n=
et, &frame);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (skb) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Set erro=
r frame flags based on bus state */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->can_=
id =3D can_id;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 frame->data=
[1] =3D data1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Update n=
et stats for overflows */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (eflag &=
 (EFLG_RX0OVR | EFLG_RX1OVR)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 if (eflag & EFLG_RX0OVR)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 net->stats.rx_over_errors++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 if (eflag & EFLG_RX1OVR)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 net->stats.rx_over_errors++;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 frame->can_id |=3D CAN_ERR_CRTL;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 frame->data[1] |=3D
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 CAN_ERR_CRTL_RX_OVERFLOW;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_rx(sk=
b);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 } else {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_info(&s=
pi->dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0"cannot allocate error skb\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_ERRIF) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Handle overflow counters=
 */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (eflag & (EFLG_RX0OVR | =
EFLG_RX1OVR)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (eflag &=
 EFLG_RX0OVR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 net->stats.rx_over_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (eflag &=
 EFLG_RX1OVR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 net->stats.rx_over_errors++;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 can_id |=3D=
 CAN_ERR_CRTL;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 data1 |=3D =
CAN_ERR_CRTL_RX_OVERFLOW;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_error_skb(net, can_=
id, data1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (priv->can.state =3D=3D CAN_STATE_BUS_O=
FF) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (priv->can.restart_ms =
=3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 priv->force=
_quit =3D 1;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0can_bus_of=
f(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mcp251x_hw=
_sleep(spi);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (intf =3D=3D 0)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_WAKIF)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 complete(&priv->awake);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_MERRF) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* If there are pending Tx =
buffers, restart queue */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 txbnctrl =3D mcp251x_read_r=
eg(spi, TXBCTRL(0));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(txbnctrl & TXBCTRL_TX=
REQ)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (priv->t=
x_skb || priv->tx_len)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 mcp251x_clean(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_wake_=
queue(net);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> -
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (intf & (CANINTF_TX2IF | CANINTF_TX1IF =
| CANINTF_TX0IF)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0net->stats.tx_packets++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0net->stats.tx_bytes +=3D p=
riv->tx_len - 1;
> @@ -914,12 +851,66 @@ static void mcp251x_irq_work_handler(struct work_st=
ruct *ws)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_wake_queue(net);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_RX0IF)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_rx(spi, 0);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 mutex_unlock(&priv->mcp_lock);
> + =A0 =A0 =A0 return IRQ_HANDLED;
> +}
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intf & CANINTF_RX1IF)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_hw_rx(spi, 1);
> +static int mcp251x_open(struct net_device *net)
> +{
> + =A0 =A0 =A0 struct mcp251x_priv *priv =3D netdev_priv(net);
> + =A0 =A0 =A0 struct spi_device *spi =3D priv->spi;
> + =A0 =A0 =A0 struct mcp251x_platform_data *pdata =3D spi->dev.platform_d=
ata;
> + =A0 =A0 =A0 int ret;
> +
> + =A0 =A0 =A0 ret =3D open_candev(net);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "unable to set initial b=
audrate!\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return ret;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 mutex_lock(&priv->mcp_lock);
> + =A0 =A0 =A0 if (pdata->transceiver_enable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->transceiver_enable(1);
> +
> + =A0 =A0 =A0 priv->force_quit =3D 0;
> + =A0 =A0 =A0 priv->tx_skb =3D NULL;
> + =A0 =A0 =A0 priv->tx_len =3D 0;
> +
> + =A0 =A0 =A0 ret =3D request_threaded_irq(spi->irq, NULL, mcp251x_can_is=
t,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IRQF_TRIGGER_FALLING, D=
EVICE_NAME, priv);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev_err(&spi->dev, "failed to acquire irq %=
d\n", spi->irq);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (pdata->transceiver_enable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 pdata->transceiver_enable(0=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 close_candev(net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto open_unlock;
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 priv->wq =3D create_freezeable_workqueue("mcp251x_wq");
> + =A0 =A0 =A0 INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
> + =A0 =A0 =A0 INIT_WORK(&priv->restart_work, mcp251x_restart_work_handler=
);
> +
> + =A0 =A0 =A0 ret =3D mcp251x_hw_reset(spi);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_open_clean(net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto open_unlock;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 ret =3D mcp251x_setup(net, priv, spi);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_open_clean(net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto open_unlock;
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 ret =3D mcp251x_set_normal_mode(spi);
> + =A0 =A0 =A0 if (ret) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mcp251x_open_clean(net);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto open_unlock;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 netif_wake_queue(net);
> +
> +open_unlock:
> + =A0 =A0 =A0 mutex_unlock(&priv->mcp_lock);
> + =A0 =A0 =A0 return ret;
> =A0}
>
> =A0static const struct net_device_ops mcp251x_netdev_ops =3D {
> @@ -961,7 +952,7 @@ static int __devinit mcp251x_can_probe(struct spi_dev=
ice *spi)
> =A0 =A0 =A0 =A0dev_set_drvdata(&spi->dev, priv);
>
> =A0 =A0 =A0 =A0priv->spi =3D spi;
> - =A0 =A0 =A0 mutex_init(&priv->spi_lock);
> + =A0 =A0 =A0 mutex_init(&priv->mcp_lock);
>
> =A0 =A0 =A0 =A0/* If requested, allocate DMA buffers */
> =A0 =A0 =A0 =A0if (mcp251x_enable_dma) {
> @@ -1010,18 +1001,12 @@ static int __devinit mcp251x_can_probe(struct spi=
_device *spi)
>
> =A0 =A0 =A0 =A0SET_NETDEV_DEV(net, &spi->dev);
>
> - =A0 =A0 =A0 priv->wq =3D create_freezeable_workqueue("mcp251x_wq");
> -
> - =A0 =A0 =A0 INIT_WORK(&priv->tx_work, mcp251x_tx_work_handler);
> - =A0 =A0 =A0 INIT_WORK(&priv->irq_work, mcp251x_irq_work_handler);
> -
> - =A0 =A0 =A0 init_completion(&priv->awake);
> -
> =A0 =A0 =A0 =A0/* Configure the SPI bus */
> =A0 =A0 =A0 =A0spi->mode =3D SPI_MODE_0;
> =A0 =A0 =A0 =A0spi->bits_per_word =3D 8;
> =A0 =A0 =A0 =A0spi_setup(spi);
>
> + =A0 =A0 =A0 /* Here is OK to not lock the MCP, no one knows about it ye=
t */
> =A0 =A0 =A0 =A0if (!mcp251x_hw_probe(spi)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev_info(&spi->dev, "Probe failed\n");
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0goto error_probe;
> @@ -1064,10 +1049,6 @@ static int __devexit mcp251x_can_remove(struct spi=
_device *spi)
> =A0 =A0 =A0 =A0unregister_candev(net);
> =A0 =A0 =A0 =A0free_candev(net);
>
> - =A0 =A0 =A0 priv->force_quit =3D 1;
> - =A0 =A0 =A0 flush_workqueue(priv->wq);
> - =A0 =A0 =A0 destroy_workqueue(priv->wq);
> -
> =A0 =A0 =A0 =A0if (mcp251x_enable_dma) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dma_free_coherent(&spi->dev, PAGE_SIZE,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->=
spi_tx_buf, priv->spi_tx_dma);
> @@ -1089,6 +1070,12 @@ static int mcp251x_can_suspend(struct spi_device *=
spi, pm_message_t state)
> =A0 =A0 =A0 =A0struct mcp251x_priv *priv =3D dev_get_drvdata(&spi->dev);
> =A0 =A0 =A0 =A0struct net_device *net =3D priv->net;
>
> + =A0 =A0 =A0 priv->force_quit =3D 1;
> + =A0 =A0 =A0 disable_irq(spi->irq);
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Note: at this point neither IST nor workqueues are run=
ning.
> + =A0 =A0 =A0 =A0* open/stop cannot be called anyway so locking is not ne=
eded
> + =A0 =A0 =A0 =A0*/
> =A0 =A0 =A0 =A0if (netif_running(net)) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_device_detach(net);
>
> @@ -1115,16 +1102,18 @@ static int mcp251x_can_resume(struct spi_device *=
spi)
>
> =A0 =A0 =A0 =A0if (priv->after_suspend & AFTER_SUSPEND_POWER) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pdata->power_enable(1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv->irq_work);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv->restart_work);
> =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (priv->after_suspend & AFTER_SUSPEND_UP=
) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (pdata->transceiver_ena=
ble)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0pdata->tra=
nsceiver_enable(1);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv-=
>irq_work);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 queue_work(priv->wq, &priv-=
>restart_work);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0priv->after_suspend =3D 0;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> + =A0 =A0 =A0 priv->force_quit =3D 0;
> + =A0 =A0 =A0 enable_irq(spi->irq);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> =A0#else
> --
> 1.5.6.5
>
>



-- =

Christian Pellegrin, see http://www.evolware.org/chri/
"Real Programmers don't play tennis, or any other sport which requires
you to change clothes. Mountain climbing is OK, and Real Programmers
wear their climbing boots to work in case a mountain should suddenly
spring up in the middle of the computer room."
