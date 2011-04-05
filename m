From: Stephen Hemminger <shemminger@vyatta.com>
Subject: [PATCH 7/7] bridge: range check STP parameters
Date: Mon, 04 Apr 2011 17:03:33 -0700
Message-ID: <20110405000537.559988210@vyatta.com>
References: <20110405000326.714524584@vyatta.com>
Cc: netdev@vger.kernel.org
To: "David S. Miller" <davem@davemloft.net>,
	Sasikanth V <sasikanth.v19@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from suva.vyatta.com ([76.74.103.44]:42828 "EHLO suva.vyatta.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751145Ab1DEAJx (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Apr 2011 20:09:53 -0400
Content-Disposition: inline; filename=br-param.patch
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Apply restrictions on STP parameters based 802.1D 1998 standard.
   * Fixes missing locking in set path cost ioctl
   * Uses common code for both ioctl and sysfs

This is based on an earlier patch Sasikanth V but with overhaul.

Note:
1. It does NOT enforce the restriction on the relationship max_age and
   forward delay or hello time because in existing implementation these are
   set as independant operations.

2. If STP is disabled, there is no restriction on forward delay

3. No restriction on holding time because users use Linux code to act
   as hub or be sticky.

4. Although standard allow 0-255, Linux only allows 0-63 for port priority
   because more bits are reserved for port number.

Signed-off-by: Stephen Hemminger <shemminger@vyatta.com>


---
 net/bridge/br_ioctl.c       |   40 ++++++++----------------------------
 net/bridge/br_private.h     |   13 ++++++++---
 net/bridge/br_private_stp.h |   13 +++++++++++
 net/bridge/br_stp.c         |   48 ++++++++++++++++++++++++++++++++++++++++++++
 net/bridge/br_stp_if.c      |   21 +++++++++++++++----
 net/bridge/br_sysfs_br.c    |   39 ++---------------------------------
 net/bridge/br_sysfs_if.c    |   26 +++++++----------------
 7 files changed, 107 insertions(+), 93 deletions(-)

--- a/net/bridge/br_ioctl.c	2011-04-04 15:46:46.822291708 -0700
+++ b/net/bridge/br_ioctl.c	2011-04-04 16:34:29.164630581 -0700
@@ -181,40 +181,19 @@ static int old_dev_ioctl(struct net_devi
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_bh(&br->lock);
-		br->bridge_forward_delay = clock_t_to_jiffies(args[1]);
-		if (br_is_root_bridge(br))
-			br->forward_delay = br->bridge_forward_delay;
-		spin_unlock_bh(&br->lock);
-		return 0;
+		return br_set_forward_delay(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
-	{
-		unsigned long t = clock_t_to_jiffies(args[1]);
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		if (t < HZ)
-			return -EINVAL;
-
-		spin_lock_bh(&br->lock);
-		br->bridge_hello_time = t;
-		if (br_is_root_bridge(br))
-			br->hello_time = br->bridge_hello_time;
-		spin_unlock_bh(&br->lock);
-		return 0;
-	}
+		return br_set_hello_time(br, args[1]);
 
 	case BRCTL_SET_BRIDGE_MAX_AGE:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		spin_lock_bh(&br->lock);
-		br->bridge_max_age = clock_t_to_jiffies(args[1]);
-		if (br_is_root_bridge(br))
-			br->max_age = br->bridge_max_age;
-		spin_unlock_bh(&br->lock);
-		return 0;
+		return br_set_max_age(br, args[1]);
 
 	case BRCTL_SET_AGEING_TIME:
 		if (!capable(CAP_NET_ADMIN))
@@ -275,19 +254,16 @@ static int old_dev_ioctl(struct net_devi
 	case BRCTL_SET_PORT_PRIORITY:
 	{
 		struct net_bridge_port *p;
-		int ret = 0;
+		int ret;
 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
-		if (args[2] >= (1<<(16-BR_PORT_BITS)))
-			return -ERANGE;
-
 		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, args[1])) == NULL)
 			ret = -EINVAL;
 		else
-			br_stp_set_port_priority(p, args[2]);
+			ret = br_stp_set_port_priority(p, args[2]);
 		spin_unlock_bh(&br->lock);
 		return ret;
 	}
@@ -295,15 +271,17 @@ static int old_dev_ioctl(struct net_devi
 	case BRCTL_SET_PATH_COST:
 	{
 		struct net_bridge_port *p;
-		int ret = 0;
+		int ret;
 
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
 
+		spin_lock_bh(&br->lock);
 		if ((p = br_get_port(br, args[1])) == NULL)
 			ret = -EINVAL;
 		else
-			br_stp_set_path_cost(p, args[2]);
+			ret = br_stp_set_path_cost(p, args[2]);
+		spin_unlock_bh(&br->lock);
 
 		return ret;
 	}
--- a/net/bridge/br_private.h	2011-04-04 15:39:32.777614097 -0700
+++ b/net/bridge/br_private.h	2011-04-04 16:39:55.816195002 -0700
@@ -495,6 +495,11 @@ extern struct net_bridge_port *br_get_po
 extern void br_init_port(struct net_bridge_port *p);
 extern void br_become_designated_port(struct net_bridge_port *p);
 
+extern int br_set_forward_delay(struct net_bridge *br, unsigned long x);
+extern int br_set_hello_time(struct net_bridge *br, unsigned long x);
+extern int br_set_max_age(struct net_bridge *br, unsigned long x);
+
+
 /* br_stp_if.c */
 extern void br_stp_enable_bridge(struct net_bridge *br);
 extern void br_stp_disable_bridge(struct net_bridge *br);
@@ -505,10 +510,10 @@ extern bool br_stp_recalculate_bridge_id
 extern void br_stp_change_bridge_id(struct net_bridge *br, const unsigned char *a);
 extern void br_stp_set_bridge_priority(struct net_bridge *br,
 				       u16 newprio);
-extern void br_stp_set_port_priority(struct net_bridge_port *p,
-				     u8 newprio);
-extern void br_stp_set_path_cost(struct net_bridge_port *p,
-				 u32 path_cost);
+extern int br_stp_set_port_priority(struct net_bridge_port *p,
+				    unsigned long newprio);
+extern int br_stp_set_path_cost(struct net_bridge_port *p,
+				unsigned long path_cost);
 extern ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id);
 
 /* br_stp_bpdu.c */
--- a/net/bridge/br_private_stp.h	2011-04-04 15:40:02.125930146 -0700
+++ b/net/bridge/br_private_stp.h	2011-04-04 16:21:05.960073263 -0700
@@ -16,6 +16,19 @@
 #define BPDU_TYPE_CONFIG 0
 #define BPDU_TYPE_TCN 0x80
 
+/* IEEE 802.1D-1998 timer values */
+#define BR_MIN_HELLO_TIME	(1*HZ)
+#define BR_MAX_HELLO_TIME	(10*HZ)
+
+#define BR_MIN_FORWARD_DELAY	(2*HZ)
+#define BR_MAX_FORWARD_DELAY	(30*HZ)
+
+#define BR_MIN_MAX_AGE		(6*HZ)
+#define BR_MAX_MAX_AGE		(40*HZ)
+
+#define BR_MIN_PATH_COST	1
+#define BR_MAX_PATH_COST	65535
+
 struct br_config_bpdu
 {
 	unsigned	topology_change:1;
--- a/net/bridge/br_stp.c	2011-04-04 15:47:54.707023927 -0700
+++ b/net/bridge/br_stp.c	2011-04-04 16:33:49.908201916 -0700
@@ -484,3 +484,51 @@ void br_received_tcn_bpdu(struct net_bri
 		br_topology_change_acknowledge(p);
 	}
 }
+
+/* Change bridge STP parameter */
+int br_set_hello_time(struct net_bridge *br, unsigned long val)
+{
+	unsigned long t = clock_t_to_jiffies(val);
+
+	if (t < BR_MIN_HELLO_TIME || t > BR_MAX_HELLO_TIME)
+		return -ERANGE;
+
+	spin_lock_bh(&br->lock);
+	br->bridge_hello_time = t;
+	if (br_is_root_bridge(br))
+		br->hello_time = br->bridge_hello_time;
+	spin_unlock_bh(&br->lock);
+	return 0;
+}
+
+int br_set_max_age(struct net_bridge *br, unsigned long val)
+{
+	unsigned long t = clock_t_to_jiffies(val);
+
+	if (t < BR_MIN_MAX_AGE || t > BR_MAX_MAX_AGE)
+		return -ERANGE;
+
+	spin_lock_bh(&br->lock);
+	br->bridge_max_age = t;
+	if (br_is_root_bridge(br))
+		br->max_age = br->bridge_max_age;
+	spin_unlock_bh(&br->lock);
+	return 0;
+
+}
+
+int br_set_forward_delay(struct net_bridge *br, unsigned long val)
+{
+	unsigned long t = clock_t_to_jiffies(val);
+
+	if (br->stp_enabled != BR_NO_STP &&
+	    (t < BR_MIN_FORWARD_DELAY || t > BR_MAX_FORWARD_DELAY))
+		return -ERANGE;
+
+	spin_lock_bh(&br->lock);
+	br->bridge_forward_delay = t;
+	if (br_is_root_bridge(br))
+		br->forward_delay = br->bridge_forward_delay;
+	spin_unlock_bh(&br->lock);
+	return 0;
+}
--- a/net/bridge/br_stp_if.c	2011-04-04 16:11:56.538282617 -0700
+++ b/net/bridge/br_stp_if.c	2011-04-04 16:33:49.888201699 -0700
@@ -20,7 +20,7 @@
 
 
 /* Port id is composed of priority and port number.
- * NB: least significant bits of priority are dropped to
+ * NB: some bits of priority are dropped to
  *     make room for more ports.
  */
 static inline port_id br_make_port_id(__u8 priority, __u16 port_no)
@@ -29,6 +29,8 @@ static inline port_id br_make_port_id(__
 		| (port_no & ((1<<BR_PORT_BITS)-1));
 }
 
+#define BR_MAX_PORT_PRIORITY ((u16)~0 >> BR_PORT_BITS)
+
 /* called under bridge lock */
 void br_init_port(struct net_bridge_port *p)
 {
@@ -255,10 +257,14 @@ void br_stp_set_bridge_priority(struct n
 }
 
 /* called under bridge lock */
-void br_stp_set_port_priority(struct net_bridge_port *p, u8 newprio)
+int br_stp_set_port_priority(struct net_bridge_port *p, unsigned long newprio)
 {
-	port_id new_port_id = br_make_port_id(newprio, p->port_no);
+	port_id new_port_id;
+
+	if (newprio > BR_MAX_PORT_PRIORITY)
+		return -ERANGE;
 
+	new_port_id = br_make_port_id(newprio, p->port_no);
 	if (br_is_designated_port(p))
 		p->designated_port = new_port_id;
 
@@ -269,14 +275,21 @@ void br_stp_set_port_priority(struct net
 		br_become_designated_port(p);
 		br_port_state_selection(p->br);
 	}
+
+	return 0;
 }
 
 /* called under bridge lock */
-void br_stp_set_path_cost(struct net_bridge_port *p, u32 path_cost)
+int br_stp_set_path_cost(struct net_bridge_port *p, unsigned long path_cost)
 {
+	if (path_cost < BR_MIN_PATH_COST ||
+	    path_cost > BR_MAX_PATH_COST)
+		return -ERANGE;
+
 	p->path_cost = path_cost;
 	br_configuration_update(p->br);
 	br_port_state_selection(p->br);
+	return 0;
 }
 
 ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id)
--- a/net/bridge/br_sysfs_br.c	2011-04-04 15:56:51.112815302 -0700
+++ b/net/bridge/br_sysfs_br.c	2011-04-04 15:59:07.710269828 -0700
@@ -43,9 +43,7 @@ static ssize_t store_bridge_parm(struct
 	if (endp == buf)
 		return -EINVAL;
 
-	spin_lock_bh(&br->lock);
 	err = (*set)(br, val);
-	spin_unlock_bh(&br->lock);
 	return err ? err : len;
 }
 
@@ -57,20 +55,11 @@ static ssize_t show_forward_delay(struct
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
 }
 
-static int set_forward_delay(struct net_bridge *br, unsigned long val)
-{
-	unsigned long delay = clock_t_to_jiffies(val);
-	br->forward_delay = delay;
-	if (br_is_root_bridge(br))
-		br->bridge_forward_delay = delay;
-	return 0;
-}
-
 static ssize_t store_forward_delay(struct device *d,
 				   struct device_attribute *attr,
 				   const char *buf, size_t len)
 {
-	return store_bridge_parm(d, buf, len, set_forward_delay);
+	return store_bridge_parm(d, buf, len, br_set_forward_delay);
 }
 static DEVICE_ATTR(forward_delay, S_IRUGO | S_IWUSR,
 		   show_forward_delay, store_forward_delay);
@@ -82,24 +71,11 @@ static ssize_t show_hello_time(struct de
 		       jiffies_to_clock_t(to_bridge(d)->hello_time));
 }
 
