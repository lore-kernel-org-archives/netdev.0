From: Benjamin Herrenschmidt <benh@kernel.crashing.org>
Subject: netdev ioctl & dev_base_lock : bad idea ?
Date: Fri, 26 Nov 2004 19:48:49 +1100
Message-ID: <1101458929.28048.9.camel@gaston>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Return-path: <netdev-bounce@oss.sgi.com>
To: netdev@oss.sgi.com
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

Hi !

While working on simplifying sungem, I had a problem with locking.
Basically, I'm forced to do a lot of things under spinlocks, a lot more
than I should have to, because in a few places, I can't schedule. This
is typically the case of ioctl handling, and more specifically,
change_mtu() and set_multicast() callbacks.

For some reason, a while ago, those calls got a
read_lock(&dev_base_lock) added aroud them in net/core/dev.c. That means
they can't schedule, which is by itself a problem, since it force them
to use spinlocks as a synchronisation primitive and prevents them to
call netif_stop_polling(). Thus, they can't stop NAPI, which force the
napi poll() callback to take a lock too (we end up with 2 locks in there
now in sungem) while some careful coding (stopping the queue, stopping
polling, stopping chip irqs) could have permitted to not do any locking
and eventually schedule in a few places where I need to wait some time
instead of udelay.

I suppose there is a good reason we can't just use the rtnl_sem for
these guys, though why isn't dev_base_lock a read/write semaphore
instead of a spinlock ? At least on ppc, I don't think there's any
overhead in the normal path, and this is not on a very critical path
anyway, is it ?

Since we never take this lock with irq masking, I suppose there is no
problem with trying to lock at irq time, is there ? Or may we try to
acquire it occasionally from some contexts where a spinlock is already
held ?

Ben.
