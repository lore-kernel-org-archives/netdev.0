From: Alexander Aring <alex.aring-Re5JQEeQqe8AvxtiuMwx3w@public.gmane.org>
Subject: 6lowpan: lockless tx queue of routing netlink
	device
Date: Sun, 9 Feb 2014 11:20:49 +0100
Message-ID: <20140209102047.GA14770@omega>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
To: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Return-path: <linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
Content-Disposition: inline
List-Unsubscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=unsubscribe>
List-Archive: <http://sourceforge.net/mailarchive/forum.php?forum_name=linux-zigbee-devel>
List-Post: <mailto:linux-zigbee-devel-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org>
List-Help: <mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=help>
List-Subscribe: <https://lists.sourceforge.net/lists/listinfo/linux-zigbee-devel>,
	<mailto:linux-zigbee-devel-request-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org?subject=subscribe>
Errors-To: linux-zigbee-devel-bounces-5NWGOfrQmneRv+LV9MX5uipxlwaOVQ5f@public.gmane.org
List-Id: netdev.vger.kernel.org

Hi,

I got some locking issues with CONFIG_PROVE_LOCKING enabled and need help.

Full output:

=============================================
[ INFO: possible recursive locking detected ]
3.13.0-08605-g8f2b630-dirty #105 Not tainted
---------------------------------------------
agetty/841 is trying to acquire lock:
 (_xmit_IEEE802154#2){+.-...}, at: [<c0356b39>] sch_direct_xmit+0x34/0x122

but task is already holding lock:
 (_xmit_IEEE802154#2){+.-...}, at: [<c0346926>] __dev_queue_xmit+0x26e/0x329

other info that might help us debug this:
 Possible unsafe locking scenario:

       CPU0
       ----
  lock(_xmit_IEEE802154#2);
  lock(_xmit_IEEE802154#2);

 *** DEADLOCK ***

 May be due to missing lock nesting notation

6 locks held by agetty/841:
 #0:  (((&idev->mc_ifc_timer))){+.-...}, at: [<c012b6f2>] call_timer_fn+0x0/0xb3
 #1:  (rcu_read_lock){.+.+..}, at: [<c03b4335>] rcu_read_lock+0x0/0x21
 #2:  (rcu_read_lock_bh){.+....}, at: [<c039d39d>] rcu_lock_acquire+0x0/0x1c
 #3:  (rcu_read_lock_bh){.+....}, at: [<c03426e5>] rcu_lock_acquire+0x0/0x1c
 #4:  (_xmit_IEEE802154#2){+.-...}, at: [<c0346926>] __dev_queue_xmit+0x26e/0x329
 #5:  (rcu_read_lock_bh){.+....}, at: [<c03426e5>] rcu_lock_acquire+0x0/0x1c



The solution was for me to change
dev->type = ARPHRD_IEEE802154
to
dev->type = ARPHRD_6LOWPAN
of the rtnl device. What we really shall do in the near future. (I have
a patch for this).


Another solution was to add:
dev->features           |= NETIF_F_LLTX;
in setup callback of rtnl device.


This enables a lockless tx queue.
I am not sure if we can do a lockless tx queue here and the comment of
NETIF_F_LLTX says it's deprecated "/* do not use LLTX in new drivers */".
Exists there some alternative for this?



So a little bit more information about the current architecture which is
a little bit complex for tx. Maybe then it's more clear how to fix this
issue correctly.

To setup a lowpan interface you need to run:
"ip link add link $WPAN_INTERFACE name $LOWPAN_INTERFACE type lowpan"

This setups a lowpan interface which "sitting" on top of the
$WPAN_INTERFACE.

The lowpan rtnl implementation saves pointers from both interfaces we
name it:

"real_dev" <-- WPAN_INTERFACE
"dev" <-- LOWPAN_INTERFACE


If we get some "usually" ipv6 packets from LOWPAN_INTERFACE which calls
header_create function, then we doing some manipulating of sk_buff there.

After this we calling dev_hard_header with the callback of
WPAN_INTERFACE to generate the mac header.

Then we are in the xmit callback of LOWPAN_INTERFACE and doing a
skb->dev pointer change from LOWPAN_INTERFACE to the WPAN_INTERFACE and
calling dev_queue_xmit to send it via the WPAN_INTERFACE.
The skb->dev switch is necessary because we call then the xmit callback
of the WPAN_INTERFACE, the LOWPAN_INTERFACE is more a "virtual" interface.

I think that's the problem. We have two dev_queue_xmit calls first from 
LOWPAN_INTERFACE then the WPAN_INTERFACE, so we locking something twice.


That's very much complicated and I think we doing some hacked stuff
there but currently it works so (except the locking issue). :-)

- Alex

------------------------------------------------------------------------------
Managing the Performance of Cloud-Based Applications
Take advantage of what the Cloud has to offer - Avoid Common Pitfalls.
Read the Whitepaper.
http://pubads.g.doubleclick.net/gampad/clk?id=121051231&iu=/4140/ostg.clktrk
