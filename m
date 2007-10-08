From: Greg KH <gregkh@suse.de>
Subject: [patch 04/12] sky2: fix transmit state on resume
Date: Mon, 8 Oct 2007 11:06:15 -0700
Message-ID: <20071008180615.GE7627@kroah.com>
References: <20071008180406.052382073@mini.kroah.org>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Justin Forbes <jmforbes@linuxtx.org>,
	Zwane Mwaikambo <zwane@arm.linux.org.uk>,
	Theodore Ts'o <tytso@mit.edu>,
	Randy Dunlap <rdunlap@xenotime.net>,
	Dave Jones <davej@redhat.com>,
	Chuck Wolber <chuckw@quantumlinux.com>,
	Chris Wedgwood <reviews@ml.cw.f00f.org>,
	Michael Krufky <mkrufky@linuxtv.org>,
	Chuck Ebbert <cebbert@redhat.com>,
	Domenico Andreoli <cavokz@gmail.com>,
	torvalds@linux-foundation.org, akpm@linux-foundation.org,
	alan@lxorguk.ukuu.org.uk, netdev@vger.kernel.org,
	Stephen Hemminger <shemminger@linux-foundation.org>
To: linux-kernel@vger.kernel.org, stable@kernel.org,
	Krzysztof Oledzki <olel@ans.pl>, Greg KH <greg@kroah.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from pentafluge.infradead.org ([213.146.154.40]:46081 "EHLO
	pentafluge.infradead.org" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751375AbXJHSOO (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 8 Oct 2007 14:14:14 -0400
Content-Disposition: inline; filename="sky2-tx-sum-resume.patch"
In-Reply-To: <20071008180551.GA7627@kroah.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Stephen Hemminger <shemminger@linux-foundation.org>

Already upstream.

After resume, driver has reset the chip so the current state
of transmit checksum offload state machine and DMA state machine
will be undefined.

The fix is to set the state so that first Tx will set MSS and offset
values.

Signed-off-by: Stephen Hemminger <shemminger@linux-foundation.org>
Signed-off-by: Greg Kroah-Hartman <gregkh@suse.de>

---
 drivers/net/sky2.c |   17 ++++++++++++++++-
 1 file changed, 16 insertions(+), 1 deletion(-)

--- a/drivers/net/sky2.c
+++ b/drivers/net/sky2.c
@@ -831,6 +831,20 @@ static inline struct sky2_tx_le *get_tx_
 	return le;
 }
 
+static void tx_init(struct sky2_port *sky2)
+{
+	struct sky2_tx_le *le;
+
+	sky2->tx_prod = sky2->tx_cons = 0;
+	sky2->tx_tcpsum = 0;
+	sky2->tx_last_mss = 0;
+
+	le = get_tx_le(sky2);
+	le->addr = 0;
+	le->opcode = OP_ADDR64 | HW_OWNER;
+	sky2->tx_addr64 = 0;
+}
+
 static inline struct tx_ring_info *tx_le_re(struct sky2_port *sky2,
 					    struct sky2_tx_le *le)
 {
@@ -1244,7 +1258,8 @@ static int sky2_up(struct net_device *de
 				GFP_KERNEL);
 	if (!sky2->tx_ring)
 		goto err_out;
-	sky2->tx_prod = sky2->tx_cons = 0;
+
+	tx_init(sky2);
 
 	sky2->rx_le = pci_alloc_consistent(hw->pdev, RX_LE_BYTES,
 					   &sky2->rx_le_map);

-- 
