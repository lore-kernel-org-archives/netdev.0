From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 6/7] e1000e: workaround a Tx hang on 82577/82578
Date: Tue, 02 Jun 2009 14:29:37 -0700
Message-ID: <20090602212937.24614.36773.stgit@localhost.localdomain>
References: <20090602212800.24614.45798.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Bruce Allan <bruce.w.allan@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta08.westchester.pa.mail.comcast.net ([76.96.62.80]:35142
	"EHLO QMTA08.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751465AbZFBV3w (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 2 Jun 2009 17:29:52 -0400
In-Reply-To: <20090602212800.24614.45798.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Bruce Allan <bruce.w.allan@intel.com>

With bi-directional stress traffic, the receiver could hang causing the
hardware to stop and a "Detected Tx Unit Hang" message dumped to the system
logfile.  Temporarily workaround this issue by disabling Tx flow control by
default.  The issue is currently being investigated and a follow-on patch
will be provided to revert this when it is resolved.

Signed-off-by: Bruce Allan <bruce.w.allan@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/ich8lan.c |    9 +++++++--
 1 files changed, 7 insertions(+), 2 deletions(-)

diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index b69c819..9e23f50 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2348,8 +2348,13 @@ static s32 e1000_setup_link_ich8lan(struct e1000_hw *hw)
 	 * the default flow control setting, so we explicitly
 	 * set it to full.
 	 */
-	if (hw->fc.requested_mode == e1000_fc_default)
-		hw->fc.requested_mode = e1000_fc_full;
+	if (hw->fc.requested_mode == e1000_fc_default) {
+		/* Workaround h/w hang when Tx flow control enabled */
+		if (hw->mac.type == e1000_pchlan)
+			hw->fc.requested_mode = e1000_fc_rx_pause;
+		else
+			hw->fc.requested_mode = e1000_fc_full;
+	}
 
 	/*
 	 * Save off the requested flow control mode for use later.  Depending

