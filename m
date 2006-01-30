From: Harald Welte <laforge@netfilter.org>
Subject: [PATCH] [NETFILTER] nfnetlink_log: add sequence numbers for log
	events
Date: Tue, 31 Jan 2006 00:23:48 +0100
Message-ID: <20060130232348.GH4603@sunbeam.de.gnumonks.org>
Mime-Version: 1.0
Content-Type: multipart/signed; micalg=pgp-sha1;
	protocol="application/pgp-signature"; boundary="spcZW7qGO+dl6Mj8"
Cc: Linux Netdev List <netdev@vger.kernel.org>,
	Netfilter Development Mailinglist <netfilter-devel@lists.netfilter.org>
Return-path: <netfilter-devel-bounces@lists.netfilter.org>
To: David Miller <davem@davemloft.net>
Content-Disposition: inline
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


--spcZW7qGO+dl6Mj8
Content-Type: text/plain; charset=us-ascii
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

Hi Dave,

please apply, thanks!

[NETFILTER] nfnetlink_log: add sequence numbers for log events

By using a sequence number for every logged netfilter event, we can
determine from userspace whether logging information was lots somewhere
downstream.

The user has a choice of either having per-instance local sequence
counters, or using a global sequence counter, or both.

Signed-off-by: Harald Welte <laforge@netfilter.org>

---
commit e3c7a1f99300fbd6de35a40fcd9c4dc1b0fbfee2
tree fa0df65edd0ec729af8033c0605b19dc49c1a688
parent 1259fffe55307fa41e932a594442aa78e1e37cfd
author Harald Welte <laforge@netfilter.org> Thu, 26 Jan 2006 15:05:29 +0100
committer Harald Welte <laforge@netfilter.org> Thu, 26 Jan 2006 15:05:29 +0=
100

 include/linux/netfilter/nfnetlink_log.h |    6 ++++
 net/netfilter/nfnetlink_log.c           |   46 +++++++++++++++++++++++++++=
++++
 2 files changed, 52 insertions(+), 0 deletions(-)

diff --git a/include/linux/netfilter/nfnetlink_log.h b/include/linux/netfil=
ter/nfnetlink_log.h
index b04b038..a7497c7 100644
--- a/include/linux/netfilter/nfnetlink_log.h
+++ b/include/linux/netfilter/nfnetlink_log.h
@@ -47,6 +47,8 @@ enum nfulnl_attr_type {
 	NFULA_PAYLOAD,			/* opaque data payload */
 	NFULA_PREFIX,			/* string prefix */
 	NFULA_UID,			/* user id of socket */
+	NFULA_SEQ,			/* instance-local sequence number */
+	NFULA_SEQ_GLOBAL,		/* global sequence number */
=20
 	__NFULA_MAX
 };
@@ -77,6 +79,7 @@ enum nfulnl_attr_config {
 	NFULA_CFG_NLBUFSIZ,		/* u_int32_t buffer size */
 	NFULA_CFG_TIMEOUT,		/* u_int32_t in 1/100 s */
 	NFULA_CFG_QTHRESH,		/* u_int32_t */
+	NFULA_CFG_FLAGS,		/* u_int16_t */
 	__NFULA_CFG_MAX
 };
 #define NFULA_CFG_MAX (__NFULA_CFG_MAX -1)
