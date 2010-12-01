From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Wed, 1 Dec 2010 15:44:57 -0500
Message-ID: <20101201204457.GA8393@hmsreliant.think-freely.org>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
 <1291126341.2904.82.camel@edumazet-laptop>
 <20101130143720.GA6017@hmsreliant.think-freely.org>
 <AANLkTim7SSRMkhc_eMz+Bk12kAwfG==j-dH4NOPu-uS2@mail.gmail.com>
 <1291210691.2856.740.camel@edumazet-laptop>
 <AANLkTinViD=WpwUFUDF6mKbc-Cap_Tg=SXwOjVQ=5u4B@mail.gmail.com>
 <1291216396.2856.861.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Changli Gao <xiaosuo@gmail.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:53811 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1755654Ab0LAUpG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 15:45:06 -0500
Content-Disposition: inline
In-Reply-To: <1291216396.2856.861.camel@edumazet-laptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Dec 01, 2010 at 04:13:16PM +0100, Eric Dumazet wrote:
> Le mercredi 01 d=E9cembre 2010 =E0 22:16 +0800, Changli Gao a =E9crit=
 :
>=20
> > Even then, tpacket_fill_skb() is called for every skb, and
> > pgv_to_page() is used in it. We have to optimize pgv_to_page().
>=20
> With the __pure trick I gave, pgv_to_page() is _not_ called for the
> typical use case of af_packet : packet sniffing.
>=20
> Compiler is able to remove the call completely, since
>=20
> static inline void flush_dcache_page(struct page *page) { }
>=20
> The only remaining pgv_to_page() call is the one done in mmap packet
> send, since we have to do :
>=20
> page =3D pgv_to_page(data);
> get_page(page);
>=20
> I personally dont use this path, its known to be buggy...
>=20
> Optimize if you want, but make all this
> ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE conditional.
>=20
> Its not needed to maintain an array of 'struct page *' if its not nee=
ded
> at all.
>=20
+1 to this approach, its much cleaner than maintaing an array of struct=
 pages to
do fast mappings.  I just spent a few hours putting a test patch togeth=
er to do
such a mapping, and it requires either doing a lengthly search of the r=
ing
buffer, or passing around the struct pgv that the potentially vmalloced=
 address
came from, which fans out quite alot and gets tricky in several places =
(the tx
paths skb desctructor for instance).  At any rate, letting the compiler
eliminate code using __pure here seems much more efficient
Neil

> # vi +2448 block/blk-core.c
>=20
> #if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
> /**
>  * rq_flush_dcache_pages - Helper function to flush all pages in a re=
quest
>  * @rq: the request to be flushed
>  *
>  * Description:
>  *     Flush all pages in @rq.
>  */
> void rq_flush_dcache_pages(struct request *rq)
> {
>         struct req_iterator iter;
>         struct bio_vec *bvec;
>=20
>         rq_for_each_segment(bvec, rq, iter)
>                 flush_dcache_page(bvec->bv_page);
> }
> EXPORT_SYMBOL_GPL(rq_flush_dcache_pages);
> #endif
>=20
>=20
>=20
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
>=20
