From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next] net/mlx4: use one page fragment per incoming frame
Date: Mon, 03 Jun 2013 10:54:55 -0700
Message-ID: <1370282095.24311.171.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Amir Vadai <amirv@mellanox.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f47.google.com ([209.85.220.47]:50239 "EHLO
	mail-pa0-f47.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757202Ab3FCRy5 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 3 Jun 2013 13:54:57 -0400
Received: by mail-pa0-f47.google.com with SMTP id kl13so998520pab.34
        for <netdev@vger.kernel.org>; Mon, 03 Jun 2013 10:54:57 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Eric Dumazet <edumazet@google.com>

mlx4 driver has a suboptimal memory allocation strategy for regular
MTU=1500 frames, as it uses two page fragments :

One of 512 bytes and one of 1024 bytes.

This makes GRO less effective, as each GSO packet contains 8 MSS instead
of 16 MSS.

Performance of a single TCP flow gains 25 % increase with the following
patch.

Before patch :

A:~# netperf -H 192.168.0.2 -Cc
MIGRATED TCP STREAM TEST ...
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      13798.47   3.06     4.20     0.436   0.598  

After patch :

A:~# netperf -H 192.68.0.2 -Cc
MIGRATED TCP STREAM TEST ...
Recv   Send    Send                          Utilization       Service Demand
Socket Socket  Message  Elapsed              Send     Recv     Send    Recv
Size   Size    Size     Time     Throughput  local    remote   local   remote
bytes  bytes   bytes    secs.    10^6bits/s  % S      % S      us/KB   us/KB

 87380  16384  16384    10.00      17273.80   3.44     4.19     0.391   0.477  

Signed-off-by: Eric Dumazet <edumazet@google.com>
Cc: Amir Vadai <amirv@mellanox.com>
---
 drivers/net/ethernet/mellanox/mlx4/mlx4_en.h |    6 +++---
 1 file changed, 3 insertions(+), 3 deletions(-)

diff --git a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
index b1d7657..b1f51c1 100644
--- a/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
+++ b/drivers/net/ethernet/mellanox/mlx4/mlx4_en.h
@@ -98,11 +98,11 @@
 #define MLX4_EN_ALLOC_SIZE	PAGE_ALIGN(16384)
 #define MLX4_EN_ALLOC_ORDER	get_order(MLX4_EN_ALLOC_SIZE)
 
-/* Receive fragment sizes; we use at most 4 fragments (for 9600 byte MTU
+/* Receive fragment sizes; we use at most 3 fragments (for 9600 byte MTU
  * and 4K allocations) */
 enum {
-	FRAG_SZ0 = 512 - NET_IP_ALIGN,
-	FRAG_SZ1 = 1024,
+	FRAG_SZ0 = 1536 - NET_IP_ALIGN,
+	FRAG_SZ1 = 4096,
 	FRAG_SZ2 = 4096,
 	FRAG_SZ3 = MLX4_EN_ALLOC_SIZE
 };
