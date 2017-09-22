From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: [PATCH,v2,net-next 2/2] tun: enable napi_gro_frags() for TUN/TAP driver
Date: Fri, 22 Sep 2017 10:06:28 -0400
Message-ID: <CAF=yD-KSdujdkgOAvUnuj+xeok9KgT0mem0oQYHP4uq+U8uahA@mail.gmail.com>
References: <20170922021715.2618-1-peterpenkov96@gmail.com> <20170922021715.2618-3-peterpenkov96@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Mahesh Bandewar <maheshb@google.com>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>, ppenkov@stanford.edu
To: Petar Penkov <peterpenkov96@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-io0-f169.google.com ([209.85.223.169]:44610 "EHLO
        mail-io0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752368AbdIVOHJ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 10:07:09 -0400
Received: by mail-io0-f169.google.com with SMTP id v36so3304931ioi.1
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 07:07:09 -0700 (PDT)
In-Reply-To: <20170922021715.2618-3-peterpenkov96@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> @@ -2061,6 +2174,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>         if (tfile->detached)
>                 return -EINVAL;
>
> +       if ((ifr->ifr_flags & IFF_NAPI_FRAGS) && !capable(CAP_NET_ADMIN))
> +               return -EPERM;
> +

This should perhaps be moved into the !dev branch, directly below the
ns_capable check.

>         dev = __dev_get_by_name(net, ifr->ifr_name);
>         if (dev) {
>                 if (ifr->ifr_flags & IFF_TUN_EXCL)
> @@ -2185,6 +2301,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>         tun->flags = (tun->flags & ~TUN_FEATURES) |
>                 (ifr->ifr_flags & TUN_FEATURES);
>
> +       if (!(tun->flags & IFF_NAPI) || (tun->flags & TUN_TYPE_MASK) != IFF_TAP)
> +               tun->flags = tun->flags & ~IFF_NAPI_FRAGS;
> +

Similarly, this check only need to be performed in that branch.
Instead of reverting to non-frags mode, a tun_set_iff with the wrong
set of flags should probably fail hard.
