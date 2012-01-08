From: Bjarke Istrup Pedersen <gurligebis@gentoo.org>
Subject: Re: [PATCH net-next 0/7] via-rhine NAPI rework and misc.
Date: Sun, 8 Jan 2012 12:57:06 +0100
Message-ID: <CACPM=kUE2zDotO9WvBpCBPCKk5uTgS_fWp4VEjH6dN_gy0t55w@mail.gmail.com>
References: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, rl@hellgate.ch,
	David Miller <davem@davemloft.net>
To: Francois Romieu <romieu@fr.zoreil.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:43437 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab2AHL5I convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 8 Jan 2012 06:57:08 -0500
Received: by iaeh11 with SMTP id h11so5246681iae.19
        for <netdev@vger.kernel.org>; Sun, 08 Jan 2012 03:57:07 -0800 (PST)
In-Reply-To: <20120107224856.GA24928@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2012/1/7 Francois Romieu <romieu@fr.zoreil.com>:
> I have reworked the series since the last submission so as to limit
> unneeded changes before the move of work from IRQ context to NAPI
> and work queue. =A0Those changes were mostly related to debug message=
s.
> They are now done later in the the series. I have included a few
> resume + suspend changes as well. Unbalanced task disabling should
> now be fixed. Newly introduced methods have been set so as to
> limit useless forward declarations.
>
> I am very confident that everything works fine and it is fairly well
> known that my patches always reach perfection, especially on week end
> when I'd better go downtown to avoid the noise of those pesky young
> neighbors. I have however not included Bjarke's Tested-by since the
> content is not strictly identical. I'll gladly do so for #1..#4 if
> everything is ok.

Hey,

It runs great, I've been testing it for the last hour without any
problems, lots of trafic and connections, and the usual messing around
with tools :)
You're welcome to add my as Tested-by if you want.

/Bjarke

