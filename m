From: "K. Y. Srinivasan" <kys@microsoft.com>
Subject: [PATCH 1/1 V2] Drivers: net-next: hyperv: Increase the size of the
 sendbuf region
Date: Sat,  2 Aug 2014 10:42:02 -0700
Message-ID: <1407001322-12010-1-git-send-email-kys@microsoft.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com
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

Intel did some benchmarking on our network throughput when Linux on Hyper-V
is as used as a gateway. This fix gave us almost a 1 Gbps additional throughput
on about 5Gbps base throughput we hadi, prior to increasing the sendbuf size.
The sendbuf mechanism is a copy based transport that we have which is clearly
more optimal than the copy-free page flipping mechanism (for small packets).
In the forwarding scenario, we deal only with MTU sized packets,
and increasing the size of the senbuf area gave us the additional performance.
For what it is worth, Windows guests on Hyper-V, I am told use similar sendbuf
size as well.

The exact value of sendbuf I think is less important than the fact that it needs
to be larger than what Linux can allocate as physically contiguous memory.
Thus the change over to allocating via vmalloc().

We currently allocate 16MB receive buffer and we use vmalloc there for allocation.
Also the low level channel code has already been modified to deal with physically
dis-contiguous memory in the ringbuffer setup.

Based on experimentation Intel did, they say there was some improvement in throughput
as the sendbuf size was increased up to 16MB and there was no effect on throughput
beyond 16MB. Thus I have chosen 16MB here.

Increasing the sendbuf value makes a material difference in small packet handling

In this version of the patch, based on David's feedback, I have added
additional details in the commit log.


Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    2 +-
 drivers/net/hyperv/netvsc.c     |    7 ++-----
 2 files changed, 3 insertions(+), 6 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 6cc37c1..40ba1ef 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -584,7 +584,7 @@ struct nvsp_message {
 
 #define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*16)	/* 16MB */
 #define NETVSC_RECEIVE_BUFFER_SIZE_LEGACY	(1024*1024*15)  /* 15MB */
-#define NETVSC_SEND_BUFFER_SIZE			(1024 * 1024)   /* 1MB */
+#define NETVSC_SEND_BUFFER_SIZE			(1024 * 1024 * 16)   /* 16MB */
 #define NETVSC_INVALID_INDEX			-1
 
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index c041f63..c76178e 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -193,8 +193,7 @@ static int netvsc_destroy_buf(struct netvsc_device *net_device)
 	}
 	if (net_device->send_buf) {
 		/* Free up the receive buffer */
-		free_pages((unsigned long)net_device->send_buf,
-			   get_order(net_device->send_buf_size));
+		vfree(net_device->send_buf);
 		net_device->send_buf = NULL;
 	}
 	kfree(net_device->send_section_map);
@@ -303,9 +302,7 @@ static int netvsc_init_buf(struct hv_device *device)
 
 	/* Now setup the send buffer.
 	 */
-	net_device->send_buf =
-		(void *)__get_free_pages(GFP_KERNEL|__GFP_ZERO,
-					 get_order(net_device->send_buf_size));
+	net_device->send_buf = vzalloc(net_device->send_buf_size);
 	if (!net_device->send_buf) {
 		netdev_err(ndev, "unable to allocate send "
 			   "buffer of size %d\n", net_device->send_buf_size);
-- 
1.7.4.1
