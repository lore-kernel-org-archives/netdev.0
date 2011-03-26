From: Sasikanth V <sasikanth.v19@gmail.com>
Subject: =?UTF-8?q?=5BPATCH=5D=20Bridge=20allows=20the=20userspace=20to=20configure=20the=20bridge=20parameters=20with=20values=20not=20defined=20in=20the=20IEEE=20802=2E1D=20std?=
Date: Sat, 26 Mar 2011 20:19:57 +0530
Message-ID: <1301150997-4639-1-git-send-email-sasikanth.v19@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Sasikanth V <sasikanth.v19@gmail.com>
To: Stephen Hemminger <shemminger@linux-foundation.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-iy0-f174.google.com ([209.85.210.174]:47196 "EHLO
	mail-iy0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752061Ab1CZOx7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 26 Mar 2011 10:53:59 -0400
Received: by iyb14 with SMTP id 14so1502772iyb.19
        for <netdev@vger.kernel.org>; Sat, 26 Mar 2011 07:53:58 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


Signed-off-by: Sasikanth V <sasikanth.v19@gmail.com>
---
 include/linux/if_bridge.h |   28 +++++++++++++++
 net/bridge/br_ioctl.c     |   35 +++++++-----------
 net/bridge/br_private.h   |    7 +++-
 net/bridge/br_stp_if.c    |    7 +++-
 net/bridge/br_sysfs_br.c  |   83 ++++++++++++++++++++++++++++++++++++-=
--------
 net/bridge/br_sysfs_if.c  |    3 +-
 6 files changed, 122 insertions(+), 41 deletions(-)

diff --git a/include/linux/if_bridge.h b/include/linux/if_bridge.h
index dd3f201..9c6cc49 100644
--- a/include/linux/if_bridge.h
+++ b/include/linux/if_bridge.h
@@ -49,6 +49,34 @@
 #define BR_STATE_FORWARDING 3
 #define BR_STATE_BLOCKING 4
=20
+/*802.1D STP compatibility Range*/
+#define BR_DEFAULT_BRIDGE_PRIORITY 32768=20
+#define BR_MIN_BRIDGE_PRIORITY 0
+#define BR_MAX_BRIDGE_PRIORITY 65535
+
+#define BR_DEFAULT_PORT_PRIORITY 128
+#define BR_MIN_PORT_PRIORITY 0
+#define BR_MAX_PORT_PRIORITY 240
+
+#define BR_MIN_PATH_COST 1
+#define BR_MAX_PATH_COST 200000000
+
+#define BR_DEFAULT_HELLO_TIME 2
+#define BR_MIN_HELLO_TIME 1
+#define BR_MAX_HELLO_TIME 10
+
+#define BR_DEFAULT_MAX_AGE  20
+#define BR_MIN_MAX_AGE  6
+#define BR_MAX_MAX_AGE  40
+
+#define BR_DEFAULT_FORWARD_DELAY  15
+#define BR_MIN_FORWARD_DELAY  2
+#define BR_MAX_FORWARD_DELAY 30=20
+
+#define BR_DEFAULT_AGEING_TIME 300
+#define BR_MIN_AGEING_TIME 10
+#define BR_MAX_AGEING_TIME 1000000
+
 struct __bridge_info {
 	__u64 designated_root;
 	__u64 bridge_id;
diff --git a/net/bridge/br_ioctl.c b/net/bridge/br_ioctl.c
index cb43312..72cf6b6 100644
--- a/net/bridge/br_ioctl.c
+++ b/net/bridge/br_ioctl.c
@@ -112,6 +112,7 @@ static int old_dev_ioctl(struct net_device *dev, st=
ruct ifreq *rq, int cmd)
 {
 	struct net_bridge *br =3D netdev_priv(dev);
 	unsigned long args[4];
+	int rval =3D 0;
=20
 	if (copy_from_user(args, rq->ifr_data, sizeof(args)))
 		return -EFAULT;
@@ -182,27 +183,19 @@ static int old_dev_ioctl(struct net_device *dev, =
struct ifreq *rq, int cmd)
 			return -EPERM;
=20
 		spin_lock_bh(&br->lock);
-		br->bridge_forward_delay =3D clock_t_to_jiffies(args[1]);
-		if (br_is_root_bridge(br))
-			br->forward_delay =3D br->bridge_forward_delay;
+		rval =3D set_forward_delay (br, args[1]);
 		spin_unlock_bh(&br->lock);
-		return 0;
+		return rval;
=20
 	case BRCTL_SET_BRIDGE_HELLO_TIME:
 	{
-		unsigned long t =3D clock_t_to_jiffies(args[1]);
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
=20
-		if (t < HZ)
-			return -EINVAL;
-
 		spin_lock_bh(&br->lock);
-		br->bridge_hello_time =3D t;
-		if (br_is_root_bridge(br))
-			br->hello_time =3D br->bridge_hello_time;
+		rval =3D set_hello_time (br, args[1]);
 		spin_unlock_bh(&br->lock);
-		return 0;
+		return rval;
 	}
=20
 	case BRCTL_SET_BRIDGE_MAX_AGE:
@@ -210,18 +203,18 @@ static int old_dev_ioctl(struct net_device *dev, =
struct ifreq *rq, int cmd)
 			return -EPERM;
=20
 		spin_lock_bh(&br->lock);
-		br->bridge_max_age =3D clock_t_to_jiffies(args[1]);
-		if (br_is_root_bridge(br))
-			br->max_age =3D br->bridge_max_age;
+		rval =3D set_max_age (br, args[1]);
 		spin_unlock_bh(&br->lock);
-		return 0;
+		return rval;
=20
 	case BRCTL_SET_AGEING_TIME:
 		if (!capable(CAP_NET_ADMIN))
 			return -EPERM;
=20
-		br->ageing_time =3D clock_t_to_jiffies(args[1]);
-		return 0;
+		spin_lock_bh(&br->lock);
+		rval =3D set_ageing_time (br, args[1]);
+		spin_unlock_bh(&br->lock);
+		return rval;
=20
 	case BRCTL_GET_PORT_INFO:
 	{
@@ -268,9 +261,9 @@ static int old_dev_ioctl(struct net_device *dev, st=
ruct ifreq *rq, int cmd)
 			return -EPERM;
=20
 		spin_lock_bh(&br->lock);
-		br_stp_set_bridge_priority(br, args[1]);
+		rval =3D set_priority (br, args[1]);
 		spin_unlock_bh(&br->lock);
-		return 0;
+		return rval;
=20
 	case BRCTL_SET_PORT_PRIORITY:
 	{
@@ -303,7 +296,7 @@ static int old_dev_ioctl(struct net_device *dev, st=
ruct ifreq *rq, int cmd)
 		if ((p =3D br_get_port(br, args[1])) =3D=3D NULL)
 			ret =3D -EINVAL;
 		else
-			br_stp_set_path_cost(p, args[2]);
+			ret =3D br_stp_set_path_cost(p, args[2]);
=20
 		return ret;
 	}
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 19e2f46..87dd054 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -503,7 +503,7 @@ extern void br_stp_set_bridge_priority(struct net_b=
ridge *br,
 				       u16 newprio);
 extern void br_stp_set_port_priority(struct net_bridge_port *p,
 				     u8 newprio);
-extern void br_stp_set_path_cost(struct net_bridge_port *p,
+extern int br_stp_set_path_cost(struct net_bridge_port *p,
 				 u32 path_cost);
 extern ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id=
);
=20
@@ -536,6 +536,11 @@ extern int br_sysfs_renameif(struct net_bridge_por=
t *p);
 /* br_sysfs_br.c */
 extern int br_sysfs_addbr(struct net_device *dev);
 extern void br_sysfs_delbr(struct net_device *dev);
+extern int set_forward_delay(struct net_bridge *br, unsigned long val)=
;
+extern int set_max_age(struct net_bridge *br, unsigned long val);
+extern int set_hello_time(struct net_bridge *br, unsigned long val);
+extern int set_priority(struct net_bridge *br, unsigned long val);
+extern int set_ageing_time(struct net_bridge *br, unsigned long val);
=20
 #else
=20
diff --git a/net/bridge/br_stp_if.c b/net/bridge/br_stp_if.c
index 79372d4..6b9923c 100644
--- a/net/bridge/br_stp_if.c
+++ b/net/bridge/br_stp_if.c
@@ -269,11 +269,16 @@ void br_stp_set_port_priority(struct net_bridge_p=
ort *p, u8 newprio)
 }
=20
 /* called under bridge lock */
-void br_stp_set_path_cost(struct net_bridge_port *p, u32 path_cost)
+int br_stp_set_path_cost(struct net_bridge_port *p, u32 path_cost)
 {
+	if (path_cost < BR_MIN_PATH_COST &&
+	    path_cost > BR_MAX_PATH_COST)
+		return -ERANGE;
+
 	p->path_cost =3D path_cost;
 	br_configuration_update(p->br);
 	br_port_state_selection(p->br);
+	return 0;
 }
=20
 ssize_t br_show_bridge_id(char *buf, const struct bridge_id *id)
diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 5c1e555..31a09c5 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -57,12 +57,25 @@ static ssize_t show_forward_delay(struct device *d,
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->forward_delay));
 }
=20
-static int set_forward_delay(struct net_bridge *br, unsigned long val)
+int set_forward_delay(struct net_bridge *br, unsigned long val)
 {
-	unsigned long delay =3D clock_t_to_jiffies(val);
-	br->forward_delay =3D delay;
+	unsigned long fwd_dly =3D clock_t_to_jiffies(val) / HZ;
+	unsigned long max_age =3D br->max_age / HZ;
+
+	if ((fwd_dly < BR_MIN_FORWARD_DELAY) ||
+	    (fwd_dly > BR_MAX_FORWARD_DELAY))
+		return -ERANGE;
+
+	/*2 =C3=97 (Bridge_Forward_Delay =E2=80=93 1.0 seconds) >=3D Bridge_M=
ax_Age*/
+	if ((2 * (fwd_dly - 1) < (max_age))) {
+		return -EINVAL;
+	}
+
+	fwd_dly *=3D HZ;
+
+	br->forward_delay =3D fwd_dly;
 	if (br_is_root_bridge(br))
-		br->bridge_forward_delay =3D delay;
+		br->bridge_forward_delay =3D fwd_dly;
 	return 0;
 }
=20
@@ -82,16 +95,25 @@ static ssize_t show_hello_time(struct device *d, st=
ruct device_attribute *attr,
 		       jiffies_to_clock_t(to_bridge(d)->hello_time));
 }
