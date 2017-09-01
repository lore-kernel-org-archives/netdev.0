From: Orson Zhai <orson.zhai@linaro.org>
Subject: [RFC] tools: selftests: psock_tpacket: skip un-supported tpacket_v3 test
Date: Fri, 1 Sep 2017 11:53:45 +0800
Message-ID: <20170901035345.15512-1-orson.zhai@linaro.org>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, <linux-kselftest@vger.kernel.org>,
        <linux-kernel@vger.kernel.org>, Orson Zhai <orson.zhai@linaro.org>
To: "David S . Miller" <davem@davemloft.net>,
        Shuah Khan <shuah@kernel.org>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The TPACKET_V3 test of PACKET_TX_RING will fail with kernel version
lower than v4.11. Supported code of tx ring was add with commit id
<7f953ab2ba46: af_packet: TX_RING support for TPACKET_V3> at Jan. 3
of 2017.

So skip this item test instead of reporting failing for old kernels.

Signed-off-by: Orson Zhai <orson.zhai@linaro.org>
---
 tools/testing/selftests/net/psock_tpacket.c | 17 ++++++++++++++---
 1 file changed, 14 insertions(+), 3 deletions(-)

diff --git a/tools/testing/selftests/net/psock_tpacket.c b/tools/testing/selftests/net/psock_tpacket.c
index 7f6cd9fdacf3..f0cfc18c3726 100644
--- a/tools/testing/selftests/net/psock_tpacket.c
+++ b/tools/testing/selftests/net/psock_tpacket.c
@@ -57,6 +57,7 @@
 #include <net/if.h>
 #include <inttypes.h>
 #include <poll.h>
+#include <errno.h>
 
 #include "psock_lib.h"
 
@@ -676,7 +677,7 @@ static void __v3_fill(struct ring *ring, unsigned int blocks, int type)
 	ring->flen = ring->req3.tp_block_size;
 }
 
-static void setup_ring(int sock, struct ring *ring, int version, int type)
+static int setup_ring(int sock, struct ring *ring, int version, int type)
 {
 	int ret = 0;
 	unsigned int blocks = 256;
@@ -703,7 +704,11 @@ static void setup_ring(int sock, struct ring *ring, int version, int type)
 
 	if (ret == -1) {
 		perror("setsockopt");
-		exit(1);
+		if (errno == EINVAL) {
+			printf("[SKIP] This type seems un-supported in current kernel, skipped.\n");
+			return -1;
+		} else
+			exit(1);
 	}
 
 	ring->rd_len = ring->rd_num * sizeof(*ring->rd);
@@ -715,6 +720,7 @@ static void setup_ring(int sock, struct ring *ring, int version, int type)
 
 	total_packets = 0;
 	total_bytes = 0;
+	return 0;
 }
 
 static void mmap_ring(int sock, struct ring *ring)
@@ -830,7 +836,12 @@ static int test_tpacket(int version, int type)
 
 	sock = pfsocket(version);
 	memset(&ring, 0, sizeof(ring));
-	setup_ring(sock, &ring, version, type);
+	if(setup_ring(sock, &ring, version, type)) {
+		/* skip test when error of invalid argument */
+		close(sock);
+		return 0;
+	}
+
 	mmap_ring(sock, &ring);
 	bind_ring(sock, &ring);
 	walk_ring(sock, &ring);
-- 
2.12.2
