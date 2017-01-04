From: Mahesh Bandewar <mahesh@bandewar.net>
Subject: [RFC PATCH next] ipv6: do not send RTM_DELADDR for tentative addresses
Date: Wed,  4 Jan 2017 15:01:01 -0800
Message-ID: <20170104230101.17470-1-mahesh@bandewar.net>
Cc: netdev <netdev@vger.kernel.org>,
        Mahesh Bandewar <mahesh@bandewar.net>,
        Mahesh Bandewar <maheshb@google.com>,
        Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
        Patrick McHardy <kaber@trash.net>,
        Hannes Frederic Sowa <hannes@stressinduktion.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f68.google.com ([74.125.83.68]:33856 "EHLO
        mail-pg0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751998AbdADXIZ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 4 Jan 2017 18:08:25 -0500
Received: by mail-pg0-f68.google.com with SMTP id b1so38545466pgc.1
        for <netdev@vger.kernel.org>; Wed, 04 Jan 2017 15:08:24 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Mahesh Bandewar <maheshb@google.com>

RTM_NEWADDR notification is sent when IFA_F_TENTATIVE is cleared from
the address. So if the address is added and deleted before DAD probes
completes, the RTM_DELADDR will be sent for which there was no
RTM_NEWADDR causing asymmetry in notification. However if the same
logic is used while sending RTM_DELADDR notification, this asymmetry
can be avoided.

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
CC: Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>
CC: Patrick McHardy <kaber@trash.net>
CC: Hannes Frederic Sowa <hannes@stressinduktion.org>
---
 net/ipv6/addrconf.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index c1e124bc8e1e..ac9bd5620f81 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4888,6 +4888,13 @@ static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 	struct net *net = dev_net(ifa->idev->dev);
 	int err = -ENOBUFS;
 
+	/* Don't send DELADDR notification for TENTATIVE address,
+	 * since NEWADDR notification is sent only after removing
+	 * TENTATIVE flag.
+	 */
+	if (ifa->flags & IFA_F_TENTATIVE && event == RTM_DELADDR)
+		return;
+
 	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_ATOMIC);
 	if (!skb)
 		goto errout;
-- 
2.11.0.390.gc69c2f50cf-goog
