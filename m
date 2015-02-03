From: Lorenzo Colitti <lorenzo@google.com>
Subject: Re: [PATCH net v3] net: ipv6: allow explicitly choosing optimistic addresses
Date: Wed, 4 Feb 2015 00:40:12 +0900
Message-ID: <CAKD1Yr0k44kwwtfWN-t9C1f7WKT0o=yimPwbfLtBnnvUvXrm=w@mail.gmail.com>
References: <1422859156-30691-1-git-send-email-ek@google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Erik Kline <ek@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ig0-f180.google.com ([209.85.213.180]:47984 "EHLO
	mail-ig0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754501AbbBCPkd (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 3 Feb 2015 10:40:33 -0500
Received: by mail-ig0-f180.google.com with SMTP id b16so25156168igk.1
        for <netdev@vger.kernel.org>; Tue, 03 Feb 2015 07:40:33 -0800 (PST)
In-Reply-To: <1422859156-30691-1-git-send-email-ek@google.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Feb 2, 2015 at 3:39 PM, Erik Kline <ek@google.com> wrote:
> @@ -1526,8 +1534,13 @@ int ipv6_chk_addr(struct net *net, const struct in6_addr *addr,
>         hlist_for_each_entry_rcu(ifp, &inet6_addr_lst[hash], addr_lst) {
>                 if (!net_eq(dev_net(ifp->idev->dev), net))
>                         continue;
> +               /* Permit optimistic addresses, but only under explicitly
> +                * defined circumstances.
> +                */

I don't think this comment adds much of value, the code right below it
is pretty clear.

> +               bool optimistic_ok = (ifp->flags & IFA_F_OPTIMISTIC) &&
> +                                    (banned_flags == IFA_F_TENTATIVE);

Not sure if this can happen in any real use case, but I think that
technically this is incorrect if banned_flags contains both
IFA_F_TENTATIVE and other flags that aren't IFA_F_OPTIMISTIC. For
example, suppose banned_flags = IFA_F_TENTATIVE | IFA_F_PERMANENT. In
that case, I think the code would reject an address with
IFA_F_TENTATIVE | IFA_F_OPTIMISTIC. You might be able to fix that
using something like:

        int ifp_flags;

        ...

               ifp_flags = ifp->flags;
               if (ifp_flags & IFA_F_OPTIMISTIC) ifp_flags &= ~IFA_F_TENTATIVE;
               if (ipv6_addr_equal(&ifp->addr, addr) &&
                 !(ifp_flags & banned_flags) &&

Though I think that at this point your original formulation (the one
that treated IFA_F_TENTATIVE specially and did not pass it in via
banned_flags) might be faster/simpler/better.

Hannes, any better ideas?
