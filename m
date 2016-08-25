From: Linus Torvalds <torvalds@linux-foundation.org>
Subject: Re: possible memory leak in ipc
Date: Thu, 25 Aug 2016 15:20:03 -0700
Message-ID: <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
 <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
 <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com> <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>
To: CAI Qian <caiqian@redhat.com>, Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f42.google.com ([209.85.218.42]:35416 "EHLO
        mail-oi0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753696AbcHYWUF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 25 Aug 2016 18:20:05 -0400
Received: by mail-oi0-f42.google.com with SMTP id 4so87214124oih.2
        for <netdev@vger.kernel.org>; Thu, 25 Aug 2016 15:20:05 -0700 (PDT)
In-Reply-To: <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Aug 25, 2016 at 1:17 PM, CAI Qian <caiqian@redhat.com> wrote:
> I am unsure if it is really a memleak (could be a security issue due to
> eventually OOM and DoS) or just a soft lockup with in kmemlock code with
> false alarm.

Hmm. The reported leaks look like

unreferenced object 0xffffc90004857000 (size 4608):
  comm "kworker/16:0", pid 110, jiffies 4294705908 (age 883.925s)
  hex dump (first 32 bytes):
    c0 05 3d 5e 08 88 ff ff ff ff ff ff 00 00 dc 6e  ..=^...........n
    ff ff ff ff ff ff ff ff 28 c7 46 83 ff ff ff ff  ........(.F.....
  backtrace:
    [<ffffffff817d95ba>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff8123df4e>] __vmalloc_node_range+0x1de/0x2f0
    [<ffffffff8123e324>] vmalloc+0x54/0x60
    [<ffffffff81404934>] alloc_bucket_locks.isra.7+0xd4/0xf0
    [<ffffffff814049a8>] bucket_table_alloc+0x58/0x100
    [<ffffffff8140538e>] rht_deferred_worker+0x10e/0x890
    [<ffffffff810c30a8>] process_one_work+0x218/0x750
    [<ffffffff810c3705>] worker_thread+0x125/0x4a0
    [<ffffffff810ca8b1>] kthread+0x101/0x120
    [<ffffffff817e70af>] ret_from_fork+0x1f/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff

which would indicate that it's a rhashtable resize event where we
perhaps haven't free'd the old hash table when we create a new one.

The actually freeing of the old one is done RCU-deferred from
rhashtable_rehash_table(), but that itself is also deferred by a
worker thread (rht_deferred_worker).

I'm not seeing anything wrong in the logic, but let's bring in Thomas
Graf and Herbert Xu.

Hmm. The size (4608) is always the same and doesn't change, so maybe
it's not actually a rehash events per se - it's somebody creating a
rhashtable, but perhaps not freeing it?

Sadly, all but one of the traces are that kthread one, and the one
that isn't that might give an idea about what code triggers this is:

unreferenced object 0xffffc900048b6000 (size 4608):
  comm "modprobe", pid 2485, jiffies 4294727633 (age 862.590s)
  hex dump (first 32 bytes):
    00 9c 49 21 00 ea ff ff 00 d5 59 21 00 ea ff ff  ..I!......Y!....
    00 a5 7d 21 00 ea ff ff c0 da 74 21 00 ea ff ff  ..}!......t!....
  backtrace:
    [<ffffffff817d95ba>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff8123df4e>] __vmalloc_node_range+0x1de/0x2f0
    [<ffffffff8123e324>] vmalloc+0x54/0x60
    [<ffffffff81404934>] alloc_bucket_locks.isra.7+0xd4/0xf0
    [<ffffffff814049a8>] bucket_table_alloc+0x58/0x100
    [<ffffffff81404d8d>] rhashtable_init+0x1ed/0x390
    [<ffffffffa05b201b>] 0xffffffffa05b201b
    [<ffffffff81002190>] do_one_initcall+0x50/0x190
    [<ffffffff811e6eed>] do_init_module+0x60/0x1f3
    [<ffffffff81155107>] load_module+0x1487/0x1ca0
    [<ffffffff81155b56>] SYSC_finit_module+0xa6/0xf0
    [<ffffffff81155bbe>] SyS_finit_module+0xe/0x10
    [<ffffffff81003c4c>] do_syscall_64+0x6c/0x1e0
    [<ffffffff817e6f3f>] return_from_SYSCALL_64+0x0/0x7a
    [<ffffffffffffffff>] 0xffffffffffffffff

so it comes from some module init code, but since the module hasn't
fully initialized, the kallsym code doesn't find the symbol name
either. Annoying.

Maybe the above just makes one of the rhashtable people go "Oh, that's
obvious".

                 Linus
