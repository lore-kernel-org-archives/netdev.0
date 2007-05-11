From: "Satyam Sharma" <satyam.sharma@gmail.com>
Subject: Re: 2.6.21-rc7: BUG: sleeping function called from
	invalid context at net/core/sock.c:1523
Date: Fri, 11 May 2007 18:59:31 +0530
Message-ID: <a781481a0705110629n7c7130c1x3a89fa958b271f20@mail.gmail.com>
References: <462D1B09.9050005@goop.org>
	<Pine.LNX.4.64.0704232257090.20657@twin.jikos.cz>
	<Pine.LNX.4.64.0704261625410.20657@twin.jikos.cz>
Reply-To: BlueZ development <bluez-devel@lists.sourceforge.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Jeremy Fitzhardinge <jeremy@goop.org>, netdev@vger.kernel.org,
	Marcel Holtmann <marcel@holtmann.org>, Greg KH <gregkh@suse.de>,
	Linux Kernel Mailing List <linux-kernel@vger.kernel.org>,
	Cedric Le Goater <clg@fr.ibm.com>, bluez-devel@lists.sourceforge.net,
	maxk@qualcomm.com
To: "Jiri Kosina" <jikos@jikos.cz>
Return-path: <bluez-devel-bounces@lists.sourceforge.net>
In-Reply-To: <Pine.LNX.4.64.0704261625410.20657@twin.jikos.cz>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=bluez-devel>
List-Post: <mailto:bluez-devel@lists.sourceforge.net>
List-Help: <mailto:bluez-devel-request@lists.sourceforge.net?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/bluez-devel>,
	<mailto:bluez-devel-request@lists.sourceforge.net?subject=subscribe>
Sender: bluez-devel-bounces@lists.sourceforge.net
Errors-To: bluez-devel-bounces@lists.sourceforge.net
List-Id: netdev.vger.kernel.org

Hi Jiri,

On 4/26/07, Jiri Kosina <jikos@jikos.cz> wrote:
> On Mon, 23 Apr 2007, Jiri Kosina wrote:
>
> > > BUG: sleeping function called from invalid context at net/core/sock.c:1523
> > > in_atomic():1, irqs_disabled():0
> > > 1 lock held by khubd/180:
> > >  #0:  (old_style_rw_init#2){-.-?}, at: [<f88c5816>] hci_sock_dev_event+0x42/0xc5 [bluetooth]
> [...]
> > OK, this probably started happening since b40df5743. Before that commit,
> > hci_sock_dev_event() used bh_lock_sock() to lock the corresponding
> > struct sock. This was obviously buggy - not deadlock safe against
> > l2cap_connect_cfm() from softirq context. This however introduced
> > another problem - hci_sock_dev_event() is now obviously being triggered
> > (for HCI_DEV_UNREG event, when suspending) in atomic context with

I saw that hci_sock_dev_event() is _always_ triggered in atomic
context. It's the callout for hci_notifier which is defined as an
atomic notifier chain (hence executed in an RCU read section -- and
sleeping inside that would be illegal).

> > preemption disabled. This is what lock_sock_nested() complains about, as
> > it is allowed to sleep inside __lock_sock(), waiting for the lock owner.
> [...]
> Bluetooth: postpone hci_dev unregistration
>
> Commit b40df57 substituted bh_lock_sock() in hci_sock_dev_event() for
> lock_sock() when unregistering HCI device, in order to prevent deadlock
> against locking in l2cap_connect_cfm() from softirq context.

Isn't this a problem faced by other places in the kernel already
(where simply using bh_lock_sock() would potentially deadlock with
another thread? I wonder what's the "recommended" (or one that's
generally used) way to handle such a case.

> This however introduces another problem - hci_sock_dev_event() for
> HCI_DEV_UNREG can also be triggered in atomic context, in which calling

Actually, I remember going over the hci_sock_dev_event() calling
codepath (in reverse) quite exhaustively, and did not find a
legitimate reason why anybody would want it to be atomic. hci_notify()
has six call sites, and all are sleep-capable, IMO. In the case of
hci_unregister_dev(), for example, what's happening is as follows:

