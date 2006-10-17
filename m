From: Evgeniy Polyakov <johnpol@2ka.mipt.ru>
Subject: Re: PATCH zero-copy send completion callback
Date: Tue, 17 Oct 2006 17:13:46 +0400
Message-ID: <20061017131345.GA20225@2ka.mipt.ru>
References: <021a01c6f1ea$c45e1820$0281a8c0@ebpc>
Mime-Version: 1.0
Content-Type: text/plain; charset=koi8-r
Cc: "'David Miller'" <davem@davemloft.net>, netdev@vger.kernel.org
Return-path: <netdev-owner@vger.kernel.org>
Received: from relay.2ka.mipt.ru ([194.85.82.65]:37029 "EHLO 2ka.mipt.ru")
	by vger.kernel.org with ESMTP id S1750890AbWJQNNv (ORCPT
	<rfc822;netdev@vger.kernel.org>); Tue, 17 Oct 2006 09:13:51 -0400
To: Eric Barton <eeb@bartonsoftware.com>
Content-Disposition: inline
In-Reply-To: <021a01c6f1ea$c45e1820$0281a8c0@ebpc>
Sender: netdev-owner@vger.kernel.org
List-Id: netdev.vger.kernel.org

On Tue, Oct 17, 2006 at 01:50:04PM +0100, Eric Barton (eeb@bartonsoftware.com) wrote:
> Evgeniy,
> 
> > You can use existing skb destructor and appropriate reference
> > counter is already there. In your own destructor you need to
> > call old one of course, and it's type can be determined from
> > the analysis of the headers and skb itself (there are not so
> > much destructor's types actually).  If that level of
> > abstraction is not enough, it is possible to change
> > skb_release_data()/__kfree_skb() so that it would be possible
> > in skb->destructor() to determine if attached pages will be
> > freed or not.
> 
> Yes absolutely.  My first thought was to use the skbuf destructor
> but I was paranoid I might screw up the destructor stacking.
> Maybe I should have been braver?

It depends on the results quality...

> Since the callback descriptor needs to track the pages in
> skb_shinfo() rather than the skbuf itself, it seemed "natural"
> to make skb_release_data() the trigger.
> 
> > Existing sendfile() implementation is synchronous, it does not
> > require async callback. 
> 
> Is it not true that you cannot know when it is safe to overwrite
> pages sent in this way?

There are tricks all over the place in sendfile. First one is sendpage()
imeplementation, which copies data if hardware does not support
checksumming and scater-gather, and simultaneous writing is "protected" in
the higher layer (check do_generic_mapping_read()). We do not care about
'later' writing, i.e. while skb was in some queue on the local machine,
since new data will be transferred in that case.
truncation is also protected by the fact, that page's reference counter
is increased, so the same page can not be freed and reused.

It was design decision not to care about page overwrites (and thus no
page locking) - either smart hardware transfers new data, or we do copy 
and send old data.

> > skbs are allocated from own cache, and the smaller it is, the better.
> 
> As I mentioned in another reply, skbs are indeed allocated from
> their own cache, but skb_shinfo() is allocated contiguously with
> the packet header using kmalloc.

Yes, skb itself is not touched.

You probably saw a lot of discussions about problems with e1000
hardware, memory fragmentation and jumbo frames.
Since skb_shared_info is added to the actual data, it frequently forces
next order allocations, so one of the solution is to put skb_shared_info
into separate allocations in some cases, although those discussions are
sleeping right now, problem still exists and if your current needs can
be handled within existing interfaces it should be tried first.

> -- 
> 
>                 Cheers,
>                         Eric
> 

-- 
	Evgeniy Polyakov
