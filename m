From: Grant Likely <grant.likely@secretlab.ca>
Subject: Re: [net-next-2.6 PATCH v2 2/3] fs_enet: Add support for MPC512x to
	fs_enet driver
Date: Wed, 17 Feb 2010 08:11:53 -0700
Message-ID: <fa686aa41002170711we60f1afq5993223c134cbdd8@mail.gmail.com>
References: <1266418530-2727-1-git-send-email-agust@denx.de>
	<1266418530-2727-2-git-send-email-agust@denx.de>
	<1266418530-2727-3-git-send-email-agust@denx.de>
Mime-Version: 1.0
Content-Type: text/plain; charset="iso-8859-1"
Content-Transfer-Encoding: quoted-printable
Cc: Wolfgang Denk <wd@denx.de>, Detlev Zundel <dzu@denx.de>,
	netdev@vger.kernel.org, linuxppc-dev@ozlabs.org,
	"David S. Miller" <davem@davemloft.net>, Piotr Ziecik <kosmo@semihalf.com>
To: Anatolij Gustschin <agust@denx.de>
Return-path: <linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org>
In-Reply-To: <1266418530-2727-3-git-send-email-agust@denx.de>
List-Unsubscribe: <https://lists.ozlabs.org/options/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=unsubscribe>
List-Archive: <http://lists.ozlabs.org/pipermail/linuxppc-dev>
List-Post: <mailto:linuxppc-dev@lists.ozlabs.org>
List-Help: <mailto:linuxppc-dev-request@lists.ozlabs.org?subject=help>
List-Subscribe: <https://lists.ozlabs.org/listinfo/linuxppc-dev>,
	<mailto:linuxppc-dev-request@lists.ozlabs.org?subject=subscribe>
Sender: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
Errors-To: linuxppc-dev-bounces+glppe-linuxppc-embedded-2=m.gmane.org@lists.ozlabs.org
List-Id: netdev.vger.kernel.org

On Wed, Feb 17, 2010 at 7:55 AM, Anatolij Gustschin <agust@denx.de> wrote:
> Extend the fs_enet driver to support MPC512x FEC.
> Enable it with CONFIG_FS_ENET_MPC5121_FEC option.
>
> Signed-off-by: John Rigby <jcrigby@gmail.com>
> Signed-off-by: Piotr Ziecik <kosmo@semihalf.com>
> Signed-off-by: Wolfgang Denk <wd@denx.de>
> Signed-off-by: Anatolij Gustschin <agust@denx.de>

Looks sane to me.

Acked-by: Grant Likely <grant.likely@secretlab.ca>

