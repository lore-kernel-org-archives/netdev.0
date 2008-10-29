From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 2/2] macvlan: propogate mtu changes
Date: Wed, 29 Oct 2008 12:59:12 -0700
Message-ID: <20081029125912.002dbe9d@extreme>
References: <20081029125343.695eeb3c@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: Patrick McHardy <kaber@trash.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([76.74.103.46]:53065 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752526AbYJ2T7S (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 29 Oct 2008 15:59:18 -0400
In-Reply-To: <20081029125343.695eeb3c@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If MTU of underlying real device is changed, propogate up to macvlan
pseudo devices.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


--- a/drivers/net/macvlan.c	2008-10-29 09:53:00.000000000 -0700
+++ b/drivers/net/macvlan.c	2008-10-29 12:58:40.000000000 -0700
@@ -537,6 +537,19 @@ static int macvlan_device_event(struct n
 		list_for_each_entry_safe(vlan, next, &port->vlans, list)
 			macvlan_dellink(vlan->dev);
 		break;
+	case NETDEV_CHANGEMTU:
+		list_for_each_entry(vlan, &port->vlans, list) {
+			int err, oldmtu = vlan->dev->mtu;
+
+			err = dev_set_mtu(vlan->dev, dev->mtu);
+			if (err) {
+				list_for_each_entry_continue_reverse(vlan,
+								     &port->vlans,
+								     list)
+					dev_set_mtu(vlan->dev, oldmtu);
+				return notifier_from_errno(err);
+			}
+		}
 	}
 	return NOTIFY_DONE;
 }
