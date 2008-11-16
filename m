From: Johannes Berg <johannes@sipsolutions.net>
Subject: rtnetlink: propagate error from dev_change_flags in do_setlink()
Date: Sun, 16 Nov 2008 14:10:29 +0100
Message-ID: <1226841029.3644.2.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: netdev <netdev@vger.kernel.org>, Patrick McHardy <kaber@trash.net>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from xc.sipsolutions.net ([83.246.72.84]:59976 "EHLO
	sipsolutions.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751476AbYKPNKh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 16 Nov 2008 08:10:37 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Unlike ifconfig, iproute doesn't report an error when setting
an interface up fails:

(example: put wireless network mac80211 interface into repeater mode
with iwconfig but do not set a peer MAC address, it should fail with
-ENOLINK)

without patch:
# ip link set wlan0 up ; echo $?
0
# 

with patch:
# ip link set wlan0 up ; echo $?
RTNETLINK answers: Link has been severed
2
# 

Propagate the return value from dev_change_flags() to fix this.

Signed-off-by: Patrick McHardy <kaber@trash.net>
Tested-by: Johannes Berg <johannes@sipsolutions.net>
Signed-off-by: Johannes Berg <johannes@sipsolutions.net>
---
 net/core/rtnetlink.c |    4 +++-
 1 file changed, 3 insertions(+), 1 deletion(-)

--- everything.orig/net/core/rtnetlink.c	2008-10-26 20:00:12.000000000 +0100
+++ everything/net/core/rtnetlink.c	2008-11-11 23:24:14.000000000 +0100
@@ -878,7 +878,9 @@ static int do_setlink(struct net_device 
 		if (ifm->ifi_change)
 			flags = (flags & ifm->ifi_change) |
 				(dev->flags & ~ifm->ifi_change);
-		dev_change_flags(dev, flags);
+		err = dev_change_flags(dev, flags);
+		if (err < 0)
+			goto errout;
 	}
 
 	if (tb[IFLA_TXQLEN])


