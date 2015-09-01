From: Ahmed Amamou <ahmed@gandi.net>
Subject: [PATCH RFC v2 07/21] net: rbridge: add sysfs for trill_state
Date: Tue,  1 Sep 2015 17:43:02 +0200
Message-ID: <1441122196-11662-8-git-send-email-ahmed@gandi.net>
References: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Cc: William Dauchy <william@gandi.net>, Ahmed Amamou <ahmed@gandi.net>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail4.gandi.net ([217.70.183.210]:55328 "EHLO gandi.net"
	rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
	id S1752953AbbIAPxn (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 1 Sep 2015 11:53:43 -0400
In-Reply-To: <1441122196-11662-1-git-send-email-ahmed@gandi.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

in order to activate trill port without need for brctl
add a sysfs for trill_state for net_bridge_port

Signed-off-by: Ahmed Amamou <ahmed@gandi.net>
Signed-off-by: William Dauchy <william@gandi.net>
---
 net/bridge/br_sysfs_br.c | 38 ++++++++++++++++++++++++++++++++++++++
 net/bridge/br_sysfs_if.c | 26 ++++++++++++++++++++++++++
 2 files changed, 64 insertions(+)

diff --git a/net/bridge/br_sysfs_br.c b/net/bridge/br_sysfs_br.c
index 4c97fc5..63820c1 100644
--- a/net/bridge/br_sysfs_br.c
+++ b/net/bridge/br_sysfs_br.c
@@ -146,6 +146,41 @@ static ssize_t stp_state_store(struct device *d,
 }
 static DEVICE_ATTR_RW(stp_state);
 
+#ifdef CONFIG_TRILL
+static ssize_t trill_state_show(struct device *d,
+				struct device_attribute *attr, char *buf)
+{
+	struct net_bridge *br = to_bridge(d);
+
+	return sprintf(buf, "%d\n", br->trill_enabled);
+}
+
+static ssize_t trill_state_store(struct device *d,
+				 struct device_attribute *attr, const char *buf,
+				 size_t len)
+{
+	struct net_bridge *br = to_bridge(d);
+	int err;
+	unsigned long val;
+
+	if (!ns_capable(dev_net(br->dev)->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+
+	err = kstrtoul(buf, 0, &val);
+	if (err)
+		return err;
+
+	if (!rtnl_trylock())
+		return restart_syscall();
+	br_trill_set_enabled(br, val);
+	rtnl_unlock();
+
+	return len;
+}
+
+static DEVICE_ATTR_RW(trill_state);
+#endif
+
 static ssize_t group_fwd_mask_show(struct device *d,
 				   struct device_attribute *attr,
 				   char *buf)
@@ -749,6 +784,9 @@ static struct attribute *bridge_attrs[] = {
 	&dev_attr_max_age.attr,
 	&dev_attr_ageing_time.attr,
 	&dev_attr_stp_state.attr,
+#ifdef CONFIG_TRILL
+	&dev_attr_trill_state.attr,
+#endif
 	&dev_attr_group_fwd_mask.attr,
 	&dev_attr_priority.attr,
 	&dev_attr_bridge_id.attr,
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index efe415a..174a705 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -137,6 +137,29 @@ static ssize_t show_port_state(struct net_bridge_port *p, char *buf)
 }
 static BRPORT_ATTR(state, S_IRUGO, show_port_state, NULL);
 
+#ifdef CONFIG_TRILL
+
+static ssize_t show_port_trill_state(struct net_bridge_port *p, char *buf)
+{
+	return sprintf(buf, "%d\n", p->trill_flag);
+}
+
+static int store_port_trill_state(struct net_bridge_port *p,  unsigned long v)
+{
+	u8 val;
+
+	if (!ns_capable(dev_net(p->dev)->user_ns, CAP_NET_ADMIN))
+		return -EPERM;
+	val = (u8)v;
+	if (val > TRILL_FLAG_TRUNK)
+		return -ERANGE;
+	p->trill_flag = val;
+	return 0;
+}
+static BRPORT_ATTR(trill_state, S_IRUGO | S_IWUSR, show_port_trill_state,
+				   store_port_trill_state);
+#endif
+
 static ssize_t show_message_age_timer(struct net_bridge_port *p,
 					    char *buf)
 {
@@ -200,6 +223,9 @@ static const struct brport_attribute *brport_attrs[] = {
 	&brport_attr_designated_port,
 	&brport_attr_designated_cost,
 	&brport_attr_state,
+#ifdef CONFIG_TRILL
+	&brport_attr_trill_state,
+#endif
 	&brport_attr_change_ack,
 	&brport_attr_config_pending,
 	&brport_attr_message_age_timer,
-- 
2.1.4
