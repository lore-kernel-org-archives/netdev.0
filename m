From: Cong Wang <cwang@twopensource.com>
Subject: Re: [PATCH] [net]ip_tunnel: the lack of vti_link_ops' dellink() cause
 kernel panic
Date: Tue, 18 Nov 2014 14:12:47 -0800
Message-ID: <CAHA+R7NKdS_j2MC+-Bcw=hFERODiMw1Z6ju6yw5TvXXHbTXK5A@mail.gmail.com>
References: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: network dev <netdev@vger.kernel.org>
To: Xin Long <lucien.xin@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f181.google.com ([209.85.216.181]:61275 "EHLO
	mail-qc0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753796AbaKRWMs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 Nov 2014 17:12:48 -0500
Received: by mail-qc0-f181.google.com with SMTP id m20so6575641qcx.40
        for <netdev@vger.kernel.org>; Tue, 18 Nov 2014 14:12:47 -0800 (PST)
In-Reply-To: <1416307059-32732-1-git-send-email-lucien.xin@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 18, 2014 at 2:37 AM, Xin Long <lucien.xin@gmail.com> wrote:
> Now the vti_link_ops do not point the .dellink, rtnl_newlink will invoke
> the default function, unregister_netdevice_queue, which will cause the
> dev to unregister later. so when we delete a vti device, the net_device
> will be removed, but the tunnel still in the tunnel list. then, we add
> a new vti, in ip_tunnel_find():
>
>         hlist_for_each_entry_rcu(t, head, hash_node) {
>                 if (local == t->parms.iph.saddr &&
>                     remote == t->parms.iph.daddr &&
>                     link == t->parms.link &&
>                     type == t->dev->type &&
>                     ip_tunnel_key_match(&t->parms, flags, key))
>                         break;
>         }
>
> the dev of ip_tunnel *t may be null because of unregister_netdevice_queue
> motioned above. so the panic will happen:


Are you sure? We call ->ndo_uninit() in unregister path, and vti tunnel
has ip_tunnel_uninit() which removes non-fb tunnel from that list.

>
> [ 3835.072977] IP: [<ffffffffa04103fd>] ip_tunnel_find+0x9d/0xc0 [ip_tunnel]
> [ 3835.073008] PGD b2c21067 PUD b7277067 PMD 0
> [ 3835.073008] Oops: 0000 [#1] SMP
> .....
> [ 3835.073008] Stack:
> [ 3835.073008]  ffff8800b72d77f0 ffffffffa0411924 ffff8800bb956000 ffff8800b72d78e0
> [ 3835.073008]  ffff8800b72d78a0 0000000000000000 ffffffffa040d100 ffff8800b72d7858
> [ 3835.073008]  ffffffffa040b2e3 0000000000000000 0000000000000000 0000000000000000
> [ 3835.073008] Call Trace:
> [ 3835.073008]  [<ffffffffa0411924>] ip_tunnel_newlink+0x64/0x160 [ip_tunnel]
> [ 3835.073008]  [<ffffffffa040b2e3>] vti_newlink+0x43/0x70 [ip_vti]
> [ 3835.073008]  [<ffffffff8150d4da>] rtnl_newlink+0x4fa/0x5f0
> [ 3835.073008]  [<ffffffff812f68bb>] ? nla_strlcpy+0x5b/0x70
> [ 3835.073008]  [<ffffffff81508fb0>] ? rtnl_link_ops_get+0x40/0x60
> [ 3835.073008]  [<ffffffff8150d11f>] ? rtnl_newlink+0x13f/0x5f0
> [ 3835.073008]  [<ffffffff81509cf4>] rtnetlink_rcv_msg+0xa4/0x270
> [ 3835.073008]  [<ffffffff8126adf5>] ? sock_has_perm+0x75/0x90
> [ 3835.073008]  [<ffffffff81509c50>] ? rtnetlink_rcv+0x30/0x30
> [ 3835.073008]  [<ffffffff81529e39>] netlink_rcv_skb+0xa9/0xc0
> [ 3835.073008]  [<ffffffff81509c48>] rtnetlink_rcv+0x28/0x30
> ....
>
> the reproduction can be like this:
>
> modprobe ip_vti
> ip link del ip_vti0 type vti
> ip link add ip_vti0 type vti
> rmmod ip_vti
>
> do that one or more time, kernel will panic.


>From your reproducer, I suspect the problem is we might miss
some clean up for the fb device ip_vti0, not for every vti tunnel.
Or maybe some race condition. Still digging.
