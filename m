From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [PATCH RFC] fix problems with NETIF_F_HIGHDMA in networking
	drivers v2
Date: Thu, 25 Mar 2010 19:03:37 -0600
Message-ID: <51f3faa71003251803q7ccec5d5x82bc277c590e2848@mail.gmail.com>
References: <4B8F213B.40603@gmail.com>
	 <20100304135738C.fujita.tomonori@lab.ntt.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	linux-usb@vger.kernel.org, davem@davemloft.net, bzolnier@gmail.com
To: FUJITA Tomonori <fujita.tomonori@lab.ntt.co.jp>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100304135738C.fujita.tomonori@lab.ntt.co.jp>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wed, Mar 3, 2010 at 10:58 PM, FUJITA Tomonori
<fujita.tomonori@lab.ntt.co.jp> wrote:
> On Wed, 03 Mar 2010 20:55:55 -0600
> Robert Hancock <hancockrwd@gmail.com> wrote:
>
>> Many networking drivers have issues with the use of the NETIF_F_HIGH=
DMA flag.
>> This flag actually indicates whether or not the device/driver can ha=
ndle
>> skbs located in high memory (as opposed to lowmem). If the flag isn'=
t set and
>> the skb is located in highmem, it needs to be copied.
>> There are two problems with this flag:
>>
>> -Many drivers only set the flag when they detect they can use 64-bit=
 DMA,
>> since otherwise they could receive DMA addresses that they can't han=
dle
>> (which on platforms without IOMMU/SWIOTLB support is fatal). This me=
ans that if
>> 64-bit support isn't available, even buffers located below 4GB will =
get copied
>> unnecessarily.
>>
>> -Some drivers set the flag even though they can't actually handle 64=
-bit DMA,
>> which would mean that on platforms without IOMMU/SWIOTLB they would =
get a DMA
>> mapping error if the memory they received happened to be located abo=
ve 4GB.
>>
>> In order to fix this problem, the existing NETIF_F_HIGHDMA flag is s=
plit into
>> two new flags:
>>
>> NETIF_F_DMA_HIGH - indicates if the driver can do DMA to highmem at =
all
>> NETIF_F_DMA_64BIT - indicates the driver can do DMA to 64-bit memory
>
> Why can't you use dev->dma_mask here like the following?
>
> Then you can fix drivers that use the NETIF_F_HIGHDMA flag to indicat=
e
> that they don't support 64bit DMA.
>
> diff --git a/net/core/dev.c b/net/core/dev.c
> index bcc490c..b15f94b 100644
> --- a/net/core/dev.c
> +++ b/net/core/dev.c
> @@ -129,6 +129,7 @@
> =A0#include <linux/jhash.h>
> =A0#include <linux/random.h>
> =A0#include <trace/events/napi.h>
> +#include <linux/pci.h>
>
> =A0#include "net-sysfs.h"
>
> @@ -1787,14 +1788,21 @@ static inline int illegal_highdma(struct net_=
device *dev, struct sk_buff *skb)
> =A0{
> =A0#ifdef CONFIG_HIGHMEM
> =A0 =A0 =A0 =A0int i;
> + =A0 =A0 =A0 if (!(dev->features & NETIF_F_HIGHDMA)) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < skb_shinfo(skb)->nr_f=
rags; i++)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageHighMem(skb_shi=
nfo(skb)->frags[i].page))
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
1;
> + =A0 =A0 =A0 }
>
> - =A0 =A0 =A0 if (dev->features & NETIF_F_HIGHDMA)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 0;
> -
> - =A0 =A0 =A0 for (i =3D 0; i < skb_shinfo(skb)->nr_frags; i++)
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (PageHighMem(skb_shinfo(skb)->frags[=
i].page))
> - =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return 1;
> + =A0 =A0 =A0 if (PCI_DMA_BUS_IS_PHYS) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 struct device *pdev =3D dev->dev.parent=
;
>
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 for (i =3D 0; i < skb_shinfo(skb)->nr_f=
rags; i++) {
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 dma_addr_t addr =3D pag=
e_to_phys(skb_shinfo(skb)->frags[i].page);
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 if (!pdev->dma_mask || =
addr + PAGE_SIZE - 1 > *pdev->dma_mask)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 return =
1;
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 }
> + =A0 =A0 =A0 }
> =A0#endif
> =A0 =A0 =A0 =A0return 0;
> =A0}
>

This seems like it could be a reasonable approach. The only thing is
that in this code you're returning 1 if the parent device has no DMA
mask set. Wouldn't it make more sense to return 0 in this case? I'm
assuming that in that situation it's a virtual device not backed by
any hardware and there should be no DMA mask restriction...
