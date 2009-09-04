From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next PATCH 3/3] ixgbe: Add support for using FCoE DDP in 82599
	as FCoE targets
Date: Thu, 03 Sep 2009 17:56:31 -0700
Message-ID: <20090904005630.14869.67340.stgit@localhost.localdomain>
References: <20090904005549.14869.66878.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com,
	Yi Zou <yi.zou@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta05.westchester.pa.mail.comcast.net ([76.96.62.48]:44304
	"EHLO QMTA05.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754841AbZIDA4r (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 3 Sep 2009 20:56:47 -0400
In-Reply-To: <20090904005549.14869.66878.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Yi Zou <yi.zou@intel.com>

The FCoE DDP in 82599 can be used for both FCoE initiator as well as FCoE
target, depending on the indication of the exchange being the responder or
originator in the F_CTL (frame control) field in the encapsulated Fiber
Channel frame header (T10 Spec., FC-FS). For the initiator, OX_ID is used
for FCoE DDP, where for the target RX_ID is used for FCoE DDP.

Signed-off-by: Yi Zou <yi.zou@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_fcoe.c |    8 +++++++-
 1 files changed, 7 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_fcoe.c b/drivers/net/ixgbe/ixgbe_fcoe.c
index 0607cff..a3c9f99 100644
--- a/drivers/net/ixgbe/ixgbe_fcoe.c
+++ b/drivers/net/ixgbe/ixgbe_fcoe.c
@@ -292,6 +292,7 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 		   struct sk_buff *skb)
 {
 	u16 xid;
+	u32 fctl;
 	u32 sterr, fceofe, fcerr, fcstat;
 	int rc = -EINVAL;
 	struct ixgbe_fcoe *fcoe;
@@ -312,7 +313,12 @@ int ixgbe_fcoe_ddp(struct ixgbe_adapter *adapter,
 	skb_set_transport_header(skb, skb_network_offset(skb) +
 				 sizeof(struct fcoe_hdr));
 	fh = (struct fc_frame_header *)skb_transport_header(skb);
-	xid =  be16_to_cpu(fh->fh_ox_id);
+	fctl = ntoh24(fh->fh_f_ctl);
+	if (fctl & FC_FC_EX_CTX)
+		xid =  be16_to_cpu(fh->fh_ox_id);
+	else
+		xid =  be16_to_cpu(fh->fh_rx_id);
+
 	if (xid >= IXGBE_FCOE_DDP_MAX)
 		goto ddp_out;
 

