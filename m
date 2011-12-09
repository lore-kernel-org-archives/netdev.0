From: Laszlo Ersek <lersek@redhat.com>
Subject: [PATCH v3 REPOST] xen-netfront: delay gARP until backend switches to Connected
Date: Fri,  9 Dec 2011 12:38:58 +0100
Message-ID: <1323430738-3798-1-git-send-email-lersek@redhat.com>
To: ian.campbell@citrix.com, konrad.wilk@oracle.com, jeremy@goop.org,
	xen-devel@lists.xensource.com,
	virtualization@lists.linux-foundation.org, netdev@vger.kernel.org,
	linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

After a guest is live migrated, the xen-netfront driver emits a gratuitous
ARP message, so that networking hardware on the target host's subnet can
take notice, and public routing to the guest is re-established. However,
if the packet appears on the backend interface before the backend is added
to the target host's bridge, the packet is lost, and the migrated guest's
peers become unable to talk to the guest.

A sufficient two-parts condition to prevent the above is:

(1) ensure that the backend only moves to Connected xenbus state after its
hotplug scripts completed, ie. the netback interface got added to the
bridge; and

(2) ensure the frontend only queues the gARP when it sees the backend move
to Connected.

These two together provide complete ordering. Sub-condition (1) is
satisfied by pvops commit 43223efd9bfd.

In general, the full condition is sufficient, not necessary, because,
according to [1], live migration has been working for a long time without
satisfying sub-condition (2). However, after 43223efd9bfd was backported
to the RHEL-5 host to ensure (1), (2) still proved necessary in the RHEL-6
guest. This patch intends to provide (2) for upstream.

The Reviewed-by line comes from [2].

[1] http://old-list-archives.xen.org/xen-devel/2011-06/msg01969.html
[2] http://old-list-archives.xen.org/xen-devel/2011-07/msg00484.html

Signed-off-by: Laszlo Ersek <lersek@redhat.com>
Reviewed-by: Ian Campbell <ian.campbell@citrix.com>
---
 drivers/net/xen-netfront.c |    4 +++-
 1 files changed, 3 insertions(+), 1 deletions(-)

diff --git a/drivers/net/xen-netfront.c b/drivers/net/xen-netfront.c
index d29365a..f033656 100644
--- a/drivers/net/xen-netfront.c
+++ b/drivers/net/xen-netfront.c
@@ -1646,7 +1646,6 @@ static void netback_changed(struct xenbus_device *dev,
 	case XenbusStateInitialised:
 	case XenbusStateReconfiguring:
 	case XenbusStateReconfigured:
-	case XenbusStateConnected:
 	case XenbusStateUnknown:
 	case XenbusStateClosed:
 		break;
@@ -1657,6 +1656,9 @@ static void netback_changed(struct xenbus_device *dev,
 		if (xennet_connect(netdev) != 0)
 			break;
 		xenbus_switch_state(dev, XenbusStateConnected);
+		break;
+
+	case XenbusStateConnected:
 		netif_notify_peers(netdev);
 		break;
 
-- 
1.7.4.4
