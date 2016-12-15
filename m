From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: Soft lockup in inet_put_port on 4.6
Date: Thu, 15 Dec 2016 18:25:13 -0500
Message-ID: <CAEfhGiy4A7h4JcD0Cur2OAFO4SuPJE9=21wnRaRPbg1TJ7hFXA@mail.gmail.com>
References: <CALx6S36OVUqAxq9vNnfHp2eJOuG+gSSg896zzaZoc3Og4tyxFw@mail.gmail.com>
 <1481231024.1911284.813071977.72AF4DEE@webmail.messagingengine.com>
 <1481233016.11849.1@smtp.office365.com> <1481243432.4930.145.camel@edumazet-glaptop3.roam.corp.google.com>
 <6C6EE0ED-7E78-4866-8AAF-D75FD4719EF3@fb.com> <1481335192.3663.0@smtp.office365.com>
 <1481341624.4930.204.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481343298.4930.208.camel@edumazet-glaptop3.roam.corp.google.com>
 <1481565929.24490.0@smtp.office365.com> <3c022731-e703-34ac-55f1-60f5b94b6d62@stressinduktion.org>
 <1481581466.24490.2@smtp.office365.com> <CALx6S34S82kFVqYW1M0ZuHx_Mxut4QaLFVerLX4aEsksrFirXg@mail.gmail.com>
 <CAEfhGiyFW1YHmmUYpFv+q4J4r=wSv3ZBZowG69BqkT3p-G4gNw@mail.gmail.com>
 <CALx6S369T_hvoTgyHbmeSiR2p3d68h+0tMKqMmcGYLrKiN3JMA@mail.gmail.com>
 <1481828016.24490.5@smtp.office365.com> <CALx6S34dmOWiEtOFQMc1FGhqvLqxM5JkD6q5MvaZz0cGZmNM=A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Josef Bacik <jbacik@fb.com>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>,
        Eric Dumazet <eric.dumazet@gmail.com>,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Tom Herbert <tom@herbertland.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f67.google.com ([74.125.82.67]:33001 "EHLO
        mail-wm0-f67.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753532AbcLOX0M (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 15 Dec 2016 18:26:12 -0500
Received: by mail-wm0-f67.google.com with SMTP id u144so1293315wmu.0
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 15:25:18 -0800 (PST)
Received: from mail-wm0-f54.google.com (mail-wm0-f54.google.com. [74.125.82.54])
        by smtp.gmail.com with ESMTPSA id v3sm4150057wjp.13.2016.12.15.15.25.16
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Thu, 15 Dec 2016 15:25:16 -0800 (PST)
Received: by mail-wm0-f54.google.com with SMTP id u144so9479980wmu.1
        for <netdev@vger.kernel.org>; Thu, 15 Dec 2016 15:25:16 -0800 (PST)
In-Reply-To: <CALx6S34dmOWiEtOFQMc1FGhqvLqxM5JkD6q5MvaZz0cGZmNM=A@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Dec 15, 2016 at 5:39 PM, Tom Herbert <tom@herbertland.com> wrote:
> On Thu, Dec 15, 2016 at 10:53 AM, Josef Bacik <jbacik@fb.com> wrote:
>> On Tue, Dec 13, 2016 at 6:32 PM, Tom Herbert <tom@herbertland.com> wrote:
>>>
>>> On Tue, Dec 13, 2016 at 3:03 PM, Craig Gallek <kraigatgoog@gmail.com>
>>> wrote:
>>>>
>>>>  On Tue, Dec 13, 2016 at 3:51 PM, Tom Herbert <tom@herbertland.com>
>>>> wrote:
>>>>>
>>>>>  I think there may be some suspicious code in inet_csk_get_port. At
>>>>>  tb_found there is:
>>>>>
>>>>>                  if (((tb->fastreuse > 0 && reuse) ||
>>>>>                       (tb->fastreuseport > 0 &&
>>>>>                        !rcu_access_pointer(sk->sk_reuseport_cb) &&
>>>>>                        sk->sk_reuseport && uid_eq(tb->fastuid, uid))) &&
>>>>>                      smallest_size == -1)
>>>>>                          goto success;
>>>>>                  if (inet_csk(sk)->icsk_af_ops->bind_conflict(sk, tb,
>>>>> true)) {
>>>>>                          if ((reuse ||
>>>>>                               (tb->fastreuseport > 0 &&
>>>>>                                sk->sk_reuseport &&
>>>>>                                !rcu_access_pointer(sk->sk_reuseport_cb)
>>>>> &&
>>>>>                                uid_eq(tb->fastuid, uid))) &&
>>>>>                              smallest_size != -1 && --attempts >= 0) {
>>>>>                                  spin_unlock_bh(&head->lock);
>>>>>                                  goto again;
>>>>>                          }
>>>>>                          goto fail_unlock;
>>>>>                  }
>>>>>
>>>>>  AFAICT there is redundancy in these two conditionals.  The same clause
>>>>>  is being checked in both: (tb->fastreuseport > 0 &&
>>>>>  !rcu_access_pointer(sk->sk_reuseport_cb) && sk->sk_reuseport &&
>>>>>  uid_eq(tb->fastuid, uid))) && smallest_size == -1. If this is true the
>>>>>  first conditional should be hit, goto done,  and the second will never
>>>>>  evaluate that part to true-- unless the sk is changed (do we need
>>>>>  READ_ONCE for sk->sk_reuseport_cb?).
>>>>
>>>>  That's an interesting point... It looks like this function also
>>>>  changed in 4.6 from using a single local_bh_disable() at the beginning
>>>>  with several spin_lock(&head->lock) to exclusively
>>>>  spin_lock_bh(&head->lock) at each locking point.  Perhaps the full bh
>>>>  disable variant was preventing the timers in your stack trace from
>>>>  running interleaved with this function before?
>>>
>>>
>>> Could be, although dropping the lock shouldn't be able to affect the
>>> search state. TBH, I'm a little lost in reading function, the
>>> SO_REUSEPORT handling is pretty complicated. For instance,
>>> rcu_access_pointer(sk->sk_reuseport_cb) is checked three times in that
>>> function and also in every call to inet_csk_bind_conflict. I wonder if
>>> we can simply this under the assumption that SO_REUSEPORT is only
>>> allowed if the port number (snum) is explicitly specified.
>>
>>
>> Ok first I have data for you Hannes, here's the time distributions before
>> during and after the lockup (with all the debugging in place the box
>> eventually recovers).  I've attached it as a text file since it is long.
>>
>> Second is I was thinking about why we would spend so much time doing the
>> ->owners list, and obviously it's because of the massive amount of timewait
>> sockets on the owners list.  I wrote the following dumb patch and tested it
>> and the problem has disappeared completely.  Now I don't know if this is
>> right at all, but I thought it was weird we weren't copying the soreuseport
>> option from the original socket onto the twsk.  Is there are reason we
>> aren't doing this currently?  Does this help explain what is happening?
>> Thanks,
>>
> I think that would explain it. We would be walking long lists of TW
> sockets in inet_bind_bucket_for_each(tb, &head->chain). This should
> break, although now I'm wondering if there's other ways we can get
> into this situation. reuseport ensures that we can have long lists of
> sockets in a single bucket, TW sockets can make that list really long.
What if the time-wait timer implementation was changed to do more
opportunistic removals?  In this case, you seem to have a coordinated
timer event causing many independent locking events on the bucket in
question.  If one of those firing events realized it could handle all
of them, you could greatly reduce the contention.  The fact that they
all hash to the same bucket may make this even easier...

> Tom
>
>> Josef
