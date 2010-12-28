From: Akinobu Mita <akinobu.mita@gmail.com>
Subject: Re: [PATCH net-2.6] starfire: Replace broken preprocessor test for
 dma_addr_t size
Date: Tue, 28 Dec 2010 14:27:44 +0900
Message-ID: <AANLkTinx-n045io5bPT-u_7T5cEiu6+74p30=94vkhPU@mail.gmail.com>
References: <1293509989.2928.99.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Ion Badulescu <ionut@badula.org>,
	netdev <netdev@vger.kernel.org>, fujita.tomonori@lab.ntt.co.jp
To: Ben Hutchings <ben@decadent.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qw0-f46.google.com ([209.85.216.46]:64855 "EHLO
	mail-qw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750757Ab0L1F1q convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 28 Dec 2010 00:27:46 -0500
Received: by qwa26 with SMTP id 26so9015896qwa.19
        for <netdev@vger.kernel.org>; Mon, 27 Dec 2010 21:27:45 -0800 (PST)
In-Reply-To: <1293509989.2928.99.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

2010/12/28 Ben Hutchings <ben@decadent.org.uk>:
> Commit 56543af "starfire: use BUILD_BUG_ON for netdrv_addr_t" reveale=
d
> that the preprocessor condition used to find the size of dma_addr_t
> yielded the wrong result for some architectures and configurations.
> This was kluged for 64-bit PowerPC in commit 3e502e6 by adding yet
> another case to the condition. =A0However, some MIPS configurations a=
re
> still handled incorrectly.
>
> Replace the preprocessor test with expressions using ?: or
> __builtin_choose_expr() as necessary.

I remember ARCH_DMA_ADDR_T_64BIT was introduced to handle this kind of
test easily.

So please use CONFIG_ARCH_DMA_ADDR_T_64BIT for this test.
You may also need to set ARCH_DMA_ADDR_T_64BIT for the MIPS
architecture correctly.

> Signed-off-by: Ben Hutchings <ben@decadent.org.uk>
> ---
> This is compile-tested only.
>
> The build failure on MIPS can be seen at
> <https://buildd.debian.org/fetch.cgi?pkg=3Dlinux-2.6;ver=3D2.6.37~rc7=
-1~experimental.1;arch=3Dmips;stamp=3D1293414847>.
>
> Ben.
>
> =A0drivers/net/starfire.c | =A0 59 +++++++++++++++++++---------------=
-------------
> =A01 files changed, 24 insertions(+), 35 deletions(-)
>
> diff --git a/drivers/net/starfire.c b/drivers/net/starfire.c
> index 4adf124..ea789d6 100644
> --- a/drivers/net/starfire.c
> +++ b/drivers/net/starfire.c
> @@ -144,31 +144,22 @@ static int full_duplex[MAX_UNITS] =3D {0, };
> =A0/* Time in jiffies before concluding the transmitter is hung. */
> =A0#define TX_TIMEOUT =A0 =A0 (2 * HZ)
>
> -/*
> - * This SUCKS.
> - * We need a much better method to determine if dma_addr_t is 64-bit=
=2E
> - */
> -#if (defined(__i386__) && defined(CONFIG_HIGHMEM64G)) || defined(__x=
86_64__) || defined (__ia64__) || defined(__alpha__) || defined(__mips6=
4__) || (defined(__mips__) && defined(CONFIG_HIGHMEM) && defined(CONFIG=
_64BIT_PHYS_ADDR)) || (defined(__powerpc64__) || defined(CONFIG_PHYS_64=
BIT))
> -/* 64-bit dma_addr_t */
> -#define ADDR_64BITS =A0 =A0/* This chip uses 64 bit addresses. */
> -#define netdrv_addr_t __le64
> -#define cpu_to_dma(x) cpu_to_le64(x)
> -#define dma_to_cpu(x) le64_to_cpu(x)
> -#define RX_DESC_Q_ADDR_SIZE RxDescQAddr64bit
> -#define TX_DESC_Q_ADDR_SIZE TxDescQAddr64bit
> -#define RX_COMPL_Q_ADDR_SIZE RxComplQAddr64bit
> -#define TX_COMPL_Q_ADDR_SIZE TxComplQAddr64bit
> -#define RX_DESC_ADDR_SIZE RxDescAddr64bit
> -#else =A0/* 32-bit dma_addr_t */
> -#define netdrv_addr_t __le32
> -#define cpu_to_dma(x) cpu_to_le32(x)
> -#define dma_to_cpu(x) le32_to_cpu(x)
> -#define RX_DESC_Q_ADDR_SIZE RxDescQAddr32bit
> -#define TX_DESC_Q_ADDR_SIZE TxDescQAddr32bit
> -#define RX_COMPL_Q_ADDR_SIZE RxComplQAddr32bit
> -#define TX_COMPL_Q_ADDR_SIZE TxComplQAddr32bit
> -#define RX_DESC_ADDR_SIZE RxDescAddr32bit
> -#endif
> +#define IS_ADDR_64BIT (sizeof(dma_addr_t) =3D=3D 8)
> +#define cpu_to_dma(x) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 __builtin_choose_expr(IS_ADDR_64BIT, cpu_to_le64(x), cp=
u_to_le32(x))
> +#define dma_to_cpu(x) =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 __builtin_choose_expr(IS_ADDR_64BIT, le64_to_cpu(x), le=
32_to_cpu(x))
> +typedef typeof(cpu_to_dma(0)) netdrv_addr_t;
> +#define RX_DESC_Q_ADDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 (IS_ADDR_64BIT ? RxDescQAddr64bit : RxDescQAddr32bit)
> +#define TX_DESC_Q_ADDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =
=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 (IS_ADDR_64BIT ? TxDescQAddr64bit : TxDescQAddr32bit)
> +#define RX_COMPL_Q_ADDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 (IS_ADDR_64BIT ? RxComplQAddr64bit : RxComplQAddr32bit)
> +#define TX_COMPL_Q_ADDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 \
> + =A0 =A0 =A0 (IS_ADDR_64BIT ? TxComplQAddr64bit : TxComplQAddr32bit)
> +#define RX_DESC_ADDR_SIZE =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0\
> + =A0 =A0 =A0 (IS_ADDR_64BIT ? RxDescAddr64bit : RxDescAddr32bit)
>
> =A0#define skb_first_frag_len(skb) =A0 =A0 =A0 =A0skb_headlen(skb)
> =A0#define skb_num_frags(skb) (skb_shinfo(skb)->nr_frags + 1)
> @@ -512,13 +503,12 @@ struct starfire_tx_desc_2 {
> =A0 =A0 =A0 =A0__le64 addr;
> =A0};
>
> -#ifdef ADDR_64BITS
> -typedef struct starfire_tx_desc_2 starfire_tx_desc;
> -#define TX_DESC_TYPE TxDescType2
> -#else =A0/* not ADDR_64BITS */
> -typedef struct starfire_tx_desc_1 starfire_tx_desc;
> -#define TX_DESC_TYPE TxDescType1
> -#endif /* not ADDR_64BITS */
> +extern struct starfire_tx_desc_1 starfire_tx_desc_1_dummy(void);
> +extern struct starfire_tx_desc_2 starfire_tx_desc_2_dummy(void);
> +typedef typeof(__builtin_choose_expr(IS_ADDR_64BIT, starfire_tx_desc=
_2_dummy(),
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0=
 =A0starfire_tx_desc_1_dummy()))
