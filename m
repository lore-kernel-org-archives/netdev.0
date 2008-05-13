From: David Miller <davem@davemloft.net>
Subject: Re: [RFC/T] [NET] make pskb_expand_head warn when called with
 invalid state
Date: Mon, 12 May 2008 22:11:14 -0700 (PDT)
Message-ID: <20080512.221114.127758510.davem@davemloft.net>
References: <1209924962.3655.8.camel@johannes.berg>
	<1210002047.8245.31.camel@johannes.berg>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org, herbert@gondor.apana.org.au
To: johannes@sipsolutions.net
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:35738
	"EHLO sunset.davemloft.net" rhost-flags-OK-FAIL-OK-OK)
	by vger.kernel.org with ESMTP id S1756058AbYEMFLU (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 13 May 2008 01:11:20 -0400
In-Reply-To: <1210002047.8245.31.camel@johannes.berg>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Johannes Berg <johannes@sipsolutions.net>
Date: Mon, 05 May 2008 17:40:47 +0200

> On Sun, 2008-05-04 at 20:16 +0200, Johannes Berg wrote:
> > This makes pskb_expand_head warn when called when a socket is attached.
>  
> > +	WARN_ON((nhead || ntail) && skb->sk);
> > +
> 
> This is triggering now. I think it's a false positive, trace below.

Hmmm, I wonder how you're getting this trace in the first
place :-)

> [23194.608074] Call Trace:
> [23194.608077] [ccf9bba0] [c02735a0] pskb_expand_head+0x58/0x1f8 (unreliable)
> [23194.608082] [ccf9bbc0] [c02737a4] __pskb_pull_tail+0x64/0x374
> [23194.608087] [ccf9bbf0] [c027b94c] dev_queue_xmit+0x1e4/0x3cc
> [23194.608093] [ccf9bc10] [c02a5c54] ip_finish_output+0x1e8/0x354
> [23194.608098] [ccf9bc30] [c02a61b0] ip_local_out+0x34/0x48
> [23194.608104] [ccf9bc40] [c02a699c] ip_queue_xmit+0x1fc/0x38c
> [23194.608109] [ccf9bcc0] [c02b94d4] tcp_transmit_skb+0x454/0x878
> [23194.608115] [ccf9bcf0] [c02bbfb4] tcp_push_one+0x124/0x1f0
> [23194.608120] [ccf9bd10] [c02b014c] tcp_sendpage+0x6ec/0x6f4
> [23194.608125] [ccf9bd80] [c0269ec0] sock_sendpage+0x34/0x44
> [23194.608130] [ccf9bd90] [c00c6dc8] pipe_to_sendpage+0x84/0xa4
> [23194.608136] [ccf9bdc0] [c00c802c] __splice_from_pipe+0x118/0x290
> [23194.608142] [ccf9be00] [c00c8328] splice_from_pipe+0x64/0x8c
> [23194.608147] [ccf9be40] [c00c72d4] do_splice_from+0x80/0x9c
> [23194.608152] [ccf9be60] [c00c7aac] splice_direct_to_actor+0xb8/0x1e0
> [23194.608158] [ccf9bea0] [c00c7c18] do_splice_direct+0x44/0x80
> [23194.608163] [ccf9bed0] [c00a0494] do_sendfile+0x1ec/0x2b0
> [23194.608169] [ccf9bf10] [c00a0740] sys_sendfile+0xb4/0x108
> [23194.608174] [ccf9bf40] [c00124cc] ret_from_syscall+0x0/0x38

There are only a few ways this code path can happen.

1) Route changed from a device with SG+CSUM capabilities to one
   which does not have those features.  I think you are not
   hitting such a case.

2) SKB is fraglist'd, but device lacks NETIF_F_FRAGLIST.  Since
   this is TCP, this case is also exceedingly unlikely.

If the device lacks SG, the sendpage path will use
sock_no_sendpage() instead of tcp_sendpage().  Since
tcp_sendpage() is in the backtrace, whatever device this
is must have NETIF_F_SG set.

Is this from a kernel with your GSO wireless patches applied by
chance? :-)


