From: Pavel Roskin <proski@gnu.org>
Subject: [PATCH] d80211: configure hardware when the interface is brought up
Date: Thu, 25 Jan 2007 19:37:12 -0500
Message-ID: <1169771832.19253.14.camel@dv>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from fencepost.gnu.org ([199.232.76.164]:34014 "EHLO
	fencepost.gnu.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1030687AbXAZAhO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 25 Jan 2007 19:37:14 -0500
Received: from proski by fencepost.gnu.org with local (Exim 4.60)
	(envelope-from <proski@gnu.org>)
	id 1HAF4n-00058w-7R
	for netdev@vger.kernel.org; Thu, 25 Jan 2007 19:36:21 -0500
Received: from proski by gnu.org with local (Exim 4.63)
	(envelope-from <proski@gnu.org>)
	id 1HAF5c-0006wL-94
	for netdev@vger.kernel.org; Thu, 25 Jan 2007 19:37:12 -0500
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

ieee80211_hw_config() is called from scanning functions and ioctl
handlers, but not when the interface is brought up.  This is
unreasonable.  Since the config function is provided by hardware drivers
to d80211, the later should be responsible for calling it in all
situations when the hardware needs to be reconfigured.

Without this patch, bcm43xx_d80211 needs the channel to be set again
after the interface goes down and up.  Similar problems are reported for
rt2x00 drivers.

Failure in ieee80211_hw_config() leads to the interface staying down.

Signed-off-by: Pavel Roskin <proski@gnu.org>
---

 net/d80211/ieee80211.c |    2 ++
 1 files changed, 2 insertions(+), 0 deletions(-)

diff --git a/net/d80211/ieee80211.c b/net/d80211/ieee80211.c
index 2f1dce5..7219416 100644
--- a/net/d80211/ieee80211.c
+++ b/net/d80211/ieee80211.c
@@ -2239,6 +2239,8 @@ static int ieee80211_open(struct net_device *dev)
 		res = 0;
 		if (local->ops->open)
 			res = local->ops->open(local_to_hw(local));
+		if (res == 0)
+			res = ieee80211_hw_config(local);
 		if (res == 0) {
 			res = dev_open(local->mdev);
 			if (res) {


-- 
Regards,
Pavel Roskin


