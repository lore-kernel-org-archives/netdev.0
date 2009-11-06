From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [RFC] move dma_head/dma_maps out of skb_shared_info and into
 sk_buff
Date: Fri, 06 Nov 2009 03:14:35 +0100
Message-ID: <4AF3868B.7070409@gmail.com>
References: <4AF373C9.7040700@intel.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"davem@davemloft.net" <davem@davemloft.net>
To: Alexander Duyck <alexander.h.duyck@intel.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from gw1.cosmosbay.com ([212.99.114.194]:52247 "EHLO
	gw1.cosmosbay.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757671AbZKFCOg (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 5 Nov 2009 21:14:36 -0500
In-Reply-To: <4AF373C9.7040700@intel.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Alexander Duyck a =E9crit :
> During testing we found issues with the use of skb_dma_map/unmap on
> systems that had iommu enabled and were configured to use a bridge.  =
The
> issue is that if two ports are members of the same bridge, and a
> broadcast packet is sent out on the bridge skb_clone will be used to
> send a copy to all ports, but the clones run into issues because the
> dma mappings for the cloned skbs all share the shared_info structure
> where the dma mappings are stored.
>=20
> To resolve that this patch moves those dma mappings out of the
> shared_info structure and into the sk_buff itself.  This allows clone=
d
> skbs to be mapped separately without causing dma unmapping errors.
>=20
> Signed-off-by: Alexander Duyck <alexander.h.duyck@intel.com>

Hello Alexander

You probably know such a change is a major one ;)

1) a diffstat -p1 -w70 for this kind of patch would be nice.

2) Your patch is garbled (tabulations were replaced by spaces
 by your mailer)

3) Are you sure we need to clear dma_maps[] array and dma_head=20
   in __alloc_skb() ? I guess not.
   MAX_SKB_FRAGS =3D 18 on x86  -> 152 bytes on x86_64.
   Previous implementation was not clearing them.
   Thats would be a major slow down.

4) 152 bytes more in skb -> 304 bytes more in skbuff_fclone_cache
   Do we really want two copies of dma_maps[] when skb are allocated
   from fclone cache ?

5) It seems to me this stuff is needed for xmit only and few drivers,
   could we find a way to not have it for RX path and drivers that dont
   need it ? Maybe drivers themselves should allocate storage for this
  stuff so we can remove it both from shared_info *and* skb=20

Thanks


