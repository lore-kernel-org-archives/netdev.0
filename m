From: Paul Durrant <Paul.Durrant@citrix.com>
Subject: RE: [PATCH net v3] xen-netback: fix fragment detection in checksum
 setup
Date: Mon, 2 Dec 2013 09:45:50 +0000
Message-ID: <9AAE0902D5BC7E449B7C8E4E778ABCD019BC50@AMSPEX01CL01.citrite.net>
References: <1385722328-32875-1-git-send-email-paul.durrant@citrix.com>
 <20131130.161357.1101467615641418549.davem@davemloft.net>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Content-Transfer-Encoding: 8BIT
Cc: "xen-devel@lists.xen.org" <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>,
	David Vrabel <david.vrabel@citrix.com>
To: David Miller <davem@davemloft.net>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp02.citrix.com ([66.165.176.63]:64174 "EHLO
	SMTP02.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753213Ab3LBJpx convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Mon, 2 Dec 2013 04:45:53 -0500
In-Reply-To: <20131130.161357.1101467615641418549.davem@davemloft.net>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

> -----Original Message-----
> From: David Miller [mailto:davem@davemloft.net]
> Sent: 30 November 2013 21:14
> To: Paul Durrant
> Cc: xen-devel@lists.xen.org; netdev@vger.kernel.org; Wei Liu; Ian Campbell;
> David Vrabel
> Subject: Re: [PATCH net v3] xen-netback: fix fragment detection in checksum
> setup
> 
> From: Paul Durrant <paul.durrant@citrix.com>
> Date: Fri, 29 Nov 2013 10:52:08 +0000
> 
> > @@ -1166,15 +1166,27 @@ static int checksum_setup_ip(struct xenvif *vif,
> struct sk_buff *skb,
> >  	struct iphdr *iph = (void *)skb->data;
> >  	unsigned int header_size;
> >  	unsigned int off;
> > +	bool fragment;
> >  	int err = -EPROTO;
> >
> > +	fragment = false;
> > +
> >  	off = sizeof(struct iphdr);
> >
> >  	header_size = skb->network_header + off + MAX_IPOPTLEN;
> >  	maybe_pull_tail(skb, header_size);
> >
> > +	if (iph->frag_off & htons(IP_OFFSET | IP_MF))
> > +		fragment = true;
> 
> This function has a serious problem.
> 
> maybe_pull_tail() can change skb->data, therefore this "iph" pointer
> can become invalid, you're essentially dereferencing garbage if
> maybe_pull_tail() actually does any work.

Ok. Clearly I'm misunderstanding what __pskb_pull_tail() does then. I was under the impression that it moved skb->tail on but left skb->data alone (which is what I want to do). I will have another look.

> 
> Secondly, do you really (even rate limited) want to span the system
> log just because some ipv4 fragmented frames end up here?  That
> doesn't make any sense to me.  Maybe bump a statistic or something
> like that, but a log message triggerable by a remote entity?  No way.

Ok.

  Paul
