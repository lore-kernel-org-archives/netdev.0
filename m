From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: [PATCH net-next-2.6] pktgen: Optionally leak kernel memory
Date: Sat, 24 Jul 2010 07:23:44 +0200
Message-ID: <1279949024.2451.43.camel@edumazet-laptop>
References: <4C4A224B.8080806@candelatech.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: NetDev <netdev@vger.kernel.org>
To: Ben Greear <greearb@candelatech.com>,
	David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ww0-f44.google.com ([74.125.82.44]:34377 "EHLO
	mail-ww0-f44.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751114Ab0GXFXu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 24 Jul 2010 01:23:50 -0400
Received: by wwj40 with SMTP id 40so5324070wwj.1
        for <netdev@vger.kernel.org>; Fri, 23 Jul 2010 22:23:48 -0700 (PDT)
In-Reply-To: <4C4A224B.8080806@candelatech.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le vendredi 23 juillet 2010 =C3=A0 16:14 -0700, Ben Greear a =C3=A9crit=
 :
> Some time back, someone added some memset() calls to pktgen to
> keep from leaking memory contents to the network.
>=20

Well, someone might be me ;)

> At least in our modified version of pktgen, this caused about 25%
> performance degradation when sending 1514 byte pkts (multi-pkt =3D=3D=
 0)
> on a pair of 10G ports.  It was easy enough to comment these memset
> calls out of course.
>=20
> I don't mind if this patch stays in,
> but thought I'd post my findings in case anyone else wonders why
> their pktgen slowed down...
>=20

Thanks Ben

Here is a patch adding a new pktgen flag, so that admins can choose
speed if they want to, if they dont use clone_skb to reduce skb setup
costs.

Oc course, admins could change pktgen code themselves, but as you said,
better document it so that admins are aware of this possible speed
increase.

[PATCH net-next-2.6] pktgen: Optionally leak kernel memory

Commit 66ed1e5ec1d979 (pktgen: Dont leak kernel memory)
closed a security hole, by making sure data sent to network was cleared=
,
instead of using previous content of pages.

As Ben Greear noticed, this can slow down pktgen as much as 25%.

Add a new pktgen flag, UNSAFE, to ask pktgen to not clear data and use
previous content of memory.

Also add documentation for UNSAFE and NODE_ALLOC flags

Reported-by: Ben Greear <greearb@candelatech.com>
Signed-off-by: Eric Dumazet <eric.dumazet@gmail.com>
---
 Documentation/networking/pktgen.txt |   24 ++++++++++++++++++++++-
 net/core/pktgen.c                   |   27 +++++++++++++++++++++-----
 2 files changed, 45 insertions(+), 6 deletions(-)

diff --git a/Documentation/networking/pktgen.txt b/Documentation/networ=
king/pktgen.txt
index 75e4fd7..88e2e6f 100644
--- a/Documentation/networking/pktgen.txt
+++ b/Documentation/networking/pktgen.txt
@@ -108,7 +108,10 @@ Examples:
                               MPLS_RND, VID_RND, SVID_RND
                               QUEUE_MAP_RND # queue map random
                               QUEUE_MAP_CPU # queue map mirrors smp_pr=
ocessor_id()
-
+                              NODE_ALLOC # NUMA aware skb allocations
+                              UNSAFE # Dont clear packets payload
+                                      (Might be 25% faster, but can le=
ak sensitive
+                                       data to network. Use at your ow=
n risk !)
=20
  pgset "udp_src_min 9"   set UDP source port min, If < udp_src_max, th=
en
                          cycle through the port range.
@@ -178,6 +181,18 @@ Note when adding devices to a specific CPU there g=
ood idea to also assign
 as this reduces cache bouncing when freeing skb's.
=20
=20
+Very fast mode
+=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
+One knob to get very fast pktgen is the UNSAFE flag :
+
+flag UNSAFE
+
+This ask to pktgen to not clear content of packets before sending them=
=2E
+Note this is a security problem, and should be used only if really nee=
ded.
+If packets are cloned (clone_skb 1000), clearing data cost is amortize=
d so
+this UNSAFE mode is less interesting.
+
+
 Current commands and configuration options
 =3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=
=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D=3D
=20
@@ -225,6 +240,13 @@ flag
   UDPDST_RND
   MACSRC_RND
   MACDST_RND
+  MPLS_RND
+  VID_RND
+  SVID_RND
+  FLOW_SEQ
+  IPSEC
+  NODE_ALLOC
+  UNSAFE
=20
 dst_min
 dst_max
