From: David Gibson <dgibson@redhat.com>
Subject: RFC: rtnetlink problems with Cisco enic and VFs
Date: Tue, 22 Apr 2014 14:14:25 +1000
Message-ID: <20140422141425.127dabd3c63482a6a655469e@redhat.com>
Mime-Version: 1.0
Content-Type: multipart/signed; protocol="application/pgp-signature";
 micalg="PGP-SHA1";
 boundary="Signature=_Tue__22_Apr_2014_14_14_25_+1000_pKu5L=B4irXzXZ=n"
Cc: Christian Benvenuti <benve@cisco.com>,
	Sujith Sankar <ssujith@cisco.com>,
	Govindarajulu Varadarajan <govindarajulu90@gmail.com>,
	Neel Patel <neepatel@cisco.com>,
	Nishank Trivedi <nistrive@cisco.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36451 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750705AbaDVEOf (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 22 Apr 2014 00:14:35 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

--Signature=_Tue__22_Apr_2014_14_14_25_+1000_pKu5L=B4irXzXZ=n
Content-Type: text/plain; charset=US-ASCII
Content-Disposition: inline
Content-Transfer-Encoding: quoted-printable

I believe I've found a problem with netlink handling which can be
triggered on Cisco enic devices with a large number (30-40) of virtual
functions.  I believe this is the cause of a real customer problem
we've seen.

 * When requesting a list of interfaces with RTM_GETLINK, enic devices
   (and currently, _only_ enic devices) report IFLA_VF_PORTS
   information=20

 * IFLA_VF_PORTS information has at least 90 bytes ber virtual function

 * Unlike IFLA_VFINFO_LIST, the ports information is always reported,
   regardless of the setting of the IFLA_EXT_MASK parameter

 * When IFLA_EXT_MASK is not specified, the reply packets have maximum
   size NLMSG_GOODSIZE (4k - overheads)

 * If there are enough virtual functions the IFLA_VF_PORTS information
   can cause a single interface's info to exceed NLMSG_GOODSIZE

 * The number of interfaces necessary to trigger this is reduced
   substantially if both IPv4 and IPv6 IFLA_AF_SPEC information is
   present (~972 bytes)

 * If the dump function returns -EMSGSIZE on the first message in a
   packet, netlink_dump() incorrectly assumes the listing is done,
   omitting information for that interface and any later ones.

 * This can cause getifaddrs(3) to go into an infinite loop

 * 'ip link' is not affected, because it supplies IFLA_EXT_MASK which
   triggers rtnl_calcit() to recalculate the required packet size to
   greater than NLMSG_GOODSIZE.


I can see several possible ways to fix this, but they all have
possible problems.  I'm hoping someone here can determine which, if
any, are real problems, and therefore what's the right approach to fix
this.

    A) Always calculate the RTM_NEWLINK packet size, rather than
       assuming NLMSG_GOODSIZE.
    Problem: The NLMSG_GOODSIZE limit was introduced to stop broken
             user tools with limited buffers encountering problems
             (see 115c9b81928360d769a76c632bae62d15206a94a). This
             approach might mean that such tools break again.

    B) Don't issue the VF port information when RTEXT_FILTER_VF isn't
       set
    Problem: Do tools using the port information already set this flag?

    C) Don't include the VF port info when listing interfaces, only
       when doing GETLINK on a specific interface.
    Problem: As (B), plus it's ugly.

    D) Detect the case when the first interface in a packet doesn't fit
       reallocate the packet buffer
    Problem: As (A), plus more complicated.

As an interim band-aid, here's a patch which adds a WARN_ON() in this
situation, which will at least make the problem easier to locate for
the next person to encounter it.

From: David Gibson <david@gibson.dropbear.id.au>
Subject: [PATCH] rtnetlink: Warn when interface's information won't fit
         in our packet

Without IFLA_EXT_MASK specified, the information reported for a single
interface in response to RTM_GETLINK is expected to fit within a netlink
packet of NLMSG_GOODSIZE.

