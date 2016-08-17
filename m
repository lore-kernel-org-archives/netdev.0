From: Hadar Hen Zion <hadarh@dev.mellanox.co.il>
Subject: Re: [PATCH net-next V2 1/5] flow_dissector: For stripped vlan, get
 vlan info from skb->vlan_tci
Date: Wed, 17 Aug 2016 14:05:33 +0300
Message-ID: <CAJL1qvEDgd2r-iggQ5W-uvYVsWN-uQGN7ab5gN_J26Sk7-=O=g@mail.gmail.com>
References: <1471430174-27740-1-git-send-email-hadarh@mellanox.com>
 <1471430174-27740-2-git-send-email-hadarh@mellanox.com> <20160817104614.GD1956@nanopsycho>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Cc: Hadar Hen Zion <hadarh@mellanox.com>,
	"David S. Miller" <davem@davemloft.net>,
	netdev <netdev@vger.kernel.org>, Jiri Pirko <jiri@mellanox.com>,
	Amir Vadai <amirva@mellanox.com>,
	Or Gerlitz <ogerlitz@mellanox.com>,
	Tom Herbert <tom@herbertland.com>
To: Jiri Pirko <jiri@resnulli.us>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-oi0-f68.google.com ([209.85.218.68]:33916 "EHLO
	mail-oi0-f68.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751463AbcHQLFf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 17 Aug 2016 07:05:35 -0400
Received: by mail-oi0-f68.google.com with SMTP id t127so9953897oie.1
        for <netdev@vger.kernel.org>; Wed, 17 Aug 2016 04:05:34 -0700 (PDT)
In-Reply-To: <20160817104614.GD1956@nanopsycho>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, Aug 17, 2016 at 1:46 PM, Jiri Pirko <jiri@resnulli.us> wrote:
> Wed, Aug 17, 2016 at 12:36:10PM CEST, hadarh@mellanox.com wrote:
>>Early in the datapath skb_vlan_untag function is called, stripped
>>the vlan from the skb and set skb->vlan_tci and skb->vlan_proto fields.
>>
>>The current dissection doesn't handle stripped vlan packets correctly.
>>In some flows, vlan doesn't exist in skb->data anymore when applying
>>flow dissection on the skb, fix that.
>>
>>In case vlan info wasn't stripped before applying flow_dissector (RPS
>>flow for example), or in case of skb with multiple vlans (e.g. 802.1ad),
>>get the vlan info from skb->data. The flow_dissector correctly skips
>>any number of vlans and stores only the first level vlan.
>>
>>Fixes: 0744dd00c1b1 ('net: introduce skb_flow_dissect()')
>>Signed-off-by: Hadar Hen Zion <hadarh@mellanox.com>
>>---
>> net/core/flow_dissector.c | 34 ++++++++++++++++++++++++++--------
>> 1 file changed, 26 insertions(+), 8 deletions(-)
>>
>>diff --git a/net/core/flow_dissector.c b/net/core/flow_dissector.c
>>index 91028ae..362d693 100644
>>--- a/net/core/flow_dissector.c
>>+++ b/net/core/flow_dissector.c
>>@@ -119,12 +119,14 @@ bool __skb_flow_dissect(const struct sk_buff *skb,
>>       struct flow_dissector_key_ports *key_ports;
>>       struct flow_dissector_key_tags *key_tags;
>>       struct flow_dissector_key_keyid *key_keyid;
>>+      bool skip_vlan = false;
>>       u8 ip_proto = 0;
>>       bool ret = false;
>>
>>       if (!data) {
>>               data = skb->data;
>>-              proto = skb->protocol;
>>+              proto = skb_vlan_tag_present(skb) ?
>>+                       skb->vlan_proto : skb->protocol;
>>               nhoff = skb_network_offset(skb);
>>               hlen = skb_headlen(skb);
>>       }
>>@@ -243,23 +245,39 @@ ipv6:
>>       case htons(ETH_P_8021AD):
>>       case htons(ETH_P_8021Q): {
>>               const struct vlan_hdr *vlan;
>>-              struct vlan_hdr _vlan;
>>
>>-              vlan = __skb_header_pointer(skb, nhoff, sizeof(_vlan), data, hlen, &_vlan);
>>-              if (!vlan)
>>-                      goto out_bad;
>>+              if (skb_vlan_tag_present(skb))
>>+                      proto = skb->protocol;
>>+
>>+              if (!skb_vlan_tag_present(skb) ||
>>+                  proto == cpu_to_be16(ETH_P_8021Q) ||
>>+                  proto == cpu_to_be16(ETH_P_8021AD)) {
>
> How this can happen? Could you give me an example?
>

This can happen in 2 cases:

1. vlan wasn't stripped yet from the skb.
In RPS flow for example, get_rps_cpu function is using flow-dissector
before vlan_untag is called by __netif_receive_skb_core.

2. skb with multiple vlan tags.
Only the first vlan is stripped while the inner vlans are still in skb->data.
In this case skb->vlan_proto is 802.1AD and skb->protocol is 802.1Q
(for example) so I have to take the next header from skb->data.
