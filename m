From: Vladislav Yasevich <vyasevich@gmail.com>
Subject: [PATCH v2 net-next 1/2] rtnetlink: Convert rtnetlink_event to white list
Date: Tue,  4 Apr 2017 09:23:41 -0400
Message-ID: <1491312223-18772-2-git-send-email-vyasevic@redhat.com>
References: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Cc: roopa@cumulusnetworks.com, dsa@cumulusnetworks.com,
        davem@davemloft.net, Vladislav Yasevich <vyasevic@redhat.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f194.google.com ([209.85.216.194]:33368 "EHLO
        mail-qt0-f194.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752461AbdDDNYR (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 4 Apr 2017 09:24:17 -0400
Received: by mail-qt0-f194.google.com with SMTP id r45so23209479qte.0
        for <netdev@vger.kernel.org>; Tue, 04 Apr 2017 06:24:17 -0700 (PDT)
In-Reply-To: <1491312223-18772-1-git-send-email-vyasevic@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The rtnetlink_event currently functions as a blacklist where
we block cerntain netdev events from being sent to user space.
As a result, events have been added to the system that userspace
probably doesn't care about.

This patch converts the implementation to the white list so that
newly events would have to be specifically added to the list to
be sent to userspace.  This would force new event implementers to
consider whether a given event is usefull to user space or if it's
just a kernel event.

Signed-off-by: Vladislav Yasevich <vyasevic@redhat.com>
---
V2: Added missed events (from David Ahern)

 net/core/rtnetlink.c | 31 +++++++++++++++++--------------
 1 file changed, 17 insertions(+), 14 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 9c3947a..58419da 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -4116,22 +4116,25 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	struct net_device *dev = netdev_notifier_info_to_dev(ptr);
 
 	switch (event) {
-	case NETDEV_UP:
-	case NETDEV_DOWN:
-	case NETDEV_PRE_UP:
-	case NETDEV_POST_INIT:
-	case NETDEV_REGISTER:
-	case NETDEV_CHANGE:
-	case NETDEV_PRE_TYPE_CHANGE:
-	case NETDEV_GOING_DOWN:
-	case NETDEV_UNREGISTER:
-	case NETDEV_UNREGISTER_FINAL:
-	case NETDEV_RELEASE:
-	case NETDEV_JOIN:
-	case NETDEV_BONDING_INFO:
+	case NETDEV_REBOOT:
+	case NETDEV_CHANGEMTU:
+	case NETDEV_CHANGEADDR:
+	case NETDEV_CHANGENAME:
+	case NETDEV_FEAT_CHANGE:
+	case NETDEV_BONDING_FAILOVER:
+	case NETDEV_POST_TYPE_CHANGE:
+	case NETDEV_NOTIFY_PEERS:
+	case NETDEV_CHANGEUPPER:
+	case NETDEV_RESEND_IGMP:
+	case NETDEV_PRECHANGEMTU:
+	case NETDEV_CHANGEINFODATA:
+	case NETDEV_PRECHANGEUPPER:
+	case NETDEV_CHANGELOWERSTATE:
+	case NETDEV_UDP_TUNNEL_PUSH_INFO:
+	case NETDEV_CHANGE_TX_QUEUE_LEN:
+		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	default:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, 0, GFP_KERNEL);
 		break;
 	}
 	return NOTIFY_DONE;
-- 
2.7.4
