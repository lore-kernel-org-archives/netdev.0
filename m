From: Jarno Rajahalme <jarno@ovn.org>
Subject: Re: [PATCH net-next 2/2] openvswitch: Fix skb->protocol for vlan frames.
Date: Mon, 28 Nov 2016 14:29:39 -0800
Message-ID: <76814927-D373-4C3A-BC85-5771304235A7@ovn.org>
References: <1479874174-75329-1-git-send-email-jarno@ovn.org> <1479874174-75329-2-git-send-email-jarno@ovn.org> <20161124171046.7eb0e287@griffin>
Mime-Version: 1.0 (Mac OS X Mail 9.3 \(3124\))
Content-Type: text/plain; charset=utf-8
Content-Transfer-Encoding: 8BIT
Cc: netdev@vger.kernel.org
To: Jiri Benc <jbenc@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pf0-f195.google.com ([209.85.192.195]:33890 "EHLO
        mail-pf0-f195.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
        with ESMTP id S1755318AbcK1W3m (ORCPT
        <rfc822;netdev@vger.kernel.org>); Mon, 28 Nov 2016 17:29:42 -0500
Received: by mail-pf0-f195.google.com with SMTP id y68so7037440pfb.1
        for <netdev@vger.kernel.org>; Mon, 28 Nov 2016 14:29:42 -0800 (PST)
In-Reply-To: <20161124171046.7eb0e287@griffin>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


> On Nov 24, 2016, at 8:10 AM, Jiri Benc <jbenc@redhat.com> wrote:
> 
> On Tue, 22 Nov 2016 20:09:34 -0800, Jarno Rajahalme wrote:
>> Do not set skb->protocol to be the ethertype of the L3 header, unless
>> the packet only has the L3 header.  For a non-hardware offloaded VLAN
>> frame skb->protocol needs to be one of the VLAN ethertypes.
>> 
>> Any VLAN offloading is undone on the OVS netlink interface.  Due to
>> this all VLAN packets sent to openvswitch module from userspace are
>> non-offloaded.
> 
> This is exactly why I wanted to always accelerate the vlan tag, the
> same way it is done in other parts of the networking stack: to prevent
> all those weird corner cases.
> 
> Looks to me this is the only real way forward.
> 

I’m not sure what you suggest here. Obviously the kernel ABI can not be changed as existing userspace code expects upcalled packets to be non-accelerated. Also, if userspace pushes vlan headers, the packet will actually have them.

> This patch is wrong, it would leave skb->protocol as ETH_P_TEB for L2
> frames received via ARPHRD_NONE interface.
> 

Would this incremental fix this:

diff --git a/net/openvswitch/flow.c b/net/openvswitch/flow.c
index 9be9fda..37f1bb9 100644
--- a/net/openvswitch/flow.c
+++ b/net/openvswitch/flow.c
@@ -354,6 +354,8 @@ static int parse_vlan(struct sk_buff *skb, struct sw_flow_key *key)
 		res = parse_vlan_tag(skb, &key->eth.vlan);
 		if (res <= 0)
 			return res;
+		if (skb->protocol == htons(ETH_P_TEB))
+			skb->protocol = key->eth.vlan.tpid;
 	}
 
 	/* Parse inner vlan tag. */


  Jarno
