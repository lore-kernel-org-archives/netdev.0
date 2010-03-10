From: Jiri Pirko <jpirko@redhat.com>
Subject: [net-next-2.6 PATCH 3/3] net: forbid underlaying devices to change
 its type
Date: Wed, 10 Mar 2010 21:30:19 +0100
Message-ID: <20100310203019.GF2834@psychotron.redhat.com>
References: <20100310202804.GC2834@psychotron.redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: fubar@us.ibm.com, bonding-devel@lists.sourceforge.net,
	davem@davemloft.net, shemminger@linux-foundation.org,
	kaber@trash.net
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:42160 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757044Ab0CJUah (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 10 Mar 2010 15:30:37 -0500
Content-Disposition: inline
In-Reply-To: <20100310202804.GC2834@psychotron.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

It's not desired for underlaying devices to change type. At the time, there is
for example possible to have bond with changed type from Ethernet to Infiniband
as a port of a bridge. This patch fixes this.

Signed-off-by: Jiri Pirko <jpirko@redhat.com>
---
 drivers/net/macvlan.c  |    3 +++
 net/8021q/vlan.c       |    4 ++++
 net/bridge/br_notify.c |    4 ++++
 3 files changed, 11 insertions(+), 0 deletions(-)

diff --git a/drivers/net/macvlan.c b/drivers/net/macvlan.c
index 40faa36..445e73c 100644
--- a/drivers/net/macvlan.c
+++ b/drivers/net/macvlan.c
@@ -748,6 +748,9 @@ static int macvlan_device_event(struct notifier_block *unused,
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			vlan->dev->rtnl_link_ops->dellink(vlan->dev, NULL);
 		break;
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* Forbid underlaying device to change its type. */
+		return NOTIFY_BAD;
 	}
 	return NOTIFY_DONE;
 }
diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 4535122..c39a5f4 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -530,6 +530,10 @@ static int vlan_device_event(struct notifier_block *unused, unsigned long event,
 		}
 		unregister_netdevice_many(&list);
 		break;
+
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* Forbid underlaying device to change its type. */
+		return NOTIFY_BAD;
 	}
 
 out:
diff --git a/net/bridge/br_notify.c b/net/bridge/br_notify.c
index 763a3ec..1413b72 100644
--- a/net/bridge/br_notify.c
+++ b/net/bridge/br_notify.c
@@ -82,6 +82,10 @@ static int br_device_event(struct notifier_block *unused, unsigned long event, v
 	case NETDEV_UNREGISTER:
 		br_del_if(br, dev);
 		break;
+
+	case NETDEV_PRE_TYPE_CHANGE:
+		/* Forbid underlaying device to change its type. */
+		return NOTIFY_BAD;
 	}
 
 	/* Events that may cause spanning tree to refresh */
-- 
1.6.6.1

