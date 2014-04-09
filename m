From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/3] staging: r8188eu: Fix case where ethtype was never
 obtained and always be checked against 0
Date: Wed,  9 Apr 2014 11:12:59 -0500
Message-ID: <1397059980-11942-3-git-send-email-Larry.Finger@lwfinger.net>
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
 drivers/staging/rtl8188eu/core/rtw_recv.c | 20 ++++++++------------
 1 file changed, 8 insertions(+), 12 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 01fcabc..61084d6 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -551,7 +551,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	struct sta_info *psta;
 	struct sta_priv *pstapriv;
 	struct recv_frame *prtnframe;
-	u16	ether_type = 0;
+	u16	ether_type;
 	u16  eapol_type = 0x888e;/* for Funia BD's WPA issue */
 	struct rx_pkt_attrib *pattrib;
 	__be16 be_tmp;
@@ -571,19 +571,17 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("########portctrl:adapter->securitypriv.dot11AuthAlgrthm=%d\n", adapter->securitypriv.dot11AuthAlgrthm));
 
-	if (auth_alg == 2) {
+	if (auth_alg == dot11AuthAlgrthm_8021X) {
+		/* get ether_type */
+		ptr = ptr + pfhdr->attrib.hdrlen + LLC_HEADER_SIZE;
+		memcpy(&ether_type, ptr, 2);
+		ether_type = ntohs((unsigned short)ether_type);
+
 		if ((psta != NULL) && (psta->ieee8021x_blocked)) {
 			/* blocked */
 			/* only accept EAPOL frame */
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("########portctrl:psta->ieee8021x_blocked==1\n"));
 
-			prtnframe = precv_frame;
-
-			/* get ether_type */
-			ptr = ptr+pfhdr->attrib.hdrlen+pfhdr->attrib.iv_len+LLC_HEADER_SIZE;
-			memcpy(&be_tmp, ptr, 2);
-			ether_type = ntohs(be_tmp);
-
 			if (ether_type == eapol_type) {
 				prtnframe = precv_frame;
 			} else {
@@ -616,9 +614,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	} else {
 		prtnframe = precv_frame;
 	}
-
-
-		return prtnframe;
+	return prtnframe;
 }
 
 static int recv_decache(struct recv_frame *precv_frame, u8 bretry,
-- 
1.8.1.4
