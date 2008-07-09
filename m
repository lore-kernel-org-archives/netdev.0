From: Max Krasnyansky <maxk@qualcomm.com>
Subject: [PATCH] tun: Persistent devices can get stuck in xoff state
Date: Tue,  8 Jul 2008 23:24:08 -0700
Message-ID: <1215584648-13444-1-git-send-email-maxk@qualcomm.com>
Cc: netdev@vger.kernel.org, Max Krasnyansky <maxk@qualcomm.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:58346 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751526AbYGIGYL (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 9 Jul 2008 02:24:11 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The scenario goes like this. App stops reading from tun/tap.
TX queue gets full and driver does netif_stop_queue().
App closes fd and TX queue gets flushed as part of the cleanup.
Next time the app opens tun/tap and starts reading from it but
the xoff state is not cleared. We're stuck.
Normally xoff state is cleared when netdev is brought up. But
in the case of persistent devices this happens only during
initial setup.

The fix is trivial. If device is already up when an app opens
it we clear xoff state and that gets things moving again.

Signed-off-by: Max Krasnyansky <maxk@qualcomm.com>
---
 drivers/net/tun.c |    5 +++++
 1 files changed, 5 insertions(+), 0 deletions(-)

diff --git a/drivers/net/tun.c b/drivers/net/tun.c
index 5b5d875..e665f72 100644
--- a/drivers/net/tun.c
+++ b/drivers/net/tun.c
@@ -576,6 +576,11 @@ static int tun_set_iff(struct file *file, struct ifreq *ifr)
 	file->private_data = tun;
 	tun->attached = 1;
 
+	/* Make sure persistent devices do not get stuck in
+	 * xoff state */
+	if (netif_running(tun->dev))
+		netif_wake_queue(tun->dev);
+
 	strcpy(ifr->ifr_name, tun->dev->name);
 	return 0;
 
-- 
1.5.5.1

