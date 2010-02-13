From: David Lamparter <equinox@diac24.net>
Subject: [RFC]: IPv4 mroute interface referencing
Date: Sat, 13 Feb 2010 19:29:12 +0100
Message-ID: <1266085752.5539.76.camel@arkology.n2.diac24.net>
Mime-Version: 1.0
Content-Type: multipart/mixed; boundary="=-IDlUmiaXnfS37ewWPf2L"
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from spaceboyz.net ([87.106.131.203]:51765 "EHLO spaceboyz.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757586Ab0BMSyG (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sat, 13 Feb 2010 13:54:06 -0500
Received: from jupiter.n2.diac24.net ([2001:8d8:81:5c2:21b:fcff:fe4c:9e6f])
	by spaceboyz.net with esmtps (TLSv1:AES256-SHA:256)
	(Exim 4.69)
	(envelope-from <equinox@diac24.net>)
	id 1NgMk2-0005GP-92
	for netdev@vger.kernel.org; Sat, 13 Feb 2010 19:29:18 +0100
Received: from arkology.n2.diac24.net ([2001:8d8:81:5c2:219:dbff:feea:a8a8])
	by jupiter.n2.diac24.net with esmtps (TLSv1:CAMELLIA256-SHA:256)
	(Exim 4.71)
	(envelope-from <equinox@diac24.net>)
	id 1NgMjx-00060P-EE
	for netdev@vger.kernel.org; Sat, 13 Feb 2010 19:29:17 +0100
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


--=-IDlUmiaXnfS37ewWPf2L
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit

The attached patch introduces a new struct vifctln which is identical to
vifctl except for a new vifi_ifindex field. This allows creating mroute
vifs if you have multiple interfaces with the same IP (i.e.
"unnumbered", PtP interfaces) on your box.

Other ways to support this could be:
* new mroute API
  + it really needs an overhaul anyway
  + netlink would be more appropriate for mroute (IMHO)
  - complicated, non-immediate fix
  - complex user space software rewriting
* new MRT_ADD_VIF_EXT setsockopt
  + a bit more clean
  - not needed really, sockopt mess
* stuff ifindex in lcl_addr field ("0.0.0.ifindex IP")
  + no new struct field
  - idiotic (IMHO) API-monging
  o compatibility gain if BSD did this, but BSD doesn't, no point

* add ifindex field (attached patch does this)
  + compatibility by setsockopt length parameter
  + doesn't break userspace software (none of the existing multicast
    routers tries to pass excess junk)
  - new struct, new struct field

This patch causes userspace-visible changes, but is fully backwards
compatible. Patch is against 2.6.32.8, I will provide an updated one if
discussion is in favour of something I can code up (i.e. not netlink).

Regards,


David


--=-IDlUmiaXnfS37ewWPf2L
Content-Description: 
Content-Disposition: inline; filename*0=0001-ipmr-new-struct-vifctln-to-support-ifindex-for-MIF_A.pat; filename*1=ch
Content-Type: text/x-patch; name="0001-ipmr-new-struct-vifctln-to-support-ifindex-for-MIF_A.patch"; charset="UTF-8"
Content-Transfer-Encoding: 7bit

>From 93e78e1d65976643ea8de54cfbe46f5741f49a9d Mon Sep 17 00:00:00 2001
From: David Lamparter <equinox@diac24.net>
Date: Sat, 13 Feb 2010 19:19:22 +0100
Subject: [PATCH] ipmr: new struct vifctln to support ifindex for MIF_ADD_VIF

it isn't currently possible to do multicast routing if multiple
interfaces with the same IP address are present in a system, as only the
first of them can be selected for mroute VIF creation.

fix this by adding struct vifctln (analogous to struct mreqn) which has
a new int vifi_ifindex field. the setsockopt call differentiates vifctl
from vifctln through the length field; non-present or zero vifi_ifindex
keeps the old behaviour, nonzero vifi_ifindex causes vifi_lcladdr to be
ignored in favour of vifi_ifindex.

Signed-off-by: David Lamparter <equinox@diac24.net>
---
 include/linux/mroute.h |   14 ++++++++++++++
 net/ipv4/ipmr.c        |   19 +++++++++++++------
 2 files changed, 27 insertions(+), 6 deletions(-)

diff --git a/include/linux/mroute.h b/include/linux/mroute.h
index 08bc776..0ef73ce 100644
--- a/include/linux/mroute.h
+++ b/include/linux/mroute.h
@@ -63,6 +63,20 @@ struct vifctl {
 	struct in_addr vifc_rmt_addr;	/* IPIP tunnel addr */
 };
 
