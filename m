From: David Gibson <dgibson@redhat.com>
Subject: Re: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 14:17:50 +1000
Message-ID: <20140422141750.9fa985b939c0967ab8384b23@redhat.com>
References: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__22_Apr_2014_14_17_50_+1000_S1PGm2QClA74po=n"
Cc: netdev@vger.kernel.org, Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: David Gibson <dgibson@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:22555 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750716AbaDVERy (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 00:17:54 -0400
In-Reply-To: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__22_Apr_2014_14_17_50_+1000_S1PGm2QClA74po=n
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

On Tue, 22 Apr 2014 14:14:25 +1000
David Gibson <dgibson@redhat.com> wrote:
[snip]

Sorry, had the wrong mailer setting, which mangled the patch.  Trying
again:

>From a8c1396c45449c0692560844d148abe7d5d1c2cc Mon Sep 17 00:00:00 2001
From: David Gibson <david@gibson.dropbear.id.au>
Date: Tue, 22 Apr 2014 14:13:16 +1000
Subject: [PATCH] rtnetlink: Warn when interface's information won't fit in =
our
 packet

Without IFLA_EXT_MASK specified, the information reported for a single
interface in response to RTM_GETLINK is expected to fit within a netlink
packet of NLMSG_GOODSIZE.

If it doesn't, however, things will go badly wrong,  When listing all
interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
message in a packet as the end of the listing and omit information for
that interface and all subsequent ones.  This can cause getifaddrs(3) to
enter an infinite loop.

This patch won't fix the problem, but it will WARN_ON() making it easier to
track down what's going wrong.


Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 net/core/rtnetlink.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4ff417..5331db2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1198,6 +1198,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, stru=
ct netlink_callback *cb)
 	struct hlist_head *head;
 	struct nlattr *tb[IFLA_MAX+1];
 	u32 ext_filter_mask =3D 0;
+	int err;
=20
 	s_h =3D cb->args[0];
 	s_idx =3D cb->args[1];
@@ -1218,11 +1219,16 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb, st=
ruct netlink_callback *cb)
 		hlist_for_each_entry_rcu(dev, head, index_hlist) {
 			if (idx < s_idx)
 				goto cont;
-			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
-					     NETLINK_CB(cb->skb).portid,
-					     cb->nlh->nlmsg_seq, 0,
-					     NLM_F_MULTI,
-					     ext_filter_mask) <=3D 0)
+			err =3D rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
+					       NETLINK_CB(cb->skb).portid,
+					       cb->nlh->nlmsg_seq, 0,
+					       NLM_F_MULTI,
+					       ext_filter_mask);
+			/* If we ran out of room on the first message,
+			 * we're in trouble */
+			WARN_ON((err =3D=3D -EMSGSIZE) && (skb->len =3D=3D 0));
+
+			if (err <=3D 0)
 				goto out;
=20
 			nl_dump_check_consistent(cb, nlmsg_hdr(skb));
--=20
1.9.0



--=20
David Gibson <dgibson@redhat.com>

--Signature=_Tue__22_Apr_2014_14_17_50_+1000_S1PGm2QClA74po=n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVe1uAAoJEGw4ysog2bOSn4AP/1rKx2t/vgfcMjrNzBgi1C1R
fCumOVa0TPfDfP26g+6PYSkauaerkUp1hjPh17TTZpsbJ2VXAv7/zjjJKywGEiXT
8vunuHCTA8m4tMcEUMREoFp64vj6wUBvWIG6P4PqDQXTLutNXBdHYVlI3Gu/So/t
EjJS1E+8QUSF0Bb+ojevLoQg/EEpbICQUMwv7vJVFaKJP/+Zk6hikm+pkqC466/1
r1o4UCYLxJ54em8x4nvyyzeZyAxJ9wO5CLMPqhYAcXXbHXxXSZSTz+PXcSJpQRg1
VOVj+DcbzyznIXP3SIIZJ0e9m6PY7iOBfBQTcSt7ggriS1sma7eRwv3zlG+WArcr
UMLXUpeCc3KyXbugAo6D5KPiNlI/S2LXYKUekBbVb2pu9JDBAi1MUhfsYB+pQMHy
5zpBkagUeA8mab2lPq3r3aQAE3iAEt8vFSD18BNc0v8lOve4mt9B9/lTaQlZnawO
zLoeNMLhDGEU6O1dS6/1OCJ35AmkfiO+xZF9KTsTE1JcLLcGjElq35kjPpl1cVX/
D5ktMUR9Kod1SyKxZ0kI5C3UM5D9pwzoZbPJC1rNoYJcUPqj90DacqoAVY58M24x
HM+7Jm3HMxttgOACiDMWzJB+QL0DDkQi6lVNs4ETru670iaf+yvnTJ7GgUYncper
FPGDHSGnITdd/yDSVVCE
=NgOy
-----END PGP SIGNATURE-----

--Signature=_Tue__22_Apr_2014_14_17_50_+1000_S1PGm2QClA74po=n--
