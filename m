From: Dmitry Vyukov <dvyukov@google.com>
Subject: Re: [PATCH v3] net/irda: fix lockdep annotation
Date: Fri, 17 Feb 2017 22:13:58 +0100
Message-ID: <CACT4Y+ZTxUDsLo3TzXT9=op3e2iSMxtbPzpP0-22EUJqy1b3_Q@mail.gmail.com>
References: <20170116211052.46525-1-dvyukov@google.com> <20170117.151901.998994334183973013.davem@davemloft.net>
 <CACT4Y+Yx3wVAgxJRYKMOYM419NTSc9naSxUVfwCb21kjvAnF6Q@mail.gmail.com>
 <20170119.112736.1928027614533032571.davem@davemloft.net> <CACT4Y+Y+QQz59UbSW7K_NXKFPGt0FtVGvmTs0gm1aTAUyAGusA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Dave Jones <davej@redhat.com>, Samuel Ortiz <samuel@sortiz.org>,
        Alexander Potapenko <glider@google.com>,
        andreyknvl <andreyknvl@google.com>,
        netdev <netdev@vger.kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f41.google.com ([209.85.213.41]:33955 "EHLO
        mail-vk0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S932757AbdBQVOU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 17 Feb 2017 16:14:20 -0500
Received: by mail-vk0-f41.google.com with SMTP id r136so36370235vke.1
        for <netdev@vger.kernel.org>; Fri, 17 Feb 2017 13:14:19 -0800 (PST)
In-Reply-To: <CACT4Y+Y+QQz59UbSW7K_NXKFPGt0FtVGvmTs0gm1aTAUyAGusA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 20, 2017 at 11:53 PM, Dmitry Vyukov <dvyukov@google.com> wrote:
> On Thu, Jan 19, 2017 at 5:27 PM, David Miller <davem@davemloft.net> wrote:
>> From: Dmitry Vyukov <dvyukov@google.com>
>> Date: Thu, 19 Jan 2017 11:05:36 +0100
>>
>>> Thanks for looking into it! This particular issue bothers my fuzzers
>>> considerably. I agree that removing recursion is better.
>>> So do how we proceed? Will you mail this as a real patch?
>>
>> Someone needs to test this:
>
>
> I've stressed this with the fuzzer for a day.
> It gets rid of the lockdep warning, and I did not notice any other
> related crashes.
>
> Tested-by: Dmitry Vyukov <dvyukov@google.com>
>
> Thanks!


Hello David,

Have you merged this into some tree? Can't find it. If not, please
queue this for the next release.
This hurts us badly, but I don't want to turn off lockdep entirely.

Thanks

>> diff --git a/net/irda/irqueue.c b/net/irda/irqueue.c
>> index acbe61c..160dc89 100644
>> --- a/net/irda/irqueue.c
>> +++ b/net/irda/irqueue.c
>> @@ -383,9 +383,6 @@ EXPORT_SYMBOL(hashbin_new);
>>   *    for deallocating this structure if it's complex. If not the user can
>>   *    just supply kfree, which should take care of the job.
>>   */
>> -#ifdef CONFIG_LOCKDEP
>> -static int hashbin_lock_depth = 0;
>> -#endif
>>  int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
>>  {
>>         irda_queue_t* queue;
>> @@ -396,22 +393,27 @@ int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
>>         IRDA_ASSERT(hashbin->magic == HB_MAGIC, return -1;);
>>
>>         /* Synchronize */
>> -       if ( hashbin->hb_type & HB_LOCK ) {
>> -               spin_lock_irqsave_nested(&hashbin->hb_spinlock, flags,
>> -                                        hashbin_lock_depth++);
>> -       }
>> +       if (hashbin->hb_type & HB_LOCK)
>> +               spin_lock_irqsave(&hashbin->hb_spinlock, flags);
>>
>>         /*
>>          *  Free the entries in the hashbin, TODO: use hashbin_clear when
>>          *  it has been shown to work
>>          */
>>         for (i = 0; i < HASHBIN_SIZE; i ++ ) {
>> -               queue = dequeue_first((irda_queue_t**) &hashbin->hb_queue[i]);
>> -               while (queue ) {
>> -                       if (free_func)
>> -                               (*free_func)(queue);
>> -                       queue = dequeue_first(
>> -                               (irda_queue_t**) &hashbin->hb_queue[i]);
>> +               while (1) {
>> +                       queue = dequeue_first((irda_queue_t**) &hashbin->hb_queue[i]);
>> +
>> +                       if (!queue)
>> +                               break;
>> +
>> +                       if (free_func) {
>> +                               if (hashbin->hb_type & HB_LOCK)
>> +                                       spin_unlock_irqrestore(&hashbin->hb_spinlock, flags);
>> +                               free_func(queue);
>> +                               if (hashbin->hb_type & HB_LOCK)
>> +                                       spin_lock_irqsave(&hashbin->hb_spinlock, flags);
>> +                       }
>>                 }
>>         }
>>
>> @@ -420,12 +422,8 @@ int hashbin_delete( hashbin_t* hashbin, FREE_FUNC free_func)
>>         hashbin->magic = ~HB_MAGIC;
>>
>>         /* Release lock */
>> -       if ( hashbin->hb_type & HB_LOCK) {
>> +       if (hashbin->hb_type & HB_LOCK)
>>                 spin_unlock_irqrestore(&hashbin->hb_spinlock, flags);
>> -#ifdef CONFIG_LOCKDEP
>> -               hashbin_lock_depth--;
>> -#endif
>> -       }
>>
>>         /*
>>          *  Free the hashbin structure
