From: Mike Manning <mmanning@brocade.com>
Subject: [PATCH] net: ipv6: fix regression of no RTM_DELADDR sent after DAD failure
Date: Mon,  4 Sep 2017 15:52:55 +0100
Message-ID: <1504536775-23533-1-git-send-email-mmanning@brocade.com>
Cc: Mahesh Bandewar <maheshb@google.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from [144.49.130.148] ([144.49.130.148]:59460 "EHLO
        mail.eng.vyatta.net" rhost-flags-FAIL-FAIL-OK-FAIL) by vger.kernel.org
        with ESMTP id S1753838AbdIDO7D (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 4 Sep 2017 10:59:03 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Commit f784ad3d79e5 ("ipv6: do not send RTM_DELADDR for tentative
addresses") incorrectly assumes that no RTM_NEWADDR are sent for
addresses in tentative state, as this does happen for the standard
IPv6 use-case of DAD failure, see the call to ipv6_ifa_notify() in
addconf_dad_stop(). So as a result of this change, no RTM_DELADDR is
sent after DAD failure for a link-local when strict DAD (accept_dad=2)
is configured, or on the next admin down in other cases. The absence
of this notification breaks backwards compatibility and causes problems
after DAD failure if this notification was being relied on. The
solution is to allow RTM_DELADDR to still be sent after DAD failure.

Fixes: f784ad3d79e5("ipv6: do not send RTM_DELADDR for tentative addresses")
Signed-off-by: Mike Manning <mmanning@brocade.com>
Cc: Mahesh Bandewar <maheshb@google.com>
---
 net/ipv6/addrconf.c | 5 +++--
 1 file changed, 3 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 936e9ab..ba757c2 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -4982,9 +4982,10 @@ static void inet6_ifa_notify(int event, struct inet6_ifaddr *ifa)
 
 	/* Don't send DELADDR notification for TENTATIVE address,
 	 * since NEWADDR notification is sent only after removing
-	 * TENTATIVE flag.
+	 * TENTATIVE flag, if DAD has not failed.
 	 */
-	if (ifa->flags & IFA_F_TENTATIVE && event == RTM_DELADDR)
+	if (ifa->flags & IFA_F_TENTATIVE && !(ifa->flags & IFA_F_DADFAILED) &&
+	    event == RTM_DELADDR)
 		return;
 
 	skb = nlmsg_new(inet6_ifaddr_msgsize(), GFP_ATOMIC);
-- 
2.1.4