If it doesn't, however, things will go badly wrong,  When listing all
interfaces, netlink_dump() will incorrectly treat -EMSGSIZE on the first
message in a packet as the end of the listing and omit information for
that interface and all subsequent ones.  This can cause getifaddrs(3) to
enter an infinite loop.

This patch won't fix the problem, but it will WARN_ON() making it
easier to track down what's going wrong.


Signed-off-by: David Gibson <david@gibson.dropbear.id.au>
---
 net/core/rtnetlink.c | 16 +++++++++++-----
 1 file changed, 11 insertions(+), 5 deletions(-)

diff --git a/net/core/rtnetlink.c b/net/core/rtnetlink.c
index d4ff417..5331db2 100644
--- a/net/core/rtnetlink.c
+++ b/net/core/rtnetlink.c
@@ -1198,6 +1198,7 @@ static int rtnl_dump_ifinfo(struct sk_buff *skb,
struct netlink_callback *cb) struct hlist_head *head;
 	struct nlattr *tb[IFLA_MAX+1];
 	u32 ext_filter_mask =3D 0;
+	int err;
=20
 	s_h =3D cb->args[0];
 	s_idx =3D cb->args[1];
@@ -1218,11 +1219,16 @@ static int rtnl_dump_ifinfo(struct sk_buff
*skb, struct netlink_callback *cb) hlist_for_each_entry_rcu(dev, head,
index_hlist) { if (idx < s_idx)
 				goto cont;
-			if (rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
-					     NETLINK_CB
(cb->skb).portid,
-					     cb->nlh->nlmsg_seq, 0,
-					     NLM_F_MULTI,
-					     ext_filter_mask) <=3D 0)
+			err =3D rtnl_fill_ifinfo(skb, dev, RTM_NEWLINK,
+					       NETLINK_CB
(cb->skb).portid,
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

--Signature=_Tue__22_Apr_2014_14_14_25_+1000_pKu5L=B4irXzXZ=n
Content-Type: application/pgp-signature

-----BEGIN PGP SIGNATURE-----
Version: GnuPG v2.0.22 (GNU/Linux)

iQIcBAEBAgAGBQJTVeyhAAoJEGw4ysog2bOSKWwQANzlv+soba8ZjxAjea0OASEW
NDZVq/gEp9TwMg7T34McsiLlpAvlds2kGa408L1fIVeH2hP47yjjg7nfBRN/wD/1
NOJ5WpXA5FU0zHJQldKZP78NqeTwoElV96T2MP7NYxat8+MduoPfFtebEEpAZgb9
dHyPa1jiKyADOMQ7aQeEsV/TiClu1q3+H5KihYq2dAGgk1jwzoF4FGz01kfyObx4
mgNiksnUBkmxqV+fi6tF54KwP2U2+8AMyIQ0kwpXxzP3IdLQqYlzr6MMljhnoTM9
fQGkwMn/8RM4gOiaYtAcDxpIJl07hNkoD319xVvxjDHz9LoB/oqABLrQdvfhE732
hTDjI8s0qBIw1NWjOgN7rlucqldO35qqPHo/GQy1q2mJEZ96BqlnyAJMoOFbojUf
QDWSW4Y88jGTF9j7naamrW0P6sBqau309bV6X2Wl9+mUus271hWtMWzpJcgx5LyD
UJHH8SbsJnLI+ZvdQsp53+AZQbTxJ8bg2+ueHmj2dXWAeZhAyHBOGDC2moM3XZzg
gPpt5LgVG98rVQ4z0oZhM3XYSlpBg4R02kodQMSqxt38FIqguekUIJ9HUVrSdjbV
WGsn2lXyvg8WHP8fxbdOWnUhxbEhmaQZvX8l66CUJh1oiD3ZrHq92/NgaoIqNWwM
ratgtCZmcxbL/Tb72csR
=gaM/
-----END PGP SIGNATURE-----

--Signature=_Tue__22_Apr_2014_14_14_25_+1000_pKu5L=B4irXzXZ=n--
