From: Wei Wang <weiwan@google.com>
Subject: Re: [PATCH net] ipv6: remove incorrect WARN_ON() in fib6_del()
Date: Mon, 25 Sep 2017 22:52:38 -0700
Message-ID: <CAEA6p_Du641cbcvr5JVXbLMh0T9fAauWDcXqNmrNoJkddMVCBA@mail.gmail.com>
References: <20170925173522.99892-1-tracywwnj@gmail.com> <20170926005618.z4ymlry7jl47nkjm@kafai-mbp.dhcp.thefacebook.com>
 <CAEA6p_CvtmNaYcgSSyFNEbip1ckKwLjJH3PJTOqym0hCt-x2uw@mail.gmail.com>
 <20170926020720.gnvfz6xch4frf2dy@kafai-mbp> <CANn89iJWo8U=csnZNh+QHh7Sf8+Gaig56-HU9BbZbGeeFs5g3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Martin KaFai Lau <kafai@fb.com>,
        David Miller <davem@davemloft.net>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Eric Dumazet <edumazet@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f173.google.com ([209.85.217.173]:51449 "EHLO
        mail-ua0-f173.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753956AbdIZFwk (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 26 Sep 2017 01:52:40 -0400
Received: by mail-ua0-f173.google.com with SMTP id 72so5766795uas.8
        for <netdev@vger.kernel.org>; Mon, 25 Sep 2017 22:52:40 -0700 (PDT)
In-Reply-To: <CANn89iJWo8U=csnZNh+QHh7Sf8+Gaig56-HU9BbZbGeeFs5g3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Sep 25, 2017 at 7:23 PM, Eric Dumazet <edumazet@google.com> wrote:
> On Mon, Sep 25, 2017 at 7:07 PM, Martin KaFai Lau <kafai@fb.com> wrote:
>
>> I am probably still missing something.
>>
>> Considering the del operation should be under the writer lock,
>> if rt->rt6i_node should be NULL (for rt that has already been
>> removed from fib6), why this WARN_ON() is triggered?
>>
>> An example may help.
>>
>
> Look at the stack trace, you'll find the answers...
>
> ip6_link_failure() -> ip6_del_rt()
>
> Note that rt might have been deleted from the _tree_ already.

Had a brief talk with Martin.
He has a valid point.
The current WARN_ON() code is as follows:
#if RT6_DEBUG >= 2
       if (rt->dst.obsolete > 0) {
               WARN_ON(fn);
               return -ENOENT;
       }
#endif

The WARN_ON() only triggers when fn is not NULL. (I missed it before.)
In theory, fib6_del() calls fib6_del_route() which should set
rt->rt6i_node to NULL and rt->dst.obsolete to DST_OBSOLETE_DEAD within
the same write_lock session.
If those 2 values are inconsistent, it indicates something is wrong.
Will need more time to root cause the issue.

Please ignore this patch. Sorry about the confusion.
