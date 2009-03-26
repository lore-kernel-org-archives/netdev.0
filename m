From: Jiri Pirko <jpirko@redhat.com>
Subject: Re: [PATCH] bonding: allow bond in mode balance-alb to work
	properly in bridge -try3
Date: Thu, 26 Mar 2009 12:12:14 +0100
Message-ID: <20090326111213.GA3471@psychotron.englab.brq.redhat.com>
References: <20090313183303.GF3436@psychotron.englab.brq.redhat.com> <20090325151937.GI3437@psychotron.englab.brq.redhat.com> <28445.1237998713@death.nxdomain.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: linux-kernel@vger.kernel.org, netdev@vger.kernel.org,
	jgarzik@pobox.com, davem@davemloft.net,
	shemminger@linux-foundation.org, bridge@lists.linux-foundation.org,
	bonding-devel@lists.sourceforge.net, kaber@trash.net,
	mschmidt@redhat.com, dada1@cosmosbay.com
To: Jay Vosburgh <fubar@us.ibm.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx2.redhat.com ([66.187.237.31]:48800 "EHLO mx2.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751075AbZCZLO7 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 26 Mar 2009 07:14:59 -0400
Content-Disposition: inline
In-Reply-To: <28445.1237998713@death.nxdomain.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Wed, Mar 25, 2009 at 05:31:53PM CET, fubar@us.ibm.com wrote:
>>@@ -2251,10 +2258,12 @@ int netif_receive_skb(struct sk_buff *skb)
>> 	null_or_orig = NULL;
>> 	orig_dev = skb->dev;
>> 	if (orig_dev->master) {
>>-		if (skb_bond_should_drop(skb))
>>+		if (skb_bond_should_drop(skb)) {
>> 			null_or_orig = orig_dev; /* deliver only exact match */
>>-		else
>>+		} else {
>> 			skb->dev = orig_dev->master;
>>+			bond_change_dest_hook(skb);
>
>	Since you put the hook outside of the skb_bond_should_drop
>function, does the VLAN accelerated receive path do the right thing if,
>e.g., there's a VLAN on top of bonding and that VLAN is part of the
>bridge?

Don't worry :) I did not forget about this - just needed a bit time to
investigate...

Yeah, this look's like a problem. In __vlan_hwaccel_rx there is following line:
	skb->dev = vlan_group_get_device(grp, vlan_tci & VLAN_VID_MASK);
This rewrites the dev so latter on when netif_receive_skb is called the hook
will be not called (because dev->master will not be set).

Ok I will put the hook inside the skb_bond_should_drop() - it seems like a
correct solution...

Thanks for pointing this out.
>
>	-J
>
>---
>	-Jay Vosburgh, IBM Linux Technology Center, fubar@us.ibm.com
