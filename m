From: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Subject: [PATCH] net: add per device sg_max_frags for skb
Date: Wed,  6 Jan 2016 14:16:22 +0100
Message-ID: <1452086182-26748-1-git-send-email-hans.westgaard.ry@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	"Alexey Kuznetsov" <kuznet@ms2.inr.ac.ru>,
	"James Morris" <jmorris@namei.org>,
	"Hideaki YOSHIFUJI" <yoshfuji@linux-ipv6.org>,
	"Patrick McHardy" <kaber@trash.net>,
	"Alexei Starovoitov" <ast@plumgrid.com>,
	"Jiri Pirko" <jiri@mellanox.com>,
	"Eric Dumazet" <edumazet@google.com>,
	"Daniel Borkmann" <daniel@iogearbox.net>,
	"Nicolas Dichtel" <nicolas.dichtel@6wind.com>,
	"\"\"Eric W. Biederman\"\"" <ebiederm@xmission.com>,
	"Salam Noureddine" <noureddine@arista.com>,
	"Jarod Wilson" <jarod@redhat.com>,
	"Toshiaki Makita" <makita.toshiaki@lab.ntt.co.jp>,
	"Julian Anastasov" <ja@ssi.bg>,
	"Ying Xue" <ying.xue@windriver.com>,
	"Craig Gallek" <kraig@google.com>,
	"Mel Gorman" <mgorman@techsingularity.net>,
	"\"\"hannes@stressinduktion.org\"\"" <hannes@stressinduktion.org>,
	"Edward Jee" <edjee@google.com>,
	"Julia Lawall" <julia.lawall@l
To: "David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Devices may have limits on the number of fragments in an skb they
support. Current codebase uses a constant as maximum for number of
fragments (MAX_SKB_FRAGS) one skb can hold and use.

When enabling scatter/gather and running traffic with many small
messages the codebase uses the maximum number of fragments and thereby
violates the max for certain devices.

An example of such a violation is when running IPoIB on a HCA
supporting 16 SGE on an architecture with 4K pagesize. The
MAX_SKB_FRAGS will be 17 (64K/4K+1) and because IPoIB adds yet another
segment we end up with send_requests with 18 SGE resulting in
kernel-panic.

The patch allows the device to limit the maximum number fragments used
in one skb.

The functionality corresponds to gso_max_size/gso_max_segs for gso.

Signed-off-by: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Reviewed-by: H=C3=A5kon Bugge <haakon.bugge@oracle.com>
Reviewed-by: Knut Omang <knut.omang@oracle.com>
Reviewed-by: Wei Lin Guay <wei.lin.guay@oracle.com>
Reviewed-by: Santosh Shilimkar <santosh.shilimkar@oracle.com>
Reviewed-by: Yuval Shaia <yuval.shaia@oracle.com>

---
 include/linux/netdevice.h | 8 ++++++++
 include/net/sock.h        | 2 ++
 net/core/dev.c            | 1 +
 net/core/sock.c           | 1 +
 net/ipv4/tcp.c            | 4 ++--
 5 files changed, 14 insertions(+), 2 deletions(-)

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 3b5d134..c661865 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -1513,6 +1513,8 @@ enum netdev_priv_flags {
  *			NIC for GSO
  *	@gso_min_segs:	Minimum number of segments that can be passed to the
  *			NIC for GSO
+ *     @sg_max_frags:  Maximum number of fragments that can be passed =
to the
+ *                     NIC for SG
  *
  *	@dcbnl_ops:	Data Center Bridging netlink ops
  *	@num_tc:	Number of traffic classes in the net device
@@ -1799,6 +1801,7 @@ struct net_device {
 	struct phy_device *phydev;
 	struct lock_class_key *qdisc_tx_busylock;
 	bool proto_down;
+	u16 sg_max_frags;
 };
 #define to_net_dev(d) container_of(d, struct net_device, dev)
=20
@@ -3794,6 +3797,11 @@ static inline void netif_set_gso_max_size(struct=
 net_device *dev,
 {
 	dev->gso_max_size =3D size;
 }
+static inline void netif_set_sg_max_frags(struct net_device *dev,
+					u16 max)
+{
+	dev->sg_max_frags =3D min_t(u16, MAX_SKB_FRAGS, max);
+}
=20
 static inline void skb_gso_error_unwind(struct sk_buff *skb, __be16 pr=
otocol,
 					int pulled_hlen, u16 mac_offset,
diff --git a/include/net/sock.h b/include/net/sock.h
index 52d27ee..c884104 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -274,6 +274,7 @@ struct cg_proto;
   *	@sk_gso_type: GSO type (e.g. %SKB_GSO_TCPV4)
   *	@sk_gso_max_size: Maximum GSO segment size to build
   *	@sk_gso_max_segs: Maximum number of GSO segments
+  *    @sk_sg_max_frags: Maximum number of SG fragments
   *	@sk_lingertime: %SO_LINGER l_linger setting
   *	@sk_backlog: always used with the per-socket spinlock held
   *	@sk_callback_lock: used with the callbacks in the end of this stru=
ct
@@ -456,6 +457,7 @@ struct sock {
 	int			(*sk_backlog_rcv)(struct sock *sk,
 						  struct sk_buff *skb);
 	void                    (*sk_destruct)(struct sock *sk);
+	u16                     sk_sg_max_frags;
 };
=20
 #define __sk_user_data(sk) ((*((void __rcu **)&(sk)->sk_user_data)))
diff --git a/net/core/dev.c b/net/core/dev.c
index ae00b89..abfbd3a 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -7106,6 +7106,7 @@ struct net_device *alloc_netdev_mqs(int sizeof_pr=
iv, const char *name,
 	dev->gso_max_size =3D GSO_MAX_SIZE;
 	dev->gso_max_segs =3D GSO_MAX_SEGS;
 	dev->gso_min_segs =3D 0;
+	dev->sg_max_frags =3D MAX_SKB_FRAGS;
=20
 	INIT_LIST_HEAD(&dev->napi_list);
 	INIT_LIST_HEAD(&dev->unreg_list);
diff --git a/net/core/sock.c b/net/core/sock.c
index e31dfce..53d0cf0 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -1621,6 +1621,7 @@ void sk_setup_caps(struct sock *sk, struct dst_en=
try *dst)
 		}
 	}
 	sk->sk_gso_max_segs =3D max_segs;
+	sk->sk_sg_max_frags =3D dst->dev->sg_max_frags;
 }
 EXPORT_SYMBOL_GPL(sk_setup_caps);
=20
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c82cca1..ca5f7a0 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -938,7 +938,7 @@ new_segment:
=20
 		i =3D skb_shinfo(skb)->nr_frags;
 		can_coalesce =3D skb_can_coalesce(skb, i, page, offset);
-		if (!can_coalesce && i >=3D MAX_SKB_FRAGS) {
+		if (!can_coalesce && i >=3D sk->sk_sg_max_frags) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
@@ -1211,7 +1211,7 @@ new_segment:
=20
 			if (!skb_can_coalesce(skb, i, pfrag->page,
 					      pfrag->offset)) {
-				if (i =3D=3D MAX_SKB_FRAGS || !sg) {
+				if (i >=3D sk->sk_sg_max_frags || !sg) {
 					tcp_mark_push(tp, skb);
 					goto new_segment;
 				}
--=20
2.4.3
