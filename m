From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Wed, 5 Nov 2008 16:47:03 -0800
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60F56@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
	 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
 <1225838743.6116.20.camel@fry>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Evgeniy Polyakov <zbr@ioremap.net>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:11887 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752044AbYKFArO convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Wed, 5 Nov 2008 19:47:14 -0500
In-Reply-To: <1225838743.6116.20.camel@fry>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>



> -----Original Message-----
> From: Johann Baudy [mailto:johaahn@gmail.com]
> Sent: November-04-08 2:46 PM
> To: Lovich, Vitali
> Cc: netdev@vger.kernel.org; Evgeniy Polyakov
> Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> This won't work if your network card doesn't support Scatter/Gather IO.
> Indeed, when SG is not supported, fragmented packets are linearized
> after dev_queue_xmit() call. Thus addresses of pages are then lost.
> 
> Best regards,
> Johann
Hi Johann, 
Actually, I believe it still will.  There's only two cases that can occur if the device doesn't support scatter gather: dev_queue_xmit linearizes, or it fails (e.g. too much payload - can't reallocate contiguous portion of skb).

The relevant code is in __pskb_pull_tail of net/core/skbuff.c (note how delta = skb->data_len when called from skb_linearize).

If it linearizes, then great - the actual fragments aren't actually modified (note how eat will be 0, so it won't update the frag list in __pskb_pull_tail).
If it doesn't, then dev_queue_xmit fails, then it won't have touched the fragments either.

In either case, the skb given to the destructor will still have the correct values for fragments we specified.  Of course, this is based on 2 assumptions:

1.  Nothing further down the line won't add fragments, thereby overwriting frags[0]
2.  No-one writes to frags[0].page & frags[0].page_offset

1 is reasonable because since the only reason we would be linearizing in the first place is if the device doesn't support scatter/gather, so it would be strange for something down the line to add more fragments that would have to be linearized anyways.

2 is reasonable since it would only make sense if something down the line used this as a temporary variable storage, which again should be unlikely.

Another approach may be to store it in the cb as we had done so originally, except with skb_clone to ensure no other layers overwrite it, although I'm not 100% sure of the implications of skb_clone has for things like the cb & users fields and kfree_skb.
