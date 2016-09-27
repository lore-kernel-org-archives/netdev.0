From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Tue, 27 Sep 2016 10:06:24 +0200
Message-ID: <91be8fd4-6600-d58d-d77a-d06ebed79f7e@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=windows-1252; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org,
 Eric Dumazet <eric.dumazet@gmail.com>
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <20160926170105.517f74cd67ecdd5ef73e1865@linux-foundation.org>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 09/27/2016 02:01 AM, Andrew Morton wrote:
> On Thu, 22 Sep 2016 18:43:59 +0200 Vlastimil Babka <vbabka@suse.cz> wrote:
>
>> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>> with the number of fds passed. We had a customer report page allocation
>> failures of order-4 for this allocation. This is a costly order, so it might
>> easily fail, as the VM expects such allocation to have a lower-order fallback.
>>
>> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>> physically contiguous. Also the allocation is temporary for the duration of the
>> syscall, so it's unlikely to stress vmalloc too much.
>>
>> Note that the poll(2) syscall seems to use a linked list of order-0 pages, so
>> it doesn't need this kind of fallback.
>>
>> ...
>>
>> --- a/fs/select.c
>> +++ b/fs/select.c
>> @@ -29,6 +29,7 @@
>>  #include <linux/sched/rt.h>
>>  #include <linux/freezer.h>
>>  #include <net/busy_poll.h>
>> +#include <linux/vmalloc.h>
>>
>>  #include <asm/uaccess.h>
>>
>> @@ -558,6 +559,7 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>>  	struct fdtable *fdt;
>>  	/* Allocate small arguments on the stack to save memory and be faster */
>>  	long stack_fds[SELECT_STACK_ALLOC/sizeof(long)];
>> +	unsigned long alloc_size;
>>
>>  	ret = -EINVAL;
>>  	if (n < 0)
>> @@ -580,8 +582,12 @@ int core_sys_select(int n, fd_set __user *inp, fd_set __user *outp,
>>  	bits = stack_fds;
>>  	if (size > sizeof(stack_fds) / 6) {
>>  		/* Not enough space in on-stack array; must use kmalloc */
>> +		alloc_size = 6 * size;
>
> Well.  `size' is `unsigned'.  The multiplication will be done as 32-bit
> so there was no point in making `alloc_size' unsigned long.

Uh, right. Thanks.

> So can we tighten up the types in this function?  size_t might make
> sense, but vmalloc() takes a ulong.

Let's do size_t then, as the conversion to ulong is safe.


--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
