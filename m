From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 16:21:39 +0100
Message-ID: <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
 <20161124222357-mutt-send-email-mst@kernel.org> <20161125112203.GA26611@leverpostej>
 <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com> <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net> <20161125124404.GI3174@twins.programming.kicks-ass.net>
 <20161125145512.GA4014@Boquns-MacBook-Pro.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Peter Zijlstra <peterz@infradead.org>,
        Mark Rutland <mark.rutland@arm.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>, dbueso@suse.de,
        jasowang@redhat.com, KVM list <kvm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        virtualization@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Boqun Feng <boqun.feng@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f53.google.com ([209.85.215.53]:36171 "EHLO
        mail-lf0-f53.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754975AbcKYPWQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 10:22:16 -0500
Received: by mail-lf0-f53.google.com with SMTP id t196so53024915lff.3
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 07:22:01 -0800 (PST)
In-Reply-To: <20161125145512.GA4014@Boquns-MacBook-Pro.local>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 3:56 PM, Boqun Feng <boqun.feng@gmail.com> wrote:
> On Fri, Nov 25, 2016 at 01:44:04PM +0100, Peter Zijlstra wrote:
>> On Fri, Nov 25, 2016 at 01:40:44PM +0100, Peter Zijlstra wrote:
>> > #define SINGLE_LOAD(x)                                              \
>> > {(                                                          \
>> >     compiletime_assert_atomic_type(typeof(x));              \
>>
>> Should be:
>>
>>       compiletime_assert_atomic_type(x);
>>
>> >     WARN_SINGLE_COPY_ALIGNMENT(&(x));                       \
>
> Do we need to worry about the side effect on x? Maybe
>
> #define SINGLE_LOAD(x)                                  \
> ({                                                      \
>         typeof(x) *_____ptr;                            \
>                                                         \
>         compiletime_assert_atomic_type(typeof(x));      \
>                                                         \
>         _____ptr = &(x);                                \
>                                                         \
>         WARN_SINGLE_COPY_ALIGNMENT(_____ptr);           \
>                                                         \
>         READ_ONCE(*_____ptr);                           \
> })
>
> Ditto for SINGLE_STORE()
>
> Regards,
> Boqun
>
>> >     READ_ONCE(x);                                           \
>> > })
>> >
>> > #define SINGLE_STORE(x, v)                                  \
>> > ({                                                          \
>> >     compiletime_assert_atomic_type(typeof(x));              \
>>
>> idem
>>
>> >     WARN_SINGLE_COPY_ALIGNMENT(&(x));                       \
>> >     WRITE_ONCE(x, v);                                       \
>> > })


READ/WRITE_ONCE imply atomicity. Even if their names don't spell it (a
function name doesn't have to spell all of its guarantees). Most of
the uses of READ/WRITE_ONCE will be broken if they are not atomic.
"Read once but not necessary atomically" is a very subtle primitive
which is very easy to misuse. What are use cases for such primitive
that won't be OK with "read once _and_ atomically"? Copy to/from user
is obviously one such case, but it is already handled specially.
