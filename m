From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [PATCH net-next 3/6] netvsc: prefetch the first incoming ring element
Date: Mon, 24 Jul 2017 10:57:27 -0700
Message-ID: <20170724175730.31806-4-sthemmin@microsoft.com>
References: <20170724175730.31806-1-sthemmin@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, netdev@vger.kernel.org
To: kys@microsoft.com,
	haiyangz@microsoft.com,
	sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20170724175730.31806-1-sthemmin@microsoft.com>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel/>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: "devel" <driverdev-devel-bounces@linuxdriverproject.org>
List-Id: netdev.vger.kernel.org

In interrupt handler, prefetch the first incoming ring element
so that it is in cache by the time NAPI poll gets to it.

Signed-off-by: Stephen Hemminger <sthemmin@microsoft.com>
---
 drivers/net/hyperv/netvsc.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 0a9d9feedc3f..06f39a99da7c 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -30,6 +30,7 @@
 #include <linux/if_ether.h>
 #include <linux/vmalloc.h>
 #include <linux/rtnetlink.h>
+#include <linux/prefetch.h>
 
 #include <asm/sync_bitops.h>
 
@@ -1265,10 +1266,15 @@ int netvsc_poll(struct napi_struct *napi, int budget)
 void netvsc_channel_cb(void *context)
 {
 	struct netvsc_channel *nvchan = context;
+	struct vmbus_channel *channel = nvchan->channel;
+	struct hv_ring_buffer_info *rbi = &channel->inbound;
+
+	/* preload first vmpacket descriptor */
+	prefetch(hv_get_ring_buffer(rbi) + rbi->priv_read_index);
 
 	if (napi_schedule_prep(&nvchan->napi)) {
 		/* disable interupts from host */
-		hv_begin_read(&nvchan->channel->inbound);
+		hv_begin_read(rbi);
 
 		__napi_schedule(&nvchan->napi);
 	}
-- 
2.11.0
