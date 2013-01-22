From: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
Subject: [PATCH net] r8169: remove the obsolete and incorrect AMD workaround
Date: Tue, 22 Jan 2013 10:30:35 +0200
Message-ID: <1358843435-24719-1-git-send-email-timo.teras@iki.fi>
References: <20130121234205.GA12449@electric-eye.fr.zoreil.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: =?UTF-8?q?Timo=20Ter=C3=A4s?= <timo.teras@iki.fi>
To: Francois Romieu <romieu@fr.zoreil.com>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ee0-f54.google.com ([74.125.83.54]:38272 "EHLO
	mail-ee0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753288Ab3AVIaa (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 22 Jan 2013 03:30:30 -0500
Received: by mail-ee0-f54.google.com with SMTP id c41so3371105eek.13
        for <netdev@vger.kernel.org>; Tue, 22 Jan 2013 00:30:29 -0800 (PST)
In-Reply-To: <20130121234205.GA12449@electric-eye.fr.zoreil.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This was introduced in commit 6dccd16 "r8169: merge with version
6.001.00 of Realtek's r8169 driver". I did not find the version
6.001.00 online, but in 6.002.00 or any later r8169 from Realtek
this hunk is no longer present.

Also commit 05af214 "r8169: fix Ethernet Hangup for RTL8110SC
rev d" claims to have fixed this issue otherwise.

The magic compare mask of 0xfffe000 is dubious as it masks
parts of the Reserved part, and parts of the VLAN tag. But this
does not make much sense as the VLAN tag parts are perfectly
valid there. In matter of fact this seems to be triggered with
any VLAN tagged packet as RxVlanTag bit is matched. I would
suspect 0xfffe0000 was intended to test reserved part only.

=46inally, this hunk is evil as it can cause more packets to be
handled than what was NAPI quota causing net/core/dev.c:
net_rx_action(): WARN_ON_ONCE(work > weight) to trigger, and
mess up the NAPI state causing device to hang.

As result, any system using VLANs and having high receive
traffic (so that NAPI poll budget limits rtl_rx) would result
in device hang.

Signed-off-by: Timo Ter=C3=A4s <timo.teras@iki.fi>
---
I decided to suggest just removal without the suggested WARN_ON_ONCE.
This is because the test is incorrect as explained above, and not
present anywhere else either. Oh yeah, and I'm feeling brave today ;)

If acceptable, this should go to -stable too. The hunk was introduced
in v2.6.23-rc1 and the alternate fix went in to v2.6.32-rc6.

 drivers/net/ethernet/realtek/r8169.c | 7 -------
 1 file changed, 7 deletions(-)

diff --git a/drivers/net/ethernet/realtek/r8169.c b/drivers/net/etherne=
t/realtek/r8169.c
index ed96f30..c28bc31 100644
--- a/drivers/net/ethernet/realtek/r8169.c
+++ b/drivers/net/ethernet/realtek/r8169.c
@@ -6111,13 +6111,6 @@ process_pkt:
 			tp->rx_stats.bytes +=3D pkt_size;
 			u64_stats_update_end(&tp->rx_stats.syncp);
 		}
-
-		/* Work around for AMD plateform. */
-		if ((desc->opts2 & cpu_to_le32(0xfffe000)) &&
-		    (tp->mac_version =3D=3D RTL_GIGA_MAC_VER_05)) {
-			desc->opts2 =3D 0;
-			cur_rx++;
-		}
 	}
=20
 	count =3D cur_rx - tp->cur_rx;
--=20
1.8.1
