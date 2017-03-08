From: Jakub Kicinski <jakub.kicinski@netronome.com>
Subject: [PATCH net-next 8/9] nfp: add metadata format bit
Date: Wed,  8 Mar 2017 08:57:07 -0800
Message-ID: <20170308165708.96087-9-jakub.kicinski@netronome.com>
References: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Cc: oss-drivers@netronome.com,
        Jakub Kicinski <jakub.kicinski@netronome.com>
To: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f176.google.com ([209.85.192.176]:34474 "EHLO
        mail-pf0-f176.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1753721AbdCHQ7E (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 8 Mar 2017 11:59:04 -0500
Received: by mail-pf0-f176.google.com with SMTP id v190so16983947pfb.1
        for <netdev@vger.kernel.org>; Wed, 08 Mar 2017 08:58:15 -0800 (PST)
In-Reply-To: <20170308165708.96087-1-jakub.kicinski@netronome.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

We only need FW version in the first cache line of adapter struct
because we need to know the metadata format.  To save space add a
metadata format bit.

Signed-off-by: Jakub Kicinski <jakub.kicinski@netronome.com>
---
 drivers/net/ethernet/netronome/nfp/nfp_net.h        | 2 ++
 drivers/net/ethernet/netronome/nfp/nfp_net_common.c | 4 +++-
 2 files changed, 5 insertions(+), 1 deletion(-)

diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net.h b/drivers/net/ethernet/netronome/nfp/nfp_net.h
index 4ad27570b6c4..34f8c439f42f 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net.h
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net.h
@@ -440,6 +440,7 @@ struct nfp_stat_pair {
  * @is_vf:              Is the driver attached to a VF?
  * @bpf_offload_skip_sw:  Offloaded BPF program will not be rerun by cls_bpf
  * @bpf_offload_xdp:	Offloaded BPF program is XDP
+ * @chained_metadata_format:  Firemware will use new metadata format
  * @ctrl:               Local copy of the control register/word.
  * @fl_bufsz:           Currently configured size of the freelist buffers
  * @rx_offset:		Offset in the RX buffers where packet data starts
@@ -507,6 +508,7 @@ struct nfp_net {
 	unsigned is_vf:1;
 	unsigned bpf_offload_skip_sw:1;
 	unsigned bpf_offload_xdp:1;
+	unsigned chained_metadata_format:1;
 
 	u32 ctrl;
 	u32 fl_bufsz;
diff --git a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
index 119775d4097e..2d964d030dbe 100644
--- a/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
+++ b/drivers/net/ethernet/netronome/nfp/nfp_net_common.c
@@ -1652,7 +1652,7 @@ static int nfp_net_rx(struct nfp_net_rx_ring *rx_ring, int budget)
 		skb_reserve(skb, data_off);
 		skb_put(skb, pkt_len);
 
-		if (nn->fw_ver.major <= 3) {
+		if (!nn->chained_metadata_format) {
 			nfp_net_set_hash_desc(nn->netdev, skb, rxd);
 		} else if (meta_len) {
 			void *end;
@@ -3196,6 +3196,8 @@ int nfp_net_netdev_init(struct net_device *netdev)
 	struct nfp_net *nn = netdev_priv(netdev);
 	int err;
 
+	nn->chained_metadata_format = nn->fw_ver.major > 3;
+
 	/* Get some of the read-only fields from the BAR */
 	nn->cap = nn_readl(nn, NFP_NET_CFG_CAP);
 	nn->max_mtu = nn_readl(nn, NFP_NET_CFG_MAX_MTU);
-- 
2.11.0
