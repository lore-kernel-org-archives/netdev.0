From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] add bridging support to nfnetlink_{log,queue}
Date: Mon, 8 Aug 2005 15:24:13 +0200
Message-ID: <20050808132413.GA25303@rama.de.gnumonks.org>
References: <W911141491296841123491979@kostunerix.telenet-ops.be>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="raC6veAxrt5nqIoY"
Cc: "bdschuym@pandora.be" <bdschuym@telenet.be>,
	Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
In-Reply-To: <W911141491296841123491979@kostunerix.telenet-ops.be>
List-Unsubscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=unsubscribe>
List-Archive: </pipermail/netfilter-devel>
List-Post: <mailto:netfilter-devel@lists.netfilter.org>
List-Help: <mailto:netfilter-devel-request@lists.netfilter.org?subject=help>
List-Subscribe: <https://lists.netfilter.org/mailman/listinfo/netfilter-devel>,
	<mailto:netfilter-devel-request@lists.netfilter.org?subject=subscribe>
Sender: netfilter-devel-bounces@lists.netfilter.org
Errors-To: netfilter-devel-bounces@lists.netfilter.org
List-Id: netdev.vger.kernel.org


--raC6veAxrt5nqIoY
Content-Type: multipart/mixed; boundary="TakKZr9L6Hm6aLOc"
Content-Disposition: inline


--TakKZr9L6Hm6aLOc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

> There is one case missing: the brouter case. If br0=3Deth0+eth1 and a
> packet arrives at eth0 (not br0) in the IP code (not the bridge code),
> then the indev must be eth0, not br0.  How about something like this?

Ok, I've implemented your suggested modifications now.

Dave: Please apply to your net-2.6.14 tree. Thanks!

--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--TakKZr9L6Hm6aLOc
Content-Type: text/plain; charset=us-ascii
Content-Disposition: attachment; filename="38-nfnetlink_queue_log-bridge.patch"
Content-Transfer-Encoding: quoted-printable

[NETFILTER] add correct bridging support to nfnetlink_{queue,log}

This patch adds support for passing the real 'physical' device ifindex down
to userspace via nfnetlink_log and nfnetlink_queue.

This feature basically obsoletes net/bridge/netfilter/ebt_ulog.c, and it
is likely ebt_ulog.c will die with one of the next couple of patches.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 5f748d529c9bf1f0f52453d02a5e3aa9eca351e3
tree f337de87d43b721ba0653e759c7d54d5daa27c52
parent e9d42778324d0432fe18b1a26d915d342a067351
author Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 15:20:14 +0200
committer Harald Welte <laforge@netfilter.org> Mo, 08 Aug 2005 15:20:14 +02=
00

 include/linux/netfilter/nfnetlink_log.h   |    2 +
 include/linux/netfilter/nfnetlink_queue.h |    2 +
 net/netfilter/nfnetlink_log.c             |   58 +++++++++++++++++++++++++=
++++
 net/netfilter/nfnetlink_queue.c           |   58 +++++++++++++++++++++++++=
++++
 4 files changed, 120 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_log.h b/include/linux/netfil=
