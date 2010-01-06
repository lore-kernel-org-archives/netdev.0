From: Jay Vosburgh <fubar@us.ibm.com>
Subject: Re: [PATCH net-next-2.6] fix bonding: allow arp_ip_targets on separate vlans to use arp validation
Date: Wed, 06 Jan 2010 15:53:49 -0800
Message-ID: <13683.1262822029@death.nxdomain.ibm.com>
References: <65634d660911201528k5a07135el471b65fff9dd7c9d@mail.gmail.com> <20091120154046.67252d23@nehalam> <65634d660912171304p751e1698mbc9de50dade4317d@mail.gmail.com> <65634d661001051732qd64e79dt37e6247f8b0dc863@mail.gmail.com> <4B44258C.2050302@gmail.com> <4B44D89B.8070006@gmail.com> <4B44FC2B.4090505@gmail.com> <20100106225637.GC6490@gospo.rdu.redhat.com>
Cc: Eric Dumazet <eric.dumazet@gmail.com>,
	Tom Herbert <therbert@google.com>,
	David Miller <davem@davemloft.net>,
	Linux Netdev List <netdev@vger.kernel.org>
To: Andy Gospodarek <andy@greyhouse.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from e3.ny.us.ibm.com ([32.97.182.143]:46213 "EHLO e3.ny.us.ibm.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S933103Ab0AFXyJ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 6 Jan 2010 18:54:09 -0500
Received: from d01relay07.pok.ibm.com (d01relay07.pok.ibm.com [9.56.227.147])
	by e3.ny.us.ibm.com (8.14.3/8.13.1) with ESMTP id o06NiNcX016517
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 18:44:23 -0500
Received: from d01av02.pok.ibm.com (d01av02.pok.ibm.com [9.56.224.216])
	by d01relay07.pok.ibm.com (8.13.8/8.13.8/NCO v10.0) with ESMTP id o06Ns8jh2068530
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 18:54:08 -0500
Received: from d01av02.pok.ibm.com (loopback [127.0.0.1])
	by d01av02.pok.ibm.com (8.14.3/8.13.1/NCO v10.0 AVout) with ESMTP id o06Ns7UM027498
	for <netdev@vger.kernel.org>; Wed, 6 Jan 2010 21:54:08 -0200
In-reply-to: <20100106225637.GC6490@gospo.rdu.redhat.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Andy Gospodarek <andy@greyhouse.net> wrote:

>This patch fixes up a problem with found with commit
>1f3c8804acba841b5573b953f5560d2683d2db0d.  The original change
>overloaded null_or_orig, but doing that prevented any packet handlers
>that were not tied to a specific device (i.e. ptype->dev == NULL) from
>ever receiving any frames.
>
>The null_or_orig variable cannot be overloaded, and must be kept as NULL
>to prevent the frame from being ignored by packet handlers designed to
>accept frames on any interface.
>
>Signed-off-by: Andy Gospodarek <andy@greyhouse.net>

	Tested, and it appears to work fine.  Tcpdump also appears to
behave rationally.

	-J

Signed-off-by: Jay Vosburgh <fubar@us.ibm.com>


>---
> dev.c |   11 +++++------
> 1 file changed, 5 insertions(+), 6 deletions(-)
>
>diff --git a/net/core/dev.c b/net/core/dev.c
>index f9aa699..d9ab9be 100644
>--- a/net/core/dev.c
>+++ b/net/core/dev.c
>@@ -2430,6 +2430,7 @@ int netif_receive_skb(struct sk_buff *skb)
> 	struct packet_type *ptype, *pt_prev;
> 	struct net_device *orig_dev;
> 	struct net_device *null_or_orig;
>+	struct net_device *null_or_bond;
> 	int ret = NET_RX_DROP;
> 	__be16 type;
>
>@@ -2500,21 +2501,19 @@ ncls:
> 	 * bonding interfaces still make their way to any base bonding
> 	 * device that may have registered for a specific ptype.  The
> 	 * handler may have to adjust skb->dev and orig_dev.
>-	 *
>-	 * null_or_orig can be overloaded since it will not be set when
>-	 * using VLANs on top of bonding.  Putting it here prevents
>-	 * disturbing the ptype_all handlers above.
> 	 */
>+	null_or_bond = NULL;
> 	if ((skb->dev->priv_flags & IFF_802_1Q_VLAN) &&
> 	    (vlan_dev_real_dev(skb->dev)->priv_flags & IFF_BONDING)) {
>-		null_or_orig = vlan_dev_real_dev(skb->dev);
>+		null_or_bond = vlan_dev_real_dev(skb->dev);
> 	}
>
> 	type = skb->protocol;
> 	list_for_each_entry_rcu(ptype,
> 			&ptype_base[ntohs(type) & PTYPE_HASH_MASK], list) {
> 		if (ptype->type == type && (ptype->dev == null_or_orig ||
>-		     ptype->dev == skb->dev || ptype->dev == orig_dev)) {
>+		     ptype->dev == skb->dev || ptype->dev == orig_dev ||
>+		     ptype->dev == null_or_bond)) {
> 			if (pt_prev)
> 				ret = deliver_skb(skb, pt_prev, orig_dev);
> 			pt_prev = ptype;
>--
>To unsubscribe from this list: send the line "unsubscribe netdev" in
>the body of a message to majordomo@vger.kernel.org
>More majordomo info at  http://vger.kernel.org/majordomo-info.html
