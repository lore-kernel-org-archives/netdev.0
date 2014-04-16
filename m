From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 2/2 V2] staging: r8188eu: Fix case where ethtype was never obtained and always be checked against 0
Date: Wed, 16 Apr 2014 14:49:34 -0500
Message-ID: <1397677774-20283-2-git-send-email-Larry.Finger@lwfinger.net>
References: <1397677774-20283-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Stable <stable@vger.kernel.org>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f176.google.com ([209.85.214.176]:43800 "EHLO
	mail-ob0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751925AbaDPTtt (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 16 Apr 2014 15:49:49 -0400
In-Reply-To: <1397677774-20283-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Zero-initializing ether_type masked that the ether type would never be
obtained for 8021x packets and the comparison against eapol_type
would always fail.

Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Stable <stable@vger.kernel.org>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c | 15 ++++++---------
 1 file changed, 6 insertions(+), 9 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 636ec55..aeb0053 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -551,10 +551,9 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	struct sta_info *psta;
 	struct sta_priv *pstapriv;
 	struct recv_frame *prtnframe;
-	u16	ether_type = 0;
+	u16	ether_type;
 	u16  eapol_type = 0x888e;/* for Funia BD's WPA issue */
 	struct rx_pkt_attrib *pattrib;
-	__be16 be_tmp;
 
 
 	pstapriv = &adapter->stapriv;
@@ -572,18 +571,16 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("########portctrl:adapter->securitypriv.dot11AuthAlgrthm=%d\n", adapter->securitypriv.dot11AuthAlgrthm));
 
 	if (auth_alg == 2) {
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
-- 
1.8.1.4
