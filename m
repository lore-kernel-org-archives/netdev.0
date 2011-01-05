From: Arnaud Lacombe <lacombar@gmail.com>
Subject: Re: [RFC v2 PATCH] m68knommu: added dm9000 support
Date: Wed, 5 Jan 2011 18:51:44 -0500
Message-ID: <AANLkTi=E0hkTUSd-rXWh5tkct0wwYX_75E-oaSWaa2bn@mail.gmail.com>
References: <4D24B27F.3020104@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	Randy Dunlap <randy.dunlap@oracle.com>
To: Angelo Dureghello <angelo70@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:34432 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753569Ab1AEXvp convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Jan 2011 18:51:45 -0500
In-Reply-To: <4D24B27F.3020104@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

[disclamer: I have no power whatsoever on the dm9k driver, and the
only dm9000 chip I've access to belongs to hardware whose parent
company is now defunct.]

Btw, Linux 68k folks is missing from the CC list.

On Wed, Jan 5, 2011 at 1:03 PM, Angelo Dureghello <angelo70@gmail.com> =
wrote:
> This patch allows to use the dm9000 network chip with a m68knommu
> big-endian cpu. From the HW point of view,
what hardware ?

> the cpu data bus connected to
> the dm9000 chip should be hardware-byte-swapped, crossing the bytes
> wires (D0:7 to D24:31, etc.). In anyway, has been also added an optio=
n
> to swap the bytes in the driver, if some cpu has been wired straight
> D0:D31 to dm9000.
>
> Signed-off-by: Angelo Dureghello <angelo70@gmail.com>
> ---
>
> --- linux/drivers/net/Kconfig.orig =A0 =A0 =A02011-01-05 17:11:37.992=
376124 +0100
> +++ linux/drivers/net/Kconfig =A0 2011-01-04 22:33:14.132301872 +0100
> @@ -960,7 +960,7 @@ config TI_DAVINCI_EMAC
>
> =A0config DM9000
> =A0 =A0 =A0 =A0tristate "DM9000 support"
> - =A0 =A0 =A0 depends on ARM || BLACKFIN || MIPS
> + =A0 =A0 =A0 depends on COLDFIRE || ARM || BLACKFIN || MIPS
> =A0 =A0 =A0 =A0select CRC32
> =A0 =A0 =A0 =A0select MII
> =A0 =A0 =A0 =A0---help---
> @@ -986,6 +986,14 @@ config DM9000_FORCE_SIMPLE_PHY_POLL
> =A0 =A0 =A0 =A0 =A0costly MII PHY reads. Note, this will not work if =
the chip is
> =A0 =A0 =A0 =A0 =A0operating with an external PHY.
>
> +config DM9000_32BIT_SW_SWAP
> + =A0 =A0 =A0 bool "Software byte swap for 32 bit data bus"
> + =A0 =A0 =A0 depends on DM9000 && COLDFIRE
> + =A0 =A0 =A0 ---help---
> + =A0 =A0 =A0 =A0 This configuration allows to swap data bytes from t=
he dm9000
> + =A0 =A0 =A0 =A0 driver itself, when the big endian cpu is wired str=
aight to
> + =A0 =A0 =A0 =A0 the dm9000 32 bit data bus.
> +
I'm not sure COLDFIRE is the best dependency. AFAICS, it should
depends on endianness, and potentially board specific settings.

> =A0config ENC28J60
> =A0 =A0 =A0 =A0tristate "ENC28J60 support"
> =A0 =A0 =A0 =A0depends on EXPERIMENTAL && SPI && NET_ETHERNET
> @@ -3347,4 +3355,3 @@ config VMXNET3
> =A0 =A0 =A0 =A0 =A0module will be called vmxnet3.
>
> =A0endif # NETDEVICES
> -
>
useless whitespace change ...