-static int set_hello_time(struct net_bridge *br, unsigned long val)
-{
-	unsigned long t = clock_t_to_jiffies(val);
-
-	if (t < HZ)
-		return -EINVAL;
-
-	br->hello_time = t;
-	if (br_is_root_bridge(br))
-		br->bridge_hello_time = t;
-	return 0;
-}
-
 static ssize_t store_hello_time(struct device *d,
 				struct device_attribute *attr, const char *buf,
 				size_t len)
 {
-	return store_bridge_parm(d, buf, len, set_hello_time);
+	return store_bridge_parm(d, buf, len, br_set_hello_time);
 }
 static DEVICE_ATTR(hello_time, S_IRUGO | S_IWUSR, show_hello_time,
 		   store_hello_time);
@@ -111,19 +87,10 @@ static ssize_t show_max_age(struct devic
 		       jiffies_to_clock_t(to_bridge(d)->max_age));
 }
 
-static int set_max_age(struct net_bridge *br, unsigned long val)
-{
-	unsigned long t = clock_t_to_jiffies(val);
-	br->max_age = t;
-	if (br_is_root_bridge(br))
-		br->bridge_max_age = t;
-	return 0;
-}
-
 static ssize_t store_max_age(struct device *d, struct device_attribute *attr,
 			     const char *buf, size_t len)
 {
-	return store_bridge_parm(d, buf, len, set_max_age);
+	return store_bridge_parm(d, buf, len, br_set_max_age);
 }
 static DEVICE_ATTR(max_age, S_IRUGO | S_IWUSR, show_max_age, store_max_age);
 
