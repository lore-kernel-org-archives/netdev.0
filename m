From: Eric Dumazet <edumazet@google.com>
Subject: Re: possible memory leak in ipc
Date: Fri, 26 Aug 2016 08:41:19 -0700
Message-ID: <CANn89iJ606XRvmUhiODgXY5240ffBsak_6-rhZsnQhRyLFD4MA@mail.gmail.com>
References: <544270328.2536943.1472154674747.JavaMail.zimbra@redhat.com>
 <1474737839.2538727.1472155133819.JavaMail.zimbra@redhat.com>
 <CANn89iL3J6nTbNRm215xv2LL_6SjoPV-XtUJq7Ka_7pFsuAg0g@mail.gmail.com>
 <2107409749.2541400.1472156272168.JavaMail.zimbra@redhat.com>
 <CA+55aFwFatFWpW3UfT9mUizDTAoFueiCGTUuM-t85orDWN+pvg@mail.gmail.com> <364510660.2709914.1472225156558.JavaMail.zimbra@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
        Thomas Graf <tgraf@suug.ch>,
        Herbert Xu <herbert@gondor.apana.org.au>,
        Network Development <netdev@vger.kernel.org>
To: CAI Qian <caiqian@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yb0-f182.google.com ([209.85.213.182]:35196 "EHLO
        mail-yb0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1754217AbcHZPl0 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 26 Aug 2016 11:41:26 -0400
Received: by mail-yb0-f182.google.com with SMTP id h3so7132939ybi.2
        for <netdev@vger.kernel.org>; Fri, 26 Aug 2016 08:41:25 -0700 (PDT)
In-Reply-To: <364510660.2709914.1472225156558.JavaMail.zimbra@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Aug 26, 2016 at 8:25 AM, CAI Qian <caiqian@redhat.com> wrote:
>
>
> ----- Original Message -----
>> From: "Linus Torvalds" <torvalds@linux-foundation.org>
>> To: "CAI Qian" <caiqian@redhat.com>, "Thomas Graf" <tgraf@suug.ch>, "Herbert Xu" <herbert@gondor.apana.org.au>
>> Cc: "Eric Dumazet" <edumazet@google.com>, "Network Development" <netdev@vger.kernel.org>
>> Sent: Thursday, August 25, 2016 6:20:03 PM
>> Subject: Re: possible memory leak in ipc
>>
>> On Thu, Aug 25, 2016 at 1:17 PM, CAI Qian <caiqian@redhat.com> wrote:
>> > I am unsure if it is really a memleak (could be a security issue due to
>> > eventually OOM and DoS) or just a soft lockup with in kmemlock code with
>> > false alarm.
>>
>> Hmm. The reported leaks look like
>>
>> unreferenced object 0xffffc90004857000 (size 4608):
>>   comm "kworker/16:0", pid 110, jiffies 4294705908 (age 883.925s)
>>   hex dump (first 32 bytes):
>>     c0 05 3d 5e 08 88 ff ff ff ff ff ff 00 00 dc 6e  ..=^...........n
>>     ff ff ff ff ff ff ff ff 28 c7 46 83 ff ff ff ff  ........(.F.....
>>   backtrace:
>>     [<ffffffff817d95ba>] kmemleak_alloc+0x4a/0xa0
>>     [<ffffffff8123df4e>] __vmalloc_node_range+0x1de/0x2f0
>>     [<ffffffff8123e324>] vmalloc+0x54/0x60
>>     [<ffffffff81404934>] alloc_bucket_locks.isra.7+0xd4/0xf0
>>     [<ffffffff814049a8>] bucket_table_alloc+0x58/0x100
>>     [<ffffffff8140538e>] rht_deferred_worker+0x10e/0x890
>>     [<ffffffff810c30a8>] process_one_work+0x218/0x750
>>     [<ffffffff810c3705>] worker_thread+0x125/0x4a0
>>     [<ffffffff810ca8b1>] kthread+0x101/0x120
>>     [<ffffffff817e70af>] ret_from_fork+0x1f/0x40
>>     [<ffffffffffffffff>] 0xffffffffffffffff
>>
>> which would indicate that it's a rhashtable resize event where we
>> perhaps haven't free'd the old hash table when we create a new one.
>>
>> The actually freeing of the old one is done RCU-deferred from
>> rhashtable_rehash_table(), but that itself is also deferred by a
>> worker thread (rht_deferred_worker).
>>
>> I'm not seeing anything wrong in the logic, but let's bring in Thomas
>> Graf and Herbert Xu.
>

There is a trivial bug in alloc_bucket_locks()
I will send a patch.

Thanks.
