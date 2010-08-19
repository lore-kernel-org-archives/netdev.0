From: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
Subject: [net-next-2.6 PATCH 10/20] ixgbe: combine accesses to FCTRL register
	into ixgbe_set_rx_mode
Date: Thu, 19 Aug 2010 16:36:49 -0700
Message-ID: <20100819233647.10335.20152.stgit@localhost.localdomain>
References: <20100819233052.10335.13176.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, gospo@redhat.com, bphilips@novell.com,
	Alexander Duyck <alexander.h.duyck@intel.com>,
	Jeff Kirsher <jeffrey.t.kirsher@intel.com>
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from qmta11.westchester.pa.mail.comcast.net ([76.96.59.211]:60179
	"EHLO QMTA11.westchester.pa.mail.comcast.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1750877Ab0HSXhU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 19 Aug 2010 19:37:20 -0400
In-Reply-To: <20100819233052.10335.13176.stgit@localhost.localdomain>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Alexander Duyck <alexander.h.duyck@intel.com>

We are accessing the FCTRL register in multiple spots in the init path and
we can simplify things by combining the configuration all into
ixgbe_set_rx_mode.

Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
Signed-off-by: Jeff Kirsher <jeffrey.t.kirsher@intel.com>
---

 drivers/net/ixgbe/ixgbe_main.c |   13 ++++++-------
 1 files changed, 6 insertions(+), 7 deletions(-)

diff --git a/drivers/net/ixgbe/ixgbe_main.c b/drivers/net/ixgbe/ixgbe_main.c
index 88e6936..b755364 100644
--- a/drivers/net/ixgbe/ixgbe_main.c
+++ b/drivers/net/ixgbe/ixgbe_main.c
@@ -2709,7 +2709,7 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 	int max_frame = netdev->mtu + ETH_HLEN + ETH_FCS_LEN;
 	int i;
 	u32 rxctrl;
-	u32 fctrl, hlreg0;
+	u32 hlreg0;
 	u32 rdrxctl;
 	int rx_buf_len;
 
@@ -2731,12 +2731,6 @@ static void ixgbe_configure_rx(struct ixgbe_adapter *adapter)
 			rx_buf_len = ALIGN(max_frame, 1024);
 	}
 
-	fctrl = IXGBE_READ_REG(&adapter->hw, IXGBE_FCTRL);
-	fctrl |= IXGBE_FCTRL_BAM;
-	fctrl |= IXGBE_FCTRL_DPF; /* discard pause frames when FC enabled */
-	fctrl |= IXGBE_FCTRL_PMCF;
-	IXGBE_WRITE_REG(&adapter->hw, IXGBE_FCTRL, fctrl);
-
 	hlreg0 = IXGBE_READ_REG(hw, IXGBE_HLREG0);
 	if (adapter->netdev->mtu <= ETH_DATA_LEN)
 		hlreg0 &= ~IXGBE_HLREG0_JUMBOEN;
@@ -3055,6 +3049,11 @@ void ixgbe_set_rx_mode(struct net_device *netdev)
 
 	fctrl = IXGBE_READ_REG(hw, IXGBE_FCTRL);
 
+	/* set all bits that we expect to always be set */
+	fctrl |= IXGBE_FCTRL_BAM;
+	fctrl |= IXGBE_FCTRL_DPF; /* discard pause frames when FC enabled */
+	fctrl |= IXGBE_FCTRL_PMCF;
+
 	/* clear the bits we are changing the status of */
 	fctrl &= ~(IXGBE_FCTRL_UPE | IXGBE_FCTRL_MPE);
 

