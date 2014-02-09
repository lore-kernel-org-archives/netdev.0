From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: 6lowpan: lockless tx queue of routing netlink device
Date: Sun, 09 Feb 2014 04:41:47 -0800
Message-ID: <1391949707.10160.130.camel@edumazet-glaptop2.roam.corp.google.com>
References: <20140209102047.GA14770@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, linux-zigbee-devel@lists.sourceforge.net
To: Alexander Aring <alex.aring@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f174.google.com ([209.85.192.174]:46694 "EHLO
	mail-pd0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751360AbaBIMlt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 9 Feb 2014 07:41:49 -0500
Received: by mail-pd0-f174.google.com with SMTP id z10so4945861pdj.5
        for <netdev@vger.kernel.org>; Sun, 09 Feb 2014 04:41:49 -0800 (PST)
In-Reply-To: <20140209102047.GA14770@omega>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, 2014-02-09 at 11:20 +0100, Alexander Aring wrote:
> Hi,
> 
> I got some locking issues with CONFIG_PROVE_LOCKING enabled and need help.
> 
> Full output:
> 
> =============================================
> [ INFO: possible recursive locking detected ]
> 3.13.0-08605-g8f2b630-dirty #105 Not tainted
> ---------------------------------------------
> agetty/841 is trying to acquire lock:
>  (_xmit_IEEE802154#2){+.-...}, at: [<c0356b39>] sch_direct_xmit+0x34/0x122
> 
> but task is already holding lock:
>  (_xmit_IEEE802154#2){+.-...}, at: [<c0346926>] __dev_queue_xmit+0x26e/0x329
> 
> other info that might help us debug this:
>  Possible unsafe locking scenario:
> 
>        CPU0
>        ----
>   lock(_xmit_IEEE802154#2);
>   lock(_xmit_IEEE802154#2);
> 
>  *** DEADLOCK ***
> 
>  May be due to missing lock nesting notation
> 
> 6 locks held by agetty/841:
>  #0:  (((&idev->mc_ifc_timer))){+.-...}, at: [<c012b6f2>] call_timer_fn+0x0/0xb3
>  #1:  (rcu_read_lock){.+.+..}, at: [<c03b4335>] rcu_read_lock+0x0/0x21
>  #2:  (rcu_read_lock_bh){.+....}, at: [<c039d39d>] rcu_lock_acquire+0x0/0x1c
>  #3:  (rcu_read_lock_bh){.+....}, at: [<c03426e5>] rcu_lock_acquire+0x0/0x1c
>  #4:  (_xmit_IEEE802154#2){+.-...}, at: [<c0346926>] __dev_queue_xmit+0x26e/0x329
>  #5:  (rcu_read_lock_bh){.+....}, at: [<c03426e5>] rcu_lock_acquire+0x0/0x1c
> 
> 
> 
> The solution was for me to change
> dev->type = ARPHRD_IEEE802154
> to
> dev->type = ARPHRD_6LOWPAN
> of the rtnl device. What we really shall do in the near future. (I have
> a patch for this).
> 
> 
> Another solution was to add:
> dev->features           |= NETIF_F_LLTX;
> in setup callback of rtnl device.
> 
> 
> This enables a lockless tx queue.
> I am not sure if we can do a lockless tx queue here and the comment of
> NETIF_F_LLTX says it's deprecated "/* do not use LLTX in new drivers */".
> Exists there some alternative for this?
> 
> 
> 
> So a little bit more information about the current architecture which is
> a little bit complex for tx. Maybe then it's more clear how to fix this
> issue correctly.
> 
> To setup a lowpan interface you need to run:
> "ip link add link $WPAN_INTERFACE name $LOWPAN_INTERFACE type lowpan"
> 
> This setups a lowpan interface which "sitting" on top of the
> $WPAN_INTERFACE.
> 
> The lowpan rtnl implementation saves pointers from both interfaces we
> name it:
> 
> "real_dev" <-- WPAN_INTERFACE
> "dev" <-- LOWPAN_INTERFACE
> 
> 
> If we get some "usually" ipv6 packets from LOWPAN_INTERFACE which calls
> header_create function, then we doing some manipulating of sk_buff there.
> 
> After this we calling dev_hard_header with the callback of
> WPAN_INTERFACE to generate the mac header.
> 
> Then we are in the xmit callback of LOWPAN_INTERFACE and doing a
> skb->dev pointer change from LOWPAN_INTERFACE to the WPAN_INTERFACE and
> calling dev_queue_xmit to send it via the WPAN_INTERFACE.
> The skb->dev switch is necessary because we call then the xmit callback
> of the WPAN_INTERFACE, the LOWPAN_INTERFACE is more a "virtual" interface.
> 
> I think that's the problem. We have two dev_queue_xmit calls first from 
> LOWPAN_INTERFACE then the WPAN_INTERFACE, so we locking something twice.
> 
> 
> That's very much complicated and I think we doing some hacked stuff
> there but currently it works so (except the locking issue). :-)

Please try the following fix, thanks for this report !

diff --git a/net/ieee802154/6lowpan.c b/net/ieee802154/6lowpan.c
index 48b25c0af4d0..069af33013c4 100644
--- a/net/ieee802154/6lowpan.c
+++ b/net/ieee802154/6lowpan.c
@@ -533,7 +533,27 @@ static struct header_ops lowpan_header_ops = {
 	.create	= lowpan_header_create,
 };
 
+static struct lock_class_key lowpan_tx_busylock;
+static struct lock_class_key lowpan_netdev_xmit_lock_key;
+
+static void lowpan_set_lockdep_class_one(struct net_device *dev,
+					 struct netdev_queue *txq,
+					 void *_unused)
+{
+	lockdep_set_class(&txq->_xmit_lock,
+			  &lowpan_netdev_xmit_lock_key);
+}
+
+
+static int lowpan_dev_init(struct net_device *dev)
+{
+	netdev_for_each_tx_queue(dev, lowpan_set_lockdep_class_one, NULL);
+	dev->qdisc_tx_busylock = &lowpan_tx_busylock;
+	return 0;
+}
+
 static const struct net_device_ops lowpan_netdev_ops = {
+	.ndo_init		= lowpan_dev_init,
 	.ndo_start_xmit		= lowpan_xmit,
 	.ndo_set_mac_address	= lowpan_set_address,
 };
