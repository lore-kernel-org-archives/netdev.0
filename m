From: Ben Hutchings <bhutchings@solarflare.com>
Subject: Re: [PATCH net v3] xen-netback: fix fragment detection in checksum
 setup
Date: Mon, 2 Dec 2013 17:27:37 +0000
Message-ID: <1386005257.1516.20.camel@bwh-desktop.uk.level5networks.com>
References: <1385722328-32875-1-git-send-email-paul.durrant@citrix.com>
	 <20131130.161357.1101467615641418549.davem@davemloft.net>
	 <9AAE0902D5BC7E449B7C8E4E778ABCD019BC50@AMSPEX01CL01.citrite.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: David Miller <davem@davemloft.net>,
	"xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: Paul Durrant <Paul.Durrant@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from webmail.solarflare.com ([12.187.104.25]:44951 "EHLO
	webmail.solarflare.com" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1752837Ab3LBR1m (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 12:27:42 -0500
In-Reply-To: <9AAE0902D5BC7E449B7C8E4E778ABCD019BC50@AMSPEX01CL01.citrite.net>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Mon, 2013-12-02 at 09:45 +0000, Paul Durrant wrote:
> > -----Original Message-----
> > From: David Miller [mailto:davem@davemloft.net]
> > Sent: 30 November 2013 21:14
> > To: Paul Durrant
> > Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; Ian Campbell;
> > David Vrabel
> > Subject: Re: [PATCH net v3] xen-netback: fix fragment detection in checksum
> > setup
> > 
> > From: Paul Durrant <paul.durrant@citrix.com>
> > Date: Fri, 29 Nov 2013 10:52:08 +0000
> > 
> > > @@ -1166,15 +1166,27 @@ static int checksum_setup_ip(struct xenvif *vif,
> > struct sk_buff *skb,
> > >  	struct iphdr *iph = (void *)skb->data;
> > >  	unsigned int header_size;
> > >  	unsigned int off;
> > > +	bool fragment;
> > >  	int err = -EPROTO;
> > >
> > > +	fragment = false;
> > > +
> > >  	off = sizeof(struct iphdr);
> > >
> > >  	header_size = skb->network_header + off + MAX_IPOPTLEN;
> > >  	maybe_pull_tail(skb, header_size);
> > >
> > > +	if (iph->frag_off & htons(IP_OFFSET | IP_MF))
> > > +		fragment = true;
> > 
> > This function has a serious problem.
> > 
> > maybe_pull_tail() can change skb->data, therefore this "iph" pointer
> > can become invalid, you're essentially dereferencing garbage if
> > maybe_pull_tail() actually does any work.
> 
> Ok. Clearly I'm misunderstanding what __pskb_pull_tail() does then. I
> was under the impression that it moved skb->tail on but left skb->data
> alone (which is what I want to do). I will have another look.
[...]

A pull does not change the offset of skb->data but it may need to
expand, i.e. reallocate, the skb head area.  The kernel-doc states
clearly that this can happen.

Ben.

-- 
Ben Hutchings, Staff Engineer, Solarflare
Not speaking for my employer; that's the marketing department's job.
They asked us to note that Solarflare product names are trademarked.
