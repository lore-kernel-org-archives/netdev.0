From: Christophe Devriese <Christophe.Devriese@eurid.eu>
Subject: Re: PATCH Fix bonding active-backup behavior for VLAN interfaces
Date: Mon, 31 Jul 2006 10:15:40 +0200
Message-ID: <200607311015.40255.Christophe.Devriese@eurid.eu>
References: <44CA34D0.1070507@candelatech.com> <44CA87C5.1060905@candelatech.com> <20060730.205032.130618331.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain;
  charset="iso-8859-1"
Content-Transfer-Encoding: 7bit
Return-path: <netdev-owner@vger.kernel.org>
Received: from uu212-190-206-99.unknown.uunet.be ([212.190.206.99]:44509 "EHLO
	smtp.eurid.eu") by vger.kernel.org with ESMTP id S964834AbWGaIPu
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 31 Jul 2006 04:15:50 -0400
To: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
In-Reply-To: <20060730.205032.130618331.davem@davemloft.net>
Content-Disposition: inline
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Monday 31 July 2006 05:50, you wrote:
> From: Ben Greear <greearb@candelatech.com>
> Date: Fri, 28 Jul 2006 14:55:17 -0700
>
> > The skb_bond method assigns skb->dev when it does the 'keep',
> > but the VLAN code immediately over-writes the skb->dev when
> > searching for the vlan device.
> >
> > What is the purpose of assinging skb->dev to the master device?
>
> This makes me consider this patch highly dubious, at best.
>
> The whole intention of bonding on input is to make all packets
> incoming on the individual bond slaves to look like they come in via
> the master device.
>
> Therefore, even when the bond slaves are VLAN devices, in the end the
> skb->dev should be the bond master device _not_ the VLAN device.
>
> I'm not applying this patch, it doesn't look correct at all.

That code is not introduced by this patch, but is already in the kernel. This 
patch is about having the same behavior for the vlan accelerated input path 
and the normal input path.

If you bond 2 vlan subinterfaces, the patch is not necessary at all. In that 
case also the source device will be changed from eth0.<vlan> to bond<x>. So 
that's correct behavior no ?

In the second case, you create vlan subifs on a bonding device, vlan 
subinterfaces will be created on the slave interfaces. In that case the vlan 
code will reassign the skb->dev node, and because skb_bond needs to know the 
actual input device in order to make an informed drop decision before passing 
this code (skb active-backup mode needs to drop packets from the backup slave 
interface, if you don't do that you get big problems with broadcasts). 

The same struct vlan_group is assigned to all slave devices and so the only 
vlan subinterfaces that exist in this case are the bond<x>.<vlan> 
subinterfaces, and the vlan path for both slaves will assign the 
bond<x>.<vlan> interface to skb->dev, thereby erasing the information about 
where the packet came from.

I have tested the patch, and it works correctly, in both cases on my test 
sytem (where I join vlan subifs on a bonding device into a bridge and have 
xen guests' vifX.Y interfaces connected to those bridges, which is a 
configuration we imho really want to support) (without this patch, as 
explained earlier in this thread, this config does not work)

Regards,

Christophe
