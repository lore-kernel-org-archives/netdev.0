From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH 1/2] af_packet: use vmalloc_to_page() instead for the
 addresss returned by vmalloc()
Date: Wed, 01 Dec 2010 16:13:16 +0100
Message-ID: <1291216396.2856.861.camel@edumazet-laptop>
References: <1291125408-14389-1-git-send-email-xiaosuo@gmail.com>
	 <1291126341.2904.82.camel@edumazet-laptop>
	 <20101130143720.GA6017@hmsreliant.think-freely.org>
	 <AANLkTim7SSRMkhc_eMz+Bk12kAwfG==j-dH4NOPu-uS2@mail.gmail.com>
	 <1291210691.2856.740.camel@edumazet-laptop>
	 <AANLkTinViD=WpwUFUDF6mKbc-Cap_Tg=SXwOjVQ=5u4B@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Neil Horman <nhorman@tuxdriver.com>,
	"David S. Miller" <davem@davemloft.net>,
	Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org
To: Changli Gao <xiaosuo@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wy0-f174.google.com ([74.125.82.174]:37317 "EHLO
	mail-wy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751173Ab0LAPNW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 1 Dec 2010 10:13:22 -0500
Received: by wyb28 with SMTP id 28so7050722wyb.19
        for <netdev@vger.kernel.org>; Wed, 01 Dec 2010 07:13:21 -0800 (PST)
In-Reply-To: <AANLkTinViD=WpwUFUDF6mKbc-Cap_Tg=SXwOjVQ=5u4B@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mercredi 01 d=C3=A9cembre 2010 =C3=A0 22:16 +0800, Changli Gao a =C3=
=A9crit :

> Even then, tpacket_fill_skb() is called for every skb, and
> pgv_to_page() is used in it. We have to optimize pgv_to_page().

With the __pure trick I gave, pgv_to_page() is _not_ called for the
typical use case of af_packet : packet sniffing.

Compiler is able to remove the call completely, since

static inline void flush_dcache_page(struct page *page) { }

The only remaining pgv_to_page() call is the one done in mmap packet
send, since we have to do :

page =3D pgv_to_page(data);
get_page(page);

I personally dont use this path, its known to be buggy...

Optimize if you want, but make all this
ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE conditional.

Its not needed to maintain an array of 'struct page *' if its not neede=
d
at all.

# vi +2448 block/blk-core.c

#if ARCH_IMPLEMENTS_FLUSH_DCACHE_PAGE
/**
 * rq_flush_dcache_pages - Helper function to flush all pages in a requ=
est
 * @rq: the request to be flushed
 *
 * Description:
 *     Flush all pages in @rq.
 */
void rq_flush_dcache_pages(struct request *rq)
{
        struct req_iterator iter;
        struct bio_vec *bvec;

        rq_for_each_segment(bvec, rq, iter)
                flush_dcache_page(bvec->bv_page);
}
EXPORT_SYMBOL_GPL(rq_flush_dcache_pages);
#endif