> --- linux/drivers/net/dm9000.c.orig =A0 =A0 2010-12-30 23:19:39.74783=
6070 +0100
> +++ linux/drivers/net/dm9000.c =A02011-01-05 16:30:48.636116500 +0100
> [...]
> @@ -981,7 +1032,11 @@ dm9000_rx(struct net_device *dev)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0ior(db, DM9000_MRCMDX); /* Dummy read =
*/
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Get most updated data */
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 rxbyte =3D readb(db->io_data);
> +#ifdef CONFIG_DM9000_32BIT_SW_SWAP
> + =A0 =A0 =A0rxbyte =3D (u8)readl(db->io_data);
> +#else
> + =A0 =A0 =A0rxbyte =3D readb(db->io_data);
> +#endif
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* Status check: this byte must be 0 o=
r 1 */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0if (rxbyte & DM9000_PKT_ERR) {
> @@ -996,8 +1051,13 @@ dm9000_rx(struct net_device *dev)
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0/* A packet ready now =A0& Get status/=
length */
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0GoodPacket =3D true;
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 writeb(DM9000_MRCMD, db->io_addr);
>
> +#ifdef CONFIG_DM9000_32BIT_SW_SWAP
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 writel(DM9000_MRCMD, db->io_addr);
> +#else
> + =A0 =A0 =A0writeb(DM9000_MRCMD, db->io_addr);
> +#endif
> +
All these #ifdef make the driver quite horrible to read.

> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0(db->inblk)(db->io_data, &rxhdr, sizeo=
f(rxhdr));
>
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0RxLen =3D le16_to_cpu(rxhdr.RxLen);
> @@ -1077,7 +1137,7 @@ static irqreturn_t dm9000_interrupt(int
> =A0 =A0 =A0 =A0unsigned long flags;
> =A0 =A0 =A0 =A0u8 reg_save;
>
> - =A0 =A0 =A0 dm9000_dbg(db, 3, "entering %s\n", __func__);
> + =A0 =A0 =A0 //dm9000_dbg(db, 3, "entering %s\n", __func__);
>
C++ comment ... Why do you comment this ?

> =A0 =A0 =A0 =A0/* Disable all interrupts */
> =A0 =A0 =A0 =A0iow(db, DM9000_IMR, IMR_PAR);
> @@ -1100,7 +1164,7 @@ static irqreturn_t dm9000_interrupt(int
> =A0 =A0 =A0 =A0/* Received the coming packet */
> =A0 =A0 =A0 =A0if (int_status & ISR_PRS)
> =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0dm9000_rx(dev);
> -
> +
whitespace ...

> @@ -1233,11 +1301,15 @@ dm9000_phy_read(struct net_device *dev,
> =A0 =A0 =A0 =A0int ret;
>
> =A0 =A0 =A0 =A0mutex_lock(&db->addr_lock);
> -
> +
whitespace ...

> @@ -1713,4 +1811,3 @@ MODULE_AUTHOR("Sascha Hauer, Ben Dooks")
> =A0MODULE_DESCRIPTION("Davicom DM9000 network driver");
> =A0MODULE_LICENSE("GPL");
> =A0MODULE_ALIAS("platform:dm9000");
> -
whitespace ...

> --- linux/arch/m68k/include/asm/io_no.h.orig =A0 =A02011-01-05 16:53:=
55.904905038 +0100
> +++ linux/arch/m68k/include/asm/io_no.h 2011-01-04 23:45:08.893049554=
 +0100
> @@ -47,6 +47,91 @@ static inline unsigned int _swapl(volati
> =A0#define writew(b,addr) (void)((*(volatile unsigned short *) (addr)=
) =3D (b))
> =A0#define writel(b,addr) (void)((*(volatile unsigned int *) (addr)) =
=3D (b))
>
> +static inline void writesb (void __iomem *reg, void *data, int count=
)
> +{
> + =A0 =A0 =A0 unsigned char *p =3D (unsigned char*) data;
> +
> + =A0 =A0 =A0 while (count--) writeb(*p++, reg);
> +}
> +
> +static inline void writesbsw (void __iomem *reg, void *data, int cou=
nt)
> +{
> + =A0 =A0 =A0 unsigned char *p =3D (unsigned char *) data;
> +
> + =A0 =A0 =A0 while (count--) writel((int)(*p++), reg);
> +}
> +
> +static inline void writesw (void __iomem *reg, void *data, int count=
)
> +{
> + =A0 unsigned short *p =3D (unsigned short*) data;
> +
> + =A0 while (count--) writew(*p++, reg);
> +}
> +
> +static inline void writeswsw (void __iomem *reg, void *data, int cou=
nt)
> +{
> + =A0 unsigned short *p =3D (unsigned short *) data;
> +
> + =A0 while (count--) writel((int)(_swapw(*p++)), reg);
> +}
> +
> +static inline void writesl (void __iomem *reg, void *data, int count=
)
> +{
> + =A0 unsigned long *p =3D (unsigned long*) data;
> +
> + =A0 while (count--) writel(*p++, reg);
> +}
> +
> +static inline void writeslsw (void __iomem *reg, void *data, int cou=
nt)
> +{
> + =A0 unsigned long *p =3D (unsigned long *) data;
> +
> + =A0 while (count--) writel((int)(_swapl(*p++)), reg);
> +}
> +
> +static inline void readsb (void __iomem *reg, void *data, int count)
> +{
> + =A0 unsigned char *p =3D (unsigned char *) data;
> +
> + =A0 while (count--) *p++ =3D readb(reg);
> +}
> +
> +static inline void readsbsw (void __iomem *reg, void *data, int coun=
t)
> +{
> + =A0 unsigned char *p =3D (unsigned char *) data;
> +
> + =A0 while (count--) *p++ =3D (unsigned char)readl(reg);
> +}
> +
> +static inline void readsw (void __iomem *reg, void *data, int count)
> +{
> + =A0 unsigned short *p =3D (unsigned short *) data;
> +
> + =A0 while (count--) *p++ =3D readb(reg);
> +}
> +
> +static inline void readswsw (void __iomem *reg, void *data, int coun=
t)
> +{
> + =A0 unsigned short *p =3D (unsigned short *) data;
> +
> + =A0 while (count--) *p++ =3D _swapw((unsigned short)readw(reg));
> +}
> +
> +static inline void readsl (void __iomem *reg, void *data, int count)
> +{
> + =A0 unsigned long *p =3D (unsigned long *) data;
> +
> + =A0 while (count--) *p++ =3D readb(reg);
> +}
> +
> +static inline void readslsw (void __iomem *reg, void *data, int coun=
t)
> +{
> + =A0 unsigned long *p =3D (unsigned long *) data;
> +
> + =A0 while (count--) *p++ =3D _swapl(readl(reg));
> +}
> +
> +
> =A0#define __raw_readb readb
> =A0#define __raw_readw readw
> =A0#define __raw_readl readl
> @@ -180,4 +265,3 @@ extern void iounmap(void *addr);
> =A0#endif /* __KERNEL__ */
>
> =A0#endif /* _M68KNOMMU_IO_H */
Could not this be moved to a separate patch ? That way arch specific
changes are separated from the network arch-indep changes.

 - Arnaud

> -
> --
> To unsubscribe from this list: send the line "unsubscribe linux-kerne=
l" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at =A0http://vger.kernel.org/majordomo-info.html
> Please read the FAQ at =A0http://www.tux.org/lkml/
>