ter/nfnetlink_log.h
--- a/include/linux/netfilter/nfnetlink_log.h
+++ b/include/linux/netfilter/nfnetlink_log.h
@@ -40,6 +40,8 @@ enum nfulnl_attr_type {
 	NFULA_TIMESTAMP,		/* nfulnl_msg_packet_timestamp */
 	NFULA_IFINDEX_INDEV,		/* u_int32_t ifindex */
 	NFULA_IFINDEX_OUTDEV,		/* u_int32_t ifindex */
+	NFULA_IFINDEX_PHYSINDEV,	/* u_int32_t ifindex */
+	NFULA_IFINDEX_PHYSOUTDEV,	/* u_int32_t ifindex */
 	NFULA_HWADDR,			/* nfulnl_msg_packet_hw */
 	NFULA_PAYLOAD,			/* opaque data payload */
 	NFULA_PREFIX,			/* string prefix */
diff --git a/include/linux/netfilter/nfnetlink_queue.h b/include/linux/netf=
ilter/nfnetlink_queue.h
--- a/include/linux/netfilter/nfnetlink_queue.h
+++ b/include/linux/netfilter/nfnetlink_queue.h
@@ -36,6 +36,8 @@ enum nfqnl_attr_type {
 	NFQA_TIMESTAMP,			/* nfqnl_msg_packet_timestamp */
 	NFQA_IFINDEX_INDEV,		/* u_int32_t ifindex */
 	NFQA_IFINDEX_OUTDEV,		/* u_int32_t ifindex */
+	NFQA_IFINDEX_PHYSINDEV,		/* u_int32_t ifindex */
+	NFQA_IFINDEX_PHYSOUTDEV,	/* u_int32_t ifindex */
 	NFQA_HWADDR,			/* nfqnl_msg_packet_hw */
 	NFQA_PAYLOAD,			/* opaque data payload */
=20
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -33,6 +33,10 @@
=20
 #include <asm/atomic.h>
=20
+#ifdef CONFIG_BRIDGE_NETFILTER
+#include "../bridge/br_private.h"
+#endif
+
 #define NFULNL_NLBUFSIZ_DEFAULT	4096
 #define NFULNL_TIMEOUT_DEFAULT 	100	/* every second */
 #define NFULNL_QTHRESH_DEFAULT 	100	/* 100 packets */
@@ -412,14 +416,64 @@ __build_packet_message(struct nfulnl_ins
=20
 	if (indev) {
 		tmp_uint =3D htonl(indev->ifindex);
+#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV, sizeof(tmp_uint),
 			&tmp_uint);
+#else
+		if (pf =3D=3D PF_BRIDGE) {
+			/* Case 1: outdev is physical input device, we need to
+			 * look for bridge group (when called from
+			 * netfilter_bridge) */
+			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
+				sizeof(tmp_uint), &tmp_uint);
+			/* this is the bridge group "brX" */
+			tmp_uint =3D htonl(indev->br_port->br->dev->ifindex);
+			NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
+				sizeof(tmp_uint), &tmp_uint);
+		} else {
+			/* Case 2: indev is bridge group, we need to look for
+			 * physical device (when called from ipv4) */
+			NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV,
+				sizeof(tmp_uint), &tmp_uint);
+			if (skb->nf_bridge && skb->nf_bridge->physindev) {
+				tmp_uint =3D=20
+				    htonl(skb->nf_bridge->physindev->ifindex);
+				NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
+					sizeof(tmp_uint), &tmp_uint);
+			}
+		}
+#endif
 	}
=20
 	if (outdev) {
 		tmp_uint =3D htonl(outdev->ifindex);
+#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV, sizeof(tmp_uint),
 			&tmp_uint);
+#else
+		if (pf =3D=3D PF_BRIDGE) {
+			/* Case 1: outdev is physical output device, we need to
+			 * look for bridge group (when called from
+			 * netfilter_bridge) */
+			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
+				sizeof(tmp_uint), &tmp_uint);
+			/* this is the bridge group "brX" */
+			tmp_uint =3D htonl(outdev->br_port->br->dev->ifindex);
+			NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV,
+				sizeof(tmp_uint), &tmp_uint);
+		} else {
+			/* Case 2: indev is a bridge group, we need to look
+			 * for physical device (when called from ipv4) */
+			NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV,
+				sizeof(tmp_uint), &tmp_uint);
+			if (skb->nf_bridge) {
+				tmp_uint =3D=20
+				    htonl(skb->nf_bridge->physoutdev->ifindex);
+				NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
+					sizeof(tmp_uint), &tmp_uint);
+			}
+		}
+#endif
 	}
