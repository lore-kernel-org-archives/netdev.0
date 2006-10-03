From: David Miller <davem@davemloft.net>
Subject: Re: rewriting skb->truesize... good or bad idea
Date: Tue, 03 Oct 2006 16:21:53 -0700 (PDT)
Message-ID: <20061003.162153.06584617.davem@davemloft.net>
References: <451D6319.1040506@hp.com>
	<20060929.143139.74560775.davem@davemloft.net>
	<45212652.5030505@hp.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from dsl027-180-168.sfo1.dsl.speakeasy.net ([216.27.180.168]:15594
	"EHLO sunset.davemloft.net") by vger.kernel.org with ESMTP
	id S1030676AbWJCXVu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 3 Oct 2006 19:21:50 -0400
To: vladislav.yasevich@hp.com
In-Reply-To: <45212652.5030505@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

From: Vlad Yasevich <vladislav.yasevich@hp.com>
Date: Mon, 02 Oct 2006 10:46:42 -0400

> David Miller wrote:
> > If, on the other hand, you know you have exclusive access to the
> > skb and there are no other references, setting skb->truesize can
> > be OK.  However setting it to sizeof(struct sk_buff) doesn't make
> > sense since there is at least:
> > 
> > 	sizeof(struct sk_buff) + sizeof(struct skb_shared_info)
> > 
> > memory assosciated with any SKB whatsoever in the kernel.  That is,
> > even for a "zero length" skb->data buffer, we still always allocate
> > the skb_shared_info area which must be accounted for.
> 
> Well, since we are dealing with clones of the original skb, I didn't
> think that we need to include skb_shared_info.  I thought that was
> accounted for in the original skb?

We use the original packet's truesize, as-is, when making
SKB clones.  This is our global policy.

The reason for that behavior is the usual case is that the
clone is being attached to a different socket than the
original SKB will.  And we very much should charge the memory
fully to every socket that references it.

In your case it seems that the memory is already charged to
the socket, and we would just be charging that memory again
to the same socket.  So in this very specific case, it should
be OK not to include skb_shared_info in the truesize calculation.

