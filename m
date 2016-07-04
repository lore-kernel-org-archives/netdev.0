From: Marc Dionne <marc.c.dionne@gmail.com>
Subject: Re: Multi-thread udp 4.7 regression, bisected to 71d8c47fc653
Date: Mon, 4 Jul 2016 09:35:28 -0300
Message-ID: <CAB9dFds7KQxihReHhW9CXJeY9+=4BPema3ZawVA89U45QL5uBw@mail.gmail.com>
References: <CAB9dFduvE0dKzZ8Dm5RVVrUAq1Auvj8t9xXAyARGyO4NmowvYw@mail.gmail.com>
 <20160627142238.GA10613@breakpoint.cc> <CAB9dFds=qY=Dk++p7qVX7a8aOOH4wn0rtL3m4poO6HMQPuPrnA@mail.gmail.com>
 <20160627153820.GB10613@breakpoint.cc> <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Pablo Neira Ayuso <pablo@netfilter.org>,
	netdev <netdev@vger.kernel.org>, regressions@leemhuis.info
To: Florian Westphal <fw@strlen.de>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f54.google.com ([209.85.213.54]:32976 "EHLO
	mail-vk0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753520AbcGDMfb (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Jul 2016 08:35:31 -0400
Received: by mail-vk0-f54.google.com with SMTP id k68so143111405vkb.0
        for <netdev@vger.kernel.org>; Mon, 04 Jul 2016 05:35:30 -0700 (PDT)
In-Reply-To: <CAB9dFdvQ4UyKNMmOSx+FePyR0_Q425XLJRb_k5h+4JOSkQkf3w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, Jun 27, 2016 at 2:21 PM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
> On Mon, Jun 27, 2016 at 12:38 PM, Florian Westphal <fw@strlen.de> wrote:
>> Marc Dionne <marc.c.dionne@gmail.com> wrote:
>>> On Mon, Jun 27, 2016 at 11:22 AM, Florian Westphal <fw@strlen.de> wrote:
>>> > Marc Dionne <marc.c.dionne@gmail.com> wrote:
>>> >> Hi,
>>
>>> >         hlist_nulls_for_each_entry(h, n, &nf_conntrack_hash[hash], hnnode)
>>> >                 if (nf_ct_key_equal(h, &ct->tuplehash[IP_CT_DIR_ORIGINAL].tuple,
>>> > -                                   zone, net))
>>> > -                       goto out;
>>> > +                                   zone, net)) {
>>> > +                       nf_ct_add_to_dying_list(ct);
>>> > +                       ret = nf_ct_resolve_clash(net, skb, ctinfo, h);
>>> > +                       goto dying;
>>> > +               }
>>
>> This is bogus as h can be a reply too (key compare does not deal
>> with it).
>>
>> Below is what I actually intended; I can't come up with a reason why
>> you experience this issue other than that we're getting confused over
>> reply/original direction.
>>
>> If the patch doesn't help either, can you tell us what kind of iptables
>> rules are installed on the affected system or perhaps report perf drop
>> monitor stat when things go wrong?
>>
>> Thanks!
>
> The additional patch didn't help either.
>
> I had a lot of iptables bloat, but I reverted to old simple iptables
> and ip6tables configs (attached), and still see the problem.  Note
> that the test normally uses ipv6, but the behaviour is the same with
> ipv4.
>
> Marc

Hi,

Any other ideas for this issue?  I would hate to see the 4.7 release
go out without a fix or revert, and have a kernel that we have to tell
our clients not to use.

If there is no quick fix, seems like a revert should be considered:
- Looks to me like the commit attempts to fix a long standing bug
(exists at least as far back as 3.5,
https://bugzilla.kernel.org/show_bug.cgi?id=52991)
- The above bug has a simple workaround (at least for us) that we
implemented more than 3 years ago
- The commit reverts cleanly, restoring the original behaviour
- From that bug report, bind was one of the affected applications; I
would suspect that this regression is likely to affect bind as well

I'd be more than happy to test suggested fixes or give feedback with
debugging patches, etc.

Thanks,
Marc
