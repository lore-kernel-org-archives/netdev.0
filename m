From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [PATCH] e1000e: fix packet corruption and tx hang during NFSv2
Date: Fri, 05 Mar 2010 04:21:44 -0800
Message-ID: <20100305122131.8250.21132.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, nhorman@tuxdriver.com,
	Jesse Brandeburg <jesse.brandeburg@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:34155 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751266Ab0CEMWG (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 5 Mar 2010 07:22:06 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Jesse Brandeburg <jesse.brandeburg@intel.com>

when receiving a particular type of NFS v2 UDP traffic, the hardware could
DMA some bad data and then hang, possibly corrupting memory.

Disable the NFS parsing in this hardware, verified to fix the bug.

Originally reported and reproduced by RedHat's Neil Horman
CC: nhorman@tuxdriver.com
Signed-off-by: Jesse Brandeburg <jesse.brandeburg@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/e1000e/defines.h |    2 ++
 drivers/net/e1000e/ich8lan.c |   10 ++++++++++
 2 files changed, 12 insertions(+), 0 deletions(-)

diff --git a/drivers/net/e1000e/defines.h b/drivers/net/e1000e/defines.h
index db05ec3..e301e26 100644
--- a/drivers/net/e1000e/defines.h
+++ b/drivers/net/e1000e/defines.h
@@ -320,6 +320,8 @@
 #define E1000_RXCSUM_IPPCSE    0x00001000   /* IP payload checksum enable */
 
 /* Header split receive */
+#define E1000_RFCTL_NFSW_DIS            0x00000040
+#define E1000_RFCTL_NFSR_DIS            0x00000080
 #define E1000_RFCTL_ACK_DIS             0x00001000
 #define E1000_RFCTL_EXTEN               0x00008000
 #define E1000_RFCTL_IPV6_EX_DIS         0x00010000
diff --git a/drivers/net/e1000e/ich8lan.c b/drivers/net/e1000e/ich8lan.c
index 54d03a0..8b5e157 100644
--- a/drivers/net/e1000e/ich8lan.c
+++ b/drivers/net/e1000e/ich8lan.c
@@ -2740,6 +2740,16 @@ static void e1000_initialize_hw_bits_ich8lan(struct e1000_hw *hw)
 		reg &= ~(1 << 31);
 		ew32(STATUS, reg);
 	}
+
+	/*
+	 * work-around descriptor data corruption issue during nfs v2 udp
+	 * traffic, just disable the nfs filtering capability
+	 */
+	reg = er32(RFCTL);
+	reg |= (E1000_RFCTL_NFSW_DIS | E1000_RFCTL_NFSR_DIS);
+	ew32(RFCTL, reg);
+
+	return;
 }
 
 /**

