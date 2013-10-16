From: Jimmy Perchet <jimmy.perchet@parrot.com>
Subject: [PATCH RFC 0/5] net:stmmac: fix jumbo frames handling and optimisation
Date: Wed, 16 Oct 2013 17:24:07 +0200
Message-ID: <1381937052-8999-1-git-send-email-jimmy.perchet@parrot.com>
Mime-Version: 1.0
Content-Type: text/plain
Cc: <netdev@vger.kernel.org>, Jimmy Perchet <jimmy.perchet@parrot.com>
To: <peppe.cavallaro@st.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from co202.xi-lite.net ([149.6.83.202]:60729 "EHLO co202.xi-lite.net"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1752060Ab3JPPjR (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 16 Oct 2013 11:39:17 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello,

I began using Synopsys IP few weeks ago and figured out that jumbo frames
are not well supported by stmmac driver.

This patch series addresses several issues which prevent them from working
properly :
*(1/5) Threshold dma mode is needed on rx path if jumbo frames are expected.

*(2/5) RX buffers are not allocated with the needed size because
priv->dma_buf_sz is updated too late (i.e. after stmmac_init_rx_buffers call)

*(3/5) On low speed link (10MBit/s), some TX descriptors can remain dirty
if the tx coalescence timer expires before they were treated. Re-arm timer
in this case.

*(4/5) There is several confusions regarding descriptor's max buffer size, 
typically the "-1" is often forgotten.
*(4/5) Jumbo frames' last descriptor is never "closed", resulting in truncated
frames transfer.
*(4/5) Frags could not be jumbo.
Regarding these last points, I didn't find simpler way than writing
new "prepare frame" functions for both ring and chain mode and update
xmit function accordingly.


The last patch is not related to jumbo frames but concern a possible
optimisation :
*(5/5) Tx descriptor's cleanup and preparation are serialized, which is not
necessary and decrease performance. In addition TX descriptor's cleanup is
performed on NET_-RX- softirq, this is confusing.
By taking care of "cur_tx" and "dirty_tx" it is possible to avoid serialization
and defer cleanup in workqueue.
On my smp embedded system, with 1Gbit/s link which is cpu bound, it increases
througput by about 90MBit/s (400MBit/s to 490MBit/s).


Best Regards,
Jimmy Perchet

Jimmy Perchet (5):
  net:stmmac: set threshold/store and forward mode according to mtu
    size.
  net:stmmac: fix rx buffer allocation.
  net:stmmac: ensure we reclaim all dirty descriptors.
  net:stmmac: fix jumbo frame handling.
  net:stmmac: asynchronous tx_clean

 drivers/net/ethernet/stmicro/stmmac/chain_mode.c  |  99 +++++-----
 drivers/net/ethernet/stmicro/stmmac/common.h      |   6 +
 drivers/net/ethernet/stmicro/stmmac/descs_com.h   |   8 +-
 drivers/net/ethernet/stmicro/stmmac/enh_desc.c    |   6 +
 drivers/net/ethernet/stmicro/stmmac/norm_desc.c   |   6 +
 drivers/net/ethernet/stmicro/stmmac/ring_mode.c   |  90 ++++-----
 drivers/net/ethernet/stmicro/stmmac/stmmac.h      |   6 +-
 drivers/net/ethernet/stmicro/stmmac/stmmac_main.c | 219 +++++++++++++---------
 8 files changed, 233 insertions(+), 207 deletions(-)

-- 
1.8.1.2
