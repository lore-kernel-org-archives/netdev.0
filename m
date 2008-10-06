From: Jarod Neuner <j.neuner@networkharbor.com>
Subject: IGMP sent to Foreign VLAN
Date: Mon, 6 Oct 2008 14:51:47 -0500
Message-ID: <1223322707.24688.46.camel@deepthought.nh.local>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
To: <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from 75-150-216-245-Illinois.hfc.comcastbusiness.net ([75.150.216.245]:16473
	"EHLO mx.networkharbor.com" rhost-flags-OK-FAIL-OK-FAIL)
	by vger.kernel.org with ESMTP id S1752387AbYJFUBh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2008 16:01:37 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

I noticed a problem where the kernel is not responding to IGMP Queries
from several Level-3 network switches.  This behavior is caused by these
switches using VLAN tags on IGMP messages.  At first I thought the
switches were out of spec, but every other network stack I've checked
delivers packets with unconfigured VLAN assignments directly to the
incoming interface.  

This patch corrects my problem, but I'm still interested in discussion
about whether or not this should be a parameter in /proc/sys/net or even
if this policy change should be applied elsewhere in the the network
stack.

---

diff --git a/net/8021q/vlan_dev.c b/net/8021q/vlan_dev.c
index 4bf014e..b65a8fd 100644
--- a/net/8021q/vlan_dev.c
+++ b/net/8021q/vlan_dev.c
@@ -158,9 +158,13 @@ int vlan_skb_recv(struct sk_buff *skb, struct net_device *dev,
        rcu_read_lock();
        skb->dev = __find_vlan_dev(dev, vlan_id);
        if (!skb->dev) {
-               pr_debug("%s: ERROR: No net_device for VID: %u on dev: %s\n",
+               pr_debug("%s: WARNING: Forwarding VID: %u to dev: %s\n",
                         __func__, vlan_id, dev->name);
-               goto err_unlock;
+               skb->dev = dev;
+               skb_pull_rcsum(skb, VLAN_HLEN);
+               vlan_set_encap_proto(skb, vhdr);
+               rcu_read_lock();
+               return 0;
        }

        skb->dev->last_rx = jiffies;






