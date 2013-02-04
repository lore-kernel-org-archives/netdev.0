From: Tommi Rantala <tt.rantala@gmail.com>
Subject: ip6gre_tunnel_xmit() leaking an skb?
Date: Mon, 4 Feb 2013 14:29:01 +0200
Message-ID: <CA+ydwtqabWALE=CtNWrDY=uiZqpHzUnami6OR-_OrK8TgNivQw@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
To: "David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>, netdev@vger.kernel.org,
	Dmitry Kozlov <xeb@mail.ru>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-vc0-f172.google.com ([209.85.220.172]:43609 "EHLO
	mail-vc0-f172.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752478Ab3BDM3D (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 4 Feb 2013 07:29:03 -0500
Received: by mail-vc0-f172.google.com with SMTP id l6so3827971vcl.31
        for <netdev@vger.kernel.org>; Mon, 04 Feb 2013 04:29:01 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

kmemleak is giving me some complaints on boot:

# echo scan > /sys/kernel/debug/kmemleak
# echo scan > /sys/kernel/debug/kmemleak
[   13.084513] kmemleak: 2 new suspected memory leaks (see
/sys/kernel/debug/kmemleak)
# cat /sys/kernel/debug/kmemleak
unreferenced object 0xffff88003b4e3c00 (size 256):
  comm "dhcpcd", pid 1661, jiffies 4294670402 (age 15.097s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
    00 00 00 00 00 00 00 00 00 80 4a 3b 00 88 ff ff  ..........J;....
  backtrace:
    [<ffffffff81b3d636>] kmemleak_alloc+0x26/0x50
    [<ffffffff81193514>] kmem_cache_alloc_node+0xb4/0x180
    [<ffffffff817c8fc0>] __alloc_skb+0x60/0x2a0
    [<ffffffff817c57c1>] sock_alloc_send_pskb+0x1d1/0x340
    [<ffffffff8190aa38>] packet_sendmsg+0xa88/0xd40
    [<ffffffff817c0b60>] sock_sendmsg+0xb0/0xe0
    [<ffffffff817c232e>] sys_sendto+0x11e/0x160
    [<ffffffff81b62859>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff
unreferenced object 0xffff88003af07800 (size 1024):
  comm "dhcpcd", pid 1661, jiffies 4294670402 (age 15.097s)
  hex dump (first 32 bytes):
    00 74 f0 3a 00 88 ff ff fe ed ca fe 28 00 00 00  .t.:........(...
    28 00 00 00 ad 00 00 00 f0 03 1d b7 7b cb c5 ee  (...........{...
  backtrace:
    [<ffffffff81b3d636>] kmemleak_alloc+0x26/0x50
    [<ffffffff81195ce0>] __kmalloc_node_track_caller+0xe0/0x1e0
    [<ffffffff817c8efc>] __kmalloc_reserve+0x3c/0xa0
    [<ffffffff817c8ff1>] __alloc_skb+0x91/0x2a0
    [<ffffffff817c57c1>] sock_alloc_send_pskb+0x1d1/0x340
    [<ffffffff8190aa38>] packet_sendmsg+0xa88/0xd40
    [<ffffffff817c0b60>] sock_sendmsg+0xb0/0xe0
    [<ffffffff817c232e>] sys_sendto+0x11e/0x160
    [<ffffffff81b62859>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff
#

Patching ip6gre_tunnel_xmit() to not return -1 fixes the kmemleak
complaint, but I have no clue if the patch is otherwise correct:

$ git diff net/ipv6/ip6_gre.c
diff --git a/net/ipv6/ip6_gre.c b/net/ipv6/ip6_gre.c
index c727e47..131dd09 100644
--- a/net/ipv6/ip6_gre.c
+++ b/net/ipv6/ip6_gre.c
@@ -960,7 +960,7 @@ static netdev_tx_t ip6gre_tunnel_xmit(struct sk_buff *skb,
        int ret;

        if (!ip6_tnl_xmit_ctl(t))
-               return -1;
+               goto tx_err;

        switch (skb->protocol) {
        case htons(ETH_P_IP):
$

Tested with v3.8-rc6.

Tommi
