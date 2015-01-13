From: David L Stevens <david.stevens@oracle.com>
Subject: [PATCH net-next] sunvnet: fix rx packet length check to allow for
 TSO
Date: Tue, 13 Jan 2015 12:45:05 -0500
Message-ID: <54B559A1.9010303@oracle.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org,
	Sowmini Varadhan <sowmini.varadhan@oracle.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from userp1040.oracle.com ([156.151.31.81]:40337 "EHLO
	userp1040.oracle.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753068AbbAMRpM (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 Jan 2015 12:45:12 -0500
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch fixes the rx packet length check in the sunvnet driver to allow
for a TSO max packet length greater than the LDC channel negotiated MTU.
These are negotiated separately and there is no requirement that
port->tsolen be less than port->rmtu, but if it isn't, it'll drop packets
with rx length errors.

Signed-off-by: David L Stevens <david.stevens@oracle.com>
---
 drivers/net/ethernet/sun/sunvnet.c |    7 ++++++-
 1 files changed, 6 insertions(+), 1 deletions(-)

diff --git a/drivers/net/ethernet/sun/sunvnet.c b/drivers/net/ethernet/sun/sunvnet.c
index d2835bf..b5a1d3d 100644
--- a/drivers/net/ethernet/sun/sunvnet.c
+++ b/drivers/net/ethernet/sun/sunvnet.c
@@ -351,10 +351,15 @@ static int vnet_rx_one(struct vnet_port *port, struct vio_net_desc *desc)
 	unsigned int len = desc->size;
 	unsigned int copy_len;
 	struct sk_buff *skb;
+	int maxlen;
 	int err;
 
 	err = -EMSGSIZE;
-	if (unlikely(len < ETH_ZLEN || len > port->rmtu)) {
+	if (port->tso && port->tsolen > port->rmtu)
+		maxlen = port->tsolen;
+	else
+		maxlen = port->rmtu;
+	if (unlikely(len < ETH_ZLEN || len > maxlen)) {
 		dev->stats.rx_length_errors++;
 		goto out_dropped;
 	}
-- 
1.7.1
