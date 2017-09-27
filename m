From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] ipv6: remove incorrect WARN_ON() in fib6_del()
Date: Wed, 27 Sep 2017 14:08:46 -0700
Message-ID: <CAEA6p_BzZsrDCEkL+EA302f6nio+jd9j4kXGd2+g8YVdwAzaGw@mail.gmail.com>
References: <20170925173522.99892-1-tracywwnj@gmail.com> <20170926005618.z4ymlry7jl47nkjm@kafai-mbp.dhcp.thefacebook.com>
 <CAEA6p_CvtmNaYcgSSyFNEbip1ckKwLjJH3PJTOqym0hCt-x2uw@mail.gmail.com>
 <20170926020720.gnvfz6xch4frf2dy@kafai-mbp> <CANn89iJWo8U=csnZNh+QHh7Sf8+Gaig56-HU9BbZbGeeFs5g3w@mail.gmail.com>
 <CAEA6p_Du641cbcvr5JVXbLMh0T9fAauWDcXqNmrNoJkddMVCBA@mail.gmail.com> <CANn89i+uLBxzBCUP_TdyswBgAAhUMZajkLN7NGo2+9vuzVc_5A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>,
        Martin KaFai Lau <kafai@fb.com>,
        David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f171.google.com ([209.85.217.171]:52915 "EHLO
        mail-ua0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751894AbdI0VIs (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 27 Sep 2017 17:08:48 -0400
Received: by mail-ua0-f171.google.com with SMTP id n38so9326838uai.9
        for <netdev@vger.kernel.org>; Wed, 27 Sep 2017 14:08:48 -0700 (PDT)
In-Reply-To: <CANn89i+uLBxzBCUP_TdyswBgAAhUMZajkLN7NGo2+9vuzVc_5A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Sep 26, 2017 at 6:20 AM, Eric Dumazet <edumazet@google.com> wrote:
> On Mon, Sep 25, 2017 at 10:52 PM, Wei Wang <weiwan@google.com> wrote:
>> On Mon, Sep 25, 2017 at 7:23 PM, Eric Dumazet <edumazet@google.com> wrote:
>>> On Mon, Sep 25, 2017 at 7:07 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>>>
>>>> I am probably still missing something.
>>>>
>>>> Considering the del operation should be under the writer lock,
>>>> if rt->rt6i_node should be NULL (for rt that has already been
>>>> removed from fib6), why this WARN_ON() is triggered?
>>>>
>>>> An example may help.
>>>>
>>>
>>> Look at the stack trace, you'll find the answers...
>>>
>>> ip6_link_failure() -> ip6_del_rt()
>>>
>>> Note that rt might have been deleted from the _tree_ already.
>>
>> Had a brief talk with Martin.
>> He has a valid point.
>> The current WARN_ON() code is as follows:
>> #if RT6_DEBUG >= 2
>>        if (rt->dst.obsolete > 0) {
>>                WARN_ON(fn);
>>                return -ENOENT;
>>        }
>> #endif
>>
>> The WARN_ON() only triggers when fn is not NULL. (I missed it before.)
>> In theory, fib6_del() calls fib6_del_route() which should set
>> rt->rt6i_node to NULL and rt->dst.obsolete to DST_OBSOLETE_DEAD within
>> the same write_lock session.
>> If those 2 values are inconsistent, it indicates something is wrong.
>> Will need more time to root cause the issue.
>>
>> Please ignore this patch. Sorry about the confusion.
>
> Oh well, for some reason I was seeing WARN_ON(1)  here, since this is
> a construct I often add in my tests ...

Just an update on this issue:
This WARNING issue should already be fixed by commit
7483cea79957312e9f8e9cf760a1bc5d6c507113:
Author: Ido Schimmel <idosch@mellanox.com>
Date:   Thu Aug 3 13:28:22 2017 +0200

    ipv6: fib: Unlink replaced routes from their nodes

    When a route is deleted its node pointer is set to NULL to indicate it's
    no longer linked to its node. Do the same for routes that are replaced.

    This will later allow us to test if a route is still in the FIB by
    checking its node pointer instead of its reference count.

    Signed-off-by: Ido Schimmel <idosch@mellanox.com>
    Signed-off-by: Jiri Pirko <jiri@mellanox.com>
    Signed-off-by: David S. Miller <davem@davemloft.net>

So no further action is needed on this.

Thanks.
Wei
