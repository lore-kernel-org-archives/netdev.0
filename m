From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 3/3] staging: r8712u: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed,  9 Apr 2014 11:13:00 -0500
Message-ID: <1397059980-11942-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Stable <stable@vger.kernel.org>, Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1397059980-11942-1-git-send-email-Larry.Finger@lwfinger.net>
List-Unsubscribe: <http://driverdev.linuxdriverproject.org/mailman/options/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=unsubscribe>
List-Archive: <http://driverdev.linuxdriverproject.org/pipermail/driverdev-devel>
List-Post: <mailto:driverdev-devel@linuxdriverproject.org>
List-Help: <mailto:driverdev-devel-request@linuxdriverproject.org?subject=help>
List-Subscribe: <http://driverdev.linuxdriverproject.org/mailman/listinfo/driverdev-devel>,
 <mailto:driverdev-devel-request@linuxdriverproject.org?subject=subscribe>
Errors-To: driverdev-devel-bounces@linuxdriverproject.org
Sender: driverdev-devel-bounces@linuxdriverproject.org
List-Id: netdev.vger.kernel.org

Zero-initializing ether_type masked that the ether type would never be
obtained for 8021x packets and the comparition against eapol_type
would always fail.

Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/staging/rtl8712/rtl871x_recv.c | 15 +++++++--------
 1 file changed, 7 insertions(+), 8 deletions(-)

diff --git a/drivers/staging/rtl8712/rtl871x_recv.c b/drivers/staging/rtl8712/rtl871x_recv.c
index 23ec684..d8d1a76 100644
--- a/drivers/staging/rtl8712/rtl871x_recv.c
+++ b/drivers/staging/rtl8712/rtl871x_recv.c
@@ -254,7 +254,7 @@ union recv_frame *r8712_portctrl(struct _adapter *adapter,
 	struct sta_info *psta;
 	struct	sta_priv *pstapriv;
 	union recv_frame *prtnframe;
-	u16 ether_type = 0;
+	u16 ether_type;
 
 	pstapriv = &adapter->stapriv;
 	ptr = get_recvframe_data(precv_frame);
@@ -262,16 +262,15 @@ union recv_frame *r8712_portctrl(struct _adapter *adapter,
 	psta_addr = pfhdr->attrib.ta;
 	psta = r8712_get_stainfo(pstapriv, psta_addr);
 	auth_alg = adapter->securitypriv.AuthAlgrthm;
-	if (auth_alg == 2) {
+	if (auth_alg == dot11AuthAlgrthm_8021X) {
+		/* get ether_type */
+		ptr = ptr + pfhdr->attrib.hdrlen + LLC_HEADER_SIZE;
+		memcpy(&ether_type, ptr, 2);
+		ether_type = ntohs((unsigned short)ether_type);
+
 		if ((psta != NULL) && (psta->ieee8021x_blocked)) {
 			/* blocked
 			 * only accept EAPOL frame */
-			prtnframe = precv_frame;
-			/*get ether_type */
-			ptr = ptr + pfhdr->attrib.hdrlen +
-			      pfhdr->attrib.iv_len + LLC_HEADER_SIZE;
-			memcpy(&ether_type, ptr, 2);
-			ether_type = ntohs((unsigned short)ether_type);
 			if (ether_type == 0x888e)
 				prtnframe = precv_frame;
 			else {
-- 
1.8.1.4