+/* Linux extension: reference VIF by ifindex.
+ * this struct MUST exactly retain the fields from vifctl for compatibility!
+ * vifc_ifindex is used if nonzero, otherwise fall back to old behaviour
+ */
+struct vifctln {
+	vifi_t	vifc_vifi;		/* Index of VIF */
+	unsigned char vifc_flags;	/* VIFF_ flags */
+	unsigned char vifc_threshold;	/* ttl limit */
+	unsigned int vifc_rate_limit;	/* Rate limiter values (NI) */
+	struct in_addr vifc_lcl_addr;	/* Our address */
+	struct in_addr vifc_rmt_addr;	/* IPIP tunnel addr */
+	int vifc_ifindex;		/* Index of real Interface */
+};
+
 #define VIFF_TUNNEL	0x1	/* IPIP tunnel */
 #define VIFF_SRCRT	0x2	/* NI */
 #define VIFF_REGISTER	0x4	/* register vif	*/
diff --git a/net/ipv4/ipmr.c b/net/ipv4/ipmr.c
index 99508d6..9d5d22e 100644
--- a/net/ipv4/ipmr.c
+++ b/net/ipv4/ipmr.c
@@ -23,6 +23,7 @@
  *      Carlos Picoto           :       PIMv1 Support
  *	Pavlin Ivanov Radoslavov:	PIMv2 Registers must checksum only PIM header
  *					Relax this requrement to work with older peers.
+ *	David Lamparter		:	struct vifctln introduced
  *
  */
 
@@ -135,7 +136,7 @@ static void ipmr_del_tunnel(struct net_device *dev, struct vifctl *v)
 }
 
 static
-struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
+struct net_device *ipmr_new_tunnel(struct net *net, struct vifctln *v)
 {
 	struct net_device  *dev;
 
@@ -149,6 +150,7 @@ struct net_device *ipmr_new_tunnel(struct net *net, struct vifctl *v)
 		struct in_device  *in_dev;
 
 		memset(&p, 0, sizeof(p));
+		p.link = v->vifc_ifindex;
 		p.iph.daddr = v->vifc_rmt_addr.s_addr;
 		p.iph.saddr = v->vifc_lcl_addr.s_addr;
 		p.iph.version = 4;
@@ -426,7 +428,7 @@ static void ipmr_update_thresholds(struct mfc_cache *cache, unsigned char *ttls)
 	}
 }
 
-static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
+static int vif_add(struct net *net, struct vifctln *vifc, int mrtsock)
 {
 	int vifi = vifc->vifc_vifi;
 	struct vif_device *v = &net->ipv4.vif_table[vifi];
@@ -470,7 +472,10 @@ static int vif_add(struct net *net, struct vifctl *vifc, int mrtsock)
 		}
 		break;
 	case 0:
-		dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
+		if (vifc->vifc_ifindex)
+			dev = dev_get_by_index(net, vifc->vifc_ifindex);
+		else
+			dev = ip_dev_find(net, vifc->vifc_lcl_addr.s_addr);
 		if (!dev)
 			return -EADDRNOTAVAIL;
 		err = dev_set_allmulti(dev, 1);
@@ -936,7 +941,7 @@ static void mrtsock_destruct(struct sock *sk)
 int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsigned int optlen)
 {
 	int ret;
-	struct vifctl vif;
+	struct vifctln vif;
 	struct mfcctl mfc;
 	struct net *net = sock_net(sk);
 
@@ -975,9 +980,11 @@ int ip_mroute_setsockopt(struct sock *sk, int optname, char __user *optval, unsi
 		return ip_ra_control(sk, 0, NULL);
 	case MRT_ADD_VIF:
 	case MRT_DEL_VIF:
-		if (optlen != sizeof(vif))
+		/* either vifctl or vifctln is fine; take what we get */
+		if (optlen != sizeof(vif) && optlen != sizeof(struct vifctl))
 			return -EINVAL;
-		if (copy_from_user(&vif, optval, sizeof(vif)))
+		vif.vifc_ifindex = 0;
+		if (copy_from_user(&vif, optval, optlen))
 			return -EFAULT;
 		if (vif.vifc_vifi >= MAXVIFS)
 			return -ENFILE;
-- 
1.6.5.2


--=-IDlUmiaXnfS37ewWPf2L--

