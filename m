From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 1/7] ixgbe: fix header len when unsplit packet
	overflows to data buffer
Date: Tue, 18 May 2010 19:00:03 -0700
Message-ID: <20100519020003.18654.94899.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Shannon Nelson <shannon.nelson@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta02.emeryville.ca.mail.comcast.net ([76.96.30.24]:42835 "EHLO
	qmta02.emeryville.ca.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751045Ab0ESCAE (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 18 May 2010 22:00:04 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shannon Nelson <shannon.nelson@intel.com>

When in packet split mode, packet type is not recognized, and the packet is
larger than the header size, the 82599 overflows the packet into the data
area, but doesn't set the HDR_LEN field.  We can safely assume the length
is the current header size.  This fixes an obscure corner case that can be
triggered by non-ip packet headers or (more likely) by disabling the L2
packet recognition.

Signed-off-by: Shannon Nelson <shannon.nelson@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |    5 +++--
 1 files changed, 3 insertions(+), 2 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 926ad8c..a9e091c 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -1201,9 +1201,10 @@ static bool ixgbe_clean_rx_irq(struct ixgbe_q_vector *q_vector,
 			hdr_info = le16_to_cpu(ixgbe_get_hdr_info(rx_desc));
 			len = (hdr_info & IXGBE_RXDADV_HDRBUFLEN_MASK) >>
 			       IXGBE_RXDADV_HDRBUFLEN_SHIFT;
-			if (len > IXGBE_RX_HDR_SIZE)
-				len = IXGBE_RX_HDR_SIZE;
 			upper_len = le16_to_cpu(rx_desc->wb.upper.length);
+			if ((len > IXGBE_RX_HDR_SIZE) ||
+			    (upper_len && !(hdr_info & IXGBE_RXDADV_SPH)))
+				len = IXGBE_RX_HDR_SIZE;
 		} else {
 			len = le16_to_cpu(rx_desc->wb.upper.length);
 		}

