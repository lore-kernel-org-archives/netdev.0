From: Patrick McHardy <kaber@trash.net>
Subject: Re: Lockup with 2.6.9-ac15 related to netconsole
Date: Wed, 22 Dec 2004 15:57:57 +0100
Message-ID: <41C98B75.9020802@trash.net>
References: <20041221002218.GA1487@electric-eye.fr.zoreil.com> <20041221005521.GD5974@waste.org> <52121.192.102.214.6.1103624620.squirrel@webmail.wetlettuce.com> <20041221123727.GA13606@electric-eye.fr.zoreil.com> <49295.192.102.214.6.1103635762.squirrel@webmail.wetlettuce.com> <20041221204853.GA20869@electric-eye.fr.zoreil.com> <20041221212737.GK5974@waste.org> <20041221225831.GA20910@electric-eye.fr.zoreil.com> <41C93FAB.9090708@trash.net> <41C9525F.4070805@trash.net> <20041222123940.GA4241@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii; format=flowed
Content-Transfer-Encoding: 7bit
Cc: Matt Mackall <mpm@selenic.com>,
	Mark Broadbent <markb@wetlettuce.com>,
	linux-kernel@vger.kernel.org, netdev@oss.sgi.com
Return-path: <linux-kernel-owner+glk-linux-kernel=40m.gmane.org-S261835AbULVO7G@vger.kernel.org>
To: Francois Romieu <romieu@fr.zoreil.com>
In-Reply-To: <20041222123940.GA4241@electric-eye.fr.zoreil.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Francois Romieu wrote:
> Patrick McHardy <kaber@trash.net> :
> [...]
> 
>>at least the queued messages ordered. But you need to grab
>>dev->queue_lock, otherwise you risk corrupting qdisc internal data.
>>You should probably also deal with the noqueue-qdisc, which doesn't
>>have an enqueue function. So it should look something like this:
> 
> 
> If I am not mistaken, a failure on spin_trylock + the test on
> xmit_lock_owner imply that it is safe to directly handle the
> queue. It means that qdisc_run() has been interrupted on the
> current cpu and the other paths seem fine as well. Counter-example
> is welcome (no joke).

enqueue is only protected by dev->queue_lock, and dev->queue_lock
is dropped as soon as dev->xmit_lock is grabbed, so any other CPU
might call enqueue at the same time.

Example:

CPU1					CPU2

dev_queue_xmit				dev_queue_xmit
  lock(dev->queue_lock)			 lock(dev->queue_lock)
q->enqueue
qdisc_run
qdisc_restart
  trylock(dev->xmit_lock), ok
  unlock(dev->queue_lock)
...
printk("something")
...
netpoll_send_skb
  trylock(dev->xmit_lock), fails
q->enqueue				q->enqueue

> Of course the patch is completely ugly and violates any layering
> principle one could think of. It was not submitted for inclusion :o)

Sure, but I think we should have a short-term workaround until
a better solution has been invented. Maybe dropping the packets
would be best for now, it only affects printks issued in paths
starting at qdisc_restart (-> hard_start_xmit -> ...). Queueing
the packets might also cause reordering since not all packets
are queued.

>>while (!spin_trylock(&np->dev->xmit_lock)) {
>>	if (np->dev->xmit_lock_owner == smp_processor_id()) {
>>		struct Qdisc *q;
>>
>>		rcu_read_lock();
>>		q = rcu_dereference(dev->qdisc);
>>		if (q->enqueue) {
>>			spin_lock(&dev->queue_lock);
> 
> 
> I'd expect it to deadlock if dev_queue_xmit -> qdisc_run is interrupted
> on the current cpu and a printk is issued as dev->queue_lock will have
> been taken elsewhere.

Hmm this is complicated, let me think some more about it.

Regards
Patrick
