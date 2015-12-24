From: Hannes Frederic Sowa <hannes@stressinduktion.org>
Subject: Re: [PATCH] netconsole: Initialize after all core networking drivers
Date: Thu, 24 Dec 2015 11:25:54 +0100
Message-ID: <567BC832.8090704@stressinduktion.org>
References: <20151217235239.GA1444048@devbig337.prn1.facebook.com>
 <1450400894.8474.114.camel@edumazet-glaptop2.roam.corp.google.com>
 <20151218014615.GB1715233@devbig337.prn1.facebook.com>
 <20151223230328.GA967745@devbig337.prn1.facebook.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 7bit
Cc: davem@davemloft.net, shm@cumulusnetworks.com,
	izumi.taku@jp.fujitsu.com, linville@tuxdriver.com,
	dsa@cumulusnetworks.com, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org, kernel-team@fb.com,
	Cong Wang <amwang@redhat.com>
To: Calvin Owens <calvinowens@fb.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out3-smtp.messagingengine.com ([66.111.4.27]:39212 "EHLO
	out3-smtp.messagingengine.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754545AbbLXKZ5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 24 Dec 2015 05:25:57 -0500
Received: from compute3.internal (compute3.nyi.internal [10.202.2.43])
	by mailout.nyi.internal (Postfix) with ESMTP id 50E9E2098B
	for <netdev@vger.kernel.org>; Thu, 24 Dec 2015 05:25:56 -0500 (EST)
In-Reply-To: <20151223230328.GA967745@devbig337.prn1.facebook.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

On 24.12.2015 00:03, Calvin Owens wrote:
> On Thursday 12/17 at 17:46 -0800, Calvin Owens wrote:
>> On Thursday 12/17 at 17:08 -0800, Eric Dumazet wrote:
>>> On Thu, 2015-12-17 at 15:52 -0800, Calvin Owens wrote:
>>>> With built-in netconsole and IXGBE, configuring netconsole via the kernel
>>>> cmdline results in the following panic at boot:
>>>>
>>>>     netpoll: netconsole: device eth0 not up yet, forcing it
>>>>     usb 2-1: new high-speed USB device number 2 using ehci-pci
>>>>     ixgbe 0000:03:00.0: registered PHC device on eth0
>>>>     BUG: unable to handle kernel NULL pointer dereference at 0000000000000810
>>>>     <snip>
>>>>     Call Trace:
>>>>      [<ffffffff81578661>] ? vxlan_get_rx_port+0x41/0xa0
>>>>      [<ffffffff81586828>] ixgbe_open+0x4e8/0x540
>>>>      [<ffffffff8168045c>] __dev_open+0xac/0x120
>>>>      [<ffffffff81680506>] dev_open+0x36/0x70
>>>>      [<ffffffff8169abec>] netpoll_setup+0x23c/0x300
>>>>      [<ffffffff8169a66a>] ? netpoll_parse_options+0x19a/0x200
>>>>      [<ffffffff81d797a8>] ? option_setup+0x1f/0x1f
>>>>      [<ffffffff81d79882>] init_netconsole+0xda/0x262
>>>>      [<ffffffff81d797a8>] ? option_setup+0x1f/0x1f
>>>>      [<ffffffff810003a8>] do_one_initcall+0x88/0x1b0
>>>>      [<ffffffff81d31144>] kernel_init_freeable+0x14a/0x1e3
>>>>      [<ffffffff81d308f1>] ? do_early_param+0x8c/0x8c
>>>>      [<ffffffff81778610>] ? rest_init+0x80/0x80
>>>>      [<ffffffff8177861e>] kernel_init+0xe/0xe0
>>>>      [<ffffffff8177dc5f>] ret_from_fork+0x3f/0x70
>>>>      [<ffffffff81778610>] ? rest_init+0x80/0x80
>>>>
>>>> This happens because IXGBE assumes that vxlan has already been initialized.
>>>> The cleanest way to fix this is to just initialize netconsole after all the
>>>> other core networking stuff has completed.
>>>>
>>>> Signed-off-by: Calvin Owens <calvinowens@fb.com>
>>>> ---
>>>>  drivers/net/Makefile | 2 +-
>>>>  1 file changed, 1 insertion(+), 1 deletion(-)
>>>>
>>>> diff --git a/drivers/net/Makefile b/drivers/net/Makefile
>>>> index 900b0c5..31557d0 100644
>>>> --- a/drivers/net/Makefile
>>>> +++ b/drivers/net/Makefile
>>>> @@ -15,7 +15,6 @@ obj-$(CONFIG_MACVTAP) += macvtap.o
>>>>  obj-$(CONFIG_MII) += mii.o
>>>>  obj-$(CONFIG_MDIO) += mdio.o
>>>>  obj-$(CONFIG_NET) += Space.o loopback.o
>>>> -obj-$(CONFIG_NETCONSOLE) += netconsole.o
>>>>  obj-$(CONFIG_PHYLIB) += phy/
>>>>  obj-$(CONFIG_RIONET) += rionet.o
>>>>  obj-$(CONFIG_NET_TEAM) += team/
>>>> @@ -26,6 +25,7 @@ obj-$(CONFIG_VXLAN) += vxlan.o
>>>>  obj-$(CONFIG_GENEVE) += geneve.o
>>>>  obj-$(CONFIG_NLMON) += nlmon.o
>>>>  obj-$(CONFIG_NET_VRF) += vrf.o
>>>> +obj-$(CONFIG_NETCONSOLE) += netconsole.o
>>>>  
>>>>  #
>>>>  # Networking Drivers
>>>
>>>
>>> Looks odd to rely on link order, but we might already rely on this...
>>>
>>> Have you considered using device_initcall() instead of late_initcall()
>>> in vxlan ?
>>
>> I'll look.
> 
> So this does work, but commit 7332a13b038be05c explicitly changed it to
> late_initcall() because of dependencies on IPv6:
> 
>   When vxlan is compiled as builtin, its init code
>   runs before IPv6 init, this could cause problems
>   if we create IPv6 socket in the latter patch.
> 
> So I guess something like the following patch is needed to go that
> route? It's ugly, IMHO the Makefile patch is cleaner...
> 
> Stephen / Cong, what do you think?
> 
>> As-is though, I think a similar problem would happen if you
>> tried to use a virtio_net device with netconsole= cmdline (although that
>> is admittedly a bizarre use case). The Makefile patch seemed like the
>> best way to ensure this can't recur elsewhere.
> 
> I misunderstood this, it works fine as is.
> 
> 
> ---8<---
> From: Calvin Owens <calvinowens@fb.com>
> Subject: [PATCH] vxlan: Properly depend on ipv6 and revert to module_init()
> 
> Commit 7332a13b038be05c ("vxlan: defer vxlan init as late as possible")
> changed vxlan to use late_initcall(), because vxlan relies on ipv6 being
> loaded when a new device is opened.
> 
> This causes netconsole to panic at boot when configured via the kernel
> cmdline on an IXGBE NIC, because ixgbe_open() assumes that vxlan has
> already been initialized:
> 
>   netpoll: netconsole: device eth0 not up yet, forcing it
>   ixgbe 0000:03:00.0: registered PHC device on eth0
>   BUG: unable to handle kernel NULL pointer dereference at 0000000000000810
>   <snip>
>   Call Trace:
>   [<ffffffff81578661>] ? vxlan_get_rx_port+0x41/0xa0
>   [<ffffffff81586828>] ixgbe_open+0x4e8/0x540
>   [<ffffffff8168045c>] __dev_open+0xac/0x120
>   [<ffffffff81680506>] dev_open+0x36/0x70
>   [<ffffffff8169abec>] netpoll_setup+0x23c/0x300
>   [<ffffffff8169a66a>] ? netpoll_parse_options+0x19a/0x200
>   [<ffffffff81d797a8>] ? option_setup+0x1f/0x1f
>   [<ffffffff81d79882>] init_netconsole+0xda/0x262
>   [<ffffffff81d797a8>] ? option_setup+0x1f/0x1f
>   [<ffffffff810003a8>] do_one_initcall+0x88/0x1b0
>   [<ffffffff81d31144>] kernel_init_freeable+0x14a/0x1e3
>   [<ffffffff81d308f1>] ? do_early_param+0x8c/0x8c
>   [<ffffffff81778610>] ? rest_init+0x80/0x80
>   [<ffffffff8177861e>] kernel_init+0xe/0xe0
>   [<ffffffff8177dc5f>] ret_from_fork+0x3f/0x70
>   [<ffffffff81778610>] ? rest_init+0x80/0x80
> 
> This patch addresses the issue cited in 7332a13b038be05c by making vxlan
> actually check if ipv6 is loaded, and reverts it to module_init() so
> that it becomes device_initcall() when built-in, eliminating the
> netconsole issue.
> 
> The ipv6 module is permanent, so there's no need to actually do the
> usual module_get/module_put dance: once we find it loaded, we can just
> assume that it always will be.
> 
> AFAICS, nothing actually ends up calling vxlan_open() during initcalls,
> so in the (IPV6=y && VXLAN=y) case we can't end up there before ipv6 has
> initialized.
> 
> Signed-off-by: Calvin Owens <calvinowens@fb.com>

This architecture just sucks. :(


ixgbe should not have to call into vxlan but vxlan has to call to ixgbe.
Thus the vxlan_get_rx_port is absolutely unnecessary and should be
removed. This also lets ixgbe depend on vxlan which is absurd.

Simply let vxlan_get_rx_port be called from vxlan_notifier_block on
NETDEV_REGISTER or NETDEV_UP events, which is already available.

For the second vxlan_get_rx_port case, which is a
IXGBE_FLAG2_VXLAN_REREG_NEEDED needed event, I would suggest we also
push that over to the vxlan_notifier_block, maybe with a new event type
for the notifiers.

After this change ixgbe would not depend on vxlan module any more.

Thanks,
Hannes
