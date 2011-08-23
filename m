From: Julian Anastasov <ja@ssi.bg>
Subject: Re: [PATCH net-next] ipv4: one more case for non-local saddr in
 ICMP
Date: Tue, 23 Aug 2011 09:34:45 +0300 (EEST)
Message-ID: <alpine.LFD.2.00.1108230845510.1565@ja.ssi.bg>
References: <alpine.LFD.2.00.1108151857420.1481@ja.ssi.bg> <20110819.034354.219449243171613725.davem@davemloft.net> <20110820082048.GA15169@gondor.apana.org.au>
Mime-Version: 1.0
Content-Type: TEXT/PLAIN; charset=US-ASCII
Cc: David Miller <davem@davemloft.net>, netdev@vger.kernel.org
To: Herbert Xu <herbert@gondor.hengli.com.au>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ja.ssi.bg ([178.16.129.10]:60069 "EHLO ja.ssi.bg"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751595Ab1HWG3E (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 23 Aug 2011 02:29:04 -0400
In-Reply-To: <20110820082048.GA15169@gondor.apana.org.au>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>


	Hello,

On Sat, 20 Aug 2011, Herbert Xu wrote:

> On Fri, Aug 19, 2011 at 03:43:54AM -0700, David Miller wrote:
> > From: Julian Anastasov <ja@ssi.bg>
> > Date: Mon, 15 Aug 2011 19:21:23 +0300 (EEST)
> > 
> > > 
> > > 	May be there is one more case that we can avoid using
> > > non-local source for ICMP errors: xfrm_lookup, num_xfrms = 0 when
> > > reverse "Flow passes untransformed". Avoid using the input route
> > > if xfrm_lookup returns same dst.
> > > 
> > > Signed-off-by: Julian Anastasov <ja@ssi.bg>
> > > ---
> > > 
> > > 	In fact, should we use local IP in all cases when
> > > sending ICMP? I'm asking it for the following case:
> > > 
> > > 	Large packet is forwarded but is rejected with ICMP FRAG
> > > NEEDED. We usually send ICMP with local saddr instead of the
> > > original non-local destination. What is the role of
> > > this reverse check? May be after xfrm_decode_session_reverse
> > > we should use 'fl4_dec.saddr = fl4->saddr;' so that xfrm_lookup
> > > works with ICMP from local IP? What is right thing to do here?
> > > I don't see code that looks in the embedded header...
> > 
> > Well.. this relookup behavior is guided by a special transform state
> > XFRM_STATE_ICMP that the user must explicitly create IPSEC rules for.
> > 
> > Presumably they are going to add real transforms to such special IPSEC
> > rules, not create NOP ones with no transforms.  And if they do create
> > such IPSEC state with no transforms, perhaps the intention is to trigger
> > to use of the non-local source.
> > 
> > The whole thing revolves around how Herbert envisions people implementing
> > RFC4301 support using this new XFRM_STATE_ICMP thing.
> > 
> > Right?

	I see, RFC 4301 prescribes reverse check for ICMP errors
to reuse SA as a fallback mechanism. Even if we send ICMP packet via
some tunnel to the previous secure gateway, shouldn't the ICMP
receiver prefer to see our local IP as ICMP sender?

> The intention of XFRM_STATE_ICMP is to automatically allow inbound
> IPsec-protected ICMP packets (remember that IPsec tunnels are not
> automatically allowed, as that opens room for address spoofing).
> 
> Imagine if you have a policy P that allows IPsec packets with inner
> addresses going from S to D.  The purpose of this is to ensure that
> ICMP packets from D to S are automatically allowed.

	OK, thanks for the information! I don't have setup for
further tests, I hope things still work somehow, even if we
fallback to unprotected ICMP with non-local source which was
the only concern for me. I think, using local IP for ICMP packets
is preferred to help firewalling.

	I just notice that if original packet (say TCP) hits
"fwd" policy, for the locally generated ICMP error we call
xfrm_lookup with sk = NULL and it always uses "out" dir
for the flow_cache_lookup call to search for this reverse SA.
So, we must be prepared with rules in "out" dir even for
the forwarding case? icmp flag in "fwd" rules is not considered?

Regards

--
Julian Anastasov <ja@ssi.bg>