=20
-static int set_hello_time(struct net_bridge *br, unsigned long val)
+int set_hello_time(struct net_bridge *br, unsigned long val)
 {
-	unsigned long t =3D clock_t_to_jiffies(val);
+	unsigned long hello_time =3D clock_t_to_jiffies(val) / HZ;
+	unsigned long max_age =3D br->max_age / HZ;
+
+	if ((hello_time < BR_MIN_HELLO_TIME) ||
+   	    (hello_time > BR_MAX_HELLO_TIME))
+		return -ERANGE;
=20
-	if (t < HZ)
+	/*Bridge_Max_Age >=3D 2 =C3=97 (Bridge_Hello_Time + 1.0 seconds)*/
+
+	if (max_age < ( 2 * (hello_time + 1)))
 		return -EINVAL;
=20
-	br->hello_time =3D t;
+	hello_time *=3D HZ;
+
+	br->hello_time =3D hello_time;
 	if (br_is_root_bridge(br))
-		br->bridge_hello_time =3D t;
+		br->bridge_hello_time =3D hello_time;
 	return 0;
 }
=20
@@ -111,12 +133,31 @@ static ssize_t show_max_age(struct device *d, str=
uct device_attribute *attr,
 		       jiffies_to_clock_t(to_bridge(d)->max_age));
 }