> The changes are equally available as :
>
> git://violet.fr.zoreil.com/romieu/linux davem-next.via-rhine
>
> Distance from 'davem-next' (356b95424cfb456e14a59eaa579422ce014c424b)
> ---------------------------------------------------------------------
>
> e92b9b3b091d5fcdaed91d6fa9410deae135704b
> fc3e0f8aec05dd812cba2c1e31c3d1f5fc85e55c
> a384a33bb1c9ec2d99db2046b41f57023fa7d77b
> 7ab87ff4c770eed71e3777936299292739fcd0fe
> a5abec1e84c3d9cd197667e5fa94f25c21a2cb8e
> a20a28bc321fefcc23f8da7ce3722e6ae7a7199d
> 269f3114b53a3ce93eb5977852ac2624a380f600
>
> Diffstat
> --------
>
> =A0drivers/net/ethernet/via/via-rhine.c | =A0668 +++++++++++++++++++-=
--------------
> =A01 files changed, 368 insertions(+), 300 deletions(-)
>
> Shortlog
> --------
>
> Francois Romieu (7):
> =A0 =A0 =A0via-rhine: factor out tx_thresh handling
> =A0 =A0 =A0via-rhine: balance interrupt acknowledge and events retrie=
val.
> =A0 =A0 =A0via-rhine: remove useless forward declarations.
> =A0 =A0 =A0via-rhine: move work from irq handler to softirq and beyon=
d.
> =A0 =A0 =A0via-rhine: RHINE_WAIT_FOR macro removal.
> =A0 =A0 =A0via-rhine: per device debug level.
> =A0 =A0 =A0via-rhine: rework suspend and resume.
>
> Patch
> -----
>
> diff --git a/drivers/net/ethernet/via/via-rhine.c b/drivers/net/ether=
net/via/via-rhine.c
> index 5c4983b..10b18eb 100644
> --- a/drivers/net/ethernet/via/via-rhine.c
> +++ b/drivers/net/ethernet/via/via-rhine.c
> @@ -39,10 +39,9 @@
>
> =A0/* A few user-configurable values.
> =A0 =A0These may be modified when a driver module is loaded. */
> -
> -#define DEBUG
> -static int debug =3D 1; =A0/* 1 normal messages, 0 quiet .. 7 verbos=
e. */
> -static int max_interrupt_work =3D 20;
> +static int debug =3D 0;
> +#define RHINE_MSG_DEFAULT \
> + =A0 =A0 =A0 =A0(0x0000)
>
> =A0/* Set the copy breakpoint for the copy-only-tiny-frames scheme.
> =A0 =A0Setting to > 1518 effectively disables this feature. */
> @@ -128,12 +127,10 @@ MODULE_AUTHOR("Donald Becker <becker@scyld.com>=
");
> =A0MODULE_DESCRIPTION("VIA Rhine PCI Fast Ethernet driver");
> =A0MODULE_LICENSE("GPL");
>
> -module_param(max_interrupt_work, int, 0);
> =A0module_param(debug, int, 0);
> =A0module_param(rx_copybreak, int, 0);
> =A0module_param(avoid_D3, bool, 0);
> -MODULE_PARM_DESC(max_interrupt_work, "VIA Rhine maximum events handl=
ed per interrupt");
> -MODULE_PARM_DESC(debug, "VIA Rhine debug level (0-7)");
> +MODULE_PARM_DESC(debug, "VIA Rhine debug message flags");
> =A0MODULE_PARM_DESC(rx_copybreak, "VIA Rhine copy breakpoint for copy=
-only-tiny-frames");
> =A0MODULE_PARM_DESC(avoid_D3, "Avoid power state D3 (work-around for =
broken BIOSes)");
>
> @@ -351,16 +348,25 @@ static const int mmio_verify_registers[] =3D {
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
> @@ -439,8 +445,13 @@ struct rhine_private {
> =A0 =A0 =A0 =A0struct net_device *dev;
> =A0 =A0 =A0 =A0struct napi_struct napi;
> =A0 =A0 =A0 =A0spinlock_t lock;
> + =A0 =A0 =A0 struct mutex task_lock;
> + =A0 =A0 =A0 bool task_enable;
> + =A0 =A0 =A0 struct work_struct slow_event_task;
> =A0 =A0 =A0 =A0struct work_struct reset_task;
>
> + =A0 =A0 =A0 u32 msg_enable;
> +
> =A0 =A0 =A0 =A0/* Frequently used values: keep some adjacent for cach=
e effect. */
> =A0 =A0 =A0 =A0u32 quirks;
> =A0 =A0 =A0 =A0struct rx_desc *rx_head_desc;
> @@ -476,41 +487,50 @@ static int =A0mdio_read(struct net_device *dev,=
 int phy_id, int location);
> =A0static void mdio_write(struct net_device *dev, int phy_id, int loc=
ation, int value);
> =A0static int =A0rhine_open(struct net_device *dev);
> =A0static void rhine_reset_task(struct work_struct *work);
> +static void rhine_slow_event_task(struct work_struct *work);
> =A0static void rhine_tx_timeout(struct net_device *dev);
> =A0static netdev_tx_t rhine_start_tx(struct sk_buff *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0st=
ruct net_device *dev);
> =A0static irqreturn_t rhine_interrupt(int irq, void *dev_instance);
> =A0static void rhine_tx(struct net_device *dev);
> =A0static int rhine_rx(struct net_device *dev, int limit);
> -static void rhine_error(struct net_device *dev, int intr_status);
> =A0static void rhine_set_rx_mode(struct net_device *dev);
> =A0static struct net_device_stats *rhine_get_stats(struct net_device =
*dev);
> =A0static int netdev_ioctl(struct net_device *dev, struct ifreq *rq, =
int cmd);
> =A0static const struct ethtool_ops netdev_ethtool_ops;
> =A0static int =A0rhine_close(struct net_device *dev);
> -static void rhine_shutdown (struct pci_dev *pdev);
> =A0static int rhine_vlan_rx_add_vid(struct net_device *dev, unsigned =
short vid);
> =A0static int rhine_vlan_rx_kill_vid(struct net_device *dev, unsigned=
 short vid);
> -static void rhine_set_cam(void __iomem *ioaddr, int idx, u8 *addr);
> -static void rhine_set_vlan_cam(void __iomem *ioaddr, int idx, u8 *ad=
dr);
> -static void rhine_set_cam_mask(void __iomem *ioaddr, u32 mask);
> -static void rhine_set_vlan_cam_mask(void __iomem *ioaddr, u32 mask);
> -static void rhine_init_cam_filter(struct net_device *dev);
> -static void rhine_update_vcam(struct net_device *dev);
> -
> -#define RHINE_WAIT_FOR(condition) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0\
> -do { =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 int i =3D 1024; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 while (!(condition) && --i) =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 ; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 if (debug > 1 && i < 512) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("%4d cycles used @ %s:%d\n", =A0=
 =A0 =A0 =A0 =A0 =A0\
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 1024 - i, __func__, __L=
INE__); =A0 =A0 =A0 =A0 =A0\
> -} while (0)
> -
> -static inline u32 get_intr_status(struct net_device *dev)
> +static void rhine_restart_tx(struct net_device *dev);
> +
> +static void rhine_wait_bit(struct rhine_private *rp, u8 reg, u8 mask=
, bool high)
> +{
> + =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> + =A0 =A0 =A0 int i;
> +
> + =A0 =A0 =A0 for (i =3D 0; i < 1024; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (high ^ !!(ioread8(ioaddr + reg) & m=
ask))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 udelay(10);
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (i > 64) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_dbg(rp, hw, rp->dev, "%s bit wait=
 (%02x/%02x) cycle "
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "count: %04d\n", hi=
gh ? "high" : "low", reg, mask, i);
> + =A0 =A0 =A0 }
> +}
> +
> +static void rhine_wait_bit_high(struct rhine_private *rp, u8 reg, u8=
 mask)
> +{
> + =A0 =A0 =A0 rhine_wait_bit(rp, reg, mask, true);
> +}
> +
> +static void rhine_wait_bit_low(struct rhine_private *rp, u8 reg, u8 =
mask)
> +{
> + =A0 =A0 =A0 rhine_wait_bit(rp, reg, mask, false);
> +}
> +
> +static u32 rhine_get_events(struct rhine_private *rp)
> =A0{
> - =A0 =A0 =A0 struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> =A0 =A0 =A0 =A0u32 intr_status;
>
> @@ -521,6 +541,16 @@ static inline u32 get_intr_status(struct net_dev=
ice *dev)
> =A0 =A0 =A0 =A0return intr_status;
> =A0}
>
> +static void rhine_ack_events(struct rhine_private *rp, u32 mask)
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
> @@ -585,6 +615,7 @@ static void rhine_chip_reset(struct net_device *d=
ev)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> + =A0 =A0 =A0 u8 cmd1;
>
> =A0 =A0 =A0 =A0iowrite8(Cmd1Reset, ioaddr + ChipCmd1);
> =A0 =A0 =A0 =A0IOSYNC;
> @@ -597,13 +628,12 @@ static void rhine_chip_reset(struct net_device =
*dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(0x40, ioaddr =
+ MiscCmd);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Reset can take somewhat longer (rar=
e) */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 RHINE_WAIT_FOR(!(ioread8(ioaddr + ChipC=
md1) & Cmd1Reset));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_wait_bit_low(rp, ChipCmd1, Cmd1Re=
set);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Reset %s\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (ioread8(ioaddr=
 + ChipCmd1) & Cmd1Reset) ?
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "failed" : "suc=
ceeded");
> + =A0 =A0 =A0 cmd1 =3D ioread8(ioaddr + ChipCmd1);
> + =A0 =A0 =A0 netif_info(rp, hw, dev, "Reset %s\n", (cmd1 & Cmd1Reset=
) ?
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0"failed" : "succeeded");
> =A0}
>
> =A0#ifdef USE_MMIO
> @@ -629,9 +659,15 @@ static void __devinit rhine_reload_eeprom(long p=
ioaddr, struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> + =A0 =A0 =A0 int i;
>
> =A0 =A0 =A0 =A0outb(0x20, pioaddr + MACRegEEcsr);
> - =A0 =A0 =A0 RHINE_WAIT_FOR(!(inb(pioaddr + MACRegEEcsr) & 0x20));
> + =A0 =A0 =A0 for (i =3D 0; i < 1024; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!(inb(pioaddr + MACRegEEcsr) & 0x20=
))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
> + =A0 =A0 =A0 }
> + =A0 =A0 =A0 if (i > 512)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pr_info("%4d cycles used @ %s:%d\n", i,=
 __func__, __LINE__);
>
> =A0#ifdef USE_MMIO
> =A0 =A0 =A0 =A0/*
> @@ -657,23 +693,127 @@ static void rhine_poll(struct net_device *dev)
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
> + =A0 =A0 =A0 status =3D rhine_get_events(rp);
> + =A0 =A0 =A0 rhine_ack_events(rp, status & ~RHINE_EVENT_SLOW);
> +
> + =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_RX)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 work_done +=3D rhine_rx(dev, budget);
> +
> + =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_TX) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (status & RHINE_EVENT_NAPI_TX_ERR) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Avoid scavenging bef=
ore Tx engine turned off */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_wait_bit_low(rp, =
ChipCmd, CmdTxOn);
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
> @@ -797,6 +937,7 @@ static int __devinit rhine_init_one(struct pci_de=
v *pdev,
> =A0 =A0 =A0 =A0rp->quirks =3D quirks;
> =A0 =A0 =A0 =A0rp->pioaddr =3D pioaddr;
> =A0 =A0 =A0 =A0rp->pdev =3D pdev;
> + =A0 =A0 =A0 rp->msg_enable =3D netif_msg_init(debug, RHINE_MSG_DEFA=
ULT);
>
> =A0 =A0 =A0 =A0rc =3D pci_request_regions(pdev, DRV_NAME);
> =A0 =A0 =A0 =A0if (rc)
> @@ -856,7 +997,9 @@ static int __devinit rhine_init_one(struct pci_de=
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
> @@ -916,8 +1059,8 @@ static int __devinit rhine_init_one(struct pci_d=
ev *pdev,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0rp->mii_if.phy_id =3D phy_id;
> - =A0 =A0 =A0 if (debug > 1 && avoid_D3)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "No D3 power state at =
shutdown\n");
> + =A0 =A0 =A0 if (avoid_D3)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_info(rp, probe, dev, "No D3 power=
 state at shutdown\n");
>
> =A0 =A0 =A0 =A0return 0;
>
> @@ -1093,7 +1236,7 @@ static void rhine_check_media(struct net_device=
 *dev, unsigned int init_media)
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
>
> - =A0 =A0 =A0 mii_check_media(&rp->mii_if, debug, init_media);
> + =A0 =A0 =A0 mii_check_media(&rp->mii_if, netif_msg_link(rp), init_m=
edia);
>
> =A0 =A0 =A0 =A0if (rp->mii_if.full_duplex)
> =A0 =A0 =A0 =A0 =A0 =A0iowrite8(ioread8(ioaddr + ChipCmd1) | Cmd1FDup=
lex,
> @@ -1101,24 +1244,26 @@ static void rhine_check_media(struct net_devi=
ce *dev, unsigned int init_media)
> =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0iowrite8(ioread8(ioaddr + ChipCmd1) & ~Cmd1FDu=
plex,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioaddr + ChipCmd1);
> - =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "force_media %d, carri=
er %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rp->mii_if.forc=
e_media, netif_carrier_ok(dev));
> +
> + =A0 =A0 =A0 netif_info(rp, link, dev, "force_media %d, carrier %d\n=
",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->mii_if.force_media, netif_ca=
rrier_ok(dev));
> =A0}
>
> =A0/* Called after status of force_media possibly changed */
> =A0static void rhine_set_carrier(struct mii_if_info *mii)
> =A0{
> + =A0 =A0 =A0 struct net_device *dev =3D mii->dev;
> + =A0 =A0 =A0 struct rhine_private *rp =3D netdev_priv(dev);
> +
> =A0 =A0 =A0 =A0if (mii->force_media) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* autoneg is off: Link is always assu=
med to be up */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!netif_carrier_ok(mii->dev))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_on(mii->d=
ev);
> - =A0 =A0 =A0 }
> - =A0 =A0 =A0 else =A0 =A0/* Let MMI library update carrier status */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_check_media(mii->dev, 0);
> - =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(mii->dev, "force_media %d, =
carrier %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mii->force_medi=
a, netif_carrier_ok(mii->dev));
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!netif_carrier_ok(dev))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_carrier_on(dev);
> + =A0 =A0 =A0 } else =A0/* Let MMI library update carrier status */
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_check_media(dev, 0);
> +
> + =A0 =A0 =A0 netif_info(rp, link, dev, "force_media %d, carrier %d\n=
",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mii->force_media, netif_carrier_=
ok(dev));
> =A0}
>
> =A0/**
> @@ -1266,10 +1411,10 @@ static int rhine_vlan_rx_add_vid(struct net_d=
evice *dev, unsigned short vid)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> + =A0 =A0 =A0 spin_lock_bh(&rp->lock);
> =A0 =A0 =A0 =A0set_bit(vid, rp->active_vlans);
> =A0 =A0 =A0 =A0rhine_update_vcam(dev);
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> + =A0 =A0 =A0 spin_unlock_bh(&rp->lock);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -1277,10 +1422,10 @@ static int rhine_vlan_rx_kill_vid(struct net_=
device *dev, unsigned short vid)
> =A0{
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> + =A0 =A0 =A0 spin_lock_bh(&rp->lock);
> =A0 =A0 =A0 =A0clear_bit(vid, rp->active_vlans);
> =A0 =A0 =A0 =A0rhine_update_vcam(dev);
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> + =A0 =A0 =A0 spin_unlock_bh(&rp->lock);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> @@ -1310,12 +1455,7 @@ static void init_registers(struct net_device *=
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
> @@ -1323,23 +1463,27 @@ static void init_registers(struct net_device =
*dev)
> =A0}
>
> =A0/* Enable MII link status auto-polling (required for IntrLinkChang=
e) */
> -static void rhine_enable_linkmon(void __iomem *ioaddr)
> +static void rhine_enable_linkmon(struct rhine_private *rp)
> =A0{
> + =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> +
> =A0 =A0 =A0 =A0iowrite8(0, ioaddr + MIICmd);
> =A0 =A0 =A0 =A0iowrite8(MII_BMSR, ioaddr + MIIRegAddr);
> =A0 =A0 =A0 =A0iowrite8(0x80, ioaddr + MIICmd);
>
> - =A0 =A0 =A0 RHINE_WAIT_FOR((ioread8(ioaddr + MIIRegAddr) & 0x20));
> + =A0 =A0 =A0 rhine_wait_bit_high(rp, MIIRegAddr, 0x20);
>
> =A0 =A0 =A0 =A0iowrite8(MII_BMSR | 0x40, ioaddr + MIIRegAddr);
> =A0}
>
> =A0/* Disable MII link status auto-polling (required for MDIO access)=
 */
> -static void rhine_disable_linkmon(void __iomem *ioaddr, u32 quirks)
> +static void rhine_disable_linkmon(struct rhine_private *rp)
> =A0{
> + =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> +
> =A0 =A0 =A0 =A0iowrite8(0, ioaddr + MIICmd);
>
> - =A0 =A0 =A0 if (quirks & rqRhineI) {
> + =A0 =A0 =A0 if (rp->quirks & rqRhineI) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(0x01, ioaddr + MIIRegAddr); =A0=
 =A0// MII_BMSR
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Can be called from ISR. Evil. */
> @@ -1348,13 +1492,13 @@ static void rhine_disable_linkmon(void __iome=
m *ioaddr, u32 quirks)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* 0x80 must be set immediately before=
 turning it off */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(0x80, ioaddr + MIICmd);
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 RHINE_WAIT_FOR(ioread8(ioaddr + MIIRegA=
ddr) & 0x20);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_wait_bit_high(rp, MIIRegAddr, 0x2=
0);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Heh. Now clear 0x80 again. */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(0, ioaddr + MIICmd);
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0else
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 RHINE_WAIT_FOR(ioread8(ioaddr + MIIRegA=
ddr) & 0x80);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_wait_bit_high(rp, MIIRegAddr, 0x8=
0);
> =A0}
>
> =A0/* Read and write over the MII Management Data I/O (MDIO) interfac=
e. */
> @@ -1365,16 +1509,16 @@ static int mdio_read(struct net_device *dev, =
int phy_id, int regnum)
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> =A0 =A0 =A0 =A0int result;
>
> - =A0 =A0 =A0 rhine_disable_linkmon(ioaddr, rp->quirks);
> + =A0 =A0 =A0 rhine_disable_linkmon(rp);
>
> =A0 =A0 =A0 =A0/* rhine_disable_linkmon already cleared MIICmd */
> =A0 =A0 =A0 =A0iowrite8(phy_id, ioaddr + MIIPhyAddr);
> =A0 =A0 =A0 =A0iowrite8(regnum, ioaddr + MIIRegAddr);
> =A0 =A0 =A0 =A0iowrite8(0x40, ioaddr + MIICmd); =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0/* Trigger read */
> - =A0 =A0 =A0 RHINE_WAIT_FOR(!(ioread8(ioaddr + MIICmd) & 0x40));
> + =A0 =A0 =A0 rhine_wait_bit_low(rp, MIICmd, 0x40);
> =A0 =A0 =A0 =A0result =3D ioread16(ioaddr + MIIData);
>
> - =A0 =A0 =A0 rhine_enable_linkmon(ioaddr);
> + =A0 =A0 =A0 rhine_enable_linkmon(rp);
> =A0 =A0 =A0 =A0return result;
> =A0}
>
> @@ -1383,16 +1527,33 @@ static void mdio_write(struct net_device *dev=
, int phy_id, int regnum, int value
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
>
> - =A0 =A0 =A0 rhine_disable_linkmon(ioaddr, rp->quirks);
> + =A0 =A0 =A0 rhine_disable_linkmon(rp);
>
> =A0 =A0 =A0 =A0/* rhine_disable_linkmon already cleared MIICmd */
> =A0 =A0 =A0 =A0iowrite8(phy_id, ioaddr + MIIPhyAddr);
> =A0 =A0 =A0 =A0iowrite8(regnum, ioaddr + MIIRegAddr);
> =A0 =A0 =A0 =A0iowrite16(value, ioaddr + MIIData);
> =A0 =A0 =A0 =A0iowrite8(0x20, ioaddr + MIICmd); =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0/* Trigger write */
> - =A0 =A0 =A0 RHINE_WAIT_FOR(!(ioread8(ioaddr + MIICmd) & 0x20));
> + =A0 =A0 =A0 rhine_wait_bit_low(rp, MIICmd, 0x20);
>
> - =A0 =A0 =A0 rhine_enable_linkmon(ioaddr);
> + =A0 =A0 =A0 rhine_enable_linkmon(rp);
> +}
> +
> +static void rhine_task_disable(struct rhine_private *rp)
> +{
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> + =A0 =A0 =A0 rp->task_enable =3D false;
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
> +
> + =A0 =A0 =A0 cancel_work_sync(&rp->slow_event_task);
> + =A0 =A0 =A0 cancel_work_sync(&rp->reset_task);
> +}
> +
> +static void rhine_task_enable(struct rhine_private *rp)
> +{
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> + =A0 =A0 =A0 rp->task_enable =3D true;
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
> =A0}
>
> =A0static int rhine_open(struct net_device *dev)
> @@ -1406,8 +1567,7 @@ static int rhine_open(struct net_device *dev)
> =A0 =A0 =A0 =A0if (rc)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return rc;
>
> - =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "%s() irq %d\n", __func=
__, rp->pdev->irq);
> + =A0 =A0 =A0 netif_dbg(rp, ifup, dev, "%s() irq %d\n", __func__, rp-=
>pdev->irq);
>
> =A0 =A0 =A0 =A0rc =3D alloc_ring(dev);
> =A0 =A0 =A0 =A0if (rc) {
> @@ -1417,11 +1577,12 @@ static int rhine_open(struct net_device *dev)
> =A0 =A0 =A0 =A0alloc_rbufs(dev);
> =A0 =A0 =A0 =A0alloc_tbufs(dev);
> =A0 =A0 =A0 =A0rhine_chip_reset(dev);
> + =A0 =A0 =A0 rhine_task_enable(rp);
> =A0 =A0 =A0 =A0init_registers(dev);
> - =A0 =A0 =A0 if (debug > 2)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "%s() Done - status %04=
x MII status: %04x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, ioread=
16(ioaddr + ChipCmd),
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0mdio_read(dev, r=
p->mii_if.phy_id, MII_BMSR));
> +
> + =A0 =A0 =A0 netif_dbg(rp, ifup, dev, "%s() Done - status %04x MII s=
tatus: %04x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 __func__, ioread16(ioaddr + ChipCmd=
),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 mdio_read(dev, rp->mii_if.phy_id, M=
II_BMSR));
>
> =A0 =A0 =A0 =A0netif_start_queue(dev);
>
> @@ -1434,11 +1595,12 @@ static void rhine_reset_task(struct work_stru=
ct *work)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0reset_task);
> =A0 =A0 =A0 =A0struct net_device *dev =3D rp->dev;
>
> - =A0 =A0 =A0 /* protect against concurrent rx interrupts */
> - =A0 =A0 =A0 disable_irq(rp->pdev->irq);
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
>
> - =A0 =A0 =A0 napi_disable(&rp->napi);
> + =A0 =A0 =A0 if (!rp->task_enable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
>
> + =A0 =A0 =A0 napi_disable(&rp->napi);
> =A0 =A0 =A0 =A0spin_lock_bh(&rp->lock);
>
> =A0 =A0 =A0 =A0/* clear all descriptors */
> @@ -1452,11 +1614,13 @@ static void rhine_reset_task(struct work_stru=
ct *work)
> =A0 =A0 =A0 =A0init_registers(dev);
>
> =A0 =A0 =A0 =A0spin_unlock_bh(&rp->lock);
> - =A0 =A0 =A0 enable_irq(rp->pdev->irq);
>
> =A0 =A0 =A0 =A0dev->trans_start =3D jiffies; /* prevent tx timeout */
> =A0 =A0 =A0 =A0dev->stats.tx_errors++;
> =A0 =A0 =A0 =A0netif_wake_queue(dev);
> +
> +out_unlock:
> + =A0 =A0 =A0 mutex_unlock(&rp->task_lock);
> =A0}
>
> =A0static void rhine_tx_timeout(struct net_device *dev)
> @@ -1477,7 +1641,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buf=
f *skb,
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> =A0 =A0 =A0 =A0unsigned entry;
> - =A0 =A0 =A0 unsigned long flags;
>
> =A0 =A0 =A0 =A0/* Caution: the write order is important here, set the=
 field
> =A0 =A0 =A0 =A0 =A0 with the "ownership" bits last. */
> @@ -1529,7 +1692,6 @@ static netdev_tx_t rhine_start_tx(struct sk_buf=
f *skb,
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->tx_ring[entry].tx_status =3D 0;
>
> =A0 =A0 =A0 =A0/* lock eth irq */
> - =A0 =A0 =A0 spin_lock_irqsave(&rp->lock, flags);
> =A0 =A0 =A0 =A0wmb();
> =A0 =A0 =A0 =A0rp->tx_ring[entry].tx_status |=3D cpu_to_le32(DescOwn)=
;
> =A0 =A0 =A0 =A0wmb();
> @@ -1550,78 +1712,43 @@ static netdev_tx_t rhine_start_tx(struct sk_b=
uff *skb,
> =A0 =A0 =A0 =A0if (rp->cur_tx =3D=3D rp->dirty_tx + TX_QUEUE_LEN)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_stop_queue(dev);
>
> - =A0 =A0 =A0 spin_unlock_irqrestore(&rp->lock, flags);
> + =A0 =A0 =A0 netif_dbg(rp, tx_queued, dev, "Transmit frame #%d queue=
d in slot %d\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 rp->cur_tx - 1, entry);
>
> - =A0 =A0 =A0 if (debug > 4) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Transmit frame #%d que=
ued in slot %d\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rp->cur_tx-1, en=
try);
> - =A0 =A0 =A0 }
> =A0 =A0 =A0 =A0return NETDEV_TX_OK;
> =A0}
>
> +static void rhine_irq_disable(struct rhine_private *rp)
> +{
> + =A0 =A0 =A0 iowrite16(0x0000, rp->base + IntrEnable);
> + =A0 =A0 =A0 mmiowb();
> +}
> +
> =A0/* The interrupt handler does all of the Rx thread work and cleans=
 up
> =A0 =A0after the Tx thread. */
> =A0static irqreturn_t rhine_interrupt(int irq, void *dev_instance)
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
> + =A0 =A0 =A0 status =3D rhine_get_events(rp);
>
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
> -
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
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 rhine_irq_disable(rp);
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
> @@ -1632,20 +1759,16 @@ static void rhine_tx(struct net_device *dev)
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
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 6)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Tx sca=
venge %d status %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
entry, txstatus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_dbg(rp, tx_done, dev, "Tx scaveng=
e %d status %08x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry, txstatus);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (txstatus & DescOwn)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (txstatus & 0x8000) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_=
dbg(dev, "Transmit error, Tx status %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0txstatus);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_dbg(rp, tx_done, =
dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 "Tr=
ansmit error, Tx status %08x\n", txstatus);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.tx_errors++=
;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (txstatus & 0x0400)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->s=
tats.tx_carrier_errors++;
> @@ -1667,10 +1790,8 @@ static void rhine_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->s=
tats.collisions +=3D (txstatus >> 3) & 0x0F;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0else
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->s=
tats.collisions +=3D txstatus & 0x0F;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 6)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_=
dbg(dev, "collisions: %1.1x:%1.1x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0(txstatus >> 3) & 0xF,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0txstatus & 0xF);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_dbg(rp, tx_done, =
dev, "collisions: %1.1x:%1.1x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 (tx=
status >> 3) & 0xF, txstatus & 0xF);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.tx_bytes +=3D=
 rp->tx_skbuff[entry]->len;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->stats.tx_packets+=
