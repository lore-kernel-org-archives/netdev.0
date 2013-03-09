From: Mathias Krause <minipli@googlemail.com>
Subject: [PATCH 2/3] rtnl: fix info leak on RTM_GETLINK request for VF devices
Date: Sat,  9 Mar 2013 16:52:20 +0100
Message-ID: <1362844341-12591-3-git-send-email-minipli@googlemail.com>
References: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Cc: netdev@vger.kernel.org, Mathias Krause <minipli@googlemail.com>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bk0-f48.google.com ([209.85.214.48]:57882 "EHLO
	mail-bk0-f48.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1759056Ab3CIPwp (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 9 Mar 2013 10:52:45 -0500
Received: by mail-bk0-f48.google.com with SMTP id jf20so1116024bkc.7
        for <netdev@vger.kernel.org>; Sat, 09 Mar 2013 07:52:43 -0800 (PST)
In-Reply-To: <1362844341-12591-1-git-send-email-minipli@googlemail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Initialize the mac address buffer with 0 as the driver specific function
will probably not fill the whole buffer. In fact, all in-kernel drivers
fill only ETH_ALEN of the MAX_ADDR_LEN bytes, i.e. 6 of the 32 possible
bytes. Therefore we currently leak 26 bytes of stack memory to userland
via the netlink interface.

Signed-off-by: Mathias Krause <minipli@googlemail.com>
---
 net/core/rtnetlink.c |    1 +
 1 file changed, 1 insertion(+)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index b376410..a585d45 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -979,6 +979,7 @@ static int rtnl_fill_ifinfo(struct sk_buff *skb, struct net_device *dev,
 			 * report anything.
 			 */
 			ivi.spoofchk = -1;
+			memset(ivi.mac, 0, sizeof(ivi.mac));
 			if (dev->netdev_ops->ndo_get_vf_config(dev, i, &ivi))
 				break;
 			vf_mac.vf =
-- 
1.7.10.4
