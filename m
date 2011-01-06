From: Angelo Dureghello <angelo70@gmail.com>
Subject: Re: [RFC v2 PATCH] m68knommu: added dm9000 support
Date: Thu, 06 Jan 2011 13:39:27 +0100
Message-ID: <4D25B7FF.5030204@gmail.com>
References: <4D24B27F.3020104@gmail.com> <AANLkTi=E0hkTUSd-rXWh5tkct0wwYX_75E-oaSWaa2bn@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	m68k@vger.kernel.org
To: Arnaud Lacombe <lacombar@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <AANLkTi=E0hkTUSd-rXWh5tkct0wwYX_75E-oaSWaa2bn@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

thanks for the review, 
- sure, i agree the sw byte swap could be related to a BIG_ENDIAN config option only.
- about HW, can be replaced with something like "dm9000 to cpu bus wiring", i will be more clear in my next patch version.
- i will remove blank lines
- readsX and writesX was completely missing for m68knommu, i have seen that the most appropriate file where to create them was probably "linux/arch/m68k/include/asm/io_no.h" but any comment is appreciated.
- i am adding m68k guys list from now.

thanks
angelo

On 06/01/2011 00:51, Arnaud Lacombe wrote:
> Hi,
> 
> [disclamer: I have no power whatsoever on the dm9k driver, and the
> only dm9000 chip I've access to belongs to hardware whose parent
> company is now defunct.]
> 
> Btw, Linux 68k folks is missing from the CC list.
> 
> On Wed, Jan 5, 2011 at 1:03 PM, Angelo Dureghello <angelo70@gmail.com> wrote:
>> This patch allows to use the dm9000 network chip with a m68knommu
>> big-endian cpu. From the HW point of view,
> what hardware ?
> 
>> the cpu data bus connected to
>> the dm9000 chip should be hardware-byte-swapped, crossing the bytes
>> wires (D0:7 to D24:31, etc.). In anyway, has been also added an option
>> to swap the bytes in the driver, if some cpu has been wired straight
>> D0:D31 to dm9000.
>>
>> Signed-off-by: Angelo Dureghello <angelo70@gmail.com>
>> ---
>>
>> --- linux/drivers/net/Kconfig.orig      2011-01-05 17:11:37.992376124 +0100
>> +++ linux/drivers/net/Kconfig   2011-01-04 22:33:14.132301872 +0100
>> @@ -960,7 +960,7 @@ config TI_DAVINCI_EMAC
>>
>>  config DM9000
>>        tristate "DM9000 support"
>> -       depends on ARM || BLACKFIN || MIPS
>> +       depends on COLDFIRE || ARM || BLACKFIN || MIPS
>>        select CRC32
>>        select MII
>>        ---help---
>> @@ -986,6 +986,14 @@ config DM9000_FORCE_SIMPLE_PHY_POLL
>>          costly MII PHY reads. Note, this will not work if the chip is
>>          operating with an external PHY.
>>
>> +config DM9000_32BIT_SW_SWAP
>> +       bool "Software byte swap for 32 bit data bus"
>> +       depends on DM9000 && COLDFIRE
>> +       ---help---
>> +         This configuration allows to swap data bytes from the dm9000
>> +         driver itself, when the big endian cpu is wired straight to
>> +         the dm9000 32 bit data bus.
>> +
> I'm not sure COLDFIRE is the best dependency. AFAICS, it should
> depends on endianness, and potentially board specific settings.
> 
>>  config ENC28J60
>>        tristate "ENC28J60 support"
>>        depends on EXPERIMENTAL && SPI && NET_ETHERNET
>> @@ -3347,4 +3355,3 @@ config VMXNET3
>>          module will be called vmxnet3.
>>
>>  endif # NETDEVICES
>> -
>>
> useless whitespace change ...
> 
>> --- linux/drivers/net/dm9000.c.orig     2010-12-30 23:19:39.747836070 +0100
>> +++ linux/drivers/net/dm9000.c  2011-01-05 16:30:48.636116500 +0100
>> [...]
>> @@ -981,7 +1032,11 @@ dm9000_rx(struct net_device *dev)
>>                ior(db, DM9000_MRCMDX); /* Dummy read */
>>
>>                /* Get most updated data */
>> -               rxbyte = readb(db->io_data);
>> +#ifdef CONFIG_DM9000_32BIT_SW_SWAP
>> +      rxbyte = (u8)readl(db->io_data);
>> +#else
>> +      rxbyte = readb(db->io_data);
>> +#endif
>>
>>                /* Status check: this byte must be 0 or 1 */
>>                if (rxbyte & DM9000_PKT_ERR) {
>> @@ -996,8 +1051,13 @@ dm9000_rx(struct net_device *dev)
>>
>>                /* A packet ready now  & Get status/length */
>>                GoodPacket = true;
>> -               writeb(DM9000_MRCMD, db->io_addr);
>>
>> +#ifdef CONFIG_DM9000_32BIT_SW_SWAP
>> +               writel(DM9000_MRCMD, db->io_addr);
>> +#else
>> +      writeb(DM9000_MRCMD, db->io_addr);
>> +#endif
>> +
> All these #ifdef make the driver quite horrible to read.
> 
>>                (db->inblk)(db->io_data, &rxhdr, sizeof(rxhdr));
>>
>>                RxLen = le16_to_cpu(rxhdr.RxLen);
>> @@ -1077,7 +1137,7 @@ static irqreturn_t dm9000_interrupt(int
>>        unsigned long flags;
>>        u8 reg_save;
>>
>> -       dm9000_dbg(db, 3, "entering %s\n", __func__);
>> +       //dm9000_dbg(db, 3, "entering %s\n", __func__);
>>
> C++ comment ... Why do you comment this ?
> 
>>        /* Disable all interrupts */
>>        iow(db, DM9000_IMR, IMR_PAR);
>> @@ -1100,7 +1164,7 @@ static irqreturn_t dm9000_interrupt(int
>>        /* Received the coming packet */
>>        if (int_status & ISR_PRS)
>>                dm9000_rx(dev);
>> -
>> +
> whitespace ...
> 
>> @@ -1233,11 +1301,15 @@ dm9000_phy_read(struct net_device *dev,
>>        int ret;
>>
>>        mutex_lock(&db->addr_lock);
>> -
>> +
> whitespace ...
> 
>> @@ -1713,4 +1811,3 @@ MODULE_AUTHOR("Sascha Hauer, Ben Dooks")
>>  MODULE_DESCRIPTION("Davicom DM9000 network driver");
>>  MODULE_LICENSE("GPL");
>>  MODULE_ALIAS("platform:dm9000");
>> -
> whitespace ...
> 
>> --- linux/arch/m68k/include/asm/io_no.h.orig    2011-01-05 16:53:55.904905038 +0100
>> +++ linux/arch/m68k/include/asm/io_no.h 2011-01-04 23:45:08.893049554 +0100
>> @@ -47,6 +47,91 @@ static inline unsigned int _swapl(volati
>>  #define writew(b,addr) (void)((*(volatile unsigned short *) (addr)) = (b))
>>  #define writel(b,addr) (void)((*(volatile unsigned int *) (addr)) = (b))
>>
>> +static inline void writesb (void __iomem *reg, void *data, int count)
>> +{
>> +       unsigned char *p = (unsigned char*) data;
>> +
>> +       while (count--) writeb(*p++, reg);
>> +}
>> +
>> +static inline void writesbsw (void __iomem *reg, void *data, int count)
>> +{
>> +       unsigned char *p = (unsigned char *) data;
>> +
>> +       while (count--) writel((int)(*p++), reg);
>> +}
>> +
>> +static inline void writesw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned short *p = (unsigned short*) data;
>> +
>> +   while (count--) writew(*p++, reg);
>> +}
>> +
>> +static inline void writeswsw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned short *p = (unsigned short *) data;
>> +
>> +   while (count--) writel((int)(_swapw(*p++)), reg);
>> +}
>> +
>> +static inline void writesl (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned long *p = (unsigned long*) data;
>> +
>> +   while (count--) writel(*p++, reg);
>> +}
>> +
>> +static inline void writeslsw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned long *p = (unsigned long *) data;
>> +
>> +   while (count--) writel((int)(_swapl(*p++)), reg);
>> +}
>> +
>> +static inline void readsb (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned char *p = (unsigned char *) data;
>> +
>> +   while (count--) *p++ = readb(reg);
>> +}
>> +
>> +static inline void readsbsw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned char *p = (unsigned char *) data;
>> +
>> +   while (count--) *p++ = (unsigned char)readl(reg);
>> +}
>> +
>> +static inline void readsw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned short *p = (unsigned short *) data;
>> +
>> +   while (count--) *p++ = readb(reg);
>> +}
>> +
>> +static inline void readswsw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned short *p = (unsigned short *) data;
>> +
>> +   while (count--) *p++ = _swapw((unsigned short)readw(reg));
>> +}
>> +
>> +static inline void readsl (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned long *p = (unsigned long *) data;
>> +
>> +   while (count--) *p++ = readb(reg);
>> +}
>> +
>> +static inline void readslsw (void __iomem *reg, void *data, int count)
>> +{
>> +   unsigned long *p = (unsigned long *) data;
>> +
>> +   while (count--) *p++ = _swapl(readl(reg));
>> +}
>> +
>> +
>>  #define __raw_readb readb
>>  #define __raw_readw readw
>>  #define __raw_readl readl
>> @@ -180,4 +265,3 @@ extern void iounmap(void *addr);
>>  #endif /* __KERNEL__ */
>>
>>  #endif /* _M68KNOMMU_IO_H */
> Could not this be moved to a separate patch ? That way arch specific
> changes are separated from the network arch-indep changes.
> 
>  - Arnaud
> 
>> -
>> --
>> To unsubscribe from this list: send the line "unsubscribe linux-kernel" in
>> the body of a message to majordomo@vger.kernel.org
>> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>> Please read the FAQ at  http://www.tux.org/lkml/
>>
