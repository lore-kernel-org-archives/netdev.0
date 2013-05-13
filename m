From: John Greene <jogreene@redhat.com>
Subject: [RHEL 6.5 PATCH 170/176] brcmsmac: avoid 512 byte stack variable
Date: Mon, 13 May 2013 11:47:12 -0400
Message-ID: <1368460038-21195-171-git-send-email-jogreene@redhat.com>
References: <1368460038-21195-1-git-send-email-jogreene@redhat.com>
Cc: John Greene <jogreene@redhat.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, Tim Gardner <tim.gardner@canonical.com>
To: rhkernel-list@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-075-189-159-031.nc.res.rr.com ([75.189.159.31]:44243 "EHLO
	jgpicker.rdu.redhat.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754418Ab3EMQoT (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 12:44:19 -0400
In-Reply-To: <1368460038-21195-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bugzilla: 757944
Brew: <https://brewweb.devel.redhat.com/taskinfo?taskID=5738553>
Upstream Status: 0d61c9177cb9bf48dcec9c3d9205a309085d4318
Tested: By me. Acceptable. See BZ for details

Dynamically allocate the probe response template which
avoids potential stack corruption. Observed with smatch:

drivers/net/wireless/brcm80211/brcmsmac/main.c:7412 brcms_c_bss_update_probe_resp()
 warn: 'prb_resp' puts 512 bytes on stack

Cc: Brett Rudley <brudley@broadcom.com>
Cc: Arend van Spriel <arend@broadcom.com>
Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
Cc: Hante Meuleman <meuleman@broadcom.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Seth Forshee <seth.forshee@canonical.com>
Cc: Pieter-Paul Giesberts <pieterpg@broadcom.com>
Cc: Hauke Mehrtens <hauke@hauke-m.de>
Cc: linux-wireless@vger.kernel.org
Cc: brcm80211-dev-list@broadcom.com
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Acked-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c | 8 +++++++-
 1 file changed, 7 insertions(+), 1 deletion(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index c72fbab..8ec610e 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -7398,9 +7398,13 @@ brcms_c_bss_update_probe_resp(struct brcms_c_info *wlc,
 			      struct brcms_bss_cfg *cfg,
 			      bool suspend)
 {
-	u16 prb_resp[BCN_TMPL_LEN / 2];
+	u16 *prb_resp;
 	int len = BCN_TMPL_LEN;
 
+	prb_resp = kmalloc(BCN_TMPL_LEN, GFP_ATOMIC);
+	if (!prb_resp)
+		return;
+
 	/*
 	 * write the probe response to hardware, or save in
 	 * the config structure
@@ -7434,6 +7438,8 @@ brcms_c_bss_update_probe_resp(struct brcms_c_info *wlc,
 
 	if (suspend)
 		brcms_c_enable_mac(wlc);
+
+	kfree(prb_resp);
 }
 
 void brcms_c_update_probe_resp(struct brcms_c_info *wlc, bool suspend)
-- 
1.7.11.7
