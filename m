From: "Paul Moore" <paul.moore@centrify.com>
Subject: RE: xfrm selector generating IKE
Date: Tue, 24 Feb 2009 18:07:06 -0800
Message-ID: <BB7E16A14DE689469A181EC770AFBF4D02C5BC01@exch-one.centrify.com>
References: <BB7E16A14DE689469A181EC770AFBF4D02A7775E@exch-one.centrify.com> <20090130063048.GA4702@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BA6E@exch-one.centrify.com> <20090224020839.GC18696@gondor.apana.org.au> <BB7E16A14DE689469A181EC770AFBF4D02C5BAE1@exch-one.centrify.com> <20090225003330.GA29906@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: text/plain;
	charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: <kaber@trash.net>, <davem@davemloft.net>, <netdev@vger.kernel.org>
To: "Herbert Xu" <herbert@gondor.apana.org.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mail.centrify.com ([216.112.107.103]:20540 "EHLO
	exch-one.centrify.com" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1753011AbZBYCHJ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 24 Feb 2009 21:07:09 -0500
Content-class: urn:content-classes:message
In-Reply-To: <20090225003330.GA29906@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

You seem to be saying that that if I explicitly set the policy reqids
that it should work. 

I had experimented with that a lot 

The problem is that I cannot find a good combination of reqids 

I want to say - "for this subnet all ftp auth (port 21)  traffic is
encrypted"
I am testing between RedHat 5 and Windows

So I have 4 rules (all specifying esp transport mode)


// for outbound connections
subnet -> subnet[21] out
subnet[21] -> subnet in
// for inbound connections
subnet[21] -> subnet out
subnet -> subnet[21] in


So how to set the reqids - what would you suggest I set?

a) just say unique and let the kernel allocate a new reqid each time (or
explicitly put different reqid on each rule)
you would think that this would work but it does not
outbound connection works
inbound connection does not - see below for why it fails
even when the inbound connection is the first thing you do
I can fix this behavior by reordering the SPD
If I move the last 'in' to be before the first 'in' then inbound
connection works
There is no logical reason why I should have to reorder the rules like
that
and it doesn't feel very deterministic to me. 

why does it fail, because __xfrm_policy_check does
xfrm_sk_policy_lookup. This matches the flow to a policy, since the SAs
making up the flow do not have selectors then ports are ignored in the
lookup. So the lookup matches the first one with matching dir and
addresses. In the initial ordering of rules it returns #2 but the SPI it
is checking against was built using #4 - xfrm_state_ok rejects it -> SOL
If I reorder the rules then its OK.
However the inverse case must also exist, where it needs to find other
inbound policy. I just cant find the test case yet

b) set both in rules to 1 (say) and both out rules to 2 (say)
inbound connection works because both inbound rules have same reqid and
so we avoid (a) case
outbound connection after inbound connection done fails because it tries
to reuse the outbound SA setup by the inbound connection (both have the
same reqid) but the remote system (windows) thinks that that SA is for
inbound traffic from 21 (which it is) and so discards the packets

c) set both port src 21 rules to 1 and both dest 21 rules to 2
this fails like (a) 



BTW all works fine after I change af_key.c to accept port numbers from
sadb_address and copy to SA selector - dont need any reqids


