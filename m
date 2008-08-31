From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [RFC] bridge: STP timer management range checking
Date: Sun, 31 Aug 2008 10:43:09 -0700
Message-ID: <20080831104309.780cc01f@extreme>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	<48975BD3.6040709@shaw.ca>
	<a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
	<20080807185802.GA16327@electric-eye.fr.zoreil.com>
	<a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
	<a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com>
	<a08621850808291848q5660148fx57d576ecfcbfce8@mail.gmail.com>
	<a08621850808310151o143845h195a8658d02270d9@mail.gmail.com>
	<20080831100537.6929c51e@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Francois Romieu" <romieu@fr.zoreil.com>,
	"Robert Hancock" <hancockr@shaw.ca>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>,
	"Dushan Tcholich" <dusanc@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:55703 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754698AbYHaRnL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 31 Aug 2008 13:43:11 -0400
In-Reply-To: <20080831100537.6929c51e@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The Spanning Tree Protocol timers need to be set within certain boundaries
to keep the internal protocol engine working, and to be interoperable.
This patch restricts changes to those timers to the values defined in IEEE 802.1D
specification.

The only exception to the standards are:
  * if STP is disabled allow forwarding delay to be turned off
  * allow wider range of ageing timer since this isn't directly part of
    STP, and setting it to zero allows for non-remembering bridge.

Warning: this may cause user backlash since apparently working but standards
  conforming configurations will get configuration errors that they didn't
  see before.

--- a/net/bridge/br_ioctl.c	2008-08-31 10:00:44.000000000 -0700
+++ b/net/bridge/br_ioctl.c	2008-08-31 10:34:00.000000000 -0700
@@ -177,38 +177,63 @@ static int old_dev_ioctl(struct net_devi
 	}
 
 	case BRCTL_SET_BRIDGE_FORWARD_DELAY:
+	{
+		unsigned long t = clock_t_to_jiffies(args[1]);
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		/* enforce range checking per IEEE 802.1D 17.14 */
+		if (br->stp_enabled != BR_NO_STP &&
+		    (t < 4*HZ || t > 30 * HZ))
+			return -EINVAL;
+
 		spin_lock_bh(&br->lock);
-		br->bridge_forward_delay = clock_t_to_jiffies(args[1]);
+		br->bridge_forward_delay = t;
 		if (br_is_root_bridge(br))
 			br->forward_delay = br->bridge_forward_delay;
 		spin_unlock_bh(&br->lock);
 		return 0;
-
+	}
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
+	{
+		unsigned long t = clock_t_to_jiffies(args[1]);
+
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		if (t < HZ || t > 15 * HZ)
+			return -EINVAL;
+
 		spin_lock_bh(&br->lock);
-		br->bridge_hello_time = clock_t_to_jiffies(args[1]);
+		br->bridge_hello_time = t;
 		if (br_is_root_bridge(br))
 			br->hello_time = br->bridge_hello_time;
 		spin_unlock_bh(&br->lock);
 		return 0;
-
+	}
 	case BRCTL_SET_BRIDGE_MAX_AGE:
+	{
+		unsigned long t = clock_t_to_jiffies(args[1]);
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		/* enforce range checking per IEEE 802.1D 17.14 */
+		if (t < 6 * HZ || t > 40 * HZ)
+			return -EINVAL;
+
+		if (t < 2 * (br->bridge_hello_time + HZ))
+			return -EINVAL;
+
+		if (t / 2 + HZ > br->bridge_forward_delay)
+			return -EINVAL;
+
 		spin_lock_bh(&br->lock);
 		br->bridge_max_age = clock_t_to_jiffies(args[1]);
 		if (br_is_root_bridge(br))
 			br->max_age = br->bridge_max_age;
 		spin_unlock_bh(&br->lock);
 		return 0;
-
+	}
 	case BRCTL_SET_AGEING_TIME:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
