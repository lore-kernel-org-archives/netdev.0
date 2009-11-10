From: "Michael S. Tsirkin" <mst@redhat.com>
Subject: Re: [RFC PATCH] net: add dataref destructor to sk_buff
Date: Tue, 10 Nov 2009 16:36:52 +0200
Message-ID: <20091110143652.GB19645@redhat.com>
References: <20091002141407.30224.54207.stgit@dev.haskins.net> <20091110115335.GC6989@redhat.com> <4AF919020200005A000586A9@sinclair.provo.novell.com> <20091110131722.GA19645@redhat.com> <4AF9747E.8020408@novell.com>
Mime-Version: 1.0
Content-Type: text/plain; charset=us-ascii
Cc: alacrityvm-devel@lists.sourceforge.net, herbert.xu@redhat.com,
	linux-kernel@vger.kernel.org, netdev@vger.kernel.org
To: Gregory Haskins <ghaskins@novell.com>
Return-path: <netdev-owner@vger.kernel.org>
Received: from mx1.redhat.com ([209.132.183.28]:36616 "EHLO mx1.redhat.com"
	rhost-flags-OK-OK-OK-OK) by vger.kernel.org with ESMTP
	id S1750811AbZKJOje (ORCPT <rfc822;netdev@vger.kernel.org>);
	Tue, 10 Nov 2009 09:39:34 -0500
Content-Disposition: inline
In-Reply-To: <4AF9747E.8020408@novell.com>
Sender: netdev-owner@vger.kernel.org
List-ID: <netdev.vger.kernel.org>

