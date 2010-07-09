From: rpartearroyo@albentia.com
Subject: [PATCH 001/001] QoS and/or fair queueing: Stateless NAT BUG
Date: Fri, 9 Jul 2010 18:35:59 +0200 (CEST)
Message-ID: <25524.83.175.223.254.1278693359.squirrel@mail.albentia.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=iso-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "Herbert Xu" <herbert@gondor.apana.org.au>,
	"Linux Kernel Mailing List" <linux-kernel@vger.kernel.org>,
	"Iratxo Pichel Ortiz" <ipichel@albentia.com>,
	Noelia =?iso-8859-1?Q?Mor=F3n?= <nmoron@albentia.com>,
	"netdev" <netdev@vger.kernel.org>
To: "Eric Dumazet" <eric.dumazet@gmail.com>
Return-path: <linux-kernel-owner@vger.kernel.org>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Hi all,
I have been testing Stateless NAT and found that ICMP packets with leng=
th
less than 20 bytes were not correctly NAT'ed. I have found a BUG that
makes taking into account IP header length twice, so ICMP packets small=
er
than 20 bytes were being dropped.

Proposed formal patch is below, as suggested by Eric Dumazet, thanks.
It is taken from 2.6.34.1 stable version.

Signed-off-by: Rodrigo Partearroyo Gonz=E1lez <rpartearroyo@albentia.co=
m>
---
diff -uprN a/net/sched/act_nat.c b/net/sched/act_nat.c
--- a/net/sched/act_nat.c    2010-07-09 18:25:18.000000000 +0200
+++ b/net/sched/act_nat.c 2010-07-09 18:26:16.000000000 +0200
@@ -202,7 +202,7 @@ static int tcf_nat(struct sk_buff *skb,
        {
                struct icmphdr *icmph;

-               if (!pskb_may_pull(skb, ihl + sizeof(*icmph) + sizeof(*=
iph)))
+               if (!pskb_may_pull(skb, ihl + sizeof(*icmph)))
                        goto drop;

                icmph =3D (void *)(skb_network_header(skb) + ihl);
@@ -223,7 +223,7 @@ static int tcf_nat(struct sk_buff *skb,

                if (skb_cloned(skb) &&
                    !skb_clone_writable(skb,
-                                       ihl + sizeof(*icmph) +
sizeof(*iph)) &&
+                                       ihl + sizeof(*icmph) ) &&
                    pskb_expand_head(skb, 0, 0, GFP_ATOMIC))
                        goto drop;
---

--=20
Rodrigo Partearroyo Gonz=E1lez

Albentia Systems S.A.
http://www.albentia.com

C\Margarita Salas 22
Parque Tecnol=F3gico de Legan=E9s
Legan=E9s (28918)
Madrid
Spain
