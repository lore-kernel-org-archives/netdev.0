From: Robert Olsson <Robert.Olsson@data.slu.se>
Subject: [PATCH] pktgen IPSEC 3/4: Introduce xfrm SAD only lookup
Date: Tue, 12 Jun 2007 15:30:15 +0200
Message-ID: <18030.40935.850541.752953@robur.slu.se>
References: <1181649373.4060.50.camel@localhost>
	<1181649628.4060.54.camel@localhost>
	<1181649715.4060.56.camel@localhost>
	<1181649791.4060.59.camel@localhost>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Content-Transfer-Encoding: 7bit
Cc: Robert Olsson <Robert.Olsson@data.slu.se>,
	David Miller <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	netdev@vger.kernel.org, James Morris <jmorris@namei.org>
To: hadi@cyberus.ca
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.slu.se ([130.238.96.70]:56849 "EHLO mx1.slu.se"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1754787AbXFLNiZ (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 12 Jun 2007 09:38:25 -0400
In-Reply-To: <1181649791.4060.59.camel@localhost>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org


jamal writes:
 > 3 of 4 ..

 >     [XFRM] Introduce standalone SAD lookup
 >     This allows other in-kernel functions to do SAD lookups.
 >     The only known user at the moment is pktgen.
 >     
 >     Signed-off-by: Jamal Hadi Salim <hadi@cyberus.ca>
 

 xfrm is not my area..... 

 Acked-by: Robert Olsson <robert.olsson@its.uu.se>

 Cheers
					--ro


 > 
 > diff --git a/include/net/xfrm.h b/include/net/xfrm.h
 > index 311f25a..79d2c37 100644
 > --- a/include/net/xfrm.h
 > +++ b/include/net/xfrm.h
 > @@ -920,6 +920,10 @@ extern struct xfrm_state *xfrm_state_find(xfrm_address_t *daddr, xfrm_address_t
 >  					  struct flowi *fl, struct xfrm_tmpl *tmpl,
 >  					  struct xfrm_policy *pol, int *err,
 >  					  unsigned short family);
 > +extern struct xfrm_state * xfrm_stateonly_find(xfrm_address_t *daddr,
 > +					       xfrm_address_t *saddr,
 > +					       unsigned short family,
 > +					       u8 mode, u8 proto, u32 reqid);
 >  extern int xfrm_state_check_expire(struct xfrm_state *x);
 >  extern void xfrm_state_insert(struct xfrm_state *x);
 >  extern int xfrm_state_add(struct xfrm_state *x);
 > diff --git a/net/xfrm/xfrm_state.c b/net/xfrm/xfrm_state.c
 > index 85f3f43..b8562e4 100644
 > --- a/net/xfrm/xfrm_state.c
 > +++ b/net/xfrm/xfrm_state.c
 > @@ -686,6 +686,41 @@ out:
 >  	return x;
 >  }
 >  
 > +struct xfrm_state *
 > +xfrm_stateonly_find(xfrm_address_t *daddr, xfrm_address_t *saddr,
 > +		    unsigned short family, u8 mode, u8 proto, u32 reqid)
 > +{
 > +	unsigned int h = xfrm_dst_hash(daddr, saddr, reqid, family);
 > +	struct xfrm_state *rx = NULL, *x = NULL;
 > +	struct hlist_node *entry;
 > +
 > +	spin_lock(&xfrm_state_lock);
 > +	hlist_for_each_entry(x, entry, xfrm_state_bydst+h, bydst) {
 > +		if (x->props.family == family &&
 > +		    x->props.reqid == reqid &&
 > +		    !(x->props.flags & XFRM_STATE_WILDRECV) &&
 > +		    xfrm_state_addr_check(x, daddr, saddr, family) &&
 > +		    mode == x->props.mode &&
 > +		    proto == x->id.proto)  {
 > +
 > +			if (x->km.state != XFRM_STATE_VALID)
 > +					continue;
 > +			else {
 > +				rx = x;
 > +				break;
 > +			}
 > +		}
 > +	}
 > +
 > +	if (rx)
 > +		xfrm_state_hold(rx);
 > +	spin_unlock(&xfrm_state_lock);
 > +
 > +
 > +	return rx;
 > +}
 > +EXPORT_SYMBOL(xfrm_stateonly_find);
 > +
 >  static void __xfrm_state_insert(struct xfrm_state *x)
 >  {
 >  	unsigned int h;
