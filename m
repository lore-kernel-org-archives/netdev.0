From: Patrick Ohly <patrick.ohly@intel.com>
Subject: Re: TX time stamping
Date: Wed, 25 Mar 2009 08:08:44 +0100
Message-ID: <1237964924.26966.310.camel@pohly-MOBL>
References: <1236105081.4653.68.camel@pohly-MOBL>
	 <20090319.140509.152824531.davem@davemloft.net>
	 <20090320021050.GA7021@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain
Content-Transfer-Encoding: 7bit
Cc: "netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"Kirsher, Jeffrey T" <jeffrey.t.kirsher@intel.com>
To: David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mga11.intel.com ([192.55.52.93]:59163 "EHLO mga11.intel.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1756261AbZCYHIu (ORCPT <rfc822;netdev@vger.kernel.org>);
	Wed, 25 Mar 2009 03:08:50 -0400
In-Reply-To: <20090320021050.GA7021@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hello Dave, Herbert!

On Fri, 2009-03-20 at 02:10 +0000, Herbert Xu wrote: 
> On Thu, Mar 19, 2009 at 02:05:09PM -0700, David Miller wrote:
> >
> > Instead, we have a half-working turd in a tree, and I'm removing it.
> 
> Yes, we need to spend a bit more time pondering the semantics
> of all this.

Agreed. It never was the goal to somehow force this into the kernel
unless you are happy with it - not that this would have worked
anyway ;-) I'd be happy to discuss better ways of solving these issues;
the current patches work, but they have their shortcomings. There's no
point in including them when you don't deem them sufficient.

As I said in my initial email in this thread, I don't know a better
solution and depend on some guidance by experts in this area. When I
didn't get a reply to that email I thought that the current solution had
been accepted, but clearly that wasn't the case. I have had a patch
ready for the TX software time stamping for a while (the third point of
my email), but that doesn't address the main reason why you are unhappy
about the patches.

> First of all, if a packet bifurcates and is transmitted through
> two interfaces both capable of timestamping, which event do we
> take as the timestamp of the original packet?

I suggest to make it so that the sender gets the packet back once per
interface, with different time stamps and information about the
interface.

> As to the problem of skb->sk, I don't think that's even needed
> as we can simply use the skb shared area as the communication
> medium.

Can you elaborate on that?

I still think we need to ensure that only the sender is told about the
send time stamp and the associated packet data. Is there perhaps a
unique integer ID for each socket, or is adding it acceptable (a running
count basically)?

In that case we could do something like this: 
      * when sending a packet with TX request, add the socket ID 
      * clear skb->sk 
      * after generating the TX time stamp, try to find the socket by
        ID 
              * if it is found, send packet back with additional info
                like it is done now
              * if not, discard information because the sender is gone 

The drawback is the more costly socket lookup. For PTP this isn't an
issue due to the low packet rate, so a very simple solution would be
good enough. But for other use cases it might be problematic. I also
have no idea how the locking for the socket lookup can be done safely.

-- 
Best Regards, Patrick Ohly

The content of this message is my personal opinion only and although
I am an employee of Intel, the statements I make here in no way
represent Intel's position on the issue, nor am I authorized to speak
on behalf of Intel on this matter.