> ---
> =A0drivers/net/fs_enet/Kconfig =A0 =A0 =A0 =A0| =A0 10 +++++--
> =A0drivers/net/fs_enet/fs_enet-main.c | =A0 =A07 +++++
> =A0drivers/net/fs_enet/fs_enet.h =A0 =A0 =A0| =A0 49 ++++++++++++++++++++=
+++++++++++++++-
> =A0drivers/net/fs_enet/mac-fec.c =A0 =A0 =A0| =A0 46 ++++++++++++++++++++=
++-----------
> =A0drivers/net/fs_enet/mii-fec.c =A0 =A0 =A0| =A0 =A04 +-
> =A05 files changed, 95 insertions(+), 21 deletions(-)
>
> diff --git a/drivers/net/fs_enet/Kconfig b/drivers/net/fs_enet/Kconfig
> index 562ea68..fc073b5 100644
> --- a/drivers/net/fs_enet/Kconfig
> +++ b/drivers/net/fs_enet/Kconfig
> @@ -1,9 +1,13 @@
> =A0config FS_ENET
> =A0 =A0 =A0 =A0tristate "Freescale Ethernet Driver"
> - =A0 =A0 =A0 depends on CPM1 || CPM2
> + =A0 =A0 =A0 depends on CPM1 || CPM2 || PPC_MPC512x
> =A0 =A0 =A0 =A0select MII
> =A0 =A0 =A0 =A0select PHYLIB
>
> +config FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 def_bool y if (FS_ENET && PPC_MPC512x)
> + =A0 =A0 =A0 select FS_ENET_HAS_FEC
> +
> =A0config FS_ENET_HAS_SCC
> =A0 =A0 =A0 =A0bool "Chip has an SCC usable for ethernet"
> =A0 =A0 =A0 =A0depends on FS_ENET && (CPM1 || CPM2)
> @@ -16,13 +20,13 @@ config FS_ENET_HAS_FCC
>
> =A0config FS_ENET_HAS_FEC
> =A0 =A0 =A0 =A0bool "Chip has an FEC usable for ethernet"
> - =A0 =A0 =A0 depends on FS_ENET && CPM1
> + =A0 =A0 =A0 depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
> =A0 =A0 =A0 =A0select FS_ENET_MDIO_FEC
> =A0 =A0 =A0 =A0default y
>
> =A0config FS_ENET_MDIO_FEC
> =A0 =A0 =A0 =A0tristate "MDIO driver for FEC"
> - =A0 =A0 =A0 depends on FS_ENET && CPM1
> + =A0 =A0 =A0 depends on FS_ENET && (CPM1 || FS_ENET_MPC5121_FEC)
>
> =A0config FS_ENET_MDIO_FCC
> =A0 =A0 =A0 =A0tristate "MDIO driver for FCC"
> diff --git a/drivers/net/fs_enet/fs_enet-main.c b/drivers/net/fs_enet/fs_=
enet-main.c
> index c34a7e0..4297021 100644
> --- a/drivers/net/fs_enet/fs_enet-main.c
> +++ b/drivers/net/fs_enet/fs_enet-main.c
> @@ -1094,11 +1094,18 @@ static struct of_device_id fs_enet_match[] =3D {
> =A0 =A0 =A0 =A0},
> =A0#endif
> =A0#ifdef CONFIG_FS_ENET_HAS_FEC
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .compatible =3D "fsl,mpc5121-fec",
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 .data =3D (void *)&fs_fec_ops,
> + =A0 =A0 =A0 },
> +#else
> =A0 =A0 =A0 =A0{
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.compatible =3D "fsl,pq1-fec-enet",
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0.data =3D (void *)&fs_fec_ops,
> =A0 =A0 =A0 =A0},
> =A0#endif
> +#endif
> =A0 =A0 =A0 =A0{}
> =A0};
> =A0MODULE_DEVICE_TABLE(of, fs_enet_match);
> diff --git a/drivers/net/fs_enet/fs_enet.h b/drivers/net/fs_enet/fs_enet.h
> index ef01e09..1ece4b1 100644
> --- a/drivers/net/fs_enet/fs_enet.h
> +++ b/drivers/net/fs_enet/fs_enet.h
> @@ -13,9 +13,56 @@
>
> =A0#ifdef CONFIG_CPM1
> =A0#include <asm/cpm1.h>
> +#endif
> +
> +#if defined(CONFIG_FS_ENET_HAS_FEC)
> +#include <asm/cpm.h>
> +
> +#if defined(CONFIG_FS_ENET_MPC5121_FEC)
> +/* MPC5121 FEC has different register layout */
> +struct fec {
> + =A0 =A0 =A0 u32 fec_reserved0;
> + =A0 =A0 =A0 u32 fec_ievent; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Interrup=
t event reg */
> + =A0 =A0 =A0 u32 fec_imask; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Interr=
upt mask reg */
> + =A0 =A0 =A0 u32 fec_reserved1;
> + =A0 =A0 =A0 u32 fec_r_des_active; =A0 =A0 =A0 =A0 =A0 /* Receive descri=
ptor reg */
> + =A0 =A0 =A0 u32 fec_x_des_active; =A0 =A0 =A0 =A0 =A0 /* Transmit descr=
iptor reg */
> + =A0 =A0 =A0 u32 fec_reserved2[3];
> + =A0 =A0 =A0 u32 fec_ecntrl; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Ethernet=
 control reg */
> + =A0 =A0 =A0 u32 fec_reserved3[6];
> + =A0 =A0 =A0 u32 fec_mii_data; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* MII manage=
 frame reg */
> + =A0 =A0 =A0 u32 fec_mii_speed; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* MII speed =
control reg */
> + =A0 =A0 =A0 u32 fec_reserved4[7];
> + =A0 =A0 =A0 u32 fec_mib_ctrlstat; =A0 =A0 =A0 =A0 =A0 /* MIB control/st=
atus reg */
> + =A0 =A0 =A0 u32 fec_reserved5[7];
> + =A0 =A0 =A0 u32 fec_r_cntrl; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Receive =
control reg */
> + =A0 =A0 =A0 u32 fec_reserved6[15];
> + =A0 =A0 =A0 u32 fec_x_cntrl; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Transmit=
 Control reg */
> + =A0 =A0 =A0 u32 fec_reserved7[7];
> + =A0 =A0 =A0 u32 fec_addr_low; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* Low 32bits=
 MAC address */
> + =A0 =A0 =A0 u32 fec_addr_high; =A0 =A0 =A0 =A0 =A0 =A0 =A0/* High 16bit=
s MAC address */
> + =A0 =A0 =A0 u32 fec_opd; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Opco=
de + Pause duration */
> + =A0 =A0 =A0 u32 fec_reserved8[10];
> + =A0 =A0 =A0 u32 fec_hash_table_high; =A0 =A0 =A0 =A0/* High 32bits hash=
 table */
> + =A0 =A0 =A0 u32 fec_hash_table_low; =A0 =A0 =A0 =A0 /* Low 32bits hash =
table */
> + =A0 =A0 =A0 u32 fec_grp_hash_table_high; =A0 =A0/* High 32bits hash tab=
le */
> + =A0 =A0 =A0 u32 fec_grp_hash_table_low; =A0 =A0 /* Low 32bits hash tabl=
e */
> + =A0 =A0 =A0 u32 fec_reserved9[7];
> + =A0 =A0 =A0 u32 fec_x_wmrk; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* FIFO tra=
nsmit water mark */
> + =A0 =A0 =A0 u32 fec_reserved10;
> + =A0 =A0 =A0 u32 fec_r_bound; =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* FIFO rec=
eive bound reg */
> + =A0 =A0 =A0 u32 fec_r_fstart; =A0 =A0 =A0 =A0 =A0 =A0 =A0 /* FIFO recei=
ve start reg */
> + =A0 =A0 =A0 u32 fec_reserved11[11];
> + =A0 =A0 =A0 u32 fec_r_des_start; =A0 =A0 =A0 =A0 =A0 =A0/* Receive desc=
riptor ring */
> + =A0 =A0 =A0 u32 fec_x_des_start; =A0 =A0 =A0 =A0 =A0 =A0/* Transmit des=
criptor ring */
> + =A0 =A0 =A0 u32 fec_r_buff_size; =A0 =A0 =A0 =A0 =A0 =A0/* Maximum rece=
ive buff size */
> + =A0 =A0 =A0 u32 fec_reserved12[26];
> + =A0 =A0 =A0 u32 fec_dma_control; =A0 =A0 =A0 =A0 =A0 =A0/* DMA Endian a=
nd other ctrl */
> +};
> +#endif
>
> =A0struct fec_info {
> - =A0 =A0 =A0 fec_t __iomem *fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp;
> =A0 =A0 =A0 =A0u32 mii_speed;
> =A0};
> =A0#endif
> diff --git a/drivers/net/fs_enet/mac-fec.c b/drivers/net/fs_enet/mac-fec.c
> index 7047813..c9657da 100644
> --- a/drivers/net/fs_enet/mac-fec.c
> +++ b/drivers/net/fs_enet/mac-fec.c
> @@ -80,7 +80,7 @@
> =A0*/
> =A0#define FEC_RESET_DELAY =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A050
>
> -static int whack_reset(fec_t __iomem *fecp)
> +static int whack_reset(struct fec __iomem *fecp)
> =A0{
> =A0 =A0 =A0 =A0int i;
>
> @@ -168,7 +168,7 @@ static void cleanup_data(struct net_device *dev)
> =A0static void set_promiscuous_mode(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FS(fecp, r_cntrl, FEC_RCNTRL_PROM);
> =A0}
> @@ -216,7 +216,7 @@ static void set_multicast_one(struct net_device *dev,=
 const u8 *mac)
> =A0static void set_multicast_finish(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0/* if all multi or too many multicasts; just enable all */
> =A0 =A0 =A0 =A0if ((dev->flags & IFF_ALLMULTI) !=3D 0 ||
> @@ -246,7 +246,7 @@ static void set_multicast_list(struct net_device *dev)
> =A0static void restart(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
> =A0 =A0 =A0 =A0const struct fs_platform_info *fpi =3D fep->fpi;
> =A0 =A0 =A0 =A0dma_addr_t rx_bd_base_phys, tx_bd_base_phys;
> =A0 =A0 =A0 =A0int r;
> @@ -280,7 +280,11 @@ static void restart(struct net_device *dev)
> =A0 =A0 =A0 =A0 * Set maximum receive buffer size.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0FW(fecp, r_buff_size, PKT_MAXBLR_SIZE);
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 FW(fecp, r_cntrl, PKT_MAXBUF_SIZE << 16);
> +#else
> =A0 =A0 =A0 =A0FW(fecp, r_hash, PKT_MAXBUF_SIZE);
> +#endif
>
> =A0 =A0 =A0 =A0/* get physical address */
> =A0 =A0 =A0 =A0rx_bd_base_phys =3D fep->ring_mem_addr;
> @@ -297,7 +301,11 @@ static void restart(struct net_device *dev)
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Enable big endian and don't care about SDMA FC.
> =A0 =A0 =A0 =A0 */
> +#ifdef CONFIG_FS_ENET_MPC5121_FEC
> + =A0 =A0 =A0 FS(fecp, dma_control, 0xC0000000);
> +#else
> =A0 =A0 =A0 =A0FW(fecp, fun_code, 0x78000000);
> +#endif
>
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * Set MII speed.
> @@ -308,9 +316,17 @@ static void restart(struct net_device *dev)
> =A0 =A0 =A0 =A0 * Clear any outstanding interrupt.
> =A0 =A0 =A0 =A0 */
> =A0 =A0 =A0 =A0FW(fecp, ievent, 0xffc0);
> +#ifndef CONFIG_FS_ENET_MPC5121_FEC
> =A0 =A0 =A0 =A0FW(fecp, ivec, (virq_to_hw(fep->interrupt) / 2) << 29);
>
> =A0 =A0 =A0 =A0FW(fecp, r_cntrl, FEC_RCNTRL_MII_MODE); /* MII enable */
> +#else
> + =A0 =A0 =A0 /*
> + =A0 =A0 =A0 =A0* Only set MII mode - do not touch maximum frame length
> + =A0 =A0 =A0 =A0* configured before.
> + =A0 =A0 =A0 =A0*/
> + =A0 =A0 =A0 FS(fecp, r_cntrl, FEC_RCNTRL_MII_MODE);
> +#endif
> =A0 =A0 =A0 =A0/*
> =A0 =A0 =A0 =A0 * adjust to duplex mode
> =A0 =A0 =A0 =A0 */
> @@ -339,7 +355,7 @@ static void stop(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> =A0 =A0 =A0 =A0const struct fs_platform_info *fpi =3D fep->fpi;
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0struct fec_info* feci=3D fep->phydev->bus->priv;
>
> @@ -375,7 +391,7 @@ static void stop(struct net_device *dev)
> =A0static void napi_clear_rx_event(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FW(fecp, ievent, FEC_NAPI_RX_EVENT_MSK);
> =A0}
> @@ -383,7 +399,7 @@ static void napi_clear_rx_event(struct net_device *de=
v)
> =A0static void napi_enable_rx(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FS(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
> =A0}
> @@ -391,7 +407,7 @@ static void napi_enable_rx(struct net_device *dev)
> =A0static void napi_disable_rx(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FC(fecp, imask, FEC_NAPI_RX_EVENT_MSK);
> =A0}
> @@ -399,7 +415,7 @@ static void napi_disable_rx(struct net_device *dev)
> =A0static void rx_bd_done(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FW(fecp, r_des_active, 0x01000000);
> =A0}
> @@ -407,7 +423,7 @@ static void rx_bd_done(struct net_device *dev)
> =A0static void tx_kickstart(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FW(fecp, x_des_active, 0x01000000);
> =A0}
> @@ -415,7 +431,7 @@ static void tx_kickstart(struct net_device *dev)
> =A0static u32 get_int_events(struct net_device *dev)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0return FR(fecp, ievent) & FR(fecp, imask);
> =A0}
> @@ -423,7 +439,7 @@ static u32 get_int_events(struct net_device *dev)
> =A0static void clear_int_events(struct net_device *dev, u32 int_events)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fep->fec.fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fep->fec.fecp;
>
> =A0 =A0 =A0 =A0FW(fecp, ievent, int_events);
> =A0}
> @@ -439,17 +455,17 @@ static int get_regs(struct net_device *dev, void *p=
, int *sizep)
> =A0{
> =A0 =A0 =A0 =A0struct fs_enet_private *fep =3D netdev_priv(dev);
>
> - =A0 =A0 =A0 if (*sizep < sizeof(fec_t))
> + =A0 =A0 =A0 if (*sizep < sizeof(struct fec))
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0return -EINVAL;
>
> - =A0 =A0 =A0 memcpy_fromio(p, fep->fec.fecp, sizeof(fec_t));
> + =A0 =A0 =A0 memcpy_fromio(p, fep->fec.fecp, sizeof(struct fec));
>
> =A0 =A0 =A0 =A0return 0;
> =A0}
>
> =A0static int get_regs_len(struct net_device *dev)
> =A0{
> - =A0 =A0 =A0 return sizeof(fec_t);
> + =A0 =A0 =A0 return sizeof(struct fec);
> =A0}
>
> =A0static void tx_restart(struct net_device *dev)
> diff --git a/drivers/net/fs_enet/mii-fec.c b/drivers/net/fs_enet/mii-fec.c
> index 96eba42..5944b65 100644
> --- a/drivers/net/fs_enet/mii-fec.c
> +++ b/drivers/net/fs_enet/mii-fec.c
> @@ -52,7 +52,7 @@
> =A0static int fs_enet_fec_mii_read(struct mii_bus *bus , int phy_id, int =
location)
> =A0{
> =A0 =A0 =A0 =A0struct fec_info* fec =3D bus->priv;
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fec->fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fec->fecp;
> =A0 =A0 =A0 =A0int i, ret =3D -1;
>
> =A0 =A0 =A0 =A0BUG_ON((in_be32(&fecp->fec_r_cntrl) & FEC_RCNTRL_MII_MODE)=
 =3D=3D 0);
> @@ -75,7 +75,7 @@ static int fs_enet_fec_mii_read(struct mii_bus *bus , i=
nt phy_id, int location)
> =A0static int fs_enet_fec_mii_write(struct mii_bus *bus, int phy_id, int =
location, u16 val)
> =A0{
> =A0 =A0 =A0 =A0struct fec_info* fec =3D bus->priv;
> - =A0 =A0 =A0 fec_t __iomem *fecp =3D fec->fecp;
> + =A0 =A0 =A0 struct fec __iomem *fecp =3D fec->fecp;
> =A0 =A0 =A0 =A0int i;
>
> =A0 =A0 =A0 =A0/* this must never happen */
> --
> 1.6.3.3
>
>



-- =

Grant Likely, B.Sc., P.Eng.
Secret Lab Technologies Ltd.
