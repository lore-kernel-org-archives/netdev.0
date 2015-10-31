From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sat, 31 Oct 2015 15:34:44 -0700
Message-ID: <1446330884.6254.76.camel@edumazet-glaptop2.roam.corp.google.com>
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
	 <1446324359.6254.71.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFz9wm7LssaaUzmo-NYNGW88gb_TkUFSJoFJrY+fvtt8+A@mail.gmail.com>
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
In-Reply-To: <CA+55aFz9wm7LssaaUzmo-NYNGW88gb_TkUFSJoFJrY+fvtt8+A@mail.gmail.com>
Sender: linux-fsdevel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2015-10-31 at 14:23 -0700, Linus Torvalds wrote:

> Mind testing something really stupid, and making the __clear_bit() in
> __clear_close_on_exec() conditiona, something like this:
> 
>      static inline void __clear_close_on_exec(int fd, struct fdtable *fdt)
>      {
>     -       __clear_bit(fd, fdt->close_on_exec);
>     +       if (test_bit(fd, fdt->close_on_exec)
>     +               __clear_bit(fd, fdt->close_on_exec);
>      }
> 
> and see if it makes a difference.

It does ;)

About 4 % qps increase

3 runs : 
lpaa24:~# taskset ff0ff ./opensock -t 16 -n 10000000 -l 10
total = 4176651
total = 4178012
total = 4105226

instead of :
total = 3910620
total = 3874567
total = 3971028

Perf profile :

    69.12%       opensock  opensock             [.] memset                                       
                 |
                 --- memset

    12.37%       opensock  [kernel.kallsyms]    [k] queued_spin_lock_slowpath                    
                 |
                 --- queued_spin_lock_slowpath
                    |          
                    |--99.99%-- _raw_spin_lock
                    |          |          
                    |          |--51.99%-- __close_fd
                    |          |          sys_close
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __libc_close
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |          |          
                    |          |--47.79%-- __alloc_fd
                    |          |          get_unused_fd_flags
                    |          |          sock_map_fd
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |           --0.21%-- [...]
                     --0.01%-- [...]

     1.92%       opensock  [kernel.kallsyms]    [k] _find_next_bit.part.0                        
                 |
                 --- _find_next_bit.part.0
                    |          
                    |--66.93%-- find_next_zero_bit
                    |          __alloc_fd
                    |          get_unused_fd_flags
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                     --33.07%-- __alloc_fd
                               get_unused_fd_flags
                               sock_map_fd
                               sys_socket
                               entry_SYSCALL_64_fastpath
                               __socket
                               |          
                                --100.00%-- 0x0

     1.63%       opensock  [kernel.kallsyms]    [k] _raw_spin_lock                               
                 |
                 --- _raw_spin_lock
                    |          
                    |--28.66%-- get_unused_fd_flags
                    |          sock_map_fd


