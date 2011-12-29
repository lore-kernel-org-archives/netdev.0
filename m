From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH 1/1] via-rhine: Fix hanging with high CPU load on low-end broads.
Date: Thu, 29 Dec 2011 23:00:33 +0100
Message-ID: <CACPM=kX_2W54FuyGaJ8nb188N_aCa37Jfc+TmaGxwEnszntOeg@mail.gmail.com>
References: <1325092423.2327.70.camel@deadeye>
	<CACPM=kX2hcGt3XXDJkCAcOjv=5oqSHChhhphUAyRhR_PsNFEEQ@mail.gmail.com>
	<20111228101710.51c4893f@nehalam.linuxnetplumber.net>
	<20111228.133450.479385013770977594.davem@davemloft.net>
	<CACPM=kXOddA+T6vQPijR6sh8x5cMO=4baKGeKxEmMKG896Lz4g@mail.gmail.com>
	<20111229153902.GB21946@electric-eye.fr.zoreil.com>
	<20111229183902.GC21946@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, shemminger@vyatta.com,
	bhutchings@solarflare.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, rl@hellgate.ch
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20111229183902.GC21946@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2011/12/29 Francois Romieu <romieu@fr.zoreil.com>:
> Francois Romieu <romieu@fr.zoreil.com> :
> [...]
>> Feel free to try the extra "new year's eve week end is getting close=
r"
>> patch below (against net-next).
>>
>> You have been warned.
>
> The one below could be a bit better.
>
> Out for dinner.

Thanks, I'll try that one in a while, once I'm done bisecting 3.1.4 ->
3.1.5, since all kernels after 3.1.4 won't pass control onto init.

/Bjarke

> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ether=
net/via/via-rhine.c
> index 5c4983b..66e5c08 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -42,7 +42,8 @@
>
> =A0#define DEBUG
> =A0static int debug =3D 1; =A0/* 1 normal messages, 0 quiet .. 7 verb=
ose. */
> -static int max_interrupt_work =3D 20;
> +#define RHINE_MSG_DEFAULT \
> + =A0 =A0 =A0 =A0(NETIF_MSG_INTR)
>
> =A0/* Set the copy breakpoint for the copy-only-tiny-frames scheme.
> =A0 =A0Setting to > 1518 effectively disables this feature. */
> @@ -128,11 +129,9 @@ MODULE_AUTHOR("Donald Becker <becker@scyld.com>"=
);
> =A0MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
> =A0MODULE_LICENSE("GPL");
>
> -module_param(max_interrupt_work, int, 0);
> =A0module_param(debug, int, 0);
> =A0module_param(rx_copybreak, int, 0);
> =A0module_param(avoid_D3, bool, 0);
> -MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handl=
ed per interrupt");
> =A0MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
> =A0MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy=
-only-tiny-frames");
> =A0MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for =
broken BIOSes)");
> @@ -351,16 +350,25 @@ static const int mmio_verify_registers[] =3D {
>
> =A0/* Bits in the interrupt status/mask registers. */
> =A0enum intr_status_bits {
> - =A0 =A0 =A0 IntrRxDone=3D0x0001, IntrRxErr=3D0x0004, IntrRxEmpty=3D=
0x0020,
> - =A0 =A0 =A0 IntrTxDone=3D0x0002, IntrTxError=3D0x0008, IntrTxUnderr=
un=3D0x0210,
> - =A0 =A0 =A0 IntrPCIErr=3D0x0040,
> - =A0 =A0 =A0 IntrStatsMax=3D0x0080, IntrRxEarly=3D0x0100,
> - =A0 =A0 =A0 IntrRxOverflow=3D0x0400, IntrRxDropped=3D0x0800, IntrRx=
NoBuf=3D0x1000,
> - =A0 =A0 =A0 IntrTxAborted=3D0x2000, IntrLinkChange=3D0x4000,
> - =A0 =A0 =A0 IntrRxWakeUp=3D0x8000,
> - =A0 =A0 =A0 IntrNormalSummary=3D0x0003, IntrAbnormalSummary=3D0xC26=
0,
> - =A0 =A0 =A0 IntrTxDescRace=3D0x080000, =A0 =A0 =A0 =A0/* mapped fro=
m IntrStatus2 */
> - =A0 =A0 =A0 IntrTxErrSummary=3D0x082218,
> + =A0 =A0 =A0 IntrRxDone =A0 =A0 =A0=3D 0x0001,
> + =A0 =A0 =A0 IntrTxDone =A0 =A0 =A0=3D 0x0002,
> + =A0 =A0 =A0 IntrRxErr =A0 =A0 =A0 =3D 0x0004,
> + =A0 =A0 =A0 IntrTxError =A0 =A0 =3D 0x0008,
> + =A0 =A0 =A0 IntrRxEmpty =A0 =A0 =3D 0x0020,
> + =A0 =A0 =A0 IntrPCIErr =A0 =A0 =A0=3D 0x0040,
> + =A0 =A0 =A0 IntrStatsMax =A0 =A0=3D 0x0080,
> + =A0 =A0 =A0 IntrRxEarly =A0 =A0 =3D 0x0100,
> + =A0 =A0 =A0 IntrTxUnderrun =A0=3D 0x0210,
> + =A0 =A0 =A0 IntrRxOverflow =A0=3D 0x0400,
> + =A0 =A0 =A0 IntrRxDropped =A0 =3D 0x0800,
> + =A0 =A0 =A0 IntrRxNoBuf =A0 =A0 =3D 0x1000,
> + =A0 =A0 =A0 IntrTxAborted =A0 =3D 0x2000,
> + =A0 =A0 =A0 IntrLinkChange =A0=3D 0x4000,
> + =A0 =A0 =A0 IntrRxWakeUp =A0 =A0=3D 0x8000,
> + =A0 =A0 =A0 IntrTxDescRace =A0 =A0 =A0 =A0 =A0=3D 0x080000, =A0 =A0=
 /* mapped from IntrStatus2 */
> + =A0 =A0 =A0 IntrNormalSummary =A0 =A0 =A0 =3D IntrRxDone | IntrTxDo=
ne,
> + =A0 =A0 =A0 IntrTxErrSummary =A0 =A0 =A0 =A0=3D IntrTxDescRace | In=
trTxAborted | IntrTxError |
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Int=
rTxUnderrun,
> =A0};
>
> =A0/* Bits in WOLcrSet/WOLcrClr and PwrcsrSet/PwrcsrClr */
> @@ -439,8 +447,12 @@ struct rhine_private {
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0struct napi_struct napi;
> =A0 =A0 =A0 =A0spinlock_t lock;
> + =A0 =A0 =A0 struct mutex task_lock;
> + =A0 =A0 =A0 struct work_struct slow_event_task;
> =A0 =A0 =A0 =A0struct work_struct reset_task;
>
> + =A0 =A0 =A0 u32 msg_enable;
> +
> =A0 =A0 =A0 =A0/* Frequently used values: keep some adjacent for cach=
e effect. */
> =A0 =A0 =A0 =A0u32 quirks;
> =A0 =A0 =A0 =A0struct rx_desc *rx_head_desc;
> @@ -482,7 +494,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buff =
*skb,
> =A0static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
> =A0static void rhine_tx(struct net_device *dev);
> =A0static int rhine_rx(struct net_device *dev, int limit);
> -static void rhine_error(struct net_device *dev, int intr_status);
> =A0static void rhine_set_rx_mode(struct net_device *dev);
> =A0static struct net_device_stats *rhine_get_stats(struct net_device =
*dev);
> =A0static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, =
int cmd);
> @@ -497,6 +508,8 @@ static void rhine_set_cam_mask(void __iomem *ioad=
dr, u32 mask);
> =A0static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask=
);
> =A0static void rhine_init_cam_filter(struct net_device *dev);
> =A0static void rhine_update_vcam(struct net_device *dev);
> +static void rhine_slow_event_task(struct work_struct *work);
> +static void rhine_restart_tx(struct net_device *dev);
>
> =A0#define RHINE_WAIT_FOR(condition) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0\
> =A0do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> @@ -508,7 +521,7 @@ do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0\
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A01024 - i, __func__, __=
LINE__); =A0 =A0 =A0 =A0 =A0\
> =A0} while (0)
>
> -static inline u32 get_intr_status(struct net_device *dev)
> +static u32 get_intr_status(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> @@ -521,6 +534,16 @@ static inline u32 get_intr_status(struct net_dev=
ice *dev)
> =A0 =A0 =A0 =A0return intr_status;
> =A0}
>
> +static void rhine_ack_event(struct rhine_private *rp, u32 mask)
> +{
> + =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> +
> + =A0 =A0 =A0 if (rp->quirks & rqStatusWBRace)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite8(mask >> 16, ioaddr + IntrStatu=
s2);
> + =A0 =A0 =A0 iowrite16(mask, ioaddr + IntrStatus);
> + =A0 =A0 =A0 mmiowb();
> +}
> +
> =A0/*
> =A0* Get power related registers into sane state.
> =A0* Notify user about past WOL event.
> @@ -657,23 +680,127 @@ static void rhine_poll(struct net_device *dev)
> =A0}
> =A0#endif
>
> +static void rhine_kick_tx_threshold(struct rhine_private *rp)
> +{
> + =A0 =A0 =A0 if (rp->tx_thresh < 0xe0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rp->tx_thresh +=3D 0x20;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 BYTE_REG_BITS_SET(rp->tx_thresh, 0x80, =
ioaddr + TxConfig);
> + =A0 =A0 =A0 }
> +}
> +
> +static void rhine_tx_err(struct rhine_private *rp, u32 status)
> +{
> + =A0 =A0 =A0 struct net_device *dev =3D rp->dev;
> +
> + =A0 =A0 =A0 if (status & IntrTxAborted) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_info(rp, tx_err, dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Abort %08x, fra=
me dropped\n", status);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (status & IntrTxUnderrun) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_kick_tx_threshold(rp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_info(rp, tx_err ,dev, "Transmitte=
r underrun, "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Tx threshold no=
w %02x\n", rp->tx_thresh);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (status & IntrTxDescRace)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_info(rp, tx_err, dev, "Tx descrip=
tor write-back race\n");
> +
> + =A0 =A0 =A0 if ((status & IntrTxError) &&
> + =A0 =A0 =A0 =A0 =A0 (status & (IntrTxAborted | IntrTxUnderrun | Int=
rTxDescRace)) =3D=3D 0) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_kick_tx_threshold(rp);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_info(rp, tx_err, dev, "Unspecifie=
d error. "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"Tx threshold no=
w %02x\n", rp->tx_thresh);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 rhine_restart_tx(dev);
> +}
> +
> +static void rhine_update_rx_crc_and_missed_errord(struct rhine_priva=
te *rp)
> +{
> + =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> + =A0 =A0 =A0 struct net_device_stats *stats =3D &rp->dev->stats;
> +
> + =A0 =A0 =A0 stats->rx_crc_errors =A0 =A0+=3D ioread16(ioaddr + RxCR=
CErrs);
> + =A0 =A0 =A0 stats->rx_missed_errors +=3D ioread16(ioaddr + RxMissed=
);
> +
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Clears the "tally counters" for CRC errors and mis=
sed frames(?).
> + =A0 =A0 =A0 =A0* It has been reported that some chips need a write =
of 0 to clear
> + =A0 =A0 =A0 =A0* these, for others the counters are set to 1 when w=
ritten to and
> + =A0 =A0 =A0 =A0* instead cleared when read. So we clear them both w=
ays ...
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 iowrite32(0, ioaddr + RxMissed);
> + =A0 =A0 =A0 ioread16(ioaddr + RxCRCErrs);
> + =A0 =A0 =A0 ioread16(ioaddr + RxMissed);
> +}
> +
> +#define RHINE_EVENT_NAPI_RX =A0 =A0(IntrRxDone | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
RxErr | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
RxEmpty | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
RxOverflow | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
RxDropped | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
RxNoBuf | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
RxWakeUp)
> +
> +#define RHINE_EVENT_NAPI_TX_ERR =A0 =A0 =A0 =A0(IntrTxError | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
TxAborted | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
TxUnderrun | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
TxDescRace)
> +#define RHINE_EVENT_NAPI_TX =A0 =A0(IntrTxDone | RHINE_EVENT_NAPI_TX=
_ERR)
> +
> +#define RHINE_EVENT_NAPI =A0 =A0 =A0 (RHINE_EVENT_NAPI_RX | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RHIN=
E_EVENT_NAPI_TX | \
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0Intr=
StatsMax)
> +#define RHINE_EVENT_SLOW =A0 =A0 =A0 (IntrPCIErr | IntrLinkChange)
> +#define RHINE_EVENT =A0 =A0 =A0 =A0 =A0 =A0(RHINE_EVENT_NAPI | RHINE=
_EVENT_SLOW)
> +
> =A0static int rhine_napipoll(struct napi_struct *napi, int budget)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D container_of(napi, struct=
 rhine_private, napi);
> =A0 =A0 =A0 =A0struct net_device *dev =3D rp->dev;
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> - =A0 =A0 =A0 int work_done;
> + =A0 =A0 =A0 u16 enable_mask =3D RHINE_EVENT & 0xffff;
> + =A0 =A0 =A0 int work_done =3D 0;
> + =A0 =A0 =A0 u32 status;
> +
> + =A0 =A0 =A0 status =3D get_intr_status(dev);
> + =A0 =A0 =A0 rhine_ack_event(rp, status & ~RHINE_EVENT_SLOW);
> +
> + =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_RX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 work_done +=3D rhine_rx(dev, budget);
> +
> + =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_TX) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_TX_ERR) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Avoid scavenging bef=
ore Tx engine turned off */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RHINE_WAIT_FOR(!(ioread=
8(ioaddr + ChipCmd) & CmdTxOn));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (ioread8(ioaddr + Ch=
ipCmd) & CmdTxOn)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_w=
arn(rp, tx_err, dev, "Tx still on\n");
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 work_done =3D rhine_rx(dev, budget);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_tx(dev);
> +
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_TX_ERR)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_tx_err(rp, status=
);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (status & IntrStatsMax) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_lock(&rp->lock);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_update_rx_crc_and_missed_errord(r=
p);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 spin_unlock(&rp->lock);
> + =A0 =A0 =A0 }
> +
> + =A0 =A0 =A0 if (status & RHINE_EVENT_SLOW) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 enable_mask &=3D ~RHINE_EVENT_SLOW;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 schedule_work(&rp->slow_event_task);
> + =A0 =A0 =A0 }
>
> =A0 =A0 =A0 =A0if (work_done < budget) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0napi_complete(napi);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite16(IntrRxDone | IntrRxErr | Intr=
RxEmpty| IntrRxOverflow |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IntrRxDropped | Int=
rRxNoBuf | IntrTxAborted |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IntrTxDone | IntrTx=
Error | IntrTxUnderrun |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IntrPCIErr | IntrSt=
atsMax | IntrLinkChange,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioaddr + IntrEnable=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite16(enable_mask, ioaddr + IntrEna=
ble);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mmiowb();
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0return work_done;
> =A0}
> @@ -797,6 +924,7 @@ static int __devinit rhine_init_one(struct pci_de=
v *pdev,
> =A0 =A0 =A0 =A0rp->quirks =3D quirks;
> =A0 =A0 =A0 =A0rp->pioaddr =3D pioaddr;
> =A0 =A0 =A0 =A0rp->pdev =3D pdev;
> + =A0 =A0 =A0 rp->msg_enable =3D netif_msg_init(-1, RHINE_MSG_DEFAULT=
);
>
> =A0 =A0 =A0 =A0rc =3D pci_request_regions(pdev, DRV_NAME);
> =A0 =A0 =A0 =A0if (rc)
> @@ -856,7 +984,9 @@ static int __devinit rhine_init_one(struct pci_de=
v *pdev,
> =A0 =A0 =A0 =A0dev->irq =3D pdev->irq;
>
> =A0 =A0 =A0 =A0spin_lock_init(&rp->lock);
> + =A0 =A0 =A0 mutex_init(&rp->task_lock);
> =A0 =A0 =A0 =A0INIT_WORK(&rp->reset_task, rhine_reset_task);
> + =A0 =A0 =A0 INIT_WORK(&rp->slow_event_task, rhine_slow_event_task);
>
> =A0 =A0 =A0 =A0rp->mii_if.dev =3D dev;
> =A0 =A0 =A0 =A0rp->mii_if.mdio_read =3D mdio_read;
> @@ -1310,12 +1440,7 @@ static void init_registers(struct net_device *=
dev)
>
> =A0 =A0 =A0 =A0napi_enable(&rp->napi);
>
> - =A0 =A0 =A0 /* Enable interrupts by setting the interrupt mask. */
> - =A0 =A0 =A0 iowrite16(IntrRxDone | IntrRxErr | IntrRxEmpty| IntrRxO=
verflow |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0IntrRxDropped | IntrRxNoBuf | IntrTxAbor=
ted |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0IntrTxDone | IntrTxError | IntrTxUnderru=
n |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0IntrPCIErr | IntrStatsMax | IntrLinkChan=
ge,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0ioaddr + IntrEnable);
> + =A0 =A0 =A0 iowrite16(RHINE_EVENT & 0xffff, ioaddr + IntrEnable);
>
> =A0 =A0 =A0 =A0iowrite16(CmdStart | CmdTxOn | CmdRxOn | (Cmd1NoTxPoll=
 << 8),
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioaddr + ChipCmd);
> @@ -1434,13 +1559,10 @@ static void rhine_reset_task(struct work_stru=
ct *work)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0reset_task);
> =A0 =A0 =A0 =A0struct net_device *dev =3D rp->dev;
>
> - =A0 =A0 =A0 /* protect against concurrent rx interrupts */
> - =A0 =A0 =A0 disable_irq(rp->pdev->irq);
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
>
> =A0 =A0 =A0 =A0napi_disable(&rp->napi);
>
> - =A0 =A0 =A0 spin_lock_bh(&rp->lock);
> -
> =A0 =A0 =A0 =A0/* clear all descriptors */
> =A0 =A0 =A0 =A0free_tbufs(dev);
> =A0 =A0 =A0 =A0free_rbufs(dev);
> @@ -1451,12 +1573,11 @@ static void rhine_reset_task(struct work_stru=
ct *work)
> =A0 =A0 =A0 =A0rhine_chip_reset(dev);
> =A0 =A0 =A0 =A0init_registers(dev);
>
> - =A0 =A0 =A0 spin_unlock_bh(&rp->lock);
> - =A0 =A0 =A0 enable_irq(rp->pdev->irq);
> -
> =A0 =A0 =A0 =A0dev->trans_start =3D jiffies; /* prevent tx timeout */
> =A0 =A0 =A0 =A0dev->stats.tx_errors++;
> =A0 =A0 =A0 =A0netif_wake_queue(dev);
> +
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
> =A0}
>
> =A0static void rhine_tx_timeout(struct net_device *dev)
> @@ -1477,7 +1598,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buf=
f *skb,
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> =A0 =A0 =A0 =A0unsigned entry;
> - =A0 =A0 =A0 unsigned long flags;
>
> =A0 =A0 =A0 =A0/* Caution: the write order is important here, set the=
 field
> =A0 =A0 =A0 =A0 =A0 with the "ownership" bits last. */
> @@ -1529,7 +1649,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buf=
f *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->tx_ring[entry].tx_status =3D 0;
>
> =A0 =A0 =A0 =A0/* lock eth irq */
> - =A0 =A0 =A0 spin_lock_irqsave(&rp->lock, flags);
> =A0 =A0 =A0 =A0wmb();
> =A0 =A0 =A0 =A0rp->tx_ring[entry].tx_status |=3D cpu_to_le32(DescOwn)=
;
> =A0 =A0 =A0 =A0wmb();
> @@ -1543,15 +1662,12 @@ static netdev_tx_t rhine_start_tx(struct sk_b=
uff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0BYTE_REG_BITS_ON(1 << 7, ioaddr + TQWa=
ke);
>
> =A0 =A0 =A0 =A0/* Wake the potentially-idle transmit channel */
> - =A0 =A0 =A0 iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0ioaddr + ChipCmd1);
> + =A0 =A0 =A0 iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1TxDemand, ioa=
ddr + ChipCmd1);
> =A0 =A0 =A0 =A0IOSYNC;
>
> =A0 =A0 =A0 =A0if (rp->cur_tx =3D=3D rp->dirty_tx + TX_QUEUE_LEN)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_stop_queue(dev);
>
> - =A0 =A0 =A0 spin_unlock_irqrestore(&rp->lock, flags);
> -
> =A0 =A0 =A0 =A0if (debug > 4) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_dbg(dev, "Transmit frame #%d qu=
eued in slot %d\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rp->cur_tx-1, ent=
ry);
> @@ -1565,63 +1681,26 @@ static irqreturn_t rhine_interrupt(int irq, v=
oid *dev_instance)
> =A0{
> =A0 =A0 =A0 =A0struct net_device *dev =3D dev_instance;
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> - =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> - =A0 =A0 =A0 u32 intr_status;
> - =A0 =A0 =A0 int boguscnt =3D max_interrupt_work;
> + =A0 =A0 =A0 u32 status;
> =A0 =A0 =A0 =A0int handled =3D 0;
>
> - =A0 =A0 =A0 while ((intr_status =3D get_intr_status(dev))) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 handled =3D 1;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Acknowledge all of the current inter=
rupt sources ASAP. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intr_status & IntrTxDescRace)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite8(0x08, ioaddr +=
 IntrStatus2);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite16(intr_status & 0xffff, ioaddr =
+ IntrStatus);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 IOSYNC;
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 4)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Interr=
upt, status %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
intr_status);
> -
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intr_status & (IntrRxDone | IntrRxE=
rr | IntrRxDropped |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
IntrRxWakeUp | IntrRxEmpty | IntrRxNoBuf)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite16(IntrTxAborted=
 |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Int=
rTxDone | IntrTxError | IntrTxUnderrun |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 Int=
rPCIErr | IntrStatsMax | IntrLinkChange,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioa=
ddr + IntrEnable);
> + =A0 =A0 =A0 status =3D get_intr_status(dev);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_schedule(&rp->napi=
);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 netif_dbg(rp, intr, dev, "Interrupt, status %08x\n", st=
atus);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intr_status & (IntrTxErrSummary | I=
ntrTxDone)) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intr_status & IntrT=
xErrSummary) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Avoi=
d scavenging before Tx engine turned off */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 RHINE_W=
AIT_FOR(!(ioread8(ioaddr+ChipCmd) & CmdTxOn));
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (deb=
ug > 2 &&
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 ioread8(ioaddr+ChipCmd) & CmdTxOn)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 netdev_warn(dev,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "%s: Tx engine still on\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_tx(dev);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (status & RHINE_EVENT) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 handled =3D 1;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Abnormal error summary/uncommon even=
ts handlers. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (intr_status & (IntrPCIErr | IntrLin=
kChange |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
IntrStatsMax | IntrTxError | IntrTxAborted |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
IntrTxUnderrun | IntrTxDescRace))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_error(dev, intr_s=
tatus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite16(0x0000, rp->base + IntrEnable=
);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 mmiowb();
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 napi_schedule(&rp->napi);
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (--boguscnt < 0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(dev, "Too m=
uch work at interrupt, status=3D%#08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 intr_status);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (status & ~(IntrLinkChange | IntrStatsMax | RHINE_EV=
ENT_NAPI)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_err(rp, intr, dev, "Something Wic=
ked happened! %08x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 status);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (debug > 3)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "exiting interrupt, sta=
tus=3D%08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioread16(ioaddr =
+ IntrStatus));
> =A0 =A0 =A0 =A0return IRQ_RETVAL(handled);
> =A0}
>
> @@ -1632,8 +1711,6 @@ static void rhine_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0int txstatus =3D 0, entry =3D rp->dirty_tx % TX_RING_S=
IZE;
>
> - =A0 =A0 =A0 spin_lock(&rp->lock);
> -
> =A0 =A0 =A0 =A0/* find and cleanup dirty tx descriptors */
> =A0 =A0 =A0 =A0while (rp->dirty_tx !=3D rp->cur_tx) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0txstatus =3D le32_to_cpu(rp->tx_ring[e=
ntry].tx_status);
> @@ -1687,8 +1764,6 @@ static void rhine_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_wake_queue(dev);
> -
> - =A0 =A0 =A0 spin_unlock(&rp->lock);
> =A0}
>
> =A0/**
> @@ -1839,20 +1914,8 @@ static int rhine_rx(struct net_device *dev, in=
t limit)
> =A0 =A0 =A0 =A0return count;
> =A0}
>
> -/*
> - * Clears the "tally counters" for CRC errors and missed frames(?).
> - * It has been reported that some chips need a write of 0 to clear
> - * these, for others the counters are set to 1 when written to and
> - * instead cleared when read. So we clear them both ways ...
> - */
> -static inline void clear_tally_counters(void __iomem *ioaddr)
> +static void rhine_restart_tx(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 iowrite32(0, ioaddr + RxMissed);
> - =A0 =A0 =A0 ioread16(ioaddr + RxCRCErrs);
> - =A0 =A0 =A0 ioread16(ioaddr + RxMissed);
> -}
> -
> -static void rhine_restart_tx(struct net_device *dev) {
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> =A0 =A0 =A0 =A0int entry =3D rp->dirty_tx % TX_RING_SIZE;
> @@ -1880,8 +1943,7 @@ static void rhine_restart_tx(struct net_device =
*dev) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(ioread8(ioaddr + ChipCmd1) | =
Cmd1TxDemand,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioaddr + ChipCmd1);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IOSYNC;
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 else {
> + =A0 =A0 =A0 } else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* This should never happen */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (debug > 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_warn(dev, "%s()=
 Another error occurred %08x\n",
> @@ -1890,72 +1952,46 @@ static void rhine_restart_tx(struct net_devic=
e *dev) {
>
> =A0}
>
> -static void rhine_error(struct net_device *dev, int intr_status)
> +static void rhine_slow_event_task(struct work_struct *work)
> =A0{
> - =A0 =A0 =A0 struct rhine_private *rp =3D netdev_priv(dev);
> + =A0 =A0 =A0 struct rhine_private *rp =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(work, struct rhine_private=
, slow_event_task);
> + =A0 =A0 =A0 struct net_device *dev =3D rp->dev;
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> + =A0 =A0 =A0 u32 intr_status;
>
> - =A0 =A0 =A0 spin_lock(&rp->lock);
> + =A0 =A0 =A0 if (!netif_running(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 return;
> +
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> +
> + =A0 =A0 =A0 intr_status =3D get_intr_status(dev);
> + =A0 =A0 =A0 rhine_ack_event(rp, intr_status & RHINE_EVENT_SLOW);
>
> =A0 =A0 =A0 =A0if (intr_status & IntrLinkChange)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rhine_check_media(dev, 0);
> - =A0 =A0 =A0 if (intr_status & IntrStatsMax) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_crc_errors +=3D ioread16(=
ioaddr + RxCRCErrs);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->stats.rx_missed_errors +=3D ioread=
16(ioaddr + RxMissed);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 clear_tally_counters(ioaddr);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (intr_status & IntrTxAborted) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Abort=
 %08x, frame dropped\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 intr_status);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (intr_status & IntrTxUnderrun) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rp->tx_thresh < 0xE0)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BYTE_REG_BITS_SET((rp->=
tx_thresh +=3D 0x20), 0x80, ioaddr + TxConfig);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Trans=
mitter underrun, Tx threshold now %02x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 rp->tx_thresh);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (intr_status & IntrTxDescRace) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 2)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Tx de=
scriptor write-back race\n");
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if ((intr_status & IntrTxError) &&
> - =A0 =A0 =A0 =A0 =A0 (intr_status & (IntrTxAborted |
> - =A0 =A0 =A0 =A0 =A0 =A0IntrTxUnderrun | IntrTxDescRace)) =3D=3D 0) =
{
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (rp->tx_thresh < 0xE0) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 BYTE_REG_BITS_SET((rp->=
tx_thresh +=3D 0x20), 0x80, ioaddr + TxConfig);
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Unspe=
cified error. Tx threshold now %02x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 rp->tx_thresh);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 if (intr_status & (IntrTxAborted | IntrTxUnderrun | Int=
rTxDescRace |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0IntrTxError))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_restart_tx(dev);
>
> - =A0 =A0 =A0 if (intr_status & ~(IntrLinkChange | IntrStatsMax | Int=
rTxUnderrun |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IntrTxError | I=
ntrTxAborted | IntrNormalSummary |
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 IntrTxDescRace)=
) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "Someth=
ing Wicked happened! %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
intr_status);
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 /* FIXME: ignore ? */
> + =A0 =A0 =A0 if (intr_status & IntrPCIErr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_warn(rp, hw, dev, "PCI error\n");
>
> - =A0 =A0 =A0 spin_unlock(&rp->lock);
> + =A0 =A0 =A0 napi_disable(&rp->napi);
> + =A0 =A0 =A0 iowrite16(0x0000, ioaddr + IntrEnable);
> + =A0 =A0 =A0 mmiowb();
> + =A0 =A0 =A0 /* Slow and safe. Consider __napi_schedule as a replace=
ment ? */
> + =A0 =A0 =A0 napi_enable(&rp->napi);
> + =A0 =A0 =A0 napi_schedule(&rp->napi);
> +
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
> =A0}
>
> =A0static struct net_device_stats *rhine_get_stats(struct net_device =
*dev)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> - =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> - =A0 =A0 =A0 unsigned long flags;
>
> - =A0 =A0 =A0 spin_lock_irqsave(&rp->lock, flags);
> - =A0 =A0 =A0 dev->stats.rx_crc_errors +=3D ioread16(ioaddr + RxCRCEr=
rs);
> - =A0 =A0 =A0 dev->stats.rx_missed_errors +=3D ioread16(ioaddr + RxMi=
ssed);
> - =A0 =A0 =A0 clear_tally_counters(ioaddr);
> - =A0 =A0 =A0 spin_unlock_irqrestore(&rp->lock, flags);
> + =A0 =A0 =A0 spin_lock_bh(&rp->lock);
> + =A0 =A0 =A0 rhine_update_rx_crc_and_missed_errord(rp);
> + =A0 =A0 =A0 spin_unlock_bh(&rp->lock);
>
> =A0 =A0 =A0 =A0return &dev->stats;
> =A0}
> @@ -2022,9 +2058,9 @@ static int netdev_get_settings(struct net_devic=
e *dev, struct ethtool_cmd *cmd)
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0int rc;
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> =A0 =A0 =A0 =A0rc =3D mii_ethtool_gset(&rp->mii_if, cmd);
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
>
> =A0 =A0 =A0 =A0return rc;
> =A0}
> @@ -2034,10 +2070,10 @@ static int netdev_set_settings(struct net_dev=
ice *dev, struct ethtool_cmd *cmd)
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0int rc;
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> =A0 =A0 =A0 =A0rc =3D mii_ethtool_sset(&rp->mii_if, cmd);
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> =A0 =A0 =A0 =A0rhine_set_carrier(&rp->mii_if);
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
>
> =A0 =A0 =A0 =A0return rc;
> =A0}
> @@ -2073,6 +2109,7 @@ static void rhine_get_wol(struct net_device *de=
v, struct ethtool_wolinfo *wol)
> =A0 =A0 =A0 =A0if (!(rp->quirks & rqWOL))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return;
>
> + =A0 =A0 =A0 /* FIXME: huh ? */
> =A0 =A0 =A0 =A0spin_lock_irq(&rp->lock);
> =A0 =A0 =A0 =A0wol->supported =3D WAKE_PHY | WAKE_MAGIC |
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 WAKE_UCAST | WAKE_MCA=
ST | WAKE_BCAST; =A0/* Untested */
> @@ -2092,6 +2129,7 @@ static int rhine_set_wol(struct net_device *dev=
, struct ethtool_wolinfo *wol)
> =A0 =A0 =A0 =A0if (wol->wolopts & ~support)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> + =A0 =A0 =A0 /* FIXME: huh (sic) ? */
> =A0 =A0 =A0 =A0spin_lock_irq(&rp->lock);
> =A0 =A0 =A0 =A0rp->wolopts =3D wol->wolopts;
> =A0 =A0 =A0 =A0spin_unlock_irq(&rp->lock);
> @@ -2119,10 +2157,10 @@ static int netdev_ioctl(struct net_device *de=
v, struct ifreq *rq, int cmd)
> =A0 =A0 =A0 =A0if (!netif_running(dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> =A0 =A0 =A0 =A0rc =3D generic_mii_ioctl(&rp->mii_if, if_mii(rq), cmd,=
 NULL);
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> =A0 =A0 =A0 =A0rhine_set_carrier(&rp->mii_if);
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
>
> =A0 =A0 =A0 =A0return rc;
> =A0}
> @@ -2133,11 +2171,10 @@ static int rhine_close(struct net_device *dev=
)
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
>
> =A0 =A0 =A0 =A0napi_disable(&rp->napi);
> + =A0 =A0 =A0 cancel_work_sync(&rp->slow_event_task);
> =A0 =A0 =A0 =A0cancel_work_sync(&rp->reset_task);
> =A0 =A0 =A0 =A0netif_stop_queue(dev);
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> -
> =A0 =A0 =A0 =A0if (debug > 1)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_dbg(dev, "Shutting down etherca=
rd, status was %04x\n",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioread16(ioaddr +=
 ChipCmd));
