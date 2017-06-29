From: Simon Horman <simon.horman@netronome.com>
Subject: [PATCH net-next v3 2/9] nfp: add phys_switch_id support
Date: Thu, 29 Jun 2017 22:08:12 +0200
Message-ID: <1498766899-30707-3-git-send-email-simon.horman@netronome.com>
References: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Cc: netdev@vger.kernel.org, oss-drivers@netronome.com,
        Or Gerlitz <gerlitz.or@gmail.com>,
        Pieter Jansen van Vuuren
        <pieter.jansenvanvuuren@netronome.com>,
        Simon Horman <simon.horman@netronome.com>
To: David Miller <davem@davemloft.net>,
        Jakub Kicinski <jakub.kicinski@netronome.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qt0-f182.google.com ([209.85.216.182]:34406 "EHLO
        mail-qt0-f182.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751875AbdF2UIv (ORCPT
        <rfc822;netdev@vger.kernel.org>); Thu, 29 Jun 2017 16:08:51 -0400
Received: by mail-qt0-f182.google.com with SMTP id 32so83763910qtv.1
        for <netdev@vger.kernel.org>; Thu, 29 Jun 2017 13:08:46 -0700 (PDT)
In-Reply-To: <1498766899-30707-1-git-send-email-simon.horman@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Add phys_switch_id support by allowing lookup of
SWITCHDEV_ATTR_ID_PORT_PARENT_ID via the nfp_repr_port_attr_get
switchdev operation.

This is visible to user-space in the phys_switch_id attribute
of a netdev.

e.g.

cd /sys/devices/pci0000:00/0000:00:01.0/0000:01:00.0
find . -name phys_switch_id | xargs grep .
./net/eth3/phys_switch_id:00154d1300bd
./net/eth4/phys_switch_id:00154d1300bd
./net/eth2/phys_switch_id:00154d1300bd
grep: ./net/eth5/phys_switch_id: Operation not supported

In the above eth2 and eth3 and representor netdevs for the first and second
physical port. eth4 is the representor for the PF. And eth5 is the PF netdev.

Signed-off-by: Simon Horman <simon.horman@netronome.com>
Reviewed-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 .../net/ethernet/netronome/nfp/nfp_net_common.c    |  3 +++
 drivers/net/ethernet/netronome/nfp/nfp_net_repr.c  |  2 ++
 drivers/net/ethernet/netronome/nfp/nfp_port.c      | 29 ++++++++++++++++++++++
 drivers/net/ethernet/netronome/nfp/nfp_port.h      |  2 ++
 4 files changed, 36 insertions(+)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 2e728543e840..b5834525c5f0 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -64,6 +64,7 @@
 #include <linux/vmalloc.h>
 #include <linux/ktime.h>
 
+#include <net/switchdev.h>
 #include <net/vxlan.h>
 
 #include "nfpcore/nfp_nsp.h"
@@ -3703,6 +3704,8 @@ static void nfp_net_netdev_init(struct nfp_net *nn)
 	netdev->netdev_ops = &nfp_net_netdev_ops;
 	netdev->watchdog_timeo = msecs_to_jiffies(5 * 1000);
 
+	SWITCHDEV_SET_OPS(netdev, &nfp_port_switchdev_ops);
+
 	/* MTU range: 68 - hw-specific max */
 	netdev->min_mtu = ETH_MIN_MTU;
 	netdev->max_mtu = nn->max_mtu;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
index 046b89eb4cf2..bc9108071e5b 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_repr.c
@@ -35,6 +35,7 @@
 #include <linux/io-64-nonatomic-hi-lo.h>
 #include <linux/lockdep.h>
 #include <net/dst_metadata.h>
+#include <net/switchdev.h>
 
 #include "nfpcore/nfp_cpp.h"
 #include "nfpcore/nfp_nsp.h"
@@ -299,6 +300,7 @@ int nfp_repr_init(struct nfp_app *app, struct net_device *netdev,
 	repr->dst->u.port_info.lower_dev = pf_netdev;
 
 	netdev->netdev_ops = &nfp_repr_netdev_ops;
+	SWITCHDEV_SET_OPS(netdev, &nfp_port_switchdev_ops);
 
 	err = register_netdev(netdev);
 	if (err)
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.c b/drivers/net/ethernet/netronome/nfp/nfp_port.c
index 0b44952945d8..3aa834fb2250 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.c
@@ -32,6 +32,7 @@
  */
 
 #include <linux/lockdep.h>
+#include <net/switchdev.h>
 
 #include "nfpcore/nfp_cpp.h"
 #include "nfpcore/nfp_nsp.h"
@@ -59,6 +60,34 @@ struct nfp_port *nfp_port_from_netdev(struct net_device *netdev)
 	return NULL;
 }
 
+static int
+nfp_port_attr_get(struct net_device *netdev, struct switchdev_attr *attr)
+{
+	struct nfp_port *port;
+
+	port = nfp_port_from_netdev(netdev);
+	if (!port)
+		return -EOPNOTSUPP;
+
+	switch (attr->id) {
+	case SWITCHDEV_ATTR_ID_PORT_PARENT_ID: {
+		const u8 *serial;
+		/* N.B: attr->u.ppid.id is binary data */
+		attr->u.ppid.id_len = nfp_cpp_serial(port->app->cpp, &serial);
+		memcpy(&attr->u.ppid.id, serial, attr->u.ppid.id_len);
+		break;
+	}
+	default:
+		return -EOPNOTSUPP;
+	}
+
+	return 0;
+}
+
+const struct switchdev_ops nfp_port_switchdev_ops = {
+	.switchdev_port_attr_get	= nfp_port_attr_get,
+};
+
 struct nfp_port *
 nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id)
 {
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_port.h b/drivers/net/ethernet/netronome/nfp/nfp_port.h
index 57d852a4ca59..1ceef5d4a744 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_port.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_port.h
@@ -106,6 +106,8 @@ struct nfp_port {
 	struct list_head port_list;
 };
 
+extern const struct switchdev_ops nfp_port_switchdev_ops;
+
 struct nfp_port *nfp_port_from_netdev(struct net_device *netdev);
 struct nfp_port *
 nfp_port_from_id(struct nfp_pf *pf, enum nfp_port_type type, unsigned int id);
-- 
2.1.4
