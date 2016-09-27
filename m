From: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Subject: [PATCH net] net: skbuff: Fix incorrect skb->mac_len adjustment in skb_vlan_push()
Date: Tue, 27 Sep 2016 20:31:45 +0300
Message-ID: <1474997505-5059-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Jiri Pirko <jiri@mellanox.com>,
        Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>
To: "David S . Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f68.google.com ([74.125.82.68]:34069 "EHLO
        mail-wm0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1751064AbcI0RcQ (ORCPT
        <rfc822;netdev@vger.kernel.org>); Tue, 27 Sep 2016 13:32:16 -0400
Received: by mail-wm0-f68.google.com with SMTP id l132so2197558wmf.1
        for <netdev@vger.kernel.org>; Tue, 27 Sep 2016 10:32:15 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

In case 'skb_vlan_push' is called on an skb with a hw-accel vlan tag
already present, the existing hw-accel tag is inserted into payload, and
the new given tag is placed as new hw-accel tag.

After the insertion:
 - 'mac_header' is adjusted to point to the new start of the vlan_ethhdr
 - 'data' is adjusted to point to the vlan_hdr portion
   (since packet's payload is the inner 802.1q)

However, 'mac_len' is incorrectly incremented with additional VLAN_HLEN
bytes, resulting in a total value of 18 bytes.

Meaning, when issuing 'skb_push(skb, skb->mac_len)' the data points
to random content, 4 bytes PRIOR the ethhdr location.

This is problematic, as many constructs in the stack are issuing
'skb_push(skb, skb->mac_len)' prior xmit to a device (e.g tcf_mirred,
tcf_bpf, nf_dup_netdev_egress), resulting in bogus frames being
xmitted (having random 4 bytes at start of frame).

For example:

 # ip l add dev d0 type dummy
 # tc filter add dev eth0 parent ffff: pref 1 basic \
     action vlan push protocol 802.1ad id 5 pipe \
     action mirred egress redirect dev d0

Any 802.1q (hw-accel) tagged frames arriving on eth0 are xmitted as
bogus frames on d0; whereas the expected behavior is having QinQ frames.

Fix, removing the unnecessary VLAN_HLEN adjustment of mac_len.

Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Pravin Shelar <pshelar@ovn.org>
Cc: Jiri Pirko <jiri@mellanox.com>
---

 - David, if patch ok, suggest this goes to -stable

 - Pravin, original push_vlan() code in openvswitch/actions.c prior Jiri
   has moved it into skbuff.c had the following comment:
        /* Update mac_len for subsequent MPLS actions */
        skb->mac_len += VLAN_HLEN;
   Can you please acknowlegde OvS code is also ok with suggested change?

 net/core/skbuff.c | 1 -
 1 file changed, 1 deletion(-)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d36c754895..0cf961868b 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4607,7 +4607,6 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
 		}
 
 		skb->protocol = skb->vlan_proto;
-		skb->mac_len += VLAN_HLEN;
 
 		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
 		__skb_pull(skb, offset);
-- 
2.7.4
