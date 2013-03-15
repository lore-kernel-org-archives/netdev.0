From: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <zenczykowski@gmail.com>
Subject: [PATCH] bnx2x: fix occasional statistics off-by-4GB error
Date: Fri, 15 Mar 2013 14:56:17 -0700
Message-ID: <1363384577-21287-1-git-send-email-zenczykowski@gmail.com>
References: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: netdev@vger.kernel.org, Mintz Yuval <yuvalmin@broadcom.com>
To: =?UTF-8?q?Maciej=20=C5=BBenczykowski?= <maze@google.com>,
	"David S. Miller" <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pb0-f54.google.com ([209.85.160.54]:38296 "EHLO
	mail-pb0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754610Ab3COV5V (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 15 Mar 2013 17:57:21 -0400
Received: by mail-pb0-f54.google.com with SMTP id rr4so4362317pbb.27
        for <netdev@vger.kernel.org>; Fri, 15 Mar 2013 14:57:21 -0700 (PDT)
In-Reply-To: <CANP3RGdWMHv-7TZ4fvASrmz7NXkO7B2g2RCZwV8ecExUsQTQ2w@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

=46rom: Maciej =C5=BBenczykowski <maze@google.com>

The UPDATE_QSTAT function introduced on February 15, 2012
in commit 1355b704b9ba "bnx2x: consistent statistics after
internal driver reload" incorrectly fails to handle overflow
during addition of the lower 32-bit field of a stat.

This bug is present since 3.4-rc1 and should thus be considered
a candidate for stable 3.4+ releases.

Google-Bug-Id: 8374428
Signed-off-by: Maciej =C5=BBenczykowski <maze@google.com>
Cc: Mintz Yuval <yuvalmin@broadcom.com>
---
 drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h | 3 ++-
 1 file changed, 2 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h b/driver=
s/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
index 364e37ecbc5c..198f6f1c9ad5 100644
--- a/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
+++ b/drivers/net/ethernet/broadcom/bnx2x/bnx2x_stats.h
@@ -459,8 +459,9 @@ struct bnx2x_fw_port_stats_old {
=20
 #define UPDATE_QSTAT(s, t) \
 	do { \
-		qstats->t##_hi =3D qstats_old->t##_hi + le32_to_cpu(s.hi); \
 		qstats->t##_lo =3D qstats_old->t##_lo + le32_to_cpu(s.lo); \
+		qstats->t##_hi =3D qstats_old->t##_hi + le32_to_cpu(s.hi) \
+			+ ((qstats->t##_lo < qstats_old->t##_lo) ? 1 : 0); \
 	} while (0)
=20
 #define UPDATE_QSTAT_OLD(f) \
--=20
1.8.1.3
