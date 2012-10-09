From: Ian Campbell <Ian.Campbell@citrix.com>
Subject: Re: compound skb frag pages appearing in start_xmit
Date: Tue, 9 Oct 2012 15:54:34 +0100
Message-ID: <1349794474.21847.215.camel@zakaz.uk.xensource.com>
References: <1349790467.21847.185.camel@zakaz.uk.xensource.com>
	 <1349790863.21172.4406.camel@edumazet-glaptop>
	 <1349791305.21172.4425.camel@edumazet-glaptop>
	 <1349792617.21847.205.camel@zakaz.uk.xensource.com>
	 <1349793217.21172.4497.camel@edumazet-glaptop>
Mime-Version: 1.0
Content-Type: text/plain; charset="UTF-8"
Content-Transfer-Encoding: 7bit
Cc: Eric Dumazet <edumazet@google.com>,
	xen-devel <xen-devel@lists.xen.org>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	Konrad Rzeszutek Wilk <konrad@kernel.org>,
	Sander Eikelenboom <linux@eikelenboom.it>
To: Eric Dumazet <eric.dumazet@gmail.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from smtp.eu.citrix.com ([62.200.22.115]:25363 "EHLO
	SMTP.EU.CITRIX.COM" rhost-flags-OK-OK-OK-OK) by vger.kernel.org
	with ESMTP id S1753321Ab2JIOyh (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 9 Oct 2012 10:54:37 -0400
In-Reply-To: <1349793217.21172.4497.camel@edumazet-glaptop>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, 2012-10-09 at 15:33 +0100, Eric Dumazet wrote:
> On Tue, 2012-10-09 at 15:23 +0100, Ian Campbell wrote:
> > On Tue, 2012-10-09 at 15:01 +0100, Eric Dumazet wrote:
> > > On Tue, 2012-10-09 at 15:54 +0200, Eric Dumazet wrote:
> > > > On Tue, 2012-10-09 at 14:47 +0100, Ian Campbell wrote:
> > > > > Hi Eric,
> > > > > 
> > > > 
> > > > Hi Ian
> > > > 
> > > > > Sander has discovered an issue where xen-netback is given a compound
> > > > > page as one of the skb frag pages to transmit. Currently netback can
> > > > > only handle PAGE_SIZE'd frags and bugs out.
> > > > > 
> > > > > I suspect this is something to do with 69b08f62e174 "net: use bigger
> > > > > pages in __netdev_alloc_frag", although perhaps not because it looks
> > > > > like only tg3 uses it and Sander has an r8169. Also tg3 seems to only
> > > > > call netdev_alloc_frag for sizes < PAGE_SIZE. I'm probably missing
> > > > > something.
> > > > 
> > > > 
> > > > Its not the commit you want ;)
> > > 
> > > Hmm, I take it back. It also can give you the same problem :
> > > 
> > > We use this allocator for rx path of drivers : 
> > > 
> > >  __netdev_alloc_skb() 
> > > 
> > > So its now absolutely possible that one skb->head is backed by a order-3
> > > page.
> > > 
> > > Is the problem coming from xen_netbk_count_skb_slots() ?
> > > 
> > > Give me more information if you want me to help.
> > 
> > The interesting code is in netbk_gop_skb(), specifically the two calls
> > to netbk_gop_frag_copy.
> > 
> > netbk_gop_frag_copy can only copy order-0 pages to the peer since they
> > go over a shared ring transport which can only deal in order-0 pages.
> > 
> > For the SKB head there is a loop which handles order>0 heads, I suspect
> > we just need something similar for the frag case.
> > 
> > Although see my question in the other response about the maximum number
> > of frags we can have when order is > 0 since if using larger pages
> > causes us to end up with a much larger number of order-0 pages once
> > we've broken them up then we have a problem and I need to put my
> > thinking cap on a bit (perhaps substantially) tighter.
> > 
> > Konrad, it looks like netfront has a similar issue in
> > xennet_make_frags() since it doesn't shatter large order mappings
> > either.
> 
> Hmm...
> 
> In theory, if a skb has 16+1 frags backed by compound pages, you could
> need ~48 order-0 frags.
> 
> (4098 bytes could need 1-4096-1 (3 frags))
> 
> In practice, it should be around ~17 order-0 frags as before.

Right, thanks. I think I can cope with that without needing to change
the PV protocol in any way.

Ian.
