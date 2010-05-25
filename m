From: Herbert Xu <herbert@gondor.apana.org.au>
Subject: Re: Question about an assignment in handle_ing()
Date: Tue, 25 May 2010 22:46:36 +1000
Message-ID: <20100525124636.GA13161@gondor.apana.org.au>
References: <20100524112236.GF2810@psychotron.lab.eng.brq.redhat.com> <1274781067.3878.872.camel@bigi> <20100525102603.GA11494@gondor.apana.org.au> <1274789024.3878.919.camel@bigi> <20100525121202.GA12712@gondor.apana.org.au> <1274790038.3878.926.camel@bigi>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: Jiri Pirko <jpirko@redhat.com>, netdev@vger.kernel.org,
	davem@davemloft.net, kaber@trash.net
To: jamal <hadi@cyberus.ca>
Return-path: <netdev-owner@vger.kernel.org>
Received: from ringil.hengli.com.au ([216.59.3.182]:48894 "EHLO
	arnor.apana.org.au" rhost-flags-OK-OK-OK-FAIL) by vger.kernel.org
	with ESMTP id S1752310Ab0EYMqu (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 25 May 2010 08:46:50 -0400
Content-Disposition: inline
In-Reply-To: <1274790038.3878.926.camel@bigi>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, May 25, 2010 at 08:20:38AM -0400, jamal wrote:
> On Tue, 2010-05-25 at 22:12 +1000, Herbert Xu wrote:
> 
> > It is guaranteed, it is illegal to hold onto the skb contents
> > without the reference that comes from cloning an skb.
> 
> As i recall this was an issue. And the example i described earlier
> would have tcpdump show edited contents coming out of eth0.

That's not very surprising as you're not checking whether the
skb is cloned in act_pedit.c:

	if (!(skb->tc_verd & TC_OK2MUNGE)) {
		/* should we set skb->cloned? */
		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
			return p->tcf_action;
		}
	}

This code needs to be changed to something like

	if (skb_cloned(skb)) {
		if (pskb_expand_head(skb, 0, 0, GFP_ATOMIC)) {
			return p->tcf_action;
		}
	}

BTW, this error handling also looks a bit suss.  Shouldn't it
drop the packet instead of continuing as if we have successfully
modified it?

Cheers,
-- 
Visit Openswan at http://www.openswan.org/
Email: Herbert Xu ~{PmV>HI~} <herbert@gondor.apana.org.au>
Home Page: http://gondor.apana.org.au/~herbert/
PGP Key: http://gondor.apana.org.au/~herbert/pubkey.txt
