From: Xin Long <lucien.xin@gmail.com>
Subject: [PATCH net] dev_ioctl: add missing NETDEV_CHANGE_TX_QUEUE_LEN event notification
Date: Mon, 16 Oct 2017 19:43:15 +0800
Message-ID: <c7cb587e601d7e27d126d79b6f06c873af1659bc.1508154195.git.lucien.xin@gmail.com>
Cc: davem@davemloft.net
To: network dev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f194.google.com ([209.85.192.194]:47125 "EHLO
        mail-pf0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752043AbdJPLnY (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 16 Oct 2017 07:43:24 -0400
Received: by mail-pf0-f194.google.com with SMTP id z11so15629021pfk.4
        for <netdev@vger.kernel.org>; Mon, 16 Oct 2017 04:43:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

When changing dev tx_queue_len via netlink or net-sysfs,
a NETDEV_CHANGE_TX_QUEUE_LEN event notification will be
called.

But dev_ioctl missed this event notification, which could
cause no userspace notification would be sent.

Signed-off-by: Xin Long <lucien.xin@gmail.com>
---
 net/core/dev_ioctl.c | 13 ++++++++++++-
 1 file changed, 12 insertions(+), 1 deletion(-)

diff --git a/net/core/dev_ioctl.c b/net/core/dev_ioctl.c
index 709a4e6..f9c7a88 100644
--- a/net/core/dev_ioctl.c
+++ b/net/core/dev_ioctl.c
@@ -303,7 +303,18 @@ static int dev_ifsioc(struct net *net, struct ifreq *ifr, unsigned int cmd)
 	case SIOCSIFTXQLEN:
 		if (ifr->ifr_qlen < 0)
 			return -EINVAL;
-		dev->tx_queue_len = ifr->ifr_qlen;
+		if (dev->tx_queue_len ^ ifr->ifr_qlen) {
+			unsigned int orig_len = dev->tx_queue_len;
+
+			dev->tx_queue_len = ifr->ifr_qlen;
+			err = call_netdevice_notifiers(
+					NETDEV_CHANGE_TX_QUEUE_LEN, dev);
+			err = notifier_to_errno(err);
+			if (err) {
+				dev->tx_queue_len = orig_len;
+				return err;
+			}
+		}
 		return 0;
 
 	case SIOCSIFNAME:
-- 
2.1.0
