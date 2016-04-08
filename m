From: David Ahern <dsa@cumulusnetworks.com>
Subject: [PATCH] net: ipv6: Do not keep linklocal and loopback addresses
Date: Fri,  8 Apr 2016 12:01:21 -0700
Message-ID: <1460142081-16675-1-git-send-email-dsa@cumulusnetworks.com>
Cc: David Ahern <dsa@cumulusnetworks.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f181.google.com ([209.85.192.181]:34062 "EHLO
	mail-pf0-f181.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752365AbcDHTB3 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 8 Apr 2016 15:01:29 -0400
Received: by mail-pf0-f181.google.com with SMTP id c20so80875028pfc.1
        for <netdev@vger.kernel.org>; Fri, 08 Apr 2016 12:01:28 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

f1705ec197e7 added the option to retain user configured addresses on an
admin down. A comment to one of the later revisions suggested using the
IFA_F_PERMANENT flag rather than adding a user_managed boolean to the
ifaddr struct. A side effect of this change is that link local and
loopback addresses are also retained which is not part of the objective
of f1705ec197e7. Add check to drop those addresses.

Fixes: f1705ec197e7 ("net: ipv6: Make address flushing on ifdown optional")

Signed-off-by: David Ahern <dsa@cumulusnetworks.com>
---
 net/ipv6/addrconf.c | 12 ++++++++++--
 1 file changed, 10 insertions(+), 2 deletions(-)

diff --git a/net/ipv6/addrconf.c b/net/ipv6/addrconf.c
index 27aed1afcf81..2dd8c1ca3287 100644
--- a/net/ipv6/addrconf.c
+++ b/net/ipv6/addrconf.c
@@ -3438,6 +3438,12 @@ static void addrconf_type_change(struct net_device *dev, unsigned long event)
 		ipv6_mc_unmap(idev);
 }
 
+static bool addr_is_local(const struct in6_addr *addr)
+{
+	return ipv6_addr_type(addr) &
+		(IPV6_ADDR_LINKLOCAL | IPV6_ADDR_LOOPBACK);
+}
+
 static int addrconf_ifdown(struct net_device *dev, int how)
 {
 	struct net *net = dev_net(dev);
@@ -3495,7 +3501,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 				 * address is retained on a down event
 				 */
 				if (!keep_addr ||
-				    !(ifa->flags & IFA_F_PERMANENT)) {
+				    !(ifa->flags & IFA_F_PERMANENT) ||
+				    addr_is_local(&ifa->addr)) {
 					hlist_del_init_rcu(&ifa->addr_lst);
 					goto restart;
 				}
@@ -3544,7 +3551,8 @@ static int addrconf_ifdown(struct net_device *dev, int how)
 		write_unlock_bh(&idev->lock);
 		spin_lock_bh(&ifa->lock);
 
-		if (keep_addr && (ifa->flags & IFA_F_PERMANENT)) {
+		if (keep_addr && (ifa->flags & IFA_F_PERMANENT) &&
+		    !addr_is_local(&ifa->addr)) {
 			/* set state to skip the notifier below */
 			state = INET6_IFADDR_STATE_DEAD;
 			ifa->state = 0;
-- 
2.1.4
