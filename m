From: Toshiaki Makita <toshiaki.makita1@gmail.com>
Subject: Re: [PATCH net-next v2] vxlan: fix handling of the inner 8021Q
 tagged frame
Date: Thu, 03 Apr 2014 01:16:36 +0900
Message-ID: <1396455396.2215.32.camel@localhost.localdomain>
References: <87d2h1i0pj.wl%atzm@stratosphere.co.jp>
		<533BCABF.80303@lab.ntt.co.jp> <874n2cszho.wl%atzm@stratosphere.co.jp>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 7bit
Cc: Toshiaki Makita <makita.toshiaki@lab.ntt.co.jp>,
	netdev@vger.kernel.org,
	Stephen Hemminger <stephen@networkplumber.org>
To: Atzm Watanabe <atzm@stratosphere.co.jp>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pa0-f41.google.com ([209.85.220.41]:34884 "EHLO
	mail-pa0-f41.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1758711AbaDBQQm (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 2 Apr 2014 12:16:42 -0400
Received: by mail-pa0-f41.google.com with SMTP id fa1so410444pad.14
        for <netdev@vger.kernel.org>; Wed, 02 Apr 2014 09:16:41 -0700 (PDT)
In-Reply-To: <874n2cszho.wl%atzm@stratosphere.co.jp>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2014-04-02 at 21:10 +0900, Atzm Watanabe wrote:
> Hi Makita-san,

Hi :)

> 
> At Wed, 02 Apr 2014 17:30:55 +0900,
> Toshiaki Makita wrote:
> > 
> > (2014/04/01 23:27), Atzm Watanabe wrote:
> > > Currently the implementation can forward the 8021Q tagged frame,
> > > but the FDB cannot learn the VID.
> > > So there is a possibility of forwarding the frame to wrong VTEP,
> > > when same LLADDR exists on different VLANs.
> > > 
> > > This patch supports only single tagged frame, so the outermost
> > > tag will be used when handling the 8021AD Q-in-Q frame.
> > > 
> > > v2: Fix probably unsafe operation on the struct vxlan_key.
> > >     The outermost tag will be used when handling the 8021AD
> > >     Q-in-Q frame.  Based on Stephen Hemminger's comments.
> > > 
> > > Signed-off-by: Atzm Watanabe <atzm@stratosphere.co.jp>
> > ...
> > > @@ -1215,8 +1257,18 @@ static void vxlan_rcv(struct vxlan_sock *vs,
> > >  #endif
> > >  	}
> > >  
> > > +	ether_addr_copy(key.eth_addr, eth_hdr(skb)->h_source);
> > > +	switch (ntohs(eth_hdr(skb)->h_proto)) {
> > > +	case ETH_P_8021Q:
> > > +	case ETH_P_8021AD:
> > > +		key.vlan_id = ntohs(vlan_eth_hdr(skb)->h_vlan_TCI) & VLAN_VID_MASK;
> > > +		break;
> > 
> > It seems that we can't segregate skbs tagged by same vlan id but
> > different vlan protocols.
> 
> Yes, but I believe it is better than all vlan protocols are ignored.
> 
> Of course it still has problems when multiple protocols (0x8100,
> 0x88a8, 0x9100, ...) are mixed in a network, but I want to fix
> a problem in case of single tagged, at the beginning.

What I'm worried about is the use of the native vlan.
For example, if we are using C-vlan/S-vlan combination and use native
vlan for a certain S-vlan id.
In this case, we may see both double C/S-tagged frames and single
C-tagged frames, and we may treat C-vid as S-vid for single tagged
case...
This causes incorrect delivery of frames.

Maybe we can explicitly set the vlan protocol to be focused on by user
space, but this is just a suggestion.
If you are starting by this implementation, it's maybe better to note
this equating two protocols and the possible problem (in changelog or
somewhere).

Thanks,
Toshiaki Makita
