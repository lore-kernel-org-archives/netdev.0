From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: change capability used by socket options IP{,V6}_TRANSPARENT
Date: Mon, 17 Oct 2011 15:16:23 -0700
Message-ID: <1318889783-23183-1-git-send-email-zenczykowski@gmail.com>
References: <20110920.154213.888729603269720228.davem@redhat.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Balazs Scheidler <bazsi@balabit.hu>,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yw0-f46.google.com ([209.85.213.46]:49811 "EHLO
	mail-yw0-f46.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751414Ab1JQWQj (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Oct 2011 18:16:39 -0400
Received: by ywf7 with SMTP id 7so1096858ywf.19
        for <netdev@vger.kernel.org>; Mon, 17 Oct 2011 15:16:39 -0700 (PDT)
In-Reply-To: <20110920.154213.888729603269720228.davem@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

Up till now the IP{,V6}_TRANSPARENT socket options (which actually set
the same bit in the socket struct) have required CAP_NET_ADMIN
privileges to set or clear the option.

- we make clearing the bit not require any privileges.
- we deprecate using CAP_NET_ADMIN for this purpose.
- we allow CAP_NET_RAW to set this bit, because raw
  sockets already effectively allow you to emulate socket
  transparency.
- we print a warning (but allow it) if you try to set the socket
  option with CAP_NET_ADMIN privs, but without CAP_NET_RAW.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/linux/capability.h |    3 ++-
 net/ipv4/ip_sockglue.c     |   20 ++++++++++++++++----
 net/ipv6/ipv6_sockglue.c   |   23 ++++++++++++++++++-----
 3 files changed, 36 insertions(+), 10 deletions(-)

diff --git a/include/linux/capability.h b/include/linux/capability.h
index c421123..ce34ae3 100644
--- a/include/linux/capability.h
+++ b/include/linux/capability.h
@@ -198,7 +198,7 @@ struct cpu_vfs_cap_data {
 /* Allow modification of routing tables */
 /* Allow setting arbitrary process / process group ownership on
    sockets */
-/* Allow binding to any address for transparent proxying */
+/* Allow binding to any address for transparent proxying (deprecated) =
*/
 /* Allow setting TOS (type of service) */
 /* Allow setting promiscuous mode */
 /* Allow clearing driver statistics */
@@ -210,6 +210,7 @@ struct cpu_vfs_cap_data {
=20
 /* Allow use of RAW sockets */
 /* Allow use of PACKET sockets */
+/* Allow binding to any address for transparent proxying */
=20
 #define CAP_NET_RAW          13
=20
diff --git a/net/ipv4/ip_sockglue.c b/net/ipv4/ip_sockglue.c
index 8905e92..74f7d30 100644
--- a/net/ipv4/ip_sockglue.c
+++ b/net/ipv4/ip_sockglue.c
@@ -961,12 +961,24 @@ mc_msf_out:
 		break;
=20
 	case IP_TRANSPARENT:
-		if (!capable(CAP_NET_ADMIN)) {
-			err =3D -EPERM;
-			break;
-		}
 		if (optlen < 1)
 			goto e_inval;
+		/* Always allow clearing the transparent proxy socket option.
+		 * The pre-3.2 permission for setting this was CAP_NET_ADMIN,
+		 * and this is still supported - but deprecated.  As of Linux
+		 * 3.2 the proper permission is CAP_NET_RAW.
+		 */
+		if (!!val && !capable(CAP_NET_RAW)) {
+			if (!capable(CAP_NET_ADMIN)) {
+				err =3D -EPERM;
+				break;
+			}
+			printk_once(KERN_WARNING "%s (%d): "
+				 "deprecated: attempt to set socket option "
+				 "IP_TRANSPARENT with CAP_NET_ADMIN but "
+				 "without CAP_NET_RAW.\n",
+				 current->comm, task_pid_nr(current));
+		}
 		inet->transparent =3D !!val;
 		break;
=20
diff --git a/net/ipv6/ipv6_sockglue.c b/net/ipv6/ipv6_sockglue.c
index 2fbda5f..7c4f5ce 100644
--- a/net/ipv6/ipv6_sockglue.c
+++ b/net/ipv6/ipv6_sockglue.c
@@ -343,13 +343,26 @@ static int do_ipv6_setsockopt(struct sock *sk, in=
t level, int optname,
 		break;
=20
 	case IPV6_TRANSPARENT:
-		if (!capable(CAP_NET_ADMIN)) {
-			retv =3D -EPERM;
-			break;
-		}
 		if (optlen < sizeof(int))
 			goto e_inval;
-		/* we don't have a separate transparent bit for IPV6 we use the one =
in the IPv4 socket */
+		/* Always allow clearing the transparent proxy socket option.
+		 * The pre-3.2 permission for setting this was CAP_NET_ADMIN,
+		 * and this is still supported - but deprecated.  As of Linux
+		 * 3.2 the proper permission is CAP_NET_RAW.
+		 */
+		if (valbool && !capable(CAP_NET_RAW)) {
+			if (!capable(CAP_NET_ADMIN)) {
+				retv =3D -EPERM;
+				break;
+			}
+			printk_once(KERN_WARNING "%s (%d): "
+				 "deprecated: attempt to set socket option "
+				 "IPV6_TRANSPARENT with CAP_NET_ADMIN but "
+				 "without CAP_NET_RAW.\n",
+				 current->comm, task_pid_nr(current));
+		}
+		/* we don't have a separate transparent bit for IPv6,
+		 * so we just use the one in the IPv4 socket */
 		inet_sk(sk)->transparent =3D valbool;
 		retv =3D 0;
 		break;
--=20
1.7.3.1
