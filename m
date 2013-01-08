From: Daniel Borkmann <dborkman@redhat.com>
Subject: [PATCH net 1/2] net: dev_queue_xmit_nit: fix skb->vlan_tci field value
Date: Tue,  8 Jan 2013 19:51:32 +0100
Message-ID: <1357671093-9605-2-git-send-email-dborkman@redhat.com>
References: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
Cc: netdev@vger.kernel.org, Daniel Borkmann <dborkman@redhat.com>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Ani Sinha <ani@aristanetworks.com>,
	Jiri Pirko <jpirko@redhat.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39755 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756955Ab3AHSvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Jan 2013 13:51:48 -0500
In-Reply-To: <1357671093-9605-1-git-send-email-dborkman@redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

VLAN packets that are locally injected through taps will loose their
skb->vlan_tci value when they pass dev_hard_start_xmit and get looped
back to a packet sniffer via dev_queue_xmit_nit. Besides others, this
meta data is used in Linux socket filtering for VLANs. Tested with a
VLAN ancillary ops filter.

Patch is based on a previous version by Jiri Pirko.

Cc: Eric Dumazet <eric.dumazet@gmail.com>
Cc: Ani Sinha <ani@aristanetworks.com>
Cc: Jiri Pirko <jpirko@redhat.com>
Reported-by: Paul Pearce <pearce@cs.berkeley.edu>
Signed-off-by: Daniel Borkmann <dborkman@redhat.com>
---
 net/core/dev.c | 13 +++++++++++++
 1 file changed, 13 insertions(+)

diff --git a/net/core/dev.c b/net/core/dev.c
index 515473e..723dcd0 100644
--- a/net/core/dev.c
+++ b/net/core/dev.c
@@ -1775,6 +1775,19 @@ static void dev_queue_xmit_nit(struct sk_buff *skb, struct net_device *dev)
 	struct packet_type *ptype;
 	struct sk_buff *skb2 = NULL;
 	struct packet_type *pt_prev = NULL;
+	struct ethhdr *ehdr;
+
+	/* Network taps could make use of skb->vlan_tci, which got wiped
+	 * out. Hence, we need to reset it correctly.
+	 */
+	skb_reset_mac_header(skb);
+	ehdr = eth_hdr(skb);
+
+	if (ehdr->h_proto == __constant_htons(ETH_P_8021Q)) {
+		skb2 = vlan_untag(skb);
+		if (likely(skb2))
+			skb = skb2;
+	}
 
 	rcu_read_lock();
 	list_for_each_entry_rcu(ptype, &ptype_all, list) {
-- 
1.7.11.7
