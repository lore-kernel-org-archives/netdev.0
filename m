From: Shmulik Ladkani <shmulik.ladkani@ravellosystems.com>
Subject: [PATCH v2 net] net: skbuff: skb_vlan_push: Fix wrong unwinding of skb->data after __vlan_insert_tag call
Date: Wed, 28 Sep 2016 12:08:41 +0300
Message-ID: <1475053721-27676-1-git-send-email-shmulik.ladkani@gmail.com>
Cc: Daniel Borkmann <daniel@iogearbox.net>, netdev@vger.kernel.org,
        Shmulik Ladkani <shmulik.ladkani@gmail.com>,
        Jiri Pirko <jiri@mellanox.com>
To: "David S. Miller" <davem@davemloft.net>,
        Pravin Shelar <pshelar@ovn.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-wm0-f54.google.com ([74.125.82.54]:35053 "EHLO
        mail-wm0-f54.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1752626AbcI1JIq (ORCPT
        <rfc822;netdev@vger.kernel.org>); Wed, 28 Sep 2016 05:08:46 -0400
Received: by mail-wm0-f54.google.com with SMTP id l132so223828383wmf.0
        for <netdev@vger.kernel.org>; Wed, 28 Sep 2016 02:08:45 -0700 (PDT)
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Shmulik Ladkani <shmulik.ladkani@gmail.com>

In case 'skb_vlan_push' is called on an skb with a hw-accel vlan tag
present, the existing hw-accel tag is inserted into the payload, and
the new given tag is placed as new hw-accel tag.

In order to insert the existing hw-accel tag, 'skb_vlan_push' adjusts
the 'data' pointer at the mac_header (if needed), invokes __vlan_insert_tag,
and finally re-adjusts 'data' back to its original position (according
to the remembered "adjustment offset").

However, successful '__vlan_insert_tag' pushes 4 more bytes at start of
frame.
Alas, the remembered "adjustment offset" is NOT fixed to account for
these additional 4 bytes, so the subsequent '__skb_pull(skb, offset)'
fails to unwind 'data' back to its original location.

Since 'skb->mac_len' IS fixed to account for the additional 4 bytes
(incremented to a total of 18 bytes), any access to
'skb->data - skb->mac_len' points to bytes PRIOR start of frame.

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

Fix, by properly accouting the additionally pushed 4 bytes (in the case
where an adjustment to point at mac_header was done).

Fixes: 93515d53b1 ("net: move vlan pop/push functions into common code")
Signed-off-by: Shmulik Ladkani <shmulik.ladkani@gmail.com>
Cc: Pravin Shelar <pshelar@ovn.org>
Cc: Jiri Pirko <jiri@mellanox.com>
---
 v2: Instead of reducing mac_len by 4 bytes, which was found incorrect,
     fix the problem of wrong unwinding of 'skb->data'

 David, if patch ok, suggest this goes to -stable
   
 net/core/skbuff.c | 2 ++
 1 file changed, 2 insertions(+)

diff --git a/net/core/skbuff.c b/net/core/skbuff.c
index d36c754..3926b79 100644
--- a/net/core/skbuff.c
+++ b/net/core/skbuff.c
@@ -4608,6 +4608,8 @@ int skb_vlan_push(struct sk_buff *skb, __be16 vlan_proto, u16 vlan_tci)
 
 		skb->protocol = skb->vlan_proto;
 		skb->mac_len += VLAN_HLEN;
+		if (offset)
+			offset += VLAN_HLEN;
 
 		skb_postpush_rcsum(skb, skb->data + (2 * ETH_ALEN), VLAN_HLEN);
 		__skb_pull(skb, offset);
-- 
1.9.1
