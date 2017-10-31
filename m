From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net-next 1/4] hv_netvsc: netvsc_teardown_gpadl() split
Date: Tue, 31 Oct 2017 14:42:01 +0100
Message-ID: <20171031134204.15287-2-vkuznets@redhat.com>
References: <20171031134204.15287-1-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 Stephen Hemminger <sthemmin@microsoft.com>, linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <20171031134204.15287-1-vkuznets@redhat.com>
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

It was found that in some cases host refuses to teardown GPADL for send/
receive buffers (probably when some work with these buffere is scheduled or
ongoing). Change the teardown logic to be:
1) Send NVSP_MSG1_TYPE_REVOKE_* messages
2) Close the channel
3) Teardown GPADLs.
This seems to work reliably.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc.c | 69 +++++++++++++++++++++++----------------------
 1 file changed, 36 insertions(+), 33 deletions(-)

diff --git a/drivers/net/hyperv/netvsc.c b/drivers/net/hyperv/netvsc.c
index 5bb6a20072dd..bfc79698b8f4 100644
--- a/drivers/net/hyperv/netvsc.c
+++ b/drivers/net/hyperv/netvsc.c
@@ -100,12 +100,11 @@ static void free_netvsc_device_rcu(struct netvsc_device *nvdev)
 	call_rcu(&nvdev->rcu, free_netvsc_device);
 }
 
-static void netvsc_destroy_buf(struct hv_device *device)
+static void netvsc_revoke_buf(struct hv_device *device,
+			      struct netvsc_device *net_device)
 {
 	struct nvsp_message *revoke_packet;
 	struct net_device *ndev = hv_get_drvdata(device);
-	struct net_device_context *ndc = netdev_priv(ndev);
-	struct netvsc_device *net_device = rtnl_dereference(ndc->nvdev);
 	int ret;
 
 	/*
@@ -148,28 +147,6 @@ static void netvsc_destroy_buf(struct hv_device *device)
 		net_device->recv_section_cnt = 0;
 	}
 
-	/* Teardown the gpadl on the vsp end */
-	if (net_device->recv_buf_gpadl_handle) {
-		ret = vmbus_teardown_gpadl(device->channel,
-					   net_device->recv_buf_gpadl_handle);
-
-		/* If we failed here, we might as well return and have a leak
-		 * rather than continue and a bugchk
-		 */
-		if (ret != 0) {
-			netdev_err(ndev,
-				   "unable to teardown receive buffer's gpadl\n");
-			return;
-		}
-		net_device->recv_buf_gpadl_handle = 0;
-	}
-
-	if (net_device->recv_buf) {
-		/* Free up the receive buffer */
-		vfree(net_device->recv_buf);
-		net_device->recv_buf = NULL;
-	}
-
 	/* Deal with the send buffer we may have setup.
 	 * If we got a  send section size, it means we received a
 	 * NVSP_MSG1_TYPE_SEND_SEND_BUF_COMPLETE msg (ie sent
@@ -210,7 +187,35 @@ static void netvsc_destroy_buf(struct hv_device *device)
 		}
 		net_device->send_section_cnt = 0;
 	}
-	/* Teardown the gpadl on the vsp end */
+}
+
+static void netvsc_teardown_gpadl(struct hv_device *device,
+				  struct netvsc_device *net_device)
+{
+	struct net_device *ndev = hv_get_drvdata(device);
+	int ret;
+
+	if (net_device->recv_buf_gpadl_handle) {
+		ret = vmbus_teardown_gpadl(device->channel,
+					   net_device->recv_buf_gpadl_handle);
+
+		/* If we failed here, we might as well return and have a leak
+		 * rather than continue and a bugchk
+		 */
+		if (ret != 0) {
+			netdev_err(ndev,
+				   "unable to teardown receive buffer's gpadl\n");
+			return;
+		}
+		net_device->recv_buf_gpadl_handle = 0;
+	}
+
+	if (net_device->recv_buf) {
+		/* Free up the receive buffer */
+		vfree(net_device->recv_buf);
+		net_device->recv_buf = NULL;
+	}
+
 	if (net_device->send_buf_gpadl_handle) {
 		ret = vmbus_teardown_gpadl(device->channel,
 					   net_device->send_buf_gpadl_handle);
@@ -420,7 +425,8 @@ static int netvsc_init_buf(struct hv_device *device,
 	goto exit;
 
 cleanup:
-	netvsc_destroy_buf(device);
+	netvsc_revoke_buf(device, net_device);
+	netvsc_teardown_gpadl(device, net_device);
 
 exit:
 	return ret;
@@ -539,11 +545,6 @@ static int netvsc_connect_vsp(struct hv_device *device,
 	return ret;
 }
 
-static void netvsc_disconnect_vsp(struct hv_device *device)
-{
-	netvsc_destroy_buf(device);
-}
-
 /*
  * netvsc_device_remove - Callback when the root bus device is removed
  */
@@ -557,7 +558,7 @@ void netvsc_device_remove(struct hv_device *device)
 
 	cancel_work_sync(&net_device->subchan_work);
 
-	netvsc_disconnect_vsp(device);
+	netvsc_revoke_buf(device, net_device);
 
 	RCU_INIT_POINTER(net_device_ctx->nvdev, NULL);
 
@@ -570,6 +571,8 @@ void netvsc_device_remove(struct hv_device *device)
 	/* Now, we can close the channel safely */
 	vmbus_close(device->channel);
 
+	netvsc_teardown_gpadl(device, net_device);
+
 	/* And dissassociate NAPI context from device */
 	for (i = 0; i < net_device->num_chn; i++)
 		netif_napi_del(&net_device->chan_table[i].napi);
-- 
2.13.6
