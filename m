From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [RFC PATCH net-next 6/7 v2]IPv6:netfilter: Record MIB counter after
 a fragment reached
Date: Sat, 27 Feb 2010 14:40:12 +0800
Message-ID: <4B88BE4C.3000504@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
To: Patrick McHardy <kaber@trash.net>,
	David Miller <davem@davemloft.net>,
	Alexey Dobriyan <adobriyan@gmail.com>,
	Yasuyuki KOZAKAI <yasuyuki.kozakai@toshiba.co.jp>,
	"netdev@vger.kernel.o
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:50560 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1753650Ab0B0GkM convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 27 Feb 2010 01:40:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch records MIB counter about fragments reassembly after a fragm=
ent reached.

Note:=20
=46or the lack of memory, if fails to clone skb, pull skb or create fra=
gment queue,
then not to forward skb to IPv6 stack, and drop it, just like IPv4.

v1->v2:
1. Conntrack can track a single fragment with MF=3D0=EF=BC=8Coffset=3D0=
 now.
   (applied patch with title [nf_conntrack_reasm: properly handle packe=
ts fragmented into a single fragment])
   So delete the changes when seeing a single fragment with MF=3D0=EF=BC=
=8Coffset=3D0.


Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
---
 net/ipv6/netfilter/nf_conntrack_reasm.c |   25 ++++++++++++++++++++---=
--
 1 files changed, 20 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/netfilter/nf_conntrack_reasm.c b/net/ipv6/netfilt=
er/nf_conntrack_reasm.c
index 4640795..fc97a68 100644
--- a/net/ipv6/netfilter/nf_conntrack_reasm.c
+++ b/net/ipv6/netfilter/nf_conntrack_reasm.c
@@ -680,27 +680,31 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff=
 *skb, u32 user)
 	u8 prevhdr;
 	struct sk_buff *ret_skb =3D NULL;
 	struct net *net =3D dev ? dev_net(dev) : dev_net(skb_dst(skb)->dev);
+	struct inet6_dev *idev;
=20
+	idev =3D dev ? in6_dev_get(dev) : ip6_dst_idev(skb_dst(skb));
 	/* Jumbo payload inhibits frag. header */
 	if (ipv6_hdr(skb)->payload_len =3D=3D 0) {
 		pr_debug("payload len =3D 0\n");
-		return skb;
+		goto out_nofrag;
 	}
=20
 	if (find_prev_fhdr(skb, &prevhdr, &nhoff, &fhoff) < 0)
-		return skb;
+		goto out_nofrag;
+
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMREQDS);
=20
 	clone =3D skb_clone(skb, GFP_ATOMIC);
 	if (clone =3D=3D NULL) {
 		pr_debug("Can't clone skb\n");
-		return skb;
+		goto out_drop_skb;
 	}
=20
 	NFCT_FRAG6_CB(clone)->orig =3D skb;
=20
 	if (!pskb_may_pull(clone, fhoff + sizeof(*fhdr))) {
 		pr_debug("message is too short.\n");
-		goto ret_orig;
+		goto out_drop_skb;
 	}
=20
 	skb_set_transport_header(clone, fhoff);
@@ -713,7 +717,7 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff *=
skb, u32 user)
 	fq =3D fq_find(net, fhdr->identification, user, &hdr->saddr, &hdr->da=
ddr);
 	if (fq =3D=3D NULL) {
 		pr_debug("Can't find and can't create new queue\n");
-		goto ret_orig;
+		goto out_drop_skb;
 	}
=20
 	spin_lock(&fq->q.lock);
@@ -732,13 +736,24 @@ struct sk_buff *nf_ct_frag6_gather(struct sk_buff=
 *skb, u32 user)
 			pr_debug("Can't reassemble fragmented packets\n");
 	}
 	spin_unlock(&fq->q.lock);
+	if (dev && idev)
+		in6_dev_put(idev);
=20
 	fq_put(fq);
 	return ret_skb;
=20
 ret_orig:
 	kfree_skb(clone);
+out_nofrag:
+	if (dev && idev)
+		in6_dev_put(idev);
 	return skb;
+out_drop_skb:
+	IP6_INC_STATS(net, idev, IPSTATS_MIB_REASMFAILS);
+	kfree_skb(clone);
+	kfree_skb(skb);
+	skb =3D NULL;
+	goto out_nofrag;
 }
=20
 void nf_ct_frag6_output(unsigned int hooknum, struct sk_buff *skb,
--=20
1.6.3.3
