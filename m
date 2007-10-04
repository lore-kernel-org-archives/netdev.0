From: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
Subject: [PATCH] mac80211: Fix TX after monitor interface is converted to managed
Date: Thu,  4 Oct 2007 12:33:43 +0100 (BST)
Message-ID: <20071004113343.552139D502B@zog.reactivated.net>
Cc: johannes-cdvu00un1VgdHxzADdlk8Q@public.gmane.org
To: linville-2XuSBdqkA4R54TAoqtyWWQ@public.gmane.org
Return-path: <linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org>
Cc: netdev-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Cc: linux-wireless-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
Sender: linux-wireless-owner-u79uwXL29TY76Z2rM5mHXA@public.gmane.org
List-Id: netdev.vger.kernel.org

This sequence of events causes loss of connectivity:

<plug in>
<associate as normal in managed mode>
ifconfig eth7 down
iwconfig eth7 mode monitor
ifconfig eth7 up
ifconfig eth7 down
iwconfig eth7 mode managed
<associate as normal>

At this point you are associated but TX does not work. This is because
the eth7 hard_start_xmit is still ieee80211_monitor_start_xmit.

Fix this by unsetting the hard_start_xmit handler in ieee80211_if_reinit. It
will then be reinitialised to the default (ieee80211_subif_start_xmit) in
ieee80211_if_set_type.

Signed-off-by: Daniel Drake <dsd-aBrp7R+bbdUdnm+yROfE0A@public.gmane.org>
---
 net/mac80211/ieee80211_iface.c |    3 +++
 1 files changed, 3 insertions(+), 0 deletions(-)

diff --git a/net/mac80211/ieee80211_iface.c b/net/mac80211/ieee80211_iface.c
index 08c1e18..40d4b63 100644
--- a/net/mac80211/ieee80211_iface.c
+++ b/net/mac80211/ieee80211_iface.c
@@ -242,6 +242,9 @@ void ieee80211_if_reinit(struct net_device *dev)
 
 	ieee80211_if_sdata_deinit(sdata);
 
+	BUG_ON(netif_running(dev));
+	dev->hard_start_xmit = NULL;
+
 	switch (sdata->type) {
 	case IEEE80211_IF_TYPE_MGMT:
 		/* nothing to do */
-- 
1.5.3.3
