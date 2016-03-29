From: Alexander Duyck <aduyck@mirantis.com>
Subject: [net PATCH v2] gro: Allow tunnel stacking in the case of FOU/GUE
Date: Tue, 29 Mar 2016 14:55:22 -0700
Message-ID: <20160329215226.12478.3696.stgit@localhost.localdomain>
Mime-Version: 1.0
Content-Type: text/plain; charset="utf-8"
Content-Transfer-Encoding: 7bit
To: jesse@kernel.org, netdev@vger.kernel.org, davem@davemloft.net,
	alexander.duyck@gmail.com, tom@herbertland.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f54.google.com ([209.85.220.54]:33199 "EHLO
	mail-pa0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1754171AbcC2VzY (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 29 Mar 2016 17:55:24 -0400
Received: by mail-pa0-f54.google.com with SMTP id zm5so23963691pac.0
        for <netdev@vger.kernel.org>; Tue, 29 Mar 2016 14:55:24 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

This patch should fix the issues seen with a recent fix to prevent
tunnel-in-tunnel frames from being generated with GRO.  The fix itself is
correct for now as long as we do not add any devices that support
NETIF_F_GSO_GRE_CSUM.  When such a device is added it could have the
potential to mess things up due to the fact that the outer transport header
points to the outer UDP header and not the GRE header as would be expected.

Fixes: fac8e0f579695 ("tunnels: Don't apply GRO to multiple layers of encapsulation.")
Signed-off-by: Alexander Duyck <aduyck@mirantis.com>
---

v2: Dropped switch statements per suggestion of Tom Herbert.

 net/ipv4/fou.c |   16 ++++++++++++++++
 1 file changed, 16 insertions(+)

diff --git a/net/ipv4/fou.c b/net/ipv4/fou.c
index a0586b4a197d..5a94aea280d3 100644
--- a/net/ipv4/fou.c
+++ b/net/ipv4/fou.c
@@ -195,6 +195,14 @@ static struct sk_buff **fou_gro_receive(struct sk_buff **head,
 	u8 proto = NAPI_GRO_CB(skb)->proto;
 	const struct net_offload **offloads;
 
+	/* We can clear the encap_mark for FOU as we are essentially doing
+	 * one of two possible things.  We are either adding an L4 tunnel
+	 * header to the outer L3 tunnel header, or we are are simply
+	 * treating the GRE tunnel header as though it is a UDP protocol
+	 * specific header such as VXLAN or GENEVE.
+	 */
+	NAPI_GRO_CB(skb)->encap_mark = 0;
+
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[proto]);
@@ -352,6 +360,14 @@ static struct sk_buff **gue_gro_receive(struct sk_buff **head,
 		}
 	}
 
+	/* We can clear the encap_mark for GUE as we are essentially doing
+	 * one of two possible things.  We are either adding an L4 tunnel
+	 * header to the outer L3 tunnel header, or we are are simply
+	 * treating the GRE tunnel header as though it is a UDP protocol
+	 * specific header such as VXLAN or GENEVE.
+	 */
+	NAPI_GRO_CB(skb)->encap_mark = 0;
+
 	rcu_read_lock();
 	offloads = NAPI_GRO_CB(skb)->is_ipv6 ? inet6_offloads : inet_offloads;
 	ops = rcu_dereference(offloads[guehdr->proto_ctype]);
