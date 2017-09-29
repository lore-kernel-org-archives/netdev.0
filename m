From: Stephen Hemminger <stephen@networkplumber.org>
Subject: Re: [PATCH net-next] net: bridge: add per-port group_fwd_mask with
 less restrictions
Date: Fri, 29 Sep 2017 14:51:03 -0700
Message-ID: <20170929145103.1e30f73c@xeon-e3>
References: <1506517964-17479-1-git-send-email-nikolay@cumulusnetworks.com>
        <20170929081420.3b069170@xeon-e3>
        <e9a70870-9b6b-0ec4-de1e-d41da80fd10f@cumulusnetworks.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=US-ASCII
Content-Transfer-Encoding: quoted-printable
Cc: netdev@vger.kernel.org, roopa@cumulusnetworks.com,
        bridge@lists.linux-foundation.org
To: Nikolay Aleksandrov <nikolay@cumulusnetworks.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pg0-f52.google.com ([74.125.83.52]:50551 "EHLO
        mail-pg0-f52.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752155AbdI2VvF (ORCPT
        <rfc822;netdev@vger.kernel.org>); Fri, 29 Sep 2017 17:51:05 -0400
Received: by mail-pg0-f52.google.com with SMTP id p5so452259pgn.7
        for <netdev@vger.kernel.org>; Fri, 29 Sep 2017 14:51:05 -0700 (PDT)
In-Reply-To: <e9a70870-9b6b-0ec4-de1e-d41da80fd10f@cumulusnetworks.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, 30 Sep 2017 00:01:24 +0300
Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:

> On 29/09/17 18:14, Stephen Hemminger wrote:
> > On Wed, 27 Sep 2017 16:12:44 +0300
> > Nikolay Aleksandrov <nikolay@cumulusnetworks.com> wrote:
> >  =20
> >> We need to be able to transparently forward most link-local frames via
> >> tunnels (e.g. vxlan, qinq). Currently the bridge's group_fwd_mask has a
> >> mask which restricts the forwarding of STP and LACP, but we need to be=
 able
> >> to forward these over tunnels and control that forwarding on a per-port
> >> basis thus add a new per-port group_fwd_mask option which only disallo=
ws
> >> mac pause frames to be forwarded (they're always dropped anyway).
> >> The patch does not change the current default situation - all of the o=
thers
> >> are still restricted unless configured for forwarding.
> >> We have successfully tested this patch with LACP and STP forwarding ov=
er
> >> VxLAN and qinq tunnels.
> >>
> >> Signed-off-by: Nikolay Aleksandrov <nikolay@cumulusnetworks.com> =20
> >=20
> > LACP is fine, but STP must not be forwarded if STP in user or kernel
> > mode is enabled.
> >=20
> > Please update this patch or revert it.
> >  =20
>=20
> The default has not changed, STP is still _not_ forwarded. It can be only=
 if explicitly
> requested by the user and that means the port might be participating in S=
TP but not
> the bridge's STP, that is explicitly forward all STP frames from that por=
t.
> I don't think we have to change anything.
>=20

You need to fail if user does something stupid. And DNR.

=46rom 16c42db4852234c13288922c1bffbf7650e08434 Mon Sep 17 00:00:00 2001
From: Stephen Hemminger <sthemmin@microsoft.com>
Date: Fri, 29 Sep 2017 14:48:17 -0700
Subject: [PATCH] bridge: check for attempt to forward STP PDU's with STP
 enabled

Move validation into set function and do not allow
configuring forwarding of STP packets if STP is enabled.

Fixes: 5af48b59f35c ("net: bridge: add per-port group_fwd_mask with less re=
strictions")
Signed-off-by: Stephen Hemminger <stephen@networkplumber.org>
---
 net/bridge/br_if.c       | 13 +++++++++++++
 net/bridge/br_netlink.c  |  6 +++---
 net/bridge/br_private.h  |  1 +
 net/bridge/br_sysfs_if.c |  6 +-----
 4 files changed, 18 insertions(+), 8 deletions(-)

diff --git a/net/bridge/br_if.c b/net/bridge/br_if.c
index f3aef22931ab..a30e12f76266 100644
--- a/net/bridge/br_if.c
+++ b/net/bridge/br_if.c
@@ -654,3 +654,16 @@ void br_port_flags_change(struct net_bridge_port *p, u=
nsigned long mask)
 	if (mask & BR_AUTO_MASK)
 		nbp_update_port_count(br);
 }
+
+int br_set_group_fwd_mask(struct net_bridge_port *p, u16 fwd_mask)
+{
+	if (fwd_mask & BR_GROUPFWD_MACPAUSE)
+		return -EINVAL;
+
+	if ((fwd_mask & BR_GROUPFWD_STP) &&
+	    (p->br->stp_enabled !=3D BR_NO_STP))
+		return -EINVAL;
+
+	p->group_fwd_mask =3D fwd_mask;
+	return 0;
+}
diff --git a/net/bridge/br_netlink.c b/net/bridge/br_netlink.c
index dea88a255d26..7b16819ecb59 100644
--- a/net/bridge/br_netlink.c
+++ b/net/bridge/br_netlink.c
@@ -780,9 +780,9 @@ static int br_setport(struct net_bridge_port *p, struct=
 nlattr *tb[])
 	if (tb[IFLA_BRPORT_GROUP_FWD_MASK]) {
 		u16 fwd_mask =3D nla_get_u16(tb[IFLA_BRPORT_GROUP_FWD_MASK]);
=20
-		if (fwd_mask & BR_GROUPFWD_MACPAUSE)
-			return -EINVAL;
-		p->group_fwd_mask =3D fwd_mask;
+		err =3D br_set_group_fwd_mask(p, fwd_mask);
+		if (err)
+			return err;
 	}
=20
 	br_port_flags_change(p, old_flags ^ p->flags);
diff --git a/net/bridge/br_private.h b/net/bridge/br_private.h
index 020c709a017f..734933bebb08 100644
--- a/net/bridge/br_private.h
+++ b/net/bridge/br_private.h
@@ -573,6 +573,7 @@ netdev_features_t br_features_recompute(struct net_brid=
ge *br,
 					netdev_features_t features);
 void br_port_flags_change(struct net_bridge_port *port, unsigned long mask=
);
 void br_manage_promisc(struct net_bridge *br);
+int br_set_group_fwd_mask(struct net_bridge_port *p, u16 mask);
=20
 /* br_input.c */
 int br_handle_frame_finish(struct net *net, struct sock *sk, struct sk_buf=
f *skb);
diff --git a/net/bridge/br_sysfs_if.c b/net/bridge/br_sysfs_if.c
index 9110d5e56085..f5871be10b24 100644
--- a/net/bridge/br_sysfs_if.c
+++ b/net/bridge/br_sysfs_if.c
@@ -173,11 +173,7 @@ static ssize_t show_group_fwd_mask(struct net_bridge_p=
ort *p, char *buf)
 static int store_group_fwd_mask(struct net_bridge_port *p,
 				unsigned long v)
 {
-	if (v & BR_GROUPFWD_MACPAUSE)
-		return -EINVAL;
-	p->group_fwd_mask =3D v;
-
-	return 0;
+	return br_set_group_fwd_mask(p, v);
 }
 static BRPORT_ATTR(group_fwd_mask, S_IRUGO | S_IWUSR, show_group_fwd_mask,
 		   store_group_fwd_mask);
--=20
2.11.0
