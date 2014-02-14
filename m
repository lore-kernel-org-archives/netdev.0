From: Larry Finger <Larry.Finger@lwfinger.net>
Subject: [PATCH 03/13] staging: r8188eu: Remove union wrapping of recv_frame
Date: Fri, 14 Feb 2014 16:54:07 -0600
Message-ID: <1392418457-3203-4-git-send-email-Larry.Finger@lwfinger.net>
References: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: devel@driverdev.osuosl.org, netdev@vger.kernel.org,
 Jes Sorensen <Jes.Sorensen@redhat.com>,
 Larry Finger <Larry.Finger@lwfinger.net>
To: gregkh@linuxfoundation.org
Return-path: <driverdev-devel-bounces@linuxdriverproject.org>
In-Reply-To: <1392418457-3203-1-git-send-email-Larry.Finger@lwfinger.net>
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

We have now removed everthing from the union except the struct. The union
can be deleted, the struct renamed, and the referencing of members of the
struct becomes a lot simpler.

Some, but not all, of the problems noted by checkpatch.pl have been fixed.

Sugggested-by: Jes Sorensen <Jes.Sorensen@redhat.com>
Signed-off-by: Larry Finger <Larry.Finger@lwfinger.net>
Cc: Jes Sorensen <Jes.Sorensen@redhat.com>
---
 drivers/staging/rtl8188eu/core/rtw_mlme_ext.c     | 143 ++++-----
 drivers/staging/rtl8188eu/core/rtw_recv.c         | 343 ++++++++++++----------
 drivers/staging/rtl8188eu/core/rtw_security.c     |  18 +-
 drivers/staging/rtl8188eu/core/rtw_sta_mgt.c      |  10 +-
 drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c   |  31 +-
 drivers/staging/rtl8188eu/hal/usb_ops_linux.c     |  38 +--
 drivers/staging/rtl8188eu/include/recv_osdep.h    |  10 +-
 drivers/staging/rtl8188eu/include/rtl8188e_recv.h |   7 +-
 drivers/staging/rtl8188eu/include/rtw_mlme_ext.h  |  49 ++--
 drivers/staging/rtl8188eu/include/rtw_recv.h      | 106 ++++---
 drivers/staging/rtl8188eu/os_dep/recv_linux.c     |  36 +--
 11 files changed, 413 insertions(+), 378 deletions(-)

diff --git a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
index 301cda5..faeec73 100644
--- a/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
+++ b/drivers/staging/rtl8188eu/core/rtw_mlme_ext.c
@@ -414,10 +414,10 @@ void free_mlme_ext_priv(struct mlme_ext_priv *pmlmeext)
 	}
 }
 
