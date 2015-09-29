From: Jason Baron <jbaron@akamai.com>
Subject: Re: List corruption on epoll_ctl(EPOLL_CTL_DEL) an AF_UNIX socket
Date: Tue, 29 Sep 2015 15:09:54 -0400
Message-ID: <560AE202.4020402@akamai.com>
References: <20150913195354.GA12352@jig.fritz.box>	<20150914023949.GA15012@dcvr.yhbt.net> <CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: Eric Wong <normalperson@yhbt.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Rainer Weikusat <rweikusat@mobileactivedefense.com>,
	Alexander Viro <viro@zeniv.linux.org.uk>,
	Davide Libenzi <davidel@xmailserver.org>,
	Davidlohr Bueso <dave@stgolabs.net>,
	Olivier Mauras <olivier@mauras.ch>,
	PaX Team <pageexec@freemail.hu>,
	Linus Torvalds <torvalds@linux-foundation.org>,
	eric.dumazet@gmail.com,
	"peterz@infradead.org" <peterz@infradead.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Mathias Krause <minipli@googlemail.com>, netdev@vger.kernel.org,
	"linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <CA+rthh8smc0fxL5sEhMpKRQgzMi=BCVyxKc=O1JWesHGwYW8XA@mail.gmail.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On 09/29/2015 02:09 PM, Mathias Krause wrote:
