From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net-next 3/3] ipv6: obsolete cached dst when removing them
 from fib tree
Date: Wed, 18 Oct 2017 10:56:39 -0700
Message-ID: <CAEA6p_DC7gZnaiKdQv7q3P6DcH31c1ioCzVk5HrapAjQG7hRKg@mail.gmail.com>
References: <cover.1508261949.git.pabeni@redhat.com> <59304478d82e52c817c92d183ef2105f35c17266.1508261949.git.pabeni@redhat.com>
 <CAEA6p_CMZu-ooO4sKXD3=wg8_wcAB+oZbTujJ4hEDQnjPZRNwg@mail.gmail.com>
 <1508270578.2548.22.camel@redhat.com> <CAEA6p_AS9c6pOym4t6FGW-bWfU=YmmL96Fc4vMcnDMCc8ywVqg@mail.gmail.com>
 <1508331782.2559.5.camel@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        Xin Long <lucien.xin@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>,
        "David S. Miller" <davem@davemloft.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: Paolo Abeni <pabeni@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f68.google.com ([209.85.213.68]:44435 "EHLO
        mail-vk0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750807AbdJRR4l (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 18 Oct 2017 13:56:41 -0400
Received: by mail-vk0-f68.google.com with SMTP id d12so3833889vkf.1
        for <netdev@vger.kernel.org>; Wed, 18 Oct 2017 10:56:41 -0700 (PDT)
In-Reply-To: <1508331782.2559.5.camel@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 18, 2017 at 6:03 AM, Paolo Abeni <pabeni@redhat.com> wrote:
> On Tue, 2017-10-17 at 13:48 -0700, Wei Wang wrote:
>> On Tue, Oct 17, 2017 at 1:02 PM, Paolo Abeni <pabeni@redhat.com> wrote:
>> > Meanwhile others sockets may grab more references to (and use) the same
>> > aged-out dst.
>> >
>>
>> I don't think other sockets could grab more reference to this dst
>> because this dst should already be removed from the fib6 tree.
>
> With the current net-next code, the dst is not removed from the fib
> tree while someone else is holding it and dst_check() does not fail
> after that the cached dst is aged out. If a socket cache grab a
> reference to the CACHE dst, it will not release it untill the next
> sernum change, regardless of the dst aging.
>
>> > The commit 1e2ea8ad37be ("ipv6: set dst.obsolete when a cached route
>> > has expired") was the solution to the above issue prior to the recent
>> > refactor.
>> >
>>
>> I don't really understand how this commit is solving the above issue.
>> This commit still only ages out cached route if &rt->dst.__refcnt ==
>> 1. So if socket is holding refcnt to this dst and dst_check() is not
>> getting called,  this cached route still won't get deleted.
>
> Setting obsolete to DST_OBSOLETE_KILL forced whoever was holding the
> dst reference to drop it on the next dst_check(), so that refcnt could
> go down.
>

Yes. Understood.
Martin and I had a discussion yesterday. We both think it is not a
good idea to set obolete to DST_OBSOLETE_KILL but not to remove it
from the fib6 tree.
It is because others who do a route lookup later might potentially
find this route and tries to use this route. However, dst_check() will
show this route is invalid. So the user will redo the route lookup.
But as this route is not yet deleted from the tree, it will find this
route again. This seems like a bad situation.
And again, setting obsolete to DST_OBSOLETE_KILL does not prevent some
idle socket holding on to this dst for a long time...

With the above said, I am now convinced what you have in your patch is
the correct thing to do. Just remove the cached route without checking
the refcnt when it is aged.

> Cheers,
>
> Paolo
