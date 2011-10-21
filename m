From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] net: add sysctl allow_so_priority for SO_PRIORITY setsockopt
Date: Fri, 21 Oct 2011 15:22:05 -0700
Message-ID: <1319235725-3046-1-git-send-email-zenczykowski@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org,
	=?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f42.google.com ([209.85.210.42]:50890 "EHLO
	mail-pz0-f42.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751692Ab1JUWWW (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 21 Oct 2011 18:22:22 -0400
Received: by pzk36 with SMTP id 36so10607403pzk.1
        for <netdev@vger.kernel.org>; Fri, 21 Oct 2011 15:22:21 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

This change adds a sysctl (/proc/sys/net/core/allow_so_priority)
with a default of true (1), as such it does not change the default
behaviour of the Linux kernel.

This sysctl can be set to false (0), this will result in non
CAP_NET_ADMIN processes being unable to set SO_PRIORITY socket
option.

This is desireable if we want to rely on socket/skb priorities
being inferred from TOS/TCLASS bits.

Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
---
 include/net/sock.h         |    2 ++
 net/core/sock.c            |    5 ++++-
 net/core/sysctl_net_core.c |    7 +++++++
 3 files changed, 13 insertions(+), 1 deletions(-)

diff --git a/include/net/sock.h b/include/net/sock.h
index 5ac682f..bf18a6a 100644
--- a/include/net/sock.h
+++ b/include/net/sock.h
@@ -1853,6 +1853,8 @@ extern __u32 sysctl_rmem_max;
=20
 extern void sk_init(void);
=20
+extern int sysctl_allow_so_priority;
+
 extern int sysctl_optmem_max;
=20
 extern __u32 sysctl_wmem_default;
diff --git a/net/core/sock.c b/net/core/sock.c
index 5a08762..383fd89 100644
--- a/net/core/sock.c
+++ b/net/core/sock.c
@@ -217,6 +217,8 @@ __u32 sysctl_rmem_max __read_mostly =3D SK_RMEM_MAX=
;
 __u32 sysctl_wmem_default __read_mostly =3D SK_WMEM_MAX;
 __u32 sysctl_rmem_default __read_mostly =3D SK_RMEM_MAX;
=20
+int sysctl_allow_so_priority __read_mostly =3D 1;
+
 /* Maximal space eaten by iovec or ancillary data plus some space */
 int sysctl_optmem_max __read_mostly =3D sizeof(unsigned long)*(2*UIO_M=
AXIOV+512);
 EXPORT_SYMBOL(sysctl_optmem_max);
@@ -612,7 +614,8 @@ set_rcvbuf:
 		break;
=20
 	case SO_PRIORITY:
-		if ((val >=3D 0 && val <=3D 6) || capable(CAP_NET_ADMIN))
+		if ((val >=3D 0 && val <=3D 6 && sysctl_allow_so_priority)
+		    || capable(CAP_NET_ADMIN))
 			sk->sk_priority =3D val;
 		else
 			ret =3D -EPERM;
diff --git a/net/core/sysctl_net_core.c b/net/core/sysctl_net_core.c
index 77a65f0..91fdaac 100644
--- a/net/core/sysctl_net_core.c
+++ b/net/core/sysctl_net_core.c
@@ -183,6 +183,13 @@ static struct ctl_table net_core_table[] =3D {
 		.mode		=3D 0644,
 		.proc_handler	=3D proc_dointvec
 	},
+	{
+		.procname	=3D "allow_so_priority",
+		.data		=3D &sysctl_allow_so_priority,
+		.maxlen		=3D sizeof(int),
+		.mode		=3D 0644,
+		.proc_handler	=3D proc_dointvec
+	},
 	{ }
 };
=20
--=20
1.7.3.1
