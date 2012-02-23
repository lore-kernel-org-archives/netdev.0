From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: Re: WARNING: at kernel/softirq.c:159
 _local_bh_enable_ip+0x35/0x71()
Date: Thu, 23 Feb 2012 15:21:06 +0100
Message-ID: <1330006866.15610.18.camel@edumazet-laptop>
References: <1422860.157191329872584374.JavaMail.weblogic@epml01>
	 <20120223104237.GA2127@electric-eye.fr.zoreil.com>
	 <1329998028.15610.14.camel@edumazet-laptop>
	 <1330003354.11248.9.camel@twins>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Francois Romieu <romieu@fr.zoreil.com>,
	Shreyas Bhatewara <sbhatewara@vmware.com>,
	Jongman Heo <jongman.heo@samsung.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Scott J. Goldman" <scottjg@vmware.com>,
	VMware PV-Drivers <pv-drivers@vmware.com>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f174.google.com ([209.85.212.174]:42656 "EHLO
	mail-wi0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754003Ab2BWOVP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Feb 2012 09:21:15 -0500
Received: by wics10 with SMTP id s10so780740wic.19
        for <netdev@vger.kernel.org>; Thu, 23 Feb 2012 06:21:13 -0800 (PST)
In-Reply-To: <1330003354.11248.9.camel@twins>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le jeudi 23 f=C3=A9vrier 2012 =C3=A0 14:22 +0100, Peter Zijlstra a =C3=A9=
crit :
> On Thu, 2012-02-23 at 12:53 +0100, Eric Dumazet wrote:
> > Hmm, I am not sure we still need local_bh_disable()/local_bh_enable=
() in
> > kmap_skb_frag()/ kunmap_skb_frag() anymore after commit 3e4d3af501c=
cc
> > (mm: stack based kmap_atomic() )
>=20
> The only thing to consider is keeping the total stack size under
> control, this is somewhat non-trivial since its non-obvious what all
> nests.
>=20
> That said, you're probably right, and we do have a WARN in there
> (dependent on CONFIG_DEBUG_HIGHMEM) that yells if we exceed the
> available stack size.
>=20
> The more 'interesting' exercise is determining a better upper bound o=
n
> the stack size and updating kmap_types.h accordingly.
>=20

I would say its the same logic than crypto : We might use at most two
contexts for SKB frags : USER or SOFTIRQ

We probably can remove KM_SKB_DATA_SOFTIRQ slot and use fact that this
kmap user can reuse existing USER/SOFTIRQ slots

> > diff --git a/net/core/kmap_skb.h b/net/core/kmap_skb.h
> > index 81e1ed7..06be5ee 100644
> > --- a/net/core/kmap_skb.h
> > +++ b/net/core/kmap_skb.h
> > @@ -2,18 +2,10 @@
> > =20
> >  static inline void *kmap_skb_frag(const skb_frag_t *frag)
> >  {
> > -#ifdef CONFIG_HIGHMEM
> > -       BUG_ON(in_irq());
> > -
> > -       local_bh_disable();
> > -#endif
> >         return kmap_atomic(skb_frag_page(frag), KM_SKB_DATA_SOFTIRQ=
);
> >  }
> > =20
> >  static inline void kunmap_skb_frag(void *vaddr)
> >  {
> >         kunmap_atomic(vaddr, KM_SKB_DATA_SOFTIRQ);
> > -#ifdef CONFIG_HIGHMEM
> > -       local_bh_enable();
> > -#endif
> >  }=20
>=20
> The nicer patch would of course be a patch that does:
>=20
>  s/kunmap_skb_frag/kunmap_atomic/
>  s/kmap_skb_frag(\([^)]*\))/kmap_atomic(skb_frag_page(\1))/
>=20
> There is no need to retain the KM_* argument and the 'helper' functio=
ns
> are quite pointless at that point.
>=20
>=20

Well, definitely a cleanup is possible, but probably not suitable for
3.3 and stable kernels ?