=20
 	if (skb->nfmark) {
@@ -536,6 +590,10 @@ nfulnl_log_packet(unsigned int pf,
 		+ NFA_SPACE(sizeof(struct nfulnl_msg_packet_hdr))
 		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
 		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
+#ifdef CONFIG_BRIDGE_NETFILTER
+		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
+		+ NFA_SPACE(sizeof(u_int32_t))	/* ifindex */
+#endif
 		+ NFA_SPACE(sizeof(u_int32_t))	/* mark */
 		+ NFA_SPACE(sizeof(u_int32_t))	/* uid */
 		+ NFA_SPACE(NFULNL_PREFIXLEN)	/* prefix */
diff --git a/net/netfilter/nfnetlink_queue.c b/net/netfilter/nfnetlink_queu=
e.c
--- a/net/netfilter/nfnetlink_queue.c
+++ b/net/netfilter/nfnetlink_queue.c
@@ -30,6 +30,10 @@
=20
 #include <asm/atomic.h>
=20
+#ifdef CONFIG_BRIDGE_NETFILTER
+#include "../bridge/br_private.h"
+#endif
+
 #define NFQNL_QMAX_DEFAULT 1024
=20
 #if 0
@@ -361,6 +365,10 @@ nfqnl_build_packet_message(struct nfqnl_
 	size =3D    NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hdr))
 		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
 		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+#ifdef CONFIG_BRIDGE_NETFILTER
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+		+ NLMSG_SPACE(sizeof(u_int32_t))	/* ifindex */
+#endif
 		+ NLMSG_SPACE(sizeof(u_int32_t))	/* mark */
 		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_hw))
 		+ NLMSG_SPACE(sizeof(struct nfqnl_msg_packet_timestamp));
@@ -412,12 +420,62 @@ nfqnl_build_packet_message(struct nfqnl_
=20
 	if (entry->info->indev) {
 		tmp_uint =3D htonl(entry->info->indev->ifindex);
+#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint), &tmp_uint);
+#else
+		if (entry->info->pf =3D=3D PF_BRIDGE) {
+			/* Case 1: indev is physical input device, we need to
+			 * look for bridge group (when called from=20
+			 * netfilter_bridge) */
+			NFA_PUT(skb, NFQA_IFINDEX_PHYSINDEV, sizeof(tmp_uint),=20
+				&tmp_uint);
+			/* this is the bridge group "brX" */
+			tmp_uint =3D htonl(entry->info->indev->br_port->br->dev->ifindex);
+			NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint),
+				&tmp_uint);
+		} else {
+			/* Case 2: indev is bridge group, we need to look for
+			 * physical device (when called from ipv4) */
+			NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint),
+				&tmp_uint);
+			if (entry->skb->nf_bridge
+			    && entry->skb->nf_bridge->physindev) {
+				tmp_uint =3D htonl(entry->skb->nf_bridge->physindev->ifindex);
+				NFA_PUT(skb, NFQA_IFINDEX_PHYSINDEV,
+					sizeof(tmp_uint), &tmp_uint);
+			}
+		}
+#endif
 	}
=20
 	if (entry->info->outdev) {
 		tmp_uint =3D htonl(entry->info->outdev->ifindex);
+#ifndef CONFIG_BRIDGE_NETFILTER
 		NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint), &tmp_uint);
+#else
+		if (entry->info->pf =3D=3D PF_BRIDGE) {
+			/* Case 1: outdev is physical output device, we need to
+			 * look for bridge group (when called from=20
+			 * netfilter_bridge) */
+			NFA_PUT(skb, NFQA_IFINDEX_PHYSOUTDEV, sizeof(tmp_uint),
+				&tmp_uint);
+			/* this is the bridge group "brX" */
+			tmp_uint =3D htonl(entry->info->outdev->br_port->br->dev->ifindex);
+			NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint),
+				&tmp_uint);
+		} else {
+			/* Case 2: outdev is bridge group, we need to look for
+			 * physical output device (when called from ipv4) */
+			NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint),
+				&tmp_uint);
+			if (entry->skb->nf_bridge
+			    && entry->skb->nf_bridge->physoutdev) {
+				tmp_uint =3D htonl(entry->skb->nf_bridge->physoutdev->ifindex);
+				NFA_PUT(skb, NFQA_IFINDEX_PHYSOUTDEV,
+					sizeof(tmp_uint), &tmp_uint);
+			}
+		}
+#endif
 	}
=20
 	if (entry->skb->nfmark) {

--TakKZr9L6Hm6aLOc--

--raC6veAxrt5nqIoY
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC91z9XaXGVTD0i/8RAh8tAKCxbQmcybEO6nYACSg/3JOuaLLFjgCgiaiU
hb8H9i4cG2VjE84lCM2XcXs=
=3sbC
-----END PGP SIGNATURE-----

--raC6veAxrt5nqIoY--
