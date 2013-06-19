From: Johannes Berg <johannes@sipsolutions.net>
Subject: [PATCH] nl80211: fix attrbuf access race by allocating a separate
 one
Date: Wed, 19 Jun 2013 10:23:58 +0200
Message-ID: <1371630238.8349.6.camel@jlt4.sipsolutions.net>
References: <CA+55aFxOde8n0M2=77-TQ2Ea9iz8s-e8zGFwjj6RVyMFXBgxEA@mail.gmail.com>
	 <20130618.190632.33329016434510583.davem@davemloft.net>
	 <CA+55aFz=eG5-zh1toHxrx=4Qm4DvwyiBCU3u-6tc0-utfZ6xiA@mail.gmail.com>
	 (sfid-20130619_042459_700600_08CD35A3) <1371628488.8349.3.camel@jlt4.sipsolutions.net>
	 (sfid-20130619_095509_334897_6BA231FA)
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	John Linville <linville@tuxdriver.com>,
	Linux Wireless List <linux-wireless@vger.kernel.org>,
	Network Development <netdev@vger.kernel.org>
To: Linus Torvalds <torvalds@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s3.sipsolutions.net ([144.76.43.152]:42325 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756684Ab3FSIYF (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 19 Jun 2013 04:24:05 -0400
In-Reply-To: <1371628488.8349.3.camel@jlt4.sipsolutions.net> (sfid-20130619_095509_334897_6BA231FA)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes.berg@intel.com>

Since my commit 3713b4e364, nl80211_dump_wiphy() uses the global
nl80211_fam.attrbuf for parsing the incoming data. This wouldn't
be a problem if it only did so on the first dump iteration which
is locked against other commands in generic netlink, but due to
space constraints in cb->args (the needed state doesn't fit) I
decided to always parse the original message. That's racy though
since nl80211_fam.attrbuf could be used by some other parsing in
generic netlink concurrently.

For now, fix this by allocating a separate parse buffer (it's a
bit too big for the stack, currently 1448 bytes on 64-bit). For
-next, I'll change the code to parse into the global buffer in
the first round only and then allocate a smaller buffer to keep
the state in cb->args.

Reported-by: Linus Torvalds <torvalds@linux-foundation.org>
Signed-off-by: Johannes Berg <johannes.berg@intel.com>
---
Let me know if you want to apply this directly, otherwise I'll send it
on its way to John.

 net/wireless/nl80211.c | 11 +++++++++--
 1 file changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/wireless/nl80211.c b/net/wireless/nl80211.c
index d5aed3b..b14b7e3 100644
--- a/net/wireless/nl80211.c
+++ b/net/wireless/nl80211.c
@@ -1564,12 +1564,17 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
 	struct cfg80211_registered_device *dev;
 	s64 filter_wiphy = -1;
 	bool split = false;
-	struct nlattr **tb = nl80211_fam.attrbuf;
+	struct nlattr **tb;
 	int res;
 
+	/* will be zeroed in nlmsg_parse() */
+	tb = kmalloc(sizeof(*tb) * (NL80211_ATTR_MAX + 1), GFP_KERNEL);
+	if (!tb)
+		return -ENOMEM;
+
 	mutex_lock(&cfg80211_mutex);
 	res = nlmsg_parse(cb->nlh, GENL_HDRLEN + nl80211_fam.hdrsize,
-			  tb, nl80211_fam.maxattr, nl80211_policy);
+			  tb, NL80211_ATTR_MAX, nl80211_policy);
 	if (res == 0) {
 		split = tb[NL80211_ATTR_SPLIT_WIPHY_DUMP];
 		if (tb[NL80211_ATTR_WIPHY])
@@ -1583,6 +1588,7 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
 			netdev = dev_get_by_index(sock_net(skb->sk), ifidx);
 			if (!netdev) {
 				mutex_unlock(&cfg80211_mutex);
+				kfree(tb);
 				return -ENODEV;
 			}
 			if (netdev->ieee80211_ptr) {
@@ -1593,6 +1599,7 @@ static int nl80211_dump_wiphy(struct sk_buff *skb, struct netlink_callback *cb)
 			dev_put(netdev);
 		}
 	}
+	kfree(tb);
 
 	list_for_each_entry(dev, &cfg80211_rdev_list, list) {
 		if (!net_eq(wiphy_net(&dev->wiphy), sock_net(skb->sk)))
-- 
1.8.0
