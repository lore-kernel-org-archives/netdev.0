From: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Subject: [net-next-2.6 PATCH 5/5] fcoe: Use NETIF_F_FCOE_MTU
	flag to set up	max frame size (lport->mfs)
Date: Wed, 22 Jul 2009 16:29:57 -0700
Message-ID: <20090722232956.26937.24429.stgit@localhost.localdomain>
References: <20090722232759.26937.78765.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: linux-scsi-u79uwXL29TY76Z2rM5mHXA@public.gmane.org, netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org,
	Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>, gospo-H+wXaHxf7aLQT0dZR+AlfA@public.gmane.org,
	devel-s9riP+hp16TNLxjTenLetw@public.gmane.org
To: davem-fT/PcQaiUtIeIZ0/mPfg9Q@public.gmane.org
Return-path: <devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org>
In-Reply-To: <20090722232759.26937.78765.stgit-bi+AKbBUZKY6gyzm1THtWbp2dZbC/Bob@public.gmane.org>
List-Unsubscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=unsubscribe>
List-Archive: <http://www.open-fcoe.org/pipermail/devel>
List-Post: <mailto:devel-s9riP+hp16TNLxjTenLetw@public.gmane.org>
List-Help: <mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=help>
List-Subscribe: <http://www.open-fcoe.org/mailman/listinfo/devel>,
	<mailto:devel-request-s9riP+hp16TNLxjTenLetw@public.gmane.org?subject=subscribe>
Sender: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
Errors-To: devel-bounces-s9riP+hp16TNLxjTenLetw@public.gmane.org
List-Id: netdev.vger.kernel.org

From: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>

Add a define of FCOE_MTU as 2158 bytes and use FCOE_MTU when the LLD is found
to support NETIF_F_FCOE_MTU. The lport->mfs is then calculated out of the
2158 FCOE_MTU. Otherwise, we stick with the netdev->mtu, i.e., LAN MTU. Also,
change the notification on NETDEV_CHANGEMTU event to bypass changing mfs when
LAN MTU is changed if NETIF_F_FCOE_MTU is supported.

Signed-off-by: Yi Zou <yi.zou-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher-ral2JQCrhuEAvxtiuMwx3w@public.gmane.org>
---

 drivers/scsi/fcoe/fcoe.c |   11 +++++++++--
 drivers/scsi/fcoe/fcoe.h |    4 ++++
 2 files changed, 13 insertions(+), 2 deletions(-)

diff --git a/drivers/scsi/fcoe/fcoe.c b/drivers/scsi/fcoe/fcoe.c
index 0a5609b..e0a885c 100644
--- a/drivers/scsi/fcoe/fcoe.c
+++ b/drivers/scsi/fcoe/fcoe.c
@@ -291,8 +291,13 @@ static int fcoe_netdev_config(struct fc_lport *lp, struct net_device *netdev)
 	 * user-configured limit.  If the MFS is too low, fcoe_link_ok()
 	 * will return 0, so do this first.
 	 */
-	mfs = fc->real_dev->mtu - (sizeof(struct fcoe_hdr) +
-				   sizeof(struct fcoe_crc_eof));
+	mfs = fc->real_dev->mtu;
+	if (fc->phys_dev->features & NETIF_F_FCOE_MTU) {
+		mfs = FCOE_MTU;
+		printk(KERN_DEBUG "fcoe:%s supports FCOE_MTU of %d bytes\n",
+		       netdev->name, mfs);
+	}
+	mfs -= (sizeof(struct fcoe_hdr) + sizeof(struct fcoe_crc_eof));
 	if (fc_set_mfs(lp, mfs))
 		return -EINVAL;
 
@@ -1420,6 +1425,8 @@ static int fcoe_device_notification(struct notifier_block *notifier,
 	case NETDEV_CHANGE:
 		break;
 	case NETDEV_CHANGEMTU:
+		if (fc->phys_dev->features & NETIF_F_FCOE_MTU)
+			break;
 		mfs = fc->real_dev->mtu -
 			(sizeof(struct fcoe_hdr) +
 			 sizeof(struct fcoe_crc_eof));
diff --git a/drivers/scsi/fcoe/fcoe.h b/drivers/scsi/fcoe/fcoe.h
index 0d724fa..be9735d 100644
--- a/drivers/scsi/fcoe/fcoe.h
+++ b/drivers/scsi/fcoe/fcoe.h
@@ -64,6 +64,10 @@ do {                                                            	\
 			   printk(KERN_INFO "fcoe: %s" fmt,	\
 				  netdev->name, ##args);)
 
+/* Max MTU for FCoE: 14 (FCoE header) + 24 (FC header) + 2112 (max FC payload)
+ * + 4 (FC CRC) + 4 (FCoE trailer) =  2158 bytes */
+#define FCOE_MTU	2158
+
 /*
  * this percpu struct for fcoe
  */