> @@ -2151,8 +2188,6 @@ static int rhine_close(struct net_device *dev)
> =A0 =A0 =A0 =A0/* Stop the chip's Tx and Rx processes. */
> =A0 =A0 =A0 =A0iowrite16(CmdStop, ioaddr + ChipCmd);
>
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> -
> =A0 =A0 =A0 =A0free_irq(rp->pdev->irq, dev);
> =A0 =A0 =A0 =A0free_rbufs(dev);
> =A0 =A0 =A0 =A0free_tbufs(dev);
> @@ -2239,10 +2274,12 @@ static int rhine_suspend(struct pci_dev *pdev=
, pm_message_t state)
> =A0 =A0 =A0 =A0netif_device_detach(dev);
> =A0 =A0 =A0 =A0pci_save_state(pdev);
>
> + =A0 =A0 =A0 /* FIXME: ? */
> =A0 =A0 =A0 =A0spin_lock_irqsave(&rp->lock, flags);
> =A0 =A0 =A0 =A0rhine_shutdown(pdev);
> =A0 =A0 =A0 =A0spin_unlock_irqrestore(&rp->lock, flags);
>
> + =A0 =A0 =A0 /* FIXME: nuclear workaround ? Check the commit log. */
> =A0 =A0 =A0 =A0free_irq(dev->irq, dev);
> =A0 =A0 =A0 =A0return 0;
> =A0}
> @@ -2257,6 +2294,7 @@ static int rhine_resume(struct pci_dev *pdev)
> =A0 =A0 =A0 =A0if (!netif_running(dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> + =A0 =A0 =A0 /* FIXME: see above. */
> =A0 =A0 =A0 =A0if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED=
, dev->name, dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netdev_err(dev, "request_irq failed\n"=
);
>
>
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
