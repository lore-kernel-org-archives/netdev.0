From: Daniel Borkmann <daniel@iogearbox.net>
Subject: [PATCH net-next] bpf: netdev is never null in __dev_map_flush
Date: Thu, 24 Aug 2017 03:20:11 +0200
Message-ID: <d8e0306b70b05bdd5e628459863d1027c8c26959.1503537400.git.daniel@iogearbox.net>
Cc: ast@fb.com, john.fastabend@gmail.com, netdev@vger.kernel.org,
        Daniel Borkmann <daniel@iogearbox.net>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from www62.your-server.de ([213.133.104.62]:47123 "EHLO
        www62.your-server.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1750962AbdHXBUU (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 23 Aug 2017 21:20:20 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

No need to test for it in fast-path, every dev in bpf_dtab_netdev
is guaranteed to be non-NULL, otherwise dev_map_update_elem() will
fail in the first place.

Signed-off-by: Daniel Borkmann <daniel@iogearbox.net>
---
 kernel/bpf/devmap.c | 8 +++-----
 1 file changed, 3 insertions(+), 5 deletions(-)

diff --git a/kernel/bpf/devmap.c b/kernel/bpf/devmap.c
index bfecabf..ecf9f99 100644
--- a/kernel/bpf/devmap.c
+++ b/kernel/bpf/devmap.c
@@ -226,12 +226,10 @@ void __dev_map_flush(struct bpf_map *map)
 		if (unlikely(!dev))
 			continue;
 
-		netdev = dev->dev;
 		__clear_bit(bit, bitmap);
-		if (unlikely(!netdev || !netdev->netdev_ops->ndo_xdp_flush))
-			continue;
-
-		netdev->netdev_ops->ndo_xdp_flush(netdev);
+		netdev = dev->dev;
+		if (likely(netdev->netdev_ops->ndo_xdp_flush))
+			netdev->netdev_ops->ndo_xdp_flush(netdev);
 	}
 }
 
-- 
1.9.3
