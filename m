From: Eric Garver <e@erig.me>
Subject: Re: [PATCH net-next v2 1/3] openvswitch: normalize vlan rx path
Date: Wed, 5 Oct 2016 15:21:32 -0400
Message-ID: <20161005192132.GR25403@egarver>
References: <cover.1475672568.git.jbenc@redhat.com>
 <c7f44c08104958c86c68d98f1e093d754b0ca61b.1475672569.git.jbenc@redhat.com>
 <CAHsH6Gvha_Saq8SVaLhsXzNggAOwbdu6n5xLQD7HFhYweJMsmw@mail.gmail.com>
 <20161005192319.713d92e1@griffin>
 <CAHsH6GvO=F38jXo18=3n1+w+sojRtRcLgbdE9PrGbGyB4vmoEA@mail.gmail.com>
 <20161005184426.GQ25403@egarver>
 <20161005210709.79732b27@griffin>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Eyal Birger <eyal.birger@gmail.com>,
        "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
        pravin shelar <pshelar@ovn.org>
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:39438 "EHLO mx1.redhat.com"
        rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
        id S1753340AbcJETVe (ORCPT <rfc822;netdev@vger.kernel.org>);
        Wed, 5 Oct 2016 15:21:34 -0400
Content-Disposition: inline
In-Reply-To: <20161005210709.79732b27@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Oct 05, 2016 at 09:07:09PM +0200, Jiri Benc wrote:
> On Wed, 5 Oct 2016 14:44:26 -0400, Eric Garver wrote:
> > On Wed, Oct 05, 2016 at 08:31:52PM +0300, Eyal Birger wrote:
> > > Just seemed less future safe to keep a pointer to an old packet lying around.
> > 
> > I agree. Alternatively refresh the eth pointer.
> 
> Sorry guys, that just doesn't make sense. Everyone should know that
> reloading of skb pointer means the former pointers to its data may
> become invalid. Please point me to any place in the kernel where we
> reload the data pointer "just because" even when not used.
> 

How about this incremental change?


diff --git a/net/openvswitch/datapath.c b/net/openvswitch/datapath.c
index 7ef02752d4ba..0dd36f353c53 100644
--- a/net/openvswitch/datapath.c
+++ b/net/openvswitch/datapath.c
@@ -562,7 +562,6 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	struct sw_flow *flow;
 	struct sw_flow_actions *sf_acts;
 	struct datapath *dp;
-	struct ethhdr *eth;
 	struct vport *input_vport;
 	u16 mru = 0;
 	int len;
@@ -584,14 +583,12 @@ static int ovs_packet_cmd_execute(struct sk_buff *skb, struct genl_info *info)
 	nla_memcpy(__skb_put(packet, len), a[OVS_PACKET_ATTR_PACKET], len);
 
 	skb_reset_mac_header(packet);
-	eth = eth_hdr(packet);
 
 	/* Normally, setting the skb 'protocol' field would be handled by a
 	 * call to eth_type_trans(), but it assumes there's a sending
 	 * device, which we may not have. */
-	if (eth_proto_is_802_3(eth->h_proto))
-		packet->protocol = eth->h_proto;
-	else
+	packet->protocol = eth_hdr(packet)->h_proto;
+	if (!eth_proto_is_802_3(packet->protocol))
 		packet->protocol = htons(ETH_P_802_2);
 
 	if (eth_type_vlan(packet->protocol)) {
