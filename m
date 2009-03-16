From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Kernel panic during stress with igb in the upstream kernel
Date: Mon, 16 Mar 2009 21:22:40 +0800
Message-ID: <20090316132240.GA18413@gondor.apana.org.au>
References: <EA929A9653AAE14F841771FB1DE5A1365F69CA4280@rrsmsx501.amr.corp.intel.com> <20090313115245.GA31949@gondor.apana.org.au> <20090315.201353.57364397.davem@davemloft.net> <20090315.201802.58015530.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: emil.s.tantilov@intel.com, alexander.h.duyck@intel.com,
	jesse.brandeburg@intel.com, jeffrey.t.kirsher@intel.com,
	netdev@vger.kernel.org
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from rhun.apana.org.au ([64.62.148.172]:57823 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753961AbZCPNWt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 16 Mar 2009 09:22:49 -0400
Content-Disposition: inline
In-Reply-To: <20090315.201802.58015530.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sun, Mar 15, 2009 at 08:18:02PM -0700, David Miller wrote:
>=20
> Actually, I had to revert, it doesn't build with netpoll
> disabled:
>=20
> net/8021q/vlan_core.c: In function =E2=80=98vlan_gro_common=E2=80=99:
> net/8021q/vlan_core.c:82: error: implicit declaration of function =E2=
=80=98netpoll_rx_on=E2=80=99
> make[2]: *** [net/8021q/vlan_core.o] Error 1
> make[1]: *** [net/8021q] Error 2
> make: *** [net] Error 2
> make: *** Waiting for unfinished jobs....

Oops, forgot the #else case.

GRO: Move netpoll checks to correct location

As my netpoll fix for net doesn't really work for net-next, we
need this update to move the checks into the right place.  As it
stands we may pass freed skbs to netpoll_receive_skb.

This patch also introduces a netpoll_rx_on function to avoid GRO
completely if we're invoked through netpoll.  This might seem
paranoid but as netpoll may have an external receive hook it's
better to be safe than sorry.  I don't think we need this for
2.6.29 though since there's nothing immediately broken by it.

This patch also moves the GRO_* return values to netdevice.h since
VLAN needs them too (I tried to avoid this originally but alas
this seems to be the easiest way out).  This fixes a bug in VLAN
where it continued to use the old return value 2 instead of the
correct GRO_DROP.

Signed-off-by: Herbert Xu <herbert@gondor.apana.org.au>

diff --git a/include/linux/netdevice.h b/include/linux/netdevice.h
index 493b065..be3ebd7 100644
--- a/include/linux/netdevice.h
+++ b/include/linux/netdevice.h
@@ -330,6 +330,14 @@ enum
 	NAPI_STATE_NPSVC,	/* Netpoll - don't dequeue from poll_list */
 };
=20
+enum {
+	GRO_MERGED,
+	GRO_MERGED_FREE,
+	GRO_HELD,
+	GRO_NORMAL,
+	GRO_DROP,
+};
+
 extern void __napi_schedule(struct napi_struct *n);
=20
 static inline int napi_disable_pending(struct napi_struct *n)
diff --git a/include/linux/netpoll.h b/include/linux/netpoll.h
index e38d3c9..de99025 100644
--- a/include/linux/netpoll.h
+++ b/include/linux/netpoll.h
@@ -63,6 +63,13 @@ static inline int netpoll_rx(struct sk_buff *skb)
 	return ret;
 }
=20
+static inline int netpoll_rx_on(struct sk_buff *skb)
+{
+	struct netpoll_info *npinfo =3D skb->dev->npinfo;
+
+	return npinfo && (npinfo->rx_np || npinfo->rx_flags);
+}
+
 static inline int netpoll_receive_skb(struct sk_buff *skb)
 {
 	if (!list_empty(&skb->dev->napi_list))
@@ -99,6 +106,10 @@ static inline int netpoll_rx(struct sk_buff *skb)
 {
 	return 0;
 }
+static inline int netpoll_rx_on(struct sk_buff *skb)
+{
+	return 0;
+}
 static inline int netpoll_receive_skb(struct sk_buff *skb)
 {
 	return 0;
diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
index 2d6e405..6227248 100644
--- a/net/8021q/vlan_core.c
+++ b/net/8021q/vlan_core.c
@@ -79,6 +79,9 @@ static int vlan_gro_common(struct napi_struct *napi, =
struct vlan_group *grp,
 {
 	struct sk_buff *p;
=20
+	if (netpoll_rx_on(skb))
+		return GRO_NORMAL;
+
 	if (skb_bond_should_drop(skb))
 		goto drop;
=20
@@ -98,7 +101,7 @@ static int vlan_gro_common(struct napi_struct *napi,=
 struct vlan_group *grp,
 	return dev_gro_receive(napi, skb);
=20
 drop:
-	return 2;
+	return GRO_DROP;
 }
=20
 int vlan_gro_receive(struct napi_struct *napi, struct vlan_group *grp,
@@ -106,9 +109,6 @@ int vlan_gro_receive(struct napi_struct *napi, stru=
ct vlan_group *grp,
 {
 	skb_gro_reset_offset(skb);
=20
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	return napi_skb_finish(vlan_gro_common(napi, grp, vlan_tci, skb), skb=
);
 }
 EXPORT_SYMBOL(vlan_gro_receive);
@@ -121,9 +121,6 @@ int vlan_gro_frags(struct napi_struct *napi, struct=
 vlan_group *grp,
 	if (!skb)
 		return NET_RX_DROP;
=20
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	return napi_frags_finish(napi, skb,
 				 vlan_gro_common(napi, grp, vlan_tci, skb));
 }
diff --git a/net/core/dev.c b/net/core/dev.c
index 033d7ca..7bd3c29 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -135,14 +135,6 @@
 /* This should be increased if a protocol with a bigger head is added.=
 */
 #define GRO_MAX_HEAD (MAX_HEADER + 128)
=20
-enum {
-	GRO_MERGED,
-	GRO_MERGED_FREE,
-	GRO_HELD,
-	GRO_NORMAL,
-	GRO_DROP,
-};
-
 /*
  *	The list of packet types we will receive (as opposed to discard)
  *	and the routines to invoke.
@@ -2474,6 +2466,9 @@ static int __napi_gro_receive(struct napi_struct =
*napi, struct sk_buff *skb)
 {
 	struct sk_buff *p;
=20
+	if (netpoll_rx_on(skb))
+		return GRO_NORMAL;
+
 	for (p =3D napi->gro_list; p; p =3D p->next) {
 		NAPI_GRO_CB(p)->same_flow =3D !compare_ether_header(
 			skb_mac_header(p), skb_gro_mac_header(skb));
@@ -2487,9 +2482,6 @@ int napi_skb_finish(int ret, struct sk_buff *skb)
 {
 	int err =3D NET_RX_SUCCESS;
=20
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	switch (ret) {
 	case GRO_NORMAL:
 		return netif_receive_skb(skb);
@@ -2587,9 +2579,6 @@ int napi_frags_finish(struct napi_struct *napi, s=
truct sk_buff *skb, int ret)
 {
 	int err =3D NET_RX_SUCCESS;
=20
-	if (netpoll_receive_skb(skb))
-		return NET_RX_DROP;
-
 	switch (ret) {
 	case GRO_NORMAL:
 	case GRO_HELD:

Thanks,
--=20
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
