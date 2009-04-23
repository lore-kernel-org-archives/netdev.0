From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: bond interface arp, vlan and trunk / network question
Date: Thu, 23 Apr 2009 11:34:20 -0700
Message-ID: <3302.1240511660@death.nxdomain.ibm.com>
References: <1ef444010904201300r43268672sb74277f4a0242236@mail.gmail.com> <7609.1240259780@death.nxdomain.ibm.com> <1ef444010904201403s5d583750i1ce3a5da6c6f4059@mail.gmail.com> <13606.1240262581@death.nxdomain.ibm.com> <1ef444010904201439i60f9e918j760d94eeca428ece@mail.gmail.com> <22462.1240272112@death.nxdomain.ibm.com> <1ef444010904220129l24a74f07q8f32edfabe603436@mail.gmail.com> <32563.1240449149@death.nxdomain.ibm.com> <20090423074803.GB29268@psychotron.englab.brq.redhat.com> <12644.1240498781@death.nxdomain.ibm.com> <20090423152005.GI29268@psychotron.englab.brq.redhat.com>
Cc: stefan novak <lms.brubaker@gmail.com>,
	Eric Dumazet <dada1@cosmosbay.com>,
	linux-kernel@vger.kernel.org,
	Linux Netdev List <netdev@vger.kernel.org>
To: Jiri Pirko <jpirko@redhat.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e35.co.us.ibm.com ([32.97.110.153]:49960 "EHLO
	e35.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757303AbZDWSeP (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 23 Apr 2009 14:34:15 -0400
In-reply-to: <20090423152005.GI29268@psychotron.englab.brq.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Jiri Pirko <jpirko@redhat.com> wrote:
>Thu, Apr 23, 2009 at 04:59:41PM CEST, fubar@us.ibm.com wrote:
>>Jiri Pirko <jpirko@redhat.com> wrote:
[...]
>>>>+{
>>>>+	struct net_device *dev = skb->dev;
>>>>+	struct net_device *master = dev->master;
>>>>+
>>>>+	if (master)
>>>>+		return bond_handle_frame_hook(skb);
>>>
>>>Maybe this hook can be called from netif_receive_skb() directly. You would safe
>>>at least 2 dereferences, 1 if check. You would also need to add
>>>"skb->dev->master &&" to if in __vlan_hwaccel_rx() and vlan_gro_common().
>>
>>	This won't work, because the VLAN code reassigns skb->dev to the
>>VLAN device before calling netif_receive_skb.
>
>Sure, but bond_should_drop is called before it actually reassigns that. So the
>check in bond_should_drop tests "original_dev->master".
>
>I had on mind something like following:
>
>Signed-off-by: Jiri Pirko <jpirko@redhat.com>
>
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index c67fe6f..87a7334 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -11,7 +11,7 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
> 	if (netpoll_rx(skb))
> 		return NET_RX_DROP;
>
>-	if (skb_bond_should_drop(skb))
>+	if (skb->dev->master && bond_handle_frame_hook(skb))
[...]

	Yah, ok, I see what you mean.  The same could be accomplished by
turning skb_bond_should_drop back into an inline in the header file, and
hiding the fiddly bits from the calling context.

	It's pretty grotty no matter how it's done; I'd prefer to avoid
the whole hook business, but I haven't thought of a less bad way.

	-J

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
