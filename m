From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [PATCH net-next v2 2/5] xen-netback: Add support for IPv6
 checksum offload from guest
Date: Tue, 8 Oct 2013 17:19:25 +0100
Message-ID: <20131008161925.GL28411@zion.uk.xensource.com>
References: <1381229896-18657-1-git-send-email-paul.durrant@citrix.com>
 <1381229896-18657-3-git-send-email-paul.durrant@citrix.com>
 <20131008133045.GI28411@zion.uk.xensource.com>
 <9AAE0902D5BC7E449B7C8E4E778ABCD012F345@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Wei Liu <wei.liu2@citrix.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	David Vrabel <david.vrabel@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:25593 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1753131Ab3JHQT0 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 8 Oct 2013 12:19:26 -0400
Content-Disposition: inline
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD012F345@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Oct 08, 2013 at 02:50:27PM +0100, Paul Durrant wrote:
[...]
> > > -#define PKT_PROT_LEN    (ETH_HLEN + \
> > > -			 VLAN_HLEN + \
> > > -			 sizeof(struct iphdr) + MAX_IPOPTLEN + \
> > > -			 sizeof(struct tcphdr) + MAX_TCP_OPTION_SPACE)
> > > +#define PKT_PROT_LEN 128
> > >
> > 
> > Where does 128 come from?
> > 
> 
> It's just an arbitrary power of 2 that was chosen because it seems to
> cover most likely v6 headers and all v4 headers.
> 

Hmm... How about using the value of MAX_TCP_HEADER? I guess that can
cover all V4 / V6 headers.

MAX_TCP_HEADER varies, depending on configuration. To make sure we can
accommodate all guests packet we might need to use its maximum value
which can be as big as 128 + 128 + 48.

> > >  		if (recalculate_partial_csum) {
> > >  			struct tcphdr *tcph = tcp_hdr(skb);
> > > +
> > > +			header_size = skb->network_header +
> > > +				off +
> > > +				sizeof(struct tcphdr) +
> > > +				MAX_TCP_OPTION_SPACE;
> > > +			maybe_pull_tail(skb, header_size);
> > > +
> > 
> > I presume this function is checksum_setup stripped down to handle IPv4
> > packet. What's the purpose of changing its behaviour? Why the pull_tail
> > here?
> > 
> 
> We have to make sure that the TCP header is in the linear area as we
> are about to write to the checksum field. In practice, the 128 byte
> pull should guarantee this but in case that is varied later I wanted
> to make sure things did not start to fail in an add way.
> 

If you already set the pull size to maximum possible value then this
will not be necessary anymore, right?

> > > +	while ((off <= sizeof(struct ipv6hdr) + ntohs(ipv6h->payload_len))
> > &&
> > > +	       !done) {
> > > +		/* We only access at most the first 2 bytes of any option
> > header
> > > +		 * to determine the next one.
> > > +		 */
> > > +		header_size = skb->network_header + off + 2;
> > > +		maybe_pull_tail(skb, header_size);
> > > +
> > 
> > Will this cause performance problem? Is it possible that you pull too
> > many times?
> > 
> 
> I guess it means we may get two pulls for the TCP/UDP headers rather
> than one so could push the pulls into the individual cases if you
> think it will affect performance that badly.

Hmm... Not sure I get what you mean here. The main problem I'm seeing is
that maybe_pull_tail is called in every loop.

I would like to see as few pulls as possible because __pskb_pull_tail
can be expensive and only expected to use in "exceptional cases" (quoted
from the comment above that function).

Is it possible to pull TCP_MAX_HEADER bytes once to eliminate all other
pulls in checksum_setup{,_ipv4,_ipv6}?

> 
[...]
> > 
> > Can you make the logic explicit here?
> > 
> >    case IPPROTO_TCP:
> >    case IPPROTO_UDP:
> >         done = true;
> > 	break;
> >    default:
> >         break;
> > 
> > Another minor suggestion is that change "done" to "found" because you're
> > trying to find the two type of headers.
> > 
> 
> Yes, I could code it that way if you prefer.
> 

Explicity is better than implicity IMHO. After this change could you
also move the default branch (netdev_err) in the following "switch" to
the first "switch".

Wei.
