From: arno@natisbad.org (Arnaud Ebalard)
Subject: Re: [PATCHv4 net-next-2.6 4/5] XFRM,IPv6: Add IRO remapping hook in xfrm_input()
Date: Wed, 06 Oct 2010 01:28:42 +0200
Message-ID: <878w2cfcd1.fsf@small.ssi.corp>
References: <cover.1286139128.git.arno@natisbad.org>
	<db067c0a2ab679dfb16c84e8509e671fa6c5cb01.1286139129.git.arno@natisbad.org>
	<20101004084041.GB17939@gondor.apana.org.au>
	<87vd5h7kbh.fsf@small.ssi.corp>
	<20101005062732.GA27337@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: "David S. Miller" <davem@davemloft.net>,
	Eric Dumazet <eric.dumazet@gmail.com>,
	Hideaki YOSHIFUJI <yoshfuji@linux-ipv6.org>,
	netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from copper.chdir.org ([88.191.97.87]:34647 "EHLO copper.chdir.org"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1757666Ab0JEX1q (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 5 Oct 2010 19:27:46 -0400
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Hi,

Herbert Xu <herbert@gondor.apana.org.au> writes:

> On Mon, Oct 04, 2010 at 10:51:46PM +0200, Arnaud Ebalard wrote:
>> 
>> Either I don't understand the sentence or this is not feasible: the
>> thing is there is nothing in the packet to demultiplex like nh for
>> RH2/HAO. Here, we only lookup for a remapping state when there is a
>> mismatch in the source/destination addresses expected for the SA.
>> 
>> That's the reason IRO remapping states only apply to IPsec traffic.
>
> I see.
>
> The thing that bugs me is that you've added an indirect call for
> all IPsec traffic when only MIPv6 users would ever need this.

The destination address check is always done by the IPsec stack and
usually results in a direct drop if/when it fails. I just replace the
direct drop by some a possible recovery (a state lookup and a possible
remapping). The change does not impact standard IPsec users.

Regarding the source address check, I indeed add an additional memcmp()
with some additional work when there is an address mismatch. From a
performance standpoint, I *think* it does not change much: removing the
address from the hash computation for the lookup should balance the
comparison.

I made some pretty lame performance test with ... dd and nc. Two boxes,
both w/ gigabit intel cards connected via a Gigabit switch. The receiver
runs current net-next-2.6, and has static IPv6/IPv4 SA/SP (transport
mode ESP using AES):

 1) First, current net-next-2.6 (no patches applied)
 2) then, with my patches applied and CONFIG_XFRM_SUB_POLICY enabled
 3) then, with my patches applied and CONFIG_XFRM_SUB_POLICY disabled

I use dd and netcat6 on the source to send 1GB of data to the receiver
over TCP (over IPv4 and then IPv6) for the various flavours of kernel
above (on the receiver):

 dd if=/dev/zero bs=1024 count=1048576 | nc -x <receiverip> 1234

receiver has

 nc -x -l -p 1234 > /dev/null

The (lack of) results are (reported by dd, 3 runs each time):

 1) IPv4: 33.5760s (32.0 MB/s)   IPv6  29.0952s (36.9 MB/s)
          28.1210s (38.2 MB/s)         31.7187s (33.9 MB/s)
          29.6547s (36.2 MB/s)         30.6551s (35.0 MB/s)

 2) IPv4: 29.4168s (36.5 MB/s)   IPv6: 30.8944s (34.8 MB/s)
          28.6593s (37.5 MB/s)         30.0922s (35.7 MB/s)
          30.1222s (35.6 MB/s)         30.1781s (35.6 MB/s)

 3) IPv4: 31.0125s (34.6 MB/s)   IPv6: 31.6964s (33.9 MB/s)
          28.8677s (37.2 MB/s)         30.1182s (35.7 MB/s)
          30.4820s (35.2 MB/s)         30.4874s (35.2 MB/s)

I expected (hoped) additional processing time to somewhat add up and
appear in the final result but I think I will need to decrease the
rest of processing to prove you right :-) I'd be happy to do some
tests if you point me better tools or good parameters to do that
(use UDP?, change MTU?, NULL enc?, more runs? ...). 

> With your remapping, would it be possible to add dummy xfrm_state
> objects with the remapped destination address that could then call
> xfrm6_input_addr?
>
> That way normal IPsec users would not be affected at all while
> preserving your new functionality.

I don't think I can do that easily (at all?) with what XFRM provides,
can I? Or at least I don't see how it is possible because I would need
some kind of policy for the state to be applied and the only trigger I
see is the src/dst address mismatch when processing the IPsec packet.

Ideally, one could think the perfect solution would be to use the SPI
and associate a remapping state to it but I already dropped that one
because SPI tracking is simply a broken idea. Among the problems: you
need to update on rekeying, you can only install the remapping state
after SA is installed, ... The problem is that it is not stable, unlike
the addresses of the SA I use in current proposal.

Cheers,

a+
