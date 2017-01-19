From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH v3] net/irda: fix lockdep annotation
Date: Thu, 19 Jan 2017 11:05:36 +0100
Message-ID: <CACT4Y+Yx3wVAgxJRYKMOYM419NTSc9naSxUVfwCb21kjvAnF6Q@mail.gmail.com>
References: <20170116211052.46525-1-dvyukov@google.com> <20170117.151901.998994334183973013.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dave Jones <davej@redhat.com>, Samuel Ortiz <samuel@sortiz.org>,
        Alexander Potapenko <glider@google.com>,
        andreyknvl <andreyknvl@google.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ua0-f172.google.com ([209.85.217.172]:35126 "EHLO
        mail-ua0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751252AbdASKF5 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 19 Jan 2017 05:05:57 -0500
Received: by mail-ua0-f172.google.com with SMTP id y9so29876426uae.2
        for <netdev@vger.kernel.org>; Thu, 19 Jan 2017 02:05:57 -0800 (PST)
In-Reply-To: <20170117.151901.998994334183973013.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Jan 17, 2017 at 9:19 PM, David Miller <davem@davemloft.net> wrote:
> From: Dmitry Vyukov <dvyukov@google.com>
> Date: Mon, 16 Jan 2017 22:10:52 +0100
>
>> The current annotation uses a global variable as recursion counter.
>> The variable is not atomic nor protected with a mutex, but mutated
>> by multiple threads. This causes lockdep bug reports episodically:
>>
>> BUG: looking up invalid subclass: 4294967295
>> ...
>> _raw_spin_lock_irqsave_nested+0x120/0x180
>> hashbin_delete+0x4fe/0x750
>> __irias_delete_object+0xab/0x170
>> irias_delete_object+0x5f/0xc0
>> ircomm_tty_detach_cable+0x1d5/0x3f0
>> ...
>>
>> Make the hashbin_lock_depth variable atomic to prevent bug reports.
>>
>> As is this causes "unused variable 'depth'" warning without LOCKDEP.
>> So also change raw_spin_lock_irqsave_nested() macro to not cause
>> the warning without LOCKDEP. Similar to what raw_spin_lock_nested()
>> already does.
>>
>> Signed-off-by: Dmitry Vyukov <dvyukov@google.com>
>> Cc: Dave Jones <davej@redhat.com>
>> Cc: Samuel Ortiz <samuel@sortiz.org>
>> Cc: David S. Miller <davem@davemloft.net>
>> Cc: netdev@vger.kernel.org
>> Fixes: c7630a4b932af ("[IrDA]: irda lockdep annotation")
>
> I took a closer look at this, and really this whole lockdep thing is
> more than a hack.
>
> The basic problem is that the free_func() passed into hashbin_delete()
> can trigger hashbin operations on other hashtables.
>
> This function is destroying a hash table completely, and is doing so
> in a context where no new hash table entries can be inserted.  The
> last thing we do is kfree() the hashtable so this must be true.
>
> Therefore, it is much better to just kill off all of this lockdep
> stuff, and recode the teardown loop into something like:
>
>         if (hashbin->hb_type & HB_LOCK)
>                 spin_lock_irqsave(&hashbin->hb_lock, flags);
>         for (i = 0; i < HASHBIN_SIZE; i++) {
>                 while (1) {
>                         queue = dequeue_first((irda_queue_t **) &hashbin->hb_queue[i]);
>
>                         if (!queue)
>                                 break;
>                         if (free_func) {
>                                 if (hashbin->hb_type & HB_LOCK)
>                                         spin_unlock_irqrestore(&hashbin->hb_lock, flags);
>                                 free_func(queue);
>                                 if (hashbin->hb_type & HB_LOCK)
>                                         spin_lock_irqsave(&hashbin->hb_lock, flags);
>                         }
>
>                 }
>         }
>         hashbin->hb_current = NULL;
>         hashbin->magic = ~HB_MAGIC;
>         if (hashbin->hb_type & HB_LOCK)
>                 spin_unlock_irqrestore(&hashbin->hb_lock, flags);
>
> At which point the recursive locking becomes impossible.


Thanks for looking into it! This particular issue bothers my fuzzers
considerably. I agree that removing recursion is better.
So do how we proceed? Will you mail this as a real patch?
