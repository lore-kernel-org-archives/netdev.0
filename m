From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [Bug 106241] New: shutdown(3)/close(3) behaviour is incorrect
 for sockets in accept(3)
Date: Sun, 01 Nov 2015 18:14:43 -0800
Message-ID: <1446430483.6254.114.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1446122119.7476.138.camel@edumazet-glaptop2.roam.corp.google.com>
	 <CA+55aFx_BQG4FzSuyL2KAz=c+R0cPv0ZpjboT_=yKjZNGmTUEg@mail.gmail.com>
	 <20151030210215.GI22011@ZenIV.linux.org.uk>
	 <CA+55aFyoA5sXQvFDavNa7cGkRevunmtPe8F8-_tZ9-826qfkgw@mail.gmail.com>
	 <CA+55aFy9fPmbSCJoQiCkjkaiU2HTM6p=o-pJgiV7asyVWBjAEg@mail.gmail.com>
	 <20151030223317.GK22011@ZenIV.linux.org.uk>
	 <CA+55aFwfFb=LXU77AbiPDHgWcpBwTBoJB4EMCZgTgX32cxMYWw@mail.gmail.com>
	 <20151031193449.GM22011@ZenIV.linux.org.uk>
	 <CA+55aFxeiVx4wMhWALfU3KYCqhsnr8T8M-dEZc3aAyzobWeRGQ@mail.gmail.com>
	 <20151031202929.GN22011@ZenIV.linux.org.uk>
	 <20151102002421.GP22011@ZenIV.linux.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Linus Torvalds <torvalds@linux-foundation.org>,
	David Miller <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Network Development <netdev@vger.kernel.org>,
	David Howells <dhowells@redhat.com>,
	linux-fsdevel <linux-fsdevel@vger.kernel.org>
