From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net] net: do not process device backlog during
 unregistration
Date: Mon, 29 Jun 2015 23:33:47 +0300 (EEST)
Message-ID: <alpine.LFD.2.11.1506292241230.1739@ja.home.ssi.bg>
References: <1435420971-19263-1-git-send-email-ja@ssi.bg> <876167wt2p.fsf@x220.int.ebiederm.org>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	"Vittorio G (VittGam)" <linuxbugs@vittgam.net>
To: "Eric W. Biederman" <ebiederm@xmission.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:56300 "EHLO ja.ssi.bg"
	rhost-flags-OK-FAIL-OK-FAIL) by vger.kernel.org with ESMTP
	id S1750834AbbF2Udy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 29 Jun 2015 16:33:54 -0400
In-Reply-To: <876167wt2p.fsf@x220.int.ebiederm.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sun, 28 Jun 2015, Eric W. Biederman wrote:

> Julian Anastasov <ja@ssi.bg> writes:
> 
> > commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
> > fixes a problem where processed packet comes from device
> > with destroyed inetdev (dev->ip_ptr). This is not expected
> > because inetdev_destroy is called in NETDEV_UNREGISTER
> > phase and packets should not be processed after
> > dev_close_many() and synchronize_net(). But backlog
> > processing is deactivated later after NETDEV_UNREGISTER_FINAL
> > phase which allows CPUs to initiate processing for new
> > packets during and after the NETDEV_UNREGISTER phase.
> >
> > Fix it by moving flush_backlog after the device driver
> > is stopped and before the synchronize_net() call. This
> > allows dev->ip_ptr to be always valid during packet
> > processing.
> 
> Do you have any evidence that there are other places that care
> besides the location in ip_error?

	Examples like that are not many because code is full with
in_dev checks:

- fib_compute_spec_dst: BUG_ON(!in_dev);

	This may need additional fix...

	But the fact is that sd->process_queue can contain
many packets and the synchronize_net call can stop maximum one
packet of them. So, we can reach NETDEV_UNREGISTER chain
while at the same time process_backlog continues to deliver
more packets. Soon, we may start to work with freed dev->ip_ptr.
The window is very small: from seeing dev->ip_ptr != NULL
to using the in_device fields. We may need slow hardirq that
can interrupt the packet processing and to crash on such
use-after-free case.

> If not this patch should be a canidate for net-next which is currently
> closed until after the merge window.
> 
> The testing is difficult and I was never able to reproduce the actual
> crash.  So I do not know how much evidence should come from testing.

	I guess, chance for crash can be increased if
large value is used for /proc/sys/net/core/netdev_max_backlog
but it looks difficult to reproduce such races.

> That said this patch actually appears wrong.  Nothing in the veth driver
> that I can see will cause packets from the other side to not be
> transmitted when only one side is closed.

	veth looks correct because veth_dellink is called
with head!=NULL.

> Further even assuming that dev_close_many actually works and causes no
> new packets to be processed there is the larger problem of calling
> flush_backlog before syncrhonize_net.   Things happening in rcu
> criticial sections (aka enqueuing packets to the backlog) are not
> expected to stop until after the end of the critical section
> and we are not out of the critical section until after synchronize_net.

	You are right. So, below is my next attempt,
still not tested. I'm trying to avoid processing for
enqueued packets. Sadly, enqueue_to_backlog() is used
both on rx (eg. NAPI) and on loop (eg. loopback_xmit) but
we are only interested to avoid enqueue_to_backlog for
the loop case. And as the looped packet may not notice
the new device state, we have to execute smp_mb on all
other CPUs and to add check in fast path. I hope I'm
doing it correctly...

> So while this work looks interesting, I don't think this is a fix for
> a serious bug, and I don't think you have yet created a correct patch.
> 
> Eric

RFC patch:

Subject: [PATCHv2 net] net: do not process device backlog during
 unregistration

commit 381c759d9916 ("ipv4: Avoid crashing in ip_error")
fixes a problem where processed packet comes from device
with destroyed inetdev (dev->ip_ptr). This is not expected
because inetdev_destroy is called in NETDEV_UNREGISTER
phase and packets should not be processed after
dev_close_many() and synchronize_net(). But backlog
processing is deactivated later after NETDEV_UNREGISTER_FINAL
phase which allows CPUs to initiate processing for new
packets during and after the NETDEV_UNREGISTER phase.

As new packets can be enqueued during processing we have
to drop them by adding new netif_running check after
memory barrier executed on every CPU.

Reported-by: Vittorio Gambaletta <linuxbugs@vittgam.net>
Fixes: 6e583ce5242f ("net: eliminate refcounting in backlog queue")
Signed-off-by: Julian Anastasov <ja@ssi.bg>
---
 net/core/dev.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index aa82f9a..28d76307 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -3670,6 +3670,8 @@ static int __netif_receive_skb_core(struct sk_buff *skb, bool pfmemalloc)
 	rcu_read_lock();
 
 another_round:
+	if (!netif_running(skb->dev))
+		goto drop;
 	skb->skb_iif = skb->dev->ifindex;
 
 	__this_cpu_inc(softnet_data.processed);
@@ -5992,6 +5994,11 @@ static void net_set_todo(struct net_device *dev)
 	dev_net(dev)->dev_unreg_count++;
 }
 
+static void force_netif_barrier_func(void *arg)
+{
+	/* smp_mb in csd_unlock */
+}
+
 static void rollback_registered_many(struct list_head *head)
 {
 	struct net_device *dev, *tmp;
@@ -6029,6 +6036,8 @@ static void rollback_registered_many(struct list_head *head)
 		dev->reg_state = NETREG_UNREGISTERING;
 	}
 
+	/* Make sure other CPUs see the new netif_running state */
+	on_each_cpu(force_netif_barrier_func, NULL, 1);
 	synchronize_net();
 
 	list_for_each_entry(dev, head, unreg_list) {
-- 
1.9.3