-static void _mgt_dispatcher(struct adapter *padapter, struct mlme_handler *ptable, union recv_frame *precv_frame)
+static void _mgt_dispatcher(struct adapter *padapter, struct mlme_handler *ptable, struct recv_frame *precv_frame)
 {
 	u8 bc_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 
 	  if (ptable->func) {
 	 /* receive the frames that ra(a1) is my address or ra(a1) is bc address. */
@@ -428,7 +428,7 @@ static void _mgt_dispatcher(struct adapter *padapter, struct mlme_handler *ptabl
 	}
 }
 
-void mgt_dispatcher(struct adapter *padapter, union recv_frame *precv_frame)
+void mgt_dispatcher(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	int index;
 	struct mlme_handler *ptable;
@@ -436,7 +436,7 @@ void mgt_dispatcher(struct adapter *padapter, union recv_frame *precv_frame)
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 #endif /* CONFIG_88EU_AP_MODE */
 	u8 bc_addr[ETH_ALEN] = {0xff, 0xff, 0xff, 0xff, 0xff, 0xff};
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	struct sta_info *psta = rtw_get_stainfo(&padapter->stapriv, GetAddr2Ptr(pframe));
 
 	RT_TRACE(_module_rtl871x_mlme_c_, _drv_info_,
@@ -465,13 +465,15 @@ void mgt_dispatcher(struct adapter *padapter, union recv_frame *precv_frame)
 
 	if (psta != NULL) {
 		if (GetRetry(pframe)) {
-			if (precv_frame->u.hdr.attrib.seq_num == psta->RxMgmtFrameSeqNum) {
+			if (precv_frame->attrib.seq_num ==
+			    psta->RxMgmtFrameSeqNum) {
 				/* drop the duplicate management frame */
-				DBG_88E("Drop duplicate management frame with seq_num=%d.\n", precv_frame->u.hdr.attrib.seq_num);
+				DBG_88E("Drop duplicate management frame with seq_num=%d.\n",
+					precv_frame->attrib.seq_num);
 				return;
 			}
 		}
-		psta->RxMgmtFrameSeqNum = precv_frame->u.hdr.attrib.seq_num;
+		psta->RxMgmtFrameSeqNum = precv_frame->attrib.seq_num;
 	}
 
 #ifdef CONFIG_88EU_AP_MODE
@@ -532,7 +534,7 @@ Following are the callback functions for each subtype of the management frames
 
 *****************************************************************************/
 
-unsigned int OnProbeReq(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnProbeReq(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	unsigned int	ielen;
 	unsigned char	*p;
@@ -540,8 +542,8 @@ unsigned int OnProbeReq(struct adapter *padapter, union recv_frame *precv_frame)
 	struct mlme_ext_priv *pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 	struct wlan_bssid_ex *cur = &(pmlmeinfo->network);
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint len = precv_frame->len;
 	u8 is_valid_p2p_probereq = false;
 
 #ifdef CONFIG_88EU_P2P
@@ -609,12 +611,12 @@ _issue_probersp:
 	return _SUCCESS;
 }
 
-unsigned int OnProbeRsp(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnProbeRsp(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 #ifdef CONFIG_88EU_P2P
 	struct wifidirect_info	*pwdinfo = &padapter->wdinfo;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 #endif
 
 #ifdef CONFIG_88EU_P2P
@@ -663,7 +665,7 @@ unsigned int OnProbeRsp(struct adapter *padapter, union recv_frame *precv_frame)
 	return _SUCCESS;
 }
 
-unsigned int OnBeacon(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnBeacon(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	int cam_idx;
 	struct sta_info	*psta;
@@ -671,8 +673,8 @@ unsigned int OnBeacon(struct adapter *padapter, union recv_frame *precv_frame)
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct sta_priv	*pstapriv = &padapter->stapriv;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint len = precv_frame->len;
 	struct wlan_bssid_ex *pbss;
 	int ret = _SUCCESS;
 
@@ -753,7 +755,7 @@ _END_ONBEACON_:
 	return _SUCCESS;
 }
 
-unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAuth(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
 	unsigned int	auth_mode, ie_len;
@@ -767,8 +769,8 @@ unsigned int OnAuth(struct adapter *padapter, union recv_frame *precv_frame)
 	struct security_priv *psecuritypriv = &padapter->securitypriv;
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint len = precv_frame->len;
 
 	if ((pmlmeinfo->state&0x03) != WIFI_FW_AP_STATE)
 		return _FAIL;
@@ -926,15 +928,15 @@ auth_fail:
 	return _FAIL;
 }
 
-unsigned int OnAuthClient(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAuthClient(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	unsigned int	seq, len, status, offset;
 	unsigned char	*p;
 	unsigned int	go2asoc = 0;
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint pkt_len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint pkt_len = precv_frame->len;
 
 	DBG_88E("%s\n", __func__);
 
@@ -1001,7 +1003,7 @@ authclnt_fail:
 	return _FAIL;
 }
 
-unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAssocReq(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
 	u16 capab_info;
@@ -1020,8 +1022,8 @@ unsigned int OnAssocReq(struct adapter *padapter, union recv_frame *precv_frame)
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 	struct wlan_bssid_ex *cur = &(pmlmeinfo->network);
 	struct sta_priv *pstapriv = &padapter->stapriv;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint pkt_len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint pkt_len = precv_frame->len;
 #ifdef CONFIG_88EU_P2P
 	struct wifidirect_info	*pwdinfo = &(padapter->wdinfo);
 	u8 p2p_status_code = P2P_STATUS_SUCCESS;
@@ -1470,7 +1472,7 @@ OnAssocReqFail:
 	return _FAIL;
 }
 
-unsigned int OnAssocRsp(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAssocRsp(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	uint i;
 	int res;
@@ -1480,8 +1482,8 @@ unsigned int OnAssocRsp(struct adapter *padapter, union recv_frame *precv_frame)
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
 	/* struct wlan_bssid_ex *cur_network = &(pmlmeinfo->network); */
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint pkt_len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint pkt_len = precv_frame->len;
 
 	DBG_88E("%s\n", __func__);
 
@@ -1560,13 +1562,13 @@ report_assoc_result:
 	return _SUCCESS;
 }
 
-unsigned int OnDeAuth(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnDeAuth(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	unsigned short	reason;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 #ifdef CONFIG_88EU_P2P
 	struct wifidirect_info *pwdinfo = &(padapter->wdinfo);
 #endif /* CONFIG_88EU_P2P */
@@ -1624,13 +1626,13 @@ unsigned int OnDeAuth(struct adapter *padapter, union recv_frame *precv_frame)
 	return _SUCCESS;
 }
 
-unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnDisassoc(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	u16 reason;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 #ifdef CONFIG_88EU_P2P
 	struct wifidirect_info *pwdinfo = &(padapter->wdinfo);
 #endif /* CONFIG_88EU_P2P */
@@ -1687,18 +1689,18 @@ unsigned int OnDisassoc(struct adapter *padapter, union recv_frame *precv_frame)
 	return _SUCCESS;
 }
 
-unsigned int OnAtim(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAtim(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	DBG_88E("%s\n", __func__);
 	return _SUCCESS;
 }
 
-unsigned int on_action_spct(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int on_action_spct(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	unsigned int ret = _FAIL;
 	struct sta_info *psta = NULL;
 	struct sta_priv *pstapriv = &padapter->stapriv;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	u8 *frame_body = (u8 *)(pframe + sizeof(struct rtw_ieee80211_hdr_3addr));
 	u8 category;
 	u8 action;
@@ -1731,17 +1733,17 @@ exit:
 	return ret;
 }
 
-unsigned int OnAction_qos(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction_qos(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	return _SUCCESS;
 }
 
-unsigned int OnAction_dls(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction_dls(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	return _SUCCESS;
 }
 
-unsigned int OnAction_back(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction_back(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	u8 *addr;
 	struct sta_info *psta = NULL;
@@ -1751,7 +1753,7 @@ unsigned int OnAction_back(struct adapter *padapter, union recv_frame *precv_fra
 	unsigned short	tid, status, reason_code = 0;
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
 	struct mlme_ext_info	*pmlmeinfo = &(pmlmeext->mlmext_info);
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 	/* check RA matches or not */
 	if (memcmp(myid(&(padapter->eeprompriv)), GetAddr1Ptr(pframe),
@@ -3857,13 +3859,13 @@ exit:
 
 #endif /* CONFIG_88EU_P2P */
 
-static s32 rtw_action_public_decache(union recv_frame *recv_frame, s32 token)
+static s32 rtw_action_public_decache(struct recv_frame *recv_frame, s32 token)
 {
-	struct adapter *adapter = recv_frame->u.hdr.adapter;
+	struct adapter *adapter = recv_frame->adapter;
 	struct mlme_ext_priv *mlmeext = &(adapter->mlmeextpriv);
-	u8 *frame = recv_frame->u.hdr.rx_data;
-	u16 seq_ctrl = ((recv_frame->u.hdr.attrib.seq_num&0xffff) << 4) |
-		(recv_frame->u.hdr.attrib.frag_num & 0xf);
+	u8 *frame = recv_frame->rx_data;
+	u16 seq_ctrl = ((recv_frame->attrib.seq_num&0xffff) << 4) |
+		(recv_frame->attrib.frag_num & 0xf);
 
 	if (GetRetry(frame)) {
 		if (token >= 0) {
@@ -3889,14 +3891,14 @@ static s32 rtw_action_public_decache(union recv_frame *recv_frame, s32 token)
 	return _SUCCESS;
 }
 
-static unsigned int on_action_public_p2p(union recv_frame *precv_frame)
+static unsigned int on_action_public_p2p(struct recv_frame *precv_frame)
 {
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	u8 *frame_body;
 	u8 dialogToken = 0;
 #ifdef CONFIG_88EU_P2P
-	struct adapter *padapter = precv_frame->u.hdr.adapter;
-	uint len = precv_frame->u.hdr.len;
+	struct adapter *padapter = precv_frame->adapter;
+	uint len = precv_frame->len;
 	u8 *p2p_ie;
 	u32	p2p_ielen;
 	struct	wifidirect_info	*pwdinfo = &(padapter->wdinfo);
@@ -4180,10 +4182,10 @@ static unsigned int on_action_public_p2p(union recv_frame *precv_frame)
 	return _SUCCESS;
 }
 
-static unsigned int on_action_public_vendor(union recv_frame *precv_frame)
+static unsigned int on_action_public_vendor(struct recv_frame *precv_frame)
 {
 	unsigned int ret = _FAIL;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	u8 *frame_body = pframe + sizeof(struct rtw_ieee80211_hdr_3addr);
 
 	if (!memcmp(frame_body + 2, P2P_OUI, 4))
@@ -4192,10 +4194,10 @@ static unsigned int on_action_public_vendor(union recv_frame *precv_frame)
 	return ret;
 }
 
-static unsigned int on_action_public_default(union recv_frame *precv_frame, u8 action)
+static unsigned int on_action_public_default(struct recv_frame *precv_frame, u8 action)
 {
 	unsigned int ret = _FAIL;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	u8 *frame_body = pframe + sizeof(struct rtw_ieee80211_hdr_3addr);
 	u8 token;
 
@@ -4210,10 +4212,10 @@ exit:
 	return ret;
 }
 
-unsigned int on_action_public(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int on_action_public(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	unsigned int ret = _FAIL;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 	u8 *frame_body = pframe + sizeof(struct rtw_ieee80211_hdr_3addr);
 	u8 category, action;
 
@@ -4239,23 +4241,23 @@ exit:
 	return ret;
 }
 
-unsigned int OnAction_ht(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction_ht(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	return _SUCCESS;
 }
 
-unsigned int OnAction_wmm(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction_wmm(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	return _SUCCESS;
 }
 
-unsigned int OnAction_p2p(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction_p2p(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_P2P
 	u8 *frame_body;
 	u8 category, OUI_Subtype;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	uint len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	uint len = precv_frame->len;
 	struct	wifidirect_info	*pwdinfo = &(padapter->wdinfo);
 
 
@@ -4294,13 +4296,13 @@ unsigned int OnAction_p2p(struct adapter *padapter, union recv_frame *precv_fram
 	return _SUCCESS;
 }
 
-unsigned int OnAction(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int OnAction(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	int i;
 	unsigned char	category;
 	struct action_handler *ptable;
 	unsigned char	*frame_body;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
+	u8 *pframe = precv_frame->rx_data;
 
 	frame_body = (unsigned char *)(pframe + sizeof(struct rtw_ieee80211_hdr_3addr));
 
@@ -4314,7 +4316,7 @@ unsigned int OnAction(struct adapter *padapter, union recv_frame *precv_frame)
 	return _SUCCESS;
 }
 
-unsigned int DoReserved(struct adapter *padapter, union recv_frame *precv_frame)
+unsigned int DoReserved(struct adapter *padapter, struct recv_frame *precv_frame)
 {
 	return _SUCCESS;
 }
@@ -6530,14 +6532,14 @@ void site_survey(struct adapter *padapter)
 }
 
 /* collect bss info from Beacon and Probe request/response frames. */
-u8 collect_bss_info(struct adapter *padapter, union recv_frame *precv_frame, struct wlan_bssid_ex *bssid)
+u8 collect_bss_info(struct adapter *padapter, struct recv_frame *precv_frame, struct wlan_bssid_ex *bssid)
 {
 	int	i;
 	u32	len;
 	u8 *p;
 	u16 val16, subtype;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	u32	packet_len = precv_frame->u.hdr.len;
+	u8 *pframe = precv_frame->rx_data;
+	u32	packet_len = precv_frame->len;
 	u8 ie_offset;
 	struct registry_priv	*pregistrypriv = &padapter->registrypriv;
 	struct mlme_ext_priv	*pmlmeext = &padapter->mlmeextpriv;
@@ -6576,10 +6578,10 @@ u8 collect_bss_info(struct adapter *padapter, union recv_frame *precv_frame, str
 	bssid->IELength = len;
 	memcpy(bssid->IEs, (pframe + sizeof(struct rtw_ieee80211_hdr_3addr)), bssid->IELength);
 
-	/* get the signal strength */
-	bssid->Rssi = precv_frame->u.hdr.attrib.phy_info.recvpower; /*  in dBM.raw data */
-	bssid->PhyInfo.SignalQuality = precv_frame->u.hdr.attrib.phy_info.SignalQuality;/* in percentage */
-	bssid->PhyInfo.SignalStrength = precv_frame->u.hdr.attrib.phy_info.SignalStrength;/* in percentage */
+	/* get the signal strength in dBM.raw data */
+	bssid->Rssi = precv_frame->attrib.phy_info.recvpower;
+	bssid->PhyInfo.SignalQuality = precv_frame->attrib.phy_info.SignalQuality;/* in percentage */
+	bssid->PhyInfo.SignalStrength = precv_frame->attrib.phy_info.SignalStrength;/* in percentage */
 	rtw_hal_get_def_var(padapter, HAL_DEF_CURRENT_ANTENNA,  &bssid->PhyInfo.Optimum_antenna);
 
 	/*  checking SSID */
@@ -7032,7 +7034,8 @@ Following are the functions to report events
 
 *****************************************************************************/
 
-void report_survey_event(struct adapter *padapter, union recv_frame *precv_frame)
+void report_survey_event(struct adapter *padapter,
+			 struct recv_frame *precv_frame)
 {
 	struct cmd_obj *pcmd_obj;
 	u8 *pevtcmd;
@@ -7041,8 +7044,6 @@ void report_survey_event(struct adapter *padapter, union recv_frame *precv_frame
 	struct C2HEvent_Header *pc2h_evt_hdr;
 	struct mlme_ext_priv *pmlmeext;
 	struct cmd_priv *pcmdpriv;
-	/* u8 *pframe = precv_frame->u.hdr.rx_data; */
-	/* uint len = precv_frame->u.hdr.len; */
 
 	if (!padapter)
 		return;
diff --git a/drivers/staging/rtl8188eu/core/rtw_recv.c b/drivers/staging/rtl8188eu/core/rtw_recv.c
index 6979c73..1e40eba 100644
--- a/drivers/staging/rtl8188eu/core/rtw_recv.c
+++ b/drivers/staging/rtl8188eu/core/rtw_recv.c
@@ -59,7 +59,7 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
 {
 	int i;
 
-	union recv_frame *precvframe;
+	struct recv_frame *precvframe;
 
 	int	res = _SUCCESS;
 
@@ -75,7 +75,7 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
 
 	rtw_os_recv_resource_init(precvpriv, padapter);
 
-	precvpriv->pallocated_frame_buf = vzalloc(NR_RECVFRAME * sizeof(union recv_frame) + RXFRAME_ALIGN_SZ);
+	precvpriv->pallocated_frame_buf = vzalloc(NR_RECVFRAME * sizeof(struct recv_frame) + RXFRAME_ALIGN_SZ);
 
 	if (precvpriv->pallocated_frame_buf == NULL) {
 		res = _FAIL;
@@ -84,19 +84,19 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter)
 
 	precvpriv->precv_frame_buf = (u8 *)N_BYTE_ALIGMENT((size_t)(precvpriv->pallocated_frame_buf), RXFRAME_ALIGN_SZ);
 
-	precvframe = (union recv_frame *)precvpriv->precv_frame_buf;
+	precvframe = (struct recv_frame *)precvpriv->precv_frame_buf;
 
 	for (i = 0; i < NR_RECVFRAME; i++) {
-		_rtw_init_listhead(&(precvframe->u.hdr.list));
+		_rtw_init_listhead(&(precvframe->list));
 
-		rtw_list_insert_tail(&(precvframe->u.hdr.list),
+		rtw_list_insert_tail(&(precvframe->list),
 				     &(precvpriv->free_recv_queue.queue));
 
 		res = rtw_os_recv_resource_alloc(padapter, precvframe);
 
-		precvframe->u.hdr.len = 0;
+		precvframe->len = 0;
 
-		precvframe->u.hdr.adapter = padapter;
+		precvframe->adapter = padapter;
 		precvframe++;
 	}
 	precvpriv->rx_pending_cnt = 1;
@@ -133,9 +133,9 @@ void _rtw_free_recv_priv (struct recv_priv *precvpriv)
 
 }
 
-union recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
+struct recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 {
-	struct recv_frame_hdr *hdr;
+	struct recv_frame *hdr;
 	struct list_head *plist, *phead;
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
@@ -147,7 +147,7 @@ union recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 
 		plist = phead->next;
 
-		hdr = container_of(plist, struct recv_frame_hdr, list);
+		hdr = container_of(plist, struct recv_frame, list);
 
 		rtw_list_delete(&hdr->list);
 		padapter = hdr->adapter;
@@ -159,12 +159,12 @@ union recv_frame *_rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 	}
 
 
-	return (union recv_frame *)hdr;
+	return (struct recv_frame *)hdr;
 }
 
-union recv_frame *rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
+struct recv_frame *rtw_alloc_recvframe(struct __queue *pfree_recv_queue)
 {
-	union recv_frame  *precvframe;
+	struct recv_frame  *precvframe;
 
 	spin_lock_bh(&pfree_recv_queue->lock);
 
@@ -175,35 +175,36 @@ union recv_frame *rtw_alloc_recvframe (struct __queue *pfree_recv_queue)
 	return precvframe;
 }
 
-void rtw_init_recvframe(union recv_frame *precvframe, struct recv_priv *precvpriv)
+void rtw_init_recvframe(struct recv_frame *precvframe, struct recv_priv *precvpriv)
 {
 	/* Perry: This can be removed */
-	_rtw_init_listhead(&precvframe->u.hdr.list);
+	_rtw_init_listhead(&precvframe->list);
 
-	precvframe->u.hdr.len = 0;
+	precvframe->len = 0;
 }
 
-int rtw_free_recvframe(union recv_frame *precvframe, struct __queue *pfree_recv_queue)
+int rtw_free_recvframe(struct recv_frame *precvframe,
+		       struct __queue *pfree_recv_queue)
 {
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
 
 	if (!precvframe)
 		return _FAIL;
-	padapter = precvframe->u.hdr.adapter;
+	padapter = precvframe->adapter;
 	precvpriv = &padapter->recvpriv;
-	if (precvframe->u.hdr.pkt) {
-		dev_kfree_skb_any(precvframe->u.hdr.pkt);/* free skb by driver */
-		precvframe->u.hdr.pkt = NULL;
+	if (precvframe->pkt) {
+		dev_kfree_skb_any(precvframe->pkt);/* free skb by driver */
+		precvframe->pkt = NULL;
 	}
 
 	spin_lock_bh(&pfree_recv_queue->lock);
 
-	rtw_list_delete(&(precvframe->u.hdr.list));
+	rtw_list_delete(&(precvframe->list));
 
-	precvframe->u.hdr.len = 0;
+	precvframe->len = 0;
 
-	rtw_list_insert_tail(&(precvframe->u.hdr.list), get_list_head(pfree_recv_queue));
+	rtw_list_insert_tail(&(precvframe->list), get_list_head(pfree_recv_queue));
 
 	if (padapter != NULL) {
 		if (pfree_recv_queue == &precvpriv->free_recv_queue)
@@ -216,14 +217,14 @@ int rtw_free_recvframe(union recv_frame *precvframe, struct __queue *pfree_recv_
 	return _SUCCESS;
 }
 
-int _rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue)
+int _rtw_enqueue_recvframe(struct recv_frame *precvframe, struct __queue *queue)
 {
-	struct adapter *padapter = precvframe->u.hdr.adapter;
+	struct adapter *padapter = precvframe->adapter;
 	struct recv_priv *precvpriv = &padapter->recvpriv;
 
 
-	rtw_list_delete(&(precvframe->u.hdr.list));
-	rtw_list_insert_tail(&(precvframe->u.hdr.list), get_list_head(queue));
+	rtw_list_delete(&(precvframe->list));
+	rtw_list_insert_tail(&(precvframe->list), get_list_head(queue));
 
 	if (padapter != NULL) {
 		if (queue == &precvpriv->free_recv_queue)
@@ -234,7 +235,7 @@ int _rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue)
 	return _SUCCESS;
 }
 
-int rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue)
+int rtw_enqueue_recvframe(struct recv_frame *precvframe, struct __queue *queue)
 {
 	int ret;
 
@@ -255,7 +256,7 @@ using spinlock to protect
 
 void rtw_free_recvframe_queue(struct __queue *pframequeue,  struct __queue *pfree_recv_queue)
 {
-	struct recv_frame_hdr *hdr;
+	struct recv_frame *hdr;
 	struct list_head *plist, *phead;
 
 	spin_lock(&pframequeue->lock);
@@ -264,11 +265,11 @@ void rtw_free_recvframe_queue(struct __queue *pframequeue,  struct __queue *pfre
 	plist = phead->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		hdr = container_of(plist, struct recv_frame_hdr, list);
+		hdr = container_of(plist, struct recv_frame, list);
 
 		plist = plist->next;
 
-		rtw_free_recvframe((union recv_frame *)hdr, pfree_recv_queue);
+		rtw_free_recvframe((struct recv_frame *)hdr, pfree_recv_queue);
 	}
 
 	spin_unlock(&pframequeue->lock);
@@ -278,7 +279,7 @@ void rtw_free_recvframe_queue(struct __queue *pframequeue,  struct __queue *pfre
 u32 rtw_free_uc_swdec_pending_queue(struct adapter *adapter)
 {
 	u32 cnt = 0;
-	union recv_frame *pending_frame;
+	struct recv_frame *pending_frame;
 	while ((pending_frame = rtw_alloc_recvframe(&adapter->recvpriv.uc_swdec_pending_queue))) {
 		rtw_free_recvframe(pending_frame, &adapter->recvpriv.free_recv_queue);
 		DBG_88E("%s: dequeue uc_swdec_pending_queue\n", __func__);
@@ -337,7 +338,8 @@ struct recv_buf *rtw_dequeue_recvbuf (struct __queue *queue)
 	return precvbuf;
 }
 
-static int recvframe_chkmic(struct adapter *adapter,  union recv_frame *precvframe)
+static int recvframe_chkmic(struct adapter *adapter,
+			    struct recv_frame *precvframe)
 {
 	int	i, res = _SUCCESS;
 	u32	datalen;
@@ -346,7 +348,7 @@ static int recvframe_chkmic(struct adapter *adapter,  union recv_frame *precvfra
 	u8	*pframe, *payload, *pframemic;
 	u8	*mickey;
 	struct	sta_info		*stainfo;
-	struct	rx_pkt_attrib	*prxattrib = &precvframe->u.hdr.attrib;
+	struct	rx_pkt_attrib	*prxattrib = &precvframe->attrib;
 	struct	security_priv	*psecuritypriv = &adapter->securitypriv;
 
 	struct mlme_ext_priv	*pmlmeext = &adapter->mlmeextpriv;
@@ -376,8 +378,10 @@ static int recvframe_chkmic(struct adapter *adapter,  union recv_frame *precvfra
 				RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("\n recvframe_chkmic: unicast key\n"));
 			}
 
-			datalen = precvframe->u.hdr.len-prxattrib->hdrlen-prxattrib->iv_len-prxattrib->icv_len-8;/* icv_len included the mic code */
-			pframe = precvframe->u.hdr.rx_data;
+			/* icv_len included the mic code */
+			datalen = precvframe->len-prxattrib->hdrlen -
+				  prxattrib->iv_len-prxattrib->icv_len-8;
+			pframe = precvframe->rx_data;
 			payload = pframe+prxattrib->hdrlen+prxattrib->iv_len;
 
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("\n prxattrib->iv_len=%d prxattrib->icv_len=%d\n", prxattrib->iv_len, prxattrib->icv_len));
@@ -410,16 +414,30 @@ static int recvframe_chkmic(struct adapter *adapter,  union recv_frame *precvfra
 					 *(pframemic-10), *(pframemic-9)));
 				{
 					uint i;
-					RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("\n ======demp packet (len=%d)======\n", precvframe->u.hdr.len));
-					for (i = 0; i < precvframe->u.hdr.len; i = i+8) {
-						RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x",
-							 *(precvframe->u.hdr.rx_data+i), *(precvframe->u.hdr.rx_data+i+1),
-							 *(precvframe->u.hdr.rx_data+i+2), *(precvframe->u.hdr.rx_data+i+3),
-							 *(precvframe->u.hdr.rx_data+i+4), *(precvframe->u.hdr.rx_data+i+5),
-							 *(precvframe->u.hdr.rx_data+i+6), *(precvframe->u.hdr.rx_data+i+7)));
+					RT_TRACE(_module_rtl871x_recv_c_, _drv_err_,
+						 ("\n ======demp packet (len=%d)======\n",
+						 precvframe->len));
+					for (i = 0; i < precvframe->len; i += 8) {
+						RT_TRACE(_module_rtl871x_recv_c_,
+							 _drv_err_,
+							 ("0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x:0x%02x",
+							 *(precvframe->rx_data+i),
+							 *(precvframe->rx_data+i+1),
+							 *(precvframe->rx_data+i+2),
+							 *(precvframe->rx_data+i+3),
+							 *(precvframe->rx_data+i+4),
+							 *(precvframe->rx_data+i+5),
+							 *(precvframe->rx_data+i+6),
+							 *(precvframe->rx_data+i+7)));
 					}
-					RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("\n ====== demp packet end [len=%d]======\n", precvframe->u.hdr.len));
-					RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("\n hrdlen=%d,\n", prxattrib->hdrlen));
+					RT_TRACE(_module_rtl871x_recv_c_,
+						 _drv_err_,
+						 ("\n ====== demp packet end [len=%d]======\n",
+						 precvframe->len));
+					RT_TRACE(_module_rtl871x_recv_c_,
+						 _drv_err_,
+						 ("\n hrdlen=%d,\n",
+						 prxattrib->hdrlen));
 				}
 
 				RT_TRACE(_module_rtl871x_recv_c_, _drv_err_,
@@ -462,17 +480,18 @@ exit:
 }
 
 /* decrypt and set the ivlen, icvlen of the recv_frame */
-static union recv_frame *decryptor(struct adapter *padapter, union recv_frame *precv_frame)
+static struct recv_frame *decryptor(struct adapter *padapter,
+				    struct recv_frame *precv_frame)
 {
-	struct rx_pkt_attrib *prxattrib = &precv_frame->u.hdr.attrib;
+	struct rx_pkt_attrib *prxattrib = &precv_frame->attrib;
 	struct security_priv *psecuritypriv = &padapter->securitypriv;
-	union recv_frame *return_packet = precv_frame;
+	struct recv_frame *return_packet = precv_frame;
 	u32	 res = _SUCCESS;
 
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("prxstat->decrypted=%x prxattrib->encrypt=0x%03x\n", prxattrib->bdecrypted, prxattrib->encrypt));
 
 	if (prxattrib->encrypt > 0) {
-		u8 *iv = precv_frame->u.hdr.rx_data+prxattrib->hdrlen;
+		u8 *iv = precv_frame->rx_data+prxattrib->hdrlen;
 		prxattrib->key_index = (((iv[3])>>6)&0x3);
 
 		if (prxattrib->key_index > WEP_KEYS) {
@@ -523,14 +542,15 @@ static union recv_frame *decryptor(struct adapter *padapter, union recv_frame *p
 }
 
 /* set the security information in the recv_frame */
-static union recv_frame *portctrl(struct adapter *adapter, union recv_frame *precv_frame)
+static struct recv_frame *portctrl(struct adapter *adapter,
+				   struct recv_frame *precv_frame)
 {
 	u8   *psta_addr = NULL, *ptr;
 	uint  auth_alg;
-	struct recv_frame_hdr *pfhdr;
+	struct recv_frame *pfhdr;
 	struct sta_info *psta;
 	struct sta_priv *pstapriv;
-	union recv_frame *prtnframe;
+	struct recv_frame *prtnframe;
 	u16	ether_type = 0;
 	u16  eapol_type = 0x888e;/* for Funia BD's WPA issue */
 	struct rx_pkt_attrib *pattrib;
@@ -543,7 +563,7 @@ static union recv_frame *portctrl(struct adapter *adapter, union recv_frame *pre
 	auth_alg = adapter->securitypriv.dot11AuthAlgrthm;
 
 	ptr = get_recvframe_data(precv_frame);
-	pfhdr = &precv_frame->u.hdr;
+	pfhdr = precv_frame;
 	pattrib = &pfhdr->attrib;
 	psta_addr = pattrib->ta;
 
@@ -575,7 +595,9 @@ static union recv_frame *portctrl(struct adapter *adapter, union recv_frame *pre
 			/* allowed */
 			/* check decryption status, and decrypt the frame if needed */
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("########portctrl:psta->ieee8021x_blocked==0\n"));
-			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("portctrl:precv_frame->hdr.attrib.privacy=%x\n", precv_frame->u.hdr.attrib.privacy));
+			RT_TRACE(_module_rtl871x_recv_c_, _drv_info_,
+				 ("portctrl:precv_frame->hdr.attrib.privacy=%x\n",
+				 precv_frame->attrib.privacy));
 
 			if (pattrib->bdecrypted == 0)
 				RT_TRACE(_module_rtl871x_recv_c_, _drv_info_, ("portctrl:prxstat->decrypted=%x\n", pattrib->bdecrypted));
@@ -599,12 +621,13 @@ static union recv_frame *portctrl(struct adapter *adapter, union recv_frame *pre
 		return prtnframe;
 }
 
-static int recv_decache(union recv_frame *precv_frame, u8 bretry, struct stainfo_rxcache *prxcache)
+static int recv_decache(struct recv_frame *precv_frame, u8 bretry,
+			struct stainfo_rxcache *prxcache)
 {
-	int tid = precv_frame->u.hdr.attrib.priority;
+	int tid = precv_frame->attrib.priority;
 
-	u16 seq_ctrl = ((precv_frame->u.hdr.attrib.seq_num&0xffff) << 4) |
-		(precv_frame->u.hdr.attrib.frag_num & 0xf);
+	u16 seq_ctrl = ((precv_frame->attrib.seq_num&0xffff) << 4) |
+		(precv_frame->attrib.frag_num & 0xf);
 
 
 	if (tid > 15) {
@@ -627,13 +650,13 @@ static int recv_decache(union recv_frame *precv_frame, u8 bretry, struct stainfo
 	return _SUCCESS;
 }
 
-void process_pwrbit_data(struct adapter *padapter, union recv_frame *precv_frame);
-void process_pwrbit_data(struct adapter *padapter, union recv_frame *precv_frame)
+void process_pwrbit_data(struct adapter *padapter,
+			 struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
 	unsigned char pwrbit;
-	u8 *ptr = precv_frame->u.hdr.rx_data;
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+	u8 *ptr = precv_frame->rx_data;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 	struct sta_info *psta = NULL;
 
@@ -654,10 +677,11 @@ void process_pwrbit_data(struct adapter *padapter, union recv_frame *precv_frame
 #endif
 }
 
-static void process_wmmps_data(struct adapter *padapter, union recv_frame *precv_frame)
+static void process_wmmps_data(struct adapter *padapter,
+			       struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 	struct sta_priv *pstapriv = &padapter->stapriv;
 	struct sta_info *psta = NULL;
 
@@ -709,12 +733,14 @@ static void process_wmmps_data(struct adapter *padapter, union recv_frame *precv
 #endif
 }
 
-static void count_rx_stats(struct adapter *padapter, union recv_frame *prframe, struct sta_info *sta)
+static void count_rx_stats(struct adapter *padapter,
+			   struct recv_frame *prframe,
+			   struct sta_info *sta)
 {
 	int	sz;
 	struct sta_info		*psta = NULL;
 	struct stainfo_stats	*pstats = NULL;
-	struct rx_pkt_attrib	*pattrib = &prframe->u.hdr.attrib;
+	struct rx_pkt_attrib	*pattrib = &prframe->attrib;
 	struct recv_priv	*precvpriv = &padapter->recvpriv;
 
 	sz = get_recvframe_len(prframe);
@@ -728,7 +754,7 @@ static void count_rx_stats(struct adapter *padapter, union recv_frame *prframe,
 	if (sta)
 		psta = sta;
 	else
-		psta = prframe->u.hdr.psta;
+		psta = prframe->psta;
 
 	if (psta) {
 		pstats = &psta->sta_stats;
@@ -740,15 +766,16 @@ static void count_rx_stats(struct adapter *padapter, union recv_frame *prframe,
 
 int sta2sta_data_frame(
 	struct adapter *adapter,
-	union recv_frame *precv_frame,
+	struct recv_frame *precv_frame,
 	struct sta_info **psta
 );
 
-int sta2sta_data_frame(struct adapter *adapter, union recv_frame *precv_frame, struct sta_info **psta)
+int sta2sta_data_frame(struct adapter *adapter, struct recv_frame *precv_frame,
+		       struct sta_info **psta)
 {
-	u8 *ptr = precv_frame->u.hdr.rx_data;
+	u8 *ptr = precv_frame->rx_data;
 	int ret = _SUCCESS;
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 	struct	sta_priv *pstapriv = &adapter->stapriv;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
 	u8 *mybssid  = get_bssid(pmlmepriv);
@@ -836,11 +863,11 @@ exit:
 
 static int ap2sta_data_frame (
 	struct adapter *adapter,
-	union recv_frame *precv_frame,
+	struct recv_frame *precv_frame,
 	struct sta_info **psta)
 {
-	u8 *ptr = precv_frame->u.hdr.rx_data;
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+	u8 *ptr = precv_frame->rx_data;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 	int ret = _SUCCESS;
 	struct	sta_priv *pstapriv = &adapter->stapriv;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
@@ -945,13 +972,13 @@ exit:
 }
 
 static int sta2ap_data_frame(struct adapter *adapter,
-			     union recv_frame *precv_frame,
+			     struct recv_frame *precv_frame,
 			     struct sta_info **psta)
 {
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 	struct	sta_priv *pstapriv = &adapter->stapriv;
 	struct	mlme_priv *pmlmepriv = &adapter->mlmepriv;
-	u8 *ptr = precv_frame->u.hdr.rx_data;
+	u8 *ptr = precv_frame->rx_data;
 	unsigned char *mybssid  = get_bssid(pmlmepriv);
 	int ret = _SUCCESS;
 
@@ -1005,13 +1032,12 @@ exit:
 }
 
 static int validate_recv_ctrl_frame(struct adapter *padapter,
-				    union recv_frame *precv_frame)
+				    struct recv_frame *precv_frame)
 {
 #ifdef CONFIG_88EU_AP_MODE
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 	struct sta_priv *pstapriv = &padapter->stapriv;
-	u8 *pframe = precv_frame->u.hdr.rx_data;
-	/* uint len = precv_frame->u.hdr.len; */
+	u8 *pframe = precv_frame->rx_data;
 
 	if (GetFrameType(pframe) != WIFI_CTRL_TYPE)
 		return _FAIL;
@@ -1130,10 +1156,11 @@ static int validate_recv_ctrl_frame(struct adapter *padapter,
 	return _FAIL;
 }
 
-union recv_frame *recvframe_chk_defrag(struct adapter *padapter, union recv_frame *precv_frame);
+struct recv_frame *recvframe_chk_defrag(struct adapter *padapter,
+					struct recv_frame *precv_frame);
 
 static int validate_recv_mgnt_frame(struct adapter *padapter,
-				    union recv_frame *precv_frame)
+				    struct recv_frame *precv_frame)
 {
 	struct sta_info *psta;
 
@@ -1146,19 +1173,20 @@ static int validate_recv_mgnt_frame(struct adapter *padapter,
 	}
 
 	/* for rx pkt statistics */
-	psta = rtw_get_stainfo(&padapter->stapriv, GetAddr2Ptr(precv_frame->u.hdr.rx_data));
+	psta = rtw_get_stainfo(&padapter->stapriv,
+			       GetAddr2Ptr(precv_frame->rx_data));
 	if (psta) {
 		psta->sta_stats.rx_mgnt_pkts++;
-		if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_BEACON) {
+		if (GetFrameSubType(precv_frame->rx_data) == WIFI_BEACON) {
 			psta->sta_stats.rx_beacon_pkts++;
-		} else if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_PROBEREQ) {
+		} else if (GetFrameSubType(precv_frame->rx_data) == WIFI_PROBEREQ) {
 			psta->sta_stats.rx_probereq_pkts++;
-		} else if (GetFrameSubType(precv_frame->u.hdr.rx_data) == WIFI_PROBERSP) {
+		} else if (GetFrameSubType(precv_frame->rx_data) == WIFI_PROBERSP) {
 			if (!memcmp(padapter->eeprompriv.mac_addr,
-				    GetAddr1Ptr(precv_frame->u.hdr.rx_data), ETH_ALEN))
+				    GetAddr1Ptr(precv_frame->rx_data), ETH_ALEN))
 				psta->sta_stats.rx_probersp_pkts++;
-			else if (is_broadcast_mac_addr(GetAddr1Ptr(precv_frame->u.hdr.rx_data)) ||
-				 is_multicast_mac_addr(GetAddr1Ptr(precv_frame->u.hdr.rx_data)))
+			else if (is_broadcast_mac_addr(GetAddr1Ptr(precv_frame->rx_data)) ||
+				 is_multicast_mac_addr(GetAddr1Ptr(precv_frame->rx_data)))
 				psta->sta_stats.rx_probersp_bm_pkts++;
 			else
 				psta->sta_stats.rx_probersp_uo_pkts++;
@@ -1171,13 +1199,13 @@ static int validate_recv_mgnt_frame(struct adapter *padapter,
 }
 
 static int validate_recv_data_frame(struct adapter *adapter,
-				    union recv_frame *precv_frame)
+				    struct recv_frame *precv_frame)
 {
 	u8 bretry;
 	u8 *psa, *pda, *pbssid;
 	struct sta_info *psta = NULL;
-	u8 *ptr = precv_frame->u.hdr.rx_data;
-	struct rx_pkt_attrib	*pattrib = &precv_frame->u.hdr.attrib;
+	u8 *ptr = precv_frame->rx_data;
+	struct rx_pkt_attrib	*pattrib = &precv_frame->attrib;
 	struct security_priv	*psecuritypriv = &adapter->securitypriv;
 	int ret = _SUCCESS;
 
@@ -1238,7 +1266,7 @@ static int validate_recv_data_frame(struct adapter *adapter,
 
 	/* psta->rssi = prxcmd->rssi; */
 	/* psta->signal_quality = prxcmd->sq; */
-	precv_frame->u.hdr.psta = psta;
+	precv_frame->psta = psta;
 
 	pattrib->amsdu = 0;
 	pattrib->ack_policy = 0;
@@ -1259,7 +1287,7 @@ static int validate_recv_data_frame(struct adapter *adapter,
 	if (pattrib->order)/* HT-CTRL 11n */
 		pattrib->hdrlen += 4;
 
-	precv_frame->u.hdr.preorder_ctrl = &psta->recvreorder_ctrl[pattrib->priority];
+	precv_frame->preorder_ctrl = &psta->recvreorder_ctrl[pattrib->priority];
 
 	/*  decache, drop duplicate recv packets */
 	if (recv_decache(precv_frame, bretry, &psta->sta_recvpriv.rxcache) == _FAIL) {
@@ -1289,7 +1317,8 @@ exit:
 	return ret;
 }
 
-static int validate_recv_frame(struct adapter *adapter, union recv_frame *precv_frame)
+static int validate_recv_frame(struct adapter *adapter,
+			       struct recv_frame *precv_frame)
 {
 	/* shall check frame subtype, to / from ds, da, bssid */
 
@@ -1299,8 +1328,8 @@ static int validate_recv_frame(struct adapter *adapter, union recv_frame *precv_
 	u8 subtype;
 	int retval = _SUCCESS;
 	u8 bDumpRxPkt;
-	struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
-	u8 *ptr = precv_frame->u.hdr.rx_data;
+	struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
+	u8 *ptr = precv_frame->rx_data;
 	u8  ver = (unsigned char) (*ptr)&0x3;
 	struct mlme_ext_priv *pmlmeext = &adapter->mlmeextpriv;
 
@@ -1399,7 +1428,7 @@ exit:
 
 /* remove the wlanhdr and add the eth_hdr */
 
-static int wlanhdr_to_ethhdr (union recv_frame *precvframe)
+static int wlanhdr_to_ethhdr(struct recv_frame *precvframe)
 {
 	int	rmv_len;
 	u16	eth_type, len;
@@ -1409,11 +1438,11 @@ static int wlanhdr_to_ethhdr (union recv_frame *precvframe)
 	struct ieee80211_snap_hdr	*psnap;
 
 	int ret = _SUCCESS;
-	struct adapter			*adapter = precvframe->u.hdr.adapter;
+	struct adapter		*adapter = precvframe->adapter;
 	struct mlme_priv	*pmlmepriv = &adapter->mlmepriv;
 
 	u8	*ptr = get_recvframe_data(precvframe); /*  point to frame_ctrl field */
-	struct rx_pkt_attrib *pattrib = &precvframe->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &precvframe->attrib;
 
 
 	if (pattrib->encrypt)
@@ -1434,7 +1463,7 @@ static int wlanhdr_to_ethhdr (union recv_frame *precvframe)
 	}
 
 	rmv_len = pattrib->hdrlen + pattrib->iv_len + (bsnaphdr ? SNAP_SIZE : 0);
-	len = precvframe->u.hdr.len - rmv_len;
+	len = precvframe->len - rmv_len;
 
 	RT_TRACE(_module_rtl871x_recv_c_, _drv_info_,
 		 ("\n===pattrib->hdrlen: %x,  pattrib->iv_len:%x===\n\n", pattrib->hdrlen,  pattrib->iv_len));
@@ -1469,13 +1498,14 @@ static int wlanhdr_to_ethhdr (union recv_frame *precvframe)
 }
 
 /* perform defrag */
-static union recv_frame *recvframe_defrag(struct adapter *adapter, struct __queue *defrag_q)
+static struct recv_frame *recvframe_defrag(struct adapter *adapter,
+					   struct __queue *defrag_q)
 {
 	struct list_head *plist, *phead;
 	u8 wlanhdr_offset;
 	u8	curfragnum;
-	struct recv_frame_hdr *pfhdr, *pnfhdr;
-	union recv_frame *prframe, *pnextrframe;
+	struct recv_frame *pfhdr, *pnfhdr;
+	struct recv_frame *prframe, *pnextrframe;
 	struct __queue *pfree_recv_queue;
 
 
@@ -1484,9 +1514,9 @@ static union recv_frame *recvframe_defrag(struct adapter *adapter, struct __queu
 
 	phead = get_list_head(defrag_q);
 	plist = phead->next;
-	pfhdr = container_of(plist, struct recv_frame_hdr, list);
-	prframe = (union recv_frame *)pfhdr;
-	rtw_list_delete(&(prframe->u.hdr.list));
+	pfhdr = container_of(plist, struct recv_frame, list);
+	prframe = (struct recv_frame *)pfhdr;
+	rtw_list_delete(&(prframe->list));
 
 	if (curfragnum != pfhdr->attrib.frag_num) {
 		/* the first fragment number must be 0 */
@@ -1504,8 +1534,8 @@ static union recv_frame *recvframe_defrag(struct adapter *adapter, struct __queu
 	plist = plist->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		pnfhdr = container_of(plist, struct recv_frame_hdr , list);
-		pnextrframe = (union recv_frame *)pnfhdr;
+		pnfhdr = container_of(plist, struct recv_frame, list);
+		pnextrframe = (struct recv_frame *)pnfhdr;
 
 		/* check the fragment sequence  (2nd ~n fragment frame) */
 
@@ -1548,22 +1578,23 @@ static union recv_frame *recvframe_defrag(struct adapter *adapter, struct __queu
 }
 
 /* check if need to defrag, if needed queue the frame to defrag_q */
-union recv_frame *recvframe_chk_defrag(struct adapter *padapter, union recv_frame *precv_frame)
+struct recv_frame *recvframe_chk_defrag(struct adapter *padapter,
+					struct recv_frame *precv_frame)
 {
 	u8	ismfrag;
 	u8	fragnum;
 	u8	*psta_addr;
-	struct recv_frame_hdr *pfhdr;
+	struct recv_frame *pfhdr;
 	struct sta_info *psta;
 	struct sta_priv *pstapriv;
 	struct list_head *phead;
-	union recv_frame *prtnframe = NULL;
+	struct recv_frame *prtnframe = NULL;
 	struct __queue *pfree_recv_queue, *pdefrag_q;
 
 
 	pstapriv = &padapter->stapriv;
 
-	pfhdr = &precv_frame->u.hdr;
+	pfhdr = precv_frame;
 
 	pfree_recv_queue = &padapter->recvpriv.free_recv_queue;
 
@@ -1635,7 +1666,7 @@ union recv_frame *recvframe_chk_defrag(struct adapter *padapter, union recv_fram
 		}
 	}
 
-	if ((prtnframe != NULL) && (prtnframe->u.hdr.attrib.privacy)) {
+	if ((prtnframe != NULL) && (prtnframe->attrib.privacy)) {
 		/* after defrag we must check tkip mic code */
 		if (recvframe_chkmic(padapter,  prtnframe) == _FAIL) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_err_, ("recvframe_chkmic(padapter,  prtnframe)==_FAIL\n"));
@@ -1648,7 +1679,7 @@ union recv_frame *recvframe_chk_defrag(struct adapter *padapter, union recv_fram
 	return prtnframe;
 }
 
-static int amsdu_to_msdu(struct adapter *padapter, union recv_frame *prframe)
+static int amsdu_to_msdu(struct adapter *padapter, struct recv_frame *prframe)
 {
 	int	a_len, padding_len;
 	u16	eth_type, nSubframe_Length;
@@ -1662,16 +1693,16 @@ static int amsdu_to_msdu(struct adapter *padapter, union recv_frame *prframe)
 	int	ret = _SUCCESS;
 	nr_subframes = 0;
 
-	pattrib = &prframe->u.hdr.attrib;
+	pattrib = &prframe->attrib;
 
-	recvframe_pull(prframe, prframe->u.hdr.attrib.hdrlen);
+	recvframe_pull(prframe, prframe->attrib.hdrlen);
 
-	if (prframe->u.hdr.attrib.iv_len > 0)
-		recvframe_pull(prframe, prframe->u.hdr.attrib.iv_len);
+	if (prframe->attrib.iv_len > 0)
+		recvframe_pull(prframe, prframe->attrib.iv_len);
 
-	a_len = prframe->u.hdr.len;
+	a_len = prframe->len;
 
-	pdata = prframe->u.hdr.rx_data;
+	pdata = prframe->rx_data;
 
 	while (a_len > ETH_HLEN) {
 		/* Offset 12 denote 2 mac address */
@@ -1693,7 +1724,7 @@ static int amsdu_to_msdu(struct adapter *padapter, union recv_frame *prframe)
 			data_ptr = (u8 *)skb_put(sub_skb, nSubframe_Length);
 			memcpy(data_ptr, pdata, nSubframe_Length);
 		} else {
-			sub_skb = skb_clone(prframe->u.hdr.pkt, GFP_ATOMIC);
+			sub_skb = skb_clone(prframe->pkt, GFP_ATOMIC);
 			if (sub_skb) {
 				sub_skb->data = pdata;
 				sub_skb->len = nSubframe_Length;
@@ -1760,7 +1791,7 @@ static int amsdu_to_msdu(struct adapter *padapter, union recv_frame *prframe)
 
 exit:
 
-	prframe->u.hdr.len = 0;
+	prframe->len = 0;
 	rtw_free_recvframe(prframe, pfree_recv_queue);/* free this recv_frame */
 
 	return ret;
@@ -1796,20 +1827,20 @@ static int check_indicate_seq(struct recv_reorder_ctrl *preorder_ctrl, u16 seq_n
 	return true;
 }
 
-int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl, union recv_frame *prframe);
-int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl, union recv_frame *prframe)
+int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl,
+			      struct recv_frame *prframe)
 {
-	struct rx_pkt_attrib *pattrib = &prframe->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &prframe->attrib;
 	struct __queue *ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
 	struct list_head *phead, *plist;
-	struct recv_frame_hdr *hdr;
+	struct recv_frame *hdr;
 	struct rx_pkt_attrib *pnextattrib;
 
 	phead = get_list_head(ppending_recvframe_queue);
 	plist = phead->next;
 
 	while (rtw_end_of_queue_search(phead, plist) == false) {
-		hdr = container_of(plist, struct recv_frame_hdr, list);
+		hdr = container_of(plist, struct recv_frame, list);
 		pnextattrib = &hdr->attrib;
 
 		if (SN_LESS(pnextattrib->seq_num, pattrib->seq_num))
@@ -1820,17 +1851,17 @@ int enqueue_reorder_recvframe(struct recv_reorder_ctrl *preorder_ctrl, union rec
 			break;
 	}
 
-	rtw_list_delete(&(prframe->u.hdr.list));
+	rtw_list_delete(&(prframe->list));
 
-	rtw_list_insert_tail(&(prframe->u.hdr.list), plist);
+	rtw_list_insert_tail(&(prframe->list), plist);
 	return true;
 }
 
 static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reorder_ctrl *preorder_ctrl, int bforced)
 {
 	struct list_head *phead, *plist;
-	union recv_frame *prframe;
-	struct recv_frame_hdr *prhdr;
+	struct recv_frame *prframe;
+	struct recv_frame *prhdr;
 	struct rx_pkt_attrib *pattrib;
 	int bPktInBuf = false;
 	struct recv_priv *precvpriv = &padapter->recvpriv;
@@ -1844,7 +1875,7 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 		if (rtw_is_list_empty(phead))
 			return true;
 
-		prhdr = container_of(plist, struct recv_frame_hdr, list);
+		prhdr = container_of(plist, struct recv_frame, list);
 	        pattrib = &prhdr->attrib;
 		preorder_ctrl->indicate_seq = pattrib->seq_num;
 	}
@@ -1852,16 +1883,16 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 	/*  Prepare indication list and indication. */
 	/*  Check if there is any packet need indicate. */
 	while (!rtw_is_list_empty(phead)) {
-		prhdr = container_of(plist, struct recv_frame_hdr, list);
-		prframe = (union recv_frame *)prhdr;
-		pattrib = &prframe->u.hdr.attrib;
+		prhdr = container_of(plist, struct recv_frame, list);
+		prframe = (struct recv_frame *)prhdr;
+		pattrib = &prframe->attrib;
 
 		if (!SN_LESS(preorder_ctrl->indicate_seq, pattrib->seq_num)) {
 			RT_TRACE(_module_rtl871x_recv_c_, _drv_notice_,
 				 ("recv_indicatepkts_in_order: indicate=%d seq=%d amsdu=%d\n",
 				  preorder_ctrl->indicate_seq, pattrib->seq_num, pattrib->amsdu));
 			plist = plist->next;
-			rtw_list_delete(&(prframe->u.hdr.list));
+			rtw_list_delete(&(prframe->list));
 
 			if (SN_EQUAL(preorder_ctrl->indicate_seq, pattrib->seq_num))
 				preorder_ctrl->indicate_seq = (preorder_ctrl->indicate_seq + 1) & 0xFFF;
@@ -1890,11 +1921,12 @@ static int recv_indicatepkts_in_order(struct adapter *padapter, struct recv_reor
 	return bPktInBuf;
 }
 
-static int recv_indicatepkt_reorder(struct adapter *padapter, union recv_frame *prframe)
+static int recv_indicatepkt_reorder(struct adapter *padapter,
+				    struct recv_frame *prframe)
 {
 	int retval = _SUCCESS;
-	struct rx_pkt_attrib *pattrib = &prframe->u.hdr.attrib;
-	struct recv_reorder_ctrl *preorder_ctrl = prframe->u.hdr.preorder_ctrl;
+	struct rx_pkt_attrib *pattrib = &prframe->attrib;
+	struct recv_reorder_ctrl *preorder_ctrl = prframe->preorder_ctrl;
 	struct __queue *ppending_recvframe_queue = &preorder_ctrl->pending_recvframe_queue;
 
 	if (!pattrib->amsdu) {
@@ -1998,17 +2030,14 @@ void rtw_reordering_ctrl_timeout_handler(void *pcontext)
 	spin_unlock_bh(&ppending_recvframe_queue->lock);
 }
 
-static int process_recv_indicatepkts(struct adapter *padapter, union recv_frame *prframe)
+static int process_recv_indicatepkts(struct adapter *padapter,
+				     struct recv_frame *prframe)
 {
 	int retval = _SUCCESS;
-	/* struct recv_priv *precvpriv = &padapter->recvpriv; */
-	/* struct rx_pkt_attrib *pattrib = &prframe->u.hdr.attrib; */
 	struct mlme_priv	*pmlmepriv = &padapter->mlmepriv;
 	struct ht_priv	*phtpriv = &pmlmepriv->htpriv;
 
 	if (phtpriv->ht_option) {  /* B/G/N Mode */
-		/* prframe->u.hdr.preorder_ctrl = &precvpriv->recvreorder_ctrl[pattrib->priority]; */
-
 		if (recv_indicatepkt_reorder(padapter, prframe) != _SUCCESS) {
 			/*  including perform A-MPDU Rx Ordering Buffer Control */
 			if ((!padapter->bDriverStopped) &&
@@ -2041,10 +2070,11 @@ static int process_recv_indicatepkts(struct adapter *padapter, union recv_frame
 	return retval;
 }
 
-static int recv_func_prehandle(struct adapter *padapter, union recv_frame *rframe)
+static int recv_func_prehandle(struct adapter *padapter,
+			       struct recv_frame *rframe)
 {
 	int ret = _SUCCESS;
-	struct rx_pkt_attrib *pattrib = &rframe->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &rframe->attrib;
 	struct __queue *pfree_recv_queue = &padapter->recvpriv.free_recv_queue;
 	struct mlme_priv *pmlmepriv = &padapter->mlmepriv;
 
@@ -2076,10 +2106,11 @@ exit:
 	return ret;
 }
 
-static int recv_func_posthandle(struct adapter *padapter, union recv_frame *prframe)
+static int recv_func_posthandle(struct adapter *padapter,
+				struct recv_frame *prframe)
 {
 	int ret = _SUCCESS;
-	union recv_frame *orig_prframe = prframe;
+	struct recv_frame *orig_prframe = prframe;
 	struct recv_priv *precvpriv = &padapter->recvpriv;
 	struct __queue *pfree_recv_queue = &padapter->recvpriv.free_recv_queue;
 
@@ -2121,16 +2152,16 @@ _recv_data_drop:
 	return ret;
 }
 
-static int recv_func(struct adapter *padapter, union recv_frame *rframe)
+static int recv_func(struct adapter *padapter, struct recv_frame *rframe)
 {
 	int ret;
-	struct rx_pkt_attrib *prxattrib = &rframe->u.hdr.attrib;
+	struct rx_pkt_attrib *prxattrib = &rframe->attrib;
 	struct security_priv *psecuritypriv = &padapter->securitypriv;
 	struct mlme_priv *mlmepriv = &padapter->mlmepriv;
 
 	/* check if need to handle uc_swdec_pending_queue*/
 	if (check_fwstate(mlmepriv, WIFI_STATION_STATE) && psecuritypriv->busetkipkey) {
-		union recv_frame *pending_frame;
+		struct recv_frame *pending_frame;
 
 		while ((pending_frame = rtw_alloc_recvframe(&padapter->recvpriv.uc_swdec_pending_queue))) {
 			if (recv_func_posthandle(padapter, pending_frame) == _SUCCESS)
@@ -2159,14 +2190,14 @@ exit:
 	return ret;
 }
 
-s32 rtw_recv_entry(union recv_frame *precvframe)
+s32 rtw_recv_entry(struct recv_frame *precvframe)
 {
 	struct adapter *padapter;
 	struct recv_priv *precvpriv;
 	s32 ret = _SUCCESS;
 
 
-	padapter = precvframe->u.hdr.adapter;
+	padapter = precvframe->adapter;
 
 	precvpriv = &padapter->recvpriv;
 
diff --git a/drivers/staging/rtl8188eu/core/rtw_security.c b/drivers/staging/rtl8188eu/core/rtw_security.c
index c3ce569..c4b16ea 100644
--- a/drivers/staging/rtl8188eu/core/rtw_security.c
+++ b/drivers/staging/rtl8188eu/core/rtw_security.c
@@ -205,11 +205,11 @@ void rtw_wep_decrypt(struct adapter  *padapter, u8 *precvframe)
 	u32	keylength;
 	u8	*pframe, *payload, *iv, wepkey[16];
 	u8	 keyindex;
-	struct	rx_pkt_attrib	 *prxattrib = &(((union recv_frame *)precvframe)->u.hdr.attrib);
+	struct	rx_pkt_attrib	 *prxattrib = &(((struct recv_frame *)precvframe)->attrib);
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 
 
-	pframe = (unsigned char *)((union recv_frame *)precvframe)->u.hdr.rx_data;
+	pframe = (unsigned char *)((struct recv_frame *)precvframe)->rx_data;
 
 	/* start to decrypt recvframe */
 	if ((prxattrib->encrypt == _WEP40_) || (prxattrib->encrypt == _WEP104_)) {
@@ -218,7 +218,7 @@ void rtw_wep_decrypt(struct adapter  *padapter, u8 *precvframe)
 		keylength = psecuritypriv->dot11DefKeylen[keyindex];
 		memcpy(&wepkey[0], iv, 3);
 		memcpy(&wepkey[3], &psecuritypriv->dot11DefKey[keyindex].skey[0], keylength);
-		length = ((union recv_frame *)precvframe)->u.hdr.len-prxattrib->hdrlen-prxattrib->iv_len;
+		length = ((struct recv_frame *)precvframe)->len-prxattrib->hdrlen-prxattrib->iv_len;
 
 		payload = pframe+prxattrib->iv_len+prxattrib->hdrlen;
 
@@ -653,12 +653,12 @@ u32 rtw_tkip_decrypt(struct adapter *padapter, u8 *precvframe)
 	u8	*pframe, *payload, *iv, *prwskey;
 	union pn48 dot11txpn;
 	struct	sta_info		*stainfo;
-	struct	rx_pkt_attrib	 *prxattrib = &((union recv_frame *)precvframe)->u.hdr.attrib;
+	struct	rx_pkt_attrib	 *prxattrib = &((struct recv_frame *)precvframe)->attrib;
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 	u32		res = _SUCCESS;
 
 
-	pframe = (unsigned char *)((union recv_frame *)precvframe)->u.hdr.rx_data;
+	pframe = (unsigned char *)((struct recv_frame *)precvframe)->rx_data;
 
 	/* 4 start to decrypt recvframe */
 	if (prxattrib->encrypt == _TKIP_) {
@@ -678,7 +678,7 @@ u32 rtw_tkip_decrypt(struct adapter *padapter, u8 *precvframe)
 
 			iv = pframe+prxattrib->hdrlen;
 			payload = pframe+prxattrib->iv_len+prxattrib->hdrlen;
-			length = ((union recv_frame *)precvframe)->u.hdr.len-prxattrib->hdrlen-prxattrib->iv_len;
+			length = ((struct recv_frame *)precvframe)->len-prxattrib->hdrlen-prxattrib->iv_len;
 
 			GET_TKIP_PN(iv, dot11txpn);
 
@@ -1455,10 +1455,10 @@ u32	rtw_aes_decrypt(struct adapter *padapter, u8 *precvframe)
 	int		length;
 	u8	*pframe, *prwskey;	/*  *payload,*iv */
 	struct	sta_info		*stainfo;
-	struct	rx_pkt_attrib	 *prxattrib = &((union recv_frame *)precvframe)->u.hdr.attrib;
+	struct	rx_pkt_attrib	 *prxattrib = &((struct recv_frame *)precvframe)->attrib;
 	struct	security_priv	*psecuritypriv = &padapter->securitypriv;
 	u32	res = _SUCCESS;
-	pframe = (unsigned char *)((union recv_frame *)precvframe)->u.hdr.rx_data;
+	pframe = (unsigned char *)((struct recv_frame *)precvframe)->rx_data;
 	/* 4 start to encrypt each fragment */
 	if ((prxattrib->encrypt == _AES_)) {
 		stainfo = rtw_get_stainfo(&padapter->stapriv, &prxattrib->ta[0]);
@@ -1482,7 +1482,7 @@ u32	rtw_aes_decrypt(struct adapter *padapter, u8 *precvframe)
 			} else {
 				prwskey = &stainfo->dot118021x_UncstKey.skey[0];
 			}
-			length = ((union recv_frame *)precvframe)->u.hdr.len-prxattrib->hdrlen-prxattrib->iv_len;
+			length = ((struct recv_frame *)precvframe)->len-prxattrib->hdrlen-prxattrib->iv_len;
 			res = aes_decipher(prwskey, prxattrib->hdrlen, pframe, length);
 		} else {
 			RT_TRACE(_module_rtl871x_security_c_, _drv_err_, ("rtw_aes_encrypt: stainfo==NULL!!!\n"));
diff --git a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
index a59f062..2d0b606 100644
--- a/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
+++ b/drivers/staging/rtl8188eu/core/rtw_sta_mgt.c
@@ -346,8 +346,8 @@ u32	rtw_free_stainfo(struct adapter *padapter , struct sta_info *psta)
 	/* for A-MPDU Rx reordering buffer control, cancel reordering_ctrl_timer */
 	for (i = 0; i < 16; i++) {
 		struct list_head *phead, *plist;
-		struct recv_frame_hdr *prhdr;
-		union recv_frame *prframe;
+		struct recv_frame *prhdr;
+		struct recv_frame *prframe;
 		struct __queue *ppending_recvframe_queue;
 		struct __queue *pfree_recv_queue = &padapter->recvpriv.free_recv_queue;
 
@@ -363,12 +363,12 @@ u32	rtw_free_stainfo(struct adapter *padapter , struct sta_info *psta)
 		plist = phead->next;
 
 		while (!rtw_is_list_empty(phead)) {
-			prhdr = container_of(plist, struct recv_frame_hdr, list);
-			prframe = (union recv_frame *)prhdr;
+			prhdr = container_of(plist, struct recv_frame, list);
+			prframe = (struct recv_frame *)prhdr;
 
 			plist = plist->next;
 
-			rtw_list_delete(&(prframe->u.hdr.list));
+			rtw_list_delete(&(prframe->list));
 
 			rtw_free_recvframe(prframe, pfree_recv_queue);
 		}
diff --git a/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c b/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
index 4e36306..f29bb79 100644
--- a/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
+++ b/drivers/staging/rtl8188eu/hal/rtl8188e_rxdesc.c
@@ -23,9 +23,9 @@
 #include <drv_types.h>
 #include <rtl8188e_hal.h>
 
-static void process_rssi(struct adapter *padapter, union recv_frame *prframe)
+static void process_rssi(struct adapter *padapter, struct recv_frame *prframe)
 {
-	struct rx_pkt_attrib *pattrib = &prframe->u.hdr.attrib;
+	struct rx_pkt_attrib *pattrib = &prframe->attrib;
 	struct signal_stat *signal_stat = &padapter->recvpriv.signal_strength_data;
 
 	if (signal_stat->update_req) {
@@ -39,7 +39,8 @@ static void process_rssi(struct adapter *padapter, union recv_frame *prframe)
 	signal_stat->avg_val = signal_stat->total_val / signal_stat->total_num;
 } /*  Process_UI_RSSI_8192C */
 
-static void process_link_qual(struct adapter *padapter, union recv_frame *prframe)
+static void process_link_qual(struct adapter *padapter,
+			      struct recv_frame *prframe)
 {
 	struct rx_pkt_attrib *pattrib;
 	struct signal_stat *signal_stat;
@@ -47,7 +48,7 @@ static void process_link_qual(struct adapter *padapter, union recv_frame *prfram
 	if (prframe == NULL || padapter == NULL)
 		return;
 
-	pattrib = &prframe->u.hdr.attrib;
+	pattrib = &prframe->attrib;
 	signal_stat = &padapter->recvpriv.signal_qual_data;
 
 	if (signal_stat->update_req) {
@@ -63,7 +64,7 @@ static void process_link_qual(struct adapter *padapter, union recv_frame *prfram
 
 void rtl8188e_process_phy_info(struct adapter *padapter, void *prframe)
 {
-	union recv_frame *precvframe = (union recv_frame *)prframe;
+	struct recv_frame *precvframe = (struct recv_frame *)prframe;
 
 	/*  Check RSSI */
 	process_rssi(padapter, precvframe);
@@ -71,7 +72,8 @@ void rtl8188e_process_phy_info(struct adapter *padapter, void *prframe)
 	process_link_qual(padapter,  precvframe);
 }
 
-void update_recvframe_attrib_88e(union recv_frame *precvframe, struct recv_stat *prxstat)
+void update_recvframe_attrib_88e(struct recv_frame *precvframe,
+				 struct recv_stat *prxstat)
 {
 	struct rx_pkt_attrib	*pattrib;
 	struct recv_stat	report;
@@ -83,7 +85,7 @@ void update_recvframe_attrib_88e(union recv_frame *precvframe, struct recv_stat
 	report.rxdw4 = prxstat->rxdw4;
 	report.rxdw5 = prxstat->rxdw5;
 
-	pattrib = &precvframe->u.hdr.attrib;
+	pattrib = &precvframe->attrib;
 	_rtw_memset(pattrib, 0, sizeof(struct rx_pkt_attrib));
 
 	pattrib->crc_err = (u8)((le32_to_cpu(report.rxdw0) >> 14) & 0x1);/* u8)prxreport->crc32; */
@@ -136,12 +138,13 @@ void update_recvframe_attrib_88e(union recv_frame *precvframe, struct recv_stat
 /*
  * Notice:
  *	Before calling this function,
- *	precvframe->u.hdr.rx_data should be ready!
+ *	precvframe->rx_data should be ready!
  */
-void update_recvframe_phyinfo_88e(union recv_frame *precvframe, struct phy_stat *pphy_status)
+void update_recvframe_phyinfo_88e(struct recv_frame *precvframe,
+				  struct phy_stat *pphy_status)
 {
-	struct adapter *padapter = precvframe->u.hdr.adapter;
-	struct rx_pkt_attrib *pattrib = &precvframe->u.hdr.attrib;
+	struct adapter *padapter = precvframe->adapter;
+	struct rx_pkt_attrib *pattrib = &precvframe->attrib;
 	struct hal_data_8188e *pHalData = GET_HAL_DATA(padapter);
 	struct odm_phy_status_info *pPHYInfo  = (struct odm_phy_status_info *)(&pattrib->phy_info);
 	u8 *wlanhdr;
@@ -185,17 +188,17 @@ void update_recvframe_phyinfo_88e(union recv_frame *precvframe, struct phy_stat
 
 	ODM_PhyStatusQuery(&pHalData->odmpriv, pPHYInfo, (u8 *)pphy_status, &(pkt_info));
 
-	precvframe->u.hdr.psta = NULL;
+	precvframe->psta = NULL;
 	if (pkt_info.bPacketMatchBSSID &&
 	    (check_fwstate(&padapter->mlmepriv, WIFI_AP_STATE))) {
 		if (psta) {
-			precvframe->u.hdr.psta = psta;
+			precvframe->psta = psta;
 			rtl8188e_process_phy_info(padapter, precvframe);
 		}
 	} else if (pkt_info.bPacketToSelf || pkt_info.bPacketBeacon) {
 		if (check_fwstate(&padapter->mlmepriv, WIFI_ADHOC_STATE|WIFI_ADHOC_MASTER_STATE)) {
 			if (psta)
-				precvframe->u.hdr.psta = psta;
+				precvframe->psta = psta;
 		}
 		rtl8188e_process_phy_info(padapter, precvframe);
 	}
diff --git a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
index 74ee2e6..1bfe497 100644
--- a/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
+++ b/drivers/staging/rtl8188eu/hal/usb_ops_linux.c
@@ -306,7 +306,7 @@ static int recvbuf2recvframe(struct adapter *adapt, struct sk_buff *pskb)
 	struct recv_stat	*prxstat;
 	struct phy_stat	*pphy_status = NULL;
 	struct sk_buff *pkt_copy = NULL;
-	union recv_frame	*precvframe = NULL;
+	struct recv_frame	*precvframe = NULL;
 	struct rx_pkt_attrib	*pattrib = NULL;
 	struct hal_data_8188e	*haldata = GET_HAL_DATA(adapt);
 	struct recv_priv	*precvpriv = &adapt->recvpriv;
@@ -332,13 +332,13 @@ static int recvbuf2recvframe(struct adapter *adapt, struct sk_buff *pskb)
 			goto _exit_recvbuf2recvframe;
 		}
 
-		_rtw_init_listhead(&precvframe->u.hdr.list);
-		precvframe->u.hdr.precvbuf = NULL;	/* can't access the precvbuf for new arch. */
-		precvframe->u.hdr.len = 0;
+		_rtw_init_listhead(&precvframe->list);
+		precvframe->precvbuf = NULL;	/* can't access the precvbuf for new arch. */
+		precvframe->len = 0;
 
 		update_recvframe_attrib_88e(precvframe, prxstat);
 
-		pattrib = &precvframe->u.hdr.attrib;
+		pattrib = &precvframe->attrib;
 
 		if ((pattrib->crc_err) || (pattrib->icv_err)) {
 			DBG_88E("%s: RX Warning! crc_err=%d icv_err=%d, skip!\n", __func__, pattrib->crc_err, pattrib->icv_err);
@@ -385,26 +385,26 @@ static int recvbuf2recvframe(struct adapter *adapt, struct sk_buff *pskb)
 		pkt_copy = netdev_alloc_skb(adapt->pnetdev, alloc_sz);
 		if (pkt_copy) {
 			pkt_copy->dev = adapt->pnetdev;
-			precvframe->u.hdr.pkt = pkt_copy;
-			precvframe->u.hdr.rx_head = pkt_copy->data;
-			precvframe->u.hdr.rx_end = pkt_copy->data + alloc_sz;
+			precvframe->pkt = pkt_copy;
+			precvframe->rx_head = pkt_copy->data;
+			precvframe->rx_end = pkt_copy->data + alloc_sz;
 			skb_reserve(pkt_copy, 8 - ((size_t)(pkt_copy->data) & 7));/* force pkt_copy->data at 8-byte alignment address */
 			skb_reserve(pkt_copy, shift_sz);/* force ip_hdr at 8-byte alignment address according to shift_sz. */
 			memcpy(pkt_copy->data, (pbuf + pattrib->drvinfo_sz + RXDESC_SIZE), skb_len);
-			precvframe->u.hdr.rx_tail = pkt_copy->data;
-			precvframe->u.hdr.rx_data = pkt_copy->data;
+			precvframe->rx_tail = pkt_copy->data;
+			precvframe->rx_data = pkt_copy->data;
 		} else {
 			if ((pattrib->mfrag == 1) && (pattrib->frag_num == 0)) {
 				DBG_88E("recvbuf2recvframe: alloc_skb fail , drop frag frame\n");
 				rtw_free_recvframe(precvframe, pfree_recv_queue);
 				goto _exit_recvbuf2recvframe;
 			}
-			precvframe->u.hdr.pkt = skb_clone(pskb, GFP_ATOMIC);
-			if (precvframe->u.hdr.pkt) {
-				precvframe->u.hdr.rx_tail = pbuf + pattrib->drvinfo_sz + RXDESC_SIZE;
-				precvframe->u.hdr.rx_head = precvframe->u.hdr.rx_tail;
-				precvframe->u.hdr.rx_data = precvframe->u.hdr.rx_tail;
-				precvframe->u.hdr.rx_end =  pbuf + pattrib->drvinfo_sz + RXDESC_SIZE + alloc_sz;
+			precvframe->pkt = skb_clone(pskb, GFP_ATOMIC);
+			if (precvframe->pkt) {
+				precvframe->rx_tail = pbuf + pattrib->drvinfo_sz + RXDESC_SIZE;
+				precvframe->rx_head = precvframe->rx_tail;
+				precvframe->rx_data = precvframe->rx_tail;
+				precvframe->rx_end =  pbuf + pattrib->drvinfo_sz + RXDESC_SIZE + alloc_sz;
 			} else {
 				DBG_88E("recvbuf2recvframe: skb_clone fail\n");
 				rtw_free_recvframe(precvframe, pfree_recv_queue);
@@ -437,17 +437,17 @@ static int recvbuf2recvframe(struct adapter *adapt, struct sk_buff *pskb)
 			/* enqueue recvframe to txrtp queue */
 			if (pattrib->pkt_rpt_type == TX_REPORT1) {
 				/* CCX-TXRPT ack for xmit mgmt frames. */
-				handle_txrpt_ccx_88e(adapt, precvframe->u.hdr.rx_data);
+				handle_txrpt_ccx_88e(adapt, precvframe->rx_data);
 			} else if (pattrib->pkt_rpt_type == TX_REPORT2) {
 				ODM_RA_TxRPT2Handle_8188E(
 							&haldata->odmpriv,
-							precvframe->u.hdr.rx_data,
+							precvframe->rx_data,
 							pattrib->pkt_len,
 							pattrib->MacIDValidEntry[0],
 							pattrib->MacIDValidEntry[1]
 							);
 			} else if (pattrib->pkt_rpt_type == HIS_REPORT) {
-				interrupt_handler_8188eu(adapt, pattrib->pkt_len, precvframe->u.hdr.rx_data);
+				interrupt_handler_8188eu(adapt, pattrib->pkt_len, precvframe->rx_data);
 			}
 			rtw_free_recvframe(precvframe, pfree_recv_queue);
 		}
diff --git a/drivers/staging/rtl8188eu/include/recv_osdep.h b/drivers/staging/rtl8188eu/include/recv_osdep.h
index 6912380..d76cc2d 100644
--- a/drivers/staging/rtl8188eu/include/recv_osdep.h
+++ b/drivers/staging/rtl8188eu/include/recv_osdep.h
@@ -28,18 +28,20 @@ int _rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter);
 void _rtw_free_recv_priv(struct recv_priv *precvpriv);
 
 
-s32  rtw_recv_entry(union recv_frame *precv_frame);
-int rtw_recv_indicatepkt(struct adapter *adapter, union recv_frame *recv_frame);
+s32  rtw_recv_entry(struct recv_frame *precv_frame);
+int rtw_recv_indicatepkt(struct adapter *adapter,
+			 struct recv_frame *recv_frame);
 void rtw_recv_returnpacket(struct  net_device *cnxt, struct sk_buff *retpkt);
 
-void rtw_hostapd_mlme_rx(struct adapter *padapter, union recv_frame *recv_fr);
+void rtw_hostapd_mlme_rx(struct adapter *padapter, struct recv_frame *recv_fr);
 void rtw_handle_tkip_mic_err(struct adapter *padapter, u8 bgroup);
 
 int rtw_init_recv_priv(struct recv_priv *precvpriv, struct adapter *padapter);
 void rtw_free_recv_priv(struct recv_priv *precvpriv);
 
 int rtw_os_recv_resource_init(struct recv_priv *recvpr, struct adapter *adapt);
-int rtw_os_recv_resource_alloc(struct adapter *adapt, union recv_frame *recvfr);
+int rtw_os_recv_resource_alloc(struct adapter *adapt,
+			       struct recv_frame *recvfr);
 void rtw_os_recv_resource_free(struct recv_priv *precvpriv);
 
 int rtw_os_recvbuf_resource_alloc(struct adapter *adapt, struct recv_buf *buf);
diff --git a/drivers/staging/rtl8188eu/include/rtl8188e_recv.h b/drivers/staging/rtl8188eu/include/rtl8188e_recv.h
index a8facf0..07e5f52 100644
--- a/drivers/staging/rtl8188eu/include/rtl8188e_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtl8188e_recv.h
@@ -61,9 +61,10 @@ s32 rtl8188eu_init_recv_priv(struct adapter *padapter);
 void rtl8188eu_free_recv_priv(struct adapter *padapter);
 void rtl8188eu_recv_hdl(struct adapter *padapter, struct recv_buf *precvbuf);
 void rtl8188eu_recv_tasklet(void *priv);
-void rtl8188e_query_rx_phy_status(union recv_frame *fr, struct phy_stat *phy);
+void rtl8188e_query_rx_phy_status(struct recv_frame *fr, struct phy_stat *phy);
 void rtl8188e_process_phy_info(struct adapter *padapter, void *prframe);
-void update_recvframe_phyinfo_88e(union recv_frame *fra, struct phy_stat *phy);
-void update_recvframe_attrib_88e(union recv_frame *fra, struct recv_stat *stat);
+void update_recvframe_phyinfo_88e(struct recv_frame *fra, struct phy_stat *phy);
+void update_recvframe_attrib_88e(struct recv_frame *fra,
+				 struct recv_stat *stat);
 
 #endif
diff --git a/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h b/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h
index f0c982d..09e2a39 100644
--- a/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h
+++ b/drivers/staging/rtl8188eu/include/rtw_mlme_ext.h
@@ -236,13 +236,13 @@ enum SCAN_STATE {
 struct mlme_handler {
 	unsigned int   num;
 	char *str;
-	unsigned int (*func)(struct adapter *adapt, union recv_frame *frame);
+	unsigned int (*func)(struct adapter *adapt, struct recv_frame *frame);
 };
 
 struct action_handler {
 	unsigned int   num;
 	char *str;
-	unsigned int (*func)(struct adapter *adapt, union recv_frame *frame);
+	unsigned int (*func)(struct adapter *adapt, struct recv_frame *frame);
 };
 
 struct	ss_res {
@@ -490,7 +490,7 @@ int allocate_fw_sta_entry(struct adapter *padapter);
 void flush_all_cam_entry(struct adapter *padapter);
 
 void site_survey(struct adapter *padapter);
-u8 collect_bss_info(struct adapter *padapter, union recv_frame *precv_frame,
+u8 collect_bss_info(struct adapter *padapter, struct recv_frame *precv_frame,
 		    struct wlan_bssid_ex *bssid);
 void update_network(struct wlan_bssid_ex *dst, struct wlan_bssid_ex *src,
 		    struct adapter *adapter, bool update_ie);
@@ -544,7 +544,8 @@ unsigned int is_ap_in_wep(struct adapter *padapter);
 unsigned int should_forbid_n_rate(struct adapter *padapter);
 
 void report_join_res(struct adapter *padapter, int res);
-void report_survey_event(struct adapter *padapter, union recv_frame *precv_frame);
+void report_survey_event(struct adapter *padapter,
+			 struct recv_frame *precv_frame);
 void report_surveydone_event(struct adapter *padapter);
 void report_del_sta_event(struct adapter *padapter,
 			  unsigned char *addr, unsigned short reason);
@@ -609,46 +610,46 @@ void start_clnt_join(struct adapter *padapter);
 void start_create_ibss(struct adapter *padapter);
 
 unsigned int OnAssocReq(struct adapter *padapter,
-			union recv_frame *precv_frame);
+			struct recv_frame *precv_frame);
 unsigned int OnAssocRsp(struct adapter *padapter,
-			union recv_frame *precv_frame);
+			struct recv_frame *precv_frame);
 unsigned int OnProbeReq(struct adapter *padapter,
-			union recv_frame *precv_frame);
+			struct recv_frame *precv_frame);
 unsigned int OnProbeRsp(struct adapter *padapter,
-			union recv_frame *precv_frame);
+			struct recv_frame *precv_frame);
 unsigned int DoReserved(struct adapter *padapter,
-			union recv_frame *precv_frame);
+			struct recv_frame *precv_frame);
 unsigned int OnBeacon(struct adapter *padapter,
-		      union recv_frame *precv_frame);
+		      struct recv_frame *precv_frame);
 unsigned int OnAtim(struct adapter *padapter,
-		    union recv_frame *precv_frame);
+		    struct recv_frame *precv_frame);
 unsigned int OnDisassoc(struct adapter *padapter,
-			union recv_frame *precv_frame);
+			struct recv_frame *precv_frame);
 unsigned int OnAuth(struct adapter *padapter,
-		    union recv_frame *precv_frame);
+		    struct recv_frame *precv_frame);
 unsigned int OnAuthClient(struct adapter *padapter,
-			  union recv_frame *precv_frame);
+			  struct recv_frame *precv_frame);
 unsigned int OnDeAuth(struct adapter *padapter,
-		      union recv_frame *precv_frame);
+		      struct recv_frame *precv_frame);
 unsigned int OnAction(struct adapter *padapter,
-		      union recv_frame *precv_frame);
+		      struct recv_frame *precv_frame);
 
 unsigned int on_action_spct(struct adapter *padapter,
-			    union recv_frame *precv_frame);
+			    struct recv_frame *precv_frame);
 unsigned int OnAction_qos(struct adapter *padapter,
-			  union recv_frame *precv_frame);
+			  struct recv_frame *precv_frame);
 unsigned int OnAction_dls(struct adapter *padapter,
-			  union recv_frame *precv_frame);
+			  struct recv_frame *precv_frame);
 unsigned int OnAction_back(struct adapter *padapter,
-			   union recv_frame *precv_frame);
+			   struct recv_frame *precv_frame);
 unsigned int on_action_public(struct adapter *padapter,
-			      union recv_frame *precv_frame);
+			      struct recv_frame *precv_frame);
 unsigned int OnAction_ht(struct adapter *padapter,
-			 union recv_frame *precv_frame);
+			 struct recv_frame *precv_frame);
 unsigned int OnAction_wmm(struct adapter *padapter,
-			  union recv_frame *precv_frame);
+			  struct recv_frame *precv_frame);
 unsigned int OnAction_p2p(struct adapter *padapter,
-			  union recv_frame *precv_frame);
+			  struct recv_frame *precv_frame);
 
 void mlmeext_joinbss_event_callback(struct adapter *padapter, int join_res);
 void mlmeext_sta_del_event_callback(struct adapter *padapter);
diff --git a/drivers/staging/rtl8188eu/include/rtw_recv.h b/drivers/staging/rtl8188eu/include/rtw_recv.h
index c6d7a65..e579c38 100644
--- a/drivers/staging/rtl8188eu/include/rtw_recv.h
+++ b/drivers/staging/rtl8188eu/include/rtw_recv.h
@@ -270,7 +270,7 @@ struct recv_buf {
 	len = (unsigned int )(tail - data);
 
 */
-struct recv_frame_hdr {
+struct recv_frame {
 	struct list_head list;
 	struct sk_buff	 *pkt;
 	struct sk_buff	 *pkt_newalloc;
@@ -289,21 +289,16 @@ struct recv_frame_hdr {
 	struct recv_reorder_ctrl *preorder_ctrl;
 };
 
-union recv_frame {
-	union {
-		struct recv_frame_hdr hdr;
-	} u;
-};
-
-union recv_frame *_rtw_alloc_recvframe(struct __queue *pfree_recv_queue);
-union recv_frame *rtw_alloc_recvframe(struct __queue *pfree_recv_queue);
-void rtw_init_recvframe(union recv_frame *precvframe,
+struct recv_frame *_rtw_alloc_recvframe(struct __queue *pfree_recv_queue);
+struct recv_frame *rtw_alloc_recvframe(struct __queue *pfree_recv_queue);
+void rtw_init_recvframe(struct recv_frame *precvframe,
 			struct recv_priv *precvpriv);
-int  rtw_free_recvframe(union recv_frame *precvframe,
+int  rtw_free_recvframe(struct recv_frame *precvframe,
 			struct __queue *pfree_recv_queue);
 #define rtw_dequeue_recvframe(queue) rtw_alloc_recvframe(queue)
-int _rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue);
-int rtw_enqueue_recvframe(union recv_frame *precvframe, struct __queue *queue);
+int _rtw_enqueue_recvframe(struct recv_frame *precvframe,
+			   struct __queue *queue);
+int rtw_enqueue_recvframe(struct recv_frame *precvframe, struct __queue *queue);
 void rtw_free_recvframe_queue(struct __queue *pframequeue,
 			      struct __queue *pfree_recv_queue);
 u32 rtw_free_uc_swdec_pending_queue(struct adapter *adapter);
@@ -313,29 +308,29 @@ struct recv_buf *rtw_dequeue_recvbuf(struct __queue *queue);
 
 void rtw_reordering_ctrl_timeout_handler(void *pcontext);
 
-static inline u8 *get_rxmem(union recv_frame *precvframe)
+static inline u8 *get_rxmem(struct recv_frame *precvframe)
 {
 	/* always return rx_head... */
 	if (precvframe == NULL)
 		return NULL;
-	return precvframe->u.hdr.rx_head;
+	return precvframe->rx_head;
 }
 
-static inline u8 *get_rx_status(union recv_frame *precvframe)
+static inline u8 *get_rx_status(struct recv_frame *precvframe)
 {
 	return get_rxmem(precvframe);
 }
 
-static inline u8 *get_recvframe_data(union recv_frame *precvframe)
+static inline u8 *get_recvframe_data(struct recv_frame *precvframe)
 {
 	/* always return rx_data */
 	if (precvframe == NULL)
 		return NULL;
 
-	return precvframe->u.hdr.rx_data;
+	return precvframe->rx_data;
 }
 
-static inline u8 *recvframe_push(union recv_frame *precvframe, int sz)
+static inline u8 *recvframe_push(struct recv_frame *precvframe, int sz)
 {
 	/*  append data before rx_data */
 
@@ -346,16 +341,16 @@ static inline u8 *recvframe_push(union recv_frame *precvframe, int sz)
  */
 	if (precvframe == NULL)
 		return NULL;
-	precvframe->u.hdr.rx_data -= sz ;
-	if (precvframe->u.hdr.rx_data < precvframe->u.hdr.rx_head) {
-		precvframe->u.hdr.rx_data += sz;
+	precvframe->rx_data -= sz;
+	if (precvframe->rx_data < precvframe->rx_head) {
+		precvframe->rx_data += sz;
 		return NULL;
 	}
-	precvframe->u.hdr.len += sz;
-	return precvframe->u.hdr.rx_data;
+	precvframe->len += sz;
+	return precvframe->rx_data;
 }
 
-static inline u8 *recvframe_pull(union recv_frame *precvframe, int sz)
+static inline u8 *recvframe_pull(struct recv_frame *precvframe, int sz)
 {
 	/*  rx_data += sz; move rx_data sz bytes  hereafter */
 
@@ -364,16 +359,16 @@ static inline u8 *recvframe_pull(union recv_frame *precvframe, int sz)
 
 	if (precvframe == NULL)
 		return NULL;
-	precvframe->u.hdr.rx_data += sz;
-	if (precvframe->u.hdr.rx_data > precvframe->u.hdr.rx_tail) {
-		precvframe->u.hdr.rx_data -= sz;
+	precvframe->rx_data += sz;
+	if (precvframe->rx_data > precvframe->rx_tail) {
+		precvframe->rx_data -= sz;
 		return NULL;
 	}
-	precvframe->u.hdr.len -= sz;
-	return precvframe->u.hdr.rx_data;
+	precvframe->len -= sz;
+	return precvframe->rx_data;
 }
 
-static inline u8 *recvframe_put(union recv_frame *precvframe, int sz)
+static inline u8 *recvframe_put(struct recv_frame *precvframe, int sz)
 {
 	/* used for append sz bytes from ptr to rx_tail, update rx_tail
 	 * and return the updated rx_tail to the caller */
@@ -382,17 +377,17 @@ static inline u8 *recvframe_put(union recv_frame *precvframe, int sz)
 	if (precvframe == NULL)
 		return NULL;
 
-	precvframe->u.hdr.rx_tail += sz;
+	precvframe->rx_tail += sz;
 
-	if (precvframe->u.hdr.rx_tail > precvframe->u.hdr.rx_end) {
-		precvframe->u.hdr.rx_tail -= sz;
+	if (precvframe->rx_tail > precvframe->rx_end) {
+		precvframe->rx_tail -= sz;
 		return NULL;
 	}
-	precvframe->u.hdr.len += sz;
-	return precvframe->u.hdr.rx_tail;
+	precvframe->len += sz;
+	return precvframe->rx_tail;
 }
 
-static inline u8 *recvframe_pull_tail(union recv_frame *precvframe, int sz)
+static inline u8 *recvframe_pull_tail(struct recv_frame *precvframe, int sz)
 {
 	/*  rmv data from rx_tail (by yitsen) */
 
@@ -402,16 +397,16 @@ static inline u8 *recvframe_pull_tail(union recv_frame *precvframe, int sz)
 
 	if (precvframe == NULL)
 		return NULL;
-	precvframe->u.hdr.rx_tail -= sz;
-	if (precvframe->u.hdr.rx_tail < precvframe->u.hdr.rx_data) {
-		precvframe->u.hdr.rx_tail += sz;
+	precvframe->rx_tail -= sz;
+	if (precvframe->rx_tail < precvframe->rx_data) {
+		precvframe->rx_tail += sz;
 		return NULL;
 	}
-	precvframe->u.hdr.len -= sz;
-	return precvframe->u.hdr.rx_tail;
+	precvframe->len -= sz;
+	return precvframe->rx_tail;
 }
 
-static inline unsigned char *get_rxbuf_desc(union recv_frame *precvframe)
+static inline unsigned char *get_rxbuf_desc(struct recv_frame *precvframe)
 {
 	unsigned char *buf_desc;
 
@@ -420,20 +415,21 @@ static inline unsigned char *get_rxbuf_desc(union recv_frame *precvframe)
 	return buf_desc;
 }
 
-static inline union recv_frame *rxmem_to_recvframe(u8 *rxmem)
+static inline struct recv_frame *rxmem_to_recvframe(u8 *rxmem)
 {
 	/* due to the design of 2048 bytes alignment of recv_frame,
-	 * we can reference the union recv_frame */
+	 * we can reference the struct recv_frame */
 	/* from any given member of recv_frame. */
 	/*  rxmem indicates the any member/address in recv_frame */
 
-	return (union recv_frame *)(((size_t)rxmem >> RXFRAME_ALIGN) << RXFRAME_ALIGN);
+	return (struct recv_frame *)(((size_t)rxmem >> RXFRAME_ALIGN) <<
+				     RXFRAME_ALIGN);
 }
 
-static inline union recv_frame *pkt_to_recvframe(struct sk_buff *pkt)
+static inline struct recv_frame *pkt_to_recvframe(struct sk_buff *pkt)
 {
 	u8 *buf_star;
-	union recv_frame *precv_frame;
+	struct recv_frame *precv_frame;
 	precv_frame = rxmem_to_recvframe((unsigned char *)buf_star);
 
 	return precv_frame;
@@ -443,23 +439,23 @@ static inline u8 *pkt_to_recvmem(struct sk_buff *pkt)
 {
 	/*  return the rx_head */
 
-	union recv_frame *precv_frame = pkt_to_recvframe(pkt);
+	struct recv_frame *precv_frame = pkt_to_recvframe(pkt);
 
-	return	precv_frame->u.hdr.rx_head;
+	return	precv_frame->rx_head;
 }
 
 static inline u8 *pkt_to_recvdata(struct sk_buff *pkt)
 {
 	/*  return the rx_data */
 
-	union recv_frame *precv_frame = pkt_to_recvframe(pkt);
+	struct recv_frame *precv_frame = pkt_to_recvframe(pkt);
 
-	return	precv_frame->u.hdr.rx_data;
+	return	precv_frame->rx_data;
 }
 
-static inline int get_recvframe_len(union recv_frame *precvframe)
+static inline int get_recvframe_len(struct recv_frame *precvframe)
 {
-	return precvframe->u.hdr.len;
+	return precvframe->len;
 }
 
 static inline s32 translate_percentage_to_dbm(u32 sig_stren_index)
@@ -478,6 +474,6 @@ struct sta_info;
 
 void _rtw_init_sta_recv_priv(struct sta_recv_priv *psta_recvpriv);
 
-void  mgt_dispatcher(struct adapter *padapter, union recv_frame *precv_frame);
+void  mgt_dispatcher(struct adapter *padapter, struct recv_frame *precv_frame);
 
 #endif
diff --git a/drivers/staging/rtl8188eu/os_dep/recv_linux.c b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
index fd8ca60..9a9fee4 100644
--- a/drivers/staging/rtl8188eu/os_dep/recv_linux.c
+++ b/drivers/staging/rtl8188eu/os_dep/recv_linux.c
@@ -36,16 +36,16 @@ int rtw_os_recv_resource_init(struct recv_priv *precvpriv,
 	return _SUCCESS;
 }
 
-/* alloc os related resource in union recv_frame */
+/* alloc os related resource in struct recv_frame */
 int rtw_os_recv_resource_alloc(struct adapter *padapter,
-			       union recv_frame *precvframe)
+			       struct recv_frame *precvframe)
 {
-	precvframe->u.hdr.pkt_newalloc = NULL;
-	precvframe->u.hdr.pkt = NULL;
+	precvframe->pkt_newalloc = NULL;
+	precvframe->pkt = NULL;
 	return _SUCCESS;
 }
 
-/* free os related resource in union recv_frame */
+/* free os related resource in struct recv_frame */
 void rtw_os_recv_resource_free(struct recv_priv *precvpriv)
 {
 }
@@ -118,12 +118,12 @@ void rtw_handle_tkip_mic_err(struct adapter *padapter, u8 bgroup)
 }
 
 void rtw_hostapd_mlme_rx(struct adapter *padapter,
-			 union recv_frame *precv_frame)
+			 struct recv_frame *precv_frame)
 {
 }
 
 int rtw_recv_indicatepkt(struct adapter *padapter,
-			 union recv_frame *precv_frame)
+			 struct recv_frame *precv_frame)
 {
 	struct recv_priv *precvpriv;
 	struct __queue *pfree_recv_queue;
@@ -134,7 +134,7 @@ int rtw_recv_indicatepkt(struct adapter *padapter,
 	precvpriv = &(padapter->recvpriv);
 	pfree_recv_queue = &(precvpriv->free_recv_queue);
 
-	skb = precv_frame->u.hdr.pkt;
+	skb = precv_frame->pkt;
 	if (skb == NULL) {
 		RT_TRACE(_module_recv_osdep_c_, _drv_err_,
 			 ("rtw_recv_indicatepkt():skb == NULL something wrong!!!!\n"));
@@ -144,18 +144,18 @@ int rtw_recv_indicatepkt(struct adapter *padapter,
 	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
 		 ("rtw_recv_indicatepkt():skb != NULL !!!\n"));
 	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
-		 ("rtw_recv_indicatepkt():precv_frame->u.hdr.rx_head =%p  precv_frame->hdr.rx_data =%p\n",
-		 precv_frame->u.hdr.rx_head, precv_frame->u.hdr.rx_data));
+		 ("rtw_recv_indicatepkt():precv_frame->rx_head =%p  precv_frame->hdr.rx_data =%p\n",
+		 precv_frame->rx_head, precv_frame->rx_data));
 	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
-		 ("precv_frame->hdr.rx_tail =%p precv_frame->u.hdr.rx_end =%p precv_frame->hdr.len =%d\n",
-		 precv_frame->u.hdr.rx_tail, precv_frame->u.hdr.rx_end,
-		 precv_frame->u.hdr.len));
+		 ("precv_frame->hdr.rx_tail =%p precv_frame->rx_end =%p precv_frame->hdr.len =%d\n",
+		 precv_frame->rx_tail, precv_frame->rx_end,
+		 precv_frame->len));
 
-	skb->data = precv_frame->u.hdr.rx_data;
+	skb->data = precv_frame->rx_data;
 
-	skb_set_tail_pointer(skb, precv_frame->u.hdr.len);
+	skb_set_tail_pointer(skb, precv_frame->len);
 
-	skb->len = precv_frame->u.hdr.len;
+	skb->len = precv_frame->len;
 
 	RT_TRACE(_module_recv_osdep_c_, _drv_info_,
 		 ("skb->head =%p skb->data =%p skb->tail =%p skb->end =%p skb->len =%d\n",
@@ -166,7 +166,7 @@ int rtw_recv_indicatepkt(struct adapter *padapter,
 		struct sk_buff *pskb2 = NULL;
 		struct sta_info *psta = NULL;
 		struct sta_priv *pstapriv = &padapter->stapriv;
-		struct rx_pkt_attrib *pattrib = &precv_frame->u.hdr.attrib;
+		struct rx_pkt_attrib *pattrib = &precv_frame->attrib;
 		int bmcast = IS_MCAST(pattrib->dst);
 
 		if (memcmp(pattrib->dst, myid(&padapter->eeprompriv),
@@ -208,7 +208,7 @@ int rtw_recv_indicatepkt(struct adapter *padapter,
 _recv_indicatepkt_end:
 
 	/*  pointers to NULL before rtw_free_recvframe() */
-	precv_frame->u.hdr.pkt = NULL;
+	precv_frame->pkt = NULL;
 
 	rtw_free_recvframe(precv_frame, pfree_recv_queue);
 
-- 
1.8.4.5