To: Al Viro <viro@ZenIV.linux.org.uk>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f52.google.com ([209.85.220.52]:36614 "EHLO
	mail-pa0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751714AbbKBCOp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 1 Nov 2015 21:14:45 -0500
In-Reply-To: <20151102002421.GP22011@ZenIV.linux.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2015-11-02 at 00:24 +0000, Al Viro wrote:

> This ought to be a bit cleaner.  Eric, could you test the variant below on your
> setup?

Sure !

5 runs of :
lpaa24:~# taskset ff0ff ./opensock -t 16 -n 10000000 -l 10

total = 4386311
total = 4560402
total = 4437309
total = 4516227
total = 4478778


With 48 threads :

./opensock -t 48 -n 10000000 -l 10
total = 4940245
total = 4848513
total = 4813153
total = 4813946
total = 5127804

Perf output taken on the 16 threads run :

    74.71%       opensock  opensock           [.] memset                                    
                 |
                 --- memset

     5.64%       opensock  [kernel.kallsyms]  [k] queued_spin_lock_slowpath                 
                 |
                 --- queued_spin_lock_slowpath
                    |          
                    |--99.89%-- _raw_spin_lock
                    |          |          
                    |          |--52.74%-- __close_fd
                    |          |          sys_close
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __libc_close
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |          |          
                    |          |--46.97%-- __alloc_fd
                    |          |          get_unused_fd_flags
                    |          |          sock_map_fd
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |           --0.30%-- [...]
                     --0.11%-- [...]

     1.69%       opensock  [kernel.kallsyms]  [k] _raw_spin_lock                            
                 |
                 --- _raw_spin_lock
                    |          
                    |--27.37%-- get_unused_fd_flags
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--22.40%-- sys_close
                    |          entry_SYSCALL_64_fastpath
                    |          __libc_close
                    |          
                    |--15.79%-- cache_alloc_refill
                    |          |          
                    |          |--99.27%-- kmem_cache_alloc
                    |          |          |          
                    |          |          |--81.25%-- sk_prot_alloc
                    |          |          |          sk_alloc
                    |          |          |          inet_create
                    |          |          |          __sock_create
                    |          |          |          sock_create
                    |          |          |          sys_socket
                    |          |          |          entry_SYSCALL_64_fastpath
                    |          |          |          __socket
                    |          |          |          
                    |          |          |--9.08%-- sock_alloc_inode
                    |          |          |          alloc_inode
                    |          |          |          new_inode_pseudo
                    |          |          |          sock_alloc
                    |          |          |          __sock_create
                    |          |          |          sock_create
                    |          |          |          sys_socket
                    |          |          |          entry_SYSCALL_64_fastpath
                    |          |          |          __socket
                    |          |          |          
                    |          |          |--4.98%-- __d_alloc
                    |          |          |          d_alloc_pseudo
                    |          |          |          sock_alloc_file
                    |          |          |          sock_map_fd
                    |          |          |          sys_socket
                    |          |          |          entry_SYSCALL_64_fastpath
                    |          |          |          __socket
                    |          |          |          
                    |          |           --4.69%-- get_empty_filp
                    |          |                     alloc_file
                    |          |                     sock_alloc_file
                    |          |                     sock_map_fd
                    |          |                     sys_socket
                    |          |                     entry_SYSCALL_64_fastpath
                    |          |                     __socket
                    |          |          
                    |           --0.73%-- kmem_cache_alloc_trace
                    |                     sock_alloc_inode
                    |                     alloc_inode
                    |                     new_inode_pseudo
                    |                     sock_alloc
                    |                     __sock_create
                    |                     sock_create
                    |                     sys_socket
                    |                     entry_SYSCALL_64_fastpath
                    |                     __socket
                    |          
                    |--10.80%-- sock_alloc_file
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--7.47%-- sock_alloc
                    |          __sock_create
                    |          sock_create
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--6.96%-- kmem_cache_alloc
                    |          |          
                    |          |--72.94%-- sk_prot_alloc
                    |          |          sk_alloc
                    |          |          inet_create
                    |          |          __sock_create
                    |          |          sock_create
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          
                    |          |--15.51%-- sock_alloc_inode
                    |          |          alloc_inode
                    |          |          new_inode_pseudo
                    |          |          sock_alloc
                    |          |          __sock_create
                    |          |          sock_create
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          
                    |          |--7.59%-- get_empty_filp
                    |          |          alloc_file
                    |          |          sock_alloc_file
                    |          |          sock_map_fd
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          
                    |           --3.96%-- __d_alloc
                    |                     d_alloc_pseudo
                    |                     sock_alloc_file
                    |                     sock_map_fd
                    |                     sys_socket
                    |                     entry_SYSCALL_64_fastpath
                    |                     __socket
                    |          
                    |--3.74%-- d_instantiate
                    |          sock_alloc_file
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--2.03%-- iput
                    |          __dentry_kill
                    |          dput
                    |          __fput
                    |          ____fput
                    |          task_work_run
                    |          prepare_exit_to_usermode
                    |          syscall_return_slowpath
                    |          int_ret_from_sys_call
                    |          __libc_close
                    |          
                    |--0.60%-- __fsnotify_inode_delete
                    |          __destroy_inode
                    |          destroy_inode
                    |          evict
                    |          iput
                    |          __dentry_kill
                    |          dput
                    |          __fput
                    |          ____fput
                    |          task_work_run
                    |          prepare_exit_to_usermode
                    |          syscall_return_slowpath
                    |          int_ret_from_sys_call
                    |          __libc_close
                    |          
                    |--0.55%-- evict
                    |          iput
                    |          __dentry_kill
                    |          dput
                    |          __fput
                    |          ____fput
                    |          task_work_run
                    |          prepare_exit_to_usermode
                    |          syscall_return_slowpath
                    |          int_ret_from_sys_call
                    |          __libc_close
                    |          
                    |--0.53%-- inet_release
                    |          sock_release
                    |          sock_close
                    |          __fput
                    |          ____fput
                    |          task_work_run
                    |          prepare_exit_to_usermode
                    |          syscall_return_slowpath
                    |          int_ret_from_sys_call
                    |          __libc_close
                    |          
                    |--0.51%-- __fput
                    |          ____fput
                    |          task_work_run
                    |          prepare_exit_to_usermode
                    |          syscall_return_slowpath


Perf taken on the 48 threads run :

   48.34%       opensock  [kernel.kallsyms]   [k] queued_spin_lock_slowpath           
                 |
                 --- queued_spin_lock_slowpath
                    |          
                    |--99.93%-- _raw_spin_lock
                    |          |          
                    |          |--50.11%-- __close_fd
                    |          |          sys_close
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __libc_close
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |          |          
                    |          |--49.85%-- __alloc_fd
                    |          |          get_unused_fd_flags
                    |          |          sock_map_fd
                    |          |          sys_socket
                    |          |          entry_SYSCALL_64_fastpath
                    |          |          __socket
                    |          |          |          
                    |          |           --100.00%-- 0x0
                    |           --0.03%-- [...]
                     --0.07%-- [...]

    41.03%       opensock  opensock            [.] memset                              
                 |
                 --- memset

     0.69%       opensock  [kernel.kallsyms]   [k] _raw_spin_lock                      
                 |
                 --- _raw_spin_lock
                    |          
                    |--30.22%-- sys_close
                    |          entry_SYSCALL_64_fastpath
                    |          __libc_close
                    |          |          
                    |           --100.00%-- 0x0
                    |          
                    |--30.15%-- get_unused_fd_flags
                    |          sock_map_fd
                    |          sys_socket
                    |          entry_SYSCALL_64_fastpath
                    |          __socket
                    |          
                    |--14.61%-- cache_alloc_refill
                    |          |          
