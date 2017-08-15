From: Craig Gallek <kraigatgoog@gmail.com>
Subject: [PATCH net-next] dsa: fix flow disector null pointer
Date: Tue, 15 Aug 2017 09:43:40 -0400
Message-ID: <20170815134340.169914-1-kraigatgoog@gmail.com>
Cc: Dmitry Vyukov <dvyukov@google.com>, netdev@vger.kernel.org
To: John Crispin <john@phrozen.org>, Andrew Lunn <andrew@lunn.ch>,
        "David S . Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f169.google.com ([209.85.216.169]:37879 "EHLO
        mail-qt0-f169.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752038AbdHONnn (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 15 Aug 2017 09:43:43 -0400
Received: by mail-qt0-f169.google.com with SMTP id 16so4446990qtz.4
        for <netdev@vger.kernel.org>; Tue, 15 Aug 2017 06:43:43 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Craig Gallek <kraig@google.com>

A recent change to fix up DSA device behavior made the assumption that
all skbs passing through the flow disector will be associated with a
device. This does not appear to be a safe assumption.  Syzkaller found
the crash below by attaching a BPF socket filter that tries to find the
payload offset of a packet passing between two unix sockets.

kasan: GPF could be caused by NULL-ptr deref or user memory access
general protection fault: 0000 [#1] SMP KASAN
Dumping ftrace buffer:
   (ftrace buffer empty)
Modules linked in:
CPU: 0 PID: 2940 Comm: syzkaller872007 Not tainted 4.13.0-rc4-next-20170811 #1
Hardware name: Google Google Compute Engine/Google Compute Engine, BIOS Google 01/01/2011
task: ffff8801d1b425c0 task.stack: ffff8801d0bc0000
RIP: 0010:__skb_flow_dissect+0xdcd/0x3ae0 net/core/flow_dissector.c:445
RSP: 0018:ffff8801d0bc7340 EFLAGS: 00010206
RAX: dffffc0000000000 RBX: 0000000000000000 RCX: 0000000000000000
RDX: 0000000000000060 RSI: ffffffff856dc080 RDI: 0000000000000300
RBP: ffff8801d0bc7870 R08: 0000000000000000 R09: 0000000000000000
R10: 0000000000000008 R11: ffffed003a178f1e R12: 0000000000000000
R13: 0000000000000000 R14: ffffffff856dc080 R15: ffff8801ce223140
FS:  00000000016ed880(0000) GS:ffff8801dc000000(0000) knlGS:0000000000000000
CS:  0010 DS: 0000 ES: 0000 CR0: 0000000080050033
CR2: 0000000020008000 CR3: 00000001ce22d000 CR4: 00000000001406f0
DR0: 0000000000000000 DR1: 0000000000000000 DR2: 0000000000000000
DR3: 0000000000000000 DR6: 00000000fffe0ff0 DR7: 0000000000000400
Call Trace:
 skb_flow_dissect_flow_keys include/linux/skbuff.h:1176 [inline]
 skb_get_poff+0x9a/0x1a0 net/core/flow_dissector.c:1079
 ______skb_get_pay_offset net/core/filter.c:114 [inline]
 __skb_get_pay_offset+0x15/0x20 net/core/filter.c:112
Code: 80 3c 02 00 44 89 6d 10 0f 85 44 2b 00 00 4d 8b 67 20 48 b8 00 00 00 00 00 fc ff df 49 8d bc 24 00 03 00 00 48 89 fa 48 c1 ea 03 <80> 3c 02 00 0f 85 13 2b 00 00 4d 8b a4 24 00 03 00 00 4d 85 e4
RIP: __skb_flow_dissect+0xdcd/0x3ae0 net/core/flow_dissector.c:445 RSP: ffff8801d0bc7340

Fixes: 43e665287f93 ("net-next: dsa: fix flow dissection")
Reported-by: Dmitry Vyukov <dvyukov@google.com>
Signed-off-by: Craig Gallek <kraig@google.com>
---
 net/core/flow_dissector.c | 2 +-
 1 file changed, 1 insertion(+), 1 deletion(-)

diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
index 79b9c06c83ad..e2eaa1ff948d 100644
--- a/net/core/flow_dissector.c
+++ b/net/core/flow_dissector.c
@@ -442,7 +442,7 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
 		nhoff = skb_network_offset(skb);
 		hlen = skb_headlen(skb);
 #if IS_ENABLED(CONFIG_NET_DSA)
-		if (unlikely(netdev_uses_dsa(skb->dev))) {
+		if (unlikely(skb->dev && netdev_uses_dsa(skb->dev))) {
 			const struct dsa_device_ops *ops;
 			int offset;
 
-- 
2.14.0.434.g98096fd7a8-goog
