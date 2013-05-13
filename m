From: John Greene <jogreene@redhat.com>
Subject: [RHEL 6.5 PATCH 169/176] brcmsmac: fix u16 overflow warning
Date: Mon, 13 May 2013 11:47:11 -0400
Message-ID: <1368460038-21195-170-git-send-email-jogreene@redhat.com>
References: <1368460038-21195-1-git-send-email-jogreene@redhat.com>
Cc: John Greene <jogreene@redhat.com>,
	Brett Rudley <brudley@broadcom.com>,
	Arend van Spriel <arend@broadcom.com>,
	"Franky (Zhenhui) Lin" <frankyl@broadcom.com>,
	Hante Meuleman <meuleman@broadcom.com>,
	"John W. Linville" <linville@tuxdriver.com>,
	Pieter-Paul Giesberts <pieterpg@broadcom.com>,
	Seth Forshee <seth.forshee@canonical.com>,
	Hauke Mehrtens <hauke@hauke-m.de>,
	linux-wireless@vger.kernel.org, brcm80211-dev-list@broadcom.com,
	netdev@vger.kernel.org, Tim Gardner <tim.gardner@canonical.com>
To: rhkernel-list@redhat.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from cpe-075-189-159-031.nc.res.rr.com ([75.189.159.31]:44243 "EHLO
	jgpicker.rdu.redhat.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1754429Ab3EMQoU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 13 May 2013 12:44:20 -0400
In-Reply-To: <1368460038-21195-1-git-send-email-jogreene@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Bugzilla: 757944
Brew: <https://brewweb.devel.redhat.com/taskinfo?taskID=5738553>
Upstream Status: 708eb54f20334470ad92042547db0fef0cd60462
Tested: By me. Acceptable. See BZ for details

DOT11_MIN_BEACON_PERIOD and DOT11_MAX_BEACON_PERIOD are
superfluous. The only invalid beacon period is 0. Comparing
a 16 bit quantity to 0xffff also causes a compile warning:

drivers/net/wireless/brcm80211/brcmsmac/main.c:5560 brcms_c_set_beacon_period()
 warn: impossible condition '(period > 65535) => (0-65535 > 65535)'

Observed from smatch analysis.

Cc: Brett Rudley <brudley@broadcom.com>
Cc: Arend van Spriel <arend@broadcom.com>
Cc: "Franky (Zhenhui) Lin" <frankyl@broadcom.com>
Cc: Hante Meuleman <meuleman@broadcom.com>
Cc: "John W. Linville" <linville@tuxdriver.com>
Cc: Pieter-Paul Giesberts <pieterpg@broadcom.com>
Cc: Seth Forshee <seth.forshee@canonical.com>
Cc: Hauke Mehrtens <hauke@hauke-m.de>
Cc: linux-wireless@vger.kernel.org
Cc: brcm80211-dev-list@broadcom.com
Cc: netdev@vger.kernel.org
Signed-off-by: Tim Gardner <tim.gardner@canonical.com>
Acked-by: Arend van Spriel <arend@broadcom.com>
Signed-off-by: John W. Linville <linville@tuxdriver.com>
---
 drivers/net/wireless/brcm80211/brcmsmac/main.c | 5 +----
 1 file changed, 1 insertion(+), 4 deletions(-)

diff --git a/drivers/net/wireless/brcm80211/brcmsmac/main.c b/drivers/net/wireless/brcm80211/brcmsmac/main.c
index 5c50b79..c72fbab 100644
--- a/drivers/net/wireless/brcm80211/brcmsmac/main.c
+++ b/drivers/net/wireless/brcm80211/brcmsmac/main.c
@@ -101,8 +101,6 @@
 #define DOT11_RTS_LEN			16
 #define DOT11_CTS_LEN			10
 #define DOT11_BA_BITMAP_LEN		128
-#define DOT11_MIN_BEACON_PERIOD		1
-#define DOT11_MAX_BEACON_PERIOD		0xFFFF
 #define DOT11_MAXNUMFRAGS		16
 #define DOT11_MAX_FRAG_LEN		2346
 
@@ -5548,8 +5546,7 @@ int brcms_c_set_rateset(struct brcms_c_info *wlc, struct brcm_rateset *rs)
 
 int brcms_c_set_beacon_period(struct brcms_c_info *wlc, u16 period)
 {
-	if (period < DOT11_MIN_BEACON_PERIOD ||
-	    period > DOT11_MAX_BEACON_PERIOD)
+	if (period == 0)
 		return -EINVAL;
 
 	wlc->default_bss->beacon_period = period;
-- 
1.7.11.7