diff --git a/net/core/pktgen.c b/net/core/pktgen.c
index 24a19de..01990cb 100644
--- a/net/core/pktgen.c
+++ b/net/core/pktgen.c
@@ -172,7 +172,7 @@
 #include <asm/dma.h>
 #include <asm/div64.h>		/* do_div */
=20
-#define VERSION	"2.74"
+#define VERSION	"2.75"
 #define IP_NAME_SZ 32
 #define MAX_MPLS_LABELS 16 /* This is the max label stack depth */
 #define MPLS_STACK_BOTTOM htonl(0x00000100)
@@ -196,6 +196,7 @@
 #define F_QUEUE_MAP_RND (1<<13)	/* queue map Random */
 #define F_QUEUE_MAP_CPU (1<<14)	/* queue map mirrors smp_processor_id(=
) */
 #define F_NODE          (1<<15)	/* Node memory alloc*/
+#define F_UNSAFE        (1<<16)	/* Payload of packets is left uninitia=
lized */
=20
 /* Thread control flag bits */
 #define T_STOP        (1<<0)	/* Stop run */
@@ -674,6 +675,9 @@ static int pktgen_if_show(struct seq_file *seq, voi=
d *v)
 	if (pkt_dev->flags & F_NODE)
 		seq_printf(seq, "NODE_ALLOC  ");
=20
+	if (pkt_dev->flags & F_UNSAFE)
+		seq_printf(seq, "UNSAFE  ");
+
 	seq_puts(seq, "\n");
=20
 	/* not really stopped, more like last-running-at */
@@ -1231,12 +1235,20 @@ static ssize_t pktgen_if_write(struct file *fil=
e,
 		else if (strcmp(f, "!NODE_ALLOC") =3D=3D 0)
 			pkt_dev->flags &=3D ~F_NODE;
=20
+		else if (strcmp(f, "UNSAFE") =3D=3D 0)
+			pkt_dev->flags |=3D F_UNSAFE;
+
+		else if (strcmp(f, "!UNSAFE") =3D=3D 0)
+			pkt_dev->flags &=3D ~F_UNSAFE;
+
 		else {
 			sprintf(pg_result,
 				"Flag -:%s:- unknown\nAvailable flags, (prepend ! to un-set flag):=
\n%s",
 				f,
 				"IPSRC_RND, IPDST_RND, UDPSRC_RND, UDPDST_RND, "
-				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, MPLS_RND, VID_RND, SVID=
_RND, FLOW_SEQ, IPSEC, NODE_ALLOC\n");
+				"MACSRC_RND, MACDST_RND, TXSIZE_RND, IPV6, "
+				"MPLS_RND, VID_RND, SVID_RND, FLOW_SEQ, IPSEC, "
+				"NODE_ALLOC, UNSAFE\n");
 			return count;
 		}
 		sprintf(pg_result, "OK: flags=3D0x%x", pkt_dev->flags);
@@ -2723,7 +2735,8 @@ static struct sk_buff *fill_packet_ipv4(struct ne=
t_device *odev,
=20
 	if (pkt_dev->nfrags <=3D 0) {
 		pgh =3D (struct pktgen_hdr *)skb_put(skb, datalen);
-		memset(pgh + 1, 0, datalen - sizeof(struct pktgen_hdr));
+		if (!(pkt_dev->flags & F_UNSAFE))
+			memset(pgh + 1, 0, datalen - sizeof(struct pktgen_hdr));
 	} else {
 		int frags =3D pkt_dev->nfrags;
 		int i, len;
@@ -2734,13 +2747,17 @@ static struct sk_buff *fill_packet_ipv4(struct =
net_device *odev,
 			frags =3D MAX_SKB_FRAGS;
 		if (datalen > frags * PAGE_SIZE) {
 			len =3D datalen - frags * PAGE_SIZE;
-			memset(skb_put(skb, len), 0, len);
+			if (!(pkt_dev->flags & F_UNSAFE))
+				memset(skb_put(skb, len), 0, len);
 			datalen =3D frags * PAGE_SIZE;
 		}
=20
 		i =3D 0;
 		while (datalen > 0) {
-			struct page *page =3D alloc_pages(GFP_KERNEL | __GFP_ZERO, 0);
+			struct page *page =3D alloc_pages((pkt_dev->flags & F_UNSAFE) ?
+								GFP_KERNEL :
+								GFP_KERNEL | __GFP_ZERO,
+							0);
 			skb_shinfo(skb)->frags[i].page =3D page;
 			skb_shinfo(skb)->frags[i].page_offset =3D 0;
 			skb_shinfo(skb)->frags[i].size =3D


