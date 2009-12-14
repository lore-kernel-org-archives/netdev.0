From: ebiederm@xmission.com (Eric W. Biederman)
Subject: [PATCH v2.6.32] net: Fix userspace RTM_NEWLINK notifications.
Date: Sun, 13 Dec 2009 22:39:28 -0800
Message-ID: <m1d42igiu7.fsf_-_@fess.ebiederm.org>
References: <m1fx7fmgyk.fsf@fess.ebiederm.org>
	<1260756336.4041.3.camel@localhost.localdomain>
	<20091213.194605.59666989.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: marcel@holtmann.org, netdev@vger.kernel.org, stable@kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from out02.mta.xmission.com ([166.70.13.232]:52135 "EHLO
	out02.mta.xmission.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751354AbZLNGjh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 14 Dec 2009 01:39:37 -0500
In-Reply-To: <20091213.194605.59666989.davem@davemloft.net> (David Miller's message of "Sun\, 13 Dec 2009 19\:46\:05 -0800 \(PST\)")
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


I received some bug reports about userspace programs having problems
because after RTM_NEWLINK was received they could not immeidate
access files under /proc/sys/net/ because they had not been
registered yet.

The problem was trivailly fixed by moving the userspace
notification from rtnetlink_event to the end of register_netdevice.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
---

This patch is against 2.6.32 and should work back to 2.6.29 and
probably earlier.

 net/core/dev.c       |   11 +++++++++++
 net/core/rtnetlink.c |    4 +---
 2 files changed, 12 insertions(+), 3 deletions(-)

diff --git a/net/core/dev.c b/net/core/dev.c
index fe10551..584046e 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4860,6 +4860,11 @@ int register_netdevice(struct net_device *dev)
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
@@ -5398,6 +5403,12 @@ int dev_change_net_namespace(struct net_device *dev, struct net *net, const char
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
index eb42873..d4fd895 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1334,13 +1334,11 @@ static int rtnetlink_event(struct notifier_block *this, unsigned long event, voi
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
+	case NETDEV_REGISTER:
 	case NETDEV_CHANGE:
 	case NETDEV_GOING_DOWN:
 		break;
-- 
1.6.5.2.143.g8cc62

