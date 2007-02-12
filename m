From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET][BRIDGE] br_if: oops in port_carrier_check
Date: Mon, 12 Feb 2007 11:28:48 +0100
Message-ID: <20070212102848.GA4275@ff.dom.local>
References: <20070207140916.088b1073@oldman> <20070209074211.GA1631@ff.dom.local> <20070209095204.7f43a964@oldman> <20070212064446.GA1651@ff.dom.local>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, pterjan@gmail.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:55575 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S964828AbXBLKZo (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 12 Feb 2007 05:25:44 -0500
Content-Disposition: inline
In-Reply-To: <20070212064446.GA1651@ff.dom.local>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Here is my patch proposal for testing.
If it doesn't work - forget about it.
(Prepared with 2.6.20-git6 but could
be applied to 2.6.20 also.)

Jarek P.


dev_hold/dev_put added to prevent dev kfree
during port_carrier_check runnig, while dev
and port are removed.

Submitted and tested by: Pascal Terjan <pterjan@gmail.com>

Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.20-git6-/net/bridge/br_if.c linux-2.6.20-git6/net/bridge/br_if.c
--- linux-2.6.20-git6-/net/bridge/br_if.c	2007-02-12 10:20:14.000000000 +0100
+++ linux-2.6.20-git6/net/bridge/br_if.c	2007-02-12 10:36:58.000000000 +0100
@@ -108,6 +108,7 @@ static void port_carrier_check(struct wo
 		spin_unlock_bh(&br->lock);
 	}
 done:
+	dev_put(dev);
 	rtnl_unlock();
 }
 
@@ -161,7 +162,8 @@ static void del_nbp(struct net_bridge_po
 
 	dev_set_promiscuity(dev, -1);
 
-	cancel_delayed_work(&p->carrier_check);
+	if (cancel_delayed_work(&p->carrier_check))
+		dev_put(dev);
 
 	spin_lock_bh(&br->lock);
 	br_stp_disable_port(p);
@@ -444,7 +446,9 @@ int br_add_if(struct net_bridge *br, str
 	spin_lock_bh(&br->lock);
 	br_stp_recalculate_bridge_id(br);
 	br_features_recompute(br);
-	schedule_delayed_work(&p->carrier_check, BR_PORT_DEBOUNCE);
+	if (schedule_delayed_work(&p->carrier_check, BR_PORT_DEBOUNCE))
+		dev_hold(dev);
+
 	spin_unlock_bh(&br->lock);
 
 	dev_set_mtu(br->dev, br_min_mtu(br));
