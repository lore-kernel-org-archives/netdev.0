From: ebiederm@xmission.com (Eric W. Biederman)
Subject: Re: [PATCH] fdtable: Avoid triggering OOMs from alloc_fdmem
Date: Tue, 04 Feb 2014 10:53:35 -0800
Message-ID: <878utqlnf4.fsf@xmission.com>
References: <87r47jsb2p.fsf@xmission.com>
	<CAHA+R7OLnrujsinNhwVvZyJDz+BrTxYmw0gWeSSyq+dJ2LF9qg@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: Andrew Morton <akpm@linux-foundation.org>,  "linux-kernel\@vger.kernel.org" <linux-kernel@vger.kernel.org>,  linux-fsdevel@vger.kernel.org,  netdev <netdev@vger.kernel.org>,  linux-mm@kvack.org
To: Cong Wang <cwang@twopensource.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <CAHA+R7OLnrujsinNhwVvZyJDz+BrTxYmw0gWeSSyq+dJ2LF9qg@mail.gmail.com>
	(Cong Wang's message of "Tue, 4 Feb 2014 10:25:33 -0800")
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

Cong Wang <cwang@twopensource.com> writes:

> On Mon, Feb 3, 2014 at 9:26 PM, Eric W. Biederman <ebiederm@xmission.com> wrote:
>> diff --git a/fs/file.c b/fs/file.c
>> index 771578b33fb6..db25c2bdfe46 100644
>> --- a/fs/file.c
>> +++ b/fs/file.c
>> @@ -34,7 +34,7 @@ static void *alloc_fdmem(size_t size)
>>          * vmalloc() if the allocation size will be considered "large" by the VM.
>>          */
>>         if (size <= (PAGE_SIZE << PAGE_ALLOC_COSTLY_ORDER)) {
>> -               void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN);
>> +               void *data = kmalloc(size, GFP_KERNEL|__GFP_NOWARN|__GFP_NORETRY);
>>                 if (data != NULL)
>>                         return data;
>>         }
>
> Or try again without __GFP_NORETRY like we do in nelink mmap?

I think I would much rather keep the current semantics of return -ENOMEM
and keep the problem localized then trigger a box wide OOM thank you
very much.


Retrying the kmalloc without __GFP_NORETRY is pointless.  If you are in
the unlikely 0.01% of the time when the kmalloc fails it is almost
certainly going to fail again.  Writing out_of_memory() as kmalloc()
is pointless and very confusing.

The vmalloc won't fail unless you are on a 32bit box.  So it isn't a
case that anyone has to deal with in practice.

Eric

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
