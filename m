From: Jason Wang <jasowang@redhat.com>
Subject: Re: surprising memory request
Date: Mon, 21 Jan 2013 13:44:02 +0800
Message-ID: <50FCD5A2.5050904@redhat.com>
References: <20130118085818.147220.FMU5901@air.gr8dns.org> <1358531190.11051.402.camel@edumazet-glaptop> <20130118095250.6b9ca9b7@nehalam.linuxnetplumber.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Dirk Hohndel <dirk@hohndel.org>, netdev@vger.kernel.org,
	David Woodhouse <dwmw2@infradead.org>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:9972 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750885Ab3AUFoQ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 21 Jan 2013 00:44:16 -0500
In-Reply-To: <20130118095250.6b9ca9b7@nehalam.linuxnetplumber.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On 01/19/2013 01:52 AM, Stephen Hemminger wrote:
> On Fri, 18 Jan 2013 09:46:30 -0800
> Eric Dumazet <eric.dumazet@gmail.com> wrote:
>
>> On Fri, 2013-01-18 at 08:58 -0800, Dirk Hohndel wrote:
>>> Running openconnect on a very recent 3.8 (a few commits before Linus cut
>>> RC4) I get this allocation failure. I'm unclear why we would need 128
>>> contiguous pages here...
>>>
>>> /D
>>>
>>> [66015.673818] openconnect: page allocation failure: order:7, mode:0x10c0d0
>>> [66015.673827] Pid: 3292, comm: openconnect Tainted: G        W    3.8.0-rc3-00352-gdfdebc2 #94
>>> [66015.673830] Call Trace:
>>> [66015.673841]  [<ffffffff810e9c29>] warn_alloc_failed+0xe9/0x140
>>> [66015.673849]  [<ffffffff81093967>] ? on_each_cpu_mask+0x87/0xa0
>>> [66015.673854]  [<ffffffff810ec349>] __alloc_pages_nodemask+0x579/0x720
>>> [66015.673859]  [<ffffffff810ec507>] __get_free_pages+0x17/0x50
>>> [66015.673866]  [<ffffffff81123979>] kmalloc_order_trace+0x39/0xf0
>>> [66015.673874]  [<ffffffff81666178>] ? __hw_addr_add_ex+0x78/0xc0
>>> [66015.673879]  [<ffffffff811260d8>] __kmalloc+0xc8/0x180
>>> [66015.673883]  [<ffffffff81666616>] ? dev_addr_init+0x66/0x90
>>> [66015.673889]  [<ffffffff81660985>] alloc_netdev_mqs+0x145/0x300
>>> [66015.673896]  [<ffffffff81513830>] ? tun_net_fix_features+0x20/0x20
>>> [66015.673902]  [<ffffffff815168aa>] __tun_chr_ioctl+0xd0a/0xec0
>>> [66015.673908]  [<ffffffff81516a93>] tun_chr_ioctl+0x13/0x20
>>> [66015.673913]  [<ffffffff8113b197>] do_vfs_ioctl+0x97/0x530
>>> [66015.673917]  [<ffffffff811256f3>] ? kmem_cache_free+0x33/0x170
>>> [66015.673923]  [<ffffffff81134896>] ? final_putname+0x26/0x50
>>> [66015.673927]  [<ffffffff8113b6c1>] sys_ioctl+0x91/0xb0
>>> [66015.673935]  [<ffffffff8180e3d2>] system_call_fastpath+0x16/0x1b
>>> [66015.673938] Mem-Info:
>> Thats because Jason thought that tun device had to have an insane number
>> of queues to get good performance.
>>
>> #define MAX_TAP_QUEUES 1024
>>
>> Thats crazy if your machine has say 8 cpus.
>>
>> And Jason didnt care to adapt the memory allocations done in
>> alloc_netdev_mqs(), in order to switch to vmalloc() when kmalloc()
>> fails.
>>
>> commit c8d68e6be1c3b242f1c598595830890b65cea64a
>> Author: Jason Wang <jasowang@redhat.com>
>> Date:   Wed Oct 31 19:46:00 2012 +0000
>>
>>     tuntap: multiqueue support
>>     
>>     This patch converts tun/tap to a multiqueue devices and expose the multiqueue
>>     queues as multiple file descriptors to userspace. Internally, each tun_file were
>>     abstracted as a queue, and an array of pointers to tun_file structurs were
>>     stored in tun_structure device, so multiple tun_files were allowed to be
>>     attached to the device as multiple queues.
>>     
>>     When choosing txq, we first try to identify a flow through its rxhash, if it
>>     does not have such one, we could try recorded rxq and then use them to choose
>>     the transmit queue. This policy may be changed in the future.
>>     
>>     Signed-off-by: Jason Wang <jasowang@redhat.com>
>>     Signed-off-by: David S. Miller <davem@davemloft.net>
> Also the tuntap device now has it's own flow cache which is also a bad idea.
> Why not just 128 queues and a hash like SFQ?

Hi Stephen:

I know your concerns, I think we can solve it by limiting the number of
flow caches to a value (say 4096). With this, the average worst
searching depth is 4 which solves the issue when there's lots of
short-live connections.

The issue of just an array of 128 entries is that the matching is not
accurate. With an array of limited entries, we can easily get the index
collision with two different flows, which may result the packets of a
flow move back of forth between queues. Ideally we may need a perfect
filter and doing comparison on n-tuple which may be very expensive for
software device such as tun, so I choose to store rxhash in the flow
caches and using a hash list to do the match.

Thanks


>
> --
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
