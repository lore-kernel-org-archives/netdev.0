From: Felix Manlunas <felix.manlunas@cavium.com>
Subject: [PATCH net-next] vxlan: vxlan dev should inherit lowerdev's
 gso_max_size
Date: Wed, 29 Mar 2017 17:56:43 -0700
Message-ID: <20170330005643.GA1068@felix-thinkpad.cavium.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: netdev@vger.kernel.org, satananda.burla@cavium.com,
        stephen@networkplumber.org
To: davem@davemloft.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-sn1nam02on0060.outbound.protection.outlook.com ([104.47.36.60]:34878
        "EHLO NAM02-SN1-obe.outbound.protection.outlook.com"
        rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org with ESMTP
        id S1754209AbdC3Aut (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 29 Mar 2017 20:50:49 -0400
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

vxlan dev currently ignores lowerdev's gso_max_size, which adversely
affects TSO performance of liquidio if it's the lowerdev.  Egress TCP
packets' skb->len often exceed liquidio's advertised gso_max_size.  This
may happen on other NIC drivers.

Fix it by assigning lowerdev's gso_max_size to that of vxlan dev.  Might as
well do likewise for gso_max_segs.

Single flow TSO throughput of liquidio as lowerdev (using iperf3):

    Before the patch:    139 Mbps
    After the patch :   8.68 Gbps
    Percent increase:  6,144 %

Signed-off-by: Felix Manlunas <felix.manlunas@cavium.com>
Signed-off-by: Satanand Burla <satananda.burla@cavium.com>
---
 drivers/net/vxlan.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/drivers/net/vxlan.c b/drivers/net/vxlan.c
index 1e54fb5..714f74f 100644
--- a/drivers/net/vxlan.c
+++ b/drivers/net/vxlan.c
@@ -2926,6 +2926,11 @@ static int vxlan_dev_configure(struct net *src_net, struct net_device *dev,
 		return -EINVAL;
 	}
 
+	if (lowerdev) {
+		dev->gso_max_size = lowerdev->gso_max_size;
+		dev->gso_max_segs = lowerdev->gso_max_segs;
+	}
+
 	if (conf->mtu) {
 		int max_mtu = ETH_MAX_MTU;
 
