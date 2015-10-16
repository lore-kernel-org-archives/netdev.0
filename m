From: Joe Stringer <joestringer@nicira.com>
Subject: [PATCHv2 net] openvswitch: Scrub skb between namespaces
Date: Fri, 16 Oct 2015 11:08:18 -0700
Message-ID: <1445018901-18839-1-git-send-email-joestringer@nicira.com>
Cc: tgraf@suug.ch, hannes@redhat.com, jesse@nicira.com
To: netdev@vger.kernel.org, pshelar@nicira.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-yk0-f177.google.com ([209.85.160.177]:34310 "EHLO
	mail-yk0-f177.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752308AbbJPSIc (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 16 Oct 2015 14:08:32 -0400
Received: by ykfy204 with SMTP id y204so92423475ykf.1
        for <netdev@vger.kernel.org>; Fri, 16 Oct 2015 11:08:32 -0700 (PDT)
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
v2: Add unlikely(), shift all within the netns check block.
---
 net/openvswitch/vport.c | 9 +++++++++
 1 file changed, 9 insertions(+)

diff --git a/net/openvswitch/vport.c b/net/openvswitch/vport.c
index fc5c0b9ccfe9..12a36ac21eda 100644
--- a/net/openvswitch/vport.c
+++ b/net/openvswitch/vport.c
@@ -444,6 +444,15 @@ int ovs_vport_receive(struct vport *vport, struct sk_buff *skb,
 
 	OVS_CB(skb)->input_vport = vport;
 	OVS_CB(skb)->mru = 0;
+	if (unlikely(dev_net(skb->dev) != ovs_dp_get_net(vport->dp))) {
+		u32 mark;
+
+		mark = skb->mark;
+		skb_scrub_packet(skb, true);
+		skb->mark = mark;
+		tun_info = NULL;
+	}
+
 	/* Extract flow from 'skb' into 'key'. */
 	error = ovs_flow_key_extract(tun_info, skb, &key);
 	if (unlikely(error)) {
-- 
2.1.4
