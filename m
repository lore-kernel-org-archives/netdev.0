From: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Subject: [PATCH v2] net:Add sysctl_tcp_sg_max_skb_frags
Date: Wed, 27 Jan 2016 14:20:29 +0100
Message-ID: <1453900829-3384-1-git-send-email-hans.westgaard.ry@oracle.com>
References: <568F87AC.60405@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>,
	"David S. Miller" <davem@davemloft.net>,
	Alexey Kuznetsov <kuznet@ms2.inr.ac.ru>,
	James Morris <jmorris@namei.org>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	Patrick McHardy <kaber@trash.net>,
	"\"\"hannes@stressinduktion.org\"\"" <hannes@stressinduktion.org>,
	netdev@vger.kernel.org (open list:NETWORKING [GENERAL]),
	linux-kernel@vger.kernel.org (open list),
	"Haakon Bugge" <haakon.bugge@oracle.com>
To: unlisted-recipients:; (no To-header on input)
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:46901 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932176AbcA0NV7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 27 Jan 2016 08:21:59 -0500
In-Reply-To: <568F87AC.60405@oracle.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Devices may have limits on the number of fragments in an skb they suppo=
rt.
Current codebase uses a constant as maximum for number of fragments one
skb can hold and use.
When enabling scatter/gather and running traffic with many small messag=
es
the codebase uses the maximum number of fragments and may thereby viola=
te
the max for certain devices.
The patch introduces a global variable as max number of fragments in
scatter/gather.

Signed-off-by: Hans Westgaard Ry <hans.westgaard.ry@oracle.com>
Reviewed-by: H=C3=A5kon Bugge <haakon.bugge@oracle.com>

---
 include/net/tcp.h          |  2 ++
 net/ipv4/sysctl_net_ipv4.c | 10 ++++++++++
 net/ipv4/tcp.c             |  8 +++++---
 3 files changed, 17 insertions(+), 3 deletions(-)

diff --git a/include/net/tcp.h b/include/net/tcp.h
index f80e74c..8d18df3 100644
--- a/include/net/tcp.h
+++ b/include/net/tcp.h
@@ -285,6 +285,8 @@ extern int sysctl_tcp_invalid_ratelimit;
 extern int sysctl_tcp_pacing_ss_ratio;
 extern int sysctl_tcp_pacing_ca_ratio;
=20
+extern int sysctl_tcp_sg_max_skb_frags;
+
 extern atomic_long_t tcp_memory_allocated;
 extern struct percpu_counter tcp_sockets_allocated;
 extern int tcp_memory_pressure;
diff --git a/net/ipv4/sysctl_net_ipv4.c b/net/ipv4/sysctl_net_ipv4.c
index a0bd7a5..498dcf9 100644
--- a/net/ipv4/sysctl_net_ipv4.c
+++ b/net/ipv4/sysctl_net_ipv4.c
@@ -40,6 +40,7 @@ static int ip_ttl_min =3D 1;
 static int ip_ttl_max =3D 255;
 static int tcp_syn_retries_min =3D 1;
 static int tcp_syn_retries_max =3D MAX_TCP_SYNCNT;
+static int tcp_sg_max_skb_frags =3D MAX_SKB_FRAGS;
 static int ip_ping_group_range_min[] =3D { 0, 0 };
 static int ip_ping_group_range_max[] =3D { GID_T_MAX, GID_T_MAX };
=20
@@ -761,6 +762,15 @@ static struct ctl_table ipv4_table[] =3D {
 		.proc_handler	=3D proc_dointvec_ms_jiffies,
 	},
 	{
+		.procname	=3D "tcp_sg_max_skb_frags",
+		.data		=3D &sysctl_tcp_sg_max_skb_frags,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec_minmax,
+		.extra1		=3D &one,
+		.extra2		=3D &tcp_sg_max_skb_frags,
+	},
+	{
 		.procname	=3D "icmp_msgs_per_sec",
 		.data		=3D &sysctl_icmp_msgs_per_sec,
 		.maxlen		=3D sizeof(int),
diff --git a/net/ipv4/tcp.c b/net/ipv4/tcp.c
index c82cca1..928d2c7 100644
--- a/net/ipv4/tcp.c
+++ b/net/ipv4/tcp.c
@@ -300,7 +300,9 @@ EXPORT_SYMBOL(sysctl_tcp_wmem);
=20
 atomic_long_t tcp_memory_allocated;	/* Current allocated memory. */
 EXPORT_SYMBOL(tcp_memory_allocated);
-
+/* maximum number of fragments for tcp scatter/gather */
+int sysctl_tcp_sg_max_skb_frags __read_mostly =3D MAX_SKB_FRAGS;
+EXPORT_SYMBOL(sysctl_tcp_sg_max_skb_frags);
 /*
  * Current number of TCP sockets.
  */
@@ -938,7 +940,7 @@ new_segment:
=20
 		i =3D skb_shinfo(skb)->nr_frags;
 		can_coalesce =3D skb_can_coalesce(skb, i, page, offset);
-		if (!can_coalesce && i >=3D MAX_SKB_FRAGS) {
+		if (!can_coalesce && i >=3D sysctl_tcp_sg_max_skb_frags) {
 			tcp_mark_push(tp, skb);
 			goto new_segment;
 		}
@@ -1211,7 +1213,7 @@ new_segment:
=20
 			if (!skb_can_coalesce(skb, i, pfrag->page,
 					      pfrag->offset)) {
-				if (i =3D=3D MAX_SKB_FRAGS || !sg) {
+				if (i =3D=3D sysctl_tcp_sg_max_skb_frags || !sg) {
 					tcp_mark_push(tp, skb);
 					goto new_segment;
 				}
--=20
2.4.3
