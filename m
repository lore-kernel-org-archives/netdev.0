From: Mahesh Bandewar <maheshb@google.com>
Subject: [PATCH] Net-ethtool : Allow ethtool to set interface in loopback mode.
Date: Tue, 30 Nov 2010 00:00:29 -0800
Message-ID: <AANLkTikVaVv4fkLom+NSQgOUzCd2i3mbHkBNQ6PD4d9Y@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: David Miller <davem@davemloft.net>,
	linux-netdev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp-out.google.com ([216.239.44.51]:1889 "EHLO
	smtp-out.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753480Ab0K3IAc convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 30 Nov 2010 03:00:32 -0500
Received: from hpaq13.eem.corp.google.com (hpaq13.eem.corp.google.com [172.25.149.13])
	by smtp-out.google.com with ESMTP id oAU80U8q009477
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 00:00:31 -0800
Received: from bwz4 (bwz4.prod.google.com [10.188.26.4])
	by hpaq13.eem.corp.google.com with ESMTP id oAU7xpdH025209
	for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 00:00:30 -0800
Received: by bwz4 with SMTP id 4so4710451bwz.11
        for <netdev@vger.kernel.org>; Tue, 30 Nov 2010 00:00:29 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch enables ethtool to set the loopback mode on a given
interface. This is the reworked version of earlier submit (which I
don't have reference to). By configuring the interface in loopback
mode in conjunction with a policy route / rule, a userland application
can stress the egress / ingress path exposing the flows of the change
in progress and potentially help developer(s) understand the impact of
those changes without even sending a packet out on the network.

=46ollowing set of commands illustrates one such example -
=A0=A0 =A0a)=A0ifconfig eth1 192.168.1.1
=A0=A0 =A0b)=A0ip -4 rule add from all iif eth1 lookup 250
=A0=A0 =A0c)=A0ip -4 route add local 0/0 dev lo proto kernel scope host=
 table 250
=A0=A0 =A0d) arp -Ds 192.168.1.100 eth1
=A0=A0 =A0e)=A0arp -Ds 192.168.1.200 eth1
=A0=A0 =A0f)=A0sysctl -w net.ipv4.ip_nonlocal_bind=3D1
=A0=A0 =A0g)=A0sysctl -w net.ipv4.conf.all.accept_local=3D1
=A0=A0 =A0# Assuming that the machine has 8 cores
=A0=A0 =A0h) taskset 000f netserver -L 192.168.1.200
=A0=A0 =A0i) taskset 00f0 netperf -t TCP_CRR -L 192.168.1.100 -H 192.16=
8.1.200 -l 30

Signed-off-by: Mahesh Bandewar <maheshb@google.com>
---
=A0include/linux/ethtool.h | =A0 =A04 ++++
=A0net/core/ethtool.c =A0 =A0 =A0| =A0 39 +++++++++++++++++++++++++++++=
++++++++++
=A02 files changed, 43 insertions(+), 0 deletions(-)

diff --git a/include/linux/ethtool.h b/include/linux/ethtool.h
index 6628a50..7523d45 100644
--- a/include/linux/ethtool.h
+++ b/include/linux/ethtool.h
@@ -678,6 +678,8 @@ struct ethtool_ops {
=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0s=
truct ethtool_rxfh_indir *);
=A0=A0 =A0 =A0 =A0int =A0 =A0 (*set_rxfh_indir)(struct net_device *,
=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0c=
onst struct ethtool_rxfh_indir *);
+ =A0 =A0 =A0 int =A0 =A0 (*get_loopback)(struct net_device *, u32 *);
+ =A0 =A0 =A0 int =A0 =A0 (*set_loopback)(struct net_device *, u32);
=A0};
=A0#endif /* __KERNEL__ */

@@ -741,6 +743,8 @@ struct ethtool_ops {
=A0#define ETHTOOL_GSSET_INFO =A0 =A0 0x00000037 /* Get string set info=
 */
=A0#define ETHTOOL_GRXFHINDIR =A0 =A0 0x00000038 /* Get RX flow hash in=
dir'n table */
=A0#define ETHTOOL_SRXFHINDIR =A0 =A0 0x00000039 /* Set RX flow hash in=
dir'n table */
+#define ETHTOOL_SLOOPBACK =A0 =A0 =A00x0000003a /* Enable / Disable Lo=
opback */
+#define ETHTOOL_GLOOPBACK =A0 =A0 =A00x0000003b /* Get Loopback status=
 */

=A0/* compatibility with older code */
=A0#define SPARC_ETH_GSET =A0 =A0 =A0 =A0 ETHTOOL_GSET
diff --git a/net/core/ethtool.c b/net/core/ethtool.c
index 956a9f4..5c87c93 100644
--- a/net/core/ethtool.c
+++ b/net/core/ethtool.c
@@ -1434,6 +1434,39 @@ static noinline_for_stack int ethtool_flash_devi=
ce(struct
=A0=A0 =A0 =A0 =A0return dev->ethtool_ops->flash_device(dev, &efl);
=A0}

+static int ethtool_set_loopback(struct net_device *dev, void __user *u=
seraddr)
+{
+ =A0 =A0 =A0 struct ethtool_value edata;
+ =A0 =A0 =A0 const struct ethtool_ops *ops =3D dev->ethtool_ops;
+
+ =A0 =A0 =A0 if (!ops || !ops->set_loopback)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
+
+ =A0 =A0 =A0 if (copy_from_user(&edata, useraddr, sizeof(edata)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
+
+ =A0 =A0 =A0 return ops->set_loopback(dev, edata.data);
+}
+
+static int ethtool_get_loopback(struct net_device *dev, void __user *u=
seraddr)
+{
+ =A0 =A0 =A0 struct ethtool_value edata;
+ =A0 =A0 =A0 const struct ethtool_ops *ops =3D dev->ethtool_ops;
+ =A0 =A0 =A0 int err;
+
+ =A0 =A0 =A0 if (!ops || !ops->get_loopback)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EOPNOTSUPP;
+
+ =A0 =A0 =A0 err =3D ops->get_loopback(dev, &edata.data);
+ =A0 =A0 =A0 if (err)
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return (err);
+
+ =A0 =A0 =A0 if (copy_to_user(useraddr, &edata, sizeof(edata)))
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 return -EFAULT;
+
+ =A0 =A0 =A0 return 0;
+}
+
=A0/* The main entry point in this file. =A0Called from net/core/dev.c =
*/

=A0int dev_ethtool(struct net *net, struct ifreq *ifr)
@@ -1678,6 +1711,12 @@ int dev_ethtool(struct net *net, struct ifreq *i=
fr)
=A0=A0 =A0 =A0 =A0case ETHTOOL_SRXFHINDIR:
=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D ethtool_set_rxfh_indir(dev, us=
eraddr);
=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0break;
+ =A0 =A0 =A0 case ETHTOOL_SLOOPBACK:
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D ethtool_set_loopback(dev, useraddr=
);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
+ =A0 =A0 =A0 case ETHTOOL_GLOOPBACK:
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 rc =3D ethtool_get_loopback(dev, useraddr=
);
+ =A0 =A0 =A0 =A0 =A0 =A0 =A0 break;
=A0=A0 =A0 =A0 =A0default:
=A0=A0 =A0 =A0 =A0 =A0 =A0 =A0 =A0rc =3D -EOPNOTSUPP;
=A0=A0 =A0 =A0 =A0}
