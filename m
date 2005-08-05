From: Harald Welte <laforge@gnumonks.org>
Subject: Re: [RFC PATCH] convert ebt_ulog to nfnetlink_log
Date: Fri, 5 Aug 2005 19:10:28 +0200
Message-ID: <20050805171028.GA7855@rama.de.gnumonks.org>
References: <20050730110353.GD6620@rama.de.gnumonks.org>
	<20050730.210423.111177162.davem@davemloft.net>
	<20050731070509.GD3835@rama.de.gnumonks.org>
	<1123241167.3377.15.camel@localhost.localdomain>
	<20050805163709.GF4033@rama.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="KsGdsel6WgEHnImy"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>,
	kaber@trash.net
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: Bart De Schuymer <bdschuym@pandora.be>
Content-Disposition: inline
In-Reply-To: <20050805163709.GF4033@rama.de.gnumonks.org>
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


--KsGdsel6WgEHnImy
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Fri, Aug 05, 2005 at 06:37:09PM +0200, Harald Welte wrote:
> Ok, I'll extend nfnetlink_log.c to add TLV's for those two fields in
> case CONFIG_BRIDGE_NF is set.  I'll send a patch later tonight.

What about the following (only compile-tested) patch ?

[NETFILTER] add phys{in,out}dev support to nfnetlink_log and nfnetlink_queue

Since bridges don't have a 'reasonable' input and output net_device
(e.g. 'br0'), we need to add seperate TLV's for the 'physindev' and 'physou=
tdev'
to get to the real underlying device (e.g. 'eth0').

I really hate to have those CONFIG_BRIDGE_NETFILTER ifdef's all over the
code - but for now we have them almost everywhere, so two more doesn't
hurt.  At some point we need to get rid of this ugliness and have something
like an 'input device stack' that can be traversed.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit 9f7972a4e1af559a1aeecfacfb1d6ca87f99f762
tree 36b9459801b3e4a2c61d1238a32bddbb4b5946e0
parent ed8612c164a21e71cf6139c4e67a98b7a417b1cb
author Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 19:07:28 +0200
committer Harald Welte <laforge@netfilter.org> Fr, 05 Aug 2005 19:07:28 +02=
00

 include/linux/netfilter/nfnetlink_log.h   |    2 ++
 include/linux/netfilter/nfnetlink_queue.h |    2 ++
 net/netfilter/nfnetlink_log.c             |   22 ++++++++++++++++++++++
 net/netfilter/nfnetlink_queue.c           |   22 ++++++++++++++++++++++
 4 files changed, 48 insertions(+), 0 deletions(-)

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
@@ -414,12 +418,26 @@ __build_packet_message(struct nfulnl_ins
 		tmp_uint =3D htonl(indev->ifindex);
 		NFA_PUT(inst->skb, NFULA_IFINDEX_INDEV, sizeof(tmp_uint),
 			&tmp_uint);
+#ifdef CONFIG_BRIDGE_NETFILTER
+		if (indev->br_port) {
+			tmp_uint =3D htonl(indev->br_port->br->dev->ifindex);
+			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSINDEV,
+				sizeof(tmp_uint), &tmp_uint);
+		}
+#endif
 	}
=20
 	if (outdev) {
 		tmp_uint =3D htonl(outdev->ifindex);
 		NFA_PUT(inst->skb, NFULA_IFINDEX_OUTDEV, sizeof(tmp_uint),
 			&tmp_uint);
+#ifdef CONFIG_BRIDGE_NETFILTER
+		if (outdev->br_port) {
+			tmp_uint =3D htonl(outdev->br_port->br->dev->ifindex);
+			NFA_PUT(inst->skb, NFULA_IFINDEX_PHYSOUTDEV,
+				sizeof(tmp_uint), &tmp_uint);
+		}
+#endif
 	}
=20
 	if (skb->nfmark) {
@@ -536,6 +554,10 @@ nfulnl_log_packet(unsigned int pf,
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
@@ -413,11 +421,25 @@ nfqnl_build_packet_message(struct nfqnl_
 	if (entry->info->indev) {
 		tmp_uint =3D htonl(entry->info->indev->ifindex);
 		NFA_PUT(skb, NFQA_IFINDEX_INDEV, sizeof(tmp_uint), &tmp_uint);
+#ifdef CONFIG_BRIDGE_NETFILTER
+		if (entry->info->indev->br_port) {
+			tmp_uint =3D htonl(entry->info->indev->br_port->br->dev->ifindex);
+			NFA_PUT(skb, NFQA_IFINDEX_PHYSINDEV,=20
+				sizeof(tmp_uint), &tmp_uint);
+		}
+#endif
 	}
=20
 	if (entry->info->outdev) {
 		tmp_uint =3D htonl(entry->info->outdev->ifindex);
 		NFA_PUT(skb, NFQA_IFINDEX_OUTDEV, sizeof(tmp_uint), &tmp_uint);
+#ifdef CONFIG_BRIDGE_NETFILTER
+		if (entry->info->outdev->br_port) {
+			tmp_uint =3D htonl(entry->info->outdev->br_port->br->dev->ifindex);
+			NFA_PUT(skb, NFQA_IFINDEX_PHYSOUTDEV,=20
+				sizeof(tmp_uint), &tmp_uint);
+		}
+#endif
 	}
=20
 	if (entry->skb->nfmark) {
--=20
- Harald Welte <laforge@gnumonks.org>          	        http://gnumonks.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
"Privacy in residential applications is a desirable marketing option."
                                                  (ETSI EN 300 175-7 Ch. A6)

--KsGdsel6WgEHnImy
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.1 (GNU/Linux)

iD8DBQFC852EXaXGVTD0i/8RAnmEAKCSR4NP4fCfDGO+T9cyA9wVWMH3kACeLW22
litlAcQ/YSvFx+RdYgK7UTQ=
=DQnO
-----END PGP SIGNATURE-----

--KsGdsel6WgEHnImy--
