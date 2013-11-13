From: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
Subject: [PATCH net 3/3] bridge: Fix memory leak when deleting bridge with vlan filtering enabled
Date: Wed, 13 Nov 2013 17:26:14 +0900
Message-ID: <1384331175-4136-4-git-send-email-makita.toshiaki@lab.ntt.co.jp>
References: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
To: "David S . Miller" <davem@davemloft.net>,
	Stephen Hemminger <stephen@networkplumber.org>,
	Vlad Yasevich <vyasevic@redhat.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from tama50.ecl.ntt.co.jp ([129.60.39.147]:47788 "EHLO
	tama50.ecl.ntt.co.jp" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758394Ab3KMI2W (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 13 Nov 2013 03:28:22 -0500
In-Reply-To: <1384331175-4136-1-git-send-email-makita.toshiaki@lab.ntt.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We currently don't call br_vlan_flush() when deleting a bridge, which
leads to memory leak if br->vlan_info is allocated.

Steps to reproduce:
  while :
  do
    brctl addbr br0
    bridge vlan add dev br0 vid 10 self
    brctl delbr br0
  done
We can observe the cache size of corresponding slab entry
(as kmalloc-2048 in SLUB) is increased.

kmemleak output:
unreferenced object 0xffff8800b68a7000 (size 2048):
  comm "bridge", pid 2086, jiffies 4295774704 (age 47.656s)
  hex dump (first 32 bytes):
    00 00 00 00 00 00 00 00 00 48 9b 36 00 88 ff ff  .........H.6....
    00 00 00 00 00 00 00 00 00 00 00 00 00 00 00 00  ................
  backtrace:
    [<ffffffff815eb6ae>] kmemleak_alloc+0x4e/0xb0
    [<ffffffff8116a1ca>] kmem_cache_alloc_trace+0xca/0x220
    [<ffffffffa03eddd6>] br_vlan_add+0x66/0xe0 [bridge]
    [<ffffffffa03e543c>] br_setlink+0x2dc/0x340 [bridge]
    [<ffffffff8150e481>] rtnl_bridge_setlink+0x101/0x200
    [<ffffffff8150d9d9>] rtnetlink_rcv_msg+0x99/0x260
    [<ffffffff81528679>] netlink_rcv_skb+0xa9/0xc0
    [<ffffffff8150d938>] rtnetlink_rcv+0x28/0x30
    [<ffffffff81527ccd>] netlink_unicast+0xdd/0x190
    [<ffffffff8152807f>] netlink_sendmsg+0x2ff/0x740
    [<ffffffff814e8368>] sock_sendmsg+0x88/0xc0
    [<ffffffff814e8ac8>] ___sys_sendmsg.part.14+0x298/0x2b0
    [<ffffffff814e91de>] __sys_sendmsg+0x4e/0x90
    [<ffffffff814e922e>] SyS_sendmsg+0xe/0x10
    [<ffffffff81601669>] system_call_fastpath+0x16/0x1b
    [<ffffffffffffffff>] 0xffffffffffffffff

Signed-off-by: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>
---
 net/bridge/br_if.c | 1 +
 1 file changed, 1 insertion(+)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index c41d5fb..6e6194f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -172,6 +172,7 @@ void br_dev_delete(struct net_device *dev, struct list_head *head)
 		del_nbp(p);
 	}
 
+	br_vlan_flush(br);
 	del_timer_sync(&br->gc_timer);
 
 	br_sysfs_delbr(br->dev);
-- 
1.8.1.2
