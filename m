From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] fix cfg80211 WE compat code
Date: Sun, 10 Dec 2006 17:21:37 +0100
Message-ID: <1165767697.3131.29.camel@johannes.berg>
References: <1165654123.2816.29.camel@portland.localdomain>
	 <20061209160640.GA3365@tuxdriver.com>
	 <87hcw49rg8.fsf@briny.internal.ondioline.org>
	 <20061210031202.6rgqw4go8ck48kks@webmail.spamcop.net>
	 <1165756653.3131.1.camel@johannes.berg>
	 <20061210110802.kq50mvc4s00s0skw@webmail.spamcop.net>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Paul Collins <paul@briny.ondioline.org>,
	"John W. Linville" <linville@tuxdriver.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from crystal.sipsolutions.net ([195.210.38.204]:42348 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761865AbWLJQVt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 10 Dec 2006 11:21:49 -0500
To: Pavel Roskin <proski@gnu.org>
In-Reply-To: <20061210110802.kq50mvc4s00s0skw@webmail.spamcop.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When cfg80211's WE compat code is enabled and the cfg80211 module is
loaded (or built-in) WE calls on non-cfg80211 devices will return
-ENODEV because cfg80211 internally says -ENODEV for cfg80211 calls on
devices that don't have cfg80211 handlers.

This patch makes the cfg80211 core return -ENOSYS which is more
appropriate since the device exists but the configuration request can't
be fulfilled. This will then cause the fallback code to the original WE
to trigger.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
John, please apply this to wireless-dev if Pavel says it works (I think
it should).

On Sun, 2006-12-10 at 11:08 -0500, Pavel Roskin wrote:

> Not quite.  cfg80211_wext_ioctl() returns -ENODEV (no idea why), but the code
> only falls back to Wireless Extensions if the return code is -ENOSYS.  That
> should be quite easy to fix.

Ah, but you said -ENOSYS and I thought that somehow went to userspace
and was confused.

Yeah, the bug is actually hidden in cfg80211_wx_setup() and all that
calls.

This patch should fix it.

--- wireless-dev.orig/net/wireless/core.c	2006-12-10 17:15:43.442451537 +0100
+++ wireless-dev/net/wireless/core.c	2006-12-10 17:15:54.672451537 +0100
@@ -131,7 +131,7 @@ cfg80211_get_drv_from_ifindex(int ifinde
 	if (drv)
 		mutex_lock(&drv->mtx);
 	else
-		drv = ERR_PTR(-ENODEV);
+		drv = ERR_PTR(-ENOSYS);
 	dev_put(dev);
  out:
 	mutex_unlock(&cfg80211_drv_mutex);


