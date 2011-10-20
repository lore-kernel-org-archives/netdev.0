From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: allow CAP_NET_RAW to set socket options IP{,V6}_TRANSPARENT
Date: Thu, 20 Oct 2011 15:10:14 -0700
Message-ID: <1319148614-6739-1-git-send-email-zenczykowski@gmail.com>
References: <20111020.003458.1034042223691970343.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yx0-f174.google.com ([209.85.213.174]:61550 "EHLO
	mail-yx0-f174.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750927Ab1JTWKZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 20 Oct 2011 18:10:25 -0400
Received: by yxl42 with SMTP id 42so710929yxl.19
        for <netdev@vger.kernel.org>; Thu, 20 Oct 2011 15:10:24 -0700 (PDT)
In-Reply-To: <20111020.003458.1034042223691970343.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Up till now the IP{,V6}_TRANSPARENT socket options (which actually set
the same bit in the socket struct) have required CAP_NET_ADMIN
privileges to set or clear the option.

- we make clearing the bit not require any privileges.
- we allow CAP_NET_ADMIN to set the bit (as before this change)
- we allow CAP_NET_RAW to set this bit, because raw
  sockets already pretty much effectively allow you
  to emulate socket transparency.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/linux/capability.h |    3 ++-
 net/ipv4/ip_sockglue.c     |    2 +-
 net/ipv6/ipv6_sockglue.c   |    2 +-
 3 files changed, 4 insertions(+), 3 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index c421123..a63d13d 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -198,7 +198,7 @@ struct cpu_vfs_cap_data {
 /* Allow modification of routing tables */
 /* Allow setting arbitrary process / process group ownership on
    sockets */
-/* Allow binding to any address for transparent proxying */
+/* Allow binding to any address for transparent proxying (also via NET=
_RAW) */
 /* Allow setting TOS (type of service) */
 /* Allow setting promiscuous mode */
 /* Allow clearing driver statistics */
@@ -210,6 +210,7 @@ struct cpu_vfs_cap_data {
=20
 /* Allow use of RAW sockets */
 /* Allow use of PACKET sockets */
+/* Allow binding to any address for transparent proxying (also via NET=
_ADMIN) */
=20
 #define CAP_NET_RAW          13
=20
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8905e92..f0dc3ad 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -961,7 +961,7 @@ mc_msf_out:
 		break;
=20
 	case IP_TRANSPARENT:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (!!val && !capable(CAP_NET_RAW) && !capable(CAP_NET_ADMIN)) {
 			err =3D -EPERM;
 			break;
 		}
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2fbda5f..c99e3ee 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -343,7 +343,7 @@ static int do_ipv6_setsockopt(struct sock *sk, int =
level, int optname,
 		break;
=20
 	case IPV6_TRANSPARENT:
-		if (!capable(CAP_NET_ADMIN)) {
+		if (valbool && !capable(CAP_NET_ADMIN) && !capable(CAP_NET_RAW)) {
 			retv =3D -EPERM;
 			break;
 		}
--=20
1.7.3.1
