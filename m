From: Shan Wei <shanwei88@gmail.com>
Subject: [PATCH net-next 1/2] net: neighbour: prohibit negative value for
 unres_qlen_bytes parameter
Date: Wed, 05 Dec 2012 12:49:15 +0800
Message-ID: <50BED24B.1030205@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Shan Wei <shanwei88@gmail.com>
To: David Miller <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	NetDev <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f46.google.com ([209.85.160.46]:63188 "EHLO
	mail-pb0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752808Ab2LEEt1 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 4 Dec 2012 23:49:27 -0500
Received: by mail-pb0-f46.google.com with SMTP id wy7so3362612pbc.19
        for <netdev@vger.kernel.org>; Tue, 04 Dec 2012 20:49:26 -0800 (PST)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Shan Wei <davidshan@tencent.com>

unres_qlen_bytes and unres_qlen are int type.
But multiple relation(unres_qlen_bytes =3D unres_qlen * SKB_TRUESIZE(ET=
H_FRAME_LEN))
will cause type overflow when seting unres_qlen. e.g.

$ echo 1027506 > /proc/sys/net/ipv4/neigh/eth1/unres_qlen
$ cat /proc/sys/net/ipv4/neigh/eth1/unres_qlen
1182657265
$ cat /proc/sys/net/ipv4/neigh/eth1/unres_qlen_bytes=20
-2147479756

The gutted value is not that we setting=E3=80=82
But user/administrator don't know this is caused by int type overflow.

what's more, it is meaningless and even dangerous that unres_qlen_bytes=
 is set
with negative number. Because, for unresolved neighbour address, kernel=
 will cache packets
without limit in __neigh_event_send()(e.g. (u32)-1 =3D 2GB).


Signed-off-by: Shan Wei <davidshan@tencent.com>
---
 net/core/neighbour.c |   17 ++++++++++++-----
 1 files changed, 12 insertions(+), 5 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f1c0c2e..36fc692 100644
--- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -62,6 +62,9 @@ static void __neigh_notify(struct neighbour *n, int t=
ype, int flags);
 static void neigh_update_notify(struct neighbour *neigh);
 static int pneigh_ifdown(struct neigh_table *tbl, struct net_device *d=
ev);
=20
+static int zero;
+static int unres_qlen_max =3D INT_MAX / SKB_TRUESIZE(ETH_FRAME_LEN);
+
 static struct neigh_table *neigh_tables;
 #ifdef CONFIG_PROC_FS
 static const struct file_operations neigh_stat_seq_fops;
@@ -1787,8 +1790,7 @@ static int neightbl_fill_parms(struct sk_buff *sk=
b, struct neigh_parms *parms)
 	    nla_put_u32(skb, NDTPA_QUEUE_LENBYTES, parms->queue_len_bytes) ||
 	    /* approximative value for deprecated QUEUE_LEN (in packets) */
 	    nla_put_u32(skb, NDTPA_QUEUE_LEN,
-			DIV_ROUND_UP(parms->queue_len_bytes,
-				     SKB_TRUESIZE(ETH_FRAME_LEN))) ||
+			parms->queue_len_bytes / SKB_TRUESIZE(ETH_FRAME_LEN)) ||
 	    nla_put_u32(skb, NDTPA_PROXY_QLEN, parms->proxy_qlen) ||
 	    nla_put_u32(skb, NDTPA_APP_PROBES, parms->app_probes) ||
 	    nla_put_u32(skb, NDTPA_UCAST_PROBES, parms->ucast_probes) ||
@@ -2777,9 +2779,13 @@ static int proc_unres_qlen(ctl_table *ctl, int w=
rite, void __user *buffer,
 	int size, ret;
 	ctl_table tmp =3D *ctl;
=20
+	tmp.extra1 =3D &zero;
+	tmp.extra2 =3D &unres_qlen_max;
 	tmp.data =3D &size;
-	size =3D DIV_ROUND_UP(*(int *)ctl->data, SKB_TRUESIZE(ETH_FRAME_LEN))=
;
-	ret =3D proc_dointvec(&tmp, write, buffer, lenp, ppos);
+
+	size =3D *(int *)ctl->data / SKB_TRUESIZE(ETH_FRAME_LEN);
+	ret =3D proc_dointvec_minmax(&tmp, write, buffer, lenp, ppos);
+
 	if (write && !ret)
 		*(int *)ctl->data =3D size * SKB_TRUESIZE(ETH_FRAME_LEN);
 	return ret;
@@ -2865,7 +2871,8 @@ static struct neigh_sysctl_table {
 			.procname	=3D "unres_qlen_bytes",
 			.maxlen		=3D sizeof(int),
 			.mode		=3D 0644,
-			.proc_handler	=3D proc_dointvec,
+			.extra1		=3D &zero,
+			.proc_handler   =3D proc_dointvec_minmax,
 		},
 		[NEIGH_VAR_PROXY_QLEN] =3D {
 			.procname	=3D "proxy_qlen",
--=20
1.7.1