+;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0}
> @@ -1687,8 +1808,6 @@ static void rhine_tx(struct net_device *dev)
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0if ((rp->cur_tx - rp->dirty_tx) < TX_QUEUE_LEN - 4)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0netif_wake_queue(dev);
> -
> - =A0 =A0 =A0 spin_unlock(&rp->lock);
> =A0}
>
> =A0/**
> @@ -1713,11 +1832,8 @@ static int rhine_rx(struct net_device *dev, in=
t limit)
> =A0 =A0 =A0 =A0int count;
> =A0 =A0 =A0 =A0int entry =3D rp->cur_rx % RX_RING_SIZE;
>
> - =A0 =A0 =A0 if (debug > 4) {
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "%s(), entry %d status =
%08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, entry,
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0le32_to_cpu(rp->=
rx_head_desc->rx_status));
> - =A0 =A0 =A0 }
> + =A0 =A0 =A0 netif_dbg(rp, rx_status, dev, "%s(), entry %d status %0=
8x\n", __func__,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 entry, le32_to_cpu(rp->rx_head_desc=
->rx_status));
>
> =A0 =A0 =A0 =A0/* If EOP is set on the next entry, it's a new packet.=
 Send it up. */
> =A0 =A0 =A0 =A0for (count =3D 0; count < limit; ++count) {
> @@ -1729,9 +1845,8 @@ static int rhine_rx(struct net_device *dev, int=
 limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (desc_status & DescOwn)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
>
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 4)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "%s() s=
tatus is %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
__func__, desc_status);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_dbg(rp, rx_status, dev, "%s() sta=
tus %08x\n", __func__,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 desc_status);
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((desc_status & (RxWholePkt | RxErr=
)) !=3D RxWholePkt) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if ((desc_status & RxW=
holePkt) !=3D RxWholePkt) {
> @@ -1747,9 +1862,9 @@ static int rhine_rx(struct net_device *dev, int=
 limit)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->s=
tats.rx_length_errors++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0} else if (desc_status=
 & RxErr) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* The=
re was a error. */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (deb=
ug > 2)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 netdev_dbg(dev, "%s() Rx error was %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0__func__, desc_status);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_d=
bg(rp, rx_err, dev,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 "%s() Rx error %08x\n", __func__,
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 desc_status);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dev->s=
tats.rx_errors++;
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (de=
sc_status & 0x0030)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0dev->stats.rx_length_errors++;
> @@ -1839,19 +1954,6 @@ static int rhine_rx(struct net_device *dev, in=
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
> -{
> - =A0 =A0 =A0 iowrite32(0, ioaddr + RxMissed);
> - =A0 =A0 =A0 ioread16(ioaddr + RxCRCErrs);
> - =A0 =A0 =A0 ioread16(ioaddr + RxMissed);
> -}
> -
> =A0static void rhine_restart_tx(struct net_device *dev) {
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
> @@ -1862,7 +1964,7 @@ static void rhine_restart_tx(struct net_device =
*dev) {
> =A0 =A0 =A0 =A0 * If new errors occurred, we need to sort them out be=
fore doing Tx.
> =A0 =A0 =A0 =A0 * In that case the ISR will be back here RSN anyway.
> =A0 =A0 =A0 =A0 */
> - =A0 =A0 =A0 intr_status =3D get_intr_status(dev);
> + =A0 =A0 =A0 intr_status =3D rhine_get_events(rp);
>
> =A0 =A0 =A0 =A0if ((intr_status & IntrTxErrSummary) =3D=3D 0) {
>
> @@ -1883,79 +1985,50 @@ static void rhine_restart_tx(struct net_devic=
e *dev) {
> =A0 =A0 =A0 =A0}
> =A0 =A0 =A0 =A0else {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* This should never happen */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_warn(dev, "%s() =
Another error occurred %08x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
__func__, intr_status);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_warn(rp, tx_err, dev, "another er=
ror occurred %08x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0intr_status);
> =A0 =A0 =A0 =A0}
>
> =A0}
>
> -static void rhine_error(struct net_device *dev, int intr_status)
> +static void rhine_slow_event_task(struct work_struct *work)
> =A0{
> - =A0 =A0 =A0 struct rhine_private *rp =3D netdev_priv(dev);
> - =A0 =A0 =A0 void __iomem *ioaddr =3D rp->base;
> + =A0 =A0 =A0 struct rhine_private *rp =3D
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 container_of(work, struct rhine_private=
, slow_event_task);
> + =A0 =A0 =A0 struct net_device *dev =3D rp->dev;
> + =A0 =A0 =A0 u32 intr_status;
>
> - =A0 =A0 =A0 spin_lock(&rp->lock);
> + =A0 =A0 =A0 mutex_lock(&rp->task_lock);
> +
> + =A0 =A0 =A0 if (!rp->task_enable)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 goto out_unlock;
> +
> + =A0 =A0 =A0 intr_status =3D rhine_get_events(rp);
> + =A0 =A0 =A0 rhine_ack_events(rp, intr_status & RHINE_EVENT_SLOW);
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
> -
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
>
> - =A0 =A0 =A0 spin_unlock(&rp->lock);
> + =A0 =A0 =A0 if (intr_status & IntrPCIErr)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 netif_warn(rp, hw, dev, "PCI error\n");
> +
> + =A0 =A0 =A0 napi_disable(&rp->napi);
> + =A0 =A0 =A0 rhine_irq_disable(rp);
> + =A0 =A0 =A0 /* Slow and safe. Consider __napi_schedule as a replace=
ment ? */
> + =A0 =A0 =A0 napi_enable(&rp->napi);
> + =A0 =A0 =A0 napi_schedule(&rp->napi);
> +
> +out_unlock:
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
> @@ -2022,9 +2095,9 @@ static int netdev_get_settings(struct net_devic=
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
> @@ -2034,10 +2107,10 @@ static int netdev_set_settings(struct net_dev=
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
> @@ -2058,12 +2131,16 @@ static u32 netdev_get_link(struct net_device =
*dev)
>
> =A0static u32 netdev_get_msglevel(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 return debug;
> + =A0 =A0 =A0 struct rhine_private *rp =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 return rp->msg_enable;
> =A0}
>
> =A0static void netdev_set_msglevel(struct net_device *dev, u32 value)
> =A0{
> - =A0 =A0 =A0 debug =3D value;
> + =A0 =A0 =A0 struct rhine_private *rp =3D netdev_priv(dev);
> +
> + =A0 =A0 =A0 rp->msg_enable =3D value;
> =A0}
>
> =A0static void rhine_get_wol(struct net_device *dev, struct ethtool_w=
olinfo *wol)
> @@ -2119,10 +2196,10 @@ static int netdev_ioctl(struct net_device *de=
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
> @@ -2132,27 +2209,21 @@ static int rhine_close(struct net_device *dev=
)
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0void __iomem *ioaddr =3D rp->base;
>
> + =A0 =A0 =A0 rhine_task_disable(rp);
> =A0 =A0 =A0 =A0napi_disable(&rp->napi);
> - =A0 =A0 =A0 cancel_work_sync(&rp->reset_task);
> =A0 =A0 =A0 =A0netif_stop_queue(dev);
>
> - =A0 =A0 =A0 spin_lock_irq(&rp->lock);
> -
> - =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_dbg(dev, "Shutting down ethercar=
d, status was %04x\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ioread16(ioaddr =
+ ChipCmd));
> + =A0 =A0 =A0 netif_dbg(rp, ifdown, dev, "Shutting down ethercard, st=
atus was %04x\n",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ioread16(ioaddr + ChipCmd));
>
> =A0 =A0 =A0 =A0/* Switch to loopback mode to avoid hardware races. */
> =A0 =A0 =A0 =A0iowrite8(rp->tx_thresh | 0x02, ioaddr + TxConfig);
>
> - =A0 =A0 =A0 /* Disable interrupts by clearing the interrupt mask. *=
/
> - =A0 =A0 =A0 iowrite16(0x0000, ioaddr + IntrEnable);
> + =A0 =A0 =A0 rhine_irq_disable(rp);
>
> =A0 =A0 =A0 =A0/* Stop the chip's Tx and Rx processes. */
> =A0 =A0 =A0 =A0iowrite16(CmdStop, ioaddr + ChipCmd);
>
> - =A0 =A0 =A0 spin_unlock_irq(&rp->lock);
> -
> =A0 =A0 =A0 =A0free_irq(rp->pdev->irq, dev);
> =A0 =A0 =A0 =A0free_rbufs(dev);
> =A0 =A0 =A0 =A0free_tbufs(dev);
> @@ -2192,6 +2263,8 @@ static void rhine_shutdown (struct pci_dev *pde=
v)
> =A0 =A0 =A0 =A0if (rp->quirks & rq6patterns)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(0x04, ioaddr + WOLcgClr);
>
> + =A0 =A0 =A0 spin_lock(&rp->lock);
> +
> =A0 =A0 =A0 =A0if (rp->wolopts & WAKE_MAGIC) {
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(WOLmagic, ioaddr + WOLcrSet);
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/*
> @@ -2216,58 +2289,46 @@ static void rhine_shutdown (struct pci_dev *p=
dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0iowrite8(ioread8(ioaddr + StickyHW) | =
0x04, ioaddr + StickyHW);
> =A0 =A0 =A0 =A0}
>
> - =A0 =A0 =A0 /* Hit power state D3 (sleep) */
> - =A0 =A0 =A0 if (!avoid_D3)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite8(ioread8(ioaddr + StickyHW) | 0=
x03, ioaddr + StickyHW);
> + =A0 =A0 =A0 spin_unlock(&rp->lock);
>
> - =A0 =A0 =A0 /* TODO: Check use of pci_enable_wake() */
> + =A0 =A0 =A0 if (system_state =3D=3D SYSTEM_POWER_OFF && !avoid_D3) =
{
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 iowrite8(ioread8(ioaddr + StickyHW) | 0=
x03, ioaddr + StickyHW);
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_wake_from_d3(pdev, true);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 pci_set_power_state(pdev, PCI_D3hot);
> + =A0 =A0 =A0 }
> =A0}
>
> -#ifdef CONFIG_PM
> -static int rhine_suspend(struct pci_dev *pdev, pm_message_t state)
> +#ifdef CONFIG_PM_SLEEP
> +static int rhine_suspend(struct device *device)
> =A0{
> + =A0 =A0 =A0 struct pci_dev *pdev =3D to_pci_dev(device);
> =A0 =A0 =A0 =A0struct net_device *dev =3D pci_get_drvdata(pdev);
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> - =A0 =A0 =A0 unsigned long flags;
>
> =A0 =A0 =A0 =A0if (!netif_running(dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> + =A0 =A0 =A0 rhine_task_disable(rp);
> + =A0 =A0 =A0 rhine_irq_disable(rp);
> =A0 =A0 =A0 =A0napi_disable(&rp->napi);
>
> =A0 =A0 =A0 =A0netif_device_detach(dev);
> - =A0 =A0 =A0 pci_save_state(pdev);
>
> - =A0 =A0 =A0 spin_lock_irqsave(&rp->lock, flags);
> =A0 =A0 =A0 =A0rhine_shutdown(pdev);
> - =A0 =A0 =A0 spin_unlock_irqrestore(&rp->lock, flags);
>
> - =A0 =A0 =A0 free_irq(dev->irq, dev);
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> -static int rhine_resume(struct pci_dev *pdev)
> +static int rhine_resume(struct device *device)
> =A0{
> + =A0 =A0 =A0 struct pci_dev *pdev =3D to_pci_dev(device);
> =A0 =A0 =A0 =A0struct net_device *dev =3D pci_get_drvdata(pdev);
> =A0 =A0 =A0 =A0struct rhine_private *rp =3D netdev_priv(dev);
> - =A0 =A0 =A0 unsigned long flags;
> - =A0 =A0 =A0 int ret;
>
> =A0 =A0 =A0 =A0if (!netif_running(dev))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return 0;
>
> - =A0 =A0 =A0 if (request_irq(dev->irq, rhine_interrupt, IRQF_SHARED,=
 dev->name, dev))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_err(dev, "request_irq failed\n")=
;
> -
> - =A0 =A0 =A0 ret =3D pci_set_power_state(pdev, PCI_D0);
> - =A0 =A0 =A0 if (debug > 1)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 netdev_info(dev, "Entering power state =
D0 %s (%d)\n",
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 ret ? "failed" =
: "succeeded", ret);
> -
> - =A0 =A0 =A0 pci_restore_state(pdev);
> -
> - =A0 =A0 =A0 spin_lock_irqsave(&rp->lock, flags);
> =A0#ifdef USE_MMIO
> =A0 =A0 =A0 =A0enable_mmio(rp->pioaddr, rp->quirks);
> =A0#endif
> @@ -2276,25 +2337,32 @@ static int rhine_resume(struct pci_dev *pdev)
> =A0 =A0 =A0 =A0free_rbufs(dev);
> =A0 =A0 =A0 =A0alloc_tbufs(dev);
> =A0 =A0 =A0 =A0alloc_rbufs(dev);
> + =A0 =A0 =A0 rhine_task_enable(rp);
> + =A0 =A0 =A0 spin_lock_bh(&rp->lock);
> =A0 =A0 =A0 =A0init_registers(dev);
> - =A0 =A0 =A0 spin_unlock_irqrestore(&rp->lock, flags);
> + =A0 =A0 =A0 spin_unlock_bh(&rp->lock);
>
> =A0 =A0 =A0 =A0netif_device_attach(dev);
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
> -#endif /* CONFIG_PM */
> +
> +static SIMPLE_DEV_PM_OPS(rhine_pm_ops, rhine_suspend, rhine_resume);
> +#define RHINE_PM_OPS =A0 (&rhine_pm_ops)
> +
> +#else
> +
> +#define RHINE_PM_OPS =A0 NULL
> +
> +#endif /* !CONFIG_PM_SLEEP */
>
> =A0static struct pci_driver rhine_driver =3D {
> =A0 =A0 =A0 =A0.name =A0 =A0 =A0 =A0 =A0 =3D DRV_NAME,
> =A0 =A0 =A0 =A0.id_table =A0 =A0 =A0 =3D rhine_pci_tbl,
> =A0 =A0 =A0 =A0.probe =A0 =A0 =A0 =A0 =A0=3D rhine_init_one,
> =A0 =A0 =A0 =A0.remove =A0 =A0 =A0 =A0 =3D __devexit_p(rhine_remove_o=
ne),
> -#ifdef CONFIG_PM
> - =A0 =A0 =A0 .suspend =A0 =A0 =A0 =A0=3D rhine_suspend,
> - =A0 =A0 =A0 .resume =A0 =A0 =A0 =A0 =3D rhine_resume,
> -#endif /* CONFIG_PM */
> - =A0 =A0 =A0 .shutdown =3D =A0 =A0 rhine_shutdown,
> + =A0 =A0 =A0 .shutdown =A0 =A0 =A0 =3D rhine_shutdown,
> + =A0 =A0 =A0 .driver.pm =A0 =A0 =A0=3D RHINE_PM_OPS,
> =A0};
>
> =A0static struct dmi_system_id __initdata rhine_dmi_table[] =3D {
> --
> Ueimor
>
