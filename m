From: Vitaly Kuznetsov <vkuznets@redhat.com>
Subject: [PATCH net 3/4] hv_netvsc: protect module refcount by checking
 net_device_ctx->vf_netdev
Date: Thu, 11 Aug 2016 12:58:56 +0200
Message-ID: <1470913137-29167-4-git-send-email-vkuznets@redhat.com>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@linuxdriverproject.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
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

We're not guaranteed to see NETDEV_REGISTER/NETDEV_UNREGISTER notifications
only once per VF but we increase/decrease module refcount unconditionally.
Check vf_netdev to make sure we don't take/release it twice. We presume
that only one VF per netvsc device may exist.

Signed-off-by: Vitaly Kuznetsov <vkuznets@redhat.com>
---
 drivers/net/hyperv/netvsc_drv.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/drivers/net/hyperv/netvsc_drv.c b/drivers/net/hyperv/netvsc_drv.c
index b3c31e3..874829a 100644
--- a/drivers/net/hyperv/netvsc_drv.c
+++ b/drivers/net/hyperv/netvsc_drv.c
@@ -1204,7 +1204,7 @@ static int netvsc_register_vf(struct net_device *vf_netdev)
 
 	net_device_ctx = netdev_priv(ndev);
 	netvsc_dev = net_device_ctx->nvdev;
-	if (netvsc_dev == NULL)
+	if (!netvsc_dev || net_device_ctx->vf_netdev)
 		return NOTIFY_DONE;
 
 	netdev_info(ndev, "VF registering: %s\n", vf_netdev->name);
@@ -1334,7 +1334,7 @@ static int netvsc_unregister_vf(struct net_device *vf_netdev)
 
 	net_device_ctx = netdev_priv(ndev);
 	netvsc_dev = net_device_ctx->nvdev;
-	if (netvsc_dev == NULL)
+	if (!netvsc_dev || !net_device_ctx->vf_netdev)
 		return NOTIFY_DONE;
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 	netvsc_inject_disable(net_device_ctx);
-- 
2.7.4
