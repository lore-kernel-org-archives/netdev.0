From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] net: Fix spinlock use in alloc_netdev_mq()
Date: Thu, 6 Aug 2009 10:31:02 +0200
Message-ID: <20090806083102.GA3737@psychotron.englab.brq.redhat.com>
References: <20090804.125742.32009006.davem@davemloft.net> <20090805070205.GA8741@elte.hu> <20090805071411.GA9217@elte.hu> <20090805071658.GA14073@elte.hu> <20090805084746.GA3897@psychotron.englab.brq.redhat.com> <20090805101327.2c49cc62.akpm@linux-foundation.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Ingo Molnar <mingo@elte.hu>, David Miller <davem@davemloft.net>,
	Peter Zijlstra <a.p.zijlstra@chello.nl>,
	torvalds@linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, eric.dumazet@gmail.com
To: Andrew Morton <akpm@linux-foundation.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1754450AbZHFIbh@vger.kernel.org>
Content-Disposition: inline
In-Reply-To: <20090805101327.2c49cc62.akpm@linux-foundation.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Wed, Aug 05, 2009 at 07:13:27PM CEST, akpm@linux-foundation.org wrote:
>On Wed, 5 Aug 2009 10:47:47 +0200 Jiri Pirko <jpirko@redhat.com> wrote:
>
>> >it's using an zero-initialized spinlock. This is a side-effect of:
>> >
>> >        dev_unicast_init(dev);
>> >
>> >in alloc_netdev_mq() making use of dev->addr_list_lock.
>> >
>> >The device has just been allocated freshly, it's not accessible
>> >anywhere yet so no locking is needed at all - in fact it's wrong
>> >to lock it here (the lock isnt initialized yet).
>> 
>> Yes this looks like the right approach. Sorry for this bug :(
>
>Really?
>
>> >--- a/net/core/dev.c
>> >+++ b/net/core/dev.c
>> >@@ -4007,9 +4007,7 @@ static void dev_unicast_flush(struct net_device *dev)
>> > 
>> > static void dev_unicast_init(struct net_device *dev)
>> > {
>> >-	netif_addr_lock_bh(dev);
>> > 	__hw_addr_init(&dev->uc);
>> >-	netif_addr_unlock_bh(dev);
>> > }
>
>This means that the net_device is still floating around for quite a
>long time with an uninitialised spinlock, so it will be quite easy for
>the same problem to reoccur as the code evolves.
>
>It would be more robust were we to initialise that lock close to the
>netdev's allocation site.

Hmm, I see your point here. Eric previously posted patch which moved spin lock
init into alloc_netdev_mq(). But he was worried about having it here and
netdev_set_addr_lockdep_class() in register_netdevice() (because before
dev_unicast_init() dev->type is not set). So how about the following patch?

[PATCH net-2.6] net: move address lists spinlock closer to alloc and do unicast_init locking

Move spin_lock_init(), netdev_set_addr_lockdep_class() and dev_unicast_init()
right after setup is called from alloc_netdev_mq(). In that moment dev->type is
initialized. List is not needed to be initialized earlier. Also restore
previously removed locking in dev_unicast_init().

Signed-off-by: Jiri Pirko <jpirko@redhat.com>

diff --git a/net/core/dev.c b/net/core/dev.c
index 6a94475..916a6d0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4007,7 +4007,9 @@ static void dev_unicast_flush(struct net_device *dev)
 
 static void dev_unicast_init(struct net_device *dev)
 {
+	netif_addr_lock_bh(dev);
 	__hw_addr_init(&dev->uc);
+	netif_addr_unlock_bh(dev);
 }
 
 
@@ -4726,8 +4728,6 @@ int register_netdevice(struct net_device *dev)
 	BUG_ON(dev->reg_state != NETREG_UNINITIALIZED);
 	BUG_ON(!net);
 
-	spin_lock_init(&dev->addr_list_lock);
-	netdev_set_addr_lockdep_class(dev);
 	netdev_init_queue_locks(dev);
 
 	dev->iflink = -1;
@@ -5107,8 +5107,6 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	if (dev_addr_init(dev))
 		goto free_tx;
 
-	dev_unicast_init(dev);
-
 	dev_net_set(dev, &init_net);
 
 	dev->_tx = tx;
@@ -5123,6 +5121,11 @@ struct net_device *alloc_netdev_mq(int sizeof_priv, const char *name,
 	dev->priv_flags = IFF_XMIT_DST_RELEASE;
 	setup(dev);
 	strcpy(dev->name, name);
+
+	spin_lock_init(&dev->addr_list_lock);
+	netdev_set_addr_lockdep_class(dev);
+	dev_unicast_init(dev);
+
 	return dev;
 
 free_tx:
>
