From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH v2 net-next] net: better IFF_XMIT_DST_RELEASE support
Date: Mon, 06 Oct 2014 15:05:26 -0700
Message-ID: <1412633126.11091.89.camel@edumazet-glaptop2.roam.corp.google.com>
References: <1412559515.11091.46.camel@edumazet-glaptop2.roam.corp.google.com>
	 <20141006.175015.2075737681876306575.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, ja@ssi.bg
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pd0-f178.google.com ([209.85.192.178]:38092 "EHLO
	mail-pd0-f178.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1751213AbaJFWF2 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 6 Oct 2014 18:05:28 -0400
Received: by mail-pd0-f178.google.com with SMTP id y10so3931894pdj.37
        for <netdev@vger.kernel.org>; Mon, 06 Oct 2014 15:05:27 -0700 (PDT)
In-Reply-To: <20141006.175015.2075737681876306575.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2014-10-06 at 17:50 -0400, David Miller wrote:
> From: Eric Dumazet <eric.dumazet@gmail.com>
> Date: Sun, 05 Oct 2014 18:38:35 -0700
> 
> > @@ -1001,7 +1001,8 @@ static netdev_features_t bond_fix_features(struct net_device *dev,
> >  
> >  static void bond_compute_features(struct bonding *bond)
> >  {
> > -	unsigned int flags, dst_release_flag = IFF_XMIT_DST_RELEASE;
> > +	unsigned int dst_release_flag = IFF_XMIT_DST_RELEASE |
> > +					IFF_XMIT_DST_RELEASE_PERM;
> >  	netdev_features_t vlan_features = BOND_VLAN_FEATURES;
> >  	netdev_features_t enc_features  = BOND_ENC_FEATURES;
> >  	struct net_device *bond_dev = bond->dev;
> > @@ -1037,8 +1038,10 @@ done:
> >  	bond_dev->gso_max_segs = gso_max_segs;
> >  	netif_set_gso_max_size(bond_dev, gso_max_size);
> >  
> > -	flags = bond_dev->priv_flags & ~IFF_XMIT_DST_RELEASE;
> > -	bond_dev->priv_flags = flags | dst_release_flag;
> > +	bond_dev->priv_flags &= ~IFF_XMIT_DST_RELEASE;
> > +	if ((bond_dev->priv_flags & IFF_XMIT_DST_RELEASE_PERM) &&
> > +	    dst_release_flag == (IFF_XMIT_DST_RELEASE | IFF_XMIT_DST_RELEASE_PERM))
> > +		bond_dev->priv_flags |= IFF_XMIT_DST_RELEASE;
> 
> I think I might be missing something, but in all of these places where
> you add this logic, it looks to me like:
> 
> 	dst_release_flag = CONSTANT;
> 	...
> 	if (... &&
> 	    dst_release_flags == CONSTANT)
> 
> This 'dst_release_flag' variable never changes, so why bother with the
> test at all?


We have a loop over team/bonding members, where we do :

dst_release_flag &= slave->dev->priv_flags;

So at the end of the loop, we check if any one of the member had one of
the bit cleared.

if dst_release_flags has both bits set, then we are set and we allow the
IFF_XMIT_DST_RELEASE being set on the master.
