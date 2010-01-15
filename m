From: Cosmin Ratiu <cratiu@ixiacom.com>
Subject: [RFC PATCH] extend RTM_GETNEIGH to allow getting more precise information
Date: Fri, 15 Jan 2010 18:42:59 +0200
Message-ID: <201001151842.59813.cratiu@ixiacom.com>
Mime-Version: 1.0
Content-Type: Multipart/Mixed;
  boundary="Boundary-00=_TsJUL3GYxoORcq0"
Cc: ixlk-cr@farscape.ixiacom.com,
	Pinaki Chakrabarti <pchakrabarti@ixiacom.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from ixro-out-rtc.ixiacom.com ([92.87.192.98]:15063 "EHLO
	ixro-ex1.ixiacom.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753159Ab0AOQnD (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Jan 2010 11:43:03 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Boundary-00=_TsJUL3GYxoORcq0
Content-Type: Text/Plain;
  charset="utf-8"
Content-Transfer-Encoding: 7bit

Hello.

Please have a look at this patch which tries to solve a problem we 
encountered.

The background is that RTM_GETNEIGH netlink message is used to get a complete 
dump of a neighbor table. Sometimes, that's too much (especially when you have 
a lot of neighbors). This patch allows one to specify the IPv4/6 address of a 
neighbor and the device index through which it is accessible in order to 
obtain only that entry.

If you have other suggestions on how to accomplish this task, please let us 
know.

Thanks,
Cosmin.

--Boundary-00=_TsJUL3GYxoORcq0
Content-Type: text/x-patch;
  charset="utf-8";
  name="0001-Extend-RTM_GETNEIGH-to-allow-getting-more-precise-in.patch"
Content-Transfer-Encoding: quoted-printable
Content-Disposition: inline;
	filename="0001-Extend-RTM_GETNEIGH-to-allow-getting-more-precise-in.patch"

=46rom beb2cd45109f28b9067d7fa902e49cbbc7667ff5 Mon Sep 17 00:00:00 2001
=46rom: Cosmin Ratiu <cratiu@ixiacom.com>
Date: Fri, 15 Jan 2010 18:34:39 +0200
Subject: [PATCH] Extend RTM_GETNEIGH to allow getting more precise informat=
ion.

RTM_GETNEIGH makes a complete dump of the neighbour table for a given
net and address family. The patch allows requests for a single entry
by specifying the device and IP address. This should increase
performance when there are many neighbour entries and a specific one is
desired.

Signed-off-by: Pinaki Chakrabarti <pchakrabarti@ixiacom.com>
Signed-off-by: Cosmin Ratiu <cratiu@ixiacom.com>
=2D--
 net/core/neighbour.c |   75 ++++++++++++++++++++++++++++++++++++++++------=
=2D--
 1 files changed, 61 insertions(+), 14 deletions(-)

diff --git a/net/core/neighbour.c b/net/core/neighbour.c
index f35377b..243fa5b 100644
=2D-- a/net/core/neighbour.c
+++ b/net/core/neighbour.c
@@ -2119,24 +2119,71 @@ out:
 static int neigh_dump_info(struct sk_buff *skb, struct netlink_callback *c=
b)
 {
 	struct neigh_table *tbl;
=2D	int t, family, s_t;
+	struct net *net =3D sock_net(skb->sk);
+	const struct nlmsghdr *nlh =3D cb->nlh;
+	int min_len =3D NLMSG_LENGTH(sizeof(struct ndmsg));
+	int family =3D ((struct rtgenmsg *) nlmsg_data(nlh))->rtgen_family;
=20
=2D	read_lock(&neigh_tbl_lock);
=2D	family =3D ((struct rtgenmsg *) nlmsg_data(cb->nlh))->rtgen_family;
=2D	s_t =3D cb->args[0];
+	if (nlh->nlmsg_len <=3D min_len) {
+		struct neigh_table *tbl;
+		int t, s_t;
=20
=2D	for (tbl =3D neigh_tables, t =3D 0; tbl; tbl =3D tbl->next, t++) {
=2D		if (t < s_t || (family && tbl->family !=3D family))
=2D			continue;
=2D		if (t > s_t)
=2D			memset(&cb->args[1], 0, sizeof(cb->args) -
=2D						sizeof(cb->args[0]));
=2D		if (neigh_dump_table(tbl, skb, cb) < 0)
+		read_lock(&neigh_tbl_lock);
+		s_t =3D cb->args[0];
+
+		for (tbl =3D neigh_tables, t =3D 0; tbl; tbl =3D tbl->next, t++) {
+			if (t < s_t || (family && tbl->family !=3D family))
+				continue;
+			if (t > s_t)
+				memset(&cb->args[1], 0, sizeof(cb->args) -
+							sizeof(cb->args[0]));
+			if (neigh_dump_table(tbl, skb, cb) < 0)
+				break;
+		}
+		read_unlock(&neigh_tbl_lock);
+		cb->args[0] =3D t;
+	} else {
+		char key[16] =3D {0};
+		struct ndmsg *ndm =3D NULL;
+		struct net_device *dev =3D NULL;
+		struct rtattr *attr =3D NULL;
+		int attrlen;
+		struct neighbour *n;
+
+		if (cb->args[0])
+			goto out;
+		cb->args[0] =3D 1;
+
+		ndm =3D NLMSG_DATA(nlh);
+		if (!(dev =3D dev_get_by_index(net, ndm->ndm_ifindex)))
+			goto out;
+
+		attrlen =3D nlh->nlmsg_len - NLMSG_ALIGN(min_len);
+		attr =3D (void*)nlh + NLMSG_ALIGN(min_len);
+		if (!RTA_OK(attr, attrlen) || attr->rta_type !=3D NDA_DST)
+			goto out;
+		memcpy(key, RTA_DATA(attr), attr->rta_len);
+
+		/* look for the neighbor */
+		read_lock(&neigh_tbl_lock);
+		for (tbl =3D neigh_tables; tbl; tbl =3D tbl->next) {
+			if (tbl->family !=3D family)
+				continue;
+			n =3D neigh_lookup(tbl, key, dev);
+			if (!n)
+				continue;
+			if (n->nud_state & NUD_CONNECTED) {
+				neigh_fill_info(skb, n, NETLINK_CB(cb->skb).pid,
+						nlh->nlmsg_seq, RTM_NEWNEIGH, 0);
+				neigh_release(n);
+			}
 			break;
+		}
+		read_unlock(&neigh_tbl_lock);
+out:
+		if (dev)
+			dev_put(dev);
 	}
=2D	read_unlock(&neigh_tbl_lock);
=2D
=2D	cb->args[0] =3D t;
 	return skb->len;
 }
=20
=2D-=20
1.6.5


--Boundary-00=_TsJUL3GYxoORcq0--
