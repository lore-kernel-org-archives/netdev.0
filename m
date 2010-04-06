From: Eric Dumazet <eric.dumazet@gmail.com>
Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 06 Apr 2010 22:24:01 +0200
Message-ID: <1270585441.2091.65.camel@edumazet-laptop>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	 <1270502993.9013.36.camel@edumazet-laptop>
	 <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local>
	 <1270573233.2081.47.camel@edumazet-laptop>
	 <bf8eac92-5008-4c1f-9b99-0199e62436fa@SG2EHSMHS010.ehs.local>
	 <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=UTF-8
Content-Transfer-Encoding: QUOTED-PRINTABLE
Cc: John Linn <John.Linn@xilinx.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail-bw0-f209.google.com ([209.85.218.209]:34291 "EHLO
	mail-bw0-f209.google.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753224Ab0DFUYJ (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 16:24:09 -0400
Received: by bwz1 with SMTP id 1so260125bwz.21
        for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 13:24:06 -0700 (PDT)
In-Reply-To: <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Le mardi 06 avril 2010 =C3=A0 12:53 -0600, Grant Likely a =C3=A9crit :

> Hold on.... BUFFER_ALIGN is being used to align the DMA buffer on a
> cache line boundary.  I don't think netdev_alloc_skb() makes any
> guarantees about how the start of the IP header lines up against cach=
e
> line boundaries.  The amount of padding needed is not known until an
> skbuff is obtained from netdev_alloc_skb(), and
> netdev_alloc_skb_ip_align() can only handle a fixed size padding,
>=20
> It doesn't look like netdev_alloc_skb_ip_align() is the right thing i=
n
> this regard.
>=20

OK, time to have a long explanation :

netdev_alloc_skb_ip_align() is doing the right thing, but it seems you
guys insist to invent a new private stuff.

I am only wondering if you really know why you do this.=20

Many drivers do have same requirements, so every driver should reinvent
the wheel ? Really this is beyond me.

Original code was aligning the buffer on a 32 bytes boundary (because o=
f
a hardware requirement on NIC, I only trust original code on this).

Then you want to change this to align buffer on this 32 bytes boundary
PLUS 2. What is this kind of new requirement ?=20

1) Hardware requirement really changed that much. (firmware changed on
NIC). If not using this new alignement, NIC doesnt work at all.

2) or Microblaze arch requires that IP header is aligned on a word
boundary to avoid unaligned traps in IP stack ? (like many arches)

If this is the latest requirement, then use standard mechanism.
skb data is naturally aligned on L1_CACHE_SIZE + SKB_PAD boundaries.
(32 bytes alignment)

netdev_alloc_skb_ip_align()() then skips 2 bytes to make skb data
aligned so that 2 + 14 (sizeof eth header) =3D 16 : IP header is aligne=
d
(modulo 16)

It just works. If not, we should correct it, please fill a bug report.

Thanks


