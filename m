From: "=?ISO-8859-1?Q?Ilpo_J=E4rvinen?=" <ilpo.jarvinen@helsinki.fi>
Subject: [PATCH 10/18] [TCP]: Don't enter to fast recovery while using FRTO
Date: Mon, 19 Feb 2007 13:38:04 +0200
Message-ID: <11718850922734-git-send-email-ilpo.jarvinen@helsinki.fi>
References: <11718850923446-git-send-email-ilpo.jarvinen@helsinki.fi> <1171885092563-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921459-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923208-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921817-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922528-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921864-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850922604-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850921021-git-send-email-ilpo.jarvinen@helsinki.fi> <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: David Miller <davem@davemloft.net>,
	Pasi Sarolahti <pasi.sarolahti@nokia.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from courier.cs.helsinki.fi ([128.214.9.1]:49901 "EHLO
	mail.cs.helsinki.fi" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S932130AbXBSLiQ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 19 Feb 2007 06:38:16 -0500
In-Reply-To: <11718850923324-git-send-email-ilpo.jarvinen@helsinki.fi>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Because TCP is not in Loss state during FRTO recovery, fast
recovery could be triggered by accident. Non-SACK FRTO is more
robust than not yet included SACK-enhanced version (that can
receiver high number of duplicate ACKs with SACK blocks during
=46RTO), at least with unidirectional transfers, but under
extraordinary patterns fast recovery can be incorrectly
triggered, e.g., Data loss+ACK losses =3D> cumulative ACK with
enough SACK blocks to meet sacked_out >=3D dupthresh condition).

Signed-off-by: Ilpo J=E4rvinen <ilpo.jarvinen@helsinki.fi>
---
 net/ipv4/tcp_input.c |    4 ++++
 1 files changed, 4 insertions(+), 0 deletions(-)

diff --git a/net/ipv4/tcp_input.c b/net/ipv4/tcp_input.c
index 9637abd..309da3e 100644
--- a/net/ipv4/tcp_input.c
+++ b/net/ipv4/tcp_input.c
@@ -1547,6 +1547,10 @@ static int tcp_time_to_recover(struct so
 {
 	__u32 packets_out;
=20
+	/* Do not perform any recovery during FRTO algorithm */
+	if (tp->frto_counter)
+		return 0;
+
 	/* Trick#1: The loss is proven. */
 	if (tp->lost_out)
 		return 1;
--=20
1.4.2

