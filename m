From: David Miller <davem@davemloft.net>
Subject: Re: [RFC net-next PATCH 0/4] qlge: Performance changes for qlge.
Date: Mon, 17 Aug 2009 17:57:00 -0700 (PDT)
Message-ID: <20090817.175700.207432952.davem@davemloft.net>
References: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Mime-Version: 1.0
Content-Type: Text/Plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: netdev@vger.kernel.org
To: ron.mercer@qlogic.com
Return-path: <netdev-owner@vger.kernel.org>
Received: from 74-93-104-97-Washington.hfc.comcastbusiness.net ([74.93.104.97]:41776
	"EHLO sunset.davemloft.net" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1751005AbZHRA4t (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 17 Aug 2009 20:56:49 -0400
In-Reply-To: <1250543329-15123-1-git-send-email-ron.mercer@qlogic.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Ron Mercer <ron.mercer@qlogic.com>
Date: Mon, 17 Aug 2009 14:08:45 -0700

> 1) Do TX completions in send path (with cleaner timer).

You should really do them in NAPI context.

When you do them from hardware interrupt context, they all
get rescheduled into a softirq for the real SKB freeing
work anyways.

So by doing it in NAPI poll, you're avoiding some needless
overhead.

BTW, it's insanely confusing that there is a function called
qlge_msix_tx_isr() that of all things does RX work :-/

> 2) Change RSS queue count to match MSIx vector count instead
>    of CPU count.  Some platforms didn't offer enough vectors
>    for our previous approach.

Ideally you want "max(num_msix_vectors, num_cpus)" because
if you hook up more MSIX vectors than you have cpus it's just
extra overhead and depending upon the descrepency between the
two counts it might unevenly distribute traffic work amongst
the cpus.

> 3) Change large RX buffer logic to use either multiple pages
>    or chunks of pages based on MTU and system page size.
> 
>    Examples:
> 
>    64k Pages with 1500 MTU.  The RX buffers size would be
>    2048 bytes and there would be 32 per page.
> 
>    4k pages with 9000 MTU.  The RX buffer size would be 16k,
>    or 4 pages per buffer.

This is wasteful, does the card have a mechnism by which it
can dynamically carve up pages depending upon the actual
frame size?

If anything, make sure that skb->truesize gets set to something
reasonable, or else TCP is going to reallocate SKBs when the
receive queue limits are hit.