On Tue, Nov 10, 2009 at 09:11:10AM -0500, Gregory Haskins wrote:
> Michael S. Tsirkin wrote:
> > On Tue, Nov 10, 2009 at 05:40:50AM -0700, Gregory Haskins wrote:
> >>>>> On 11/10/2009 at  6:53 AM, in message <20091110115335.GC6989@redhat.com>,
> >> "Michael S. Tsirkin" <mst@redhat.com> wrote: 
> >>> On Fri, Oct 02, 2009 at 10:20:00AM -0400, Gregory Haskins wrote:
> >>>> (Applies to davem/net-2.6.git:4fdb78d30)
> >>>>
> >>>> Hi David, netdevs,
> >>>>
> >>>> The following is an RFC for an attempt at addressing a zero-copy solution.
> >>>>
> >>>> To be perfectly honest, I have no idea if this is the best solution, or if
> >>>> there is truly a problem with skb->destructor that requires an alternate
> >>>> mechanism.  What I do know is that this patch seems to work, and I would
> >>>> like to see some kind of solution available upstream.  So I thought I would
> >>>> send my hack out as at least a point of discussion.  FWIW: This has been
> >>>> tested heavily in my rig and is technically suitable for inclusion after
> >>>> review as is, if that is decided to be the optimal path forward here.
> >>>>
> >>>> Thanks for your review and consideration,
> >>>>
> >>>> Kind regards,
> >>>> -Greg
> >>>>
> >>>> ----------------------------------------
> >>>> From: Gregory Haskins <ghaskins@novell.com>
> >>>> Subject: [RFC PATCH] net: add dataref destructor to sk_buff
> >>>>
> >>>> What: The skb->destructor field is reportedly unreliable for ensuring
> >>>> that all shinfo users have dropped their references.  Therefore, we add
> >>>> a distinct ->release() method for the shinfo structure which is closely
> >>>> tied to the underlying page resources we want to protect.
> >>>>
> >>>> Why: We want to add zero-copy transmit support for AlacrityVM guests.
> >>>> In order to support this, the host kernel must map guest pages directly
> >>>> into a paged-skb and send it as normal.  put_page() alone is not
> >>>> sufficient lifetime management since the pages are ultimately allocated
> >>>> from within the guest.  Therefore, we need higher-level notification
> >>>> when the skb is finally freed on the host so we can then inject a proper
> >>>> "tx-complete" event into the guest context.
> >>>>
> >>>> Signed-off-by: Gregory Haskins <ghaskins@novell.com>
> >>>> ---
> >>>>
> >>>>  include/linux/skbuff.h |    2 ++
> >>>>  net/core/skbuff.c      |    9 +++++++++
> >>>>  2 files changed, 11 insertions(+), 0 deletions(-)
> >>>>
> >>>> diff --git a/include/linux/skbuff.h b/include/linux/skbuff.h
> >>>> index df7b23a..02cdab6 100644
> >>>> --- a/include/linux/skbuff.h
> >>>> +++ b/include/linux/skbuff.h
> >>>> @@ -207,6 +207,8 @@ struct skb_shared_info {
> >>>>  	/* Intermediate layers must ensure that destructor_arg
> >>>>  	 * remains valid until skb destructor */
> >>>>  	void *		destructor_arg;
> >>>> +	void *          priv;
> >>>> +	void           (*release)(struct sk_buff *skb);
> >>>>  };
> >>>>  
> >>>>  /* We divide dataref into two halves.  The higher 16 bits hold references
> >>>> diff --git a/net/core/skbuff.c b/net/core/skbuff.c
> >>>> index 80a9616..a7e40a9 100644
> >>>> --- a/net/core/skbuff.c
> >>>> +++ b/net/core/skbuff.c
> >>>> @@ -219,6 +219,8 @@ struct sk_buff *__alloc_skb(unsigned int size, gfp_t 
> >>> gfp_mask,
> >>>>  	shinfo->tx_flags.flags = 0;
> >>>>  	skb_frag_list_init(skb);
> >>>>  	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
> >>>> +	shinfo->release = NULL;
> >>>> +	shinfo->priv = NULL;
> >>>>  
> >>>>  	if (fclone) {
> >>>>  		struct sk_buff *child = skb + 1;
> >>>> @@ -350,6 +352,9 @@ static void skb_release_data(struct sk_buff *skb)
> >>>>  		if (skb_has_frags(skb))
> >>>>  			skb_drop_fraglist(skb);
> >>>>  
> >>>> +		if (skb_shinfo(skb)->release)
> >>>> +			skb_shinfo(skb)->release(skb);
> >>>> +
> >>>>  		kfree(skb->head);
> >>>>  	}
> >>>>  }
> >>>> @@ -514,6 +519,8 @@ int skb_recycle_check(struct sk_buff *skb, int skb_size)
> >>>>  	shinfo->tx_flags.flags = 0;
> >>>>  	skb_frag_list_init(skb);
> >>>>  	memset(&shinfo->hwtstamps, 0, sizeof(shinfo->hwtstamps));
> >>>> +	shinfo->release = NULL;
> >>>> +	shinfo->priv = NULL;
> >>>>  
> >>>>  	memset(skb, 0, offsetof(struct sk_buff, tail));
> >>>>  	skb->data = skb->head + NET_SKB_PAD;
> >>>> @@ -856,6 +863,8 @@ int pskb_expand_head(struct sk_buff *skb, int nhead, int 
> >>> ntail,
> >>>>  	skb->hdr_len  = 0;
> >>>>  	skb->nohdr    = 0;
> >>>>  	atomic_set(&skb_shinfo(skb)->dataref, 1);
> >>>> +	skb_shinfo(skb)->release = NULL;
> >>>> +	skb_shinfo(skb)->priv = NULL;
> >>>>  	return 0;
> >>>>  
> >>>>  nodata:
> >>> This is basically subset of the skb data destructors patch, isn't it?
> >> Sort of, but the emphasis is different.  Here are the main differences:
> >>
> >> 1) skb->destructor() is on the skb level, shinfo->release() is at the shared-info/page level
> >>
> >> 2) skb->destructor is (iiuc) modified during the skb's lifetime (for instance rmem hooks here to
> >> manage the buffer-space dynamically), whereas shinfo->release is designed to be used by
> >> "the owner" and is thus only set at creation.
> >>
> >> 3) shinfo->release tracks the lifetime of the pages, not the skb.  This means it transcends
> >> the skb's lifetime (such as splits for clone, etc) and focuses on the shared component: the pages
> > 
> > You are comparing with skb destructors, not skb data destructors :) skb
> > data destructor is Rusty's patch which he wanted to use for vringfd.  I
> > mean e.g. this:
> > http://lists.openwall.net/netdev/2008/04/18/7
> 
> Ah, I wasn't aware.  I believe Anthony Ligouri had pointed me at this
> same patch earlier this year.  However, more recently when I saw
> skb->destructor() in mainline (seemingly from Rusty), I thought it had
> been accepted and didn't investigate further.  I see now that you are
> talking about something else.
> 
> > 
> >>> Last time this was tried, this is the objection that was voiced:
> >>>
> >>> 	The problem with this patch is that it's tracking skb's, while
> >>> 	you want use it to track pages for zero-copy.  That just doesn't
> >>> 	work.  Through mechanisms like splice, individual pages in the
> >>> 	skb can be detached and metastasize to other locations, e.g.,
> >>> 	the VFS.
> >> Right, and I don't think this applies here because I specifically chose the shinfo level to try to properly
> >> track the page level avoid this issue.  Multiple skb's can point to a single shinfo, iiuc.
> > 
> > VFS does not know about shinfo either, does it?
> 
> I do not follow the reference.  Where does VFS come into play?

"Through mechanisms like splice, individual pages in the
skb can be detached and metastasize to other locations, e.g.,
the VFS"

> > 
> >>> and I think this applies here.
> >> I don't think so, but if you think I missed something, do not be shy (not that you ever are).
> > 
> > Well, I hope the reviews are helpful.
> 
> Yes, I didn't mean it as a slam.  Was only trying to convey that I
> didn't think I was wrong but am open minded to the possibility, so
> please keep the discussion going.
> 
> >  I'll be happy if we learn to
> > track pages involved in transmit, but need to be careful.
> > 
> 
> Agreed.
> 
> >>> In other words, this only *seems*
> >>> to work for you because you are not trying to do things like
> >>> guest to host communication, with host doing smart things.
> >> I am not following what you mean here, as I do use this for guest->host and guest->host->remote, and
> >> it works quite nicely.  I map the guest pages in, and when the last reference to the pages are dropped,
> >> I release the pages back to the guest.  It doesn't matter if the skb egresses out a physical adapter or is
> >> received locally.  All that matters is the lifetime of the shinfo (and thus its pages) is handled correctly.
> > 
> > Not if someone else is referencing the pages without a reference to shinfo.
> 
> I agree that if we can reference pages outside of the skb/shinfo then
> there is a problem.  I wasn't aware that we could do this, tbh.
> 
> However, it seems to me that this is a problem with the overall stack,
> if true....isn't it?  For instance, if I do a sendmsg() from a userspace
> app and block until its consumed,

consumed == memcpy_from_iovec?

> how can the system function sanely if
> the app returns from the call but something is still referencing the
> page(s)?

which pages?

>  This seems broken to me.
> > 
> >>> Cc Herbert which was involved in the original discussion.
> >>>
> >>> In the specific case, it seems that things like pskb_copy,
> >>> skb_split and others will also be broken, won't they?
> >> Not to my knowledge.   They up the reference to the shinfo before proceeding.
> > 
> > I don't seem to find where does skb_split reference the shinfo.
> > It seems to do get_page on individual pages?
> 
> Ill take a look.
> 
> If so, one alternate solution that I had considered was to look at some
> kind of page->release() hook.  There are obvious disadvantages to such a
> solution (for one, it has no such notion, and second we have to manage
> the aggregate collection which has overhead), so I shied away from that
> design in favor of this one.  But perhaps we will ultimately have no choice.
> 
> Kind Regards,
> -Greg
> 


