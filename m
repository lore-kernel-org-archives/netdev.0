From: Shan Wei <shanwei@cn.fujitsu.com>
Subject: Re: [GIT PULL net-2.6] IPv6 fixes.
Date: Wed, 04 Jun 2008 10:27:45 +0800
Message-ID: <4845FDA1.1040009@cn.fujitsu.com>
References: <20080604.094917.75827853.yoshfuji@linux-ipv6.org> <4845EDB0.7030809@hp.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?B?WU9TSElGVUpJIEhpZGVha2kgLyDlkInol6Toi7HmmI4=?=
	<yoshfuji@linux-ipv6.org>, davem@davemloft.net,
	netdev@vger.kernel.org
To: Brian Haley <Brian.Haley@hp.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from cn.fujitsu.com ([222.73.24.84]:51970 "EHLO song.cn.fujitsu.com"
	rhost-flags-OK-FAIL-OK-OK) by vger.kernel.org with ESMTP
	id S1751163AbYFDC2o (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Jun 2008 22:28:44 -0400
In-Reply-To: <4845EDB0.7030809@hp.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Brian Haley =E5=86=99=E9=81=93:
> YOSHIFUJI Hideaki / =E5=90=89=E8=97=A4=E8=8B=B1=E6=98=8E wrote:
>> Please consider pulling following fixes on top of net-2.6 tree
>> available at
>>     git://git.linux-ipv6.org/gitroot/yoshfuji/linux-2.6-fix.git
>> net-2.6-misc-20080604b
>>
> ...
>> commit c878bc2da63acd3b80ba4cf428702f6e98c55b3c
>> Author: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>> Date:   Mon Jun 2 18:45:23 2008 +0900
>>
>>     [IPv6]: Check outgoing interface even if source address is
>> unspecified.
>>         The outgoing interface index (ipi6_ifindex) in IPV6_PKTINFO
>>     ancillary data, is not checked if the source address (ipi6_addr)
>>     is unspecified.  If the ipi6_ifindex is the not-exist interface,
>>     it should be fail and the errno should be set ENODEV.
>>         Based on patch from Shan Wei <shanwei@cn.fujitsu.com>.
>>         Signed-off-by: Shan Wei <shanwei@cn.fujitsu.com>
>>     Signed-off-by: YOSHIFUJI Hideaki <yoshfuji@linux-ipv6.org>
>>
>> diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
>> index 94fa6ae..76d4ab4 100644
>> --- a/net/ipv6/datagram.c
>> +++ b/net/ipv6/datagram.c
>> @@ -535,27 +535,29 @@ int datagram_send_ctl(struct msghdr *msg, stru=
ct
>> flowi *fl,
>>                  fl->oif =3D src_info->ipi6_ifindex;
>>              }
>> =20
>> -            addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
>> +            if (fl->oif) {
>> +                dev =3D dev_get_by_index(&init_net, fl->oif);
>> +                if (!dev)
>> +                    return -ENODEV;
>> +            }
>> =20
>> -            if (addr_type =3D=3D IPV6_ADDR_ANY)
>> +            addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
>> +            if (addr_type =3D=3D IPV6_ADDR_ANY) {
>> +                if (dev)
>> +                    dev_put(dev);
>>                  break;
>> -
>> -            if (addr_type & IPV6_ADDR_LINKLOCAL) {
>> -                if (!src_info->ipi6_ifindex)
>> -                    return -EINVAL;
>> -                else {
>> -                    dev =3D dev_get_by_index(&init_net,
>> src_info->ipi6_ifindex);
>> -                    if (!dev)
>> -                        return -ENODEV;
>> -                }
>>              }
>> -            if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
>> +
>> +            if (((addr_type & IPV6_ADDR_LINKLOCAL) &&
>> +                 !src_info->ipi6_ifindex) ||
>> +                !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
>=20
> I think this !src_info->ipi6_ifindex here should be !fl->oif - that w=
ill
> have been assigned correctly if it was zero and src_info->ipi6_ifinde=
x
> was passed-in, and is what we used to do the device lookup.

the attached patch fix it.


Signed-off-by: Shan Wei<shanwei@cn.fujitsu.com>
---
 net/ipv6/datagram.c |   30 +++++++++++++++++-------------
 1 files changed, 17 insertions(+), 13 deletions(-)

diff --git a/net/ipv6/datagram.c b/net/ipv6/datagram.c
index 94fa6ae..f3c7529 100644
--- a/net/ipv6/datagram.c
+++ b/net/ipv6/datagram.c
@@ -508,8 +508,6 @@ int datagram_send_ctl(struct msghdr *msg, struct fl=
owi *fl,
 	int err =3D 0;
=20
 	for (cmsg =3D CMSG_FIRSTHDR(msg); cmsg; cmsg =3D CMSG_NXTHDR(msg, cms=
g)) {
-		int addr_type;
-		struct net_device *dev =3D NULL;
=20
 		if (!CMSG_OK(msg, cmsg)) {
 			err =3D -EINVAL;
@@ -522,6 +520,10 @@ int datagram_send_ctl(struct msghdr *msg, struct f=
lowi *fl,
 		switch (cmsg->cmsg_type) {
 		case IPV6_PKTINFO:
 		case IPV6_2292PKTINFO:
+		     {
+			int addr_type;
+			struct net_device *dev =3D NULL;
+
 			if (cmsg->cmsg_len < CMSG_LEN(sizeof(struct in6_pktinfo))) {
 				err =3D -EINVAL;
 				goto exit_f;
@@ -534,22 +536,23 @@ int datagram_send_ctl(struct msghdr *msg, struct =
flowi *fl,
 					return -EINVAL;
 				fl->oif =3D src_info->ipi6_ifindex;
 			}
+		=09
+			if (fl->oif) {
+				dev =3D dev_get_by_index(&init_net, fl->oif);
+				if (!dev)
+					return -ENODEV;
+			}
=20
 			addr_type =3D ipv6_addr_type(&src_info->ipi6_addr);
=20
-			if (addr_type =3D=3D IPV6_ADDR_ANY)
+			if (addr_type =3D=3D IPV6_ADDR_ANY) {
+				if (dev)
+					dev_put(dev);
 				break;
-
-			if (addr_type & IPV6_ADDR_LINKLOCAL) {
-				if (!src_info->ipi6_ifindex)
-					return -EINVAL;
-				else {
-					dev =3D dev_get_by_index(&init_net, src_info->ipi6_ifindex);
-					if (!dev)
-						return -ENODEV;
-				}
 			}
-			if (!ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
+	=09
+			if (((addr_type & IPV6_ADDR_LINKLOCAL) && !dev) ||
+			    !ipv6_chk_addr(&init_net, &src_info->ipi6_addr,
 					   dev, 0)) {
 				if (dev)
 					dev_put(dev);
@@ -561,6 +564,7 @@ int datagram_send_ctl(struct msghdr *msg, struct fl=
owi *fl,
=20
 			ipv6_addr_copy(&fl->fl6_src, &src_info->ipi6_addr);
 			break;
+		    }
=20
 		case IPV6_FLOWINFO:
 			if (cmsg->cmsg_len < CMSG_LEN(4)) {
--=20
1.5.4.4


