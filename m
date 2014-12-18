From: Ezequiel Garcia <ezequiel.garcia@free-electrons.com>
Subject: Re: Bug: mv643xxx fails with highmem
Date: Thu, 18 Dec 2014 10:13:19 -0300
Message-ID: <5492D2EF.6050807@free-electrons.com>
References: <20141211194920.GR11285@n2100.arm.linux.org.uk> <20141211.151055.817876561546126576.davem@davemloft.net> <20141211202507.GS11285@n2100.arm.linux.org.uk> <5491F342.5090301@free-electrons.com> <20141218000357.GX11285@n2100.arm.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Nimrod Andy <B38611@freescale.com>,
	Fabio Estevam <fabio.estevam@freescale.com>,
	netdev@vger.kernel.org, fugang.duan@freescale.com
To: Russell King - ARM Linux <linux@arm.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from down.free-electrons.com ([37.187.137.238]:46727 "EHLO
	mail.free-electrons.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1750981AbaLRNPO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Dec 2014 08:15:14 -0500
In-Reply-To: <20141218000357.GX11285@n2100.arm.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 12/17/2014 09:03 PM, Russell King - ARM Linux wrote:
> On Wed, Dec 17, 2014 at 06:18:58PM -0300, Ezequiel Garcia wrote:
>> On the other side, I haven't been able to reproduce this on my board=
s. I
>> did try to put a hack to hold most lowmem pages, but it didn't make =
a
>> difference. (In fact, I haven't been able to clearly see how the pag=
es
>> for the skbuff are allocated from high memory.)
>=20
> To be honest, I don't know either.  All that I can do is describe wha=
t
> happened...
>=20
> I've been running 3.17 since a week after it came out, and never saw =
a
> problem there.
>=20
> Then I moved forward to 3.18, and ended up with memory corruption, wh=
ich
> seemed to be the GPU scribbling over kernel text (since the oops reve=
aled
> pixel values in the Code: line.)
>=20
> I thought it was a GPU problem - which seemed a reasonable assumption=
 as
> I know that the runtime PM I implemented for the GPU doesn't properly
> restore the hardware state yet.  So, I rebooted back into 3.18, this
> time with all GPU users disabled, intending to download a kernel with
> GPU runtime PM disabled.  I'd also added additional debug to my X DDX
> driver which logged the GPU command stream to a file on a NFS mount -
> this does open(, O_CREAT|O_WRONLY|O_APPEND), write(), close() each
> time it submits a block of commands.
>=20
> However, while my scripts to download the built kernel to the Cubox
> were running, the kernel oopsed in the depths of dma_map_single() - t=
he
> kernel was trying to access a struct page for phys address 0x40000000=
,
> which didn't exist.  I decided to go back to 3.17 to get the updated
> kernel on it, hoping that would sort it out.
>=20
> With the updated 3.18 kernel (with GPU runtime PM disabled), I found
> that I'd still get oopses in from the network driver while X was star=
ting
> up, again from dma_map_single().  So, with all GPU users again disabl=
ed,
> I set about debugging the this issue.
>=20
> I added a BUG_ON(!addr) after the page_address(), and that fired.  I
> added a BUG_ON(PageHighMem(this_frag->page.p)) and that fired too.
> (Each time, I had to boot back to 3.17 in order to download the new
> kernel, because very time I tried with 3.18, I'd hit this bug.)
>=20
> It's then when I reported the issue and asked the questions...
>=20
> I've since done a simple change, taking advantage that on ARM (or any
> asm-generic/dma-mapping-common.h user), dma_unmap_single() and
> dma_unmap_page() are the same function:
>=20
> diff --git a/drivers/net/ethernet/marvell/mv643xx_eth.c b/drivers/net=
/ethernet/marvell/mv643xx_eth.c
> index d44560d1d268..c343ab03ab8b 100644
> --- a/drivers/net/ethernet/marvell/mv643xx_eth.c
> +++ b/drivers/net/ethernet/marvell/mv643xx_eth.c
> @@ -879,10 +879,8 @@ static void txq_submit_frag_skb(struct tx_queue =
*txq, struct sk_buff *skb)
>                 skb_frag_t *this_frag;
>                 int tx_index;
>                 struct tx_desc *desc;
> -               void *addr;
>=20
>                 this_frag =3D &skb_shinfo(skb)->frags[frag];
> -               addr =3D page_address(this_frag->page.p) + this_frag-=
>page_offset;                tx_index =3D txq->tx_curr_desc++;
>                 if (txq->tx_curr_desc =3D=3D txq->tx_ring_size)
>                         txq->tx_curr_desc =3D 0;
> @@ -902,8 +900,9 @@ static void txq_submit_frag_skb(struct tx_queue *=
txq, struct sk_buff *skb)
>=20
>                 desc->l4i_chk =3D 0;
>                 desc->byte_cnt =3D skb_frag_size(this_frag);
> -               desc->buf_ptr =3D dma_map_single(mp->dev->dev.parent,=
 addr,
> -                                              desc->byte_cnt, DMA_TO=
_DEVICE);
> +               desc->buf_ptr =3D skb_frag_dma_map(mp->dev->dev.paren=
t,
> +                                                this_frag, 0,
> +                                                desc->byte_cnt, DMA_=
TO_DEVICE);        }
>  }
>=20
>=20
> I've been running that for the last five days, and I've yet to see
> /any/ issues what so ever, and that includes running with the GPU
> logging all that time:
>=20
> -rw-r--r-- 1 root root 17113616 Dec 17 23:52 /shared/etnaviv.bin
>=20
> During that time, I've been using the device over the network, runnin=
g
> various git commands, running builds, running the occasional build
> via NFS, etc.
>=20
> So, for me it was trivially easy to reproduce (without my fix in plac=
e)
> and all problems have gone away when I've fixed the apparent problem.
>=20

Well that's interesting. You've fixed only the non-TSO egress path,
yet your original ethtool output showed tcp-segmentation-offload enable=
d.

This seems to imply the highmem pages are found only for the non-TSO pa=
th.

> However, exactly how it occurs, I don't know.  My understanding from
> reading the various feature flags was that NETIF_F_HIGHDMA was requir=
ed
> for highmem (see illegal_highdma()) so as this isn't set, we shouldn'=
t
> be seeing highmem fragments - which is why I asked the question in my
> original email.
>=20
> If you want me to revert my fix above, and reproduce again, I can
> certainly try that - or put a WARN_ON_ONCE(PageHighMem(this_frag->pag=
e.p))
> in there, but I seem to remember that it wasn't particularly useful a=
s
> the backtrace didn't show where the memory actually came from.
>=20

No, that's OK. Thanks a lot for all the details. I'll try to come up wi=
th a
fix soon.
--=20
Ezequiel Garc=EDa, Free Electrons
Embedded Linux, Kernel and Android Engineering
http://free-electrons.com
