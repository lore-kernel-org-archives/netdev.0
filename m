From: =?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
Subject: [PATCH] iproute2: List interfaces without net address by default
Date: Wed,  3 Oct 2012 16:42:41 +0200
Message-ID: <1349275361-9271-1-git-send-email-ppisar@redhat.com>
References: <1348565799-20080-1-git-send-email-ppisar@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: <netdev@vger.kernel.org>,
	=?UTF-8?q?Petr=20P=C3=ADsa=C5=99?= <ppisar@redhat.com>
To: <shemminger@vyatta.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:48965 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750991Ab2JCOnA (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 3 Oct 2012 10:43:00 -0400
In-Reply-To: <1348565799-20080-1-git-send-email-ppisar@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This fixes regression in iproute2-3.5.1 when `ip addr show' skipped
interfaces without network layer address.

Wrong output:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP qlen 1000
    link/ether 00:50:54:00:0f:03 brd ff:ff:ff:ff:ff:ff
    inet 10.34.25.198/23 brd 10.34.25.255 scope global eth0
    inet6 2620:52:0:2219:250:54ff:fe00:f03/64 scope global dynamic
       valid_lft 2591919sec preferred_lft 604719sec
    inet6 fe80::250:54ff:fe00:f03/64 scope link
       valid_lft forever preferred_lft forever

Expected output:
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 16436 qdisc noqueue state UNKNOWN
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc pfifo_fast st=
ate UP qlen 1000
    link/ether 00:50:54:00:0f:03 brd ff:ff:ff:ff:ff:ff
    inet 10.34.25.198/23 brd 10.34.25.255 scope global eth0
    inet6 2620:52:0:2219:250:54ff:fe00:f03/64 scope global dynamic
       valid_lft 2591896sec preferred_lft 604696sec
    inet6 fe80::250:54ff:fe00:f03/64 scope link
       valid_lft forever preferred_lft forever
5: veth1: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 100=
0
    link/ether 8a:ec:35:34:1f:a8 brd ff:ff:ff:ff:ff:ff
6: veth0: <BROADCAST,MULTICAST> mtu 1500 qdisc noop state DOWN qlen 100=
0
    link/ether 2e:97:ef:77:40:82 brd ff:ff:ff:ff:ff:ff

Signed-off-by: Petr P=C3=ADsa=C5=99 <ppisar@redhat.com>
---
 ip/ipaddress.c | 10 ++++++++--
 1 file changed, 8 insertions(+), 2 deletions(-)

diff --git a/ip/ipaddress.c b/ip/ipaddress.c
index 6c11ce4..5498f46 100644
--- a/ip/ipaddress.c
+++ b/ip/ipaddress.c
@@ -884,6 +884,7 @@ static void ipaddr_filter(struct nlmsg_chain *linfo=
, struct nlmsg_chain *ainfo)
 	lp =3D &linfo->head;
 	while ( (l =3D *lp) !=3D NULL) {
 		int ok =3D 0;
+		int missing_net_address =3D 1;
 		struct ifinfomsg *ifi =3D NLMSG_DATA(&l->h);
 		struct nlmsg_list *a;
=20
@@ -891,8 +892,10 @@ static void ipaddr_filter(struct nlmsg_chain *linf=
o, struct nlmsg_chain *ainfo)
 			struct nlmsghdr *n =3D &a->h;
 			struct ifaddrmsg *ifa =3D NLMSG_DATA(n);
=20
-			if (ifa->ifa_index !=3D ifi->ifi_index ||
-			    (filter.family && filter.family !=3D ifa->ifa_family))
+			if (ifa->ifa_index !=3D ifi->ifi_index)
+				continue;
+			missing_net_address =3D 0;
+			if (filter.family && filter.family !=3D ifa->ifa_family)
 				continue;
 			if ((filter.scope^ifa->ifa_scope)&filter.scopemask)
 				continue;
@@ -927,6 +930,9 @@ static void ipaddr_filter(struct nlmsg_chain *linfo=
, struct nlmsg_chain *ainfo)
 			ok =3D 1;
 			break;
 		}
+		if (missing_net_address &&
+		    (filter.family =3D=3D AF_UNSPEC || filter.family =3D=3D AF_PACKE=
T))
+			ok =3D 1;
 		if (!ok) {
 			*lp =3D l->next;
 			free(l);
--=20
1.7.11.7
