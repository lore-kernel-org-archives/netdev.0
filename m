From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH net-next v2 0/7] net: unify dst caching for tunnel
 devices
Date: Wed, 27 Apr 2016 16:31:15 -0700
Message-ID: <1461799875.5535.87.camel@edumazet-glaptop3.roam.corp.google.com>
References: <cover.1455287867.git.pabeni@redhat.com>
	 <20160216.202221.489011866131335381.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: pabeni@redhat.com, netdev@vger.kernel.org, tgraf@suug.ch,
	pshelar@nicira.com, jbenc@redhat.com, hannes@stressinduktion.org,
	therbert@google.com, sergei.shtylyov@cogentembedded.com
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f180.google.com ([209.85.192.180]:34290 "EHLO
	mail-pf0-f180.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752653AbcD0XbR (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Apr 2016 19:31:17 -0400
Received: by mail-pf0-f180.google.com with SMTP id y69so26163293pfb.1
        for <netdev@vger.kernel.org>; Wed, 27 Apr 2016 16:31:17 -0700 (PDT)
In-Reply-To: <20160216.202221.489011866131335381.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2016-02-16 at 20:22 -0500, David Miller wrote:
> From: Paolo Abeni <pabeni@redhat.com>
> Date: Fri, 12 Feb 2016 15:43:52 +0100
> 
> > This patch series try to unify the dst cache implementations currently
> > present in the kernel, namely in ip_tunnel.c and ip6_tunnel.c, introducing a
> > new generic implementation, replacing the existing ones, and then using
> > the new implementation in other tunnel devices which currently lack it.
> > 
> > The new dst implementation is compiled, as built-in, only if any device using
> > it is enabled.
> > 
> > Caching the dst for the tunnel remote address gives small, but measurable,
> > performance improvement when tunneling over ipv4 (in the 2%-4% range) and
> > significant ones when tunneling over ipv6 (roughly 60% when no
> > fragmentation/segmentation take place and the tunnel local address
> > is not specified).
> > 
> > v2:
> > - move the vxlan dst_cache usage inside the device lookup functions
> > - fix usage after free for lwt tunnel moving the dst cache storage inside
> >   the dst_metadata,
> > - sparse codying style cleanup
> 
> Series applied, thanks for doing this work as it is a major improvement.

Paolo, please check following warning :

This might be caused by e09acddf873bf775b208b452a4c3a3fd26fa9427
("ip_tunnel: replace dst_cache with generic implementation")


[   73.982267] BUG: using smp_processor_id() in preemptible [00000000] code: ip/10604
[   73.990978] caller is debug_smp_processor_id+0x17/0x20
[   73.990981] CPU: 26 PID: 10604 Comm: ip Not tainted 4.6.0-dbx-DEV #1075
[   73.990982] Hardware name: ...
[   73.990983]  0000000000000000 ffff881fc11d3b98 ffffffff8140a51f 000000000000001a
[   73.990987]  ffffffff81a585c5 ffff881fc11d3bc8 ffffffff8142700f 000060bfa000e0c0
[   73.990989]  ffff881fcb6b0f00 000000009807f60a ffff881fcb6b0f00 ffff881fc11d3bd8
[   73.990992] Call Trace:
[   73.990996]  [<ffffffff8140a51f>] dump_stack+0x67/0x98
[   73.990998]  [<ffffffff8142700f>] check_preemption_disabled+0xef/0x100
[   73.991000]  [<ffffffff81427057>] debug_smp_processor_id+0x17/0x20
[   73.991003]  [<ffffffff816bc2cc>] dst_cache_set_ip4+0x2c/0x70
[   73.991006]  [<ffffffff8174fed1>] ip_tunnel_bind_dev+0x101/0x170
[   73.991008]  [<ffffffff81750750>] ip_tunnel_ioctl+0x330/0x430
[   73.991010]  [<ffffffff81750425>] ? ip_tunnel_ioctl+0x5/0x430
[   73.991012]  [<ffffffff81754b2b>] ipgre_tunnel_ioctl+0xdb/0x160
[   73.991015]  [<ffffffff816a66f7>] ? rtnl_lock+0x17/0x20
[   73.991017]  [<ffffffff816b03e5>] dev_ifsioc+0x325/0x370
[   73.991018]  [<ffffffff816b0662>] dev_ioctl+0xd2/0x630
[   73.991022]  [<ffffffff8166fc23>] sock_ioctl+0xd3/0x270
[   73.991025]  [<ffffffff81283643>] do_vfs_ioctl+0x93/0x6f0
[   73.991026]  [<ffffffff8166ff01>] ? sock_alloc_file+0x91/0x120
[   73.991029]  [<ffffffff8128fa3c>] ? __fget_light+0x6c/0x90
[   73.991031]  [<ffffffff81283d2b>] SyS_ioctl+0x8b/0xa0
[   73.991042]  [<ffffffff817ef2a5>] entry_SYSCALL_64_fastpath+0x18/0xa8

Thanks
