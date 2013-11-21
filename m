From: Saurabh Mohan <saurabh.mohan@brocade.com>
Subject: RE: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not
 ipsec pkt
Date: Thu, 21 Nov 2013 10:35:54 -0800
Message-ID: <1902752B0C92F943AB7EA9EE13E2DEEC1273BA9AC7@HQ1-EXCH02.corp.brocade.com>
References: <1383646612-30103-1-git-send-email-christophe.gouault@6wind.com>
 <1383725153-26298-1-git-send-email-christophe.gouault@6wind.com>
 <20131121121246.GD31491@secunet.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "David S. Miller" <davem@davemloft.net>,
	Herbert Xu <herbert@gondor.apana.org.au>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Sergei Shtylyov <sergei.shtylyov@cogentembedded.com>,
	Eric Dumazet <eric.dumazet@gmail.com>
To: Steffen Klassert <steffen.klassert@secunet.com>,
	Christophe Gouault <christophe.gouault@6wind.com>,
	"Fan Du (fan.du@windriver.com)" <fan.du@windriver.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0a-000f0801.pphosted.com ([67.231.144.122]:47999 "EHLO
	mx0a-000f0801.pphosted.com" rhost-flags-OK-OK-OK-OK)
	by vger.kernel.org with ESMTP id S1754218Ab3KUSgL convert rfc822-to-8bit
	(ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 21 Nov 2013 13:36:11 -0500
Received: from pps.filterd (m0000542 [127.0.0.1])
	by mx0a-000f0801.pphosted.com (8.14.5/8.14.5) with SMTP id rALIJaki004690
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 10:36:10 -0800
Received: from hq1wp-exchub01.corp.brocade.com ([144.49.131.13])
	by mx0a-000f0801.pphosted.com with ESMTP id 1g9aytrmnq-3
	(version=TLSv1/SSLv3 cipher=AES128-SHA bits=128 verify=NOT)
	for <netdev@vger.kernel.org>; Thu, 21 Nov 2013 10:36:10 -0800
In-Reply-To: <20131121121246.GD31491@secunet.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Steffen Klassert [mailto:steffen.klassert@secunet.com]
> Sent: Thursday, November 21, 2013 4:13 AM
> To: Christophe Gouault
> Cc: David S. Miller; Herbert Xu; netdev@vger.kernel.org; Saurabh Mohan;
> Sergei Shtylyov; Eric Dumazet
> Subject: Re: [PATCH net v3] vti: fix spd lookup: match plaintext pkt, not ipsec
> pkt
> 
> On Wed, Nov 06, 2013 at 09:05:53AM +0100, Christophe Gouault wrote:
> >
> > @@ -133,7 +134,13 @@ static int vti_rcv(struct sk_buff *skb)
> >  		 * only match policies with this mark.
> >  		 */
> >  		skb->mark = be32_to_cpu(tunnel->parms.o_key);
> > +		/* The packet is decrypted, but not yet decapsulated.
> > +		 * Temporarily make network_header point to the inner
> header
> > +		 * for policy check.
> > +		 */
> > +		skb_reset_network_header(skb);
> >  		ret = xfrm4_policy_check(NULL, XFRM_POLICY_IN, skb);
> 
> If we do it like this, we would do an input policy check even for
> packets that should be forwarded. I think that's a bit odd.
> 
> If we really change to match plaintext traffic, we should do
> it like Fan Du proposed. Remove the policy check here and
> let the further layers do the policy enforcement. All we
> have to do is to set the skb mark, then the lookup should
> match the vti policy.
> 
> It is already clear that this packet was IPsec transformed
> when it enters vti_rcv, so deferring the policy check should
> be ok.

Agreed. The right thing to do here is apply the vti mark
and then let xfrm policy check match the clear packet with
the vti-mark on it.
The side-effect is that we'll lose the old mark.
