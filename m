From: Nikolay Borisov <kernel@kyup.com>
Subject: [PATCH] Fix sleeping memory allocation in atomic context
Date: Thu, 15 Oct 2015 11:57:52 +0300
Message-ID: <1444899472-8191-1-git-send-email-kernel@kyup.com>
Cc: pablo@netfilter.org, davem@davemloft.net,
	netfilter-devel@vger.kernel.org, netdev@vger.kernel.org,
	operations@siteground.com
To: kadlec@blackhole.kfki.hu
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wi0-f169.google.com ([209.85.212.169]:33608 "EHLO
	mail-wi0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750817AbbJOI56 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 Oct 2015 04:57:58 -0400
Received: by wijp11 with SMTP id p11so18724197wij.0
        for <netdev@vger.kernel.org>; Thu, 15 Oct 2015 01:57:55 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Ipset 6.26 produces the following splat:

BUG: sleeping function called from invalid context at mm/page_alloc.c:2759
in_atomic(): 1, irqs_disabled(): 0, pid: 9664, name: ipset
CPU: 18 PID: 9664 Comm: ipset Tainted: G           O 3.12.47-clouder3 #1
Hardware name: Supermicro X10DRi/X10DRi, BIOS 1.1 04/14/2015
 0000000000000002 ffff881fd14273c8 ffffffff8163d891 ffff881fcb4264b0
 ffff881fcb4260c0 ffff881fd14273e8 ffffffff810ba5bf ffff881fd1427558
 0000000000000000 ffff881fd1427568 ffffffff81142b33 ffff881f00000000
Call Trace:
 [<ffffffff8163d891>] dump_stack+0x58/0x7f
 [<ffffffff810ba5bf>] __might_sleep+0xdf/0x110
 [<ffffffff81142b33>] __alloc_pages_nodemask+0x243/0xc20
 [<ffffffff81181c6e>] alloc_pages_current+0xbe/0x170
 [<ffffffff81188315>] new_slab+0x295/0x340
 [<ffffffff81189a40>] __slab_alloc+0x2c0/0x5a0
 [<ffffffff8164000c>] ? __schedule+0x2dc/0x760
 [<ffffffff8118a71b>] __kmalloc+0x11b/0x230
 [<ffffffffa02bd0ac>] ? ip_set_get_byname+0xec/0x100 [ip_set]
 [<ffffffffa02d23fb>] list_set_uadd+0x16b/0x314 [ip_set_list_set]
 [<ffffffff81642148>] ? _raw_write_unlock_bh+0x28/0x30
 [<ffffffffa02d1cfc>] list_set_uadt+0x21c/0x320 [ip_set_list_set]
 [<ffffffffa02d2290>] ? list_set_create+0x1a0/0x1a0 [ip_set_list_set]
 [<ffffffffa02be242>] call_ad+0x82/0x200 [ip_set]
 [<ffffffffa02bb171>] ? find_set_type+0x51/0xa0 [ip_set]
 [<ffffffff8133f275>] ? nla_parse+0xf5/0x130
 [<ffffffffa02be8ae>] ip_set_uadd+0x20e/0x2d0 [ip_set]
 [<ffffffffa02be013>] ? ip_set_create+0x2a3/0x450 [ip_set]
 [<ffffffffa02be6a0>] ? ip_set_udel+0x2e0/0x2e0 [ip_set]
 [<ffffffff815b316e>] nfnetlink_rcv_msg+0x31e/0x330
 [<ffffffff815b2e91>] ? nfnetlink_rcv_msg+0x41/0x330
 [<ffffffff815b2e50>] ? nfnl_lock+0x30/0x30
 [<ffffffff815ae179>] netlink_rcv_skb+0xa9/0xd0
 [<ffffffff815b2d45>] nfnetlink_rcv+0x15/0x20
 [<ffffffff815ade5f>] netlink_unicast+0x10f/0x190
 [<ffffffff815aedb0>] netlink_sendmsg+0x2c0/0x660
 [<ffffffff81567f00>] sock_sendmsg+0x90/0xc0
 [<ffffffff81565b03>] ? move_addr_to_user+0xa3/0xc0
 [<ffffffff81568552>] ? ___sys_recvmsg+0x182/0x300
 [<ffffffff81568064>] SYSC_sendto+0x134/0x180
 [<ffffffff811c4e01>] ? mntput+0x21/0x30
 [<ffffffff81572d2f>] ? __kfree_skb+0x3f/0xa0
 [<ffffffff815680be>] SyS_sendto+0xe/0x10
 [<ffffffff816434b2>] system_call_fastpath+0x16/0x1b

The call chain leading to this as follow:
call_add -> list_set_uadt -> list_set_uadd -> kzalloc(, GFP_KERNEL).
And since GFP_KERNEL allows initiating direct reclaim thus
potentially sleeping in the allocation path, this leads to the
aforementioned splat.

To fix it change that particular allocation type to GFP_ATOMIC, to
correctly reflect that it is happening in an atomic context.

Signed-off-by: Nikolay Borisov <kernel@kyup.com>
---

Even though this patch has been generated against the stand-alone
ipset sources I just checked the 4.3-rc4 sources and the problem
exists there as well.

 kernel/net/netfilter/ipset/ip_set_list_set.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/kernel/net/netfilter/ipset/ip_set_list_set.c b/kernel/net/netfilter/ipset/ip_set_list_set.c
index b11ba96..0f9195f 100644
--- a/kernel/net/netfilter/ipset/ip_set_list_set.c
+++ b/kernel/net/netfilter/ipset/ip_set_list_set.c
@@ -298,7 +298,7 @@ list_set_uadd(struct ip_set *set, void *value, const struct ip_set_ext *ext,
 	      ip_set_timeout_expired(ext_timeout(n, set))))
 		n =  NULL;
 
-	e = kzalloc(set->dsize, GFP_KERNEL);
+	e = kzalloc(set->dsize, GFP_ATOMIC);
 	if (!e)
 		return -ENOMEM;
 	e->id = d->id;
-- 
2.5.0
