From: Wei Liu <wei.liu2@citrix.com>
Subject: Re: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 12:04:10 +0100
Message-ID: <20140515110410.GD1117@zion.uk.xensource.com>
References: <537262AB.5010408@canonical.com>
 <5373C8D4.2010803@citrix.com>
 <1400143605.1006.1.camel@kazak.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="us-ascii"
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	<xen-devel@lists.xenproject.org>, netdev <netdev@vger.kernel.org>,
	Wei Liu <wei.liu2@citrix.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.citrix.com ([66.165.176.89]:37660 "EHLO SMTP.CITRIX.COM"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751098AbaEOLEL (ORCPT <rfc822;netdev@vger.kernel.org>);
	Thu, 15 May 2014 07:04:11 -0400
Content-Disposition: inline
In-Reply-To: <1400143605.1006.1.camel@kazak.uk.xensource.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Thu, May 15, 2014 at 09:46:45AM +0100, Ian Campbell wrote:
> On Wed, 2014-05-14 at 20:49 +0100, Zoltan Kiss wrote:
> > On 13/05/14 19:21, Stefan Bader wrote:
> > > We had reports about this message being seen on EC2 for a while but finally a
> > > reporter did notice some details about the guests and was able to provide a
> > > simple way to reproduce[1].
> > >
> > > For my local experiments I use a Xen-4.2.2 based host (though I would say the
> > > host versions are not important). The host has one NIC which is used as the
> > > outgoing port of a Linux based (not openvswitch) bridge. And the PV guests use
> > > that bridge. I set the mtu to 9001 (which was seen on affected instance types)
> > > and also inside the guests. As described in the report one guests runs
> > > redis-server and the other nodejs through two scripts (for me I had to do the
> > > two sub.js calls in separate shells). After a bit the error messages appear on
> > > the guest running the redis-server.
> > >
> > > I added some debug printk's to show a bit more detail about the skb and got the
> > > following (<length>@<offset (after masking off complete pages)>):
> > >
> > > [ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
> > > [ 698.108134] header 1490@238 -> 1 slots
> > > [ 698.108139] frag #0 1614@2164 -> + 1 pages
> > > [ 698.108143] frag #1 3038@1296 -> + 2 pages
> > > [ 698.108147] frag #2 6076@1852 -> + 2 pages
> > > [ 698.108151] frag #3 6076@292 -> + 2 pages
> > > [ 698.108156] frag #4 6076@2828 -> + 3 pages
> > > [ 698.108160] frag #5 3038@1268 -> + 2 pages
> > > [ 698.108164] frag #6 2272@1824 -> + 1 pages
> > > [ 698.108168] frag #7 3804@0 -> + 1 pages
> > > [ 698.108172] frag #8 6076@264 -> + 2 pages
> > > [ 698.108177] frag #9 3946@2800 -> + 2 pages
> > > [ 698.108180] frags adding 18 slots
> > >
> > > Since I am not deeply familiar with the networking code, I wonder about two things:
> > > - is there something that should limit the skb data length from all frags
> > >    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
> > I think netfront should be able to handle 64K packets at most.
> 
> Ah, maybe this relates to this fix from Wei?
> 

Yes, below patch limits SKB size to 64KB.  However the problem here is
not SKB exceeding 64KB. The said SKB is acutally 43KB in size. The
problem is that guest kernel is  using compound page so a frag which can
be fit into one 4K page spans two 4K pages.  The fix seems to be
coalescing SKB in frontend, but it will degrade performance.

Wei.
