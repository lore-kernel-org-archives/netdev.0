From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [SCTP]: Always linearise packet on input
Date: Tue, 31 Oct 2006 09:36:54 -0500
Message-ID: <45475F86.6050309@hp.com>
References: <20061030071128.GA15715@gondor.apana.org.au> <20061029.234619.112618588.davem@davemloft.net> <1162258285.22597.33.camel@w-sridhar2.beaverton.ibm.com> <20061031030110.GA27427@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Sridhar Samudrala <sri@us.ibm.com>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:32419 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1423408AbWJaOg6 (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 09:36:58 -0500
To: Herbert Xu <herbert@gondor.apana.org.au>
In-Reply-To: <20061031030110.GA27427@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Herbert Xu wrote:
> Hi Sridhar:
> 
> On Mon, Oct 30, 2006 at 05:31:24PM -0800, Sridhar Samudrala wrote:
>> I think we currently assume atleast the SCTP header and the data
>> chunk header to be in the skb head.
>> But we do handle skbs with data in the frag_list.
>> Not sure about skb's with paged fragments.
> 
> You can't assume the chunk header to be in the head.  Think about what
> happens when some malicious person sends you a fragmented SCTP packet.
> 
>> Does XEN use frag_list or frags array?
> 
> Xen creates paged frags in domU=>dom0 or domU=>domU traffic.
> Of course frag_list can always occur as a result of IP fragmentation.
> 
>> Is there a simple way to simulate incoming packets with transport
>> headers and data in skb's frag_list/pages without having to use XEN.
> 
> You can use IP fragments to create them.
> 
> But the important thing is to work through the code.  Basically wherever
> you see things like skb_pull/skb->data without a preceding pskb_may_pull
> call, then you have a problem.

Wouldn't this in the end be equivalent to skb_linearize()?  I am trying to
think of a way do things without reallocating too much memory.

Yes, SCTP is really broken with regard to fragmented skbs.  In fact, I
have a test case that will crash the lksctp at will when receiving an IP fragmented
message.

The reason pskb_may_pull() is not a great solution IMO, is because we
may end up doing very large orders of allocations if someone decided to use 9000 MTU
on the first hop.  I can see things going bad on loopback with 16K MTU as well.

-vlad
