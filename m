From: Vlad Yasevich <vladislav.yasevich@hp.com>
Subject: Re: [RFC] sctp/tcp: Question -- ICMPv4 length check (not) redundant?
Date: Mon, 28 Jul 2008 13:27:46 -0400
Message-ID: <488E0192.9030406@hp.com>
References: <20080727045121.GA419@gondor.apana.org.au> <20080728112527.GB7589@gerrit.erg.abdn.ac.uk> <488DC63A.3070309@hp.com> <20080728170846.GB3762@gerrit.erg.abdn.ac.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=ISO-8859-1
Content-Transfer-Encoding: 7bit
To: Gerrit Renker <gerrit@erg.abdn.ac.uk>,
	Vlad Yasevich <vladislav.yasevich@hp.com>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	David Miller <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from g4t0016.houston.hp.com ([15.201.24.19]:22673 "EHLO
	g4t0016.houston.hp.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1760059AbYG1R1u (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 28 Jul 2008 13:27:50 -0400
In-Reply-To: <20080728170846.GB3762@gerrit.erg.abdn.ac.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

Gerrit Renker wrote:
> | >  * only TCP/SCTP seem to have a proper per-protocol "payload too short" test;
> | 
> | Hm..  In the standard case, these do seem to be redundant since 8 bytes are required
> | by ICMP spec.
> | 
> | >  * for DCCP, the work is actually doubled since 
> | >    - first the ICMP handler tests for minimally 8 bytes, 
> | >    - then the DCCP error handler tests for required minimum of 12 bytes.
> | 
> | DCCP and any other protocol that requires more error data should check for it in
> | its own handler.  8 bytes should be guaranteed to such handler.
> | 
> | What am I missing?
> | 
> As per last message, please disregard the patch suggestion made at the
> beginning of the thread.
> 
> In TCP, the 8 bytes happen to be enough for doing sequence number checks. Other
> protocols have different header lengths and semantics. Thus doing the checks
> at the transport layer makes more sense than in the ICMP handler.
> 
> RFC 1122 is almost 20 years old, from a time before IPcomp, SCTP, or DCCP.

So the suggestion really is then to remove the length check icmp_unreach()?

Because as it stands right now, the protocol error handler will not be invoked
if we don't have the iphdr + 8 bytes worth of data.  That's is actually a requirement
from the ICMP rfc 792.

Seems that not including those 8 bytes is a violation of that spec.  So, icmp_unreach()
should keep current code and jump to out_err upon failure.

Each upper layer protocol that requires additional space, should validate the existence
of that additional space and handle it appropriately.

It doesn't matter that IPcomp header is only 4 bytes.  ICMP error requires ihlen + 8 bytes and 
at least that much should be provided  Otherwise, it a malformed ICMP packet.

-vlad

