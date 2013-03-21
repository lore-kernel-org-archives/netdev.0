From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] [PATCH 2/4] xen-netfront: drop skb when skb->len >
 65535
Date: Thu, 21 Mar 2013 13:40:08 +0000
Message-ID: <1363873208.2160.13.camel@zion.uk.xensource.com>
References: <1363602955-24790-1-git-send-email-wei.liu2@citrix.com>
	 <1363602955-24790-3-git-send-email-wei.liu2@citrix.com>
	 <51471AAC.2050509@citrix.com>
	 <1363614500.30193.47.camel@zakaz.uk.xensource.com>
	 <51471DE0.9060506@citrix.com> <514A15C8.1050209@citrix.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: <wei.liu2@citrix.com>, Ian Campbell <Ian.Campbell@citrix.com>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"annie.li@oracle.com" <annie.li@oracle.com>,
	"konrad.wilk@oracle.com" <konrad.wilk@oracle.com>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>
To: David Vrabel <david.vrabel@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:29834 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1757033Ab3CUNkK (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 21 Mar 2013 09:40:10 -0400
In-Reply-To: <514A15C8.1050209@citrix.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Wed, 2013-03-20 at 20:02 +0000, David Vrabel wrote:

> >  		first->size -= txp->size;
> > @@ -938,6 +949,12 @@ static int netbk_count_requests(struct xenvif *vif,
> >  			return -EINVAL;
> >  		}
> >  	} while ((txp++)->flags & XEN_NETTXF_more_data);
> > +
> > +	if (drop) {
> > +		netbk_tx_err(vif, txp, idx + frags);
> 
> This needs to be netbk_tx_err(vif, first, idx + frags) or the guest will
> crash as we push a bunch of invalid responses.
> 

Can this really handle the situation when first->size overflows? In that
case frag == 0, the netbk_tx_err call is in fact netbk_tx_err(vif, txp,
idx). idx is the ring index of first txp, so in fact you're only
responding to the head txp, ignoring other tx requests for the same skb?

Even first->size doesn't overflow, a malicious / buggy frontend can
still generate tx req that makes txp->size > first->size. In that case
there could be also some trailing tx requests left un-responded.

I check the code before XSA-39 fix, its logic is more or less the same,
but it did work. My suspicion is that those trailing tx requests are
invalidated in future loops of xen_netbk_tx_build_gops.

I think the correct action is to just take first txp and loop responding
until we consume the whole packet.


Wei.


> David
> 
> > +		return -EIO;
> > +	}
> > +
> >  	return frags;
> >  }
> > 
> > @@ -1327,7 +1344,7 @@ static unsigned xen_netbk_tx_build_gops(struct
> > xen_netbk *netbk)
> >  				continue;
> >  		}
> > 
> > -		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do);
> > +		ret = netbk_count_requests(vif, &txreq, txfrags, work_to_do, idx);
> >  		if (unlikely(ret < 0))
> >  			continue;
