From: Antonio Quartulli <antonio@meshcoding.com>
Subject: [RFC net] bridge: clean the nf_bridge status when forwarding the skb
Date: Thu, 26 Sep 2013 22:19:50 +0200
Message-ID: <1380226790-513-1-git-send-email-antonio@meshcoding.com>
Cc: "David S. Miller" <davem@davemloft.net>,
	bridge@lists.linux-foundation.org, netdev@vger.kernel.org,
	Antonio Quartulli <antonio@open-mesh.com>
To: Stephen Hemminger <stephen@networkplumber.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from s2.neomailbox.net ([178.209.62.154]:25981 "EHLO
	s2.neomailbox.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752951Ab3IZVBB (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 26 Sep 2013 17:01:01 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Antonio Quartulli <antonio@open-mesh.com>

Even if enslaving a bridge interface into another bridge is
forbidden, it is still possible to create a chain of
virtual interfaces including two distinct bridges.

In this case, the skb entering the second bridge could have
the nf_bridge field already set due to a previous operation
and consequently lead to a wrong processing of the packet
itself.

To prevent this behaviour release and set to NULL the
nf_bridge field of the skb when exiting the bridge interface.

Signed-off-by: Antonio Quartulli <antonio@open-mesh.com>
---

I am not sure if this is a wanted behaviour or a real BUG. I found this
"misbehaviour" while testing batman-adv with the following configuration:

- br0 (bridge interface) having bat0 and eth0 as slaves
- bat0 (which is a virtual interface provided by the batman-adv module and that
  works similarly to a bridge - to some extends) having br1 as slave
- br1 (second bridge interface) having eth1 as slave

Then follow these events:
- a broadcast packet arrives on eth0
- the skb enters br0 and skb->nf_bridge gets initialised and used
- the skb enters bat0 and the packet *gets encapsulated in the batman-adv packet
  which adds a batman-adv header and another Ethernet header*
- the skb enters br1 and gets ruined because nf_bridge_maybe_copy_header() (in
  br_dev_queue_push_xmit()) will try to restore an header that does not make
  sense anymore.

With this patch the nf_bridge gets de-initialised before exiting br0 and
therefore it is processed properly inside br1: nf_bridge_maybe_copy_header()
does not take place at all because nf_bridge is never initialised (the packet is
non-IP since it is a batman-adv packet)

To the developers of the bridge module I would like to ask:
1) is skb->nf_bridge allowed to be non NULL when entering br_dev_xmit() ? If so,
   when is this supposed to happen?

2) do you think this patch is logically correct but the nf_bridge release should
   be done in batman-adv since it is the one re-encapsulating the packet?


I hope I have made the problem clear.

Best regards,


 net/bridge/br_forward.c | 5 +++++
 1 file changed, 5 insertions(+)

diff --git a/net/bridge/br_forward.c b/net/bridge/br_forward.c
index 4b81b14..65864bc 100644
--- a/net/bridge/br_forward.c
+++ b/net/bridge/br_forward.c
@@ -49,6 +49,11 @@ int br_dev_queue_push_xmit(struct sk_buff *skb)
 	} else {
 		skb_push(skb, ETH_HLEN);
 		br_drop_fake_rtable(skb);
+
+		/* clean the NF bridge data */
+		nf_bridge_put(skb->nf_bridge);
+		skb->nf_bridge = NULL;
+
 		dev_queue_xmit(skb);
 	}
 
-- 
1.8.1.5
