From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH] mac80211: Fix memory leak in ieee80211_if_write()
Date: Wed, 10 Mar 2010 17:13:36 +0100
Message-ID: <1268237616.2880.34.camel@edumazet-laptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, linux-wireless@vger.kernel.org
To: David Miller <davem@davemloft.net>,
	Johannes Berg <johannes@sipsolutions.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:46732 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756838Ab0CJQNo (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 10 Mar 2010 11:13:44 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Fix memory leak and use kmalloc() instead of kzalloc() as we are going
to overwrite the allocated buffer.

Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 net/mac80211/debugfs_netdev.c |   10 +++++++---
 1 files changed, 7 insertions(+), 3 deletions(-)

diff --git a/net/mac80211/debugfs_netdev.c b/net/mac80211/debugfs_netdev.c
index 9affe2c..a55e864 100644
--- a/net/mac80211/debugfs_netdev.c
+++ b/net/mac80211/debugfs_netdev.c
@@ -48,20 +48,24 @@ static ssize_t ieee80211_if_write(
 	ssize_t (*write)(struct ieee80211_sub_if_data *, const char *, int))
 {
 	u8 *buf;
-	ssize_t ret = -ENODEV;
+	ssize_t ret;
 
-	buf = kzalloc(count, GFP_KERNEL);
+	buf = kmalloc(count, GFP_KERNEL);
 	if (!buf)
 		return -ENOMEM;
 
+	ret = -EFAULT;
 	if (copy_from_user(buf, userbuf, count))
-		return -EFAULT;
+		goto freebuf;
 
+	ret = -ENODEV;
 	rtnl_lock();
 	if (sdata->dev->reg_state == NETREG_REGISTERED)
 		ret = (*write)(sdata, buf, count);
 	rtnl_unlock();
 
+freebuf:
+	kfree(buf);	
 	return ret;
 }
 


