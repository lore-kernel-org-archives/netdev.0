From: Patrick McHardy <kaber@trash.net>
Subject: Re: [PKT_SCHED]: Add stateless NAT
Date: Fri, 28 Sep 2007 18:55:32 +0200
Message-ID: <46FD3204.6090305@trash.net>
References: <20070927073446.GA14643@gondor.apana.org.au>	<1190896785.4290.18.camel@localhost> <20070927.120803.39482469.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-15
Content-Transfer-Encoding: 7bit
Cc: hadi@cyberus.ca, herbert@gondor.apana.org.au,
	netdev@vger.kernel.org, kuznet@ms2.inr.ac.ru
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from stinky.trash.net ([213.144.137.162]:56460 "EHLO
	stinky.trash.net" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752933AbXI1Qzf (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 28 Sep 2007 12:55:35 -0400
In-Reply-To: <20070927.120803.39482469.davem@davemloft.net>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

David Miller wrote:
> From: jamal <hadi@cyberus.ca>
> Date: Thu, 27 Sep 2007 08:39:45 -0400
> 
>>>+config NET_ACT_NAT
>>>+        tristate "Stateless NAT"
>>>+        depends on NET_CLS_ACT
>>>+        select NETFILTER
>>
>>I am gonna have to agree with Evgeniy on this Herbert;->
>>The rewards are it will improve performance for people who dont need
>>netfilter.
> 
> 
> I agree that we should move the functions out.   However...
> 
> You have to realize that this logic is a complete crock
> of shit for %99.99999999999999999999 of Linux users out there
> who get and only use distribution compiled kernels which are
> going to enable everything anyways.
> 
> So we better make sure there are zero performance implications at some
> point just for compiling netfilter into the tree.  I know that isn't
> the case currently, but that means that we aren't helping out the
> majority of Linux users and are thus only adding these optimizations
> for such a small sliver of users and that is totally pointless and
> sucks.


The hooks themselves actually shouldn't be that much of a problem
since without any registered users they come down to a simple
list_empty check. The bigger problem is probably the fact that
the "okfn" is usually declared inline, but we also take its address
for nf_hook_slow, so at least with forced inlining, we end up
with one inlined and one out-of-line version.

Looking at ip_input.o as example (everything without forced inlining):

   text    data     bss     dec     hex filename
   2076       8       0    2084     824 net/ipv4/ip_input.o
   3483       8       0    3491     da3 net/ipv4/ip_input.o


So we have roughly 1.75 more code for the two hooks. For reference,
without using the function pointer it increases a lot less:

   text    data     bss     dec     hex filename
   2319       8       0    2327     917 net/ipv4/ip_input.o

similar with not inlining ip_rcv_finish() and ip_local_deliver_finish():

   text    data     bss     dec     hex filename
   2282       8       0    2290     8f2 net/ipv4/ip_input.o

Any ideas how to do this better? Unforunately we need the function
pointers for reinjecting queued packets ..