> +starfire_tx_desc;
> +#define TX_DESC_TYPE (IS_ADDR_64BIT ? TxDescType2 : TxDescType1)
> =A0#define TX_DESC_SPACING TxDescSpaceUnlim
>
> =A0enum tx_desc_bits {
> @@ -731,9 +721,8 @@ static int __devinit starfire_init_one(struct pci=
_dev *pdev,
> =A0#ifdef VLAN_SUPPORT
> =A0 =A0 =A0 =A0dev->features |=3D NETIF_F_HW_VLAN_RX | NETIF_F_HW_VLA=
N_FILTER;
> =A0#endif /* VLAN_RX_KILL_VID */
> -#ifdef ADDR_64BITS
> - =A0 =A0 =A0 dev->features |=3D NETIF_F_HIGHDMA;
> -#endif /* ADDR_64BITS */
> + =A0 =A0 =A0 if (IS_ADDR_64BIT)
> + =A0 =A0 =A0 =A0 =A0 =A0 =A0 dev->features |=3D NETIF_F_HIGHDMA;
>
> =A0 =A0 =A0 =A0/* Serial EEPROM reads are hidden by the hardware. */
> =A0 =A0 =A0 =A0for (i =3D 0; i < 6; i++)
> --
> 1.7.2.3
>
>
>
