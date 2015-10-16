From: Joe Perches <joe@perches.com>
Subject: Re: [PATCH] net: hix5hd2_gmac: avoid integer overload warning
Date: Fri, 16 Oct 2015 14:22:15 -0700
Message-ID: <1445030535.22921.73.camel@perches.com>
References: <1444967657-107994-1-git-send-email-huangdaode@hisilicon.com>
	 <4752736.dePgPCNd9q@wuerfel>
	 <063D6719AE5E284EB5DD2968C1650D6D1CBB97A6@AcuExch.aculab.com>
	 <9667302.4m5v3ViVSt@wuerfel> <1445018654.22921.41.camel@perches.com>
	 <562146ED.1030308@cogentembedded.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="ISO-8859-1"
Content-Transfer-Encoding: 7bit
Cc: Arnd Bergmann <arnd@arndb.de>,
	David Laight <David.Laight@aculab.com>,
	huangdaode <huangdaode@hisilicon.com>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"liguozhu@hisilicon.com" <liguozhu@hisilicon.com>,
	"Yisen.Zhuang@huawei.com" <Yisen.Zhuang@huawei.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"linuxarm@huawei.com" <linuxarm@huawei.com>,
	"salil.mehta@huawei.com" <salil.mehta@huawei.com>,
	"kenneth-lee-2012@foxmail.com" <kenneth-lee-2012@foxmail.com>,
	"xuwei5@hisilicon.com" <xuwei5@hisilicon.com>,
	"lisheng011@huawei.com" <lisheng011@huawei.com>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"lipeng321@huawei.com" <lipeng321@huawei.com>
To: Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <562146ED.1030308@cogentembedded.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-10-16 at 21:50 +0300, Sergei Shtylyov wrote:
> On 10/16/2015 09:04 PM, Joe Perches wrote:
> 
> >>>> BITS_RX_EN is an 'unsigned long' constant, so the ones complement of that
> >>>> has bits set that do not fit into a 32-bit variable on 64-bit architectures,
> >>>> which causes a harmless gcc warning:
> >>> ...
> >>>>   static void hix5hd2_port_disable(struct hix5hd2_priv *priv)
> >>>>   {
> >>>> -     writel_relaxed(~(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
> >>>> +     writel_relaxed(~(u32)(BITS_RX_EN | BITS_TX_EN), priv->base + PORT_EN);
> >>>>        writel_relaxed(0, priv->base + DESC_WR_RD_ENA);
> >>>
> >>> ISTM that just means that the constants shouldn't be 'long'.
> >>
> >> Right, but that would probably mean changing the BIT() macro or not using it
> >> here. In the past I've argued against using that macro, but I've given
> >> up that fight.
> >
> > Fight on... (Somebody must have gone to USC here)
> >
> > There might be value in aefin BIT_U32 macro.
> > Maybe BIT_U64 too.
> 
>     There's BIT_ULL() already.

I know, but symmetry is good.
I think there'd be no harm in adding it.
Perhaps adding all the sized variants would be useful.

Something like:

#define BIT_OF_TYPE(type, nr)						\
({									\
	typeof(type) rtn;						\
	BUILD_BUG_ON(__builtin_constant_p(nr) &&			\
		     ((nr) < 0 ||					\
		      (nr) >= sizeof(type) * BITS_PER_BYTE));		\
	rtn = ((type)1) << (nr);					\
	rtn;								\
})

#define BIT_U8(nr)	BIT_OF_TYPE(u8, nr)
#define BIT_U16(nr)	BIT_OF_TYPE(u16, nr)
#define BIT_U32(nr)	BIT_OF_TYPE(u32, nr)
#define BIT_U64(nr)	BIT_OF_TYPE(u64, nr)
