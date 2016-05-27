From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Deadlock when running DevStack on latest pull of net tree
Date: Fri, 27 May 2016 11:21:50 -0700
Message-ID: <CAKgT0Uc=kpE1UArBpbtFu3eUVzW75zU+XD5hsc39k2CFE7PtNA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
To: Netdev <netdev@vger.kernel.org>,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

I started out this morning by trying to run DevStack on the latest
"net' kernel and it looks like I am hanging on some sort of locking
problem with RabbitMQ.  Specifically I am seeing one CPU jump to 100%
with perf showing that I am spinning on a lock.

I'm working to bisect it now, but just thought I would put it out
there if anybody had already root caused this issue.  Below is a few
traces to the spin lock call on the spinning CPU:
-   18.81%    18.81%  beam.smp  [kernel.vmlinux]  [k] _raw_spin_lock_irqsave
   - _raw_spin_lock_irqsave
      - 32.86% add_wait_queue
           n_tty_write
           tty_write
           do_loop_readv_writev
           do_readv_writev
           vfs_writev
           do_writev
           sys_writev
           do_syscall_64
           return_from_SYSCALL_64
           __libc_writev
      - 32.49% remove_wait_queue
           n_tty_write
           tty_write
           do_loop_readv_writev
           do_readv_writev
           vfs_writev
           do_writev
           sys_writev
           do_syscall_64
           return_from_SYSCALL_64
           __libc_writev
      - 31.71% __wake_up
           tty_write_unlock
           tty_write
           do_loop_readv_writev
           do_readv_writev
           vfs_writev
           do_writev
           sys_writev
           do_syscall_64
           return_from_SYSCALL_64
           __libc_writev
      - 1.96% n_tty_write
           tty_write
           do_loop_readv_writev
           do_readv_writev
           vfs_writev
           do_writev
           sys_writev
           do_syscall_64
           return_from_SYSCALL_64
           __libc_writev
      - 0.87% tty_write_unlock
           tty_write
           do_loop_readv_writev
           do_readv_writev
           vfs_writev
           do_writev
           sys_writev
           do_syscall_64
           return_from_SYSCALL_64
           __libc_writev
