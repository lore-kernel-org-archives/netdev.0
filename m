From: Stephen Hemminger <stephen@networkplumber.org>
Subject: [RFC 1/2] netvsc: reference counting fix
Date: Sat, 13 Aug 2016 11:35:59 -0700
Message-ID: <20160813113559.617b7c55@xeon-e3>
References: <1470913137-29167-1-git-send-email-vkuznets@redhat.com>
 <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, Haiyang Zhang <haiyangz@microsoft.com>,
 linux-kernel@vger.kernel.org, devel@linuxdriverproject.org
To: Vitaly Kuznetsov <vkuznets@redhat.com>
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1470913137-29167-3-git-send-email-vkuznets@redhat.com>
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

This is how I think it should be fixed, but not tested yet.

Subjec: netvsc: use device not module reference counts

Fix how the cross-device reference counting is handled.  When VF is
associated with the synthetic interface, the VF driver module should
still be able to be unloaded.  The module unload code will callback
with NETDEV_UNREGISTER event which breaks the connection safely.
(Fixes 9f4b5ba5db4 hv_netvsc: Implement support for VF drivers on Hyper-V)

Signed-off-by: Stephen Hemminger <sthemmin@linuxonhyperv.com>


--- a/drivers/net/hyperv/netvsc_drv.c	2016-08-13 11:25:40.243995863 -0700
+++ b/drivers/net/hyperv/netvsc_drv.c	2016-08-13 11:25:40.239995844 -0700
@@ -1220,10 +1220,8 @@ static int netvsc_register_vf(struct net
 		return NOTIFY_DONE;
 
 	netdev_info(ndev, "VF registering: %s\n", vf_netdev->name);
-	/*
-	 * Take a reference on the module.
-	 */
-	try_module_get(THIS_MODULE);
+
+	dev_hold(vf_netdev);
 	netvsc_dev->vf_netdev = vf_netdev;
 	return NOTIFY_OK;
 }
@@ -1345,7 +1343,7 @@ static int netvsc_unregister_vf(struct n
 	netdev_info(ndev, "VF unregistering: %s\n", vf_netdev->name);
 
 	netvsc_dev->vf_netdev = NULL;
-	module_put(THIS_MODULE);
+	dev_put(vf_netdev);
 	return NOTIFY_OK;
 }
