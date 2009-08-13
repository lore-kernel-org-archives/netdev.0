From: "Fischer, Anna" <anna.fischer@hp.com>
Subject: [PATCH] net/bridge: Add 'hairpin' port forwarding mode
Date: Thu, 13 Aug 2009 16:55:16 +0000
Message-ID: <0199E0D51A61344794750DC57738F58E6D6B0C70D9@GVW1118EXC.americas.hpqcorp.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: Stephen Hemminger <shemminger@linux-foundation.org>,
	"Paul Congdon (UC Davis)" <ptcongdon@ucdavis.edu>,
	"evb@yahoogroups.com" <evb@yahoogroups.com>,
	"bridge@lists.linux-foundation.org"
	<bridge@lists.linux-foundation.org>,
	"davem@davemloft.net" <davem@davemloft.net>,
	"virtualization@lists.linux-foundation.org"
	<virtualization@lists.linux-foundation.org>,
	"kaber@trash.net" <kaber@trash.net>, Arnd Bergmann <arnd@arndb.de>,
	"Dickson, Mike (ISS Software)" <mike.dickson@hp.com>,
	"adobriyan@gmail.com" <adobriyan@gmail.com>,
	"bridge@osdl.org" <bridge@osdl.org>
To: "linux-kernel@vger.kernel.org" <linux-kernel@vger.kernel.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <linux-kernel-owner+glk-linux-kernel-3=40m.gmane.org-S1755006AbZHMQzb@vger.kernel.org>
Content-Language: en-US
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

This patch adds a 'hairpin' (also called 'reflective relay') mode
port configuration to the Linux Ethernet bridge kernel module.
A bridge supporting hairpin forwarding mode can send frames back
out through the port the frame was received on.

Hairpin mode is required to support basic VEPA (Virtual
Ethernet Port Aggregator) capabilities.

You can find additional information on VEPA here:
http://tech.groups.yahoo.com/group/evb/
http://www.ieee802.org/1/files/public/docs2009/new-hudson-vepa_seminar-20090514d.pdf
http://www.internet2.edu/presentations/jt2009jul/20090719-congdon.pdf

An additional patch 'bridge-utils: Add 'hairpin' port forwarding mode'
is provided to allow configuring hairpin mode from userspace tools.

Signed-off-by: Paul Congdon <paul.congdon@hp.com>
Signed-off-by: Anna Fischer <anna.fischer@hp.com>

---

 net/bridge/br_forward.c  |    3 ++-
 net/bridge/br_if.c       |    1 +
 net/bridge/br_private.h  |    3 +++
 net/bridge/br_sysfs_if.c |   17 +++++++++++++++++
 4 files changed, 23 insertions(+), 1 deletions(-)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index d2c27c8..bc1704a 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -22,7 +22,8 @@
 static inline int should_deliver(const struct net_bridge_port *p,
 				 const struct sk_buff *skb)
 {
-	return (skb->dev != p->dev && p->state == BR_STATE_FORWARDING);
+	return (((p->flags & BR_HAIRPIN_MODE) || skb->dev != p->dev) &&
+		p->state == BR_STATE_FORWARDING);
 }
 
 static inline unsigned packet_length(const struct sk_buff *skb)
diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index eb404dc..e486f1f 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -256,6 +256,7 @@ static struct net_bridge_port *new_nbp(struct net_bridge *br,
 	p->path_cost = port_cost(dev);
 	p->priority = 0x8000 >> BR_PORT_BITS;
 	p->port_no = index;
+	p->flags = 0;
 	br_init_port(p);
 	p->state = BR_STATE_DISABLED;
 	br_stp_port_timer_init(p);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index d5b5537..8319247 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -81,6 +81,9 @@ struct net_bridge_port
 	struct timer_list		message_age_timer;
 	struct kobject			kobj;
 	struct rcu_head			rcu;
+
+	unsigned long 			flags;
+#define BR_HAIRPIN_MODE		0x00000001
 };
 
 struct net_bridge
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 4a3cdf8..820643a 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -143,6 +143,22 @@ static ssize_t store_flush(struct net_bridge_port *p, unsigned long v)
 }
 static BRPORT_ATTR(flush, S_IWUSR, NULL, store_flush);
 
+static ssize_t show_hairpin_mode(struct net_bridge_port *p, char *buf)
+{
+	int hairpin_mode = (p->flags & BR_HAIRPIN_MODE) ? 1 : 0;
+	return sprintf(buf, "%d\n", hairpin_mode);
+}
+static ssize_t store_hairpin_mode(struct net_bridge_port *p, unsigned long v)
+{
+	if (v)
+		p->flags |= BR_HAIRPIN_MODE;
+	else
+		p->flags &= ~BR_HAIRPIN_MODE;
+	return 0;
+}
+static BRPORT_ATTR(hairpin_mode, S_IRUGO | S_IWUSR,
+		   show_hairpin_mode, store_hairpin_mode);
+
 static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_path_cost,
 	&brport_attr_priority,
@@ -159,6 +175,7 @@ static struct brport_attribute *brport_attrs[] = {
 	&brport_attr_forward_delay_timer,
 	&brport_attr_hold_timer,
 	&brport_attr_flush,
+	&brport_attr_hairpin_mode,
 	NULL
 };
