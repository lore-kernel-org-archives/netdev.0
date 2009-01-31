From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-2.6 PATCH 2/3] igb: prevent skb_over panic w/ mtu smaller than 1K
Date: Fri, 30 Jan 2009 16:54:04 -0800
Message-ID: <20090131005404.1466.30069.stgit@lost.foo-projects.org>
References: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, jeff@garzik.org, gospo@redhat.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta10.westchester.pa.mail.comcast.net ([76.96.62.17]:57835
	"EHLO QMTA10.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1753285AbZAaAyZ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 30 Jan 2009 19:54:25 -0500
In-Reply-To: <20090131005340.1466.93281.stgit@lost.foo-projects.org>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

A panic has been observed with frame sizes smaller than 1K.  This has been
root caused to the hardware spanning larger frames across multiple buffers
and then reporting the original frame size in the first descriptor.  To
prevent this we can enable set the LPE bit which in turn will restrict
packet sizes to those set in the RLPML register.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/igb/igb_main.c |    8 ++++----
 1 files changed, 4 insertions(+), 4 deletions(-)

diff --git a/drivers/net/igb/igb_main.c b/drivers/net/igb/igb_main.c
index cc94412..a50db53 100644
--- a/drivers/net/igb/igb_main.c
+++ b/drivers/net/igb/igb_main.c
@@ -1834,11 +1834,11 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	rctl |= E1000_RCTL_SECRC;
 
 	/*
-	 * disable store bad packets, long packet enable, and clear size bits.
+	 * disable store bad packets and clear size bits.
 	 */
-	rctl &= ~(E1000_RCTL_SBP | E1000_RCTL_LPE | E1000_RCTL_SZ_256);
+	rctl &= ~(E1000_RCTL_SBP | E1000_RCTL_SZ_256);
 
-	if (adapter->netdev->mtu > ETH_DATA_LEN)
+	/* enable LPE when to prevent packets larger than max_frame_size */
 		rctl |= E1000_RCTL_LPE;
 
 	/* Setup buffer sizes */
@@ -1864,7 +1864,7 @@ static void igb_setup_rctl(struct igb_adapter *adapter)
 	 */
 	/* allocations using alloc_page take too long for regular MTU
 	 * so only enable packet split for jumbo frames */
-	if (rctl & E1000_RCTL_LPE) {
+	if (adapter->netdev->mtu > ETH_DATA_LEN) {
 		adapter->rx_ps_hdr_size = IGB_RXBUFFER_128;
 		srrctl |= adapter->rx_ps_hdr_size <<
 			 E1000_SRRCTL_BSIZEHDRSIZE_SHIFT;