__device_release_driver			(can sleep)
usb_unbind_interface			(-"-)
hci_usb_disconnect [hci_usb]		(can sleep *[1])
hci_unregister_dev [bluetooth]		(-"-)
hci_notify [bluetooth]			(-"-)
atomic_notifier_call_chain		(contains RCU read section)
notifier_call_chain			(therefore, CANNOT SLEEP [2])
hci_sock_dev_event [bluetooth]		(-"-)
lock_sock_nested			(MIGHT SLEEP *BUG*)
__might_sleep

[1] This is the first problem point. However, I didn't find any reason
why this particular driver's .disconnect() couldn't sleep. In fact, a
comment in include/linux/usb.h:811 says:

"The probe() and disconnect() methods are called in a context where
they can sleep, but they should avoid abusing the privilege. Most
work to connect to a device should be done when the device is opened,
and undone at the last close. The disconnect code needs to address
concurrency issues with respect to open() and close() methods, as
well as forcing all pending I/O requests to complete (by unlinking
them as necessary, and blocking until the unlinks complete)."

I'm assuming the comment is not obsolete, of course, but although the
first sentence says .disconnect() shouldn't abuse the privilege to
sleep, the last sentence makes it quite evident that we are _allowed_
to do so anyway, and that is how things are (with the hci_usb driver,
at least, I didn't check the .remove() or .disconnect() functions of other
USB drivers, however).

[2] This is a bogus (and unnecessary) can-sleep-to-cannot-sleep
transition point, IMO. I had copied Alan Stern in another thread a few
days back, and he wasn't sure why hci_notifier was classified as an
atomic notifier chain (when that classification happened with the new
notifier chains API). I had submitted a patch that merely changed 4
lines in net/bluetooth/hci_core.c to convert hci_notifier to a blocking
notifier chain, but couldn't test as I own no bluetooth hardware myself.

So do we ever really _need_ hci_sock_dev_event() to run in atomic
context at all?

> lock_sock() is not safe as it could sleep.
>
> This patch moves the detaching of sockets from hci_device into workqueue,
> so that lock_sock() can be used safely. This requires movement of

I did a workqueue conversion myself, but ran into the following problem:

In the scheduled work function we have:

> +       read_lock(&hci_sk_list.lock);
> +       sk_for_each(sk, node, &hci_sk_list.head) {
> +               lock_sock(sk);

This would still be illegal, we can't sleep while holding an rwlock
(hci_sk_list.lock above). Converting hci_sk_list.lock to an rwsem
is _even_ more problematic, because hci_send_to_sock()
just *cannot* sleep.

> deallocation of hci_dev - deallocating device just after
> hci_unregister_dev() would be too soon, as it could happen before the
> workqueue has been run.

Suggest a better solution for this: just introduce a flush_scheduled_work()
after hci_unregister_dev() but before hci_free_dev() in all those places.
Less disruptive that way.

So this is quite an interesting problem indeed, but I can't help wondering
that this must be faced elsewhere in the kernel (other users of lock_sock)
too. CC'ing netdev@, for any ideas.

(later)

I Googled a bit to see if this problem was faced elsewhere in the kernel
too. Saw the following commit by Ingo Molnar
(9883a13c72dbf8c518814b6091019643cdb34429):

-	lock_sock(sock->sk);
+	local_bh_disable();
+	bh_lock_sock_nested(sock->sk);
 	rc = selinux_netlbl_socket_setsid(sock, sksec->sid);
-	release_sock(sock->sk);
+	bh_unlock_sock(sock->sk);
+	local_bh_enable();

Is it _really_ *this* simple?

Satyam

-------------------------------------------------------------------------
This SF.net email is sponsored by DB2 Express
Download DB2 Express C - the FREE version of DB2 express and take
control of your XML. No limits. Just data. Click to get it now.
http://sourceforge.net/powerbar/db2/
