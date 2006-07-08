From: Arjan van de Ven <arjan@infradead.org>
Subject: Re: starting mc triggers lockdep
Date: Sat, 08 Jul 2006 11:53:20 +0200
Message-ID: <1152352400.3120.19.camel@laptopd505.fenrus.org>
References: <E1Fz33I-0006vG-00@gondolin.me.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: davej@redhat.com, mingo@elte.hu, akpm@osdl.org,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:61665 "EHLO
	pentafluge.infradead.org") by vger.kernel.org with ESMTP
	id S932318AbWGHJxf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 8 Jul 2006 05:53:35 -0400
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <E1Fz33I-0006vG-00@gondolin.me.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Sat, 2006-07-08 at 13:00 +1000, Herbert Xu wrote:
> Arjan van de Ven <arjan@infradead.org> wrote:
> > 
> > i_mutex is taken within rtln_mutex like this:
> >       [<ffffffff8030f4a0>] create_dir+0x2c/0x1e2
> >       [<ffffffff8030fa5b>] sysfs_create_dir+0x59/0x78
> >       [<ffffffff8034d2e2>] kobject_add+0x114/0x1d8
> >       [<ffffffff803bb1e7>] class_device_add+0xb5/0x49d
> >       [<ffffffff804300b1>] netdev_register_sysfs+0x98/0xa2
> >       [<ffffffff80426f58>] register_netdevice+0x28c/0x376
> >       [<ffffffff8042709c>] register_netdev+0x5a/0x69
> > creating the AB dependency
> 
> This is a sysfs inode.
> 
> > now for the third part, which involves the nfs client:
> > stat on an nfs file, which ends up taken the i_mutex of a directory in
> > the path (obvious), and then does 
> >       [<ffffffff8022800b>] tcp_sendmsg+0x1e/0xb1a
> >       [<ffffffff80248f4b>] inet_sendmsg+0x45/0x53
> >       [<ffffffff80259d25>] sock_sendmsg+0x110/0x130
> >       [<ffffffff8041f462>] kernel_sendmsg+0x3c/0x52
> >       [<ffffffff885399e9>] xs_tcp_send_request+0x117/0x320 [sunrpc]
> >       [<ffffffff885388d5>] xprt_transmit+0x105/0x21e [sunrpc]
> >       [<ffffffff8853771e>] call_transmit+0x1f4/0x239 [sunrpc]
> >       [<ffffffff8853c06e>] __rpc_execute+0x9b/0x1e6 [sunrpc]
> >       [<ffffffff8853c1de>] rpc_execute+0x1a/0x1d [sunrpc]
> >       [<ffffffff885364ad>] rpc_call_sync+0x87/0xb9 [sunrpc]
> >       [<ffffffff885a2587>] nfs3_rpc_wrapper+0x2e/0x74 [nfs]
> >       [<ffffffff885a2a14>] nfs3_proc_lookup+0xe0/0x163 [nfs]
> > where tcp_sendmsg calls lock_sock. So this is the BC dependency.
> 
> This is an nfs inode.
> 
> Did I miss something?

is it not possible to nfs export /sys, and then mount it over loopback?


