From: Chris Mi <chrism@mellanox.com>
Subject: RE: [patch net-next 1/3] idr: Add new APIs to support unsigned long
Date: Tue, 29 Aug 2017 08:00:45 +0000
Message-ID: <VI1PR0501MB2143CCC1CC15C5716193C7FCAB9F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
References: <1503902477-39829-1-git-send-email-chrism@mellanox.com>
 <1503902477-39829-2-git-send-email-chrism@mellanox.com>
 <87y3q27sn7.fsf@stressinduktion.org>
 <VI1PR0501MB214343F199709BB6EF6EB9B2AB9F0@VI1PR0501MB2143.eurprd05.prod.outlook.com>
 <20170829075711.GE1977@nanopsycho.orion>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: quoted-printable
Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        "jhs@mojatatu.com" <jhs@mojatatu.com>,
        "xiyou.wangcong@gmail.com" <xiyou.wangcong@gmail.com>,
        "davem@davemloft.net" <davem@davemloft.net>,
        "mawilcox@microsoft.com" <mawilcox@microsoft.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ve1eur01on0076.outbound.protection.outlook.com ([104.47.1.76]:48288
        "EHLO EUR01-VE1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1751223AbdH2IAt (ORCPT <rfc822;netdev@vger.kernel.org>);
        Tue, 29 Aug 2017 04:00:49 -0400
In-Reply-To: <20170829075711.GE1977@nanopsycho.orion>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Jiri Pirko [mailto:jiri@resnulli.us]
> Sent: Tuesday, August 29, 2017 3:57 PM
> To: Chris Mi <chrism@mellanox.com>
> Cc: Hannes Frederic Sowa <hannes@stressinduktion.org>;
> netdev@vger.kernel.org; jhs@mojatatu.com; xiyou.wangcong@gmail.com;
> davem@davemloft.net; mawilcox@microsoft.com
> Subject: Re: [patch net-next 1/3] idr: Add new APIs to support unsigned l=
ong
>=20
> Tue, Aug 29, 2017 at 09:34:47AM CEST, chrism@mellanox.com wrote:
> >Hi,
> >
> >> -----Original Message-----
> >> From: Hannes Frederic Sowa [mailto:hannes@stressinduktion.org]
> >> Sent: Tuesday, August 29, 2017 3:14 PM
> >> To: Chris Mi <chrism@mellanox.com>
> >> Cc: netdev@vger.kernel.org; jhs@mojatatu.com;
> >> xiyou.wangcong@gmail.com; jiri@resnulli.us; davem@davemloft.net;
> >> mawilcox@microsoft.com
> >> Subject: Re: [patch net-next 1/3] idr: Add new APIs to support
> >> unsigned long
> >>
> >> Hello,
> >>
> >> Chris Mi <chrism@mellanox.com> writes:
> >>
> >> > The following new APIs are added:
> >> >
> >> > int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
> >> >                   unsigned long start, unsigned long end, gfp_t
> >> > gfp); static inline void *idr_remove_ext(struct idr *idr, unsigned
> >> > long id); static inline void *idr_find_ext(const struct idr *idr,
> >> > unsigned long id); void *idr_replace_ext(struct idr *idr, void
> >> > *ptr, unsigned long id); void *idr_get_next_ext(struct idr *idr,
> >> > unsigned long *nextid);
> >> >
> >> > Signed-off-by: Chris Mi <chrism@mellanox.com>
> >> > Signed-off-by: Jiri Pirko <jiri@mellanox.com>
> >> > ---
> >> >  include/linux/idr.h        | 16 ++++++++++
> >> >  include/linux/radix-tree.h |  3 ++
> >> >  lib/idr.c                  | 56 +++++++++++++++++++++++++++++++++++
> >> >  lib/radix-tree.c           | 73
> >> ++++++++++++++++++++++++++++++++++++++++++++++
> >> >  4 files changed, 148 insertions(+)
> >> >
> >>
> >> [...]
> >>
> >> > +int idr_alloc_ext(struct idr *idr, void *ptr, unsigned long *index,
> >> > +		  unsigned long start, unsigned long end, gfp_t gfp) {
> >> > +	void __rcu **slot;
> >> > +	struct radix_tree_iter iter;
> >> > +
> >> > +	if (WARN_ON_ONCE(radix_tree_is_internal_node(ptr)))
> >> > +		return -EINVAL;
> >> > +
> >> > +	radix_tree_iter_init(&iter, start);
> >> > +	slot =3D idr_get_free_ext(&idr->idr_rt, &iter, gfp, end);
> >> > +	if (IS_ERR(slot))
> >> > +		return PTR_ERR(slot);
> >> > +
> >> > +	radix_tree_iter_replace(&idr->idr_rt, &iter, slot, ptr);
> >> > +	radix_tree_iter_tag_clear(&idr->idr_rt, &iter, IDR_FREE);
> >> > +
> >> > +	if (index)
> >> > +		*index =3D iter.index;
> >> > +	return 0;
> >> > +}
> >> > +EXPORT_SYMBOL_GPL(idr_alloc_ext);
> >>
> >> Can you express idr_alloc in terms of idr_alloc_ext? Same for most of
> >> the other functions (it seems that signed int was used as return
> >> value to indicate error cases, thus it should be easy to map those).
> >In idr_alloc(), we have the following check:
> >
> >        if (WARN_ON_ONCE(start < 0))
> >                return -EINVAL;
> >
> >But in idr_alloc_ext(), since we are using unsigned long, we needn't suc=
h
> check.
>=20
> You can just check and call idr_alloc_ext then to do the actual work.
OK, will fix it.