@@ -85,4 +88,7 @@ enum nfulnl_attr_config {
 #define NFULNL_COPY_META	0x01
 #define NFULNL_COPY_PACKET	0x02
=20
+#define NFULNL_CFG_F_SEQ	0x0001
+#define NFULNL_CFG_F_SEQ_GLOBAL	0x0002
+
 #endif /* _NFNETLINK_LOG_H */
diff --git a/net/netfilter/nfnetlink_log.c b/net/netfilter/nfnetlink_log.c
index e10512e..a98d0b7 100644
--- a/net/netfilter/nfnetlink_log.c
+++ b/net/netfilter/nfnetlink_log.c
@@ -11,6 +11,10 @@
  * it under the terms of the GNU General Public License version 2 as
  * published by the Free Software Foundation.
  *
+ * 2006-01-26 Harald Welte <laforge@netfilter.org>
+ * 	- Add optional local and global sequence number to detect lost=20
+ * 	  events from userspace
+ *
  */
 #include <linux/module.h>
 #include <linux/skbuff.h>
@@ -68,11 +72,14 @@ struct nfulnl_instance {
 	unsigned int nlbufsiz;		/* netlink buffer allocation size */
 	unsigned int qthreshold;	/* threshold of the queue */
 	u_int32_t copy_range;
+	u_int32_t seq;			/* instance-local sequential counter */
 	u_int16_t group_num;		/* number of this queue */
+	u_int16_t flags;
 	u_int8_t copy_mode;=09
 };
=20
 static DEFINE_RWLOCK(instances_lock);
+static atomic_t global_seq;
=20
 #define INSTANCE_BUCKETS	16
 static struct hlist_head instance_table[INSTANCE_BUCKETS];
@@ -310,6 +317,16 @@ nfulnl_set_qthresh(struct nfulnl_instanc
 	return 0;
 }
=20
+static int
+nfulnl_set_flags(struct nfulnl_instance *inst, u_int16_t flags)
+{
+	spin_lock_bh(&inst->lock);
+	inst->flags =3D ntohs(flags);
+	spin_unlock_bh(&inst->lock);
+
+	return 0;
+}
+
 static struct sk_buff *nfulnl_alloc_skb(unsigned int inst_size,=20
 					unsigned int pkt_size)
 {
@@ -373,6 +390,8 @@ static void nfulnl_timer(unsigned long d
 	spin_unlock_bh(&inst->lock);
 }
=20
+/* This is an inline function, we don't really care about a long
+ * list of arguments */
 static inline int=20
 __build_packet_message(struct nfulnl_instance *inst,
 			const struct sk_buff *skb,=20
@@ -511,6 +530,17 @@ __build_packet_message(struct nfulnl_ins
 			read_unlock_bh(&skb->sk->sk_callback_lock);
 	}
=20
+	/* local sequence number */
+	if (inst->flags & NFULNL_CFG_F_SEQ) {
+		tmp_uint =3D htonl(inst->seq++);
+		NFA_PUT(inst->skb, NFULA_SEQ, sizeof(tmp_uint), &tmp_uint);
+	}
+	/* global sequence number */
+	if (inst->flags & NFULNL_CFG_F_SEQ_GLOBAL) {
+		tmp_uint =3D atomic_inc_return(&global_seq);
+		NFA_PUT(inst->skb, NFULA_SEQ_GLOBAL, sizeof(tmp_uint), &tmp_uint);
+	}
+
 	if (data_len) {
 		struct nfattr *nfa;
 		int size =3D NFA_LENGTH(data_len);
@@ -603,6 +633,11 @@ nfulnl_log_packet(unsigned int pf,
=20
 	spin_lock_bh(&inst->lock);
=20
+	if (inst->flags & NFULNL_CFG_F_SEQ)
+		size +=3D NFA_SPACE(sizeof(u_int32_t));
+	if (inst->flags & NFULNL_CFG_F_SEQ_GLOBAL)
+		size +=3D NFA_SPACE(sizeof(u_int32_t));
+
 	qthreshold =3D inst->qthreshold;
 	/* per-rule qthreshold overrides per-instance */
 	if (qthreshold > li->u.ulog.qthreshold)
@@ -732,10 +767,14 @@ static const int nfula_min[NFULA_MAX] =3D=20
 	[NFULA_TIMESTAMP-1]	=3D sizeof(struct nfulnl_msg_packet_timestamp),
 	[NFULA_IFINDEX_INDEV-1]	=3D sizeof(u_int32_t),
 	[NFULA_IFINDEX_OUTDEV-1]=3D sizeof(u_int32_t),
+	[NFULA_IFINDEX_PHYSINDEV-1]	=3D sizeof(u_int32_t),
+	[NFULA_IFINDEX_PHYSOUTDEV-1]	=3D sizeof(u_int32_t),
 	[NFULA_HWADDR-1]	=3D sizeof(struct nfulnl_msg_packet_hw),
 	[NFULA_PAYLOAD-1]	=3D 0,
 	[NFULA_PREFIX-1]	=3D 0,
 	[NFULA_UID-1]		=3D sizeof(u_int32_t),
+	[NFULA_SEQ-1]		=3D sizeof(u_int32_t),
+	[NFULA_SEQ_GLOBAL-1]	=3D sizeof(u_int32_t),
 };
=20
 static const int nfula_cfg_min[NFULA_CFG_MAX] =3D {
@@ -744,6 +783,7 @@ static const int nfula_cfg_min[NFULA_CFG
 	[NFULA_CFG_TIMEOUT-1]	=3D sizeof(u_int32_t),
 	[NFULA_CFG_QTHRESH-1]	=3D sizeof(u_int32_t),
 	[NFULA_CFG_NLBUFSIZ-1]	=3D sizeof(u_int32_t),
+	[NFULA_CFG_FLAGS-1]	=3D sizeof(u_int16_t),
 };
=20
 static int
@@ -855,6 +895,12 @@ nfulnl_recv_config(struct sock *ctnl, st
 		nfulnl_set_qthresh(inst, ntohl(qthresh));
 	}
=20
+	if (nfula[NFULA_CFG_FLAGS-1]) {
+		u_int16_t flags =3D
+			*(u_int16_t *)NFA_DATA(nfula[NFULA_CFG_FLAGS-1]);
+		nfulnl_set_flags(inst, ntohl(flags));
+	}
+
 out_put:
 	instance_put(inst);
 	return ret;
--=20
- Harald Welte <laforge@netfilter.org>                 http://netfilter.org/
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D
  "Fragmentation is like classful addressing -- an interesting early
   architectural error that shows how much experimentation was going
   on while IP was being designed."                    -- Paul Vixie

--spcZW7qGO+dl6Mj8
Content-Type: application/pgp-signature
Content-Disposition: inline

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v1.4.2 (GNU/Linux)

iD8DBQFD3qAEXaXGVTD0i/8RAhG/AKC05DzS1RJLttOxFRkgZzkDQMWK6QCePTMh
XkUZmaOwhYH2DiMpFkGA3oE=
=DhA7
-----END PGP SIGNATURE-----

--spcZW7qGO+dl6Mj8--
