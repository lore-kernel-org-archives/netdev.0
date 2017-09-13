From: Florian Westphal <fw@strlen.de>
Subject: Re: Memory leaks in conntrack
Date: Wed, 13 Sep 2017 10:05:16 +0200
Message-ID: <20170913080516.GD25977@breakpoint.cc>
References: <CAM_iQpWvO3L1JOrCMvAvqduWH5pt_9-=GEx+eOFQyOt5Z5prrA@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netfilter-devel@vger.kernel.org,
        Linux Kernel Network Developers <netdev@vger.kernel.org>
To: Cong Wang <xiyou.wangcong@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from Chamillionaire.breakpoint.cc ([146.0.238.67]:58910 "EHLO
        Chamillionaire.breakpoint.cc" rhost-flags-OK-OK-OK-OK)
        by vger.kernel.org with ESMTP id S1750737AbdIMIIY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 13 Sep 2017 04:08:24 -0400
Content-Disposition: inline
In-Reply-To: <CAM_iQpWvO3L1JOrCMvAvqduWH5pt_9-=GEx+eOFQyOt5Z5prrA@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Cong Wang <xiyou.wangcong@gmail.com> wrote:
> While testing my TC filter patches (so not related to conntrack), the
> following memory leaks are shown up:
> 
> unreferenced object 0xffff9b19ba551228 (size 128):
>   comm "chronyd", pid 338, jiffies 4294910829 (age 53.188s)
>   hex dump (first 32 bytes):
>     6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b 6b  kkkkkkkkkkkkkkkk
>     00 00 00 00 18 00 00 30 00 00 00 00 00 00 00 00  .......0........
>   backtrace:
>     [<ffffffff9f1e1175>] create_object+0x169/0x2aa
>     [<ffffffff9fb77fb2>] kmemleak_alloc+0x25/0x41
>     [<ffffffff9f1c47ed>] slab_post_alloc_hook+0x44/0x65
>     [<ffffffff9f1ca2db>] __kmalloc_track_caller+0x113/0x146
>     [<ffffffff9f193c3b>] __krealloc+0x4a/0x69
>     [<ffffffff9f948dbd>] nf_ct_ext_add+0xe1/0x145
>     [<ffffffff9f942395>] init_conntrack+0x1f7/0x36e
>     [<ffffffff9f942762>] nf_conntrack_in+0x1d3/0x326
>     [<ffffffff9fa1ea69>] ipv4_conntrack_local+0x4d/0x50
>     [<ffffffff9f93ad70>] nf_hook_slow+0x3c/0x9b
>     [<ffffffff9f9c7999>] nf_hook.constprop.40+0xbe/0xd8
>     [<ffffffff9f9c7ba2>] __ip_local_out+0xb3/0xbf
>     [<ffffffff9f9c7bca>] ip_local_out+0x1c/0x36
>     [<ffffffff9f9c9216>] ip_send_skb+0x19/0x3d
>     [<ffffffff9f9ee3de>] udp_send_skb+0x17e/0x1df
>     [<ffffffff9f9eea37>] udp_sendmsg+0x5a2/0x77c
> unreferenced object 0xffff9b19a69b3340 (size 336):
>   comm "chronyd", pid 338, jiffies 4294910868 (age 53.032s)
>   hex dump (first 32 bytes):
>     01 00 00 00 5a 5a 5a 5a 00 00 00 00 ad 4e ad de  ....ZZZZ.....N..
>     ff ff ff ff 5a 5a 5a 5a ff ff ff ff ff ff ff ff  ....ZZZZ........
>   backtrace:
>     [<ffffffff9f1e1175>] create_object+0x169/0x2aa
>     [<ffffffff9fb77fb2>] kmemleak_alloc+0x25/0x41
>     [<ffffffff9f1c47ed>] slab_post_alloc_hook+0x44/0x65
>     [<ffffffff9f1c7a7d>] kmem_cache_alloc+0xd7/0x1f1
>     [<ffffffff9f941b78>] __nf_conntrack_alloc+0xa2/0x146
>     [<ffffffff9f942250>] init_conntrack+0xb2/0x36e
>     [<ffffffff9f942762>] nf_conntrack_in+0x1d3/0x326
>     [<ffffffff9fa1ea69>] ipv4_conntrack_local+0x4d/0x50
>     [<ffffffff9f93ad70>] nf_hook_slow+0x3c/0x9b
>     [<ffffffff9f9c7999>] nf_hook.constprop.40+0xbe/0xd8
>     [<ffffffff9f9c7ba2>] __ip_local_out+0xb3/0xbf
>     [<ffffffff9f9c7bca>] ip_local_out+0x1c/0x36
>     [<ffffffff9f9c9216>] ip_send_skb+0x19/0x3d
>     [<ffffffff9f9ee3de>] udp_send_skb+0x17e/0x1df
>     [<ffffffff9f9eea37>] udp_sendmsg+0x5a2/0x77c
>     [<ffffffff9f9f8cb8>] inet_sendmsg+0x37/0x5e
>
> I don't touch chronyd in my VM, so I have no idea why it sends out UDP
> packets, my guess is it is some periodical packet.
> 
> I don't think I use conntrack either, since /proc/net/ip_conntrack
> does not exist.

You probably do, can you try "cat /proc/net/nf_conntrack" instead?

(otherwise there should be no ipv4_conntrack_local() invocation
 since we would not register this hook at all).

I tried to reproduce this but so far I had no success.
If you can identify something that could give a hint when this
is happening (only once after boot, periodically, only with udp, etc)
please let us know.

(A reproducer would be even better of course ;-) )

Is this with current net tree?

Thanks!