--- a/net/bridge/br_sysfs_br.c	2008-08-31 10:23:59.000000000 -0700
+++ b/net/bridge/br_sysfs_br.c	2008-08-31 10:32:53.000000000 -0700
@@ -29,11 +29,12 @@
  */
 static ssize_t store_bridge_parm(struct device *d,
 				 const char *buf, size_t len,
-				 void (*set)(struct net_bridge *, unsigned long))
+				 int (*set)(struct net_bridge *, unsigned long))
 {
 	struct net_bridge *br = to_bridge(d);
 	char *endp;
 	unsigned long val;
+	int rc;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -43,9 +44,10 @@ static ssize_t store_bridge_parm(struct 
 		return -EINVAL;
 
 	spin_lock_bh(&br->lock);
-	(*set)(br, val);
+	rc = (*set)(br, val);
 	spin_unlock_bh(&br->lock);
-	return len;
+
+	return rc ? rc : len;
 }
 
 
@@ -56,12 +58,19 @@ static ssize_t show_forward_delay(struct
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
 }
 
-static void set_forward_delay(struct net_bridge *br, unsigned long val)
+static int set_forward_delay(struct net_bridge *br, unsigned long val)
 {
 	unsigned long delay = clock_t_to_jiffies(val);
+
+	if (br->stp_enabled != BR_NO_STP &&
+	    (delay < 4*HZ || delay > 30 * HZ))
+		return -EINVAL;
+
 	br->forward_delay = delay;
 	if (br_is_root_bridge(br))
 		br->bridge_forward_delay = delay;
+
+	return 0;
 }
 
 static ssize_t store_forward_delay(struct device *d,
@@ -80,12 +89,18 @@ static ssize_t show_hello_time(struct de
 		       jiffies_to_clock_t(to_bridge(d)->hello_time));
 }
 
-static void set_hello_time(struct net_bridge *br, unsigned long val)
+static int set_hello_time(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
+
+	if (t < HZ || t > 15 * HZ)
+		return -EINVAL;
+
 	br->hello_time = t;
 	if (br_is_root_bridge(br))
 		br->bridge_hello_time = t;
+
+	return 0;
 }
 
 static ssize_t store_hello_time(struct device *d,
@@ -104,12 +119,24 @@ static ssize_t show_max_age(struct devic
 		       jiffies_to_clock_t(to_bridge(d)->max_age));
 }
 
-static void set_max_age(struct net_bridge *br, unsigned long val)
+static int set_max_age(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
+
+	/* enforce range checking per IEEE 802.1D 17.14 */
+	if (t < 6 * HZ || t > 40 * HZ)
+		return -EINVAL;
+
+	if (t < 2 * (br->bridge_hello_time + HZ))
+		return -EINVAL;
+
+	if (t / 2 + HZ > br->bridge_forward_delay)
+		return -EINVAL;
+
 	br->max_age = t;
 	if (br_is_root_bridge(br))
 		br->bridge_max_age = t;
+	return 0;
 }
 
 static ssize_t store_max_age(struct device *d, struct device_attribute *attr,
@@ -126,9 +153,10 @@ static ssize_t show_ageing_time(struct d
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->ageing_time));
 }
 
-static void set_ageing_time(struct net_bridge *br, unsigned long val)
+static int set_ageing_time(struct net_bridge *br, unsigned long val)
 {
 	br->ageing_time = clock_t_to_jiffies(val);
+	return 0;
 }
 
 static ssize_t store_ageing_time(struct device *d,
@@ -180,9 +208,10 @@ static ssize_t show_priority(struct devi
 		       (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1]);
 }
 
-static void set_priority(struct net_bridge *br, unsigned long val)
+static int set_priority(struct net_bridge *br, unsigned long val)
 {
 	br_stp_set_bridge_priority(br, (u16) val);
+	return 0;
 }
 
 static ssize_t store_priority(struct device *d, struct device_attribute *attr,
