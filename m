From: Alexander Duyck <alexander.duyck@gmail.com>
Subject: Re: [RFC] move dma_head/dma_maps out of skb_shared_info and into
 sk_buff
Date: Thu, 05 Nov 2009 19:24:07 -0800
Message-ID: <1257477847.14523.30.camel@localhost>
References: <4AF373C9.7040700@intel.com>  <4AF3868B.7070409@gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: Alexander Duyck <alexander.h.duyck@intel.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-pz0-f188.google.com ([209.85.222.188]:46161 "EHLO
	mail-pz0-f188.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750741AbZKFDYK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 22:24:10 -0500
Received: by pzk26 with SMTP id 26so438765pzk.4
        for <netdev@vger.kernel.org>; Thu, 05 Nov 2009 19:24:16 -0800 (PST)
In-Reply-To: <4AF3868B.7070409@gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Fri, 2009-11-06 at 03:14 +0100, Eric Dumazet wrote:
> Alexander Duyck a =C3=A9crit :
> > During testing we found issues with the use of skb_dma_map/unmap on
> > systems that had iommu enabled and were configured to use a bridge.=
  The
> > issue is that if two ports are members of the same bridge, and a
> > broadcast packet is sent out on the bridge skb_clone will be used t=
o
> > send a copy to all ports, but the clones run into issues because th=
e
> > dma mappings for the cloned skbs all share the shared_info structur=
e
> > where the dma mappings are stored.
> >=20
> > To resolve that this patch moves those dma mappings out of the
> > shared_info structure and into the sk_buff itself.  This allows clo=
ned
> > skbs to be mapped separately without causing dma unmapping errors.
> >=20
> > Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>
>=20
> Hello Alexander
>=20
> You probably know such a change is a major one ;)
> 1) a diffstat -p1 -w70 for this kind of patch would be nice.
>=20
> 2) Your patch is garbled (tabulations were replaced by spaces
>  by your mailer)

I kind of figured that might be the case.  I didn't really intend the
patch to be applied to the tree and just meant it to get conversation
going.  That is why I had tagged it as [RFC].

> 3) Are you sure we need to clear dma_maps[] array and dma_head=20
>    in __alloc_skb() ? I guess not.
>    MAX_SKB_FRAGS =3D 18 on x86  -> 152 bytes on x86_64.
>    Previous implementation was not clearing them.
>    Thats would be a major slow down.
>=20
> 4) 152 bytes more in skb -> 304 bytes more in skbuff_fclone_cache
>    Do we really want two copies of dma_maps[] when skb are allocated
>    from fclone cache ?

The main problem that this was meant to address is the fact that
skb_dma_map is called dma_maps and dma_head needed to be maintained
until skb_dma_unmap was called.  This wasn't happening with them being
stored in the skb_shared_info structure due to the fact that if two
clones of the skb were mapped on 2 different devices the 2nd mapping
would overwrite the first, and then the skb_dma_unmap call was being
called on the 2nd dma mapping twice which would trigger a dma_unmapping
error followed by an error of mappings still being held for the first
device on driver unload.

> 5) It seems to me this stuff is needed for xmit only and few drivers,
>    could we find a way to not have it for RX path and drivers that do=
nt
>    need it ? Maybe drivers themselves should allocate storage for thi=
s
>   stuff so we can remove it both from shared_info *and* skb=20

I'm thinking the best solution may be to drop the skb_dma_map/unmap
calls entirely and move things back to the old approach in which device=
s
maintained their list of mappings.  At least until something better can
be figured out.

Thanks,

Alex


