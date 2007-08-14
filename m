From: Stephen Hemminger <shemminger@linux-foundation.org>
Subject: [PATCH] bridge: sysfs locking fix.
Date: Tue, 14 Aug 2007 14:50:52 +0100
Message-ID: <20070814145052.2d135d2f@oldman.hamilton.local>
References: <46BCE380.60508@cluded.net>
 <20070812012037.0195b610.akpm@linux-foundation.org>
 <20070814141105.0a4b8dde@oldman.hamilton.local>
 <20070814131822.GA13676@xi.wantstofly.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: Andrew Morton <akpm@linux-foundation.org>,
	"David S. Miller" <davem@davemloft.net>, netdev@vger.kernel.org,
	bridge@linux-foundation.org
To: Lennert Buytenhek <buytenh@wantstofly.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp2.linux-foundation.org ([207.189.120.14]:51427 "EHLO
	smtp2.linux-foundation.org" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751415AbXHNN5k (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 14 Aug 2007 09:57:40 -0400
In-Reply-To: <20070814131822.GA13676@xi.wantstofly.org>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Forget earlier patch, it is wrong...

The stp change code generates "sleeping function called from invalid context"
because rtnl_lock() called with BH disabled. This fixes it by not acquiring then
dropping the bridge lock.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>

--- a/net/bridge/br_sysfs_br.c	2007-08-06 09:26:48.000000000 +0100
+++ b/net/bridge/br_sysfs_br.c	2007-08-14 14:29:52.000000000 +0100
@@ -147,20 +147,26 @@ static ssize_t show_stp_state(struct dev
 	return sprintf(buf, "%d\n", br->stp_enabled);
 }
 
-static void set_stp_state(struct net_bridge *br, unsigned long val)
-{
-	rtnl_lock();
-	spin_unlock_bh(&br->lock);
-	br_stp_set_enabled(br, val);
-	spin_lock_bh(&br->lock);
-	rtnl_unlock();
-}
 
 static ssize_t store_stp_state(struct device *d,
 			       struct device_attribute *attr, const char *buf,
 			       size_t len)
 {
-	return store_bridge_parm(d, buf, len, set_stp_state);
+	struct net_bridge *br = to_bridge(d);
+	char *endp;
+	unsigned long val;
+
+	if (!capable(CAP_NET_ADMIN))
+		return -EPERM;
+
+	val = simple_strtoul(buf, &endp, 0);
+	if (endp == buf)
+		return -EINVAL;
+
+	rtnl_lock();
+	br_stp_set_enabled(br, val);
+	rtnl_unlock();
+
 }
 static DEVICE_ATTR(stp_state, S_IRUGO | S_IWUSR, show_stp_state,
 		   store_stp_state);
