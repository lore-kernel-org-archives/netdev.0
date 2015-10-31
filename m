From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 13:45:59 -0700
Message-ID: <1446324359.6254.71.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20151029001532.GE22011@ZenIV.linux.org.uk>
	 <1446089381.7476.114.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20151029041611.GF22011@ZenIV.linux.org.uk>
	 <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	 <20151030210215.GI22011@ZenIV.linux.org.uk>
	 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	 <20151030223317.GK22011@ZenIV.linux.org.uk>
	 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
	 <20151031193449.GM22011@ZenIV.linux.org.uk>
	 <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
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
In-Reply-To: <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-10-31 at 12:54 -0700, Linus Torvalds wrote:
> On Sat, Oct 31, 2015 at 12:34 PM, Al Viro <viro@zeniv.linux.org.uk> wrote:
> >
> > ... and here's the current variant of mine.
> 
> Ugh. I really liked how simple mine ended up being. Yours is definitely not.
> 
> And based on the profiles from Eric, finding the fd is no longer the
> problem even with my simpler patch. The problem ends up being the
> contention on the file_lock spinlock.
> 
> Eric, I assume that's not "expand_fdtable", since your test-program
> seems to expand the fd array at the beginning. So it's presumably all
> from the __alloc_fd() use, but we should double-check.. Eric, can you
> do a callgraph profile and see which caller is the hottest?

Sure : profile taken while test runs using 16 threads (Since this is
probably not a too biased micro benchmark...)

# hostname : lpaa24
# os release : 4.3.0-smp-DEV
# perf version : 3.12.0-6-GOOGLE
# arch : x86_64
# nrcpus online : 48
# nrcpus avail : 48
# cpudesc : Intel(R) Xeon(R) CPU E5-2696 v2 @ 2.50GHz
# cpuid : GenuineIntel,6,62,4
# total memory : 264126320 kB
# cmdline : /usr/bin/perf record -a -g sleep 4 
# event : name = cycles, type = 0, config = 0x0, config1 = 0x0, config2 = 0x0, excl_usr = 0, excl_kern = 0, excl_host = 0, excl_guest = 1, precise_ip = 0, att
# CPU_TOPOLOGY info available, use -I to display
# NUMA_TOPOLOGY info available, use -I to display
# pmu mappings: cpu = 4, msr = 38, uncore_cbox_10 = 35, uncore_cbox_11 = 36, software = 1, power = 7, uncore_irp = 8, uncore_pcu = 37, tracepoint = 2, uncore_
# Samples: 260K of event 'cycles'
# Event count (approx.): 196742182232
#
# Overhead        Command        Shared Object                                                                                                                
# ........  .............  ...................  ..............................................................................................................
#
    67.15%       opensock  opensock             [.] memset                                                                                                    
                 |
                 --- memset

    13.84%       opensock  [kernel.kallsyms]    [k] queued_spin_lock_slowpath                                                                                 
                 |
                 --- queued_spin_lock_slowpath
                    |          
                    |--99.97%-- _raw_spin_lock
                    |          |          
                    |          |--53.03%-- __close_fd
                    |          |          sys_close
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __libc_close
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |          |          
                    |          |--46.83%-- __alloc_fd
                    |          |          get_unused_fd_flags
                    |          |          sock_map_fd
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |           --0.13%-- [...]
                     --0.03%-- [...]

     1.84%       opensock  [kernel.kallsyms]    [k] _find_next_bit.part.0                                                                                     
                 |
                 --- _find_next_bit.part.0
                    |          
                    |--65.97%-- find_next_zero_bit
                    |          __alloc_fd
                    |          get_unused_fd_flags
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--34.01%-- __alloc_fd
                    |          get_unused_fd_flags
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          |          
                    |           --100.00%-- 0x0
                     --0.02%-- [...]

     1.59%       opensock  [kernel.kallsyms]    [k] _raw_spin_lock                                                                                            
                 |
                 --- _raw_spin_lock
                    |          
                    |--28.78%-- get_unused_fd_flags
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--26.53%-- sys_close
                    |          entry_SYSCALL_64_fastpath
                    |          __libc_close
                    |          
                    |--13.95%-- cache_alloc_refill
                    |          |          
                    |          |--99.48%-- kmem_cache_alloc
                    |          |          |          
                    |          |          |--81.20%-- sk_prot_alloc
                    |          |          |          sk_alloc
                    |          |          |          inet_create
                    |          |          |          __sock_create
                    |          |          |          sock_create
                    |          |          |          sys_socket
                    |          |          |          entry_SYSCALL_64_fastpath
                    |          |          |          __socket
                    |          |          |          
                    |          |          |--8.43%-- sock_alloc_inode
                    |          |          |          alloc_inode
                    |          |          |          new_inode_pseudo
                    |          |          |          sock_alloc
                    |          |          |          __sock_create
                    |          |          |          sock_create
                    |          |          |          sys_socket
                    |          |          |          entry_SYSCALL_64_fastpath
                    |          |          |          __socket
                    |          |          |          
                    |          |          |--5.80%-- __d_alloc
                    |          |          |          d_alloc_pseudo
                    |          |          |          sock_alloc_file
                    |          |          |          sock_map_fd
                    |          |          |          sys_socket


