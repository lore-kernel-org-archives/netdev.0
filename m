From: "Steven J. Magnani" <steve@digidescorp.com>
Subject: Re: [PATCH] [V3] Add non-Virtex5 support for LL TEMAC driver
Date: Tue, 06 Apr 2010 15:03:43 -0500
Message-ID: <1270584223.3949.57.camel@iscandar.digidescorp.com>
References: <d9134316-bd07-46a8-91d4-c30f27baeb60@SG2EHSMHS007.ehs.local>
	 <1270502993.9013.36.camel@edumazet-laptop>
	 <2fefb2a2-d0dc-461d-ac8c-3e7d177b7cf8@VA3EHSMHS032.ehs.local>
	 <1270573233.2081.47.camel@edumazet-laptop>
	 <bf8eac92-5008-4c1f-9b99-0199e62436fa@SG2EHSMHS010.ehs.local>
	 <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com>
Reply-To: steve@digidescorp.com
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: John Linn <John.Linn@xilinx.com>,
	Eric Dumazet <eric.dumazet@gmail.com>, netdev@vger.kernel.org,
	linuxppc-dev@ozlabs.org, jwboyer@linux.vnet.ibm.com,
	john.williams@petalogix.com, michal.simek@petalogix.com,
	John Tyner <jtyner@cs.ucr.edu>
To: Grant Likely <grant.likely@secretlab.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.digidescorp.com ([66.244.163.200]:13325 "EHLO
	digidescorp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752187Ab0DFUDs (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 6 Apr 2010 16:03:48 -0400
Received: from [10.10.6.102] by digidescorp.com (Cipher SSLv3:RC4-MD5:128) (MDaemon PRO v10.1.1)
	with ESMTP id md50001246939.msg
	for <netdev@vger.kernel.org>; Tue, 06 Apr 2010 15:03:47 -0500
In-Reply-To: <k2mfa686aa41004061153q3d065924o9172b1cf6038d917@mail.gmail.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2010-04-06 at 12:53 -0600, Grant Likely wrote:

> Hold on.... BUFFER_ALIGN is being used to align the DMA buffer on a
> cache line boundary.  I don't think netdev_alloc_skb() makes any
> guarantees about how the start of the IP header lines up against cache
> line boundaries.  The amount of padding needed is not known until an
> skbuff is obtained from netdev_alloc_skb(), and
> netdev_alloc_skb_ip_align() can only handle a fixed size padding,
> 
> It doesn't look like netdev_alloc_skb_ip_align() is the right thing in
> this regard.

__netdev_alloc_skb reserves NET_SKB_PAD bytes which gets us cacheline
alignment on Microblaze. From include/linux/skbuff.h:

/*
 * The networking layer reserves some headroom in skb data (via
 * dev_alloc_skb). This is used to avoid having to reallocate skb data
when
 * the header has to grow. In the default case, if the header has to
grow
 * 32 bytes or less we avoid the reallocation.
 *
 * Unfortunately this headroom changes the DMA alignment of the
resulting
 * network packet. As for NET_IP_ALIGN, this unaligned DMA is expensive
 * on some architectures. An architecture can override this value,
 * perhaps setting it to a cacheline in size (since that will maintain
 * cacheline alignment of the DMA). It must be a power of 2.
 *
 * Various parts of the networking layer expect at least 32 bytes of
 * headroom, you should not reduce this.
 */
#ifndef NET_SKB_PAD
#define NET_SKB_PAD     32
#endif

If this doesn't work for some of the PPC variants with larger cache
lines, maybe one of the PPC header files needs to define NET_SKB_PAD?
And if we want to guard against possible future changes to the default
NET_SKB_PAD breaking Microblaze operation, maybe one of its headers
should define NET_SKB_PAD as well?

------------------------------------------------------------------------
 Steven J. Magnani               "I claim this network for MARS!
 www.digidescorp.com              Earthling, return my space modulator!"

 #include <standard.disclaimer>



