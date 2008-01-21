From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: [Bugme-new] [Bug 9778] New: unregister_netdevice: waiting for [device] to become free
Date: Mon, 21 Jan 2008 15:14:45 +0300
Message-ID: <20080121121445.GA29459@2ka.mipt.ru>
References: <bug-9778-10286@http.bugzilla.kernel.org/> <20080119165802.2846a28e.akpm@linux-foundation.org> <20080120.023027.85710827.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: akpm@linux-foundation.org, xemul@openvz.org,
	bugme-daemon@bugzilla.kernel.org, nigel@suspend2.net,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:44127 "EHLO 2ka.mipt.ru"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754503AbYAUMP7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2008 07:15:59 -0500
Content-Disposition: inline
In-Reply-To: <20080120.023027.85710827.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Jan 20, 2008 at 02:30:27AM -0800, David Miller (davem@davemloft.net) wrote:
> From: Andrew Morton <akpm@linux-foundation.org>
> Date: Sat, 19 Jan 2008 16:58:02 -0800
> 
> > ouch.
> 
> Yep, several people are hitting this it seems.
> 
> If Pavel doesn't provide a fix or direction soon I'll just revert.

It looks like patch is still valid.
Here is a problem description as I undestood.

When new device (let's talk about ethernet, since that is what I tested)
is being turned on, it gets neigh_parms entry allocated for it via
inetdev_init(), which is called for NETDEV_REGISTER inetdev event.
This entry is stored in arp_tbl table and is in_dev->arp_parms.

When later new arp entry is created, device is provided into
arp_constructor(), which clones (increase reference counter) device's
in_dev->arp_parms and puts it into provided neighbour entry.

When later we remove device, its in_dev->arp_parms's reference counter
is high enough (it is equal to number of arp entries found on given
device plu one), so neigh_parms_destroy() is not called. Later all
neighbour entries are flushed by garbage collector and reference counter
for that parm hits zero and device can be removed.

I will think about how to fix the problem nicely or if this patch still
can be simplified/dropped, but so far it looks valid. Maybe this
analysis will help someone to fix problem first.

Here is debug dmesg:
[   21.835595] inetdev_init: allocating parms.
[   21.839829] neigh_parms_alloc: parms: ffff81003d8e8df0, dev: eth0, refcnt: 1, dev_refcnt: 2.
...
[   30.251576] r8169: eth0: link up
[   31.067079] NET: Registered protocol family 10
[   31.072055] neigh_parms_alloc: parms: ffff81003efc72a8, dev: lo, refcnt: 1, dev_refcnt: 9.
[   31.080891] neigh_alloc: parms: ffffffff8812afe8, dev: <NULL>, refcnt: 2.
[   31.087816] neigh_parms_alloc: parms: ffff81003efc7210, dev: eth0, refcnt: 1, dev_refcnt: 9.
[   31.097335] neigh_alloc: parms: ffffffff804deb88, dev: <NULL>, refcnt: 2.
[   31.104172] arp_constructor: parms: ffff81003f8c3be8, dev: lo, refcnt: 2.
[   31.500348] neigh_alloc: parms: ffffffff8812afe8, dev: <NULL>, refcnt: 2.
[   32.499628] neigh_alloc: parms: ffffffff8812afe8, dev: <NULL>, refcnt: 2.
[  102.827796] neigh_destroy: parms: ffff81003efc7210, dev: eth0, refcnt: 3, dev_refcnt: 13.
[  106.828843] neigh_destroy: parms: ffff81003f8c3be8, dev: lo, refcnt: 2, dev_refcnt: 78.
[  109.810987] neigh_alloc: parms: ffffffff804deb88, dev: <NULL>, refcnt: 2.

First arp entry for eth0 device, bump the counter:
[  109.817827] arp_constructor: parms: ffff81003d8e8df0, dev: eth0, refcnt: 2.

[  109.831811] neigh_alloc: parms: ffffffff804deb88, dev: <NULL>, refcnt: 2.
[  109.838661] arp_constructor: parms: ffff81003f8c3be8, dev: lo, refcnt: 2.
[  110.837894] neigh_destroy: parms: ffff81003efc7210, dev: eth0, refcnt: 2, dev_refcnt: 15.

Can not release that neigh parm:
[  113.638228] neigh_parms_release: parms: ffff81003d8e8df0, dev: eth0, refcnt: 2, dev_refcnt: 5.

Can release some other (for ipv6):
[  113.649380] neigh_parms_release: parms: ffff81003efc7210, dev: eth0, refcnt: 1, dev_refcnt: 5.
[  113.671806] neigh_parms_destroy: parms: ffff81003efc7210, dev: eth0, dev_refcnt: 3.

[  123.916250] unregister_netdevice: waiting for eth0 to become free. Usage count = 1

GC hits us:
[  124.839572] neigh_destroy: parms: ffff81003d8e8df0, dev: eth0, refcnt: 1, dev_refcnt: 11.
[  124.847813] neigh_parms_destroy: parms: ffff81003d8e8df0, dev: eth0, dev_refcnt: 1.
[  124.952026] ACPI: PCI interrupt for device 0000:02:0d.0 disabled

-- 
	Evgeniy Polyakov
