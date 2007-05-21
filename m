From: Patrick McHardy <kaber@trash.net>
Subject: [RTNETLINK]: Allow changing of subsets of netdevice flags in rtnl_setlink
Date: Mon, 21 May 2007 23:36:58 +0200
Message-ID: <465210FA.2020001@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------060900030400000408080508"
Cc: Kernel Netdev Mailing List <netdev@vger.kernel.org>,
	Thomas Graf <tgraf@suug.ch>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:64556 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1756769AbXEUVhE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 21 May 2007 17:37:04 -0400
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This is a multi-part message in MIME format.
--------------060900030400000408080508
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit



--------------060900030400000408080508
Content-Type: text/plain;
 name="x"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="x"

[RTNETLINK]: Allow changing of subsets of netdevice flags in rtnl_setlink

rtnl_setlink doesn't allow to change subsets of the flags, just to override
the set entirely by a new one. This means that for simply setting a device
up or down userspace first needs to query the current flags, change it and
send the changed flags back, which is racy and needlessly complicated.

Mask the flags using ifi_change since this is what it is intended for.
For backwards compatibility treat ifi_change == 0 as ~0 (even though it
seems quite unlikely that anyone has been using this so far).

Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit c80dabd4a038beb68da24327216f594119a8e05a
tree 2def6c042eb3276ef733af38fe2f27f746b89612
parent 192ecca1d62ada577a664410ed90b9a83315a65a
author Patrick McHardy <kaber@trash.net> Thu, 17 May 2007 05:31:30 +0200
committer Patrick McHardy <kaber@trash.net> Thu, 17 May 2007 22:06:27 +0200

 net/core/rtnetlink.c |   11 +++++++++--
 1 files changed, 9 insertions(+), 2 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index e2996bb..10fe3d3 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -685,8 +685,15 @@ static int rtnl_setlink(struct sk_buff *skb, struct nlmsghdr *nlh, void *arg)
 	}
 
 
-	if (ifm->ifi_flags)
-		dev_change_flags(dev, ifm->ifi_flags);
+	if (ifm->ifi_flags || ifm->ifi_change) {
+		unsigned int flags = ifm->ifi_flags;
+
+		/* bugwards compatibility: ifi_change == 0 is treated as ~0 */
+		if (ifm->ifi_change)
+			flags = (flags & ifm->ifi_change) |
+				(dev->flags & ~ifm->ifi_change);
+		dev_change_flags(dev, flags);
+	}
 
 	if (tb[IFLA_TXQLEN])
 		dev->tx_queue_len = nla_get_u32(tb[IFLA_TXQLEN]);

--------------060900030400000408080508--
