From: Craig Gallek <kraigatgoog@gmail.com>
Subject: Re: [PATCH 1/1] net: Add SO_REUSEPORT_LISTEN_OFF socket option as
 drain mode
Date: Fri, 25 Mar 2016 12:31:48 -0400
Message-ID: <CAEfhGiy-V0da6LQ_SY+E4u7S49n5dEpVaKiOOo103ijQtPujAw@mail.gmail.com>
References: <CAEfhGizvwATcG--OH_xhrV-c1t11ie-vNibJY8kqFAq3GX9upw@mail.gmail.com>
	<20160325162114.GA72479@ast-mbp.thefacebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Alexei Starovoitov <alexei.starovoitov@gmail.com>
To: Linux Kernel Network Developers <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-lf0-f68.google.com ([209.85.215.68]:34996 "EHLO
	mail-lf0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753595AbcCYQbw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 25 Mar 2016 12:31:52 -0400
Received: by mail-lf0-f68.google.com with SMTP id c62so3614242lfc.2
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 09:31:51 -0700 (PDT)
Received: from mail-lf0-f50.google.com (mail-lf0-f50.google.com. [209.85.215.50])
        by smtp.gmail.com with ESMTPSA id g14sm2021594lfb.8.2016.03.25.09.31.49
        for <netdev@vger.kernel.org>
        (version=TLS1_2 cipher=ECDHE-RSA-AES128-GCM-SHA256 bits=128/128);
        Fri, 25 Mar 2016 09:31:49 -0700 (PDT)
Received: by mail-lf0-f50.google.com with SMTP id q73so55405880lfe.2
        for <netdev@vger.kernel.org>; Fri, 25 Mar 2016 09:31:49 -0700 (PDT)
In-Reply-To: <20160325162114.GA72479@ast-mbp.thefacebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Mar 25, 2016 at 12:21 PM, Alexei Starovoitov
<alexei.starovoitov@gmail.com> wrote:
> On Fri, Mar 25, 2016 at 11:29:10AM -0400, Craig Gallek wrote:
>> On Thu, Mar 24, 2016 at 2:00 PM, Willy Tarreau <w@1wt.eu> wrote:
>> > The pattern is :
>> >
>> >   t0 : unprivileged processes 1 and 2 are listening to the same port
>> >        (sock1@pid1) (sock2@pid2)
>> >        <------ listening ------>
>> >
>> >   t1 : new processes are started to replace the old ones
>> >        (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
>> >        <------ listening ------> <------ listening ------>
>> >
>> >   t2 : new processes signal the old ones they must stop
>> >        (sock1@pid1) (sock2@pid2) (sock3@pid3) (sock4@pid4)
>> >        <------- draining ------> <------ listening ------>
>> >
>> >   t3 : pids 1 and 2 have finished, they go away
>> >                                  (sock3@pid3) (sock4@pid4)
>> >         <------ gone ----->      <------ listening ------>
> ...
>> t3: Close the first two sockets and only use the last two.  This is
>> the tricky step.  Before this point, the sockets are numbered 0
>> through 3 from the perspective of the BPF program (in the order
>> listen() was called).  As soon as socket 0 is closed, the last socket
>> in the list replaces it (what was 3 becomes 0).  When socket 1 is
>> closed, socket 2 moves into that position.  The assumptions about the
>> socket indexes in the BPF program need to change as the indexes change
>> as a result of closing them.
>
> yeah, the way reuseport_detach_sock() was done makes it hard to manage
> such transitions from bpf program, but I don't see yet what stops
> pid1 an pid2 at stage t2 to just close their sockets.
> If these 'draining' pids don't want to receive packets, they should
> close their sockets. Complicating bpf side to redistribute spraying
> to sock3 and sock4 only (while sock1 and sock2 are still open) is possible,
> but looks unnecessary complex to me.
> Just close sock1 and sock2 at t2 time and then exit pid1, pid2 later.
> If they are tcp sockets with rpc protocol on top and have a problem of
> partial messages, then kcm can solve that and it will simplify
> the user space side as well.
I believe the issue here is that closing the listen sockets will drop
any connections that are in the listen queue but have not been
accepted yet.  In the case of reuseport, you could in theory drain
those queues into the non-closed sockets, but that probably has some
interesting consequences...
