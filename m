From: <Shyam_Iyer@Dell.com>
Subject: RE: [PATCH] net: fix skb_seq_read returning wrong offset/length for page frag data
Date: Mon, 18 May 2009 18:32:29 +0530
Message-ID: <46A00B48CC54E4468EF6911F877AC4CA02294B56@blrx3m10.blr.amer.dell.com>
References: <65FDECA153DE9A40B78CA281949AC88902A9FBF1@ausx3mps309.aus.amer.dell.com>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="US-ASCII"
Content-Transfer-Encoding: 8BIT
Cc: <michaelc@cs.wisc.edu>, <davem@davemloft.net>
To: <Thomas_Chenault@Dell.com>, <netdev@vger.kernel.org>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ausc60pc101.us.dell.com ([143.166.85.206]:29919 "EHLO
	ausc60pc101.us.dell.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753916AbZERNLv convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 18 May 2009 09:11:51 -0400
Content-class: urn:content-classes:message
In-Reply-To: <65FDECA153DE9A40B78CA281949AC88902A9FBF1@ausx3mps309.aus.amer.dell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Chenault, Thomas
> Sent: Thursday, May 14, 2009 7:03 AM
> To: 'netdev@vger.kernel.org'
> Cc: Iyer, Shyam; 'michaelc@cs.wisc.edu'
> Subject: [PATCH] net: fix skb_seq_read returning wrong offset/length
> for page frag data
> 
> When called with a consumed value that is less than skb_headlen(skb)
> bytes into a page frag, skb_seq_read() incorrectly returns an
> offset/length relative to skb->data. Ensure that data which should
come
> from a page frag does.
> 
> Signed-off-by: Thomas Chenault <thomas_chenault@dell.com>
> 
> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> index d152394..e505b53 100644
> --- a/net/core/skbuff.c
> +++ b/net/core/skbuff.c
> @@ -2288,7 +2288,7 @@ unsigned int skb_seq_read(unsigned int consumed,
> const u8 **data,
>  next_skb:
>  	block_limit = skb_headlen(st->cur_skb) + st->stepped_offset;
> 
> -	if (abs_offset < block_limit) {
> +	if (abs_offset < block_limit && !st->frag_data) {
>  		*data = st->cur_skb->data + (abs_offset - st-
> >stepped_offset);
>  		return block_limit - abs_offset;
>  	}

Tested-by: Shyam Iyer <shyam_iyer@dell.com>

We have seen this scenario affect iSCSI transactions(mainly login) with
BCM57710 10G Ethernet(bnx2x driver) card.

The iSCSI login errs because the iSCSI PDU header is wrongly read with a
wrong ITT value. This error in reading the PDU is seen with this card
because of the way the bnx2x driver pushes data to the frags with LRO
enabled (through skb->frags[n]).

Intel 10G(ixgbe driver) + LRO combination does not expose the issue and
the patch doesn't cause a regression either. I am not sure if this patch
will break other driver+card configurations.  

Dave - Does this patch needs more review or you want to queue it up to
your tree? I believe it is a critical bug fix.

-Shyam Iyer
