From: Eric Dumazet <edumazet@google.com>
Subject: Re: [PATCH net-next] tcp: Revert "tcp: tcp_probe: use spin_lock_bh()"
Date: Tue, 21 Feb 2017 10:46:22 -0800
Message-ID: <CANn89iJzorQ85TTirOEsoWvVoyS-1jhahvQ873Tp38gEG-rVdA@mail.gmail.com>
References: <20170221142147.19154-1-edumazet@google.com> <20170221.132647.1720616047649729612.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: netdev <netdev@vger.kernel.org>,
        Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
To: David Miller <davem@davemloft.net>,
        Peter Zijlstra <peterz@infradead.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-it0-f46.google.com ([209.85.214.46]:36395 "EHLO
        mail-it0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753597AbdBUSq0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 21 Feb 2017 13:46:26 -0500
Received: by mail-it0-f46.google.com with SMTP id h10so114815213ith.1
        for <netdev@vger.kernel.org>; Tue, 21 Feb 2017 10:46:25 -0800 (PST)
In-Reply-To: <20170221.132647.1720616047649729612.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Feb 21, 2017 at 10:26 AM, David Miller <davem@davemloft.net> wrote:
> From: Eric Dumazet <edumazet@google.com>
> Date: Tue, 21 Feb 2017 06:21:47 -0800
>
>> This reverts commit e70ac171658679ecf6bea4bbd9e9325cd6079d2b.
>>
>> jtcp_rcv_established() is in fact called with hard irq being disabled.
>>
>> Initial bug report from Ricardo Nabinger Sanchez [1] still needs
>> to be investigated, but does not look like a TCP bug.
>>
>> [1] https://www.spinics.net/lists/netdev/msg420960.html
>>
>> Signed-off-by: Eric Dumazet <edumazet@google.com>
>> Reported-by: kernel test robot <xiaolong.ye@intel.com>
>> Cc: Ricardo Nabinger Sanchez <rnsanchez@gmail.com>
>
> Applied.
>
> But your analysis was quite sound, we can now invoke TCP input path
> from user context, therefore this jprobe needs to use BH locking.  What
> is the problem.


If hard irq are masked, then using spin_lock() should work without a
lockdep splat.

The problem here is some false positive, as if one
trace_hardirqs_off() was missing.

Peter originally fixed the issue back in this commit :

commit 58dfe883d3bc3b4c08c53a7f39e2ca3ec84f089e
Author: Peter Zijlstra <a.p.zijlstra@chello.nl>
Date:   Thu Oct 11 22:25:25 2007 +0200

So really I have no idea what is happening, because the
trace_hardirqs_off() is still in x86 setjmp_pre_handler()

Maybe some FTRACE interaction ?
