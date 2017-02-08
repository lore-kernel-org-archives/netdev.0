From: Dmitry Vyukov <dvyukov@google.com>
Subject: net/ipv6: double free in ipip6_dev_free
Date: Wed, 8 Feb 2017 14:56:11 +0100
Message-ID: <CACT4Y+Yu2mdo7w13nskZCnNwfcOaPY_SS5KDoLciGRg0E=u57A@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: syzkaller <syzkaller@googlegroups.com>
To: David Miller <davem@davemloft.net>,
        Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
        James Morris <jmorris@namei.org>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Eric Dumazet <edumazet@google.com>,
        netdev <netdev@vger.kernel.org>,
        LKML <linux-kernel@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vk0-f50.google.com ([209.85.213.50]:35099 "EHLO
        mail-vk0-f50.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753903AbdBHOEP (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Feb 2017 09:04:15 -0500
Received: by mail-vk0-f50.google.com with SMTP id x75so101150552vke.2
        for <netdev@vger.kernel.org>; Wed, 08 Feb 2017 06:03:14 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I've got the following report while running syzkaller fuzzer on
eb60f01302b24ce93108414e2c4c673cb7cd6e05:

kernel BUG at mm/percpu.c:689!
invalid opcode: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 15692 Comm: syz-executor1 Not tainted 4.10.0-rc6-next-20170206 #1
Hardware name: Google Google Compute Engine/Google Compute Engine,
BIOS Google 01/01/2011
task: ffff8801c9cc27c0 task.stack: ffff88017d1d8000
RIP: 0010:pcpu_free_area+0x68b/0x810 mm/percpu.c:689
RSP: 0018:ffff88017d1df488 EFLAGS: 00010046
RAX: 0000000000010000 RBX: 00000000000007c0 RCX: ffffc90002829000
RDX: 0000000000010000 RSI: ffffffff81940efb RDI: ffff8801db841d94
RBP: ffff88017d1df590 R08: dffffc0000000000 R09: 1ffffffff0bb3bdd
R10: dffffc0000000000 R11: 00000000000135dd R12: ffff8801db841d80
R13: 0000000000038e40 R14: 00000000000007c0 R15: 00000000000007c0
FS:  00007f6ea608f700(0000) GS:ffff8801dbe00000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 000000002000aff8 CR3: 00000001c8d44000 CR4: 00000000001426f0
DR0: 0000000020000000 DR1: 0000000020000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000ffff0ff0 DR7: 0000000000000600
Call Trace:
 free_percpu+0x212/0x520 mm/percpu.c:1264
 ipip6_dev_free+0x43/0x60 net/ipv6/sit.c:1335
 sit_init_net+0x3cb/0xa10 net/ipv6/sit.c:1831
 ops_init+0x10a/0x530 net/core/net_namespace.c:115
 setup_net+0x2ed/0x690 net/core/net_namespace.c:291
 copy_net_ns+0x26c/0x530 net/core/net_namespace.c:396
 create_new_namespaces+0x409/0x860 kernel/nsproxy.c:106
 unshare_nsproxy_namespaces+0xae/0x1e0 kernel/nsproxy.c:205
 SYSC_unshare kernel/fork.c:2281 [inline]
 SyS_unshare+0x64e/0xfc0 kernel/fork.c:2231
 entry_SYSCALL_64_fastpath+0x1f/0xc2
RIP: 0033:0x44fac9
RSP: 002b:00007f6ea608eb58 EFLAGS: 00000212 ORIG_RAX: 0000000000000110
RAX: ffffffffffffffda RBX: 0000000000000000 RCX: 000000000044fac9
RDX: 0000000000000000 RSI: 0000000000000000 RDI: 0000000062020200
RBP: 0000000062020200 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000000 R11: 0000000000000212 R12: 0000000000708150
R13: 0000000001a2fc57 R14: 00007f6ea608f9c0 R15: 0000000000000002
Code: fc 41 83 e6 01 0f 85 5a 01 00 00 48 c7 85 08 ff ff ff 0c 00 00
00 41 be 02 00 00 00 e9 66 ff ff ff e8 da 05 df ff e8 d5 05 df ff <0f>
0b 48 8b bd f8 fe ff ff e8 07 7d 0f 00 e9 29 fa ff ff 4c 89
RIP: pcpu_free_area+0x68b/0x810 mm/percpu.c:689 RSP: ffff88017d1df488
---[ end trace 19ce5f3abc145e4e ]---

Right before that there was an allocation failure:

[  184.738724] percpu: allocation failed, size=40 align=8 atomic=0,
failed to extend area map
[  184.747197] CPU: 0 PID: 15964 Comm: syz-executor7 Not tainted
4.10.0-rc7-next-20170207 #1
[  184.748147] Hardware name: Google Google Compute Engine/Google
Compute Engine, BIOS Google 01/01/2011
[  184.748147] Call Trace:
[  184.748147]  dump_stack+0x2ee/0x3ef
[  184.748147]  pcpu_alloc+0x1185/0x1290
[  184.748147]  __alloc_percpu_gfp+0x27/0x30
[  184.748147]  dst_cache_init+0x2b/0xd0
[  184.748147]  ipip6_tunnel_init+0x17a/0x250
[  184.748147]  register_netdevice+0x2f1/0xed0
[  184.748147]  register_netdev+0x1a/0x30
[  184.748147]  sit_init_net+0x391/0xa10
[  184.748147]  ops_init+0x10a/0x530
[  184.748147]  setup_net+0x2ed/0x690
[  184.748147]  copy_net_ns+0x26c/0x530
[  184.748147]  create_new_namespaces+0x409/0x860
[  184.748147]  unshare_nsproxy_namespaces+0xae/0x1e0
[  184.748147]  SyS_unshare+0x64e/0xfc0


First dev->tstats was freed here:

1376 static int ipip6_tunnel_init(struct net_device *dev)
1377 {
1378         struct ip_tunnel *tunnel = netdev_priv(dev);
1379         int err;
1380
1381         tunnel->dev = dev;
1382         tunnel->net = dev_net(dev);
1383         strcpy(tunnel->parms.name, dev->name);
1384
1385         ipip6_tunnel_bind_dev(dev);
1386         dev->tstats = netdev_alloc_pcpu_stats(struct pcpu_sw_netstats);
1387         if (!dev->tstats)
1388                 return -ENOMEM;
1389
1390         err = dst_cache_init(&tunnel->dst_cache, GFP_KERNEL);
1391         if (err) {
1392                 free_percpu(dev->tstats);
1393                 return err;
1394         }
1395
1396         return 0;
1397 }

And then again here:

1342 static void ipip6_dev_free(struct net_device *dev)
1343 {
1344         struct ip_tunnel *tunnel = netdev_priv(dev);
1345
1346         dst_cache_destroy(&tunnel->dst_cache);
1347         free_percpu(dev->tstats);
1348         free_netdev(dev);
1349 }
