From: Mike Pecovnik <mike.pecovnik@gmail.com>
Subject: [PATCH net] net: Fix permission check in netlink_connect()
Date: Mon, 24 Feb 2014 21:11:16 +0100
Message-ID: <1393272676-3188-1-git-send-email-mike.pecovnik@gmail.com>
Cc: Mike Pecovnik <mike.pecovnik@gmail.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ea0-f194.google.com ([209.85.215.194]:58726 "EHLO
	mail-ea0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751480AbaBXUO0 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 24 Feb 2014 15:14:26 -0500
Received: by mail-ea0-f194.google.com with SMTP id o10so1929928eaj.9
        for <netdev@vger.kernel.org>; Mon, 24 Feb 2014 12:14:25 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

netlink_sendmsg() was changed to prevent non-root processes from sending
messages with dst_pid != 0.
netlink_connect() however still only checks if nladdr->nl_groups is set.
This patch modifies netlink_connect() to check for the same condition.

Signed-off-by: Mike Pecovnik <mike.pecovnik@gmail.com>
---
 net/netlink/af_netlink.c | 4 ++--
 1 file changed, 2 insertions(+), 2 deletions(-)

diff --git a/net/netlink/af_netlink.c b/net/netlink/af_netlink.c
index fdf5135..04748ab6 100644
--- a/net/netlink/af_netlink.c
+++ b/net/netlink/af_netlink.c
@@ -1489,8 +1489,8 @@ static int netlink_connect(struct socket *sock, struct sockaddr *addr,
 	if (addr->sa_family != AF_NETLINK)
 		return -EINVAL;
 
-	/* Only superuser is allowed to send multicasts */
-	if (nladdr->nl_groups && !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
+	if ((nladdr->nl_groups || nladdr->nl_pid) &&
+	    !netlink_capable(sock, NL_CFG_F_NONROOT_SEND))
 		return -EPERM;
 
 	if (!nlk->portid)
-- 
1.8.3.2
