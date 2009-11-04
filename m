From: Inaky Perez-Gonzalez <inaky@linux.intel.com>
Subject: [PATCH 2.6.33/4 04/13] wimax: allow WIMAX_RF_QUERY calls when state is still uninitialized
Date: Wed,  4 Nov 2009 13:39:59 -0800
Message-ID: <81d3f905389e22bb9a5176b9309c3f451c260e1a.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
To: netdev@vger.kernel.org, wimax@linuxwimax.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga12.intel.com ([143.182.124.36]:45636 "EHLO
	azsmga102.ch.intel.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S932764AbZKDVmM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 4 Nov 2009 16:42:12 -0500
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
In-Reply-To: <cover.1257370737.git.inaky@linux.intel.com>
References: <cover.1257370737.git.inaky@linux.intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Until now, calls to wimax_rfkill() will be blocked until the device is
at least past the WIMAX_ST_UNINITIALIZED state, return -ENOMEDIUM when
the device is in the WIMAX_ST_DOWN state.

In parallel, wimax-tools would issue a wimax_rfkill(WIMAX_RF_QUERY)
call right after opening a handle with wimaxll_open() as means to
verify if the interface is really a WiMAX interface [newer kernel
version will have a call specifically for this].

The combination of these two facts is that in some cases, before the
driver has finalized initializing its device's firmware, a
wimaxll_open() call would fail, when it should not.

Thus, change the wimax_rfkill() code to allow queries when the device
is in WIMAX_ST_UNINITIALIZED state.

Signed-off-by: Inaky Perez-Gonzalez <inaky@linux.intel.com>
---
 net/wimax/op-rfkill.c |    9 ++++++++-
 1 files changed, 8 insertions(+), 1 deletions(-)

diff --git a/net/wimax/op-rfkill.c b/net/wimax/op-rfkill.c
index 40e1210..94d339c 100644
--- a/net/wimax/op-rfkill.c
+++ b/net/wimax/op-rfkill.c
@@ -305,8 +305,15 @@ int wimax_rfkill(struct wimax_dev *wimax_dev, enum wimax_rf_state state)
 	d_fnstart(3, dev, "(wimax_dev %p state %u)\n", wimax_dev, state);
 	mutex_lock(&wimax_dev->mutex);
 	result = wimax_dev_is_ready(wimax_dev);
-	if (result < 0)
+	if (result < 0) {
+		/* While initializing, < 1.4.3 wimax-tools versions use
+		 * this call to check if the device is a valid WiMAX
+		 * device; so we allow it to proceed always,
+		 * considering the radios are all off. */
+		if (result == -ENOMEDIUM && state == WIMAX_RF_QUERY)
+			result = WIMAX_RF_OFF << 1 | WIMAX_RF_OFF;
 		goto error_not_ready;
+	}
 	switch (state) {
 	case WIMAX_RF_ON:
 	case WIMAX_RF_OFF:
-- 
1.6.2.5

