From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH] net: Fix userspace RTM_NEWLINK notifications.
Date: Sun, 13 Dec 2009 00:11:15 -0800
Message-ID: <m1fx7fmgyk.fsf@fess.ebiederm.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: <netdev@vger.kernel.org>, <stable@kernel.org>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out01.mta.xmission.com ([166.70.13.231]:51225 "HELO
	out01.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with SMTP id S1751199AbZLMILW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sun, 13 Dec 2009 03:11:22 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I received some bug reports about userspace programs having problems
because after RTM_NEWLINK was received they could not immediate access
files under /proc/sys/net/ because they had not been registered yet.

The original problem was trivially fixed by moving the userspace
notification from rtnetlink_event() to the end of
register_netdevice().

When testing that change I discovered I was still getting RTM_NEWLINK
events before I could access proc and I was also getting RTM_NEWLINK
events after I was seeing RTM_DELLINK.  Things practically guaranteed
to confuse userspace.

After a little more investigation these extra notifications proved to
be from the new notifiers NETDEV_POST_INIT and NETDEV_UNREGISTER_BATCH
hitting the default case in rtnetlink_event, and triggering
unnecessary RTM_NEWLINK messages.

rtnetlink_event now explicitly handles NETDEV_UNREGISTER_BATCH and
NETDEV_POST_INIT to avoid sending the incorrect userspace
notifications.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---
 net/core/dev.c       |   11 +++++++++++
 net/core/rtnetlink.c |    6 +++---
 2 files changed, 14 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index c36a17a..369e83a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -5033,6 +5033,11 @@ int register_netdevice(struct net_device *dev)
 		rollback_registered(dev);
 		dev->reg_state = NETREG_UNREGISTERED;
 	}
+	/*
+	 *	Prevent userspace races by waiting until the network
+	 *	device is fully setup before sending notifications.
+	 */
+	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
 
 out:
 	return ret;
@@ -5595,6 +5600,12 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
 	/* Notify protocols, that a new device appeared. */
 	call_netdevice_notifiers(NETDEV_REGISTER, dev);
 
+	/*
+	 *	Prevent userspace races by waiting until the network
+	 *	device is fully setup before sending notifications.
+	 */
+	rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
+
 	synchronize_net();
 	err = 0;
 out:
diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index 33148a5..794bcb8 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1364,15 +1364,15 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
 	case NETDEV_UNREGISTER:
 		rtmsg_ifinfo(RTM_DELLINK, dev, ~0U);
 		break;
-	case NETDEV_REGISTER:
-		rtmsg_ifinfo(RTM_NEWLINK, dev, ~0U);
-		break;
 	case NETDEV_UP:
 	case NETDEV_DOWN:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, IFF_UP|IFF_RUNNING);
 		break;
+	case NETDEV_POST_INIT:
+	case NETDEV_REGISTER:
 	case NETDEV_CHANGE:
 	case NETDEV_GOING_DOWN:
+	case NETDEV_UNREGISTER_BATCH:
 		break;
 	default:
 		rtmsg_ifinfo(RTM_NEWLINK, dev, 0);
-- 
1.6.5.2.143.g8cc62

