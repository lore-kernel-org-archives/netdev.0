From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [SCTP]: Always linearise packet on input
Date: Tue, 31 Oct 2006 13:46:03 -0500
Message-ID: <454799EB.7040800@hp.com>
References: <20061030071128.GA15715@gondor.apana.org.au>	 <20061029.234619.112618588.davem@davemloft.net>	 <1162258285.22597.33.camel@w-sridhar2.beaverton.ibm.com>	 <20061031030110.GA27427@gondor.apana.org.au>  <45475F86.6050309@hp.com> <1162318708.3884.17.camel@w-sridhar2.beaverton.ibm.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
Cc: Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from atlrel6.hp.com ([156.153.255.205]:7075 "EHLO atlrel6.hp.com")
	by vger.kernel.org with ESMTP id S1423784AbWJaSqH (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 31 Oct 2006 13:46:07 -0500
To: Sridhar Samudrala <sri@us.ibm.com>
In-Reply-To: <1162318708.3884.17.camel@w-sridhar2.beaverton.ibm.com>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

Sridhar Samudrala wrote:
> On Tue, 2006-10-31 at 09:36 -0500, Vlad Yasevich wrote:
>> Herbert Xu wrote:
>>> Hi Sridhar:
>>>
>>> On Mon, Oct 30, 2006 at 05:31:24PM -0800, Sridhar Samudrala wrote:
>>>> I think we currently assume atleast the SCTP header and the data
>>>> chunk header to be in the skb head.
>>>> But we do handle skbs with data in the frag_list.
>>>> Not sure about skb's with paged fragments.
>>> You can't assume the chunk header to be in the head.  Think about what
>>> happens when some malicious person sends you a fragmented SCTP packet.
>>>
>>>> Does XEN use frag_list or frags array?
>>> Xen creates paged frags in domU=>dom0 or domU=>domU traffic.
>>> Of course frag_list can always occur as a result of IP fragmentation.
>>>
>>>> Is there a simple way to simulate incoming packets with transport
>>>> headers and data in skb's frag_list/pages without having to use XEN.
>>> You can use IP fragments to create them.
>>>
>>> But the important thing is to work through the code.  Basically wherever
>>> you see things like skb_pull/skb->data without a preceding pskb_may_pull
>>> call, then you have a problem.
>> Wouldn't this in the end be equivalent to skb_linearize()?  I am trying to
>> think of a way do things without reallocating too much memory.
> It will be equivalent only if you pass a skb->data_len as the length to 
> pskb_may_pull(). However, pskb_may_pull() is generally called with much 
> smaller lengths equal to a specific header length and it tries to copy
> the header from the fragments to skb->tail if there is enough room.

Well, this stuff accumulates eventually.  Also what happens if the multiple
chunks are bundled and fragmented?  You end up doing pskb_may_pull() on
the whole first chunk which can cause reallocation, which gets very expensive.

> 
>> Yes, SCTP is really broken with regard to fragmented skbs.  In fact, I
>> have a test case that will crash the lksctp at will when receiving an IP fragmented
>> message.
> 
> Because we support path mtu, we should not see ip fragmentation in general although 
> it is possible if there is a change in path mtu during a transfer. So i guess you may
> be trying your test with path mtu disabled and with very small MTUs(< 500) or 
> a packet with bundled chunks.

The problem happens with the MTU of 512.  If I run over loopback, I can get it to happen
when dropping mtu to 1500.   The test simulates real world wireless network used between
cellular towers.

> 
>> The reason pskb_may_pull() is not a great solution IMO, is because we
>> may end up doing very large orders of allocations if someone decided to use 9000 MTU
>> on the first hop.  I can see things going bad on loopback with 16K MTU as well.
> pskb_may_pull() should be used only to pull in the headers, not the
> entire message to the skb head. But with small messages that are
> bundled, this may get complicated.

Yes,  this is the problem that I can reproduce.  If I end up bundling multiple
messages, at the same time as IP mtu drops, we end up with IP fragmentation and
a crash on the receiver.

My temporary solution has also been a skb_linearize(), but I've been trying to
get away from that.

-vlad
