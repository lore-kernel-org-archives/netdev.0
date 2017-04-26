From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH net-next] net: vrf: Do not allow looback to be moved to a VRF
Date: Wed, 26 Apr 2017 07:58:22 -0700
Message-ID: <1493218702-10906-1-git-send-email-dsa@cumulusnetworks.com>
Cc: rshearma@brocade.com, David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f46.google.com ([74.125.83.46]:33637 "EHLO
        mail-pg0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1956183AbdDZO61 (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 26 Apr 2017 10:58:27 -0400
Received: by mail-pg0-f46.google.com with SMTP id 63so1363315pgh.0
        for <netdev@vger.kernel.org>; Wed, 26 Apr 2017 07:58:26 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Moving the loopback into a VRF breaks networking for the default VRF.
Since the VRF device is the loopback for VRF domains, there is no
reason to move the loopback. Given the repercussions, block attempts
to set lo into a VRF.

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 drivers/net/vrf.c | 6 ++++++
 1 file changed, 6 insertions(+)

diff --git a/drivers/net/vrf.c b/drivers/net/vrf.c
index aa5d30428bba..ceda5861da78 100644
--- a/drivers/net/vrf.c
+++ b/drivers/net/vrf.c
@@ -877,6 +877,12 @@ static int do_vrf_add_slave(struct net_device *dev, struct net_device *port_dev)
 {
 	int ret;
 
+	/* do not allow loopback device to be enslaved to a VRF.
+	 * The vrf device acts as the loopback for the vrf.
+	 */
+	if (port_dev == dev_net(dev)->loopback_dev)
+		return -EOPNOTSUPP;
+
 	port_dev->priv_flags |= IFF_L3MDEV_SLAVE;
 	ret = netdev_master_upper_dev_link(port_dev, dev, NULL, NULL);
 	if (ret < 0)
-- 
2.1.4
