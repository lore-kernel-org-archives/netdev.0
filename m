From: Egil Hjelmeland <privat@egil-hjelmeland.no>
Subject: [PATCH net-next 3/3] net: dsa: lan9303: lan9303_rcv set skb->offload_fwd_mark
Date: Tue, 31 Oct 2017 15:48:02 +0100
Message-ID: <20171031144802.12686-4-privat@egil-hjelmeland.no>
References: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Cc: Egil Hjelmeland <privat@egil-hjelmeland.no>
To: andrew@lunn.ch, vivien.didelot@savoirfairelinux.com,
        f.fainelli@gmail.com, netdev@vger.kernel.org,
        linux-kernel@vger.kernel.org
Return-path: <linux-kernel-owner@vger.kernel.org>
In-Reply-To: <20171031144802.12686-1-privat@egil-hjelmeland.no>
Sender: linux-kernel-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

The chip flood broadcast and unknown multicast frames.
On receive set skb->offload_fwd_mark to prevent the SW from flooding to the
same ports.

One exception: Because the ALR is set up to forward STP BPDUs only to CPU,
the SW bridge should flood STP BPDUs if local STP is not enabled.
This is archived by not setting skb->offload_fwd_mark on STP BPDUs.

Signed-off-by: Egil Hjelmeland <privat@egil-hjelmeland.no>
---
 net/dsa/tag_lan9303.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/dsa/tag_lan9303.c b/net/dsa/tag_lan9303.c
index 18f45cd9f625..e526c8967b98 100644
--- a/net/dsa/tag_lan9303.c
+++ b/net/dsa/tag_lan9303.c
@@ -126,6 +126,8 @@ static struct sk_buff *lan9303_rcv(struct sk_buff *skb, struct net_device *dev,
 	skb_pull_rcsum(skb, 2 + 2);
 	memmove(skb->data - ETH_HLEN, skb->data - (ETH_HLEN + LAN9303_TAG_LEN),
 		2 * ETH_ALEN);
+	skb->offload_fwd_mark = !ether_addr_equal(skb->data - ETH_HLEN,
+						  eth_stp_addr);
 
 	return skb;
 }
-- 
2.11.0
