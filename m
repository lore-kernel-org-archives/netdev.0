From: Sylvain Rochet <sylvain.rochet@finsecur.com>
Subject: [PATCH 2/2] ppp: mppe: discard late packet in stateless mode
Date: Sun, 26 Apr 2015 20:40:53 +0200
Message-ID: <1430073653-22131-3-git-send-email-sylvain.rochet@finsecur.com>
References: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Cc: Sylvain Rochet <sylvain.rochet@finsecur.com>
To: Paul Mackerras <paulus@samba.org>, linux-ppp@vger.kernel.org,
	netdev@vger.kernel.org, linux-kernel@vger.kernel.org,
	"David S. Miller" <davem@davemloft.net>
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <1430073653-22131-1-git-send-email-sylvain.rochet@finsecur.com>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

When PPP is used over a link which does not guarantee packet ordering,
we might get late MPPE packets. This is a problem because MPPE must be
kept synchronized and the current implementation does not drop them and
rekey 4095 times instead of 0, which is wrong.

In order to prevent rekeying about a whole count space times (~ 4095
times), drop packets which are not within the forward 4096/2 window and
increase sanity error counter.

Signed-off-by: Sylvain Rochet <sylvain.rochet@finsecur.com>
---
 drivers/net/ppp/ppp_mppe.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/drivers/net/ppp/ppp_mppe.c b/drivers/net/ppp/ppp_mppe.c
index 692ee0f..05005c6 100644
--- a/drivers/net/ppp/ppp_mppe.c
+++ b/drivers/net/ppp/ppp_mppe.c
@@ -533,6 +533,13 @@ mppe_decompress(void *arg, unsigned char *ibuf, int isize, unsigned char *obuf,
 	 */
 
 	if (!state->stateful) {
+		/* Discard late packet */
+		if ((ccount - state->ccount) % MPPE_CCOUNT_SPACE
+						> MPPE_CCOUNT_SPACE / 2) {
+			state->sanity_errors++;
+			goto sanity_error;
+		}
+
 		/* RFC 3078, sec 8.1.  Rekey for every packet. */
 		while (state->ccount != ccount) {
 			mppe_rekey(state, 0);
-- 
2.1.4
