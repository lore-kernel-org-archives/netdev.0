From: Craig Gallek <kraig@google.com>
Subject: Re: Crash with SO_REUSEPORT and ef456144da8ef507c8cf504284b6042e9201a05c
Date: Tue, 19 Jan 2016 11:31:25 -0500
Message-ID: <CAEfhGixbKf7+j_4KUvNSQL96N+-9SsDSaH0CmfL=iwWFAYDeMg@mail.gmail.com>
References: <CAB9dFdugvFvdQLGAU83CQHYbwaWCMHrAm5Xk746iwMG5g94PqQ@mail.gmail.com>
	<CAB9dFdswyri4-pDZ+uoAk00isP8Lba7-uqYPXnT=PnLataJeHg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Eric Dumazet <edumazet@google.com>
To: Marc Dionne <marc.c.dionne@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lb0-f174.google.com ([209.85.217.174]:35332 "EHLO
	mail-lb0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756594AbcASQb0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 19 Jan 2016 11:31:26 -0500
Received: by mail-lb0-f174.google.com with SMTP id bc4so365700654lbc.2
        for <netdev@vger.kernel.org>; Tue, 19 Jan 2016 08:31:25 -0800 (PST)
In-Reply-To: <CAB9dFdswyri4-pDZ+uoAk00isP8Lba7-uqYPXnT=PnLataJeHg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 19, 2016 at 11:04 AM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
> Resent with correct address for Eric.
>
> On Tue, Jan 19, 2016 at 11:57 AM, Marc Dionne <marc.c.dionne@gmail.com> wrote:
>> I shared this one with Craig but I thought I'd put it out to a wider audience.
>>
>> Trying to run the current kernel mainline on a test system I found
>> that any attempt to run many of our executables would crash the
>> system.  The networking code in all of these opens and listens on
>> multiple UDP sockets set with SO_REUSEPORT.  We also like to bind the
>> first socket before setting SO_REUSEPORT so we can catch some cases
>> where the port is actually in use by someone else (for instance a
>> previous incarnation of the same service).
>>
>> This is easily reproduced with this sequence:
>> - create 2 sockets A and B
>> - bind socket A to an address
>> - set SO_REUSEPORT on socket A
>> - set SO_REUSEPORT on socket B
>> - bind socket B to the same address as A
>>
>> The sk_reuseport_cb structure is only allocated at bind time if
>> SO_REUSEPORT is already set, so A doesn't have one.  When we bind B, A
>> is found as a match that has SO_REUSEPORT and reuseport_add_sock will
>> try to use the NULL sk_reuseport_cb structure from A, causing a crash.
>>
>> Not sure what the best fix is, but seems like the structure could be
>> either allocated (if not already done) when setting SO_REUSEPORT, or
>> when we find it to be NULL in reuseport_add_sock (but locking may be
>> an issue there).  I was able to test that allocating sk_reuseport_cb
>> when setting SO_REUSEPORT makes things behave normally again; see
>> attached patch.  That's surely not a correct/complete fix as B (in the
>> scenario above) will have an unnecessary sk_reuseport_cb which will
>> trigger a warning and should be dealt with.
>>
>> Thanks,
>> Marc

There are really two issues here: The change in behavior of when you
can set SO_REUSEPORT on a bound socket and the NULL pointer
dereference race.

It's not completely safe to allocate the reuseport struct from the
setsockopt function.  Acquisition of the spin lock in reuseport_alloc
requires prior acquisition of the hlist lock for the socket (which
doesn't exist before bind).

Further, allocating this structure before bind means that it's
possible to associate two different BPF filters with two different
sockets and then try to bind them both to the same address.  This
means that the reuseport_add_sock function would need to decide to
pick between one of these two structures and get rid of the other.
There's currently a WARN_ON in that function which would complain
about this.  (the test program in
tools/testing/selftests/net/reuseport_bpf.c will trigger this warning
with your change).

I need to think about how to handle setsockopt-after-bind condition a
bit more, but the NULL pointer dereference is obviously wrong.  Do you
have a way to easily reproduce this?  I've only managed to get it to
happen once so far...
