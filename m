From: "Benjamin Li" <benli@broadcom.com>
Subject: [PATCH] cnic: Give a chance for the uio device to be opened
 before failing the path request
Date: Thu, 8 Apr 2010 14:34:28 -0700
Message-ID: <1270762468-21128-1-git-send-email-benli@broadcom.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "Benjamin Li" <benli@broadcom.com>, "Eddie Wai" <waie@broadcom.com>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Michael Chan" <mchan@broadcom.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mms3.broadcom.com ([216.31.210.19]:4408 "EHLO MMS3.broadcom.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1759136Ab0DHVei (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 8 Apr 2010 17:34:38 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

There is a timing condition; where the time between the CNIC's
/dev/uio* device registration and then the issuing of path requests
messages is faster the brcm_iscsiuio daemon initializing.

This can be seen if one sets the machine to automatically login into
iSCSI targets.  Then reset the network and iscsi daemons in quick
succession.  The login will fail because iscsid will only try
a couple of times in quick succession.  This patch will allow some
additional needed time for the brcm_iscsiuio daemon to initialize
before failing the path request call.

Signed-off-by: Benjamin Li <benli@broadcom.com>
Signed-off-by: Eddie Wai <waie@broadcom.com>
---
 drivers/net/cnic.c |   10 +++++++++-
 1 files changed, 9 insertions(+), 1 deletions(-)

diff --git a/drivers/net/cnic.c b/drivers/net/cnic.c
index 9781942..897f171 100644
--- a/drivers/net/cnic.c
+++ b/drivers/net/cnic.c
@@ -274,9 +274,17 @@ static int cnic_send_nlmsg(struct cnic_local *cp, u32 type,
 	u16 len = 0;
 	u32 msg_type = ISCSI_KEVENT_IF_DOWN;
 	struct cnic_ulp_ops *ulp_ops;
+	int count = 0;
 
-	if (cp->uio_dev == -1)
+	while (count < 40 && cp->uio_dev == -1) {
+		msleep(50);
+		count++;
+	}
+
+	if (cp->uio_dev == -1) {
+		netdev_warn(cp->dev->netdev, "no uio dev to send nl request\n");
 		return -ENODEV;
+	}
 
 	if (csk) {
 		len = sizeof(path_req);
-- 
1.6.1.2