=20
-static int set_max_age(struct net_bridge *br, unsigned long val)
+int set_max_age(struct net_bridge *br, unsigned long val)
 {
-	unsigned long t =3D clock_t_to_jiffies(val);
-	br->max_age =3D t;
+	unsigned long max_age =3D clock_t_to_jiffies(val) / HZ;
+	unsigned long hello_time =3D br->hello_time / HZ;
+	unsigned long fwd_dly =3D br->forward_delay / HZ;
+
+	if ((max_age < BR_MIN_MAX_AGE) ||
+	    (max_age > BR_MAX_MAX_AGE))=20
+		return -ERANGE;
+
+	/* To support interoperability with legacy Bridges,=20
+   	   a Bridge shall enforce the following relationships
+  	   2 =C3=97 (Bridge_Forward_Delay =E2=80=93 1.0 seconds) >=3D Bridg=
e_Max_Age
+	   Bridge_Max_Age >=3D 2 =C3=97 (Bridge_Hello_Time + 1.0 seconds)
+	*/
+
+       if ((max_age < ( 2 * (hello_time + 1))) ||=20
+	   (2 * (fwd_dly - 1) < (max_age)))
+                return -EINVAL;
+
+	max_age *=3D HZ;
+
+	br->max_age =3D max_age;
 	if (br_is_root_bridge(br))
-		br->bridge_max_age =3D t;
+		br->bridge_max_age =3D max_age;
 	return 0;
 }
=20
@@ -134,9 +175,15 @@ static ssize_t show_ageing_time(struct device *d,
 	return sprintf(buf, "%lu\n", jiffies_to_clock_t(br->ageing_time));
 }
=20
-static int set_ageing_time(struct net_bridge *br, unsigned long val)
+int set_ageing_time(struct net_bridge *br, unsigned long val)
 {
-	br->ageing_time =3D clock_t_to_jiffies(val);
+	val =3D clock_t_to_jiffies(val) / HZ;
+
+	if (val < BR_MIN_AGEING_TIME ||
+	    val > BR_MAX_AGEING_TIME)
+		return -ERANGE;
+
+	br->ageing_time =3D val * HZ;
 	return 0;
 }
=20
@@ -190,8 +237,12 @@ static ssize_t show_priority(struct device *d, str=
uct device_attribute *attr,
 		       (br->bridge_id.prio[0] << 8) | br->bridge_id.prio[1]);
 }
=20
-static int set_priority(struct net_bridge *br, unsigned long val)
+int set_priority(struct net_bridge *br, unsigned long val)
 {
+	if ((val < BR_MIN_BRIDGE_PRIORITY) ||
+	    (val > BR_MAX_BRIDGE_PRIORITY))=20
+		return -ERANGE;
+
 	br_stp_set_bridge_priority(br, (u16) val);
 	return 0;
 }
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index fd5799c..6bd4520 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -40,8 +40,7 @@ static ssize_t show_path_cost(struct net_bridge_port =
*p, char *buf)
 }
 static ssize_t store_path_cost(struct net_bridge_port *p, unsigned lon=
g v)
 {
-	br_stp_set_path_cost(p, v);
-	return 0;
+	return br_stp_set_path_cost(p, v);
 }
 static BRPORT_ATTR(path_cost, S_IRUGO | S_IWUSR,
 		   show_path_cost, store_path_cost);
--=20
1.7.3.4

