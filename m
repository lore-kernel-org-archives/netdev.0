From: CAI Qian <caiqian@redhat.com>
Subject: Re: possible memory leak in ipc
Date: Fri, 26 Aug 2016 11:25:56 -0400 (EDT)
Message-ID: <364510660.2709914.1472225156558.JavaMail.zimbra@redhat.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com> <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com> <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com> <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com> <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Eric Dumazet <edumazet@google.com>,
        Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx5-phx2.redhat.com ([209.132.183.37]:42356 "EHLO
        mx5-phx2.redhat.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750715AbcHZP1d (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 11:27:33 -0400
In-Reply-To: <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



----- Original Message -----
> From: "Linus Torvalds" <torvalds@linux-foundation.org>
> To: "CAI Qian" <caiqian@redhat.com>, "Thomas Graf" <tgraf@suug.ch>, "Herbert Xu" <herbert@gondor.apana.org.au>
> Cc: "Eric Dumazet" <edumazet@google.com>, "Network Development" <netdev@vger.kernel.org>
> Sent: Thursday, August 25, 2016 6:20:03 PM
> Subject: Re: possible memory leak in ipc
> 
> On Thu, Aug 25, 2016 at 1:17 PM, CAI Qian <caiqian@redhat.com> wrote:
> > I am unsure if it is really a memleak (could be a security issue due to
> > eventually OOM and DoS) or just a soft lockup with in kmemlock code with
> > false alarm.
> 
> Hmm. The reported leaks look like
> 
> unreferenced object 0xffffc90004857000 (size 4608):
>   comm "kworker/16:0", pid 110, jiffies 4294705908 (age 883.925s)
>   hex dump (first 32 bytes):
>     c0 05 3d 5e 08 88 ff ff ff ff ff ff 00 00 dc 6e  ..=^...........n
>     ff ff ff ff ff ff ff ff 28 c7 46 83 ff ff ff ff  ........(.F.....
>   backtrace:
>     [<ffffffff817d95ba>] kmemleak_alloc+0x4a/0xa0
>     [<ffffffff8123df4e>] __vmalloc_node_range+0x1de/0x2f0
>     [<ffffffff8123e324>] vmalloc+0x54/0x60
>     [<ffffffff81404934>] alloc_bucket_locks.isra.7+0xd4/0xf0
>     [<ffffffff814049a8>] bucket_table_alloc+0x58/0x100
>     [<ffffffff8140538e>] rht_deferred_worker+0x10e/0x890
>     [<ffffffff810c30a8>] process_one_work+0x218/0x750
>     [<ffffffff810c3705>] worker_thread+0x125/0x4a0
>     [<ffffffff810ca8b1>] kthread+0x101/0x120
>     [<ffffffff817e70af>] ret_from_fork+0x1f/0x40
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> which would indicate that it's a rhashtable resize event where we
> perhaps haven't free'd the old hash table when we create a new one.
> 
> The actually freeing of the old one is done RCU-deferred from
> rhashtable_rehash_table(), but that itself is also deferred by a
> worker thread (rht_deferred_worker).
> 
> I'm not seeing anything wrong in the logic, but let's bring in Thomas
> Graf and Herbert Xu.
> 
> Hmm. The size (4608) is always the same and doesn't change, so maybe
> it's not actually a rehash events per se - it's somebody creating a
> rhashtable, but perhaps not freeing it?
> 
> Sadly, all but one of the traces are that kthread one, and the one
> that isn't that might give an idea about what code triggers this is:
> 
> unreferenced object 0xffffc900048b6000 (size 4608):
>   comm "modprobe", pid 2485, jiffies 4294727633 (age 862.590s)
>   hex dump (first 32 bytes):
>     00 9c 49 21 00 ea ff ff 00 d5 59 21 00 ea ff ff  ..I!......Y!....
>     00 a5 7d 21 00 ea ff ff c0 da 74 21 00 ea ff ff  ..}!......t!....
>   backtrace:
>     [<ffffffff817d95ba>] kmemleak_alloc+0x4a/0xa0
>     [<ffffffff8123df4e>] __vmalloc_node_range+0x1de/0x2f0
>     [<ffffffff8123e324>] vmalloc+0x54/0x60
>     [<ffffffff81404934>] alloc_bucket_locks.isra.7+0xd4/0xf0
>     [<ffffffff814049a8>] bucket_table_alloc+0x58/0x100
>     [<ffffffff81404d8d>] rhashtable_init+0x1ed/0x390
>     [<ffffffffa05b201b>] 0xffffffffa05b201b
>     [<ffffffff81002190>] do_one_initcall+0x50/0x190
>     [<ffffffff811e6eed>] do_init_module+0x60/0x1f3
>     [<ffffffff81155107>] load_module+0x1487/0x1ca0
>     [<ffffffff81155b56>] SYSC_finit_module+0xa6/0xf0
>     [<ffffffff81155bbe>] SyS_finit_module+0xe/0x10
>     [<ffffffff81003c4c>] do_syscall_64+0x6c/0x1e0
>     [<ffffffff817e6f3f>] return_from_SYSCALL_64+0x0/0x7a
>     [<ffffffffffffffff>] 0xffffffffffffffff
> 
> so it comes from some module init code, but since the module hasn't
> fully initialized, the kallsym code doesn't find the symbol name
> either. Annoying.
> 
> Maybe the above just makes one of the rhashtable people go "Oh, that's
> obvious".
> 
>                  Linus
> 
FYI, this also happened while compiling gcc.
$ make -j 56

$ cat /sys/kernel/debug/kmemleak
unreferenced object 0xffffc9000485a000 (size 4608):
  comm "kworker/7:1", pid 368, jiffies 4294835499 (age 1033.075s)
  hex dump (first 32 bytes):
    5f 65 76 65 6e 74 5f 69 74 65 6d 2e 68 00 05 00  _event_item.h...
    00 76 6d 73 74 61 74 2e 68 00 05 00 00 70 6c 69  .vmstat.h....pli
  backtrace:
    [<ffffffff8268aa6a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff815e4d78>] __vmalloc_node_range+0x378/0x700
    [<ffffffff815e51a4>] vmalloc+0x54/0x60
    [<ffffffff81ab48c8>] alloc_bucket_locks.isra.7+0x188/0x220
    [<ffffffff81ab4a0c>] bucket_table_alloc+0xac/0x290
    [<ffffffff81ab6955>] rht_deferred_worker+0x8c5/0x1890
    [<ffffffff811ee711>] process_one_work+0x731/0x16c0
    [<ffffffff811ef77c>] worker_thread+0xdc/0xf10
    [<ffffffff81201be3>] kthread+0x223/0x2f0
    [<ffffffff8269e82f>] ret_from_fork+0x1f/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffc90004861000 (size 4608):
  comm "kworker/10:1", pid 380, jiffies 4294843418 (age 1025.169s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff8268aa6a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff815e4d78>] __vmalloc_node_range+0x378/0x700
    [<ffffffff815e51a4>] vmalloc+0x54/0x60
    [<ffffffff81ab48c8>] alloc_bucket_locks.isra.7+0x188/0x220
    [<ffffffff81ab4a0c>] bucket_table_alloc+0xac/0x290
    [<ffffffff81ab7664>] rht_deferred_worker+0x15d4/0x1890
    [<ffffffff811ee711>] process_one_work+0x731/0x16c0
    [<ffffffff811ef77c>] worker_thread+0xdc/0xf10
    [<ffffffff81201be3>] kthread+0x223/0x2f0
    [<ffffffff8269e82f>] ret_from_fork+0x1f/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffc90004864000 (size 4608):
  comm "kworker/27:0", pid 176, jiffies 4294866756 (age 1002.065s)
  hex dump (first 32 bytes):
    83 e0 07 83 c0 03 38 d0 7c 08 84 d2 0f 85 00 15  ......8.|.......
    00 00 48 8b 85 f0 fe ff ff 45 85 e4 8b 40 4c 74  ..H......E...@Lt
  backtrace:
    [<ffffffff8268aa6a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff815e4d78>] __vmalloc_node_range+0x378/0x700
    [<ffffffff815e51a4>] vmalloc+0x54/0x60
    [<ffffffff81ab48c8>] alloc_bucket_locks.isra.7+0x188/0x220
    [<ffffffff81ab4a0c>] bucket_table_alloc+0xac/0x290
    [<ffffffff81ab6955>] rht_deferred_worker+0x8c5/0x1890
    [<ffffffff811ee711>] process_one_work+0x731/0x16c0
    [<ffffffff811ef77c>] worker_thread+0xdc/0xf10
    [<ffffffff81201be3>] kthread+0x223/0x2f0
    [<ffffffff8269e82f>] ret_from_fork+0x1f/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffc9000486a000 (size 4608):
  comm "kworker/3:1", pid 365, jiffies 4294867142 (age 1001.782s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    10 10 d2 2a 04 88 ff ff 10 10 d2 2a 04 88 ff ff  ...*.......*....
  backtrace:
    [<ffffffff8268aa6a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff815e4d78>] __vmalloc_node_range+0x378/0x700
    [<ffffffff815e51a4>] vmalloc+0x54/0x60
    [<ffffffff81ab48c8>] alloc_bucket_locks.isra.7+0x188/0x220
    [<ffffffff81ab4a0c>] bucket_table_alloc+0xac/0x290
    [<ffffffff81ab6955>] rht_deferred_worker+0x8c5/0x1890
    [<ffffffff811ee711>] process_one_work+0x731/0x16c0
    [<ffffffff811ef77c>] worker_thread+0xdc/0xf10
    [<ffffffff81201be3>] kthread+0x223/0x2f0
    [<ffffffff8269e82f>] ret_from_fork+0x1f/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffffc90004a71000 (size 4608):
  comm "kworker/16:1", pid 376, jiffies 4294891121 (age 977.869s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 fe 01 00 00  ................
    00 98 c3 1c 00 ea ff ff 40 9a c3 1c 00 ea ff ff  ........@.......
  backtrace:
    [<ffffffff8268aa6a>] kmemleak_alloc+0x4a/0xa0
    [<ffffffff815e4d78>] __vmalloc_node_range+0x378/0x700
    [<ffffffff815e51a4>] vmalloc+0x54/0x60
    [<ffffffff81ab48c8>] alloc_bucket_locks.isra.7+0x188/0x220
    [<ffffffff81ab4a0c>] bucket_table_alloc+0xac/0x290
    [<ffffffff81ab7664>] rht_deferred_worker+0x15d4/0x1890
    [<ffffffff811ee711>] process_one_work+0x731/0x16c0
    [<ffffffff811ef77c>] worker_thread+0xdc/0xf10
    [<ffffffff81201be3>] kthread+0x223/0x2f0
    [<ffffffff8269e82f>] ret_from_fork+0x1f/0x40
    [<ffffffffffffffff>] 0xffffffffffffffff
