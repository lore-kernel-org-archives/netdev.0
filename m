From: =?UTF-8?B?TWFoZXNoIEJhbmRld2FyICjgpK7gpLngpYfgpLYg4KSs4KSC4KSh4KWH4KS14KS+4KSwKQ==?=
        <maheshb@google.com>
Subject: Re: [PATCH,v2,net-next 2/2] tun: enable napi_gro_frags() for TUN/TAP driver
Date: Fri, 22 Sep 2017 09:51:36 -0700
Message-ID: <CAF2d9jhng1-jQypPqA1XdQtocBQ9ayJYfGa1UGGvBhGP=CXoaA@mail.gmail.com>
References: <20170922021715.2618-1-peterpenkov96@gmail.com>
 <20170922021715.2618-3-peterpenkov96@gmail.com> <CAF=yD-KSdujdkgOAvUnuj+xeok9KgT0mem0oQYHP4uq+U8uahA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Petar Penkov <peterpenkov96@gmail.com>,
        Network Development <netdev@vger.kernel.org>,
        Eric Dumazet <edumazet@google.com>,
        Willem de Bruijn <willemb@google.com>,
        David Miller <davem@davemloft.net>,
        Petar Bozhidarov Penkov <ppenkov@stanford.edu>
To: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f182.google.com ([209.85.161.182]:50474 "EHLO
        mail-yw0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752340AbdIVQv6 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 22 Sep 2017 12:51:58 -0400
Received: by mail-yw0-f182.google.com with SMTP id u11so1144590ywh.7
        for <netdev@vger.kernel.org>; Fri, 22 Sep 2017 09:51:58 -0700 (PDT)
In-Reply-To: <CAF=yD-KSdujdkgOAvUnuj+xeok9KgT0mem0oQYHP4uq+U8uahA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Sep 22, 2017 at 7:06 AM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
>> @@ -2061,6 +2174,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>         if (tfile->detached)
>>                 return -EINVAL;
>>
>> +       if ((ifr->ifr_flags & IFF_NAPI_FRAGS) && !capable(CAP_NET_ADMIN))
>> +               return -EPERM;
>> +
>
> This should perhaps be moved into the !dev branch, directly below the
> ns_capable check.
>
Hmm, does that mean fail only on creation but allow to attach if
exists? That would be wrong, isn't it? Correct me if I'm wrong but we
want to prevent both these scenarios if user does not have sufficient
privileges (i.e. NET_ADMIN in init-ns).

>>         dev = __dev_get_by_name(net, ifr->ifr_name);
>>         if (dev) {
>>                 if (ifr->ifr_flags & IFF_TUN_EXCL)
>> @@ -2185,6 +2301,9 @@ static int tun_set_iff(struct net *net, struct file *file, struct ifreq *ifr)
>>         tun->flags = (tun->flags & ~TUN_FEATURES) |
>>                 (ifr->ifr_flags & TUN_FEATURES);
>>
>> +       if (!(tun->flags & IFF_NAPI) || (tun->flags & TUN_TYPE_MASK) != IFF_TAP)
>> +               tun->flags = tun->flags & ~IFF_NAPI_FRAGS;
>> +
>
> Similarly, this check only need to be performed in that branch.
> Instead of reverting to non-frags mode, a tun_set_iff with the wrong
> set of flags should probably fail hard.
Yes, agree, wrong set of flags should fail hard and probably be done
before attach or open, no?
