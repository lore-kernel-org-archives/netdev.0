From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH net] ipv6: fix RTNL assert fail in DAD
Date: Tue, 18 Mar 2014 01:29:08 +0100
Message-ID: <20140318002908.GF12291@order.stressinduktion.org>
References: <20140317161853.2e880469@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from order.stressinduktion.org ([87.106.68.36]:42245 "EHLO
	order.stressinduktion.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752042AbaCRA3K (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Mar 2014 20:29:10 -0400
Content-Disposition: inline
In-Reply-To: <20140317161853.2e880469@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi!

On Mon, Mar 17, 2014 at 04:18:53PM -0700, Stephen Hemminger wrote:
> IPv6 duplicate address detection is triggering the following assertion
> failure when using macvlan + vif + multicast.
>  RTNL: assertion failed at net/core/dev.c (4496)
> 
> This happens because the DAD timer is adding a multicast address without
> acquiring the RTNL mutex. In order to acquire the RTNL mutex, it must be
> done in process context; therefore it must be in a workqueue.
> 
> Full backtrace:
> [  541.030090] RTNL: assertion failed at net/core/dev.c (4496)
> [  541.031143] CPU: 0 PID: 0 Comm: swapper/0 Tainted: G           O 3.10.33-1-amd64-vyatta #1
> [  541.031145] Hardware name: Bochs Bochs, BIOS Bochs 01/01/2007
> [  541.031146]  ffffffff8148a9f0 000000000000002f ffffffff813c98c1 ffff88007c4451f8
> [  541.031148]  0000000000000000 0000000000000000 ffffffff813d3540 ffff88007fc03d18
> [  541.031150]  0000880000000006 ffff88007c445000 ffffffffa0194160 0000000000000000
> [  541.031152] Call Trace:
> [  541.031153]  <IRQ>  [<ffffffff8148a9f0>] ? dump_stack+0xd/0x17
> [  541.031180]  [<ffffffff813c98c1>] ? __dev_set_promiscuity+0x101/0x180
> [  541.031183]  [<ffffffff813d3540>] ? __hw_addr_create_ex+0x60/0xc0
> [  541.031185]  [<ffffffff813cfe1a>] ? __dev_set_rx_mode+0xaa/0xc0
> [  541.031189]  [<ffffffff813d3a81>] ? __dev_mc_add+0x61/0x90
> [  541.031198]  [<ffffffffa01dcf9c>] ? igmp6_group_added+0xfc/0x1a0 [ipv6]
> [  541.031208]  [<ffffffff8111237b>] ? kmem_cache_alloc+0xcb/0xd0
> [  541.031212]  [<ffffffffa01ddcd7>] ? ipv6_dev_mc_inc+0x267/0x300 [ipv6]
> [  541.031216]  [<ffffffffa01c2fae>] ? addrconf_join_solict+0x2e/0x40 [ipv6]
> [  541.031219]  [<ffffffffa01ba2e9>] ? ipv6_dev_ac_inc+0x159/0x1f0 [ipv6]
> [  541.031223]  [<ffffffffa01c0772>] ? addrconf_join_anycast+0x92/0xa0 [ipv6]
> [  541.031226]  [<ffffffffa01c311e>] ? __ipv6_ifa_notify+0x11e/0x1e0 [ipv6]
> [  541.031229]  [<ffffffffa01c3213>] ? ipv6_ifa_notify+0x33/0x50 [ipv6]

This is the most often case but I fear there are more of them.

addrconf_verify seems unsafe, too, when removing the last ipv6 address. So
does addrconf_prefix_rcv if adding first address.

I wonder if we should put the whole ipv6_ifa_notify infrastructure in a
workqueue? I don't like that either and it could add subtile races.

Those races also seem possible if we only defer addrconf_join_solict,
addrconf_leave_solict, addrconf_join_anycast and addrconf_leave_anycast to
workqueues.

This change is certainly going into the right direction but I am not sure if
we could generalize it.

Greetings,

  Hannes
