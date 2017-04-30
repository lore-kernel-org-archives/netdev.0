From: kys@exchange.microsoft.com
Subject: [PATCH 6/6] HV: properly delay KVP packets when negotiation is in
 progress
Date: Sun, 30 Apr 2017 16:21:19 -0700
Message-ID: <1493594479-25329-6-git-send-email-kys@exchange.microsoft.com>
References: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
Reply-To: kys@microsoft.com
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
To: davem@davemloft.net, netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
 devel@linuxdriverproject.org, olaf@aepfle.de, apw@canonical.com,
 jasowang@redhat.com, leann.ogasawara@canonical.comi,
 marcelo.cerri@canonical.com, sthemmin@microsoft.com
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1493594420-25214-1-git-send-email-kys@exchange.microsoft.com>
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

From: Long Li <longli@microsoft.com>

The host may send multiple negotiation packets
(due to timeout) before the KVP user-mode daemon
is connected. KVP user-mode daemon is connected.
We need to defer processing those packets
until the daemon is negotiated and connected.
It's okay for guest to respond
to all negotiation packets.

In addition, the host may send multiple staged
KVP requests as soon as negotiation is done.
We need to properly process those packets using one
tasklet for exclusive access to ring buffer.

This patch is based on the work of
Nick Meier <Nick.Meier@microsoft.com>.

Signed-off-by: Long Li <longli@microsoft.com>
Signed-off-by: K. Y. Srinivasan <kys@microsoft.com>
---
 drivers/hv/hv_kvp.c |   14 ++++++++------
 1 files changed, 8 insertions(+), 6 deletions(-)

diff --git a/drivers/hv/hv_kvp.c b/drivers/hv/hv_kvp.c
index e99ff2d..9a90b91 100644
--- a/drivers/hv/hv_kvp.c
+++ b/drivers/hv/hv_kvp.c
@@ -112,7 +112,7 @@ static void kvp_poll_wrapper(void *channel)
 {
 	/* Transaction is finished, reset the state here to avoid races. */
 	kvp_transaction.state = HVUTIL_READY;
-	hv_kvp_onchannelcallback(channel);
+	tasklet_schedule(&((struct vmbus_channel *)channel)->callback_event);
 }
 
 static void kvp_register_done(void)
@@ -159,7 +159,7 @@ static void kvp_timeout_func(struct work_struct *dummy)
 
 static void kvp_host_handshake_func(struct work_struct *dummy)
 {
-	hv_poll_channel(kvp_transaction.recv_channel, hv_kvp_onchannelcallback);
+	tasklet_schedule(&kvp_transaction.recv_channel->callback_event);
 }
 
 static int kvp_handle_handshake(struct hv_kvp_msg *msg)
@@ -625,16 +625,17 @@ void hv_kvp_onchannelcallback(void *context)
 		     NEGO_IN_PROGRESS,
 		     NEGO_FINISHED} host_negotiatied = NEGO_NOT_STARTED;
 
-	if (host_negotiatied == NEGO_NOT_STARTED &&
-	    kvp_transaction.state < HVUTIL_READY) {
+	if (kvp_transaction.state < HVUTIL_READY) {
 		/*
 		 * If userspace daemon is not connected and host is asking
 		 * us to negotiate we need to delay to not lose messages.
 		 * This is important for Failover IP setting.
 		 */
-		host_negotiatied = NEGO_IN_PROGRESS;
-		schedule_delayed_work(&kvp_host_handshake_work,
+		if (host_negotiatied == NEGO_NOT_STARTED) {
+			host_negotiatied = NEGO_IN_PROGRESS;
+			schedule_delayed_work(&kvp_host_handshake_work,
 				      HV_UTIL_NEGO_TIMEOUT * HZ);
+		}
 		return;
 	}
 	if (kvp_transaction.state > HVUTIL_READY)
@@ -702,6 +703,7 @@ void hv_kvp_onchannelcallback(void *context)
 				       VM_PKT_DATA_INBAND, 0);
 
 		host_negotiatied = NEGO_FINISHED;
+		hv_poll_channel(kvp_transaction.recv_channel, kvp_poll_wrapper);
 	}
 
 }
-- 
1.7.1
