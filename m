From: Patrick McHardy <kaber@trash.net>
Subject: [VLAN]: nested VLAN: fix lockdep's recursive locking warning
Date: Thu, 10 Jan 2008 16:32:35 +0100
Message-ID: <47863A93.5060000@trash.net>
Mime-Version: 1.0
Content-Type: multipart/mixed;
 boundary="------------020300030606000909000003"
Cc: Linux Netdev List <netdev@vger.kernel.org>
To: "David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:57248 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754212AbYAJPhA (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 10 Jan 2008 10:37:00 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This is a multi-part message in MIME format.
--------------020300030606000909000003
Content-Type: text/plain; charset=ISO-8859-15; format=flowed
Content-Transfer-Encoding: 7bit


--------------020300030606000909000003
Content-Type: text/x-patch;
 name="01.diff"
Content-Transfer-Encoding: 7bit
Content-Disposition: inline;
 filename="01.diff"

[VLAN]: nested VLAN: fix lockdep's recursive locking warning

Allow vlans nesting other vlans without lockdep's warnings (max. 2 levels
i.e. parent + child). Thanks to Patrick McHardy for pointing a bug in the
first version of this patch.

Reported-by: Benny Amorsen

Signed-off-by: Jarek Poplawski <jarkao2@gmail.com>
Signed-off-by: Patrick McHardy <kaber@trash.net>

---
commit 4d14fded63dcaf9d5dcf78e2a8ea3f5de2c29eb9
tree 2f0792e8240151b1e5437b05130d1f569175f572
parent e2474f60798c97f5c05d29a906045dd1f416ba7f
author Jarek Poplawski <jarkao2@gmail.com> Thu, 10 Jan 2008 16:25:00 +0100
committer Patrick McHardy <kaber@trash.net> Thu, 10 Jan 2008 16:25:00 +0100

 net/8021q/vlan.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/net/8021q/vlan.c b/net/8021q/vlan.c
index 4add9bd..032bf44 100644
--- a/net/8021q/vlan.c
+++ b/net/8021q/vlan.c
@@ -323,6 +323,7 @@ static const struct header_ops vlan_header_ops = {
 static int vlan_dev_init(struct net_device *dev)
 {
 	struct net_device *real_dev = VLAN_DEV_INFO(dev)->real_dev;
+	int subclass = 0;
 
 	/* IFF_BROADCAST|IFF_MULTICAST; ??? */
 	dev->flags  = real_dev->flags & ~IFF_UP;
@@ -349,7 +350,11 @@ static int vlan_dev_init(struct net_device *dev)
 		dev->hard_start_xmit = vlan_dev_hard_start_xmit;
 	}
 
-	lockdep_set_class(&dev->_xmit_lock, &vlan_netdev_xmit_lock_key);
+	if (real_dev->priv_flags & IFF_802_1Q_VLAN)
+		subclass = 1;
+
+	lockdep_set_class_and_subclass(&dev->_xmit_lock,
+				&vlan_netdev_xmit_lock_key, subclass);
 	return 0;
 }
 

--------------020300030606000909000003--
