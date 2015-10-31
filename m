From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 08:59:31 -0700
Message-ID: <1446307171.6254.69.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151028223330.GD22011@ZenIV.linux.org.uk>
	 <1446073709.7476.93.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029001532.GE22011@ZenIV.linux.org.uk>
	 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029041611.GF22011@ZenIV.linux.org.uk>
	 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	 <20151030210215.GI22011@ZenIV.linux.org.uk>
	 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	 <20151030223317.GK22011@ZenIV.linux.org.uk>
	 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Al Viro <viro@zeniv.linux.org.uk>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <linux-fsdevel-owner@vger.kernel.org>
In-Reply-To: <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Fri, 2015-10-30 at 16:52 -0700, Linus Torvalds wrote: sequential
allocations...
> 
> I don't think it would matter in real life, since I don't really think
> you have lots of fd's with strictly sequential behavior.
> 
> That said, the trivial "open lots of fds" benchmark would show it, so
> I guess we can just keep it. The next_fd logic is not expensive or
> complex, after all.

+1


> Attached is an updated patch that just uses the regular bitmap
> allocator and extends it to also have the bitmap of bitmaps. It
> actually simplifies the patch, so I guess it's better this way.
> 
> Anyway, I've tested it all a bit more, and for a trivial worst-case
> stress program that explicitly kills the next_fd logic by doing
> 
>     for (i = 0; i < 1000000; i++) {
>         close(3);
>         dup2(0,3);
>         if (dup(0))
>             break;
>     }
> 
> it takes it down from roughly 10s to 0.2s. So the patch is quite
> noticeable on that kind of pattern.
> 
> NOTE! You'll obviously need to increase your limits to actually be
> able to do the above with lots of file descriptors.
> 
> I ran Eric's test-program too, and find_next_zero_bit() dropped to a
> fraction of a percent. It's not entirely gone, but it's down in the
> noise.
> 
> I really suspect this patch is "good enough" in reality, and I would
> *much* rather do something like this than add a new non-POSIX flag
> that people have to update their binaries for. I agree with Eric that
> *some* people will do so, but it's still the wrong thing to do. Let's
> just make performance with the normal semantics be good enough that we
> don't need to play odd special games.
> 
> Eric?

I absolutely agree a generic solution is far better, especially when
its performance is in par.

Tested-by: Eric Dumazet <edumazet@google.com>
Acked-by: Eric Dumazet <edumazet@google.com>

Note that a non-POSIX flag (or a thread personality hints)
would still allow the kernel to do proper NUMA affinity placement : Say
the fd_array and bitmaps are split on the 2 nodes (or more, but most
servers nowadays have 2 sockets really).

Then at fd allocation time, we can prefer to pick an fd for which memory
holding various bits and the file pointer are in the local node

This speeds up subsequent fd system call on programs that constantly
blow away cpu caches, saving QPI transactions.

Thanks a lot Linus.

lpaa24:~# taskset ff0ff ./opensock -t 16 -n 10000000 -l 10
count=10000000 (check/increase ulimit -n)
total = 3992764

lpaa24:~# ./opensock -t 48 -n 10000000 -l 10
count=10000000 (check/increase ulimit -n)
total = 3545249

Profile with 16 threads :

    69.55%  opensock          [.] memset                       
    11.83%  [kernel]          [k] queued_spin_lock_slowpath    
     1.91%  [kernel]          [k] _find_next_bit.part.0        
     1.68%  [kernel]          [k] _raw_spin_lock               
     0.99%  [kernel]          [k] kmem_cache_alloc             
     0.99%  [kernel]          [k] memset_erms                  
     0.95%  [kernel]          [k] get_empty_filp               
     0.82%  [kernel]          [k] __close_fd                   
     0.73%  [kernel]          [k] __alloc_fd                   
     0.65%  [kernel]          [k] sk_alloc                     
     0.63%  opensock          [.] child_function               
     0.56%  [kernel]          [k] fput                         
     0.35%  [kernel]          [k] sock_alloc                   
     0.31%  [kernel]          [k] kmem_cache_free              
     0.31%  [kernel]          [k] inode_init_always            
     0.28%  [kernel]          [k] d_set_d_op                   
     0.27%  [kernel]          [k] entry_SYSCALL_64_after_swapgs

Profile with 48 threads :

    57.92%  [kernel]          [k] queued_spin_lock_slowpath    
    32.14%  opensock          [.] memset                       
     0.81%  [kernel]          [k] _find_next_bit.part.0        
     0.51%  [kernel]          [k] _raw_spin_lock               
     0.45%  [kernel]          [k] kmem_cache_alloc             
     0.38%  [kernel]          [k] kmem_cache_free              
     0.34%  [kernel]          [k] __close_fd                   
     0.32%  [kernel]          [k] memset_erms                  
     0.25%  [kernel]          [k] __alloc_fd                   
     0.24%  [kernel]          [k] get_empty_filp               
     0.23%  opensock          [.] child_function               
     0.18%  [kernel]          [k] __d_alloc                    
     0.17%  [kernel]          [k] inode_init_always            
     0.16%  [kernel]          [k] sock_alloc                   
     0.16%  [kernel]          [k] del_timer                    
     0.15%  [kernel]          [k] entry_SYSCALL_64_after_swapgs
     0.15%  perf              [.] 0x000000000004d924           
     0.15%  [kernel]          [k] tcp_close                    




