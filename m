From: Sridhar Samudrala <sri@us.ibm.com>
Subject: Re: [SCTP]: Always linearise packet on input
Date: Tue, 31 Oct 2006 10:18:27 -0800
Message-ID: <1162318708.3884.17.camel@w-sridhar2.beaverton.ibm.com>
References: <20061030071128.GA15715@gondor.apana.org.au>
	 <20061029.234619.112618588.davem@davemloft.net>
	 <1162258285.22597.33.camel@w-sridhar2.beaverton.ibm.com>
	 <20061031030110.GA27427@gondor.apana.org.au>  <45475F86.6050309@hp.com>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from e4.ny.us.ibm.com ([32.97.182.144]:29110 "EHLO e4.ny.us.ibm.com")
	by vger.kernel.org with ESMTP id S1423761AbWJaSSl (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 13:18:41 -0500
Received: from d01relay02.pok.ibm.com (d01relay02.pok.ibm.com [9.56.227.234])
	by e4.ny.us.ibm.com (8.13.8/8.12.11) with ESMTP id k9VIIexY031098
	for <netdev@vger.kernel.org>; Tue, 31 Oct 2006 13:18:40 -0500
Received: from d01av04.pok.ibm.com (d01av04.pok.ibm.com [9.56.224.64])
	by d01relay02.pok.ibm.com (8.13.6/8.13.6/NCO v8.1.1) with ESMTP id k9VIIe2r225936
	for <netdev@vger.kernel.org>; Tue, 31 Oct 2006 13:18:40 -0500
Received: from d01av04.pok.ibm.com (loopback [127.0.0.1])
	by d01av04.pok.ibm.com (8.12.11.20060308/8.13.3) with ESMTP id k9VIIZ2x030321
	for <netdev@vger.kernel.org>; Tue, 31 Oct 2006 13:18:36 -0500
To: Vlad Yasevich <vladislav.yasevich@hp.com>
In-Reply-To: <45475F86.6050309@hp.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, 2006-10-31 at 09:36 -0500, Vlad Yasevich wrote:
> Herbert Xu wrote:
> > Hi Sridhar:
> > 
> > On Mon, Oct 30, 2006 at 05:31:24PM -0800, Sridhar Samudrala wrote:
> >> I think we currently assume atleast the SCTP header and the data
> >> chunk header to be in the skb head.
> >> But we do handle skbs with data in the frag_list.
> >> Not sure about skb's with paged fragments.
> > 
> > You can't assume the chunk header to be in the head.  Think about what
> > happens when some malicious person sends you a fragmented SCTP packet.
> > 
> >> Does XEN use frag_list or frags array?
> > 
> > Xen creates paged frags in domU=>dom0 or domU=>domU traffic.
> > Of course frag_list can always occur as a result of IP fragmentation.
> > 
> >> Is there a simple way to simulate incoming packets with transport
> >> headers and data in skb's frag_list/pages without having to use XEN.
> > 
> > You can use IP fragments to create them.
> > 
> > But the important thing is to work through the code.  Basically wherever
> > you see things like skb_pull/skb->data without a preceding pskb_may_pull
> > call, then you have a problem.
> 
> Wouldn't this in the end be equivalent to skb_linearize()?  I am trying to
> think of a way do things without reallocating too much memory.
It will be equivalent only if you pass a skb->data_len as the length to 
pskb_may_pull(). However, pskb_may_pull() is generally called with much 
smaller lengths equal to a specific header length and it tries to copy
the header from the fragments to skb->tail if there is enough room.

> 
> Yes, SCTP is really broken with regard to fragmented skbs.  In fact, I
> have a test case that will crash the lksctp at will when receiving an IP fragmented
> message.

Because we support path mtu, we should not see ip fragmentation in general although 
it is possible if there is a change in path mtu during a transfer. So i guess you may
be trying your test with path mtu disabled and with very small MTUs(< 500) or 
a packet with bundled chunks.

> 
> The reason pskb_may_pull() is not a great solution IMO, is because we
> may end up doing very large orders of allocations if someone decided to use 9000 MTU
> on the first hop.  I can see things going bad on loopback with 16K MTU as well.
pskb_may_pull() should be used only to pull in the headers, not the
entire message to the skb head. But with small messages that are
bundled, this may get complicated.

Thanks
Sridhar

