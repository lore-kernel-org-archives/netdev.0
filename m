From: Robert Hancock <hancockrwd@gmail.com>
Subject: Re: [RFC PATCH] fix problems with NETIF_F_HIGHDMA in networking
	drivers
Date: Sat, 27 Feb 2010 11:59:47 -0600
Message-ID: <51f3faa71002270959o4d1435e3xf67185fccaf50b18@mail.gmail.com>
References: <51f3faa71002260646r705891e8tdbab1f6faeeb4b81@mail.gmail.com>
	 <201002261625.24523.bzolnier@gmail.com>
	 <51f3faa71002261908y7cfa62eeicb3e56d5c920887a@mail.gmail.com>
	 <20100227.015350.71138134.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bzolnier@gmail.com, linux-kernel@vger.kernel.org,
	netdev@vger.kernel.org, linux-usb@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20100227.015350.71138134.davem@davemloft.net>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, Feb 27, 2010 at 3:53 AM, David Miller <davem@davemloft.net> wro=
te:
> From: Robert Hancock <hancockrwd@gmail.com>
> Date: Fri, 26 Feb 2010 21:08:04 -0600
>
>> That seems like a reasonable approach to me. Only question is how to
>> implement the check for DMA_64BIT. Can we just check page_to_phys on
>> each of the pages in the skb to see if it's > 0xffffffff ? Are there
>> any architectures where it's more complicated than that?
>
> On almost every platform it's "more complicated than that".
>
> This is the whole issue. =A0What matters is the final DMA address and
> since we have IOMMUs and the like, it is absolutely not tenable to
> solve this by checking physical address attributes.

Yeah, physical address isn't quite right. There is a precedent for
such a check in the block layer though - look at
blk_queue_bounce_limit in block/blk-settings.c:

void blk_queue_bounce_limit(struct request_queue *q, u64 dma_mask)
{
        unsigned long b_pfn =3D dma_mask >> PAGE_SHIFT;
        int dma =3D 0;

        q->bounce_gfp =3D GFP_NOIO;
#if BITS_PER_LONG =3D=3D 64
        /*
         * Assume anything <=3D 4GB can be handled by IOMMU.  Actually
         * some IOMMUs can handle everything, but I don't know of a
         * way to test this here.
         */
        if (b_pfn < (min_t(u64, 0xffffffffUL, BLK_BOUNCE_HIGH) >> PAGE_=
SHIFT))
                dma =3D 1;
        q->limits.bounce_pfn =3D max_low_pfn;
#else
        if (b_pfn < blk_max_low_pfn)
                dma =3D 1;
        q->limits.bounce_pfn =3D b_pfn;
#endif
        if (dma) {
                init_emergency_isa_pool();
                q->bounce_gfp =3D GFP_NOIO | GFP_DMA;
                q->limits.bounce_pfn =3D b_pfn;
        }
}

and then in mm/bounce.c:

static void __blk_queue_bounce(struct request_queue *q, struct bio **bi=
o_orig,
                               mempool_t *pool)
{
        struct page *page;
        struct bio *bio =3D NULL;
        int i, rw =3D bio_data_dir(*bio_orig);
        struct bio_vec *to, *from;

        bio_for_each_segment(from, *bio_orig, i) {
                page =3D from->bv_page;

                /*
                 * is destination page below bounce pfn?
                 */
                if (page_to_pfn(page) <=3D queue_bounce_pfn(q))
                        continue;

=46ollowing that logic then, it appears that page_to_pfn(page) >
(0xffffffff >> PAGE_SHIFT) should tell us what we want to know for the
DMA_64BIT flag.. or am I missing something?
