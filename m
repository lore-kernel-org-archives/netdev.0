From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 07/13] staging: r8188eu: Remove get_recvframe_data()
Date: Fri, 14 Feb 2014 16:54:11 -0600
Message-ID: <1392418457-3203-8-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Cc: netdev@vger.kernel.org, devel@driverdev.osuosl.org,
	Larry Finger <Larry.Finger@lwfinger.net>,
	Jes Sorensen <Jes.Sorensen@redhat.com>
To: gregkh@linuxfoundation.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-ob0-f171.google.com ([209.85.214.171]:56780 "EHLO
	mail-ob0-f171.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752993AbaBNWyw (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 14 Feb 2014 17:54:52 -0500
Received: by mail-ob0-f171.google.com with SMTP id wp4so14671666obc.2
        for <netdev@vger.kernel.org>; Fri, 14 Feb 2014 14:54:52 -0800 (PST)
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This inline function checks that the pointer is not NULL and then returns
the rx_data member. Unfortunately, all 3 callers of this function have
dereferenced that pointer before this routine is called. As the check for
NULL is useless, eliminate the routine.

Reported-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8188eu/core/rtw_recv.c       | 6 ++----
 drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c | 2 +-
 drivers/staging/rtl8188eu/include/rtw_recv.h    | 9 ---------
 3 files changed, 3 insertions(+), 14 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index d174a6c..a618426 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -562,7 +562,7 @@ static struct recv_frame *portctrl(struct adapter *adapter,
 
 	auth_alg = adapter->securitypriv.dot11AuthAlgrthm;
 
-	ptr = get_recvframe_data(precv_frame);
+	ptr = precv_frame->rx_data;
 	pfhdr = precv_frame;
 	pattrib = &pfhdr->attrib;
 	psta_addr = pattrib->ta;
@@ -1440,11 +1440,9 @@ static int wlanhdr_to_ethhdr(struct recv_frame *precvframe)
 	int ret = _SUCCESS;
 	struct adapter		*adapter = precvframe->adapter;
 	struct mlme_priv	*pmlmepriv = &adapter->mlmepriv;
-
-	u8	*ptr = get_recvframe_data(precvframe); /*  point to frame_ctrl field */
+	u8 *ptr = precvframe->rx_data;
 	struct rx_pkt_attrib *pattrib = &precvframe->attrib;
 
-
 	if (pattrib->encrypt)
 		recvframe_pull_tail(precvframe, pattrib->icv_len);
 
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c b/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
index f29bb79..43eb960 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
@@ -157,7 +157,7 @@ void update_recvframe_phyinfo_88e(struct recv_frame *precvframe,
 	pkt_info.bPacketToSelf = false;
 	pkt_info.bPacketBeacon = false;
 
-	wlanhdr = get_recvframe_data(precvframe);
+	wlanhdr = precvframe->rx_data;
 
 	pkt_info.bPacketMatchBSSID = ((!IsFrameTypeCtrl(wlanhdr)) &&
 		!pattrib->icv_err && !pattrib->crc_err &&
diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index 1f4d984..bcbce46 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -321,15 +321,6 @@ static inline u8 *get_rx_status(struct recv_frame *precvframe)
 	return get_rxmem(precvframe);
 }
 
-static inline u8 *get_recvframe_data(struct recv_frame *precvframe)
-{
-	/* always return rx_data */
-	if (precvframe == NULL)
-		return NULL;
-
-	return precvframe->rx_data;
-}
-
 static inline u8 *recvframe_push(struct recv_frame *precvframe, int sz)
 {
 	/*  append data before rx_data */
-- 
1.8.4.5
