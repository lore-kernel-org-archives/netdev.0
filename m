From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH] bridge: don't allow setting hello time to zero
Date: Thu, 4 Sep 2008 15:47:09 -0700
Message-ID: <20080904154709.48fe0775@extreme>
References: <fa.wTMiBcGRgw2fBtdHwtX7y0lkc8s@ifi.uio.no>
	<48975BD3.6040709@shaw.ca>
	<a08621850808041337k1d1deb6fk78098d9fcd4930dd@mail.gmail.com>
	<20080807185802.GA16327@electric-eye.fr.zoreil.com>
	<a08621850808101200n220afd2dve58abe67830b7a4f@mail.gmail.com>
	<a08621850808110053j5cbf23e6xdf52c9e7440abf19@mail.gmail.com>
	<a08621850808291848q5660148fx57d576ecfcbfce8@mail.gmail.com>
	<a08621850808310151o143845h195a8658d02270d9@mail.gmail.com>
	<20080831100537.6929c51e@extreme>
	<20080831104309.780cc01f@extreme>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: 7bit
Cc: "Dushan Tcholich" <dusanc@gmail.com>,
	"Francois Romieu" <romieu@fr.zoreil.com>,
	"Robert Hancock" <hancockr@shaw.ca>, netdev@vger.kernel.org,
	LKML <linux-kernel@vger.kernel.org>,
	bridge@lists.linux-foundation.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.vyatta.com ([216.93.170.194]:50231 "EHLO mail.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754891AbYIDWrL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 4 Sep 2008 18:47:11 -0400
In-Reply-To: <20080831104309.780cc01f@extreme>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

The bridge hello time can't be safely set to values less than 1 second,
otherwise it is possible to end up with a runaway timer.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>

--- a/net/bridge/br_ioctl.c	2008-09-04 15:25:41.000000000 -0700
+++ b/net/bridge/br_ioctl.c	2008-09-04 15:44:33.000000000 -0700
@@ -188,15 +188,21 @@ static int old_dev_ioctl(struct net_devi
 		return 0;
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
+	{
+		unsigned long t = clock_t_to_jiffies(args[1]);
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		if (t < HZ)
+			return -EINVAL;
+
 		spin_lock_bh(&br->lock);
-		br->bridge_hello_time = clock_t_to_jiffies(args[1]);
+		br->bridge_hello_time = t;
 		if (br_is_root_bridge(br))
 			br->hello_time = br->bridge_hello_time;
 		spin_unlock_bh(&br->lock);
 		return 0;
+	}
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
 		if (!capable(CAP_NET_ADMIN))
--- a/net/bridge/br_sysfs_br.c	2008-09-04 15:27:20.000000000 -0700
+++ b/net/bridge/br_sysfs_br.c	2008-09-04 15:33:31.000000000 -0700
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
+	int err;
 
 	if (!capable(CAP_NET_ADMIN))
 		return -EPERM;
@@ -43,9 +44,9 @@ static ssize_t store_bridge_parm(struct 
 		return -EINVAL;
 
 	spin_lock_bh(&br->lock);
-	(*set)(br, val);
+	err = (*set)(br, val);
 	spin_unlock_bh(&br->lock);
-	return len;
+	return err ? err : len;
 }
 
 
@@ -56,12 +57,13 @@ static ssize_t show_forward_delay(struct
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
 }
 
-static void set_forward_delay(struct net_bridge *br, unsigned long val)
+static int set_forward_delay(struct net_bridge *br, unsigned long val)
 {
 	unsigned long delay = clock_t_to_jiffies(val);
 	br->forward_delay = delay;
 	if (br_is_root_bridge(br))
 		br->bridge_forward_delay = delay;
+	return 0;
 }
 
 static ssize_t store_forward_delay(struct device *d,
@@ -80,12 +82,17 @@ static ssize_t show_hello_time(struct de
 		       jiffies_to_clock_t(to_bridge(d)->hello_time));
 }
 
-static void set_hello_time(struct net_bridge *br, unsigned long val)
+static int set_hello_time(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
+
+	if (t < HZ)
+		return -EINVAL;
+
 	br->hello_time = t;
 	if (br_is_root_bridge(br))
 		br->bridge_hello_time = t;
+	return 0;
 }
 
 static ssize_t store_hello_time(struct device *d,
@@ -104,12 +111,13 @@ static ssize_t show_max_age(struct devic
 		       jiffies_to_clock_t(to_bridge(d)->max_age));
 }
 
-static void set_max_age(struct net_bridge *br, unsigned long val)
+static int set_max_age(struct net_bridge *br, unsigned long val)
 {
 	unsigned long t = clock_t_to_jiffies(val);
 	br->max_age = t;
 	if (br_is_root_bridge(br))
 		br->bridge_max_age = t;
+	return 0;
 }
 
 static ssize_t store_max_age(struct device *d, struct device_attribute *attr,
@@ -126,9 +134,10 @@ static ssize_t show_ageing_time(struct d
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->ageing_time));
 }
 
-static void set_ageing_time(struct net_bridge *br, unsigned long val)
+static int set_ageing_time(struct net_bridge *br, unsigned long val)
 {
 	br->ageing_time = clock_t_to_jiffies(val);
+	return 0;
 }
 
 static ssize_t store_ageing_time(struct device *d,
@@ -180,9 +189,10 @@ static ssize_t show_priority(struct devi
 		       (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1]);
 }
 
-static void set_priority(struct net_bridge *br, unsigned long val)
+static int set_priority(struct net_bridge *br, unsigned long val)
 {
 	br_stp_set_bridge_priority(br, (u16) val);
+	return 0;
 }
 
 static ssize_t store_priority(struct device *d, struct device_attribute *attr,

