From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: NETIF_F_HIGHDMA misuse in networking drivers?
Date: Mon, 22 Feb 2010 18:28:15 -0600
Message-ID: <51f3faa71002221628n120070e1ic66f094a229df72a@mail.gmail.com>
References: <4B8029FA.2000404@gmail.com>
	 <20100222.155357.235673585.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100222.155357.235673585.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 22, 2010 at 5:53 PM, David Miller <davem@davemloft.net> wro=
te:
> From: Robert Hancock <hancockrwd@gmail.com>
> Date: Sat, 20 Feb 2010 12:29:14 -0600
>
>> Was just part of a discussion in another thread talking about 64-bit
>> DMA support issues where NETIF_F_HIGHDMA came up. I was originally
>> under the impression that this flag indicated the device supported
>> 64-bit DMA addressing. However, from looking at the code that checks
>> for it (and, well, the actual comment for the flag) it really means
>> "can access highmem" which has nothing to do with 64-bit at all. And
>> if there's no highmem (like on x86_64) it has no effect at all.
>
> I think it's trying to do two things, and doing only one of them
> well :-)
>
> It's trying to keep drivers from receiving highmem pages if they are
> not able to access them properly. =A0F.e. imagine a driver that copie=
s
> data out of the packet assuming that page_address() is always valid o=
n
> the SKB pages.

Yeah, it appears this is the only reason not to set the HIGHDMA flag.
Of course, given that relatively few drivers should need to do this (I
would think only emulated/virtual adapters, or really old/crappy
hardware with no bus-master support) ideally it would be better if
only those drivers needed to do something special (i.e. a NOHIGHDMA
flag or something) rather than making all the normal ones do it..

>
> It's also trying to use this to prevent physical addresses beyond 4GB
> from reaching the driver, which as you note is not implemented
> precisely here.

If by "precisely" you mean "at all, on many architectures".. on a
non-highmem arch, setting or not setting HIGHDMA has no effect on
anything, including whether >4GB addresses will be received by the
driver or not. Only the device DMA mask (presumably) does. Therefore,
conditionally setting HIGHDMA based on what DMA mask the driver has
been able to set is almost certainly a bug.

>
> Without knowing something about how the driver "DMAs" packet data we
> can't really do an accurate test here. =A0Maybe the driver directly D=
MAs
> using physical addressing (an ASIC inside of a CPU, for example,
> drivers/net/niu.c has a case of this).
>
> Maybe the platform uses an IOMMU with 32-bit virtual addressing, so
> any physical address is fine even if the card only supports 32-bit
> addressing (basically any PCI coard on sparc64 is an example of this)=
=2E
>
> And finally maybe the card supports 64-bit DMA addressing so anything
> works on any platform.

The DMA mask facility already should address all of these cases
AFAICS, so there should be no need for any extra handling here..

>
> How to test all of these possible cases precisely that at this spot i=
n
> the transmit path is the question at hand. =A0To be honest I consider
> the current hack "good enough" :-)

Well, as I see it there are two big problems with the current state:

-As there are a lot of bad examples in the tree of this flag being set
based on irrelevant criteria, such mistakes will propagate to new
drivers in cargo-cult fashion. (Looking at some of the existing
examples, it seems like has already occurred for a lot of them.)

-Failing to set the HIGHDMA flag when it should be is likely to impact
performance on highmem architectures by causing unnecessary packet
copying, and potentially using up more precious low memory.
