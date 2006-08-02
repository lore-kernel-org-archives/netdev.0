From: David Miller <davem@davemloft.net>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Wed, 02 Aug 2006 13:58:59 -0700 (PDT)
Message-ID: <20060802.135859.91441473.davem@davemloft.net>
References: <44CA87C5.1060905@candelatech.com>
	<20060730.205032.130618331.davem@davemloft.net>
	<200607311015.40255.Christophe.Devriese@eurid.eu>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:16034
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S932093AbWHBU6t (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 2 Aug 2006 16:58:49 -0400
To: Christophe.Devriese@eurid.eu
In-Reply-To: <200607311015.40255.Christophe.Devriese@eurid.eu>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Date: Mon, 31 Jul 2006 10:15:40 +0200

Thanks for the detailed explanation.

> If you bond 2 vlan subinterfaces, the patch is not necessary at all. In that 
> case also the source device will be changed from eth0.<vlan> to bond<x>. So 
> that's correct behavior no ?
> 
> In the second case, you create vlan subifs on a bonding device, vlan 
> subinterfaces will be created on the slave interfaces. In that case the vlan 
> code will reassign the skb->dev node, and because skb_bond needs to know the 
> actual input device in order to make an informed drop decision before passing 
> this code (skb active-backup mode needs to drop packets from the backup slave 
> interface, if you don't do that you get big problems with broadcasts). 
> 
> The same struct vlan_group is assigned to all slave devices and so the only 
> vlan subinterfaces that exist in this case are the bond<x>.<vlan> 
> subinterfaces, and the vlan path for both slaves will assign the 
> bond<x>.<vlan> interface to skb->dev, thereby erasing the information about 
> where the packet came from.

Assuming it is correct to do the skb_bond() here in the VLAN hwaccel
RX path, then there is still one piece missing from what I can see.

Notice that in the netif_receive_skb() path, the return value from
skb_bond() is used as the third argument to the deliver_skb() routine
and friends which in turn gets passed to the packet_type functions.

Bonding, in particular, makes use of this third argument, see:

bond_3ad_lacpdu_recv()
rlb_arp_recv()

So if the new "orig_dev" you are computing in the VLAN hwaccel RX path
is the correct one, somehow this has to propagate down to the third
argument of the packet type ->func() invocations, right?

Finally, I'm still a little stumped about why this change is necessary
still, to be honest.  When you configure the bond, the slaves should
be the VLAN devices as far as I can tell.  Therefore it should be the
"vlan_device->masster" that we are interested in not the top-level
"dev->master".

If the ethernet is on a VLAN, and the administrator configures the
underlying ethernet device as the slaves of the bond, this to me seems
like a misconfiguration rather than something we should put hacks in
to support.

The fact that you do not propagate the "orig_dev" returned from
skb_bond() down to the packet type functions seems to support this.
>From my perspective, this looks like a hack for a bonding
misconfiguration.

