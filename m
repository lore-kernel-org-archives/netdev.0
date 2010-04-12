From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH] vlan: remove receive checks for bonding
Date: Mon, 12 Apr 2010 16:19:56 -0700
Message-ID: <30741.1271114396@death.nxdomain.ibm.com>
References: <20100412221645.8068.71073.stgit@localhost6.localdomain6> <20100412221723.8068.75393.stgit@localhost6.localdomain6>
Cc: netdev@vger.kernel.org, Andy Gospodarek <andy@greyhouse.net>,
	Patrick McHardy <kaber@trash.net>,
	bonding-devel@lists.sourceforge.net
To: Chris Leech <christopher.leech@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e32.co.us.ibm.com ([32.97.110.150]:60812 "EHLO
	e32.co.us.ibm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751693Ab0DLXT7 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 12 Apr 2010 19:19:59 -0400
Received: from d03relay01.boulder.ibm.com (d03relay01.boulder.ibm.com [9.17.195.226])
	by e32.co.us.ibm.com (8.14.3/8.13.1) with ESMTP id o3CNDAUu010187
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 17:13:10 -0600
Received: from d03av03.boulder.ibm.com (d03av03.boulder.ibm.com [9.17.195.169])
	by d03relay01.boulder.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o3CNJwe5133422
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 17:19:58 -0600
Received: from d03av03.boulder.ibm.com (loopback [127.0.0.1])
	by d03av03.boulder.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o3CGJvLA000336
	for <netdev@vger.kernel.org>; Mon, 12 Apr 2010 10:19:57 -0600
In-reply-to: <20100412221723.8068.75393.stgit@localhost6.localdomain6>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Chris Leech <christopher.leech@intel.com> wrote:

>The checks in the hardware accelerated receive path are not up to date
>with what's in netif_receive_skb, which will get called anyway if the
>frame is not dropped in the vlan code.
>
>Signed-off-by: Chris Leech <christopher.leech@intel.com>

NAK.

	As I explained in a reply to Chris's separate message detailing
the problem he sees, the skb_bond_should_drop logic as implemented is
dependent upon knowing the original skb->dev the packet arrived on,
prior to VLAN reassigning it.

	That's not to say there's nothing wrong here, but removing the
calls with break other things.

	-J

>---
>
> net/8021q/vlan_core.c |    6 ------
> 1 files changed, 0 insertions(+), 6 deletions(-)
>
>diff --git a/net/8021q/vlan_core.c b/net/8021q/vlan_core.c
>index c584a0a..7576f9c 100644
>--- a/net/8021q/vlan_core.c
>+++ b/net/8021q/vlan_core.c
>@@ -11,9 +11,6 @@ int __vlan_hwaccel_rx(struct sk_buff *skb, struct vlan_group *grp,
> 	if (netpoll_rx(skb))
> 		return NET_RX_DROP;
>
>-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>-		goto drop;
>-
> 	skb->skb_iif = skb->dev->ifindex;
> 	__vlan_hwaccel_put_tag(skb, vlan_tci);
> 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>@@ -83,9 +80,6 @@ vlan_gro_common(struct napi_struct *napi, struct vlan_group *grp,
> {
> 	struct sk_buff *p;
>
>-	if (skb_bond_should_drop(skb, ACCESS_ONCE(skb->dev->master)))
>-		goto drop;
>-
> 	skb->skb_iif = skb->dev->ifindex;
> 	__vlan_hwaccel_put_tag(skb, vlan_tci);
> 	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
>

---
	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