--- a/net/bridge/br_sysfs_if.c	2011-04-04 16:11:07.277767864 -0700
+++ b/net/bridge/br_sysfs_if.c	2011-04-04 16:32:56.123614502 -0700
@@ -23,7 +23,7 @@
 struct brport_attribute {
 	struct attribute	attr;
 	ssize_t (*show)(struct net_bridge_port *, char *);
-	ssize_t (*store)(struct net_bridge_port *, unsigned long);
+	int (*store)(struct net_bridge_port *, unsigned long);
 };
 
 #define BRPORT_ATTR(_name,_mode,_show,_store)		        \
@@ -38,27 +38,17 @@ static ssize_t show_path_cost(struct net
 {
 	return sprintf(buf, "%d\n", p->path_cost);
 }
-static ssize_t store_path_cost(struct net_bridge_port *p, unsigned long v)
-{
-	br_stp_set_path_cost(p, v);
-	return 0;
-}
+
 static BRPORT_ATTR(path_cost, S_IRUGO | S_IWUSR,
-		   show_path_cost, store_path_cost);
+		   show_path_cost, br_stp_set_path_cost);
 
 static ssize_t show_priority(struct net_bridge_port *p, char *buf)
 {
 	return sprintf(buf, "%d\n", p->priority);
 }
