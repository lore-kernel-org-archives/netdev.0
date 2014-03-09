From: Haiyang Zhang <haiyangz@microsoft.com>
Subject: [PATCH net-next] hyperv: Change the receive buffer size for legacy
 hosts
Date: Sun,  9 Mar 2014 16:10:59 -0700
Message-ID: <1394406659-22493-1-git-send-email-haiyangz@microsoft.com>
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

Due to a bug in the Hyper-V host verion 2008R2, we need to use a slightly smaller
receive buffer size, otherwise the buffer will not be accepted by the legacy hosts.

Signed-off-by: Haiyang Zhang <haiyangz@microsoft.com>
---
 drivers/net/hyperv/hyperv_net.h |    1 +
 drivers/net/hyperv/netvsc.c     |    6 +++++-
 2 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/hyperv/hyperv_net.h b/drivers/net/hyperv/hyperv_net.h
index 39fc230..ea5f182 100644
--- a/drivers/net/hyperv/hyperv_net.h
+++ b/drivers/net/hyperv/hyperv_net.h
@@ -516,6 +516,7 @@ struct nvsp_message {
 #define NETVSC_MTU 65536
 
 #define NETVSC_RECEIVE_BUFFER_SIZE		(1024*1024*16)	/* 16MB */
+#define NETVSC_RECEIVE_BUFFER_SIZE_LEGACY	(1024*1024*15)  /* 15MB */
 
 #define NETVSC_RECEIVE_BUFFER_ID		0xcafe
 
diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 1a0280d..daddea2 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -365,6 +365,11 @@ static int netvsc_connect_vsp(struct hv_device *device)
 		goto cleanup;
 
 	/* Post the big receive buffer to NetVSP */
+	if (net_device->nvsp_version <= NVSP_PROTOCOL_VERSION_2)
+		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE_LEGACY;
+	else
+		net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
+
 	ret = netvsc_init_recv_buf(device);
 
 cleanup:
@@ -898,7 +903,6 @@ int netvsc_device_add(struct hv_device *device, void *additional_info)
 	ndev = net_device->ndev;
 
 	/* Initialize the NetVSC channel extension */
-	net_device->recv_buf_size = NETVSC_RECEIVE_BUFFER_SIZE;
 	spin_lock_init(&net_device->recv_pkt_list_lock);
 
 	INIT_LIST_HEAD(&net_device->recv_pkt_list);
-- 
1.7.4.1
