From: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
Subject: [PATCH net-next 6/6] sctp: only check for ECN if peer is using it
Date: Wed, 13 Jul 2016 15:09:00 -0300
Message-ID: <ba4e30dc1a674f5ccb9aa86f2f5d5d859d92f343.1468432819.git.marcelo.leitner@gmail.com>
References: <cover.1468432819.git.marcelo.leitner@gmail.com>
Cc: Neil Horman <nhorman@tuxdriver.com>,
	Vlad Yasevich <vyasevich@gmail.com>, linux-sctp@vger.kernel.org
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:10120 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751119AbcGMSJv (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 13 Jul 2016 14:09:51 -0400
In-Reply-To: <cover.1468432819.git.marcelo.leitner@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Currently only read-only checks are performed up to the point on where
we check if peer is ECN capable, checks which we can avoid otherwise.
The flag ecn_ce_done is only used to perform this check once per
incoming packet, and nothing more.

Thus this patch moves the peer check up.

Signed-off-by: Marcelo Ricardo Leitner <marcelo.leitner@gmail.com>
---
 net/sctp/sm_statefuns.c | 5 ++---
 1 file changed, 2 insertions(+), 3 deletions(-)

diff --git a/net/sctp/sm_statefuns.c b/net/sctp/sm_statefuns.c
index b7c1f7f3c8388400e51e3fbdbe099bc354559913..d88bb2b0b69913ad5962f9a5655d413f2c210ed0 100644
--- a/net/sctp/sm_statefuns.c
+++ b/net/sctp/sm_statefuns.c
@@ -6118,12 +6118,11 @@ static int sctp_eat_data(const struct sctp_association *asoc,
 	 * chunk later.
 	 */
 
-	if (!chunk->ecn_ce_done) {
+	if (asoc->peer.ecn_capable && !chunk->ecn_ce_done) {
 		struct sctp_af *af = SCTP_INPUT_CB(chunk->skb)->af;
 		chunk->ecn_ce_done = 1;
 
-		if (af->is_ce(sctp_gso_headskb(chunk->skb)) &&
-		    asoc->peer.ecn_capable) {
+		if (af->is_ce(sctp_gso_headskb(chunk->skb))) {
 			/* Do real work as sideffect. */
 			sctp_add_cmd_sf(commands, SCTP_CMD_ECN_CE,
 					SCTP_U32(tsn));
-- 
2.7.4
