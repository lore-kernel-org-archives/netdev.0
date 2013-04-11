From: Neil Horman <nhorman@tuxdriver.com>
Subject: Re: [PATCH RFC] spinlock: split out debugging check from
 spin_lock_mutex
Date: Thu, 11 Apr 2013 15:14:09 -0400
Message-ID: <20130411191409.GA9790@hmsreliant.think-freely.org>
References: <5166BDAA.3000603@acm.org>
 <1365693486-6315-1-git-send-email-nhorman@tuxdriver.com>
 <5166F35B.1040200@acm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Bart Van Assche <bvanassche@acm.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from charlotte.tuxdriver.com ([70.61.120.58]:59521 "EHLO
	smtp.tuxdriver.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752496Ab3DKTOS (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 11 Apr 2013 15:14:18 -0400
Content-Disposition: inline
In-Reply-To: <5166F35B.1040200@acm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, Apr 11, 2013 at 07:31:07PM +0200, Bart Van Assche wrote:
> On 04/11/13 17:18, Neil Horman wrote:
> >Bart, this patch should fix your problem.  Could you please test it =
and confirm?
>=20
> The fails to build on my setup after having applied that patch:
>=20
> kernel/mutex.c: In function =E2=80=98__mutex_trylock_slowpath=E2=80=99=
:
> kernel/mutex.c:446:2: error: implicit declaration of function
> =E2=80=98spin_unlock_mutex_raw=E2=80=99 [-Werror=3Dimplicit-function-=
declaration]
>=20
> Bart.
>=20


Sorry, turned out to be a stupid typo on my part.  This is a fixed vers=
ion, I've
verified that it builds with and without CONFIG_DEBUG_MUTEXS enabled


commit 2f78b4659f119302849f2b753cc1fe5ee87125bc
Author: Neil Horman <nhorman@tuxdriver.com>
Date:   Thu Apr 11 11:05:12 2013 -0400

    spinlock: split out debugging check from spin_lock_mutex
   =20
    Bart, this patch should fix your problem.  Could you please test it=
 and confirm?
   =20
    Bart Van Assche recently reported a warning to me:
   =20
    <IRQ>  [<ffffffff8103d79f>] warn_slowpath_common+0x7f/0xc0
     [<ffffffff8103d7fa>] warn_slowpath_null+0x1a/0x20
     [<ffffffff814761dd>] mutex_trylock+0x16d/0x180
     [<ffffffff813968c9>] netpoll_poll_dev+0x49/0xc30
     [<ffffffff8136a2d2>] ? __alloc_skb+0x82/0x2a0
     [<ffffffff81397715>] netpoll_send_skb_on_dev+0x265/0x410
     [<ffffffff81397c5a>] netpoll_send_udp+0x28a/0x3a0
     [<ffffffffa0541843>] ? write_msg+0x53/0x110 [netconsole]
     [<ffffffffa05418bf>] write_msg+0xcf/0x110 [netconsole]
     [<ffffffff8103eba1>] call_console_drivers.constprop.17+0xa1/0x1c0
     [<ffffffff8103fb76>] console_unlock+0x2d6/0x450
     [<ffffffff8104011e>] vprintk_emit+0x1ee/0x510
     [<ffffffff8146f9f6>] printk+0x4d/0x4f
     [<ffffffffa0004f1d>] scsi_print_command+0x7d/0xe0 [scsi_mod]
   =20
    This resulted from my commit ca99ca14c which introduced a mutex_try=
lock
    operation in a path that could execute in interrupt context.  When =
mutex
    debugging is enabled, the above warns the user when we are in fact =
exectuting in
    interrupt context.
   =20
    I think this is a false positive however.  The check is intended to=
 catch users
    who might be issuing sleeping calls in irq context, but the use of =
mutex_trylock
    here is guaranteed not to sleep.
   =20
    We could fix this by replacing the DEBUG_LOCK_WARN_ON check in spin=
_lock_mutex
    with a __might_sleep call in the appropriate parent mutex operation=
s, but for
    the sake of effiency (which It seems is why the check was put in th=
e spin lock
    code only when debug is enabled), lets split the spin_lock_mutex ca=
ll into two
    components, where the outer component does the debug checking.  The=
n
    mutex_trylock can just call the inner part as its callable from irq=
 context
    safely.
   =20
    Signed-off-by: Neil Horman <nhorman@tuxdriver.com>
    Reported-by: Bart Van Assche <bvanassche@acm.org>
    CC: Bart Van Assche <bvanassche@acm.org>
    CC: David Miller <davem@davemloft.net>
    CC: netdev@vger.kernel.org

diff --git a/kernel/mutex-debug.h b/kernel/mutex-debug.h
index 0799fd3..aac0858 100644
--- a/kernel/mutex-debug.h
+++ b/kernel/mutex-debug.h
@@ -37,13 +37,19 @@ static inline void mutex_clear_owner(struct mutex *=
lock)
 	lock->owner =3D NULL;
 }
=20
+#define spin_lock_mutex_raw(lock, flags)		\
+	do {						\
+							\
+		local_irq_save(flags);			\
+		arch_spin_lock(&(lock)->rlock.raw_lock);\
+	} while (0)
+
 #define spin_lock_mutex(lock, flags)			\
 	do {						\
 		struct mutex *l =3D container_of(lock, struct mutex, wait_lock); \
 							\
 		DEBUG_LOCKS_WARN_ON(in_interrupt());	\
-		local_irq_save(flags);			\
-		arch_spin_lock(&(lock)->rlock.raw_lock);\
+		spin_lock_mutex_raw(lock, flags);	\
 		DEBUG_LOCKS_WARN_ON(l->magic !=3D l);	\
 	} while (0)
=20
diff --git a/kernel/mutex.c b/kernel/mutex.c
index 52f2301..a62a5f8 100644
--- a/kernel/mutex.c
+++ b/kernel/mutex.c
@@ -431,7 +431,7 @@ static inline int __mutex_trylock_slowpath(atomic_t=
 *lock_count)
 	unsigned long flags;
 	int prev;
=20
-	spin_lock_mutex(&lock->wait_lock, flags);
+	spin_lock_mutex_raw(&lock->wait_lock, flags);
=20
 	prev =3D atomic_xchg(&lock->count, -1);
 	if (likely(prev =3D=3D 1)) {
diff --git a/kernel/mutex.h b/kernel/mutex.h
index 4115fbf..af6ffb4 100644
--- a/kernel/mutex.h
+++ b/kernel/mutex.h
@@ -11,6 +11,8 @@
=20
 #define spin_lock_mutex(lock, flags) \
 		do { spin_lock(lock); (void)(flags); } while (0)
+#define spin_lock_mutex_raw(lock, flags) spin_lock_mutex((lock), (flag=
s))
+
 #define spin_unlock_mutex(lock, flags) \
 		do { spin_unlock(lock); (void)(flags); } while (0)
 #define mutex_remove_waiter(lock, waiter, ti) \
