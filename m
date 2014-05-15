From: David Laight <David.Laight@ACULAB.COM>
Subject: RE: [Xen-devel] xen-netfront possibly rides the rocket too often
Date: Thu, 15 May 2014 11:14:23 +0000
Message-ID: <063D6719AE5E284EB5DD2968C1650D6D17246536@AcuExch.aculab.com>
References: <537262AB.5010408@canonical.com> <5373C8D4.2010803@citrix.com>
 <1400143605.1006.1.camel@kazak.uk.xensource.com>
 <20140515110410.GD1117@zion.uk.xensource.com>
Mime-Version: 1.0
Content-Type: text/plain; charset="Windows-1252"
Content-Transfer-Encoding: 8BIT
Cc: Zoltan Kiss <zoltan.kiss@citrix.com>,
	Stefan Bader <stefan.bader@canonical.com>,
	"xen-devel@lists.xenproject.org" <xen-devel@lists.xenproject.org>,
	netdev <netdev@vger.kernel.org>
To: 'Wei Liu' <wei.liu2@citrix.com>,
	Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx0.aculab.com ([213.249.233.131]:32996 "HELO mx0.aculab.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with SMTP
	id S1751122AbaEOLOg convert rfc822-to-8bit (ORCPT
	<rfc822;netdev@vger.kernel.org>); Thu, 15 May 2014 07:14:36 -0400
Received: from mx0.aculab.com ([127.0.0.1])
 by localhost (mx0.aculab.com [127.0.0.1]) (amavisd-new, port 10024) with SMTP
 id 00526-09 for <netdev@vger.kernel.org>;
 Thu, 15 May 2014 12:14:26 +0100 (BST)
In-Reply-To: <20140515110410.GD1117@zion.uk.xensource.com>
Content-Language: en-US
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

From: Wei Liu
> On Thu, May 15, 2014 at 09:46:45AM +0100, Ian Campbell wrote:
> > On Wed, 2014-05-14 at 20:49 +0100, Zoltan Kiss wrote:
> > > On 13/05/14 19:21, Stefan Bader wrote:
> > > > We had reports about this message being seen on EC2 for a while but finally a
> > > > reporter did notice some details about the guests and was able to provide a
> > > > simple way to reproduce[1].
> > > >
> > > > For my local experiments I use a Xen-4.2.2 based host (though I would say the
> > > > host versions are not important). The host has one NIC which is used as the
> > > > outgoing port of a Linux based (not openvswitch) bridge. And the PV guests use
> > > > that bridge. I set the mtu to 9001 (which was seen on affected instance types)
> > > > and also inside the guests. As described in the report one guests runs
> > > > redis-server and the other nodejs through two scripts (for me I had to do the
> > > > two sub.js calls in separate shells). After a bit the error messages appear on
> > > > the guest running the redis-server.
> > > >
> > > > I added some debug printk's to show a bit more detail about the skb and got the
> > > > following (<length>@<offset (after masking off complete pages)>):
> > > >
> > > > [ 698.108119] xen_netfront: xennet: skb rides the rocket: 19 slots
> > > > [ 698.108134] header 1490@238 -> 1 slots
> > > > [ 698.108139] frag #0 1614@2164 -> + 1 pages
> > > > [ 698.108143] frag #1 3038@1296 -> + 2 pages
> > > > [ 698.108147] frag #2 6076@1852 -> + 2 pages
> > > > [ 698.108151] frag #3 6076@292 -> + 2 pages
> > > > [ 698.108156] frag #4 6076@2828 -> + 3 pages
> > > > [ 698.108160] frag #5 3038@1268 -> + 2 pages
> > > > [ 698.108164] frag #6 2272@1824 -> + 1 pages
> > > > [ 698.108168] frag #7 3804@0 -> + 1 pages
> > > > [ 698.108172] frag #8 6076@264 -> + 2 pages
> > > > [ 698.108177] frag #9 3946@2800 -> + 2 pages
> > > > [ 698.108180] frags adding 18 slots
> > > >
> > > > Since I am not deeply familiar with the networking code, I wonder about two things:
> > > > - is there something that should limit the skb data length from all frags
> > > >    to stay below the 64K which the definition of MAX_SKB_FRAGS hints?
> > > I think netfront should be able to handle 64K packets at most.
> >
> > Ah, maybe this relates to this fix from Wei?
> >
> 
> Yes, below patch limits SKB size to 64KB.  However the problem here is
> not SKB exceeding 64KB. The said SKB is acutally 43KB in size. The
> problem is that guest kernel is  using compound page so a frag which can
> be fit into one 4K page spans two 4K pages.  The fix seems to be
> coalescing SKB in frontend, but it will degrade performance.

Presumably the thing to do is copy the frag list into a locally allocated
list of 4k fragments.
Unless you can support having some fragments mapped and some local
there probably isn't much point in trying to maintain the fragment
boundaries.

	David
