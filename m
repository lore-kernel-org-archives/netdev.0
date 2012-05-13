From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [PATCH RFC 1/6] skbuff: support per-page destructors in
 copy_ubufs
Date: Sun, 13 May 2012 13:10:28 +0300
Message-ID: <20120513101028.GC23273@redhat.com>
References: <cover.1336397823.git.mst@redhat.com>
 <8a3235fbceef37758ef23169c4c152e8d1251d3b.1336397823.git.mst@redhat.com>
 <1336671977.14220.26.camel@zakaz.uk.xensource.com>
 <20120510184246.GE14647@redhat.com>
 <1336726800.23818.33.camel@zakaz.uk.xensource.com>
 <1336733892.23818.69.camel@zakaz.uk.xensource.com>
 <20120511120836.GA4637@redhat.com>
 <20120511163057.GB10344@redhat.com>
 <1336802484.3891.24.camel@dagon.hellion.org.uk>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: David Miller <davem@davemloft.net>,
	"netdev@vger.kernel.org" <netdev@vger.kernel.org>,
	"eric.dumazet@gmail.com" <eric.dumazet@gmail.com>
To: Ian Campbell <Ian.Campbell@citrix.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:63906 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1751254Ab2EMKK3 (ORCPT <rfc822;netdev@vger.kernel.org>);
	Sun, 13 May 2012 06:10:29 -0400
Content-Disposition: inline
In-Reply-To: <1336802484.3891.24.camel@dagon.hellion.org.uk>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Sat, May 12, 2012 at 07:01:24AM +0100, Ian Campbell wrote:
> On Fri, 2012-05-11 at 17:30 +0100, Michael S. Tsirkin wrote:
> > On Fri, May 11, 2012 at 03:08:36PM +0300, Michael S. Tsirkin wrote:
> > > On Fri, May 11, 2012 at 11:58:12AM +0100, Ian Campbell wrote:
> > > > On Fri, 2012-05-11 at 10:00 +0100, Ian Campbell wrote:
> > > > > I'm seeing copy_ubufs called in my remote NFS test, which I don't
> > > > > think I expected -- I'll investigate why this is happening today. 
> > > > 
> > > > It's tcp_transmit_skb which can (conditionally) call skb_clone
> > > > (backtrace below)
> > > 
> > > Interesting. I didn't realise we clone skbs on data path:
> > > tcp_write_xmit calls tcp_transmit_skb with clone_it flag.
> > > Could someone comment on why we need to clone on good path
> > > like this?
> > 
> > Hmm, it's in case we need to retransmit it later.
> 
> I wonder if we could avoid the copy_ubuf in this particular clone path
> and have any subsequent calls to copy_ubufs use skb->fclone to determine
> if it can safely replace the frags?
> 
> If it cannot then could it do a full copy of the skb (including new
> shinfo, new frag pages etc) as a fallback?
> 
> Ian.
> 

Yes I think we should call a variant of clone that avoids copy_ubuf on
the first transmit.  But need to be careful we don't access the frag
list while it is being modified.

For example very roughly, maybe we could have copy_ubuf detect
packet clone is queued and take some lock?

On retransmit we could check and if we are not the only clone left
(which should be uncommon) trigger copy ubuf then.

Thoughts?

-- 
MST
