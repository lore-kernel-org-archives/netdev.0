From: Jesse Gross <jesse@kernel.org>
Subject: Re: gro: Make GRO aware of lightweight tunnels.
Date: Wed, 10 Feb 2016 13:29:40 +0100
Message-ID: <CAEh+42jUdiT0FzKC5UGa5+=Ej9zisQ+DwCCwT_cv_t-ut6vSSg@mail.gmail.com>
References: <20160202022858.60C826612C0@gitolite.kernel.org> <20160209004956.GA18196@codemonkey.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Dave Jones <davej@codemonkey.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.kernel.org ([198.145.29.136]:46979 "EHLO mail.kernel.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750926AbcBJM35 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Feb 2016 07:29:57 -0500
Received: from mail.kernel.org (localhost [127.0.0.1])
	by mail.kernel.org (Postfix) with ESMTP id 3874E20375
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 12:29:56 +0000 (UTC)
Received: from mail-qg0-f44.google.com (mail-qg0-f44.google.com [209.85.192.44])
	(using TLSv1.2 with cipher AES128-GCM-SHA256 (128/128 bits))
	(No client certificate requested)
	by mail.kernel.org (Postfix) with ESMTPSA id 2962D20364
	for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 12:29:55 +0000 (UTC)
Received: by mail-qg0-f44.google.com with SMTP id y89so12085056qge.2
        for <netdev@vger.kernel.org>; Wed, 10 Feb 2016 04:29:55 -0800 (PST)
In-Reply-To: <20160209004956.GA18196@codemonkey.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 9, 2016 at 1:49 AM, Dave Jones <davej@codemonkey.org.uk> wrote:
> On Tue, Feb 02, 2016 at 02:28:58AM +0000, Linux Kernel wrote:
>  > Web:        https://git.kernel.org/torvalds/c/ce87fc6ce3f9f4488546187e3757cf666d9d4a2a
>  > Commit:     ce87fc6ce3f9f4488546187e3757cf666d9d4a2a
>  > Parent:     5f2f3cad8b878b23f17a11dd5af4f4a2cc41c797
>  > Refname:    refs/heads/master
>  > Author:     Jesse Gross <jesse@kernel.org>
>  > AuthorDate: Wed Jan 20 17:59:49 2016 -0800
>  > Committer:  David S. Miller <davem@davemloft.net>
>  > CommitDate: Wed Jan 20 18:48:38 2016 -0800
>  >
>  >     gro: Make GRO aware of lightweight tunnels.
>
> Coverity just started complaining about this commit.
>
>  > diff --git a/include/net/dst_metadata.h b/include/net/dst_metadata.h
>  > index 6816f0f..30a56ab 100644
>  > --- a/include/net/dst_metadata.h
>  > +++ b/include/net/dst_metadata.h
>  > @@ -44,6 +44,24 @@ static inline bool skb_valid_dst(const struct sk_buff *skb)
>  >      return dst && !(dst->flags & DST_METADATA);
>  >  }
>  >
>  > +static inline int skb_metadata_dst_cmp(const struct sk_buff *skb_a,
>  > +                                   const struct sk_buff *skb_b)
>  > +{
>  > +    const struct metadata_dst *a, *b;
>  > +
>  > +    if (!(skb_a->_skb_refdst | skb_b->_skb_refdst))
>  > +            return 0;
>  > +
>  > +    a = (const struct metadata_dst *) skb_dst(skb_a);
>  > +    b = (const struct metadata_dst *) skb_dst(skb_b);
>  > +
>  > +    if (!a != !b || a->u.tun_info.options_len != b->u.tun_info.options_len)
>
> It complains that we could dereference a null 'a' here.
>
> It's possible the checker got confused, but the first part of that
> expression looks odd, is that doing what's intended ?

I don't think that this can actually happen in practice.

We know that the combination of 'a' and 'b' is not NULL from the first
line in the function ('a' is simply 'skb_a->_skb_refdst' with a flag
knocked off and there is an earlier problem if this makes a difference
for the NULL check). The expression you mentioned is seeing if one is
NULL but not the other. If that is not the case then we can safely
dereference the pointers to do further comparisons.

I guess Coverity doesn't understand the relationship between the
pointer and the flag as handled in skb_dst().