> On 14 September 2015 at 04:39, Eric Wong <normalperson@yhbt.net> wrote:
>> +cc Jason Baron since he might be able to provide more insight into
>> epoll.
>>
>> Mathias Krause <minipli@googlemail.com> wrote:
>>> Hi,
>>>
>>> this is an attempt to resurrect the thread initially started here:
>>>
>>>   http://thread.gmane.org/gmane.linux.network/353003
>>>
>>> As that patch fixed the issue for the mentioned reproducer, it did not
>>> fix the bug for the production code Olivier is using. :(
>>>
>>> Changing the reproducer only slightly allows me to trigger the following
>>> list debug splat (CONFIG_DEBUG_LIST=y) reliable within seconds -- even
>>> with the above linked patch applied:
>>>
>>> [   50.264249] ------------[ cut here ]------------
>>> [   50.264249] WARNING: CPU: 0 PID: 214 at lib/list_debug.c:59 __list_del_entry+0xa4/0xd0()
>>> [   50.264249] list_del corruption. prev->next should be ffff88003c2c1bb8, but was ffff88003f07bbb8
>>> [   50.264249] Modules linked in: ipv6 pcspkr serio_raw microcode virtio_net virtio_pci virtio_ring virtio sr_mod cdrom
>>> [   50.264249] CPU: 0 PID: 214 Comm: epoll_bug Not tainted 4.2.0 #75
>>> [   50.264249] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
>>> [   50.264249]  ffffffff817e902e ffff880000087d08 ffffffff8155593c 0000000000000007
>>> [   50.264249]  ffff880000087d58 ffff880000087d48 ffffffff8105202a 0000000000000001
>>> [   50.264249]  ffff88003c2c1bb8 ffff88003f07bb80 0000000000000286 ffff88003f736640
>>> [   50.264249] Call Trace:
>>> [   50.264249]  [<ffffffff8155593c>] dump_stack+0x4c/0x65
>>> [   50.264249]  [<ffffffff8105202a>] warn_slowpath_common+0x8a/0xc0
>>> [   50.264249]  [<ffffffff810520a6>] warn_slowpath_fmt+0x46/0x50
>>> [   50.264249]  [<ffffffff81322354>] __list_del_entry+0xa4/0xd0
>>> [   50.264249]  [<ffffffff81322391>] list_del+0x11/0x40
>>> [   50.264249]  [<ffffffff81094d39>] remove_wait_queue+0x29/0x40
>>> [   50.264249]  [<ffffffff811bc898>] ep_unregister_pollwait.isra.6+0x58/0x1a0
>>> [   50.264249]  [<ffffffff811bc8e9>] ? ep_unregister_pollwait.isra.6+0xa9/0x1a0
>>> [   50.264249]  [<ffffffff811bca02>] ep_remove+0x22/0x110
>>> [   50.264249]  [<ffffffff811be28b>] SyS_epoll_ctl+0x62b/0xf70
>>> [   50.264249]  [<ffffffff81000f44>] ? lockdep_sys_exit_thunk+0x12/0x14
>>> [   50.264249]  [<ffffffff8155cd97>] entry_SYSCALL_64_fastpath+0x12/0x6f
>>> [   50.264249] ---[ end trace d9af9b915df9667e ]---
>>> [   50.572100] ------------[ cut here ]------------
>>> [   50.572100] WARNING: CPU: 1 PID: 212 at lib/list_debug.c:62 __list_del_entry+0xc3/0xd0()
>>> [   50.584263] list_del corruption. next->prev should be ffff88003f664c90, but was ffff88003f0cb5b8
>>> [   50.584263] Modules linked in: ipv6 pcspkr serio_raw microcode virtio_net virtio_pci virtio_ring virtio sr_mod cdrom
>>> [   50.584263] CPU: 1 PID: 212 Comm: epoll_bug Tainted: G        W       4.2.0 #75
>>> [   50.584263] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
>>> [   50.584263]  ffffffff817e902e ffff88003d37fce8 ffffffff8155593c 0000000000000007
>>> [   50.584263]  ffff88003d37fd38 ffff88003d37fd28 ffffffff8105202a 0000000000000001
>>> [   50.584263]  ffff88003f664c90 ffff88003f0cb580 0000000000000282 ffff88003f731740
>>> [   50.584263] Call Trace:
>>> [   50.584263]  [<ffffffff8155593c>] dump_stack+0x4c/0x65
>>> [   50.584263]  [<ffffffff8105202a>] warn_slowpath_common+0x8a/0xc0
>>> [   50.584263]  [<ffffffff810520a6>] warn_slowpath_fmt+0x46/0x50
>>> [   50.584263]  [<ffffffff81322373>] __list_del_entry+0xc3/0xd0
>>> [   50.584263]  [<ffffffff81322391>] list_del+0x11/0x40
>>> [   50.584263]  [<ffffffff81094d39>] remove_wait_queue+0x29/0x40
>>> [   50.584263]  [<ffffffff811bc898>] ep_unregister_pollwait.isra.6+0x58/0x1a0
>>> [   50.584263]  [<ffffffff811bc8e9>] ? ep_unregister_pollwait.isra.6+0xa9/0x1a0
>>> [   50.584263]  [<ffffffff811bca02>] ep_remove+0x22/0x110
>>> [   50.584263]  [<ffffffff811bda62>] eventpoll_release_file+0x62/0xa0
>>> [   50.584263]  [<ffffffff8117704f>] __fput+0x1af/0x200
>>> [   50.584263]  [<ffffffff8155cf20>] ? int_very_careful+0x5/0x3f
>>> [   50.584263]  [<ffffffff811770ee>] ____fput+0xe/0x10
>>> [   50.584263]  [<ffffffff8107271d>] task_work_run+0x8d/0xc0
>>> [   50.584263]  [<ffffffff8100390f>] do_notify_resume+0x4f/0x60
>>> [   50.584263]  [<ffffffff8155cf6c>] int_signal+0x12/0x17
>>> [   50.584263] ---[ end trace d9af9b915df9667f ]---
>>> [   50.584263] BUG: spinlock already unlocked on CPU#1, epoll_bug/212
>>> [   50.584263]  lock: 0xffff88003f0cb580, .magic: dead4ead, .owner: <none>/-1, .owner_cpu: -1
>>> [   50.584263] CPU: 1 PID: 212 Comm: epoll_bug Tainted: G        W       4.2.0 #75
>>> [   50.584263] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
>>> [   50.584263]  ffff88003f0cb580 ffff88003d37fd38 ffffffff8155593c 0000000000000007
>>> [   50.584263]  ffffffffffffffff ffff88003d37fd58 ffffffff810a3375 ffff88003f0cb580
>>> [   50.584263]  ffffffff817b9cc8 ffff88003d37fd78 ffffffff810a33f6 ffff88003f0cb580
>>> [   50.584263] Call Trace:
>>> [   50.584263]  [<ffffffff8155593c>] dump_stack+0x4c/0x65
>>> [   50.584263]  [<ffffffff810a3375>] spin_dump+0x85/0xe0
>>> [   50.584263]  [<ffffffff810a33f6>] spin_bug+0x26/0x30
>>> [   50.584263]  [<ffffffff810a3645>] do_raw_spin_unlock+0x75/0xa0
>>> [   50.584263]  [<ffffffff8155c4ec>] _raw_spin_unlock_irqrestore+0x2c/0x50
>>> [   50.584263]  [<ffffffff81094d44>] remove_wait_queue+0x34/0x40
>>> [   50.584263]  [<ffffffff811bc898>] ep_unregister_pollwait.isra.6+0x58/0x1a0
>>> [   50.584263]  [<ffffffff811bc8e9>] ? ep_unregister_pollwait.isra.6+0xa9/0x1a0
>>> [   50.584263]  [<ffffffff811bca02>] ep_remove+0x22/0x110
>>> [   50.584263]  [<ffffffff811bda62>] eventpoll_release_file+0x62/0xa0
>>> [   50.584263]  [<ffffffff8117704f>] __fput+0x1af/0x200
>>> [   50.584263]  [<ffffffff8155cf20>] ? int_very_careful+0x5/0x3f
>>> [   50.584263]  [<ffffffff811770ee>] ____fput+0xe/0x10
>>> [   50.584263]  [<ffffffff8107271d>] task_work_run+0x8d/0xc0
>>> [   50.584263]  [<ffffffff8100390f>] do_notify_resume+0x4f/0x60
>>> [   50.584263]  [<ffffffff8155cf6c>] int_signal+0x12/0x17
>>> [...]
>>>
>>> That 'spinlock already unlocked' message is also interesting. But even
>>> better, enabling slab debugging (CONFIG_SLUB_DEBUG_ON=y) makes that
>>> list_del corruption warning a GPF:
>>>
>>> [   21.124241] general protection fault: 0000 [#1] SMP
>>> [   21.128193] Modules linked in: ipv6 pcspkr serio_raw microcode virtio_net virtio_pci virtio_ring virtio sr_mod cdrom
>>> [   21.144249] CPU: 1 PID: 221 Comm: epoll_bug Not tainted 4.2.0 #75
>>> [   21.144249] Hardware name: QEMU Standard PC (i440FX + PIIX, 1996), BIOS 1.7.5-20140531_083030-gandalf 04/01/2014
>>> [   21.144249] task: ffff88001fa82b80 ti: ffff880018894000 task.ti: ffff880018894000
>>> [   21.144249] RIP: 0010:[<ffffffff8109def0>]  [<ffffffff8109def0>] __lock_acquire+0x240/0x1800
>>> [   21.144249] RSP: 0018:ffff880018897c98  EFLAGS: 00010002
>>> [   21.144249] RAX: 0000000000000000 RBX: 6b6b6b6b6b6b6b6b RCX: 0000000000000000
>>> [   21.144249] RDX: 0000000000000000 RSI: 0000000000000000 RDI: ffff88001f8b1c18
>>> [   21.144249] RBP: ffff880018897d28 R08: 0000000000000001 R09: 0000000000000001
>>> [   21.144249] R10: 0000000000000000 R11: ffff88001f8b1c18 R12: 0000000000000000
>>> [   21.144249] R13: 0000000000000000 R14: 0000000000000000 R15: ffff88001fa82b80
>>> [   21.144249] FS:  00007f0c87e5d700(0000) GS:ffff88001eb00000(0000) knlGS:0000000000000000
>>> [   21.144249] CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
>>> [   21.144249] CR2: 00007f0c87e5cff8 CR3: 000000001899c000 CR4: 00000000001406e0
>>> [   21.144249] Stack:
>>> [   21.144249]  ffff880018897cb8 ffffffff8109d94b ffff880018b6fdb0 ffff88001e3d3b80
>>> [   21.144249]  ffff880018897cc8 ffff88001fa83250 0000000000000002 0000000000000000
>>> [   21.144249]  0000000000000001 ffff88001fa82b80 ffff880018897d88 ffffffff8109e0f7
>>> [   21.144249] Call Trace:
>>> [   21.144249]  [<ffffffff8109d94b>] ? trace_hardirqs_on_caller+0x14b/0x1e0
>>> [   21.144249]  [<ffffffff8109e0f7>] ? __lock_acquire+0x447/0x1800
>>> [   21.144249]  [<ffffffff8109fdd7>] lock_acquire+0xc7/0x260
>>> [   21.144249]  [<ffffffff81094d2d>] ? remove_wait_queue+0x1d/0x40
>>> [   21.144249]  [<ffffffff8155c373>] _raw_spin_lock_irqsave+0x43/0x60
>>> [   21.144249]  [<ffffffff81094d2d>] ? remove_wait_queue+0x1d/0x40
>>> [   21.144249]  [<ffffffff81094d2d>] remove_wait_queue+0x1d/0x40
>>> [   21.144249]  [<ffffffff811bc898>] ep_unregister_pollwait.isra.6+0x58/0x1a0
>>> [   21.144249]  [<ffffffff811bc8e9>] ? ep_unregister_pollwait.isra.6+0xa9/0x1a0
>>> [   21.144249]  [<ffffffff811bca02>] ep_remove+0x22/0x110
>>> [   21.144249]  [<ffffffff811be28b>] SyS_epoll_ctl+0x62b/0xf70
>>> [   21.144249]  [<ffffffff81000f44>] ? lockdep_sys_exit_thunk+0x12/0x14
>>> [   21.144249]  [<ffffffff8155cd97>] entry_SYSCALL_64_fastpath+0x12/0x6f
>>> [   21.144249] Code: 49 81 3b c0 9e c4 81 b8 00 00 00 00 44 0f 44 c0 41 83 fe 01 0f 87 39 fe ff ff 44 89 f0 49 8b 5c c3 08 48 85 db 0f 84 28 fe ff ff <f0> ff 83 98 01 00 00 45 8b b7 a0 06 00 00 41 83 fe 2f 76 10 44
>>> [   21.144249] RIP  [<ffffffff8109def0>] __lock_acquire+0x240/0x1800
>>> [   21.144249]  RSP <ffff880018897c98>
>>> [   21.144249] ---[ end trace 7136cfe3b6480f34 ]---
>>>
>>> The slab poisoning hits, as can be seen by the pattern in RBX which the
>>> faulting instruction is using as a memory operand. So this is probably a
>>> use-after-free bug -- or, more likely, an object that better had been
>>> freed via rcu semantics.
>>>
>>> I looked at the epoll code really hard and concluded I don't understand
>>> it at all. I've added a few calls to synchroize_rcu() and changed direct
>>> pointer assignments to rcu_assign_pointer() in places I thought would
>>> need them. But that only made the race happen less often, not cured it.
>>>
>>> This is what I did:
>>> - add a call to synchroize_rcu() in eventpoll_release_file() after
>>>   taking the epmutex. It's traversing an rcu list, after all.
>>> - make the NULL pointer assignment of whead in ep_poll_callback() an
>>>   rcu_assign_pointer() assignment and call synchronize_rcu() afterwards.
>>>   It's also an rcu pointer that should be assigned that way, no?
>>>
>>> But, apparently, all irrelevant.
>>>
>>> I had the same luck while staring at the af_unix code. I've added a few
>>> unix_state_lock() / -unlock() calls to places I though would need them
>>> to be able to reliably test / set socket flags and the peer member of
>>> struct unix_sock. But again, that only made the bug happen less often.
>>>
>>> What I did:
>>> - take other's unix_state_lock() in unix_dgram_disconnected() for
>>>   testing the flags and signaling the error
>>> - moving the 'unix_peer(sk) = NULL' assignment to the section that holds
>>>   the unix_state_lock() in unix_release_sock(). This ensures others will
>>>   see changes to the peer pointer atomically -- when themselves making
>>>   use of the lock only, of course.
>>> - in unix_dgram_poll() avoid calling sock_poll_wait() if the peer is
>>>   already SOCK_DEAD or RCV_SHUTDOWN. For testing the flags, other's
>>>   unix_state_lock() is taken.
>>>
>>> The last one is, in fact, the old patch, extended by the
>>> '(other->sk_shutdown & RCV_SHUTDOWN)' test. But Eric already noted back
>>> then, it might be an expensive lock to take here.
>>>
>>> Anyways, none of the above changes fixed the issue. I suspect it's
>>> related to the double usage of the peer_wq waitQ in unix_dgram_sendmsg()
>>> (via unix_wait_for_peer()) and unix_dgram_poll() (via sock_poll_wait()).
>>> But I might be totally wrong, here.
>>>
>>> However, it's definitely the second sock_poll_wait() call in
>>> unix_dgram_poll() that triggers the issue. Commenting out the call --
>>> thereby obviously breaking its functionality -- gets me rid of the list
>>> debug splat and the GFP. But that's not a fix either. So I'm asking for
>>> help.
>>>
>>>
>>> Regards,
>>> Mathias
>>
>>> /* use-after-free in poll routine of AF_UNIX sockets, triggerable using epoll
>>>  *
>>>  * ..intruduced in 3c73419c09 "af_unix: fix 'poll for write'/ connected DGRAM
>>>  * sockets" (v2.6.26-rc7)
>>>  *
>>>  * $ gcc -pthread -o epoll_bug epoll_bug.c
>>>  *
>>>  * - minipli
>>>  */
>>> #include <sys/socket.h>
>>> #include <sys/epoll.h>
>>> #include <sys/un.h>
>>> #include <pthread.h>
>>> #include <unistd.h>
>>> #include <signal.h>
>>> #include <stdlib.h>
>>> #include <string.h>
>>> #include <stdio.h>
>>> #include <fcntl.h>
>>> #include <errno.h>
>>>
>>>
>>> static long fd_max;
>>> static int ep = -1;
>>>
>>>
>>> static int get_fd(void) {
>>>       int fd;
>>>
>>>       for (;;) {
>>>               fd = rand() % fd_max;
>>>
>>>               if (fd > 2 && fd != ep)
>>>                       break;
>>>       }
>>>
>>>       return fd;
>>> }
>>>
>>>
>>> static void *opener(void *ptr) {
>>>       sleep(1);
>>>
>>>       for (;;) {
>>>               if (rand() % 2) {
>>>                       struct sockaddr_un sa = {
>>>                               .sun_family = AF_UNIX,
>>>                               .sun_path = "\0epool_bug-",
>>>                       };
>>>                       int sock = socket(AF_UNIX, SOCK_DGRAM, 0);
>>>                       int err;
>>>
>>>                       /* take a short nap when there are no more fds left so closer() can
>>>                        * catch up */
>>>                       if (sock < 0) {
>>>                               usleep(1);
>>>
>>>                               continue;
>>>                       }
>>>
>>>                       /* ensure the write won't block */
>>>                       fcntl(sock, F_SETFL, fcntl(sock, F_GETFL, 0) | O_NONBLOCK);
>>>
>>>                       sa.sun_path[11] = rand() % 26 + 'A';
>>>                       if (rand() % 2)
>>>                               err = connect(sock, (struct sockaddr *) &sa, sizeof(sa));
>>>                       else
>>>                               err = bind(sock, (struct sockaddr *) &sa, sizeof(sa));
>>>
>>>                       if (err)
>>>                               close(sock);
>>>               } else {
>>>                       static const char dot[] = { [0 ... 1023] = '.' };
>>>
>>>                       write(get_fd(), dot, rand() % 2 ? 1 : sizeof(dot));
>>>               }
>>>       }
>>>
>>>       return ptr;
>>> }
>>>
>>>
>>> static void *closer(void *ptr) {
>>>       int miss = 0;
>>>
>>>       sleep(1);
>>>
>>>       for (;;) {
>>>               errno = 0;
>>>               close(get_fd());
>>>
>>>               /* take a short nap when we're hitting invalid fds 5 times in a row so
>>>                * opener() can catch up */
>>>               if (errno == EBADF && ++miss >= 5) {
>>>                       usleep(10);
>>>                       miss = 0;
>>>               } else if (errno == 0) {
>>>                       miss = 0;
>>>               }
>>>       }
>>>
>>>       return ptr;
>>> }
>>>
>>>
>>> static void *ep_add(void *ptr) {
>>>       sleep(1);
>>>
>>>       for (;;) {
>>>               int fd = get_fd();
>>>               struct epoll_event ev = {
>>>                       .events = EPOLLIN | EPOLLOUT,
>>>                       .data.fd = fd,
>>>               };
>>>
>>>               if (epoll_ctl(ep, EPOLL_CTL_ADD, fd, &ev) < 0 && errno == ENOSPC)
>>>                       usleep(1);
>>>       }
>>>
>>>       return ptr;
>>> }
>>>
>>>
>>> static void *ep_del(void *ptr) {
>>>       sleep(1);
>>>
>>>       for (;;)
>>>               epoll_ctl(ep, EPOLL_CTL_DEL, get_fd(), NULL);
>>>
>>>       return ptr;
>>> }
>>>
>>>
>>> int main(void) {
>>>       pthread_t thread[4];
>>>       int i;
>>>
>>>       signal(SIGPIPE, SIG_IGN);
>>>
>>>       ep = epoll_create(42);  /* use epoll_create() for older kernels */
>>>       if (ep < 0) {
>>>               fprintf(stderr, "err: epoll_create1() failed (%s)\n", strerror(errno));
>>>
>>>               return 1;
>>>       }
>>>
>>>       fd_max = sysconf(_SC_OPEN_MAX);
>>>       if (pthread_create(&thread[0], NULL, opener, NULL) ||
>>>               pthread_create(&thread[1], NULL, closer, NULL) ||
>>>               pthread_create(&thread[2], NULL, ep_add, NULL) ||
>>>               pthread_create(&thread[3], NULL, ep_del, NULL))
>>>       {
>>>               fprintf(stderr, "err: failed to start all threads!\n");
>>>
>>>               return 1;
>>>       }
>>>
>>>       /* XXX: pthread_cancel() all threads on termination request */
>>>
>>>       for (i = 0; i < 4; i++)
>>>               pthread_join(thread[i], NULL);
>>>
>>>       return 0;
>>> }
> 
> Ping. This still triggers on v4.3-rc3.
> Any epoll expert around to have a look at this?
> 
> Regards,
> Mathias
> 

Hi,

So the issue is that unix_dgram_poll() registers not only the wait queue for
socket that we are polling against, but also the wait queue for the socket
'other' with epoll(). So if we have socket s, and we add the socket
s to an epoll set ep, normally, when either the 'ep' set closes or the
socket 's' closes, we remove all references to the wait queue. Now, in this
case we can call connect(), and associated socket 'o', with socket 's'. Thus,
epoll now has a references to both the wait queue for socket 's' *and*
the one for socket 'o'. Now, this works most of the time on close() b/c socket
's' takes a reference on socket 'o' when it does a connect. Thus, if socket
's', 'o' or 'ep' closes we properly unregister things.

However, if we call connect on socket 's', to connect to a new socket 'o2', we
drop the reference on the original socket 'o'. Thus, we can now close socket
'o' without unregistering from epoll. Then, when we either close the ep
or unregister 'o', we end up with this list corruption. Thus, this is not a
race per se, but can be triggered sequentially.

Linus explains the general case in the context the signalfd stuff here:
https://lkml.org/lkml/2013/10/14/634

So this may be the case that we've been chasing here for a while...

In any case, we could fix with that same POLLFREE mechansim, the simplest
would be something like:

diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..d499f81 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -392,6 +392,9 @@ static void unix_sock_destructor(struct sock *sk)
 	pr_debug("UNIX %p is destroyed, %ld are still alive.\n", sk,
 		atomic_long_read(&unix_nr_socks));
 #endif
+	/* make sure we remove from epoll */
+	wake_up_poll(&u->peer_wait, POLLFREE);
+	synchronize_sched();
 }
 
 static void unix_release_sock(struct sock *sk, int embrion)

I'm not suggesting we apply that, but that fixed the supplied test case.
We could enhance the above, to avoid the free'ing latency there by doing
the SLAB_DESTROY_BY_RCU for unix sockets. But I'm not convinced
that this wouldn't be still broken for select()/poll() as well. I think
we can be in a select() call for socket 's', and if we remove socket
'o' from it in the meantime (by doing a connect() on s to somewhere else
and a close on 'o'), I think we can still crash there. So POLLFREE would
have to be extended. I tried to hit this with select() but could not,
but I think if I tried harder I could.

Instead of going further down that route, perhaps something like below
might be better. The basic idea would be to do away with the 'other'
poll call in unix_dgram_poll(), and instead revert back to a registering
on a single wait queue. We add a new wait queue to unix sockets such
that we can register it with a remote other on connect(). Then we can
use the wakeup from the remote to wake up the registered unix socket.
Probably better explained with the patch below. Note I didn't add to
the remote for SOCK_STREAM, since the poll() routine there doesn't do
the double wait queue registering:

diff --git a/include/net/af_unix.h b/include/net/af_unix.h
index 4a167b3..9698aff 100644
--- a/include/net/af_unix.h
+++ b/include/net/af_unix.h
@@ -62,6 +62,7 @@ struct unix_sock {
 #define UNIX_GC_CANDIDATE	0
 #define UNIX_GC_MAYBE_CYCLE	1
 	struct socket_wq	peer_wq;
+	wait_queue_t		wait;
 };
 #define unix_sk(__sk) ((struct unix_sock *)__sk)
 
diff --git a/net/unix/af_unix.c b/net/unix/af_unix.c
index 03ee4d3..9e0692a 100644
--- a/net/unix/af_unix.c
+++ b/net/unix/af_unix.c
@@ -420,6 +420,8 @@ static void unix_release_sock(struct sock *sk, int embrion)
 	skpair = unix_peer(sk);
 
 	if (skpair != NULL) {
+		if (sk->sk_type != SOCK_STREAM)
+			remove_wait_queue(&unix_sk(skpair)->peer_wait, &u->wait);
 		if (sk->sk_type == SOCK_STREAM || sk->sk_type == SOCK_SEQPACKET) {
 			unix_state_lock(skpair);
 			/* No more writes */
@@ -636,6 +638,16 @@ static struct proto unix_proto = {
  */
 static struct lock_class_key af_unix_sk_receive_queue_lock_key;
 
+static int peer_wake(wait_queue_t *wait, unsigned mode, int sync, void *key)
+{
+	struct unix_sock *u;
+
+	u = container_of(wait, struct unix_sock, wait);
+	wake_up_interruptible_sync_poll(sk_sleep(&u->sk), key);
+
+	return 0;
+}
+
 static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 {
 	struct sock *sk = NULL;
@@ -664,6 +676,7 @@ static struct sock *unix_create1(struct net *net, struct socket *sock, int kern)
 	INIT_LIST_HEAD(&u->link);
 	mutex_init(&u->readlock); /* single task reading lock */
 	init_waitqueue_head(&u->peer_wait);
+	init_waitqueue_func_entry(&u->wait, peer_wake);
 	unix_insert_socket(unix_sockets_unbound(sk), sk);
 out:
 	if (sk == NULL)
@@ -1030,7 +1043,10 @@ restart:
 	 */
 	if (unix_peer(sk)) {
 		struct sock *old_peer = unix_peer(sk);
+
+		remove_wait_queue(&unix_sk(old_peer)->peer_wait, &unix_sk(sk)->wait);
 		unix_peer(sk) = other;
+		add_wait_queue(&unix_sk(other)->peer_wait, &unix_sk(sk)->wait);
 		unix_state_double_unlock(sk, other);
 
 		if (other != old_peer)
@@ -1038,8 +1054,12 @@ restart:
 		sock_put(old_peer);
 	} else {
 		unix_peer(sk) = other;
+		add_wait_queue(&unix_sk(other)->peer_wait, &unix_sk(sk)->wait);
 		unix_state_double_unlock(sk, other);
 	}
+	/* New remote may have created write space for us */
+	wake_up_interruptible_sync_poll(sk_sleep(sk),
+					POLLOUT | POLLWRNORM | POLLWRBAND);
 	return 0;
 
 out_unlock:
@@ -1194,6 +1214,8 @@ restart:
 
 	sock_hold(sk);
 	unix_peer(newsk)	= sk;
+	if (sk->sk_type == SOCK_SEQPACKET)
+		add_wait_queue(&unix_sk(sk)->peer_wait, &unix_sk(newsk)->wait);
 	newsk->sk_state		= TCP_ESTABLISHED;
 	newsk->sk_type		= sk->sk_type;
 	init_peercred(newsk);
@@ -1220,6 +1242,8 @@ restart:
 
 	smp_mb__after_atomic();	/* sock_hold() does an atomic_inc() */
 	unix_peer(sk)	= newsk;
+	if (sk->sk_type == SOCK_SEQPACKET)
+		add_wait_queue(&unix_sk(newsk)->peer_wait, &unix_sk(sk)->wait);
 
 	unix_state_unlock(sk);
 
@@ -1254,6 +1278,10 @@ static int unix_socketpair(struct socket *socka, struct socket *sockb)
 	sock_hold(skb);
 	unix_peer(ska) = skb;
 	unix_peer(skb) = ska;
+	if (ska->sk_type != SOCK_STREAM) {
+		add_wait_queue(&unix_sk(ska)->peer_wait, &unix_sk(skb)->wait);
+		add_wait_queue(&unix_sk(skb)->peer_wait, &unix_sk(ska)->wait);
+	}
 	init_peercred(ska);
 	init_peercred(skb);
 
@@ -1565,6 +1593,7 @@ restart:
 		unix_state_lock(sk);
 		if (unix_peer(sk) == other) {
 			unix_peer(sk) = NULL;
+			remove_wait_queue(&unix_sk(other)->peer_wait, &u->wait);
 			unix_state_unlock(sk);
 
 			unix_dgram_disconnected(sk, other);
@@ -2441,7 +2470,6 @@ static unsigned int unix_dgram_poll(struct file *file, struct socket *sock,
 	other = unix_peer_get(sk);
 	if (other) {
 		if (unix_peer(other) != sk) {
-			sock_poll_wait(file, &unix_sk(other)->peer_wait, wait);
 			if (unix_recvq_full(other))
 				writable = 0;
 		}
-- 
1.8.2.rc2



I think this makes more sense too, b/c it can also get the epoll() case
correct where the socket s is connected to a new remote. In the old code
we would continue to get wakeups then from the wrong remote. Here, we
can fix that as well.

There a perhaps a perfomance issue with this approach, since I'm adding
to the poll list on connect(). So even if we are not in a poll(), we are
still walking the list to do wakeups. That may or may not be a big deal,
and I think can be fixed by setting something like the SOCK_NOSPACE bit
in the unix_dgram_poll() when its not writeable, and condition the wakeup
on that. The alternative would be to register with the remote on poll(),
but then the unregister is more complex...

Perhaps, somebody more familiar with the unix socket code can comment
on this. Thanks for the test case!

Thanks,

-Jason
