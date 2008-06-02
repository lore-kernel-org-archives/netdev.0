From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [PATCH v2] IPv6: fix bug when specifying the non-exist outgoing
 interface
Date: Mon, 02 Jun 2008 16:52:16 +0800
Message-ID: <4843B4C0.2020705@cn.fujitsu.com>
References: <4843AB51.6010206@cn.fujitsu.com> <20080602.172009.84304151.yoshfuji@linux-ipv6.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=GB2312
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: davem@davemloft.net, netdev@vger.kernel.org
To: =?GB2312?B?WU9TSElGVUpJIEhpZGVha2kgLyC8qszZ06LD9w==?=
	<yoshfuji@linux-ipv6.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:60564 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1752103AbYFBIxN (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 2 Jun 2008 04:53:13 -0400
In-Reply-To: <20080602.172009.84304151.yoshfuji@linux-ipv6.org>
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
net/ipv6/datagram.c | 24 +++++++++++++++---------
1 files changed, 15 insertions(+), 9 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..47b85cc 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -534,20 +534,26 @@ int datagram_send_ctl(struct msghdr *msg, struct
flowi *fl,
return -EINVAL;
fl->oif =3D src_info->ipi6_ifindex;
}
+
+ if (fl->oif) {
+ dev =3D dev_get_by_index(&init_net, fl->oif);
+ if (!dev)
+ return -ENODEV;
+ }

addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);

- if (addr_type =3D=3D IPV6_ADDR_ANY)
+ if (addr_type =3D=3D IPV6_ADDR_ANY) {
+ if (dev)
+ dev_put(dev);
break;
+ }

- if (addr_type & IPV6_ADDR_LINKLOCAL) {
- if (!src_info->ipi6_ifindex)
- return -EINVAL;
- else {
- dev =3D dev_get_by_index(&init_net, src_info->ipi6_ifindex);
- if (!dev)
- return -ENODEV;
- }
+ if ((addr_type & IPV6_ADDR_LINKLOCAL) &&
+ !src_info->ipi6_ifindex) {
+ if (dev)
+ dev_put(dev);
+ return -EINVAL;
}
if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
dev, 0)) {
--=20
1.5.4.4

