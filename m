From: Andrey Konovalov <andreyknvl@google.com>
Subject: [PATCH] tun: Use netif_receive_skb instead of netif_rx
Date: Tue, 29 Nov 2016 16:25:36 +0100
Message-ID: <1480433136-7922-1-git-send-email-andreyknvl@google.com>
Cc: Dmitry Vyukov <dvyukov@google.com>,
        Kostya Serebryany <kcc@google.com>, syzkaller@googlegroups.com,
        Andrey Konovalov <andreyknvl@google.com>
To: Herbert Xu <herbert@gondor.apana.org.au>,
        "David S . Miller" <davem@davemloft.net>,
        Jason Wang <jasowang@redhat.com>,
        Eric Dumazet <edumazet@google.com>,
        Paolo Abeni <pabeni@redhat.com>,
        "Michael S . Tsirkin" <mst@redhat.com>,
        Soheil Hassas Yeganeh <soheil@google.com>,
        Markus Elfring <elfring@users.sourceforge.net>,
        Mike Rapoport <rppt@linux.vnet.ibm.com>,
        netdev@vger.kernel.org, linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wj0-f170.google.com ([209.85.210.170]:36403 "EHLO
        mail-wj0-f170.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1757777AbcK2PZx (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 29 Nov 2016 10:25:53 -0500
Received: by mail-wj0-f170.google.com with SMTP id qp4so148344648wjc.3
        for <netdev@vger.kernel.org>; Tue, 29 Nov 2016 07:25:52 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch changes tun.c to call netif_receive_skb instead of netif_rx
when a packet is received. The difference between the two is that netif_rx
queues the packet into the backlog, and netif_receive_skb proccesses the
packet in the current context.

This patch is required for syzkaller [1] to collect coverage from packet
receive paths, when a packet being received through tun (syzkaller collects
coverage per process in the process context).

A similar patch was introduced back in 2010 [2, 3], but the author found
out that the patch doesn't help with the task he had in mind (for cgroups
to shape network traffic based on the original process) and decided not to
go further with it. The main concern back then was about possible stack
exhaustion with 4K stacks, but CONFIG_4KSTACKS was removed and stacks are
8K now.

[1] https://github.com/google/syzkaller

[2] https://www.spinics.net/lists/netdev/thrd440.html#130570

[3] https://www.spinics.net/lists/netdev/msg130570.html

Signed-off-by: Andrey Konovalov <andreyknvl@google.com>
---
 drivers/net/tun.c | 4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 8093e39..4b56e91 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -1304,7 +1304,9 @@ static ssize_t tun_get_user(struct tun_struct *tun, struct tun_file *tfile,
 	skb_probe_transport_header(skb, 0);
 
 	rxhash = skb_get_hash(skb);
-	netif_rx_ni(skb);
+	local_bh_disable();
+	netif_receive_skb(skb);
+	local_bh_enable();
 
 	stats = get_cpu_ptr(tun->pcpu_stats);
 	u64_stats_update_begin(&stats->syncp);
-- 
2.8.0.rc3.226.g39d4020
