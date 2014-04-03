From: =?UTF-8?q?Cristian=20Rodr=C3=ADguez?= <crrodriguez@opensuse.org>
Subject: [PATCH ethtool 2/2] Use htobe64, htobe16 from libc instead of local byteswap code
Date: Thu,  3 Apr 2014 00:06:16 -0300
Message-ID: <1396494376-6521-2-git-send-email-crrodriguez@opensuse.org>
References: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: ben@decadent.org.uk,
	=?UTF-8?q?Cristian=20Rodr=C3=ADguez?= <crrodriguez@opensuse.org>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-qc0-f176.google.com ([209.85.216.176]:47159 "EHLO
	mail-qc0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932869AbaDCDHI (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 23:07:08 -0400
Received: by mail-qc0-f176.google.com with SMTP id m20so1214743qcx.21
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 20:07:07 -0700 (PDT)
In-Reply-To: <1396494376-6521-1-git-send-email-crrodriguez@opensuse.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

They are implemented in <endian.h> which is already included
in internal.h, no need to reinvent them with different names.

Signed-off-by: Cristian Rodr=C3=ADguez <crrodriguez@opensuse.org>
---
 ethtool.c  |  2 +-
 internal.h | 31 -------------------------------
 rxclass.c  |  4 ++--
 3 files changed, 3 insertions(+), 34 deletions(-)

diff --git a/ethtool.c b/ethtool.c
index acb4397..e47ce0b 100644
--- a/ethtool.c
+++ b/ethtool.c
@@ -368,7 +368,7 @@ static void parse_generic_cmdline(struct cmd_contex=
t *ctx,
 				}
 				case CMDL_BE16: {
 					u16 *p =3D info[idx].wanted_val;
-					*p =3D cpu_to_be16(
+					*p =3D htobe16(
 						get_uint_range(argp[i], 0,
 							       0xffff));
 					break;
diff --git a/internal.h b/internal.h
index 86a64f2..7e7266b 100644
--- a/internal.h
+++ b/internal.h
@@ -31,37 +31,6 @@ typedef __int32_t s32;
 #include "ethtool-copy.h"
 #include "net_tstamp-copy.h"
=20
-#if __BYTE_ORDER =3D=3D __BIG_ENDIAN
-static inline u16 cpu_to_be16(u16 value)
-{
-	return value;
-}
-static inline u32 cpu_to_be32(u32 value)
-{
-	return value;
-}
-static inline u64 cpu_to_be64(u64 value)
-{
-	return value;
-}
-#else
-static inline u16 cpu_to_be16(u16 value)
-{
-	return (value >> 8) | (value << 8);
-}
-static inline u32 cpu_to_be32(u32 value)
-{
-	return cpu_to_be16(value >> 16) | (cpu_to_be16(value) << 16);
-}
-static inline u64 cpu_to_be64(u64 value)
-{
-	return cpu_to_be32(value >> 32) | ((u64)cpu_to_be32(value) << 32);
-}
-#endif
-
-#define ntohll cpu_to_be64
-#define htonll cpu_to_be64
-
 #define BITS_PER_BYTE		8
 #define BITS_PER_LONG		(BITS_PER_BYTE * sizeof(long))
 #define DIV_ROUND_UP(n, d)	(((n) + (d) - 1) / (d))
diff --git a/rxclass.c b/rxclass.c
index cd686a3..a013e06 100644
--- a/rxclass.c
+++ b/rxclass.c
@@ -836,7 +836,7 @@ static int rxclass_get_val(char *str, unsigned char=
 *p, u32 *flags,
 		err =3D rxclass_get_ulong(str, &val, 64);
 		if (err)
 			return -1;
-		*(__be64 *)&p[opt->offset] =3D htonll((u64)val);
+		*(__be64 *)&p[opt->offset] =3D htobe64((u64)val);
 		if (opt->moffset >=3D 0)
 			*(__be64 *)&p[opt->moffset] =3D (__be64)mask;
 		break;
@@ -939,7 +939,7 @@ static int rxclass_get_mask(char *str, unsigned cha=
r *p,
 		err =3D rxclass_get_ulong(str, &val, 64);
 		if (err)
 			return -1;
-		*(__be64 *)&p[opt->moffset] =3D ~htonll((u64)val);
+		*(__be64 *)&p[opt->moffset] =3D ~htobe64((u64)val);
 		break;
 	}
 	case OPT_IP4: {
--=20
1.8.4.5
