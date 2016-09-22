From: Vlastimil Babka <vbabka@suse.cz>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Thu, 22 Sep 2016 19:55:09 +0200
Message-ID: <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro@zeniv.linux.org.uk>,
 Andrew Morton <akpm@linux-foundation.org>, linux-fsdevel@vger.kernel.org,
 linux-kernel@vger.kernel.org, linux-mm@kvack.org,
 Michal Hocko <mhocko@kernel.org>, netdev@vger.kernel.org,
 Linux API <linux-api@vger.kernel.org>, linux-man@vger.kernel.org
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <owner-linux-mm@kvack.org>
In-Reply-To: <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
Sender: owner-linux-mm@kvack.org
List-Id: netdev.vger.kernel.org

On 09/22/2016 07:07 PM, Eric Dumazet wrote:
> On Thu, 2016-09-22 at 18:56 +0200, Vlastimil Babka wrote:
>> On 09/22/2016 06:49 PM, Eric Dumazet wrote:
>> > On Thu, 2016-09-22 at 18:43 +0200, Vlastimil Babka wrote:
>> >> The select(2) syscall performs a kmalloc(size, GFP_KERNEL) where size grows
>> >> with the number of fds passed. We had a customer report page allocation
>> >> failures of order-4 for this allocation. This is a costly order, so it might
>> >> easily fail, as the VM expects such allocation to have a lower-order fallback.
>> >>
>> >> Such trivial fallback is vmalloc(), as the memory doesn't have to be
>> >> physically contiguous. Also the allocation is temporary for the duration of the
>> >> syscall, so it's unlikely to stress vmalloc too much.
>> >
>> > vmalloc() uses a vmap_area_lock spinlock, and TLB flushes.
>> >
>> > So I guess allowing vmalloc() being called from an innocent application
>> > doing a select() might be dangerous, especially if this select() happens
>> > thousands of time per second.
>>
>> Isn't seq_buf_alloc() similarly exposed? And ipc_alloc()?
>
> Possibly.
>
> We don't have a library function (attempting kmalloc(), fallback to
> vmalloc() presumably to avoid abuses, but I guess some patches were
> accepted without thinking about this.

So in the case of select() it seems like the memory we need 6 bits per file 
descriptor, multiplied by the highest possible file descriptor (nfds) as passed 
to the syscall. According to the man page of select:

        EINVAL nfds is negative or exceeds the RLIMIT_NOFILE resource limit (see 
getrlimit(2)).

The code actually seems to silently cap the value instead of returning EINVAL 
though? (IIUC):

        /* max_fds can increase, so grab it once to avoid race */
         rcu_read_lock();
         fdt = files_fdtable(current->files);
         max_fds = fdt->max_fds;
         rcu_read_unlock();
         if (n > max_fds)
                 n = max_fds;

The default for this cap seems to be 1024 where I checked (again, IIUC, it's 
what ulimit -n returns?). I wasn't able to change it to more than 2048, which 
makes the bitmaps still below PAGE_SIZE.

So if I get that right, the system admin would have to allow really large 
RLIMIT_NOFILE to even make vmalloc() possible here. So I don't see it as a large 
concern?

Vlastimil

--
To unsubscribe, send a message with 'unsubscribe linux-mm' in
the body to majordomo@kvack.org.  For more info on Linux MM,
see: http://www.linux-mm.org/ .
Don't email: <a href=mailto:"dont@kvack.org"> email@kvack.org </a>
