From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] mac80211_hwsim: clean up the skb before passing it back
Date: Thu, 18 Jun 2009 14:51:12 +0200
Message-ID: <1245329472.13790.33.camel@johannes.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: linux-wireless <linux-wireless@vger.kernel.org>,
	Netdev <netdev@vger.kernel.org>,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>,
	Pavel Emelyanov <xemul@openvz.org>
To: John Linville <linville@tuxdriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:49661 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1761794AbZFRMvp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 18 Jun 2009 08:51:45 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We need to clean up the skb before we can copy it, this
is required for proper operation since the socket it is
still attached to could potentially live in a different
network namespace or so.

Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
I stole this code from veth, maybe there should be a function somewhere?

 drivers/net/wireless/mac80211_hwsim.c |   10 ++++++++++
 1 file changed, 10 insertions(+)

--- wireless-testing.orig/drivers/net/wireless/mac80211_hwsim.c	2009-06-18 14:42:01.000000000 +0200
+++ wireless-testing/drivers/net/wireless/mac80211_hwsim.c	2009-06-18 14:44:27.000000000 +0200
@@ -15,6 +15,8 @@
 
 #include <linux/list.h>
 #include <linux/spinlock.h>
+#include <net/dst.h>
+#include <net/xfrm.h>
 #include <net/mac80211.h>
 #include <net/ieee80211_radiotap.h>
 #include <linux/if_arp.h>
@@ -409,6 +411,14 @@ static bool mac80211_hwsim_tx_frame(stru
 	if (data->ps != PS_DISABLED)
 		hdr->frame_control |= cpu_to_le16(IEEE80211_FCTL_PM);
 
+	/* release the skb's source info */
+	skb_orphan(skb);
+	dst_release(skb->dst);
+	skb->dst = NULL;
+	skb->mark = 0;
+	secpath_reset(skb);
+	nf_reset(skb);
+
 	/* Copy skb to all enabled radios that are on the current frequency */
 	spin_lock(&hwsim_radio_lock);
 	list_for_each_entry(data2, &hwsim_radios, list) {


