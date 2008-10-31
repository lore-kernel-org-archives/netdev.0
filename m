From: "Lovich, Vitali" <vlovich@qualcomm.com>
Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
Date: Fri, 31 Oct 2008 11:24:51 -0700
Message-ID: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CB5@NASANEXMB10.na.qualcomm.com>
References: <1225450706.5301.94.camel@localhost>
 <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>
To: Johann Baudy <johaahn@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from wolverine02.qualcomm.com ([199.106.114.251]:28313 "EHLO
	wolverine02.qualcomm.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1750822AbYJaSYy convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 31 Oct 2008 14:24:54 -0400
In-Reply-To: <FCC0EC655BD1AE408C047268D1F5DF4C3BA60CA2@NASANEXMB10.na.qualcomm.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: netdev-owner@vger.kernel.org [mailto:netdev-
> owner@vger.kernel.org] On Behalf Of Lovich, Vitali
> Sent: October-31-08 10:08 AM
> To: Johann Baudy
> Cc: netdev@vger.kernel.org
> Subject: RE: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> 
> 
> 
> > -----Original Message-----
> > From: Johann Baudy [mailto:johaahn@gmail.com]
> > Sent: October-31-08 3:58 AM
> > To: Lovich, Vitali
> > Cc: David Miller; netdev@vger.kernel.org
> > Subject: Re: [PATCH] Packet socket: mmapped IO: PACKET_TX_RING
> >
> > Hi Vitali,
> >
> > > There's no need to keep the index (packet_index).  Just store the
> > pointer directly (change it to void *) - saves an extra lookup.
> >
> > Indeed, it will be faster. I'll do the change.
> Actually, I just realized that we don't need to modify the sock_buff
> structure.  We're already filling in the fragments of the skb - just
> take the first fragment and reverse the process to determine the
> starting address of the frame.

Here's the code I came up with to determine the offset - anyone see any problems?

union {
   tpacket2_hdr *t2;
   u8 *raw;
}

struct page *first_frag;
u32 page_offset;

first_frag = skb_shinfo(skb)->frags[0].page;
page_offset = skb_shinfo(skb)->frags[0].page_offset;

page_offset -= (skb_headlen(skb) + sizeof(struct tpacket2_hdr));
if (unlikely(page_offset < 0)) {
	first_frag--;
	page_offset += PAGE_SIZE;
}
frame.raw = page_address(first_frag) + page_offset;

// rest of destructor
