From: Tom Herbert <tom@herbertland.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Tue, 13 Dec 2016 15:32:09 -0800
Message-ID: <CALx6S369T_hvoTgyHbmeSiR2p3d68h+0tMKqMmcGYLrKiN3JMA@mail.gmail.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
 <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
 <1481233016.11849.1@smtp.office365.com> <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com> <1481335192.3663.0@smtp.office365.com>
 <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481565929.24490.0@smtp.office365.com> <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
 <1481581466.24490.2@smtp.office365.com> <CALx6S34S82kFVqYW1M0ZuHx_Mxut4QaLFVerLX4aEsksrFirXg@mail.gmail.com>
 <CAEfhGiyFW1YHmmUYpFv+q4J4r=wSv3ZBZowG69BqkT3p-G4gNw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Josef Bacik <jbacik@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Craig Gallek <kraigatgoog@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qk0-f176.google.com ([209.85.220.176]:35475 "EHLO
        mail-qk0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751041AbcLMXkx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 13 Dec 2016 18:40:53 -0500
Received: by mail-qk0-f176.google.com with SMTP id n204so2823841qke.2
        for <netdev@vger.kernel.org>; Tue, 13 Dec 2016 15:40:53 -0800 (PST)
In-Reply-To: <CAEfhGiyFW1YHmmUYpFv+q4J4r=wSv3ZBZowG69BqkT3p-G4gNw@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Dec 13, 2016 at 3:03 PM, Craig Gallek <kraigatgoog@gmail.com> wrote:
> On Tue, Dec 13, 2016 at 3:51 PM, Tom Herbert <tom@herbertland.com> wrote:
>> I think there may be some suspicious code in inet_csk_get_port. At
>> tb_found there is:
>>
>>                 if (((tb->fastreuse > 0 && reuse) ||
>>                      (tb->fastreuseport > 0 &&
>>                       !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>                       sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
>>                     smallest_size == -1)
>>                         goto success;
>>                 if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb, true)) {
>>                         if ((reuse ||
>>                              (tb->fastreuseport > 0 &&
>>                               sk->sk_reuseport &&
>>                               !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>                               uid_eq(tb->fastuid, uid))) &&
>>                             smallest_size != -1 && --attempts >= 0) {
>>                                 spin_unlock_bh(&head->lock);
>>                                 goto again;
>>                         }
>>                         goto fail_unlock;
>>                 }
>>
>> AFAICT there is redundancy in these two conditionals.  The same clause
>> is being checked in both: (tb->fastreuseport > 0 &&
>> !rcu_access_pointer(sk->sk_reuseport_cb) && sk->sk_reuseport &&
>> uid_eq(tb->fastuid, uid))) && smallest_size == -1. If this is true the
>> first conditional should be hit, goto done,  and the second will never
>> evaluate that part to true-- unless the sk is changed (do we need
>> READ_ONCE for sk->sk_reuseport_cb?).
> That's an interesting point... It looks like this function also
> changed in 4.6 from using a single local_bh_disable() at the beginning
> with several spin_lock(&head->lock) to exclusively
> spin_lock_bh(&head->lock) at each locking point.  Perhaps the full bh
> disable variant was preventing the timers in your stack trace from
> running interleaved with this function before?

Could be, although dropping the lock shouldn't be able to affect the
search state. TBH, I'm a little lost in reading function, the
SO_REUSEPORT handling is pretty complicated. For instance,
rcu_access_pointer(sk->sk_reuseport_cb) is checked three times in that
function and also in every call to inet_csk_bind_conflict. I wonder if
we can simply this under the assumption that SO_REUSEPORT is only
allowed if the port number (snum) is explicitly specified.

Tom
