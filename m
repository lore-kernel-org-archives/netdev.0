From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCH net] openvswitch: Scrub skb between namespaces
Date: Wed, 14 Oct 2015 11:10:47 -0700
Message-ID: <1444846249-52053-2-git-send-email-joestringer@nicira.com>
References: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
Cc: tgraf@suug.ch, hannes@redhat.com, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f45.google.com ([209.85.220.45]:36810 "EHLO
	mail-pa0-f45.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751126AbbJNSK6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 14 Oct 2015 14:10:58 -0400
Received: by pabur7 with SMTP id ur7so11884054pab.3
        for <netdev@vger.kernel.org>; Wed, 14 Oct 2015 11:10:58 -0700 (PDT)
In-Reply-To: <1444846249-52053-1-git-send-email-joestringer@nicira.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

If OVS receives a packet from another namespace, then the packet should
be scrubbed. However, people have already begun to rely on the behaviour
that skb->mark is preserved across namespaces, so retain this one field.

This is mainly to address information leakage between namespaces when
using OVS internal ports, but by placing it in ovs_vport_receive() it is
more generally applicable, meaning it should not be overlooked if other
port types are allowed to be moved into namespaces in future.

Signed-off-by: Joe Stringer <joestringer@nicira.com>
---
I originally proposed this patch as part of the conntrack changes to OVS,
and there was some discussion on that thread, culminating here:
http://www.spinics.net/lists/netdev/msg338626.html

We also discussed this a bit in Seattle, however I didn't follow up
immediately so I don't exactly recall what the consensus was. Following
Jesse's direction in the above thread, I'm proposing that we preserve the
mark, but scrub the rest. Also fixed the use-after-free bug present in the
previous version.

I think this is relevant for 'net', because this is the first time that
the metadata_dst and nfct are exposed (albeit indirectly) through OVS so it
would be nice to get agreement on the expected behaviour.
---
 net/openvswitch/vport.c | 7 +++++++
 1 file changed, 7 insertions(+)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index fc5c0b9ccfe9..70f19ea99b92 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -440,10 +440,17 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 		      const struct ip_tunnel_info *tun_info)
 {
 	struct sw_flow_key key;
+	u32 mark = skb->mark;
 	int error;
 
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->mru = 0;
+	if (dev_net(skb->dev) != ovs_dp_get_net(vport->dp)) {
+		skb_scrub_packet(skb, true);
+		tun_info = NULL;
+	}
+	skb->mark = mark;
+
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
-- 
2.1.4
