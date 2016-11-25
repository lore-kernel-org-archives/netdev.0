From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH 0/3] virtio/vringh: kill off ACCESS_ONCE()
Date: Fri, 25 Nov 2016 18:28:53 +0100
Message-ID: <CACT4Y+YJUUjU_FCR1FOcF2DmkkcjiRFpnU7Q4=yzbgvKv0VhyQ@mail.gmail.com>
References: <1479983114-17190-1-git-send-email-mark.rutland@arm.com>
 <20161124222357-mutt-send-email-mst@kernel.org> <20161125112203.GA26611@leverpostej>
 <32dfca07-59f3-b75a-3154-cf6b6c8538f0@de.ibm.com> <20161125122356.GB26611@leverpostej>
 <20161125124044.GN3092@twins.programming.kicks-ass.net> <20161125124404.GI3174@twins.programming.kicks-ass.net>
 <20161125145512.GA4014@Boquns-MacBook-Pro.local> <CACT4Y+ZpzFhmSqOG+dG7QHSNObWatLOjPjNK2BznnRLeRQpF8A@mail.gmail.com>
 <20161125161004.GA30181@leverpostej> <20161125161709.GQ3092@twins.programming.kicks-ass.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: quoted-printable
Cc: Mark Rutland <mark.rutland@arm.com>,
        Boqun Feng <boqun.feng@gmail.com>,
        Christian Borntraeger <borntraeger@de.ibm.com>,
        "Michael S. Tsirkin" <mst@redhat.com>,
        LKML <linux-kernel@vger.kernel.org>,
        Davidlohr Bueso <dave@stgolabs.net>, dbueso@suse.de,
        jasowang@redhat.com, KVM list <kvm@vger.kernel.org>,
        netdev <netdev@vger.kernel.org>,
        Paul McKenney <paulmck@linux.vnet.ibm.com>,
        virtualization@lists.linux-foundation.org,
        Linus Torvalds <torvalds@linux-foundation.org>
To: Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f45.google.com ([209.85.215.45]:36560 "EHLO
        mail-lf0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932762AbcKYR3Q (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 25 Nov 2016 12:29:16 -0500
Received: by mail-lf0-f45.google.com with SMTP id t196so55180505lff.3
        for <netdev@vger.kernel.org>; Fri, 25 Nov 2016 09:29:15 -0800 (PST)
In-Reply-To: <20161125161709.GQ3092@twins.programming.kicks-ass.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Nov 25, 2016 at 5:17 PM, Peter Zijlstra <peterz@infradead.org> wrot=
e:
>> > What are use cases for such primitive that won't be OK with "read once
>> > _and_ atomically"?
>>
>> I have none to hand.
>
> Whatever triggers the __builtin_memcpy() paths, and even the size=3D=3D8
> paths on 32bit.
>
> You could put a WARN in there to easily find them.
>
> The advantage of introducing the SINGLE_{LOAD,STORE}() helpers is that
> they compiletime validate this the size is 'right' and can runtime check
> alignment constraints.
>
> IE, they are strictly stronger than {READ,WRITE}_ONCE().


Uh, so, READ/WRITE_ONCE are non-atomic now. I missed that.

If READ/WRITE_ONCE are non-atomic, half of kernel is broken. All these
loads of flags, ringbuffer positions, pointers, etc are broken.

What about restoring READ/WRITE_ONCE as atomic, and introducing
separate primitives for _non_ atomic loads/stores?
It seems to me that there is just a dozen of cases that don't need
atomicity and where performance is any important (though, some of
these should probably try to write to shared memory less frequently
and save hundreds of cycles, rather than try to save few cycles on
local instructions).

I've compiled kernel with restored size checks in
READ/WRITE/ACCESS_ONCE and the following places seem to expect that
access is actually atomic (while it is not).
But if we don't guarantee that word-sized READ/WRITE_ONCE are atomic,
then I am sure we can find a hundred more of broken places.


arch/x86/entry/vdso/vdso32/../vclock_gettime.c:297:18: note: in
expansion of macro =E2=80=98ACCESS_ONCE=E2=80=99
  time_t result =3D ACCESS_ONCE(gtod->wall_time_sec);

kernel/events/ring_buffer.c:160:10: error: call to
=E2=80=98__compiletime_assert_160=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
   tail =3D READ_ONCE(rb->user_page->data_tail);

kernel/events/core.c:5145:16: error: call to
=E2=80=98__compiletime_assert_5145=E2=80=99 declared with attribute error: =
Need native
word sized stores/loads for atomicity.
   aux_offset =3D ACCESS_ONCE(rb->user_page->aux_offset);
                ^
kernel/events/core.c:5146:14: error: call to
=E2=80=98__compiletime_assert_5146=E2=80=99 declared with attribute error: =
Need native
word sized stores/loads for atomicity.
   aux_size =3D ACCESS_ONCE(rb->user_page->aux_size);

drivers/cpufreq/cpufreq_governor.c:283:8: error: call to
=E2=80=98__compiletime_assert_283=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
  lst =3D READ_ONCE(policy_dbs->last_sample_time);
        ^
drivers/cpufreq/cpufreq_governor.c:301:7: error: call to
=E2=80=98__compiletime_assert_301=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
   if (unlikely(lst !=3D READ_ONCE(policy_dbs->last_sample_time))) {

net/core/gen_estimator.c:136:3: error: call to
=E2=80=98__compiletime_assert_136=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
   WRITE_ONCE(e->rate_est->bps, (e->avbps + 0xF) >> 5);
   ^
net/core/gen_estimator.c:142:3: error: call to
=E2=80=98__compiletime_assert_142=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
   WRITE_ONCE(e->rate_est->pps, (e->avpps + 0xF) >> 5);

fs/proc_namespace.c:28:10: error: call to =E2=80=98__compiletime_assert_28=
=E2=80=99
declared with attribute error: Need native word sized stores/loads for
atomicity.
  event =3D ACCESS_ONCE(ns->event);

drivers/md/dm-stats.c:700:32: error: call to
=E2=80=98__compiletime_assert_700=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
   shared->tmp.sectors[READ] +=3D ACCESS_ONCE(p->sectors[READ]);
                                ^
drivers/md/dm-stats.c:701:33: error: call to
=E2=80=98__compiletime_assert_701=E2=80=99 declared with attribute error: N=
eed native
word sized stores/loads for atomicity.
   shared->tmp.sectors[WRITE] +=3D ACCESS_ONCE(p->sectors[WRITE]);
                                 ^
