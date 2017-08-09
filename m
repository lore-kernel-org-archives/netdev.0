From: Willem de Bruijn <willemdebruijn.kernel@gmail.com>
Subject: Re: panic at sock_zerocopy_put when I ssh into a VM
Date: Tue, 8 Aug 2017 22:01:49 -0700
Message-ID: <CAF=yD-JDOoYYboh44AnHsaLPn9ip603MVwr6YPJn4HBaMjTyqg@mail.gmail.com>
References: <9ea97b60-7416-bdb2-e167-8fcc8c11b1cc@gmail.com> <CAF=yD-J8JMyVq3Qt2n+L-EmpxacJ=mD7-KdsjgO3YB3LAzbKMQ@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Cc: Willem de Bruijn <willemb@google.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: David Ahern <dsahern@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f51.google.com ([209.85.218.51]:35351 "EHLO
        mail-oi0-f51.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750866AbdHIFCa (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 9 Aug 2017 01:02:30 -0400
Received: by mail-oi0-f51.google.com with SMTP id e124so52104776oig.2
        for <netdev@vger.kernel.org>; Tue, 08 Aug 2017 22:02:30 -0700 (PDT)
In-Reply-To: <CAF=yD-J8JMyVq3Qt2n+L-EmpxacJ=mD7-KdsjgO3YB3LAzbKMQ@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Aug 8, 2017 at 9:48 PM, Willem de Bruijn
<willemdebruijn.kernel@gmail.com> wrote:
> Thanks for the report, David, and sorry for the breakage.
>
> I am not able to reproduce the issue with my qemu setup with vhost-net
> with experimental_zcopytx so far.

I did just reproduce the (well, a) panic in sock_zerocopy_put. It is
indeed in the mm_unaccount_pinned_pages code that tests
uarg->mmp:

(gdb) list *(sock_zerocopy_put+0x26)
0xffffffff81620316 is in sock_zerocopy_put (net/core/skbuff.c:933).
928     }
929
930     static void mm_unaccount_pinned_pages(struct mmpin *mmp)
931     {
932             if (mmp->user) {
933                     atomic_long_sub(mmp->num_pg, &mmp->user->locked_vm);
934                     free_uid(mmp->user);

This gives me more confidence that the previous fix is sufficient.
I will have to revise it to avoid this path for all zerocopy paths
besides msg_zerocopy.
