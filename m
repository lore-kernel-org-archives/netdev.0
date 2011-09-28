From: "Yan, Zheng" <zheng.z.yan@intel.com>
Subject: [PATCH v2] tcp: properly update lost_cnt_hint during shifting
Date: Wed, 28 Sep 2011 22:13:16 +0800
Message-ID: <4E832B7C.5070404@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?ISO-8859-1?Q?Ilpo_J=E4rvinen?= <ilpo.jarvinen@helsinki.fi>,
	Nandita Dukkipati <nanditad@google.com>,
	"davem@davemloft.net" <davem@davemloft.net>
To: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga02.intel.com ([134.134.136.20]:20052 "EHLO mga02.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752643Ab1I1ONS (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 28 Sep 2011 10:13:18 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

lost_skb_hint is used by tcp_mark_head_lost() to mark the first unhandl=
ed skb.
lost_cnt_hint is the number of sacked packets before the lost_skb_hint.=
 When
shifting a skb that is before the lost_skb_hint, tcp_shifted_skb() does=
n't need
to adjust lost_cnt_hint by itself because it calls tcp_sacktag_one() wh=
ich will
do the job right.

Signed-off-by: Zheng Yan <zheng.z.yan@intel.com>
Acked-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 21fab3e..ae5a934 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1389,9 +1389,7 @@ static int tcp_shifted_skb(struct sock *sk, struc=
t sk_buff *skb,
=20
 	BUG_ON(!pcount);
=20
-	/* Tweak before seqno plays */
-	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint &&
-	    !before(TCP_SKB_CB(tp->lost_skb_hint)->seq, TCP_SKB_CB(skb)->seq)=
)
+	if (!tcp_is_fack(tp) && tcp_is_sack(tp) && tp->lost_skb_hint =3D=3D s=
kb)
 		tp->lost_cnt_hint +=3D pcount;
=20
 	TCP_SKB_CB(prev)->end_seq +=3D shifted;
