From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Add support for physically discontinuous
 receive buffer
Date: Mon, 27 Jan 2014 15:03:42 -0800
Message-ID: <1390863822-3509-1-git-send-email-haiyangz@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: olaf@aepfle.de, jasowang@redhat.com, driverdev-devel@linuxdriverproject.org,
 linux-kernel@vger.kernel.org, haiyangz@microsoft.com
To: davem@davemloft.net,
	netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

This will allow us to use bigger receive buffer, and prevent allocation failure
due to fragmented memory.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
Reviewed-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/channel.c            |   14 ++++++++------
 drivers/net/hyperv/hyperv_net.h |    2 +-
 drivers/net/hyperv/netvsc.c     |    7 ++-----
 3 files changed, 11 insertions(+), 12 deletions(-)

diff --git a/drivers/hv/channel.c b/drivers/hv/channel.c
index cea623c..69ea36f 100644
--- a/drivers/hv/channel.c
+++ b/drivers/hv/channel.c
@@ -209,7 +209,6 @@ static int create_gpadl_header(void *kbuffer, u32 size,
 {
 	int i;
 	int pagecount;
-	unsigned long long pfn;
 	struct vmbus_channel_gpadl_header *gpadl_header;
 	struct vmbus_channel_gpadl_body *gpadl_body;
 	struct vmbus_channel_msginfo *msgheader;
@@ -219,7 +218,6 @@ static int create_gpadl_header(void *kbuffer, u32 size,
 	int pfnsum, pfncount, pfnleft, pfncurr, pfnsize;
 
 	pagecount = size >> PAGE_SHIFT;
-	pfn = virt_to_phys(kbuffer) >> PAGE_SHIFT;
 
 	/* do we need a gpadl body msg */
 	pfnsize = MAX_SIZE_CHANNEL_MESSAGE -
@@ -248,7 +246,8 @@ static int create_gpadl_header(void *kbuffer, u32 size,
 		gpadl_header->range[0].byte_offset = 0;
 		gpadl_header->range[0].byte_count = size;
 		for (i = 0; i < pfncount; i++)
-			gpadl_header->range[0].pfn_array[i] = pfn+i;
+			gpadl_header->range[0].pfn_array[i] = slow_virt_to_phys(
+				kbuffer + PAGE_SIZE * i) >> PAGE_SHIFT;
 		*msginfo = msgheader;
 		*messagecount = 1;
 
@@ -301,7 +300,9 @@ static int create_gpadl_header(void *kbuffer, u32 size,
 			 * so the hypervisor gurantees that this is ok.
 			 */
 			for (i = 0; i < pfncurr; i++)
-				gpadl_body->pfn[i] = pfn + pfnsum + i;
+				gpadl_body->pfn[i] = slow_virt_to_phys(
+					kbuffer + PAGE_SIZE * (pfnsum + i)) >>
+					PAGE_SHIFT;
 
 			/* add to msg header */
 			list_add_tail(&msgbody->msglistentry,
@@ -327,7 +328,8 @@ static int create_gpadl_header(void *kbuffer, u32 size,
 		gpadl_header->range[0].byte_offset = 0;
 		gpadl_header->range[0].byte_count = size;
 		for (i = 0; i < pagecount; i++)
-			gpadl_header->range[0].pfn_array[i] = pfn+i;
+			gpadl_header->range[0].pfn_array[i] = slow_virt_to_phys(
+				kbuffer + PAGE_SIZE * i) >> PAGE_SHIFT;
 
 		*msginfo = msgheader;
 		*messagecount = 1;
@@ -344,7 +346,7 @@ nomem:
  * vmbus_establish_gpadl - Estabish a GPADL for the specified buffer
  *
  * @channel: a channel
- * @kbuffer: from kmalloc
+ * @kbuffer: from kmalloc or vmalloc
  * @size: page-size multiple
  * @gpadl_handle: some funky thing
  */
diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index a26eecb..7b594ce 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -462,7 +462,7 @@ struct nvsp_message {
 
 #define NETVSC_MTU 65536
 
-#define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*2)	/* 2MB */
+#define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*16)	/* 16MB */
 
 #define NETVSC_RECEIVE_BUFFER_ID		0xcafe
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 93b485b..03a2c6e 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -136,8 +136,7 @@ static int netvsc_destroy_recv_buf(struct netvsc_device *net_device)
 
 	if (net_device->recv_buf) {
 		/* Free up the receive buffer */
-		free_pages((unsigned long)net_device->recv_buf,
-			get_order(net_device->recv_buf_size));
+		vfree(net_device->recv_buf);
 		net_device->recv_buf = NULL;
 	}
 
@@ -163,9 +162,7 @@ static int netvsc_init_recv_buf(struct hv_device *device)
 		return -ENODEV;
 	ndev = net_device->ndev;
 
-	net_device->recv_buf =
-		(void *)__get_free_pages(GFP_KERNEL|__GFP_ZERO,
-				get_order(net_device->recv_buf_size));
+	net_device->recv_buf = vzalloc(net_device->recv_buf_size);
 	if (!net_device->recv_buf) {
 		netdev_err(ndev, "unable to allocate receive "
 			"buffer of size %d\n", net_device->recv_buf_size);
-- 
1.7.4.1
