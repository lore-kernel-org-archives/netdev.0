From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net-next v3 2/5] xen-netback: add support for IPv6
 checksum offload from guest
Date: Fri, 11 Oct 2013 11:09:47 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD013262E@AMSPEX01CL01.citrite.net>
References: <1381418733-20470-1-git-send-email-paul.durrant@citrix.com>
 <1381418733-20470-3-git-send-email-paul.durrant@citrix.com>
 <20131011100943.GE15556@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Wei Liu <wei.liu2@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:60534 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753491Ab3JKLKQ convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Fri, 11 Oct 2013 07:10:16 -0400
In-Reply-To: <20131011100943.GE15556@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: Wei Liu [mailto:wei.liu2@citrix.com]
> Sent: 11 October 2013 11:10
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; David Vrabel;
> Ian Campbell
> Subject: Re: [PATCH net-next v3 2/5] xen-netback: add support for IPv6
> checksum offload from guest
> 
> On Thu, Oct 10, 2013 at 04:25:30PM +0100, Paul Durrant wrote:
> [...]
> > -#define PKT_PROT_LEN    (ETH_HLEN + \
> > -			 VLAN_HLEN + \
> > -			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
> > -			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
> > +#define PKT_PROT_LEN 128
> 
> I'm not against changing this, but could you please add comment on why
> 128 is chosen.
> 

Hmm. I did mod the comment, but that change seems to have got lost somewhere.

> >
> [...]
> > +	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len))
> &&
> > +	       !done) {
> > +		switch (nexthdr) {
> > +		case IPPROTO_FRAGMENT: {
> > +			struct frag_hdr *hp = (void *)(skb->data + off);
> > +
> > +			header_size = skb->network_header +
> > +				off +
> > +				sizeof(struct frag_hdr);
> > +			maybe_pull_tail(skb, header_size);
> > +
> > +			nexthdr = hp->nexthdr;
> > +			off += 8;
> 
> Can you use sizeof(frag_hdr) instead of 8?
> 
> > +			break;
> > +		}
> > +		case IPPROTO_DSTOPTS:
> > +		case IPPROTO_HOPOPTS:
> > +		case IPPROTO_ROUTING: {
> > +			struct ipv6_opt_hdr *hp = (void *)(skb->data + off);
> > +
> > +			header_size = skb->network_header +
> > +				off +
> > +				sizeof(struct ipv6_opt_hdr);
> > +			maybe_pull_tail(skb, header_size);
> > +
> > +			nexthdr = hp->nexthdr;
> > +			off += ipv6_optlen(hp);
> > +			break;
> > +		}
> > +		case IPPROTO_AH: {
> > +			struct ip_auth_hdr *hp = (void *)(skb->data + off);
> > +
> > +			header_size = skb->network_header +
> > +				off +
> > +				sizeof(struct ip_auth_hdr);
> > +			maybe_pull_tail(skb, header_size);
> > +
> > +			nexthdr = hp->nexthdr;
> > +			off += (hp->hdrlen+2)<<2;
> > +			break;
> > +		}
> > +		case IPPROTO_TCP:
> > +		case IPPROTO_UDP:
> > +			found = true;
> > +			/* Fall through */
> > +		default:
> > +			done = true;
> > +			break;
> 
> The above 'switch' doesn't seem to cover all IPPROTO_*. Will it cause
> the loop to exit too early? In other words, does any IPPROTO_* not
> listed above marks the end of parsing?
> 

AFAIK, hitting anything not in that switch would mean we don't have a TCP or UDP packet. I think the original code structure made that clearer so I'm going to go back to that.

> [...]
> >  	unsigned long now = jiffies;
> > @@ -1428,12 +1598,7 @@ static int xenvif_tx_submit(struct xenvif *vif, int
> budget)
> >
> >  		xenvif_fill_frags(vif, skb);
> >
> > -		/*
> > -		 * If the initial fragment was < PKT_PROT_LEN then
> > -		 * pull through some bytes from the other fragments to
> > -		 * increase the linear region to PKT_PROT_LEN bytes.
> > -		 */
> > -		if (skb_headlen(skb) < PKT_PROT_LEN &&
> skb_is_nonlinear(skb)) {
> > +		if (skb_is_nonlinear(skb) && skb_headlen(skb) <
> PKT_PROT_LEN) {
> 
> This change is not necessary: the comment is useful, and swapping two
> operands of && doesn't have any effect.

Sorry, that was too much cutting and pasting around. I'll just ditch that hunk.

  Paul

> 
> Wei.
