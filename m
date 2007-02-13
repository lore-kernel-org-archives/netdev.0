From: Jarek Poplawski <jarkao2@o2.pl>
Subject: [PATCH][NET][BRIDGE] br_if: oops in port_carrier_check
Date: Tue, 13 Feb 2007 07:26:51 +0100
Message-ID: <20070213062650.GA1614@ff.dom.local>
References: <20070207140916.088b1073@oldman> <20070209074211.GA1631@ff.dom.local> <20070209095204.7f43a964@oldman> <20070212064446.GA1651@ff.dom.local> <20070212102848.GA4275@ff.dom.local> <20070212094738.0a8ae896@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Andrew Morton <akpm@linux-foundation.org>, netdev@vger.kernel.org,
	"bugme-daemon\@kernel-bugs\.osdl\.org"
	<bugme-daemon@bugzilla.kernel.org>, pterjan@gmail.com
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx10.go2.pl ([193.17.41.74]:60791 "EHLO poczta.o2.pl"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1161098AbXBMGXn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 13 Feb 2007 01:23:43 -0500
Content-Disposition: inline
In-Reply-To: <20070212094738.0a8ae896@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Mon, Feb 12, 2007 at 09:47:38AM -0800, Stephen Hemminger wrote:
> On Mon, 12 Feb 2007 11:28:48 +0100
> Jarek Poplawski <jarkao2@o2.pl> wrote:
> 
> > Here is my patch proposal for testing.
> > If it doesn't work - forget about it.
> > (Prepared with 2.6.20-git6 but could
> > be applied to 2.6.20 also.)
> > 
> > Jarek P.
> > 
> > 
> > dev_hold/dev_put added to prevent dev kfree
> > during port_carrier_check runnig, while dev
> > and port are removed.
> 
> No, holding the reference just stops the kfree, it doesn't
> stop the device from being removed from the port.

But I wrote above it is only to prevent the kfree.

>        p = dev->br_port;
>        if (!p)
>                goto done;
>        br = p->br;

Then p is NULL here and we goto done.

Sorry, but the first version was wrong (incomplete).
Below I attach a new proposal.


Signed-off-by: Jarek Poplawski <jarkao2@o2.pl>

---

diff -Nurp linux-2.6.20-git7-/net/bridge/br_if.c linux-2.6.20-git7/net/bridge/br_if.c
--- linux-2.6.20-git7-/net/bridge/br_if.c	2007-02-12 20:27:49.000000000 +0100
+++ linux-2.6.20-git7/net/bridge/br_if.c	2007-02-12 20:53:27.000000000 +0100
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
diff -Nurp linux-2.6.20-git7-/net/bridge/br_notify.c linux-2.6.20-git7/net/bridge/br_notify.c
--- linux-2.6.20-git7-/net/bridge/br_notify.c	2007-02-12 20:27:49.000000000 +0100
+++ linux-2.6.20-git7/net/bridge/br_notify.c	2007-02-12 20:50:50.000000000 +0100
@@ -56,7 +56,9 @@ static int br_device_event(struct notifi
 
 	case NETDEV_CHANGE:
 		if (br->dev->flags & IFF_UP)
-			schedule_delayed_work(&p->carrier_check, BR_PORT_DEBOUNCE);
+			if (schedule_delayed_work(&p->carrier_check,
+						BR_PORT_DEBOUNCE))
+				dev_hold(dev);
 		break;
 
 	case NETDEV_FEAT_CHANGE:
