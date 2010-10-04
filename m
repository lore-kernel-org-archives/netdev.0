From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv4 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook in xfrm_input()
Date: Mon, 04 Oct 2010 22:51:46 +0200
Message-ID: <87vd5h7kbh.fsf@small.ssi.corp>
References: <cover.1286139128.git.arno@natisbad.org>
	<db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org>
	<20101004084041.GB17939@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:48246 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S932568Ab0JDUvs (ORCPT <rfc822;netdev@vger.kernel.org>);
	Mon, 4 Oct 2010 16:51:48 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Mon, Oct 04, 2010 at 08:25:23AM +0200, Arnaud Ebalard wrote:
>> Add a hook in xfrm_input() to allow IRO remapping to occur when
>> an incoming packet matching an existing SA (based on SPI) with
>> an unexpected destination or source address is received.
>> Because IRO does not consume additional bits in a packet (that's
>> the point), there is no way to demultiplex based on something
>> like nh or spi. Instead, IRO input handlers (for source and
>> destination address remapping) are called upon address mismatch
>> during IPsec processing.
>> For that to work, we rely on the fact that SPI values generated
>> locally are no more linked to destination address (first patch
>> of the set) and we postpone a bit the expected address check in
>> xfrm_input() (inside xfrm_state_lookup() against daddr param) by
>> introducing a call to the input_addr_check() handler from the
>> struct xfrm_state_afinfo associated with the address family.
>> 
>> Signed-off-by: Arnaud Ebalard <arno@natisbad.org>
>
> I would prefer for this check to go into x->type->input since
> it does not apply to IPsec.

Either I don't understand the sentence or this is not feasible: the
thing is there is nothing in the packet to demultiplex like nh for
RH2/HAO. Here, we only lookup for a remapping state when there is a
mismatch in the source/destination addresses expected for the SA.

That's the reason IRO remapping states only apply to IPsec traffic.

> Just because the SPI is unique for inbound SAs, it doesn't mean
> that we should ignore the destination IP address in the packet for
> IPsec.

I don't ignore it. Before the change, for input IPsec traffic, the SA
lookup is done as follows:

  - SA lookup based mostly on SPI
  - Destination address check (done simultaneously during lookup)
    fatal if mismatch

After the change, there are three steps for IPv6:

  - SA lookup based on SPI
  - Destination Address check
      mismatch => lookup for destination remapping state 
                  call for associated input handler
                  fatal if mismatch
  - Source Address check
      mismatch => lookup for source remapping state
                  call for associated input handler

Explanation makes it looks more complex than it is:

 - IPv4 IPsec is basically untouched
 - IPv6 IPsec is basically untouched when CONFIG_XFRM_SUB_POLICY is not
   enabled,  
 - when CONFIG_XFRM_SUB_POLICY is enabled additional work is done only
   for IPv6 upon address mismatch.

> I think another way of getting what you want is to simply add
> inbound SAs with a zero destination address in your case which
> can then be made to match any destination IP address.  You can
> then follow that up with additional checks in x->type->input.

The idea is to allow the optimization for unmodified IPsec SA
(between stable addresses, i.e. HoA). Updating IRO src/dst remapping
states allow changing the src/dst on-wire address for unmodifed SA w/o
the need to explicitly add RH2 and/or HAO. Additionally, because source
and destination remapping are not linked, your proposal would not solve
the source remapping case, would it? 

Thanks for your feedback and patience, Herbert!

Cheers,

a+

