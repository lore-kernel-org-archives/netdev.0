From: "Vegard Nossum" <vegard.nossum@gmail.com>
Subject: Re: 2.6.27.9: splice_to_pipe() hung (blocked for more than 120 seconds)
Date: Sun, 18 Jan 2009 13:12:36 +0100
Message-ID: <19f34abd0901180412w39d70ccqd0c10698bc70e6e9@mail.gmail.com>
References: <19f34abd0901161055l2edd9274n4b2d8c93e7760488@mail.gmail.com>
	 <4970F2B6.1060508@cosmosbay.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: 7bit
Cc: lkml <linux-kernel@vger.kernel.org>,
	"Linux Netdev List" <netdev@vger.kernel.org>
To: "Eric Dumazet" <dada1@cosmosbay.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f21.google.com ([209.85.218.21]:49619 "EHLO
	mail-bw0-f21.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1765995AbZARMMi (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 18 Jan 2009 07:12:38 -0500
In-Reply-To: <4970F2B6.1060508@cosmosbay.com>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, Jan 16, 2009 at 9:48 PM, Eric Dumazet <dada1@cosmosbay.com> wrote:
>
> I tried your program on latest git tree and could not reproduce any problem.
>
> (changed to 9 threads since I have 8 cpus)

Hm. My machine has 2 CPUs. I just reproduced it on a more recent
kernel, this time from:

commit a6525042bfdfcab128bd91fad264de10fd24a55e
Date:   Tue Jan 13 14:53:16 2009 -0800

with lockdep enabled, and no bad messages. So it seems that it is not
a deadlock at least...

> Problem might be that your threads all fight on the same pipe, with
> a mutex protecting its inode.
>
>
> So mutex_lock() could possibly starve for more than 120 second ?

Much longer. Last time this happened, the zombies stayed for many
hours (until I rebooted the machine).

> Maybe you can reproduce the problem using standard read()/write() syscalls...

I can try...

Tasks:   7 total,   0 running,   6 sleeping,   0 stopped,   1 zombie
Cpu(s):  0.4%us,  6.0%sy,  0.0%ni, 92.6%id,  1.0%wa,  0.0%hi,  0.0%si,  0.0%st
Mem:   1016180k total,    54596k used,   961584k free,     4084k buffers
Swap:   104380k total,        0k used,   104380k free,    20412k cached

  PID USER      PR  NI  VIRT  RES  SHR S %CPU %MEM    TIME+  COMMAND
 3808 500       20   0     0    0    0 Z    0  0.0   0:00.00 a.out <defunct>
 3809 500       20   0     0    0    0 D    0  0.0   0:00.00 a.out
 3810 500       20   0     0    0    0 D    0  0.0   0:00.00 a.out
 3813 500       20   0     0    0    0 D    0  0.0   0:00.00 a.out
 3815 500       20   0     0    0    0 D    0  0.0   0:00.00 a.out
 3817 500       20   0     0    0    0 D    0  0.0   0:00.00 a.out
 3821 500       20   0     0    0    0 D    0  0.0   0:00.00 a.out

root@ubuntu:/home/debian# strace -p 3808
attach: ptrace(PTRACE_ATTACH, ...): Operation not permitted

root@ubuntu:/home/debian# strace -p 3809
Process 3809 attached - interrupt to quit
<nothing>
^C^C^C^C^C^C^C^C
<doesn't quit>

root@ubuntu:/home/debian# cat /proc/3808/syscall
0 0xbfa1f5b4 0xbfa1f5b4 0xc8bff4 0xbfa1f5b4 0x0 0xbfa1f5c8 0xbfa1f3f8 0xb8020424
root@ubuntu:/home/debian# cat /proc/3809/syscall
313 0x9 0x0 0x7 0x0 0x3 0x0 0xb80012cc 0xb8020424
root@ubuntu:/home/debian# cat /proc/3810/syscall
313 0x6 0x0 0x5 0x0 0x17f 0x0 0xb780037c 0xb8020424
root@ubuntu:/home/debian# cat /proc/3813/syscall
313 0xa 0x0 0x7 0x0 0x3 0x0 0xb67fe2cc 0xb8020424
root@ubuntu:/home/debian# cat /proc/3815/syscall
313 0x6 0x0 0x5 0x0 0x17f 0x0 0xb5ffd37c 0xb8020424
root@ubuntu:/home/debian# cat /proc/3817/syscall
313 0x8 0x0 0x7 0x0 0x3 0x0 0xb4ffb2cc 0xb8020424
root@ubuntu:/home/debian# cat /proc/3821/syscall
313 0x6 0x0 0x5 0x0 0x17f 0x0 0xb47fa37c 0xb8020424

Also managed to grab this this time:

 SysRq : Show Locks Held

 Showing all locks held in the system:
 1 lock held by getty/2130:
  #0:  (&tty->atomic_read_lock){--..}, at: [<c1218973>] n_tty_read+0x533/0x780
 1 lock held by getty/2131:
  #0:  (&tty->atomic_read_lock){--..}, at: [<c1218973>] n_tty_read+0x533/0x780
 1 lock held by getty/2134:
  #0:  (&tty->atomic_read_lock){--..}, at: [<c1218973>] n_tty_read+0x533/0x780
 1 lock held by getty/2138:
  #0:  (&tty->atomic_read_lock){--..}, at: [<c1218973>] n_tty_read+0x533/0x780
 1 lock held by getty/2142:
  #0:  (&tty->atomic_read_lock){--..}, at: [<c1218973>] n_tty_read+0x533/0x780
 1 lock held by getty/2143:
  #0:  (&tty->atomic_read_lock){--..}, at: [<c1218973>] n_tty_read+0x533/0x780
 1 lock held by a.out/3809:
  #0:  (&sb->s_type->i_mutex_key#4){--..}, at: [<c10d5515>]
splice_to_pipe+0x25/0x260
 2 locks held by a.out/3810:
  #0:  (&sb->s_type->i_mutex_key#11/2){--..}, at: [<c10d548c>]
splice_from_pipe+0x5c/0x90
  #1:  (&sb->s_type->i_mutex_key#4){--..}, at: [<c10be5ac>] pipe_wait+0x6c/0x80
 1 lock held by a.out/3813:
  #0:  (&sb->s_type->i_mutex_key#4){--..}, at: [<c10d5515>]
splice_to_pipe+0x25/0x260
 2 locks held by a.out/3815:
  #0:  (&sb->s_type->i_mutex_key#4/1){--..}, at: [<c10c97a2>]
inode_double_lock+0x32/0xb0
  #1:  (&sb->s_type->i_mutex_key#11/2){--..}, at: [<c10d548c>]
splice_from_pipe+0x5c/0x90
 1 lock held by a.out/3817:
  #0:  (&sb->s_type->i_mutex_key#4){--..}, at: [<c10d5515>]
splice_to_pipe+0x25/0x260
 1 lock held by a.out/3821:
  #0:  (&sb->s_type->i_mutex_key#4/1){--..}, at: [<c10c97a2>]
inode_double_lock+0x32/0xb0
 2 locks held by bash/3916:
  #0:  (sysrq_key_table_lock){....}, at: [<c12297f7>] __handle_sysrq+0x17/0x140
  #1:  (tasklist_lock){..--}, at: [<c1059354>] debug_show_all_locks+0x34/0x180

 =============================================

Anything else that can help debug this? Machine is still running, so...

Thanks :-)


Vegard

-- 
"The animistic metaphor of the bug that maliciously sneaked in while
the programmer was not looking is intellectually dishonest as it
disguises that the error is the programmer's own creation."
	-- E. W. Dijkstra, EWD1036
