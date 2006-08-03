From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Thu, 3 Aug 2006 15:34:55 +0200
Message-ID: <200608031534.55921.Christophe.Devriese@eurid.eu>
References: <44CA87C5.1060905@candelatech.com> <200607311015.40255.Christophe.Devriese@eurid.eu> <20060802.135859.91441473.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from uu212-190-206-99.unknown.uunet.be ([212.190.206.99]:35022 "EHLO
	smtp.eurid.eu") by vger.kernel.org with ESMTP id S932410AbWHCNe7
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 3 Aug 2006 09:34:59 -0400
Received: from localhost (smtp.eurid.eu [127.0.0.1])
	by smtp.eurid.eu (Postfix) with ESMTP id 710C5125269
	for <netdev@vger.kernel.org>; Thu,  3 Aug 2006 15:34:58 +0200 (CEST)
To: netdev@vger.kernel.org
In-Reply-To: <20060802.135859.91441473.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Wednesday 02 August 2006 22:58, you wrote:
> From: Christophe Devriese <Christophe.Devriese@eurid.eu>
> Date: Mon, 31 Jul 2006 10:15:40 +0200
>
> Thanks for the detailed explanation.
>
> > If you bond 2 vlan subinterfaces, the patch is not necessary at all. In
> > that case also the source device will be changed from eth0.<vlan> to
> > bond<x>. So that's correct behavior no ?
> >
> > In the second case, you create vlan subifs on a bonding device, vlan
> > subinterfaces will be created on the slave interfaces. In that case the
> > vlan code will reassign the skb->dev node, and because skb_bond needs to
> > know the actual input device in order to make an informed drop decision
> > before passing this code (skb active-backup mode needs to drop packets
> > from the backup slave interface, if you don't do that you get big
> > problems with broadcasts).
> >
> > The same struct vlan_group is assigned to all slave devices and so the
> > only vlan subinterfaces that exist in this case are the bond<x>.<vlan>
> > subinterfaces, and the vlan path for both slaves will assign the
> > bond<x>.<vlan> interface to skb->dev, thereby erasing the information
> > about where the packet came from.
>
> Assuming it is correct to do the skb_bond() here in the VLAN hwaccel
> RX path, then there is still one piece missing from what I can see.

The problem is that the vlan access path changes the skb->dev pointer around, 
after which it can no longer be determined what the source device was. (It 
defineately is not the parent of the vlan subinterface in the bond case)

> Notice that in the netif_receive_skb() path, the return value from
> skb_bond() is used as the third argument to the deliver_skb() routine
> and friends which in turn gets passed to the packet_type functions.
>
> Bonding, in particular, makes use of this third argument, see:
>
> bond_3ad_lacpdu_recv()
> rlb_arp_recv()
>
> So if the new "orig_dev" you are computing in the VLAN hwaccel RX path
> is the correct one, somehow this has to propagate down to the third
> argument of the packet type ->func() invocations, right?
>
> Finally, I'm still a little stumped about why this change is necessary
> still, to be honest.  When you configure the bond, the slaves should
> be the VLAN devices as far as I can tell.  Therefore it should be the
> "vlan_device->masster" that we are interested in not the top-level
> "dev->master".

Indeed but vlan_device->master is "bond0" instead of eth0 or eth1 (assuming 
you bond eth0 and eth1) so you cannot determine where the packet came from.

> If the ethernet is on a VLAN, and the administrator configures the
> underlying ethernet device as the slaves of the bond, this to me seems
> like a misconfiguration rather than something we should put hacks in
> to support.

In this configuration you have lot's more interfaces to administer and keep 
track of. Besides, what happened to "there's more than one way to do it ?". 
If you configure vlan subifs on a bonding device the correct behavior would 
be that the bonding logic is applied _first_ and then after the vlan gets 
considered, no ?

> The fact that you do not propagate the "orig_dev" returned from
> skb_bond() down to the packet type functions seems to support this.
> From my perspective, this looks like a hack for a bonding
> misconfiguration.
>
> -
> To unsubscribe from this list: send the line "unsubscribe netdev" in
> the body of a message to majordomo@vger.kernel.org
> More majordomo info at  http://vger.kernel.org/majordomo-info.html
