From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: [PATCH] IPv6: fix bug when specifying the non-exist outgoing interface
Date: Mon, 02 Jun 2008 16:12:01 +0800
Message-ID: <4843AB51.6010206@cn.fujitsu.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org
To: yoshfuji@linux-ipv6.org, davem@sunset.davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:54202 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752851AbYFBINH (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 04:13:07 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

  When specifying the outgoing interface with sendmsg, if the ipi6_addr=
 is=20
the unspecified address and the ipi6_ifindex is the not-exist interface=
,=20
it should be fail and the errno should be set ENODEV.
  Actually, it does well(sendmsg returns on success ), because the kern=
el=20
don't check the interface=A1=A3
 =20
  The patch is against 2.6.26-rc4.

Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv6/datagram.c |   11 ++++++-----
 1 files changed, 6 insertions(+), 5 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..a6d402b 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -535,6 +535,12 @@ int datagram_send_ctl(struct msghdr *msg, struct f=
lowi *fl,
 				fl->oif =3D src_info->ipi6_ifindex;
 			}
=20
+			if (fl->oif){
+				dev =3D dev_get_by_index(&init_net, fl->oif);
+				if (!dev)
+					return -ENODEV;
+			}
+
 			addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
=20
 			if (addr_type =3D=3D IPV6_ADDR_ANY)
@@ -543,11 +549,6 @@ int datagram_send_ctl(struct msghdr *msg, struct f=
lowi *fl,
 			if (addr_type & IPV6_ADDR_LINKLOCAL) {
 				if (!src_info->ipi6_ifindex)
 					return -EINVAL;
-				else {
-					dev =3D dev_get_by_index(&init_net, src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
 			}
 			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
 					   dev, 0)) {
-- 1.5.4.4


