From: Karsten Keil <keil@b1-systems.de>
Subject: [PATCH 04/13] ISDN: Fix isdnhdlc for one byte hdlc packets
Date: Wed, 8 Jul 2009 20:58:33 +0200
Message-ID: <f3fad223ed69f406f33c9619c256858d5a5fc5c7.1248546896.git.keil@b1-systems.de>
References: <cover.1248546896.git.keil@b1-systems.de>
Cc: netdev@vger.kernel.org, David Miller <davem@davemloft.net>,
	i4ldeveloper@listserv.isdn4linux.de
To: linux-kernel@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from d112a2.x-mailer.de ([212.162.53.4]:46535 "EHLO
	d112a2.x-mailer.de" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752810AbZGYVCn (ORCPT
	<rfc822;netdev@vger.kernel.org>); Sat, 25 Jul 2009 17:02:43 -0400
In-Reply-To: <cover.1248546896.git.keil@b1-systems.de>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Normally HDLC packets contain more as one byte (e.g a X25/X75 header).
But if you use plain HDLC framing, the current code do not encode
1 byte payloads, this patch fix that.

Signed-off-by: Karsten Keil <keil@b1-systems.de>
---
 drivers/isdn/i4l/isdnhdlc.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/isdn/i4l/isdnhdlc.c b/drivers/isdn/i4l/isdnhdlc.c
index df345ce..c989aa3 100644
--- a/drivers/isdn/i4l/isdnhdlc.c
+++ b/drivers/isdn/i4l/isdnhdlc.c
@@ -47,7 +47,7 @@ enum {
 	HDLC_SEND_DATA, HDLC_SEND_CRC1, HDLC_SEND_FAST_FLAG,
 	HDLC_SEND_FIRST_FLAG, HDLC_SEND_CRC2, HDLC_SEND_CLOSING_FLAG,
 	HDLC_SEND_IDLE1, HDLC_SEND_FAST_IDLE, HDLC_SENDFLAG_B0,
-	HDLC_SENDFLAG_B1A6, HDLC_SENDFLAG_B7, STOPPED
+	HDLC_SENDFLAG_B1A6, HDLC_SENDFLAG_B7, STOPPED, HDLC_SENDFLAG_ONE
 };
 
 void isdnhdlc_rcv_init(struct isdnhdlc_vars *hdlc, u32 features)
@@ -362,6 +362,9 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src, u16 slen,
 
 	*count = slen;
 
+	/* special handling for one byte frames */
+	if ((slen == 1) && (hdlc->state == HDLC_SEND_FAST_FLAG))
+		hdlc->state = HDLC_SENDFLAG_ONE;
 	while (dsize > 0) {
 		if (hdlc->bit_shift == 0) {
 			if (slen && !hdlc->do_closing) {
@@ -407,6 +410,8 @@ int isdnhdlc_encode(struct isdnhdlc_vars *hdlc, const u8 *src, u16 slen,
 				dsize--;
 				break;
 			}
+			/* fall through */
+		case HDLC_SENDFLAG_ONE:
 			if (hdlc->bit_shift == 8) {
 				hdlc->cbin = hdlc->ffvalue >>
 					(8 - hdlc->data_bits);
-- 
1.6.0.2

