From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH v2] Net-ethtool : Allow ethtool to set interface in loopback mode.
Date: Tue, 30 Nov 2010 15:57:07 -0800
Message-ID: <AANLkTimJJzQ6f06CoWJuofwS0m2Bn3gAcfWTOEiYyjEZ@mail.gmail.com>
References: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
	<1291129305.21077.9.camel@bwh-desktop>
	<AANLkTikM4=yOu9L7h0FZUkmMNG-LVdGsdSLOLJmw2+UW@mail.gmail.com>
	<1291144507.21077.56.camel@bwh-desktop>
	<AANLkTik=YkC6w3d2ViOqH5AYcxfRB6eKx3Mk_6=aKXGH@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Cc: laurent chavey <chavey@google.com>,
	Ben Hutchings <bhutchings@solarflare.com>
To: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:41601 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751366Ab0LAAC1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 19:02:27 -0500
Received: from kpbe15.cbf.corp.google.com (kpbe15.cbf.corp.google.com [172.25.105.79])
	by smtp-out.google.com with ESMTP id oB102Qtc004782
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 16:02:26 -0800
Received: from bwz17 (bwz17.prod.google.com [10.188.26.17])
	by kpbe15.cbf.corp.google.com with ESMTP id oB1024ix017998
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 16:02:25 -0800
Received: by bwz17 with SMTP id 17so7491476bwz.37
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 16:02:24 -0800 (PST)
In-Reply-To: <AANLkTik=YkC6w3d2ViOqH5AYcxfRB6eKx3Mk_6=aKXGH@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables ethtool to set the loopback mode on a given
interface. By configuring the interface in loopback mode in conjunction
with a policy route / rule, a userland application can stress the egress /
ingress path exposing the flows of the change in progress and potentially
help developer(s) understand the impact of those changes without even
sending a packet out on the network.

Following set of commands illustrates one such example -
    a) ip -4 addr add 192.168.1.1/24 dev eth1
    b) ip -4 rule add from all iif eth1 lookup 250
    c) ip -4 route add local 0/0 dev lo proto kernel scope host table 250
    d) arp -Ds 192.168.1.100 eth1
    e) arp -Ds 192.168.1.200 eth1
    f) sysctl -w net.ipv4.ip_nonlocal_bind=1
    g) sysctl -w net.ipv4.conf.all.accept_local=1
    # Assuming that the machine has 8 cores
    h) taskset 000f netserver -L 192.168.1.200
    i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.168.1.200 -l 30

Signed-off-by: Mahesh Bandewar <maheshb@google.com>

 include/linux/ethtool.h |   15 +++++++++++++++
 net/core/ethtool.c      |   39 +++++++++++++++++++++++++++++++++++++++
 2 files changed, 54 insertions(+), 0 deletions(-)

---
diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6628a50..a7fb1f5 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -616,6 +616,17 @@ void ethtool_ntuple_flush(struct net_device *dev);
  *     Should validate the magic field.  Don't need to check len for zero
  *     or wraparound.  Update len to the amount written.  Returns an error
  *     or zero.
+ *
+ * get_loopback:
+ * set_loopback:
+    These are the driver specific get / set methods to report / enable-
+       disable loopback mode. The idea is to stress test the ingress / egress
+       paths by enabling this mode. There are multiple places this could be
+       done and choice of place will most likely be affected by the device
+       capabilities. So as a guiding principle; select a place to implement
+       loopback mode as close to the host as possible. This would maximize the
+       soft-path length and maintain parity in terms of comparison with differe
+       set of drivers.
  */
 struct ethtool_ops {
        int     (*get_settings)(struct net_device *, struct ethtool_cmd *);
@@ -678,6 +689,8 @@ struct ethtool_ops {
                                  struct ethtool_rxfh_indir *);
        int     (*set_rxfh_indir)(struct net_device *,
                                  const struct ethtool_rxfh_indir *);
+       int     (*get_loopback)(struct net_device *, u32 *);
+       int     (*set_loopback)(struct net_device *, u32);
 };
 #endif /* __KERNEL__ */

@@ -741,6 +754,8 @@ struct ethtool_ops {
 #define ETHTOOL_GSSET_INFO     0x00000037 /* Get string set info */
 #define ETHTOOL_GRXFHINDIR     0x00000038 /* Get RX flow hash indir'n table */
 #define ETHTOOL_SRXFHINDIR     0x00000039 /* Set RX flow hash indir'n table */
+#define ETHTOOL_SLOOPBACK      0x0000003a /* Enable / Disable Loopback */
+#define ETHTOOL_GLOOPBACK      0x0000003b /* Get Loopback status */

 /* compatibility with older code */
 #define SPARC_ETH_GSET         ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 956a9f4..5c87c93 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1434,6 +1434,39 @@ static noinline_for_stack int ethtool_flash_device(struct
        return dev->ethtool_ops->flash_device(dev, &efl);
 }

+static int ethtool_set_loopback(struct net_device *dev, void __user *useraddr)
+{
+       struct ethtool_value edata;
+       const struct ethtool_ops *ops = dev->ethtool_ops;
+
+       if (!ops || !ops->set_loopback)
+               return -EOPNOTSUPP;
+
+       if (copy_from_user(&edata, useraddr, sizeof(edata)))
+               return -EFAULT;
+
+       return ops->set_loopback(dev, edata.data);
+}
+
+static int ethtool_get_loopback(struct net_device *dev, void __user *useraddr)
+{
+       struct ethtool_value edata;
+       const struct ethtool_ops *ops = dev->ethtool_ops;
+       int err;
+
+       if (!ops || !ops->get_loopback)
+               return -EOPNOTSUPP;
+
+       err = ops->get_loopback(dev, &edata.data);
+       if (err)
+               return (err);
+
+       if (copy_to_user(useraddr, &edata, sizeof(edata)))
+               return -EFAULT;
+
+       return 0;
+}
+
 /* The main entry point in this file.  Called from net/core/dev.c */

 int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1678,6 +1711,12 @@ int dev_ethtool(struct net *net, struct ifreq *ifr)
        case ETHTOOL_SRXFHINDIR:
                rc = ethtool_set_rxfh_indir(dev, useraddr);
                break;
+       case ETHTOOL_SLOOPBACK:
+               rc = ethtool_set_loopback(dev, useraddr);
+               break;
+       case ETHTOOL_GLOOPBACK:
+               rc = ethtool_get_loopback(dev, useraddr);
+               break;
        default:
                rc = -EOPNOTSUPP;
        }
