From: Greg KH <gregkh@suse.de>
Subject: [86/90] net: Fix userspace RTM_NEWLINK notifications.
Date: Wed, 16 Dec 2009 17:15:37 -0800
Message-ID: <20091217011609.228623383@mini.kroah.org>
References: <20091217011835.GA20434@kroah.com>
Cc: stable-review@kernel.org, torvalds@linux-foundation.org,
	akpm@linux-foundation.org, alan@lxorguk.ukuu.org.uk,
	netdev@vger.kernel.org, marcel@holtmann.org,
	"Eric W. Biederman" <ebiederm@aristanetworks.com>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	David Miller <davem@davemloft.net>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1763805AbZLQBZz@vger.kernel.org>
In-Reply-To: <20091217011835.GA20434@kroah.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

2.6.31-stable review patch.  If anyone has any objections, please let us know.

------------------

commit d90a909e1f3e006a1d57fe11fd417173b6494701 upstream.

I received some bug reports about userspace programs having problems
because after RTM_NEWLINK was received they could not immeidate
access files under /proc/sys/net/ because they had not been
registered yet.

The problem was trivailly fixed by moving the userspace
notification from rtnetlink_event to the end of register_netdevice.

Signed-off-by: Eric W. Biederman <ebiederm@aristanetworks.com>
Cc: David Miller <davem@davemloft.net>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 net/core/dev.c       |   11 +++++++++++
 net/core/rtnetlink.c |    4 +---
 2 files changed, 12 insertions(+), 3 deletions(-)

--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -4808,6 +4808,11 @@ int register_netdevice(struct net_device
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
@@ -5343,6 +5348,12 @@ int dev_change_net_namespace(struct net_
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
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1347,13 +1347,11 @@ static int rtnetlink_event(struct notifi
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
