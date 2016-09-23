From: Vlastimil Babka <vbabka-AlSwsSmVLrQ@public.gmane.org>
Subject: Re: [PATCH v2] fs/select: add vmalloc fallback for select(2)
Date: Fri, 23 Sep 2016 11:58:34 +0200
Message-ID: <3bbcc269-ec8b-12dd-e0ae-190c18bc3f47@suse.cz>
References: <20160922164359.9035-1-vbabka@suse.cz>
 <1474562982.23058.140.camel@edumazet-glaptop3.roam.corp.google.com>
 <12efc491-a0e7-1012-5a8b-6d3533c720db@suse.cz>
 <1474564068.23058.144.camel@edumazet-glaptop3.roam.corp.google.com>
 <a212f313-1f34-7c83-3aab-b45374875493@suse.cz>
 <063D6719AE5E284EB5DD2968C1650D6DB0107DC8@AcuExch.aculab.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Alexander Viro <viro-RmSDqhL/yNMiFSDQTTA3OLVCufUGDwFn@public.gmane.org>,
        Andrew Morton <akpm-de/tnXTf+JLsfHDXvbKv3WD2FQJk+8+b@public.gmane.org>,
        "linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-fsdevel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-kernel-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org" <linux-mm-Bw31MaZKKs3YtjvyW6yDsg@public.gmane.org>,
        Michal Hocko <mhocko-DgEjT+Ai2ygdnm+yROfE0A@public.gmane.org>,
        "netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        Linux API <linux-api-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>,
        "linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org" <linux-man-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
To: David Laight <David.Laight-ZS65k/vG3HxXrIkS9f7CXA@public.gmane.org>,
        Eric Dumazet <eric.dumazet-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Return-path: <linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
In-Reply-To: <063D6719AE5E284EB5DD2968C1650D6DB0107DC8-VkEWCZq2GCInGFn1LkZF6NBPR1lH4CV8@public.gmane.org>
Sender: linux-api-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

On 09/23/2016 11:42 AM, David Laight wrote:
> From: Vlastimil Babka
>> Sent: 22 September 2016 18:55
> ...
>> So in the case of select() it seems like the memory we need 6 bits per file
>> descriptor, multiplied by the highest possible file descriptor (nfds) as passed
>> to the syscall. According to the man page of select:
>>
>>         EINVAL nfds is negative or exceeds the RLIMIT_NOFILE resource limit (see
>> getrlimit(2)).
> 
> That second clause is relatively recent.

Interesting... so it was added without actually being true in the kernel
code?

>> The code actually seems to silently cap the value instead of returning EINVAL
>> though? (IIUC):
>>
>>         /* max_fds can increase, so grab it once to avoid race */
>>          rcu_read_lock();
>>          fdt = files_fdtable(current->files);
>>          max_fds = fdt->max_fds;
>>          rcu_read_unlock();
>>          if (n > max_fds)
>>                  n = max_fds;
>>
>> The default for this cap seems to be 1024 where I checked (again, IIUC, it's
>> what ulimit -n returns?). I wasn't able to change it to more than 2048, which
>> makes the bitmaps still below PAGE_SIZE.
>>
>> So if I get that right, the system admin would have to allow really large
>> RLIMIT_NOFILE to even make vmalloc() possible here. So I don't see it as a large
>> concern?
> 
> 4k open files isn't that many.
> Especially for programs that are using pipes to emulate windows events.

Sure but IIUC we need 6 bits per file. That means up to almost 42k
files, we should fit into order-3 allocation, which effectively cannot
fail right now.

> I suspect that fdt->max_fds is an upper bound for the highest fd the
> process has open - not the RLIMIT_NOFILE value.

I gathered that the highest fd effectively limits the number of files,
so it's the same. I might be wrong.

> select() shouldn't be silently ignoring large values of 'n' unless
> the fd_set bits are zero.

Yeah that doesn't seem to conform to the manpage.

> Of course, select does scale well for high numbered fds
> and neither poll nor select scale well for large numbers of fds.

True.

> 	David
> 