-static ssize_t store_priority(struct net_bridge_port *p, unsigned long v)
-{
-	if (v >= (1<<(16-BR_PORT_BITS)))
-		return -ERANGE;
-	br_stp_set_port_priority(p, v);
-	return 0;
-}
+
 static BRPORT_ATTR(priority, S_IRUGO | S_IWUSR,
-			 show_priority, store_priority);
+			 show_priority, br_stp_set_port_priority);
 
 static ssize_t show_designated_root(struct net_bridge_port *p, char *buf)
 {
@@ -136,7 +126,7 @@ static ssize_t show_hold_timer(struct ne
 }
 static BRPORT_ATTR(hold_timer, S_IRUGO, show_hold_timer, NULL);
 
-static ssize_t store_flush(struct net_bridge_port *p, unsigned long v)
+static int store_flush(struct net_bridge_port *p, unsigned long v)
 {
 	br_fdb_delete_by_port(p->br, p, 0); // Don't delete local entry
 	return 0;
@@ -148,7 +138,7 @@ static ssize_t show_hairpin_mode(struct
 	int hairpin_mode = (p->flags & BR_HAIRPIN_MODE) ? 1 : 0;
 	return sprintf(buf, "%d\n", hairpin_mode);
 }
-static ssize_t store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
+static int store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
 {
 	if (v)
 		p->flags |= BR_HAIRPIN_MODE;
@@ -165,7 +155,7 @@ static ssize_t show_multicast_router(str
 	return sprintf(buf, "%d\n", p->multicast_router);
 }
 
-static ssize_t store_multicast_router(struct net_bridge_port *p,
+static int store_multicast_router(struct net_bridge_port *p,
 				      unsigned long v)
 {
 	return br_multicast_set_port_router(p, v);


