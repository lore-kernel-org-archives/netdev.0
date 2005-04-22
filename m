From: Jeff Moyer <jmoyer@redhat.com>
Subject: Re: [PATCH 4/7] netpoll: fix ->poll() locking
Date: Fri, 22 Apr 2005 18:24:46 -0400
Message-ID: <17001.31150.194263.732284@segfault.boston.redhat.com>
References: <4.454130102@selenic.com>
	<5.454130102@selenic.com>
Reply-To: jmoyer@redhat.com
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Jeff Garzik <jgarzik@pobox.com>, netdev@oss.sgi.com
Return-path: <netdev-bounce@oss.sgi.com>
To: Matt Mackall <mpm@selenic.com>
In-Reply-To: <5.454130102@selenic.com>
Sender: netdev-bounce@oss.sgi.com
Errors-to: netdev-bounce@oss.sgi.com
List-Id: netdev.vger.kernel.org

==> Regarding [PATCH 4/7] netpoll: fix ->poll() locking; Matt Mackall <mpm@selenic.com> adds:

mpm> Introduce a per-client poll lock and flag. The lock assures we never
mpm> have more than one caller in dev->poll(). The flag provides recursion
mpm> avoidance on UP where the lock disappears.

I don't think it makes sense to have the poll lock associated with a struct
netpoll.  We want to guard simultaneous access to the device's poll
routine.  With this implementation, if we have multiple netpoll clients
running at the same time, we can have multiple callers of dev->poll at the
same time.  In other words, there is not a 1:1 relationship between struct
netpoll's and struct net_device's.

Please consider making this a per device lock.

-Jeff

@@ -74,13 +80,10 @@
 static void poll_napi(struct netpoll *np)
 {
 	int budget = 16;
-	unsigned long flags;
-	struct softnet_data *queue;
 
-	spin_lock_irqsave(&netpoll_poll_lock, flags);
-	queue = &__get_cpu_var(softnet_data);
 	if (test_bit(__LINK_STATE_RX_SCHED, &np->dev->state) &&
-	    !list_empty(&queue->poll_list)) {
+	    np->poll_owner != __smp_processor_id() &&
+	    spin_trylock(&np->poll_lock)) {
 		np->rx_flags |= NETPOLL_RX_DROP;
 		atomic_inc(&trapped);
